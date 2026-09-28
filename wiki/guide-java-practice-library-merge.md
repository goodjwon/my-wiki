---
title: "과제 2-3. API와 화면 병합 — 프록시·CORS·E2E·한 jar 배포"
type: synthesis
tags: [java, study, practice, spring, react, vite, cors, playwright, e2e, deploy]
sources: [java-study/practice/]
created: 2026-09-29
updated: 2026-09-29
---

# 과제 2-3. API와 화면 병합

> **이 과제의 목표**: [[guide-java-practice-spring-library]](과제 2)의 Spring API와 [[guide-java-practice-library-ui]](과제 2-2)의 React 화면을 **하나의 서비스로 합칩니다.** 개발할 때는 두 서버를 띄워 Vite 프록시로 잇고, 화면에 필요한 API 하나를 Spring에 추가하고, 브라우저를 자동으로 조작하는 Playwright E2E 테스트로 흐름 전체를 지킵니다. 마지막에는 화면을 jar 안에 넣어 `java -jar` 하나로 UI와 API를 함께 서비스합니다.
>
> **선수 학습**: 과제 2의 `library` 프로젝트(포트 8090, `h2` 프로파일, 테스트 9개 통과)와 과제 2-2의 `library-ui` 프로젝트(목업 모드 동작, 테스트 9개 통과)가 같은 디렉터리 아래 형제로 있어야 합니다.

---

## 과제 개요

과제 2-2의 화면은 목업 데이터로만 움직였습니다. 이번에는 목업을 걷어 내고 실제 API와 대화하게 합니다. 이때 부딪히는 문제는 세 가지입니다. 브라우저는 **출처(origin)가 다른 서버**의 응답을 기본으로 막고, 화면이 필요로 하는 **회원별 대출 목록 API가 과제 2에는 없고**, 두 프로젝트를 **각각 배포하면 운영이 번거롭습니다.** 단계마다 하나씩 해결합니다.

| 항목 | 내용 |
|------|------|
| 결과물 | 화면+API가 한 jar에 들어간 도서 대여 서비스 (`http://localhost:8090`) |
| 기술 | Vite `server.proxy` · Spring `WebMvcConfigurer` CORS · Spring Data `@EntityGraph` · Playwright 1.63 · exec-maven-plugin · maven-resources-plugin |
| 예상 소요 | 3~4시간 |
| 프로젝트 | `library`(과제 2) + `library-ui`(과제 2-2) — 두 프로젝트를 모두 수정합니다 |

### 학습 목표

| # | 목표 | 확인 방법 |
|---|------|----------|
| 1 | 같은 출처 정책과 CORS를 설명하고, 개발용 프록시와 서버 CORS 설정 중 알맞은 것을 고를 수 있습니다 | curl로 사전 요청(preflight) 확인 |
| 2 | 화면 요구에 맞춰 API를 추가하고 N+1 없이 연관 엔티티를 함께 읽을 수 있습니다 | `./mvnw test` 11개 통과 |
| 3 | 두 서버를 띄워 실제 데이터로 대출 → 409 → 반납 흐름을 확인할 수 있습니다 | 프록시 로그 |
| 4 | Playwright로 실제 브라우저 E2E 테스트를 쓰고 HTML 리포트를 읽을 수 있습니다 | `npx playwright test` 3개 통과 |
| 5 | Maven 빌드에 화면 빌드를 끼워 넣어 한 jar로 배포하고, 새로 고침에도 화면이 뜨게 할 수 있습니다 | `java -jar` 후 `/loans` 직접 열기 |

---

## 요구사항

번호(M1~M6)는 본문과 채점 기준에서 같은 뜻으로 씁니다.

| 번호 | 요구사항 | 확인 |
|------|---------|------|
| M1 | 개발 모드에서 화면(5173)의 `/api/...` 요청이 Spring(8090)에 전달됩니다. 화면 코드의 `baseURL`은 빈 문자열 그대로 둡니다 | 프록시 로그에 `-> 200` |
| M2 | 화면을 다른 출처에서 서비스하는 경우를 위해 `/api/**`에 한해 `http://localhost:5173`의 GET·POST를 허용하는 CORS 설정을 둡니다 | 사전 요청 200, 다른 출처 403 |
| M3 | `GET /api/members/{id}/loans` — 회원의 대출 목록을 최신순(대출 번호 역순)으로, 반납 건까지 돌려줍니다. 없는 회원이면 404 `MEMBER_NOT_FOUND` | API 테스트 2개 |
| M4 | 실제 API로 대출 → 중복 대출 → 반납 시나리오가 화면에서 동작하고, 409 안내가 과제 2-2의 한글 문구로 보입니다 | 화면 확인 |
| M5 | Playwright E2E 테스트 3개(메인 검색, 대출→409→반납, 연체)가 개발 모드와 jar 배포 양쪽에서 통과합니다. 여러 번 실행해도 결과가 같습니다 | `npx playwright test` |
| M6 | `./mvnw package`가 화면을 빌드해 jar에 넣고, `java -jar` 하나로 `/`·`/books`·`/loans`·`/members/new`(화면)와 `/api/**`(API)가 모두 8090에서 서비스됩니다 | curl 상태 코드 |

두 프로젝트의 최종 구조입니다. 이 과제에서 **추가하거나 바꾸는 파일에만** 표시를 붙였습니다.

```text
practice/
├── library/
│   ├── pom.xml                                         (수정) 화면 빌드·복사 플러그인
│   └── src/
│       ├── main/java/dev/wonslab/library/
│       │   ├── config/CorsConfig.java                  (추가) M2
│       │   ├── controller/MemberController.java        (수정) M3
│       │   ├── controller/SpaForwardController.java    (추가) M6
│       │   ├── repository/LoanRepository.java          (수정) M3
│       │   └── service/LoanService.java                (수정) M3
│       └── test/java/dev/wonslab/library/
│           └── controller/MemberLoansApiTest.java      (추가) M3
└── library-ui/
    ├── .env.direct                                     (추가) CORS 확인용 모드
    ├── .gitignore                                      (수정) 테스트 산출물 제외
    ├── vite.config.ts                                  (수정) M1 프록시
    ├── playwright.config.ts                            (추가) M5
    └── e2e/library.spec.ts                             (추가) M5
```

---

## 1. 개발 모드 연결 — 프록시와 CORS

**과제**: 화면 개발 서버(5173)에서 API(8090)를 부를 수 있게 합니다. 이 단계의 목표는 **브라우저가 왜 막는지 이해하고, 개발에는 프록시를, 다른 출처 배포에는 CORS를 쓰는 이유**를 설명할 수 있게 되는 것입니다.

브라우저는 보안을 위해 **같은 출처 정책**을 지킵니다. 출처는 "프로토콜 + 호스트 + 포트"이고, `http://localhost:5173`과 `http://localhost:8090`은 포트가 달라 **다른 출처**입니다. 5173에서 받은 화면의 자바스크립트가 8090에 요청하면, 서버가 "이 출처는 허용한다"는 CORS 헤더(`Access-Control-Allow-Origin`)를 보내지 않는 한 브라우저가 응답을 화면 코드에 넘기지 않습니다. 해결 방법은 두 가지이고, 6단계의 한 jar 배포까지 합치면 세 가지 배치가 나옵니다.

| 배치 | 브라우저가 보내는 주소 | 출처 | 서버에 필요한 설정 | 쓰는 때 |
|------|------|------|------|------|
| Vite 프록시 | `http://localhost:5173/api/...` → Vite가 8090으로 전달 | 같음 | 없음 | **개발 (권장)** |
| CORS 허용 | `http://localhost:8090/api/...`에 직접 | 다름 | `CorsConfig` | 화면을 별도 도메인·CDN에 배포할 때 |
| 한 jar 배포 | `http://localhost:8090/api/...` | 같음 | 없음 | 운영 (6단계) |

개발에 프록시를 권하는 이유는 세 가지입니다. 첫째, 화면 코드의 `baseURL`이 개발·운영 모두 빈 문자열 그대로라 **환경마다 주소를 바꿀 일이 없습니다.** 둘째, 서버에 개발 전용 CORS 설정이 남지 않습니다. 셋째, 운영(한 jar)과 같은 "같은 출처" 조건에서 개발하므로 쿠키·세션을 붙일 때 개발과 운영의 동작이 갈라지지 않습니다.

### 1-1. Vite 프록시

과제 2-2의 `vite.config.ts`에 `server.proxy`를 추가합니다. `'/api'`로 시작하는 요청을 Vite 개발 서버가 받아 `target`으로 대신 보내고, 응답을 그대로 브라우저에 돌려줍니다. 브라우저 입장에서는 5173하고만 대화하므로 CORS가 끼어들 틈이 없습니다. `configure`의 `proxyRes` 이벤트는 전달한 요청과 응답 상태를 터미널에 한 줄씩 찍어, 요청이 실제로 8090까지 갔는지 눈으로 확인하게 해 줍니다.

**파일**: library-ui/vite.config.ts

```ts
/// <reference types="vitest/config" />
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    proxy: {
      // /api로 시작하는 요청은 Vite 개발 서버가 받아 Spring(8090)에 대신 전달한다
      '/api': {
        target: 'http://localhost:8090',
        configure: (proxy) => {
          proxy.on('proxyRes', (res, req) => console.log(`[proxy] ${req.method} ${req.url} -> ${res.statusCode}`))
        },
      },
    },
  },
  test: {
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    include: ['src/**/*.test.tsx'],
  },
})
```

프록시는 개발 서버(`npm run dev`)에서만 동작합니다. `npm run build`로 만든 `dist/`에는 프록시가 없으므로, 배포할 때는 6단계처럼 화면과 API를 같은 서버에 두거나 CORS를 씁니다.

### 1-2. CORS 설정 (다른 출처에서 서비스할 때)

화면을 API와 다른 곳(예: 정적 호스팅)에서 서비스하면 프록시를 쓸 수 없으므로, 서버가 CORS 헤더로 허용해야 합니다. Spring MVC에서는 `WebMvcConfigurer`의 `addCorsMappings`로 경로·출처·메서드를 지정합니다. 허용 범위는 필요한 만큼만 좁힙니다 — `allowedOrigins("*")`로 열면 아무 사이트의 스크립트나 이 API를 부를 수 있습니다.

**파일**: library/src/main/java/dev/wonslab/library/config/CorsConfig.java

```java
package dev.wonslab.library.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    // 화면이 다른 출처(origin)에서 API를 직접 부를 때만 필요하다 — 프록시·한 jar 배포에서는 쓰이지 않는다
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:5173")
                .allowedMethods("GET", "POST");
    }
}
```

JSON 본문을 보내는 POST는 브라우저가 본 요청 전에 `OPTIONS` **사전 요청(preflight)** 으로 "이 출처에서 이 메서드를 써도 되는가"를 먼저 묻습니다. API를 `h2` 프로파일로 띄운 뒤(3단계의 터미널 1 명령), 사전 요청을 curl로 흉내 내 확인합니다.

```bash
cd library
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2        # Windows: mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=h2
```

새 터미널에서 허용된 출처와 허용되지 않은 출처로 한 번씩 묻습니다.

```bash
curl -s -i -X OPTIONS http://localhost:8090/api/loans -H 'Origin: http://localhost:5173' -H 'Access-Control-Request-Method: POST'
curl -s -i -X OPTIONS http://localhost:8090/api/loans -H 'Origin: http://evil.example' -H 'Access-Control-Request-Method: POST'
```

```text
예상 결과
HTTP/1.1 200
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Access-Control-Allow-Origin: http://localhost:5173
Access-Control-Allow-Methods: GET,POST
Access-Control-Max-Age: 1800
...
HTTP/1.1 403
Vary: Origin
...
Invalid CORS request
```

허용된 출처에는 `Access-Control-Allow-Origin` 헤더가 붙고, 허용되지 않은 출처는 403 `Invalid CORS request`로 거절됩니다. curl은 브라우저가 아니라서 CORS 헤더가 없어도 응답을 그대로 보여 줍니다 — **CORS는 서버가 아니라 브라우저가 지키는 규칙**이기 때문입니다.

> **Windows**: PowerShell에서는 `curl` 대신 `curl.exe`로 실행합니다. 헤더 값의 작은따옴표는 큰따옴표로 바꿔도 됩니다.

브라우저에서도 확인하려면 화면이 8090을 **직접** 부르는 모드를 만듭니다. 과제 2-2의 `.env.mock`과 같은 방식으로, `--mode direct`로 실행할 때 읽히는 환경 변수 파일을 둡니다.

**파일**: library-ui/.env.direct

```text
VITE_API_BASE_URL=http://localhost:8090
```

`library-ui`에서 `npm run dev -- --mode direct`로 띄우고 도서 목록을 열면, 요청이 8090으로 직접 나가는데도 CORS 설정 덕분에 목록이 보입니다. `CorsConfig`의 `allowedOrigins`를 다른 값으로 바꾸고 API를 재시작하면 화면에 "서버에 연결할 수 없습니다. API 서버가 실행 중인지 확인해 주세요."가 뜹니다 — 브라우저가 응답을 막아 axios가 응답 없는 오류를 받았기 때문이고, 브라우저 개발자 도구 콘솔에는 `blocked by CORS policy`가 찍힙니다. 확인이 끝나면 `CorsConfig`를 원래대로 돌리고 `Ctrl+C`로 개발 서버를 내립니다. 이후 단계는 모두 프록시(`npm run dev`)로 진행합니다.

---

## 2. API 보강 — 회원별 대출 목록

**과제**: 과제 2-2의 대출·반납 화면(S4)이 부르는 `GET /api/members/{id}/loans`를 Spring에 추가합니다(M3). 과제 2 도전 과제 1번과 같은 API입니다. 이 단계의 목표는 **화면 요구에서 API를 끌어내고, 목록 조회에서 생기기 쉬운 N+1 쿼리를 처음부터 막는 것**입니다.

| 파일 | 할 일 |
|------|------|
| `LoanRepository` | `findByMemberIdOrderByIdDesc(Long memberId)` 추가 — 도서를 함께 읽도록 `@EntityGraph(attributePaths = "book")` |
| `LoanService` | `findByMember(Long memberId)` 추가 — 회원이 없으면 `MEMBER_NOT_FOUND`, 있으면 `LoanResponse` 목록 |
| `MemberController` | `GET /{id}/loans` 추가 — 회원 하위 자원이므로 회원 컨트롤러에 둠 |
| `MemberLoansApiTest` | 최신순 정렬, 없는 회원 404 — 테스트 2개 |

`LoanResponse`에는 `bookTitle`이 들어 있어서, 대출 목록 N건을 변환하면 지연 로딩된 도서를 N번 읽습니다. 대출 목록 1번 + 도서 N번 = **N+1 쿼리**입니다. `@EntityGraph`는 이 메서드에 한해 도서를 조인으로 함께 읽으라고 지시해 쿼리를 1번으로 줄입니다. 엔티티의 `fetch = LAZY`는 그대로 두므로 다른 조회에는 영향이 없습니다.

??? example "모범 답안 — main 코드 3개 파일"

    대출 리포지토리입니다. 과제 2의 메서드 3개 아래에 목록 조회 메서드를 추가합니다.

    **파일**: library/src/main/java/dev/wonslab/library/repository/LoanRepository.java

    ```java
    package dev.wonslab.library.repository;

    import dev.wonslab.library.domain.Loan;
    import dev.wonslab.library.domain.LoanStatus;
    import java.time.LocalDate;
    import java.util.List;
    import org.springframework.data.jpa.repository.EntityGraph;
    import org.springframework.data.jpa.repository.JpaRepository;

    public interface LoanRepository extends JpaRepository<Loan, Long> {

        boolean existsByBookIdAndStatus(Long bookId, LoanStatus status);

        boolean existsByMemberIdAndStatusAndDueDateBefore(Long memberId, LoanStatus status, LocalDate date);

        long countByMemberIdAndStatus(Long memberId, LoanStatus status);

        @EntityGraph(attributePaths = "book")   // 도서를 조인으로 한 번에 읽어 N+1을 막는다
        List<Loan> findByMemberIdOrderByIdDesc(Long memberId);
    }
    ```

    대출 서비스입니다. 과제 2 코드에 `java.util.List` import와 맨 아래 `findByMember` 메서드만 추가됐습니다. 클래스의 `@Transactional(readOnly = true)`가 그대로 적용되므로 조회 메서드에는 따로 붙이지 않습니다.

    **파일**: library/src/main/java/dev/wonslab/library/service/LoanService.java

    ```java
    package dev.wonslab.library.service;

    import dev.wonslab.library.domain.Book;
    import dev.wonslab.library.domain.Loan;
    import dev.wonslab.library.domain.LoanStatus;
    import dev.wonslab.library.domain.Member;
    import dev.wonslab.library.dto.LoanRequest;
    import dev.wonslab.library.dto.LoanResponse;
    import dev.wonslab.library.exception.ErrorCode;
    import dev.wonslab.library.exception.LibraryException;
    import dev.wonslab.library.repository.BookRepository;
    import dev.wonslab.library.repository.LoanRepository;
    import dev.wonslab.library.repository.MemberRepository;
    import java.time.LocalDate;
    import java.util.List;
    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;

    @Service
    @Transactional(readOnly = true)
    public class LoanService {

        private final LoanRepository loanRepository;
        private final MemberRepository memberRepository;
        private final BookRepository bookRepository;

        public LoanService(LoanRepository loanRepository, MemberRepository memberRepository,
                           BookRepository bookRepository) {
            this.loanRepository = loanRepository;
            this.memberRepository = memberRepository;
            this.bookRepository = bookRepository;
        }

        @Transactional
        public LoanResponse loan(LoanRequest request) {
            Member member = memberRepository.findById(request.memberId())
                    .orElseThrow(() -> new LibraryException(ErrorCode.MEMBER_NOT_FOUND));
            Book book = bookRepository.findById(request.bookId())
                    .orElseThrow(() -> new LibraryException(ErrorCode.BOOK_NOT_FOUND));
            LocalDate today = LocalDate.now();

            if (loanRepository.existsByBookIdAndStatus(book.getId(), LoanStatus.LOANED)) {
                throw new LibraryException(ErrorCode.BOOK_ALREADY_LOANED);             // R3
            }
            if (loanRepository.existsByMemberIdAndStatusAndDueDateBefore(member.getId(), LoanStatus.LOANED, today)) {
                throw new LibraryException(ErrorCode.OVERDUE_MEMBER);                  // R4
            }
            if (loanRepository.countByMemberIdAndStatus(member.getId(), LoanStatus.LOANED) >= Loan.MAX_LOANS_PER_MEMBER) {
                throw new LibraryException(ErrorCode.LOAN_LIMIT_EXCEEDED);             // R5
            }
            return LoanResponse.from(loanRepository.save(new Loan(member, book, today)));
        }

        @Transactional
        public LoanResponse returnBook(Long loanId) {
            Loan loan = loanRepository.findById(loanId)
                    .orElseThrow(() -> new LibraryException(ErrorCode.LOAN_NOT_FOUND));
            loan.returnBook(LocalDate.now());                                          // R7
            return LoanResponse.from(loan);
        }

        public List<LoanResponse> findByMember(Long memberId) {
            if (!memberRepository.existsById(memberId)) {
                throw new LibraryException(ErrorCode.MEMBER_NOT_FOUND);
            }
            return loanRepository.findByMemberIdOrderByIdDesc(memberId).stream()
                    .map(LoanResponse::from)
                    .toList();
        }
    }
    ```

    회원 컨트롤러입니다. `LoanService`를 생성자로 하나 더 받고, `GET /{id}/loans`를 추가합니다.

    **파일**: library/src/main/java/dev/wonslab/library/controller/MemberController.java

    ```java
    package dev.wonslab.library.controller;

    import dev.wonslab.library.dto.LoanResponse;
    import dev.wonslab.library.dto.MemberCreateRequest;
    import dev.wonslab.library.dto.MemberResponse;
    import dev.wonslab.library.service.LoanService;
    import dev.wonslab.library.service.MemberService;
    import io.swagger.v3.oas.annotations.Operation;
    import io.swagger.v3.oas.annotations.tags.Tag;
    import jakarta.validation.Valid;
    import java.util.List;
    import org.springframework.http.HttpStatus;
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.PathVariable;
    import org.springframework.web.bind.annotation.PostMapping;
    import org.springframework.web.bind.annotation.RequestBody;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.ResponseStatus;
    import org.springframework.web.bind.annotation.RestController;

    @Tag(name = "회원")
    @RestController
    @RequestMapping("/api/members")
    public class MemberController {

        private final MemberService memberService;
        private final LoanService loanService;

        public MemberController(MemberService memberService, LoanService loanService) {
            this.memberService = memberService;
            this.loanService = loanService;
        }

        @Operation(summary = "회원 등록")
        @PostMapping
        @ResponseStatus(HttpStatus.CREATED)
        public MemberResponse register(@Valid @RequestBody MemberCreateRequest request) {
            return memberService.register(request);
        }

        @Operation(summary = "회원 단건 조회")
        @GetMapping("/{id}")
        public MemberResponse findById(@PathVariable Long id) {
            return memberService.findById(id);
        }

        @Operation(summary = "회원의 대출 목록 (최신순, 반납 포함)")
        @GetMapping("/{id}/loans")
        public List<LoanResponse> loans(@PathVariable Long id) {
            return loanService.findByMember(id);
        }
    }
    ```

??? example "모범 답안 — MemberLoansApiTest.java"

    새 API의 테스트입니다. 과제 2의 `LoanApiTest`와 같은 구성(`@SpringBootTest` + MockMvc + 테스트마다 롤백)으로, 대출 2건을 만든 뒤 나중 대출이 먼저 오는지와 없는 회원의 404를 확인합니다.

    **파일**: library/src/test/java/dev/wonslab/library/controller/MemberLoansApiTest.java

    ```java
    package dev.wonslab.library.controller;

    import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
    import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
    import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
    import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

    import dev.wonslab.library.domain.Book;
    import dev.wonslab.library.domain.Member;
    import dev.wonslab.library.repository.BookRepository;
    import dev.wonslab.library.repository.MemberRepository;
    import org.junit.jupiter.api.Test;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.boot.test.context.SpringBootTest;
    import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc; // Boot 3.x: org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
    import org.springframework.http.MediaType;
    import org.springframework.test.web.servlet.MockMvc;
    import org.springframework.transaction.annotation.Transactional;

    @SpringBootTest
    @AutoConfigureMockMvc
    @Transactional
    class MemberLoansApiTest {

        @Autowired
        MockMvc mockMvc;

        @Autowired
        MemberRepository memberRepository;

        @Autowired
        BookRepository bookRepository;

        @Test
        void 회원의_대출_목록을_최신순으로_돌려준다() throws Exception {
            Long memberId = memberRepository.save(new Member("김자바", "java@example.com")).getId();
            Long first = bookRepository.save(new Book("9788966262281", "이펙티브 자바", "조슈아 블로크")).getId();
            Long second = bookRepository.save(new Book("9791158391409", "오브젝트", "조영호")).getId();
            for (Long bookId : new Long[] {first, second}) {
                mockMvc.perform(post("/api/loans").contentType(MediaType.APPLICATION_JSON)
                                .content("{\"memberId\": %d, \"bookId\": %d}".formatted(memberId, bookId)))
                        .andExpect(status().isCreated());
            }

            mockMvc.perform(get("/api/members/{id}/loans", memberId))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(2))
                    .andExpect(jsonPath("$[0].bookTitle").value("오브젝트"))
                    .andExpect(jsonPath("$[1].bookTitle").value("이펙티브 자바"));
        }

        @Test
        void 없는_회원의_대출_목록은_404() throws Exception {
            mockMvc.perform(get("/api/members/{id}/loans", 999))
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.code").value("MEMBER_NOT_FOUND"));
        }
    }
    ```

`library`에서 전체 테스트를 실행합니다. 과제 2의 9개에 새 테스트 2개가 더해져 11개입니다.

```bash
./mvnw test        # Windows: mvnw.cmd test
```

```text
예상 결과
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 7.114 s -- in dev.wonslab.library.repository.LoanRepositoryTest
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.426 s -- in dev.wonslab.library.controller.LoanApiTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.213 s -- in dev.wonslab.library.controller.MemberLoansApiTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.974 s -- in dev.wonslab.library.LibraryApplicationTests
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

---

## 3. 두 터미널로 실행하고 실제 시나리오 확인

이 단계에서는 두 서버를 동시에 띄워 과제 2의 curl 시나리오(대출 → 중복 대출 → 반납)를 **화면에서** 다시 해 봅니다(M4). 서버마다 터미널을 하나씩 씁니다.

| 터미널 | 디렉터리 | 명령 | 포트 |
|------|------|------|------|
| 1 | `library` | `./mvnw spring-boot:run -Dspring-boot.run.profiles=h2` | 8090 (API) |
| 2 | `library-ui` | `npm run dev` | 5173 (화면 + 프록시) |

**터미널 1** — API를 `h2` 프로파일로 띄웁니다. 1-2에서 띄워 둔 서버가 있으면 `Ctrl+C`로 내리고 다시 띄워, 2단계의 새 API가 들어간 코드와 시드 상태의 DB로 시작합니다.

```bash
cd library
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2        # Windows: mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=h2
```

**터미널 2** — 화면 개발 서버를 **목업이 아닌** 실제 API 모드로 띄웁니다.

```bash
cd library-ui
npm run dev
```

```text
예상 결과
  VITE v8.3.1  ready in 306 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

과제 2-2의 `dev:mock`과 달리 `ready` 줄에 `mock`이 없습니다. 먼저 화면이 H2의 데이터를 읽는지 확인하기 위해, 새 터미널에서 도서를 한 권 curl로 등록합니다. 목업에는 없는 도서입니다.

```bash
curl -s -w '\n%{http_code}\n' -X POST http://localhost:8090/api/books -H 'Content-Type: application/json' -d '{"isbn":"9791162242025","title":"모던 자바 인 액션","author":"라울-게이브리얼 우르마"}'
```

```text
예상 결과
{"id":5,"isbn":"9791162242025","title":"모던 자바 인 액션","author":"라울-게이브리얼 우르마"}
201
```

> **Windows**: PowerShell에서는 1-2의 안내처럼 `curl.exe`로 실행합니다. JSON 따옴표가 번거로우면 Git Bash에서 실행하거나, Swagger UI(`http://localhost:8090/swagger-ui.html`)의 **도서 등록**으로 같은 본문을 보냅니다.

브라우저에서 `http://localhost:5173/`을 엽니다.

![실제 API와 연결된 메인 화면](assets/practice/merge/06-home-real.png)

*그림 1. 실제 API 연결 메인 — 방금 curl로 등록한 5번 도서가 신착 도서 맨 앞에 보임*

신착 도서 맨 앞의 "모던 자바 인 액션"은 curl로 Spring에 등록한 도서입니다. 화면 코드는 과제 2-2 그대로인데, 목업 대신 `GET /api/books`의 실제 응답으로 신착 도서를 골랐습니다. 메뉴 오른쪽에 "목업 데이터" 표시가 없는 것으로도 실제 API 모드임을 알 수 있습니다. 검색창에 `자바`를 넣고 **검색**을 누릅니다.

![실제 API의 검색 결과](assets/practice/merge/07-search-real.png)

*그림 2. 실제 API 검색 — `/books?keyword=자바`가 H2에서 3권을 찾음*

목업에서는 2권이던 결과가 3권입니다. 검색어가 프록시를 거쳐 Spring의 `findByTitleContainingOrAuthorContaining`까지 전달돼, H2에 새로 들어간 5번 도서까지 찾았습니다.

이제 대출 흐름을 확인합니다. `http://localhost:5173/loans`를 열고 회원 번호 `1`, 도서 `1. 이펙티브 자바`로 **대출**을 누릅니다.

![실제 API와 연결된 대출 화면](assets/practice/merge/01-integrated.png)

*그림 3. 실제 API 연결 — 메뉴 오른쪽에 "목업 데이터" 표시가 없고, 대출 목록은 H2 DB의 데이터*

화면 모양은 과제 2-2와 같지만, 대출 번호·날짜가 모두 Spring이 H2에 저장한 값입니다. 같은 상태에서 **대출**을 한 번 더 누릅니다.

![실제 API의 409 안내](assets/practice/merge/02-409-real.png)

*그림 4. 중복 대출 — Spring이 돌려준 409 `BOOK_ALREADY_LOANED`를 화면이 한글 안내로 표시*

이번 409는 목업이 아니라 과제 2의 `LoanService`가 R3 위반으로 던진 `LibraryException`이 `GlobalExceptionHandler`를 거쳐 나온 응답입니다. 목업과 실제 서버가 같은 `code`를 쓰기로 약속했기 때문에 화면 코드는 한 줄도 바꾸지 않았습니다. 이어서 대출 목록의 **반납**을 누르면 "반납 완료"로 바뀝니다.

터미널 2에는 1단계에서 넣은 프록시 로그가 요청마다 찍혀 있습니다. 아래는 `/loans`를 연 뒤의 줄만 옮긴 것입니다(그 앞에는 메인·검색 화면이 부른 `GET /api/books`, `GET /api/books?keyword=%EC%9E%90%EB%B0%94` 줄이 있습니다).

```text
예상 결과
[proxy] GET /api/books -> 200
[proxy] GET /api/books -> 200
[proxy] POST /api/loans -> 201
[proxy] GET /api/members/1/loans -> 200
[proxy] POST /api/loans -> 409
[proxy] POST /api/loans/2/return -> 200
[proxy] GET /api/members/1/loans -> 200
```

![프록시 로그](assets/practice/merge/03-proxy-log.png)

*그림 5. 터미널 2의 프록시 로그 — 화면의 요청이 8090으로 전달되고 돌아온 상태 코드*

한 줄이 요청 하나입니다. 대출(201) → 목록 갱신 → 중복 대출(409) → 반납(200) → 목록 갱신 순서가 화면에서 누른 순서와 같습니다. 첫 두 줄에서 `GET /api/books`가 두 번 나가는 것은 버그가 아닙니다 — 개발 모드의 React `StrictMode`는 부수 효과를 잘못 짠 코드를 드러내려고 `useEffect`를 일부러 두 번 실행합니다. 배포용 빌드에서는 한 번만 나갑니다.

두 서버는 다음 4단계에서도 그대로 씁니다. 내리지 않고 둡니다.

---

## 4. Playwright E2E 테스트

**과제**: 3단계에서 손으로 누른 흐름을 Playwright 테스트 3개로 고정합니다(M5). 이 단계의 목표는 **실제 브라우저가 실제 화면·프록시·API·DB를 모두 거치는 끝에서 끝까지(E2E) 테스트**를 갖추는 것입니다.

지금까지의 테스트와 E2E 테스트가 지키는 범위를 비교하면 다음과 같습니다. 셋은 서로를 대신하지 않습니다 — 아래로 갈수록 넓게 지키지만 느리고, 실패했을 때 원인을 좁히기 어렵습니다.

| 테스트 | 도구 | 무엇을 띄우나 | 무엇을 지키나 | 개수 |
|------|------|------|------|------|
| API 테스트 | JUnit + MockMvc | Spring 컨텍스트 (포트 없음) | 업무 규칙·상태 코드 | 11 |
| 화면 테스트 | Vitest + Testing Library | jsdom + 목업 | 화면 동작·안내 문구 | 9 |
| E2E 테스트 | Playwright | 실제 브라우저 + 두 서버 | 화면과 API의 **약속**(경로·JSON 모양·오류 코드) | 3 |

화면 테스트는 목업이 서버와 같다고 **가정**하고, API 테스트는 화면이 무엇을 부르는지 **모릅니다.** 둘 사이의 약속이 어긋나는 것(예: 서버가 `bookTitle`을 `title`로 바꿈)은 E2E만 잡을 수 있습니다.

`library-ui`에 Playwright를 설치하고, 테스트용 브라우저(Chromium)를 내려받습니다. 브라우저는 사용자 홈의 캐시 디렉터리에 한 번만 받습니다.

```bash
npm install -D @playwright/test
npx playwright install chromium
```

```text
예상 결과
Chrome Headless Shell 153.0.8010.12 (playwright chromium-headless-shell v1243) downloaded to ...
```

Playwright 설정 파일입니다. `baseURL`은 환경 변수 `BASE_URL`이 있으면 그 값을, 없으면 개발 서버(5173)를 씁니다. 5단계에서 같은 테스트를 jar(8090)에 그대로 돌리기 위한 장치입니다. 세 테스트가 같은 H2 DB를 공유하므로 `workers: 1`로 하나씩 순서대로 실행합니다.

**파일**: library-ui/playwright.config.ts

```ts
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  workers: 1, // 모든 테스트가 같은 H2 DB를 쓰므로 하나씩 순서대로 실행한다
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:5173',
  },
})
```

E2E 테스트 파일입니다. 요소는 Testing Library와 같은 방식(역할·라벨·보이는 글자)으로 찾습니다. 첫 번째 테스트는 메인(`/`)의 검색창에서 시작해 주소가 `/books?keyword=...`로 바뀌는지(`toHaveURL`)까지 확인합니다 — 화면 테스트가 `MemoryRouter`로 흉내 낸 주소 이동을 실제 브라우저에서 다시 지키는 것입니다. 두 번째 테스트는 빌린 도서를 마지막에 반납하므로 **몇 번을 다시 실행해도** 같은 결과가 나옵니다 — 공유 DB를 쓰는 E2E 테스트는 자기가 바꾼 상태를 되돌려 놓아야 합니다. `'대출'` 버튼에 `exact: true`를 붙이는 이유는 "대출 목록 보기" 버튼도 이름에 "대출"을 포함하기 때문입니다.

**파일**: library-ui/e2e/library.spec.ts

```ts
import { expect, test } from '@playwright/test'

test('메인 화면 검색 — 실제 API의 시드 도서를 걸러 보여 준다', async ({ page }) => {
  await page.goto('/books')
  await expect(page.getByRole('row')).toHaveCount(5) // 머리글 1 + 시드 도서 4
  await page.goto('/')
  await page.getByLabel('검색어').fill('자바')
  await page.getByRole('button', { name: '검색' }).click()
  await expect(page).toHaveURL(/\/books\?keyword=/)
  await expect(page.getByRole('row')).toHaveCount(3) // 머리글 1 + "자바" 도서 2
})

test('대출 → 중복 대출 409 → 반납', async ({ page }) => {
  await page.goto('/loans')
  await page.getByLabel('회원 번호').fill('1')
  await page.getByLabel('도서').selectOption({ label: '3. 클린 코드' })
  await page.getByRole('button', { name: '대출', exact: true }).click()
  await expect(page.getByRole('status')).toContainText("'클린 코드' 대출 완료")

  await page.getByRole('button', { name: '대출', exact: true }).click()
  await expect(page.getByRole('alert')).toHaveText('이미 대출 중인 도서입니다. 반납된 뒤에 다시 대출할 수 있습니다.')

  const loaned = page.getByRole('row').filter({ hasText: '클린 코드' }).filter({ hasText: '대출 중' })
  await loaned.getByRole('button', { name: '반납' }).click()
  await expect(page.getByRole('status')).toContainText("'클린 코드' 반납 완료")
  await expect(loaned).toHaveCount(0) // 반납했으므로 다시 실행해도 같은 결과
})

test('연체 회원 — 서버의 OVERDUE_MEMBER를 한글 안내로 보여 준다', async ({ page }) => {
  await page.goto('/loans')
  await page.getByLabel('회원 번호').fill('2')
  await page.getByLabel('도서').selectOption({ label: '1. 이펙티브 자바' })
  await page.getByRole('button', { name: '대출', exact: true }).click()
  await expect(page.getByRole('alert')).toContainText('연체 중인 도서가 있어 대출할 수 없습니다')
})
```

Playwright가 만드는 리포트·결과 디렉터리는 저장소에 올리지 않도록 `.gitignore` 끝에 추가합니다. 이 두 줄은 Git만을 위한 것이 아닙니다 — Tailwind v4는 `.gitignore`에 없는 파일을 모두 훑어 클래스 이름을 찾으므로, 리포트 HTML을 제외하지 않으면 쓰지도 않는 CSS가 빌드 결과에 섞여 들어갑니다.

**추가할 내용** (`library-ui/.gitignore` 끝에):

```text
playwright-report/
test-results/
```

첫 번째 테스트는 시드 도서 4권을 기대합니다. 3단계에서 curl로 5번 도서를 등록했으므로, **터미널 1의 API를 `Ctrl+C`로 내렸다가 같은 명령으로 다시 띄워** 시드 상태로 돌립니다(`create-drop`이라 재시작하면 DB가 초기화됩니다). 터미널 2의 화면 개발 서버는 그대로 둡니다. 그다음 `library-ui`의 새 터미널에서 E2E를 실행합니다.

```bash
npx playwright test
```

```text
예상 결과
Running 3 tests using 1 worker

  ✓  1 e2e/library.spec.ts:3:1 › 메인 화면 검색 — 실제 API의 시드 도서를 걸러 보여 준다 (1.2s)
  ✓  2 e2e/library.spec.ts:13:1 › 대출 → 중복 대출 409 → 반납 (923ms)
  ✓  3 e2e/library.spec.ts:29:1 › 연체 회원 — 서버의 OVERDUE_MEMBER를 한글 안내로 보여 준다 (433ms)

  3 passed (3.8s)
```

같은 명령을 한 번 더 실행해도 3개가 모두 통과해야 합니다(M5의 "여러 번 실행해도"). 두 번째 테스트가 빌린 도서를 반납하고 끝나므로, 도서 수와 대출 가능 상태가 실행 전과 같게 남기 때문입니다. HTML 리포트는 아래 명령으로 엽니다.

```bash
npx playwright show-report
```

![Playwright HTML 리포트](assets/practice/merge/04-playwright-report.png)

*그림 6. Playwright HTML 리포트 — 3개 테스트 모두 통과, 테스트마다 실행 시간*

리포트에서 테스트 이름을 누르면 단계별(`goto` → `fill` → `click` → `expect`) 실행 내역이 보입니다. 테스트가 실패하면 그 시점의 화면 스크린샷과 오류 메시지가 함께 남아, 어느 단계에서 무엇이 달랐는지 바로 알 수 있습니다. 리포트 서버는 `Ctrl+C`로 내립니다.

---

## 5. 한 jar로 배포

**과제**: `./mvnw package` 한 번에 화면까지 빌드해 jar 안에 넣고, `java -jar` 하나로 화면과 API를 8090에서 함께 서비스합니다(M6). 이 단계의 목표는 **"개발할 때는 둘, 배포할 때는 하나"** 구조를 만드는 것입니다.

Spring Boot는 클래스패스의 `static/` 디렉터리에 있는 파일을 그대로 웹에 내보내고, `static/index.html`은 `/` 주소의 첫 화면으로 씁니다. 따라서 화면 빌드 결과(`library-ui/dist/`)를 jar 안의 `static/`에 넣기만 하면 됩니다. 이 복사를 Maven 빌드 단계에 끼워 넣는 방법은 여러 가지이고, 이 과제는 가장 단순한 것을 고릅니다.

| 방법 | 동작 | 장점 | 단점 |
|------|------|------|------|
| **exec + resources 플러그인 (이 과제)** | Maven이 `npm run build`를 실행하고 `dist/`를 `target/classes/static/`에 복사 | 설정이 짧고, 원본 디렉터리(`src/`)를 건드리지 않음 | 빌드하는 PC에 Node.js가 있어야 함 |
| frontend-maven-plugin | Maven이 지정한 버전의 Node.js를 내려받아 설치·빌드까지 실행 | Node.js 없는 빌드 서버에서도 동작 | 설정이 길고 첫 빌드가 느림 |
| Vite `build.outDir`을 `../library/src/main/resources/static`으로 | 화면 빌드 결과를 Spring 원본 디렉터리에 직접 씀 | Maven 설정 없음 | 빌드 산출물이 `src/`에 섞여 Git에 올라가기 쉽고, 화면 빌드를 잊으면 옛 화면이 배포됨 |

두 플러그인을 **`prepare-package` 단계**에 붙이는 이유는 `./mvnw test`가 화면 빌드를 기다리지 않게 하기 위해서입니다. Maven은 `compile` → `test` → `prepare-package` → `package` 순서로 진행하므로, 테스트가 끝난 뒤 jar를 만들기 직전에만 화면을 빌드합니다. 같은 단계에 붙은 플러그인은 `pom.xml`에 적힌 순서대로 실행되므로, 빌드(exec)를 복사(resources)보다 위에 둡니다.

아래 블록을 `library/pom.xml`의 `<plugins>` 안, `spring-boot-maven-plugin` **위에** 붙여 넣습니다. `maven-resources-plugin`은 Spring Boot 부모 POM이 버전을 관리하므로 버전을 적지 않습니다.

**추가할 내용** (`library/pom.xml`의 `<build><plugins>` 안):

```xml
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>exec-maven-plugin</artifactId>
                <version>3.6.4</version>
                <executions>
                    <execution>
                        <id>build-ui</id>
                        <phase>prepare-package</phase>
                        <goals>
                            <goal>exec</goal>
                        </goals>
                        <configuration>
                            <executable>npm</executable>
                            <workingDirectory>${project.basedir}/../library-ui</workingDirectory>
                            <arguments>
                                <argument>run</argument>
                                <argument>build</argument>
                            </arguments>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-resources-plugin</artifactId>
                <executions>
                    <execution>
                        <id>copy-ui</id>
                        <phase>prepare-package</phase>
                        <goals>
                            <goal>copy-resources</goal>
                        </goals>
                        <configuration>
                            <outputDirectory>${project.build.outputDirectory}/static</outputDirectory>
                            <resources>
                                <resource>
                                    <directory>${project.basedir}/../library-ui/dist</directory>
                                </resource>
                            </resources>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
```

> **Windows**: `exec-maven-plugin`이 `npm`을 찾지 못한다는 오류(`Cannot run program "npm"`)가 나면 `<executable>npm</executable>`을 `<executable>npm.cmd</executable>`로 바꿉니다. Windows의 npm은 `npm.cmd`라는 배치 파일입니다.

### 5-1. 새로 고침 대비 — SPA 경로 전달

jar로 띄운 뒤 메뉴를 눌러 `/loans`로 이동하는 것은 문제가 없습니다. 화면 안에서 React Router가 주소만 바꾸고 서버에는 묻지 않기 때문입니다. 그런데 그 상태에서 **새로 고침**하거나 주소창에 `http://localhost:8090/loans`를 직접 치면, 브라우저가 서버에 `/loans`를 요청하고 Spring에는 그런 파일도 컨트롤러도 없어 404가 납니다. 개발 서버(Vite)는 모르는 주소에 `index.html`을 대신 주도록 되어 있어서 3단계에서는 드러나지 않았던 문제입니다.

검색어가 붙은 `/books?keyword=자바`도 마찬가지입니다. `?` 뒤의 검색어는 경로가 아니므로 서버는 `/books`만 보고 판단합니다. 화면의 주소를 받아 `index.html`로 넘겨 주는 컨트롤러를 추가합니다. `forward:`는 브라우저 주소를 바꾸지 않고 서버 안에서 `/index.html`을 대신 내려 주므로, 화면이 뜬 뒤 React Router가 주소(`/loans`)를 보고 알맞은 페이지를 그립니다. 경로를 명시해 두면 `/api/...`나 오타 주소는 지금처럼 404로 남습니다.

**파일**: library/src/main/java/dev/wonslab/library/controller/SpaForwardController.java

```java
package dev.wonslab.library.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SpaForwardController {

    // React 라우터가 그리는 주소를 새로 고침하거나 직접 열면 index.html을 내려 준다 (/api는 해당 없음)
    @GetMapping({"/books", "/loans", "/members/new"})
    public String forward() {
        return "forward:/index.html";
    }
}
```

화면에 주소를 추가하면 이 목록에도 추가해야 합니다. 모든 화면 주소를 자동으로 넘기는 방법은 도전 과제 3번에 있습니다.

### 5-2. 패키징과 실행

3단계의 두 서버를 모두 `Ctrl+C`로 내리고, `library`에서 패키징합니다. 테스트 11개가 먼저 돌고, 이어서 화면 빌드와 복사가 실행됩니다.

```bash
cd library
./mvnw package        # Windows: mvnw.cmd package
```

```text
예상 결과
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0
[INFO] --- exec:3.6.4:exec (build-ui) @ library ---
> library-ui@0.0.0 build
> tsc -b && vite build
✓ built in 780ms
[INFO] --- resources:3.5.0:copy-resources (copy-ui) @ library ---
[INFO] Copying 4 resources from ../library-ui/dist to target/classes/static
[INFO] --- jar:3.5.1:jar (default-jar) @ library ---
[INFO] BUILD SUCCESS
```

`exec` → `copy-resources` → `jar` 순서로 찍히면 화면이 jar에 들어간 것입니다. jar 안의 파일 목록으로 한 번 더 확인합니다.

```bash
jar tf target/library-0.0.1-SNAPSHOT.jar | grep static        # Windows: jar tf target\library-0.0.1-SNAPSHOT.jar | findstr static
```

```text
예상 결과
BOOT-INF/classes/static/
BOOT-INF/classes/static/assets/
BOOT-INF/classes/static/index.html
BOOT-INF/classes/static/assets/index-BmvtXgMr.css
BOOT-INF/classes/static/assets/index-CXhSjJ8L.js
BOOT-INF/classes/static/favicon.svg
```

jar 하나로 실행합니다. 이제 Vite 개발 서버는 필요 없습니다.

```bash
java -jar target/library-0.0.1-SNAPSHOT.jar --spring.profiles.active=h2
```

새 터미널에서 화면 주소와 API 주소가 모두 8090에서 응답하는지 확인합니다. `-w`는 상태 코드와 응답 형식만 출력하게 합니다.

```bash
for p in / /books /loans /members/new /api/books /api/members/1/loans /nope; do echo "$p $(curl -s -o /dev/null -w '%{http_code} %{content_type}' http://localhost:8090$p)"; done
```

```text
예상 결과
/ 200 text/html
/books 200 text/html
/loans 200 text/html
/members/new 200 text/html
/api/books 200 application/json
/api/members/1/loans 200 application/json
/nope 404 application/json
```

> **Windows**: 위 `for` 명령은 Git Bash에서 실행합니다. PowerShell에서는 `curl.exe -s -o NUL -w "%{http_code}" http://localhost:8090/loans`처럼 주소를 하나씩 확인합니다.

화면 주소 4개는 `text/html`(같은 `index.html`), API 2개는 `application/json`, 없는 주소는 404입니다. 브라우저에서 `http://localhost:8090/members/new`를 **직접** 열고 회원을 한 명 가입시킵니다.

![jar 하나로 서비스되는 화면](assets/practice/merge/05-jar-8090.png)

*그림 7. `java -jar`로 띄운 8090 — 주소를 직접 연 회원 등록 화면에서 가입 성공*

주소를 직접 열었는데도 화면이 뜨는 것은 5-1의 전달 컨트롤러 덕분이고, "3번 회원" 번호는 jar 안의 Spring이 H2에 저장한 값입니다. 화면과 API가 같은 출처(8090)이므로 프록시도 CORS도 쓰이지 않았습니다.

마지막으로 4단계의 E2E 테스트를 **jar에 그대로** 실행합니다. `BASE_URL`만 바꾸면 됩니다. `library-ui`에서 실행합니다.

```bash
BASE_URL=http://localhost:8090 npx playwright test        # Windows(PowerShell): $env:BASE_URL="http://localhost:8090"; npx playwright test
```

```text
예상 결과
Running 3 tests using 1 worker

  ✓  1 e2e/library.spec.ts:3:1 › 메인 화면 검색 — 실제 API의 시드 도서를 걸러 보여 준다 (880ms)
  ✓  2 e2e/library.spec.ts:13:1 › 대출 → 중복 대출 409 → 반납 (624ms)
  ✓  3 e2e/library.spec.ts:29:1 › 연체 회원 — 서버의 OVERDUE_MEMBER를 한글 안내로 보여 준다 (344ms)

  3 passed (3.0s)
```

개발 모드(5173 + 프록시)와 배포 모드(8090 jar)에서 같은 테스트가 통과하므로, 두 배치에서 화면이 똑같이 동작한다는 것이 확인됩니다. 확인이 끝나면 jar 터미널에서 `Ctrl+C`로 서버를 내립니다.

### 자주 나는 에러 → 원인

| 증상 | 원인 | 해결 |
|------|------|------|
| 개발 모드 화면에 "서버에 연결할 수 없습니다" | 터미널 1의 API가 꺼져 있음 — 프록시 로그에 `http proxy error: /api/books ... ECONNREFUSED` | API를 먼저 띄우고 화면을 새로 고침 |
| 대출 목록 보기에서 "서버에 연결할 수 없습니다", 프록시 로그는 `-> 404` | 2단계 API 추가 전 코드로 띄운 서버 — 404 본문이 과제 2의 오류 JSON이 아님 | 2단계 적용 후 API 재시작 |
| `npm run dev -- --mode direct`에서 목록이 안 보이고 콘솔에 `blocked by CORS policy` | `CorsConfig` 없음, 또는 `allowedOrigins`와 화면 주소(포트 포함)가 다름 | 1-2 설정 확인, `http://localhost:5173`와 정확히 일치시킴 |
| Playwright `Executable doesn't exist ... chromium` | 테스트용 브라우저 미설치 | `npx playwright install chromium` |
| E2E 첫 테스트가 `Expected: 5, Received: 6`처럼 행 수 불일치 | 3단계에서 curl로 도서를 등록해 DB가 시드 상태가 아님 | API 재시작 후 다시 실행 |
| `./mvnw package`에서 `Cannot run program "npm"` | PATH에 Node.js가 없거나(Windows는) `npm.cmd` 이름 문제 | `node -v` 확인, Windows는 `<executable>npm.cmd</executable>` |
| `./mvnw package`의 `build-ui`에서 `npm error ... package.json`(또는 `Missing script: "build"`) 후 `Command execution failed` | `library-ui`가 `library`의 형제 위치에 없어 npm이 엉뚱한 디렉터리에서 실행됨 | 두 디렉터리를 같은 부모 아래에 둠 (`../library-ui`) |
| jar에서 `/`는 되는데 `/loans` 새로 고침이 404 | `SpaForwardController` 누락, 또는 새 화면 주소를 목록에 추가하지 않음 | 5-1 확인 |
| jar에서 옛 화면이 보임 | 브라우저 캐시, 또는 `prepare-package` 없이 `./mvnw compile`만 실행 | `./mvnw package`로 다시 만들고 강력 새로 고침 |

---

## 채점 기준·셀프 체크

제출 전에 아래 항목을 스스로 점검합니다. 괄호 안은 배점입니다(100점).

| 영역 | 기준 | 배점 |
|------|------|------|
| 개발 모드 연결 | Vite 프록시로 `baseURL` 변경 없이 연결(M1), CORS 설정을 필요한 경로·출처·메서드로 좁힘(M2) | 20 |
| API 보강 | `GET /api/members/{id}/loans` 최신순·404(M3), `@EntityGraph`로 N+1 방지, 테스트 2개 추가 | 20 |
| 통합 동작 | 실제 API로 대출 → 409 한글 안내 → 반납(M4) | 15 |
| E2E 테스트 | Playwright 3개, 재실행해도 통과, 개발·jar 양쪽 통과(M5) | 25 |
| 한 jar 배포 | `./mvnw package`로 화면 포함, 새로 고침에도 화면 유지, `/api` 404 동작 유지(M6) | 20 |

- [ ] `./mvnw test`가 `Tests run: 11`로 끝납니다
- [ ] 개발 모드 프록시 로그에 `POST /api/loans -> 409`가 찍히고 화면에 한글 안내가 보입니다
- [ ] `npx playwright test`를 두 번 연속 실행해도 3개 모두 통과합니다
- [ ] `java -jar` 후 `http://localhost:8090/loans`를 직접 열어도 화면이 뜹니다
- [ ] `BASE_URL=http://localhost:8090 npx playwright test`가 통과합니다
- [ ] 화면 코드(`library-ui/src/`)는 과제 2-2에서 바뀐 것이 없습니다

---

## 도전 과제

기본 과제를 마쳤다면 아래 중 하나 이상을 골라 확장해 봅니다. 위에 있을수록 쉽습니다.

| # | 과제 | 배우는 것 |
|---|------|----------|
| 1 | `show-sql` 로그에서 대출 목록 조회의 SELECT 수를 `@EntityGraph`가 있을 때와 없을 때 비교 (대출 3건 기준) | N+1을 로그로 확인하는 법 |
| 2 | CORS 허용 출처를 `application.yml`의 `app.cors.allowed-origins` 값으로 빼고, `@Value`로 주입 | 환경별 설정 분리 ([[java-study-ch06]] 6.3) |
| 3 | `SpaForwardController`의 주소 목록 대신, 점(`.`)이 없고 `/api`로 시작하지 않는 모든 GET을 `index.html`로 넘기기 | 경로 패턴, 화면 주소 추가 시 서버 수정 제거 |
| 4 | Playwright `webServer` 설정으로 테스트 실행 시 두 서버를 자동으로 띄우고 끝나면 내리기 | 테스트 환경 자동화 |
| 5 | GitHub Actions에서 `./mvnw package` → jar 실행 → `BASE_URL=http://localhost:8090 npx playwright test`까지 한 번에 | CI 파이프라인 |
| 6 | 멀티 스테이지 Dockerfile — 1단계 Node로 화면 빌드, 2단계 Maven 패키징, 3단계 JRE만으로 실행 | 컨테이너 이미지 크기 줄이기 |

---

## 관련 페이지

- [[guide-java-practice-spring-library]] — 과제 2. 이 과제에서 보강한 도서 대여 REST API
- [[guide-java-practice-library-ui]] — 과제 2-2. 이 과제에서 실제 API와 연결한 React 화면
- [[guide-java-track4-spring-web]] — Spring 웹 트랙 코스 안내
- [[java-study-ch06]] — Spring Boot 프로젝트·프로파일·정적 리소스
- [[java-study-ch09]] — 테스트 전략 (단위·통합·E2E의 역할 나누기)
