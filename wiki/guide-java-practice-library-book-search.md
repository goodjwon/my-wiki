---
title: "과제 2-4. 외부 API 연동 — 카카오 책 검색으로 도서 등록"
type: synthesis
tags: [java, study, practice, spring, restclient, external-api, kakao, react, vitest, test]
sources: [java-study/practice/]
created: 2026-09-29
updated: 2026-09-29
---

# 과제 2-4. 외부 API 연동 — 카카오 책 검색으로 도서 등록

> **이 과제의 목표**: 지금까지는 우리 서버와 우리 화면만 다뤘습니다. 이번에는 **남의 서버**를 부릅니다. 카카오(다음) 책 검색 API를 Spring의 `RestClient`로 호출해 제목·저자·ISBN·표지를 받아 오고, 사서가 결과를 골라 H2 DB에 바로 등록하는 **도서 가져오기** 화면(`/books/import`)을 만듭니다. API 키를 코드와 저장소 밖에 두는 법, 외부 서버의 실패를 우리 API의 오류 코드로 바꾸는 법, 네트워크 없이 외부 호출을 테스트하는 법이 핵심입니다.
>
> **선수 학습**: [[guide-java-practice-library-merge]](과제 2-3)를 마친 `library`(테스트 11개 통과)와 `library-ui`(테스트 9개 통과, 한 jar 배포 동작)가 형제 디렉터리로 있어야 합니다. 설정 파일과 프로파일은 [[java-study-ch06]] 6.3을 참고합니다.

> 📌 **왜 네이버가 아니라 카카오인가**: 도서 검색 실습에 널리 쓰이던 네이버 검색 API의 책 검색은 2026년 7월 31일 서비스가 종료됐습니다([네이버 개발자센터 공지](https://developers.naver.com/notice/article/32564) — 쇼핑·책·전문자료 API 종료). 지금 호출하면 404가 돌아옵니다. 이것 자체가 이 과제의 교훈입니다. **외부 API는 어느 날 사라집니다.** 그래서 이 과제는 카카오 호출 코드를 `BookSearchClient` 인터페이스 뒤에 두어, 제공자가 바뀌어도 컨트롤러와 화면은 손대지 않게 만듭니다.

---

## 과제 개요

도서를 한 권 등록하려면 사서가 ISBN 13자리와 제목·저자를 손으로 쳐야 했습니다. 카카오 책 검색에서 찾은 결과를 골라 버튼 하나로 등록하면 오타도 줄고 시간도 줄어듭니다. 대신 새로운 문제가 넷 생깁니다. 외부 API는 **키**를 요구하고, **느리거나 실패할 수 있고**, 응답 JSON의 모양을 **우리가 정하지 못하고**, 위 공지처럼 **없어질 수도 있습니다.** 단계마다 하나씩 다룹니다.

| 항목 | 내용 |
|------|------|
| 결과물 | `GET /api/external/books?query=` (카카오 책 검색 중계) + 도서 가져오기 화면 `/books/import` |
| 기술 | Spring `RestClient` · `@ConfigurationProperties` · `MockRestServiceServer`(`@RestClientTest`) · React · Vitest |
| 예상 소요 | 3~4시간 (카카오디벨로퍼스 앱 등록 10분 포함) |
| 프로젝트 | `library`와 `library-ui` 두 프로젝트를 모두 수정합니다 |
| DB | 지금까지와 같은 H2 (`h2` 프로파일) |

### 학습 목표

| # | 목표 | 확인 방법 |
|---|------|----------|
| 1 | 외부 API 키를 저장소·화면 번들 밖(로컬 파일·환경 변수)에 두고 설정 클래스로 읽을 수 있습니다 | `git status`에 키 파일이 안 보임 |
| 2 | `RestClient`로 외부 API를 호출하고, 필요한 필드만 읽는 응답 클래스를 만들 수 있습니다 | `curl .../api/external/books` |
| 3 | 외부 서버의 실패(401·타임아웃)를 우리 API의 502 `EXTERNAL_API_ERROR`로 바꿀 수 있습니다 | 키 없이 실행해 502 확인 |
| 4 | `MockRestServiceServer`로 네트워크 없이 외부 호출을 테스트할 수 있습니다 | `./mvnw test` 14개 통과 |
| 5 | 검색 결과를 골라 기존 도서 등록 API로 보내고, 중복은 409 안내로 보여 줄 수 있습니다 | `npm test` 12개 통과 |

---

## 요구사항

번호(K1~K6)는 본문과 채점 기준에서 같은 뜻으로 씁니다.

| 번호 | 요구사항 | 확인 |
|------|---------|------|
| K1 | 카카오 REST API 키는 `application-local.yml`(Git 제외) 또는 환경 변수 `KAKAO_REST_API_KEY`로만 넣습니다. 저장소에는 값이 빈 설정과 `application-local.yml.example`만 올라갑니다 | `git check-ignore` |
| K2 | `GET /api/external/books?query=자바` — 카카오 책 검색 결과를 `{title, author, publisher, isbn, image}` 목록으로 돌려줍니다. 저자 배열은 `, `로 잇고, ISBN은 13자리 하나만 고릅니다 | curl |
| K3 | 카카오가 4xx·5xx를 돌려주거나 연결 3초·응답 5초를 넘기면 502 `EXTERNAL_API_ERROR`로 응답합니다. 로그에는 원인을 남기되 **키는 남기지 않습니다** | 키 없이 실행 |
| K4 | 카카오를 부르지 않는 테스트 3개(변환·헤더, 401, 타임아웃)가 `./mvnw test`에 포함됩니다 | 14개 통과 |
| K5 | 도서 가져오기 화면(`/books/import`) — 검색창 → 결과 카드(표지·제목·저자·출판사·ISBN) → **등록**. 등록은 과제 2의 `POST /api/books`를 그대로 쓰고, 같은 ISBN이면 409 `DUPLICATE_ISBN`을 한글 안내로 보여 줍니다 | 화면 확인 |
| K6 | 목업 모드(`npm run dev:mock`)에서는 고정 검색 결과 3건으로 K5 흐름이 동작하고, 한 jar 배포에서 `/books/import`를 직접 열어도 화면이 뜹니다 | Vitest 3개, curl |

이 과제에서 추가하거나 바꾸는 파일입니다.

```text
practice/
├── library/
│   ├── .gitignore                                      (수정) application-local.yml 제외
│   ├── application-local.yml.example                   (추가) K1 키 파일 예시
│   ├── kakao-stub/                                     (추가) 4-2 대역 서버
│   ├── pom.xml                                         (수정) restclient 스타터 2개
│   └── src/
│       ├── main/java/dev/wonslab/library/
│       │   ├── controller/ExternalBookController.java  (추가) K2
│       │   ├── controller/SpaForwardController.java    (수정) K6
│       │   ├── dto/ExternalBookResponse.java           (추가) K2
│       │   ├── exception/ErrorCode.java                (수정) K3
│       │   └── external/
│       │       ├── BookSearchClient.java               (추가) 제공자 교체 지점
│       │       ├── KakaoProperties.java                (추가) K1
│       │       ├── KakaoBookSearchResponse.java        (추가) K2
│       │       └── KakaoBookClient.java                (추가) K2·K3
│       ├── main/resources/application.yml              (수정) 타임아웃·kakao 기본값
│       └── test/
│           ├── java/dev/wonslab/library/external/KakaoBookClientTest.java   (추가) K4
│           └── resources/kakao/book-search.json        (추가) K4 고정 응답
└── library-ui/src/
    ├── App.tsx                                         (수정) 메뉴·주소 추가
    ├── api/types.ts · errors.ts · http.ts · mock.ts    (수정) K5·K6
    └── pages/ImportPage.tsx · ImportPage.test.tsx      (추가) K5·K6
```

---

## 1. 키 발급과 보관 — 저장소와 화면 밖에 두기

**과제**: 카카오디벨로퍼스에서 **본인 계정으로** 앱을 만들어 REST API 키를 받고, 그 키가 Git 저장소에도 화면 번들에도 들어가지 않게 보관 장소를 정합니다. 이 단계의 목표는 **"키는 코드가 아니라 실행 환경에 속한다"** 는 원칙을 설정 파일 구조로 만드는 것입니다.

### 1-1. 앱 만들고 REST API 키 받기

카카오 책 검색은 요청마다 `Authorization: KakaoAK {REST API 키}` 헤더를 요구합니다. 각자 발급받아 씁니다 — 남의 키를 빌려 쓰면 호출 한도와 책임이 그 사람에게 갑니다.

| 순서 | 할 일 |
|------|------|
| 1 | [카카오디벨로퍼스](https://developers.kakao.com)에 카카오 계정으로 로그인합니다 |
| 2 | 상단 **내 애플리케이션 → 애플리케이션 추가하기**를 엽니다 |
| 3 | 앱 이름은 `library-practice`처럼 자유롭게, 회사명에는 본인 이름, 카테고리는 **교육**처럼 가까운 것을 고르고 저장합니다 |
| 4 | 만든 앱의 관리 페이지에서 **앱 → 플랫폼 키 → REST API 키**를 열어 값을 복사합니다 |
| 5 | (선택) 같은 화면의 **호출 허용 IP 주소**에 내 PC의 공인 IP를 넣으면, 키가 새어 나가도 다른 곳에서는 쓸 수 없습니다 |

책 검색은 공식 문서의 요구 사항이 REST API 키 하나뿐이라 동의 항목이나 플랫폼 등록 없이 바로 호출할 수 있습니다. 카카오 API에는 월간·일간 쿼터가 있으며 현재 한도는 카카오디벨로퍼스 문서의 **쿼터** 항목에서 확인합니다. 실습 수준에서는 넉넉한 양입니다.

### 1-2. 키를 두면 안 되는 곳

키를 받으면 가장 먼저 **어디에 두지 않을지**를 정합니다.

| 두는 곳 | 되는가 | 이유 |
|------|------|------|
| Java 코드·`application.yml`에 직접 | 안 됨 | 커밋하는 순간 저장소를 볼 수 있는 모든 사람에게 공개되고, 커밋 기록에서 지우기도 어렵습니다 |
| 화면의 `.env` (`VITE_KAKAO_REST_API_KEY` 등) | 안 됨 | `VITE_`로 시작하는 변수는 빌드할 때 **자바스크립트 파일에 문자 그대로 박힙니다.** 브라우저 개발자 도구로 누구나 읽을 수 있습니다 |
| 화면에서 카카오를 직접 호출 | 안 됨 | 카카오 검색 API는 브라우저 요청(CORS)을 허용하므로 **기술적으로는 됩니다.** 하지만 키를 브라우저에 보내야 하므로 위 줄과 같은 이유로 새어 나갑니다 |
| **서버**의 Git 제외 로컬 파일 `application-local.yml` | 됨 | 이 PC에만 있고, 서버만 읽고, 화면에는 결과만 나갑니다 |
| **서버**의 환경 변수 `KAKAO_REST_API_KEY` | 됨 | 파일조차 남지 않습니다. 배포 환경(CI·컨테이너)에서 쓰는 방식입니다 |

그래서 구조는 **화면 → 우리 서버(키 보유) → 카카오**입니다. 화면은 `/api/external/books`만 알고, 키는 서버 밖으로 나가지 않습니다. 과제 2-3의 프록시가 "브라우저는 5173하고만 대화한다"였던 것과 같은 모양입니다.

### 1-3. 로컬 키 파일과 Git 제외

`library`의 `.gitignore` 끝에 로컬 키 파일을 추가합니다. **파일을 만들기 전에** 먼저 추가해야 실수로 커밋될 틈이 없습니다.

**추가할 내용** (`library/.gitignore` 끝에):

```text
### 로컬 비밀 값 (커밋 금지) ###
application-local.yml
```

저장소에는 값 대신 **예시 파일**을 올립니다. 새로 합류한 사람이 이 파일을 복사해 자기 키를 채우면 됩니다.

**파일**: library/application-local.yml.example

```yaml
# 이 파일을 복사해 application-local.yml을 만들고, 발급받은 값으로 바꾼다
# application-local.yml은 .gitignore에 있으므로 커밋되지 않는다 — 이 예시 파일에는 진짜 값을 넣지 않는다
kakao:
  rest-api-key: 여기에-REST-API-키
```

예시 파일을 복사해 실제 키 파일을 만들고, `여기에-REST-API-키`를 1-1에서 복사한 값으로 바꿉니다.

```bash
cd library
cp application-local.yml.example application-local.yml        # Windows: copy application-local.yml.example application-local.yml
git check-ignore -v application-local.yml
```

```text
예상 결과
.gitignore:36:application-local.yml	application-local.yml
```

`git check-ignore`는 Git 저장소 안에서만 동작합니다(`library`를 아직 `git init`하지 않았다면 `fatal: not a git repository`가 납니다). 규칙 한 줄을 출력하면 Git이 이 파일을 무시한다는 뜻입니다(줄 번호는 `.gitignore` 길이에 따라 다릅니다). 아무것도 출력하지 않으면 `.gitignore`가 적용되지 않은 것이므로 파일 이름부터 다시 확인합니다.

이 파일을 `src/main/resources`가 아니라 **프로젝트 루트**에 두는 데도 이유가 있습니다. `src/main/resources` 안의 파일은 `./mvnw package`가 jar 안에 넣으므로, jar를 누군가에게 건네면 키도 함께 건너갑니다. Spring Boot는 클래스패스 말고도 **실행한 디렉터리**(`./`)의 `application-{프로파일}.yml`을 읽으므로, `local` 프로파일을 켜고 `library`에서 실행하면 루트의 파일이 적용됩니다.

| 실행 방법 | 키 전달 방식 | 명령 (`library`에서) |
|------|------|------|
| 로컬 파일 | `local` 프로파일 → `./application-local.yml` | `./mvnw spring-boot:run -Dspring-boot.run.profiles=h2,local` |
| 환경 변수 (Mac·Linux) | `KAKAO_REST_API_KEY` → `application.yml`의 `${KAKAO_REST_API_KEY:}` | `KAKAO_REST_API_KEY=값 ./mvnw spring-boot:run -Dspring-boot.run.profiles=h2` |
| 환경 변수 (Windows PowerShell) | 같음 | `$env:KAKAO_REST_API_KEY="값"; mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=h2` |

환경 변수는 2단계 `application.yml`의 `rest-api-key: ${KAKAO_REST_API_KEY:}` 한 줄이 읽습니다. `${이름:}`은 "환경 변수 `이름`의 값, 없으면 빈 문자열"이라는 뜻이라 설정 파일만 봐도 값이 어디서 오는지 드러납니다. 로컬 파일을 함께 쓰면 `application-local.yml`의 값이 이 줄보다 우선합니다. 이 과제의 나머지 명령은 로컬 파일 방식(`h2,local`)을 기준으로 적습니다.

---

## 2. 외부 API 클라이언트 — RestClient

**과제**: 카카오 책 검색을 부르는 클라이언트와, 그 결과를 우리 모양으로 돌려주는 API를 만듭니다. 이 단계의 목표는 **외부 서버의 사정(키 헤더, 응답 모양, 실패)을 `external` 패키지 한 곳에 가두는 것**입니다. 컨트롤러와 화면은 카카오라는 이름조차 몰라도 됩니다.

카카오 책 검색 API의 요청과 응답입니다(카카오디벨로퍼스 **Daum 검색 → REST API → 책 검색** 문서 기준).

| 항목 | 값 |
|------|------|
| 요청 | `GET https://dapi.kakao.com/v3/search/book?query=자바&size=10` |
| 필수 헤더 | `Authorization: KakaoAK {REST API 키}` |
| 선택 파라미터 | `sort`(`accuracy` 정확도순·`latest` 발간일순), `page`(1~50), `size`(1~50, 기본 10), `target`(`title`·`isbn`·`publisher`·`person`) |
| 응답 (필요한 것만) | `documents[]` 안의 `title`, `authors`, `publisher`, `isbn`, `thumbnail` |
| 응답 (읽지 않는 것) | `meta`(`total_count`·`pageable_count`·`is_end`), `contents`, `url`, `datetime`, `translators`, `price`, `sale_price`, `status` |
| 오류 응답 | 인증 실패 401 `{"errorType": "AccessDeniedError", "message": "..."}` 등 |

카카오의 `documents[]`를 그대로 화면에 넘기지 않고 다듬는 이유는 값의 모양이 우리 규칙과 다르기 때문입니다.

| 카카오 값 (예) | 문제 | 우리 응답 |
|------|------|------|
| `"authors": ["조슈아 블로크"]` | 저자가 문자열이 아니라 배열 | `"author": "조슈아 블로크"` (여럿이면 `, `로 이음) |
| `"isbn": "8966262287 9788966262281"` | 옛 10자리와 13자리 ISBN이 공백으로 함께 옴 (한쪽만 올 수도 있음) | `"9788966262281"` (과제 2의 도서 등록 규칙: 숫자 13자리) |
| `"thumbnail": "https://search1.kakaocdn.net/..."` | 필드 이름이 우리와 다름 | `"image"` |
| `"title": "이펙티브 자바"` | 그대로 씀 | `"title"` |

제목은 손대지 않습니다. 카카오 웹문서·카페 검색은 본문(`contents`)에 검색어 강조 태그 `<b>`를 섞어 보내지만, 공식 문서의 책 검색 응답 예제에는 제목에 태그가 없습니다. 혹시 태그가 섞여 와도 React는 문자열을 글자 그대로 그리므로 화면에서 HTML로 실행되지는 않습니다.

먼저 `pom.xml`에 의존성 두 개를 추가합니다. Spring Boot 4부터는 `RestClient` 자동 구성이 `spring-boot-starter-webmvc`에서 분리돼, start.spring.io의 **HTTP Client**(`spring-restclient`) 스타터를 따로 넣어야 `RestClient.Builder`를 주입받을 수 있습니다. 테스트 스타터는 3단계의 `@RestClientTest`에 씁니다.

**추가할 내용** (`library/pom.xml`의 `<dependencies>` 안):

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-restclient</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-restclient-test</artifactId>
            <scope>test</scope>
        </dependency>
```

Boot 3.x라면 두 의존성 모두 필요 없습니다 — `RestClient`는 `spring-boot-starter-web`에, `@RestClientTest`는 `spring-boot-starter-test`에 들어 있습니다.

공통 설정에 타임아웃과 `kakao` 설정의 기본값을 추가합니다. 키의 기본값이 빈 문자열이라 키 없이 실행해도 앱은 뜨고, 카카오가 401을 돌려줄 때 3단계의 오류 처리가 동작합니다. `base-url`을 설정으로 빼 두면 4-2에서 카카오 대신 로컬 대역 서버를 부를 수 있습니다.

**파일**: library/src/main/resources/application.yml

```yaml
server:
  port: 8090

spring:
  application:
    name: library
  jpa:
    open-in-view: false        # 지연 로딩은 트랜잭션(서비스) 안에서만 — 컨트롤러로 새지 않게
  sql:
    init:
      mode: never              # 시드 데이터는 h2 프로파일에서만 넣는다 (테스트는 빈 DB)
  http:
    clients:
      connect-timeout: 3s      # 외부 API 연결 대기 한도
      read-timeout: 5s         # 외부 API 응답 대기 한도

springdoc:
  swagger-ui:
    path: /swagger-ui.html

kakao:
  base-url: https://dapi.kakao.com
  rest-api-key: ${KAKAO_REST_API_KEY:}   # 환경 변수 값(없으면 빈 문자열) — application-local.yml(커밋 금지)이 있으면 그 값이 우선
```

`spring.http.clients.*`는 Spring Boot가 만들어 주는 `RestClient.Builder`에 적용되는 공통 타임아웃입니다(Boot 3.4~3.5에서는 `spring.http.client.connect-timeout`처럼 `client` 단수형). 타임아웃이 없으면 카카오가 응답하지 않을 때 요청 스레드가 하염없이 기다리고, 그런 요청이 쌓이면 대출·반납 같은 다른 API까지 멈춥니다.

| 파일 | 요구 사항 |
|------|----------|
| `ErrorCode` | `EXTERNAL_API_ERROR(502 BAD_GATEWAY, "외부 도서 검색 서비스를 호출하지 못했습니다")` 추가 |
| `BookSearchClient` | `List<ExternalBookResponse> search(String query)` 하나만 가진 인터페이스 (컨트롤러는 이 타입만 앎) |
| `KakaoProperties` | `kakao.*` 두 값(`baseUrl`, `restApiKey`)을 담는 `@ConfigurationProperties` record |
| `KakaoBookSearchResponse` | 카카오 응답 중 `documents[].title·authors·publisher·isbn·thumbnail`만 읽는 record, 모르는 필드는 무시, 위 표대로 우리 모양으로 바꾸는 메서드 |
| `ExternalBookResponse` | 우리 API의 응답 record (`title, author, publisher, isbn, image`) |
| `KakaoBookClient` | `BookSearchClient` 구현. 주입받은 `RestClient.Builder`로 기본 주소·키 헤더를 붙인 클라이언트 생성, `search(query)`에서 `RestClientException`을 잡아 `LibraryException(EXTERNAL_API_ERROR)`로 바꿈 |
| `ExternalBookController` | `GET /api/external/books?query=` → `BookSearchClient.search()` |

힌트는 네 가지입니다.

- `RestClient.create()`로 직접 만들지 말고 **Spring이 만든 `RestClient.Builder`를 주입**받습니다. 그래야 `application.yml`의 타임아웃이 적용되고, 3단계 테스트에서 가짜 서버를 끼울 수 있습니다.
- `.uri("/v3/search/book?query={query}&size=10", query)`처럼 **URI 템플릿 변수**로 검색어를 넘기면 한글·공백이 알맞게 인코딩됩니다. 문자열을 `+`로 이어 붙이면 `자바 ORM`의 공백에서 요청이 깨집니다.
- `RestClientException`은 4xx·5xx 응답(`RestClientResponseException`)과 연결·응답 시간 초과(`ResourceAccessException`)의 공통 부모입니다. 둘을 모두 잡으면 K3의 두 경우가 처리됩니다.
- 카카오의 401 오류 본문은 **받은 키를 그대로 되돌려 줍니다** — 틀린 키로 호출하면 `"appKey(보낸 키 값) does not exist"`가 옵니다. 오류 본문을 통째로 로그에 남기면 키가 로그 파일에 찍히므로, 4xx·5xx는 상태 코드만 남깁니다.

비즈니스 규칙이 없으므로 서비스 계층을 두지 않고 컨트롤러가 클라이언트를 바로 부릅니다. 등록은 새 API를 만들지 않고 과제 2의 `POST /api/books`를 그대로 씁니다 — ISBN 중복 검사(R1)와 입력 검증이 이미 거기 있기 때문입니다.

구현이 하나뿐인데 인터페이스를 두는 이유는 맨 위 📌의 사정 때문입니다. 네이버 책 검색이 종료됐을 때 네이버 클라이언트를 직접 부르던 코드는 컨트롤러와 화면 문구까지 고쳐야 했습니다. 외부 제공자는 우리가 통제하지 못하는 **바뀌는 축**이므로, 여기서만은 교체 지점을 미리 만들어 둡니다. 우리 코드 안의 협력 객체에까지 습관처럼 인터페이스를 붙이라는 뜻은 아닙니다.

??? example "모범 답안 — main 코드 7개 파일"

    오류 코드입니다. 과제 2의 9개 아래에 외부 API 오류 하나를 추가합니다. 502 Bad Gateway는 "우리 서버는 정상이지만, 우리가 기댄 다른 서버가 잘못됐다"는 뜻의 상태 코드입니다.

    **파일**: library/src/main/java/dev/wonslab/library/exception/ErrorCode.java

    ```java
    package dev.wonslab.library.exception;

    import org.springframework.http.HttpStatus;

    public enum ErrorCode {
        BOOK_NOT_FOUND(HttpStatus.NOT_FOUND, "도서를 찾을 수 없습니다"),
        MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "회원을 찾을 수 없습니다"),
        LOAN_NOT_FOUND(HttpStatus.NOT_FOUND, "대출 기록을 찾을 수 없습니다"),
        DUPLICATE_ISBN(HttpStatus.CONFLICT, "이미 등록된 ISBN입니다"),
        DUPLICATE_EMAIL(HttpStatus.CONFLICT, "이미 가입된 이메일입니다"),
        BOOK_ALREADY_LOANED(HttpStatus.CONFLICT, "이미 대출 중인 도서입니다"),
        OVERDUE_MEMBER(HttpStatus.CONFLICT, "연체 중인 도서가 있어 대출할 수 없습니다"),
        LOAN_LIMIT_EXCEEDED(HttpStatus.CONFLICT, "대출 가능 권수(3권)를 초과했습니다"),
        ALREADY_RETURNED(HttpStatus.CONFLICT, "이미 반납된 대출입니다"),
        EXTERNAL_API_ERROR(HttpStatus.BAD_GATEWAY, "외부 도서 검색 서비스를 호출하지 못했습니다");

        private final HttpStatus status;
        private final String message;

        ErrorCode(HttpStatus status, String message) {
            this.status = status;
            this.message = message;
        }

        public HttpStatus getStatus() { return status; }
        public String getMessage() { return message; }
    }
    ```

    우리 API의 응답 record입니다. 어느 제공자의 결과든 이 모양으로 바꿔 내보내므로 카카오에 관한 코드가 하나도 없습니다.

    **파일**: library/src/main/java/dev/wonslab/library/dto/ExternalBookResponse.java

    ```java
    package dev.wonslab.library.dto;

    // 외부 도서 검색 결과 한 건 — 제공자(카카오 등)와 관계없이 우리 API가 내보내는 모양
    public record ExternalBookResponse(String title, String author, String publisher, String isbn, String image) {
    }
    ```

    교체 지점인 인터페이스입니다. 컨트롤러는 이 타입만 주입받습니다.

    **파일**: library/src/main/java/dev/wonslab/library/external/BookSearchClient.java

    ```java
    package dev.wonslab.library.external;

    import dev.wonslab.library.dto.ExternalBookResponse;
    import java.util.List;

    // 외부 도서 검색 제공자를 바꿔 끼우는 자리 — 제공자가 사라져도 컨트롤러·화면은 그대로 둔다
    public interface BookSearchClient {

        List<ExternalBookResponse> search(String query);
    }
    ```

    설정 묶음입니다. `@ConfigurationProperties(prefix = "kakao")`는 `kakao.base-url`·`kakao.rest-api-key`를 record 필드 `baseUrl`·`restApiKey`에 넣어 줍니다. 값이 어디서 왔는지(yml·로컬 파일·환경 변수)는 이 클래스가 알 필요가 없습니다.

    **파일**: library/src/main/java/dev/wonslab/library/external/KakaoProperties.java

    ```java
    package dev.wonslab.library.external;

    import org.springframework.boot.context.properties.ConfigurationProperties;

    // kakao.base-url · rest-api-key 값을 묶어 받는다 — 키 값 자체는 커밋하지 않는 곳(로컬 파일·환경 변수)에만 둔다
    @ConfigurationProperties(prefix = "kakao")
    public record KakaoProperties(String baseUrl, String restApiKey) {
    }
    ```

    카카오 응답을 받는 record입니다. 필요한 다섯 필드만 선언하고 `@JsonIgnoreProperties(ignoreUnknown = true)`로 `meta`·`price` 같은 나머지를 무시합니다 — **Tolerant Reader** 방식입니다([[concept-api-backward-compatibility]]). Spring Boot의 기본 JSON 설정도 모르는 필드를 무시하지만, "이 클래스는 남의 응답을 관대하게 읽는다"는 약속을 코드에 드러내려고 명시합니다. Boot 4의 Jackson 3에서도 애너테이션 패키지는 `com.fasterxml.jackson.annotation` 그대로입니다. 카카오 모양을 우리 모양으로 바꾸는 규칙(저자 잇기·13자리 ISBN·필드 이름)은 `toExternalBook()` 한 곳에 모읍니다. 카카오가 필드를 빼먹어도(`null`) 빈 문자열로 바꿔 화면이 깨지지 않게 합니다.

    **파일**: library/src/main/java/dev/wonslab/library/external/KakaoBookSearchResponse.java

    ```java
    package dev.wonslab.library.external;

    import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
    import dev.wonslab.library.dto.ExternalBookResponse;
    import java.util.Arrays;
    import java.util.List;

    // 카카오 응답 중 필요한 필드만 읽는다 (Tolerant Reader) — 모르는 필드가 늘어도 깨지지 않는다
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record KakaoBookSearchResponse(List<Document> documents) {

        @JsonIgnoreProperties(ignoreUnknown = true)
        public record Document(String title, List<String> authors, String publisher, String isbn, String thumbnail) {

            // 카카오 모양 → 우리 모양: 저자 배열은 ", "로 잇고, ISBN은 13자리를 고르고, thumbnail은 image로
            public ExternalBookResponse toExternalBook() {
                return new ExternalBookResponse(
                        orEmpty(title),
                        authors == null ? "" : String.join(", ", authors),
                        orEmpty(publisher),
                        isbn13(isbn),
                        orEmpty(thumbnail));
            }

            private static String orEmpty(String value) {
                return value == null ? "" : value;
            }

            // "8966262287 9788966262281"처럼 10자리·13자리가 함께 오면 13자리를 고른다 (없으면 빈 문자열)
            private static String isbn13(String isbn) {
                if (isbn == null) {
                    return "";
                }
                return Arrays.stream(isbn.trim().split("\\s+"))
                        .filter(value -> value.matches("\\d{13}"))
                        .findFirst()
                        .orElse("");
            }
        }
    }
    ```

    카카오 클라이언트입니다. 생성자에서 기본 주소와 키 헤더를 한 번 붙여 두고, `search()`는 호출과 변환만 합니다. `catch`가 둘인 이유는 힌트의 마지막 항목 때문입니다. 4xx·5xx(`RestClientResponseException`)는 본문에 키가 되돌아올 수 있어 상태 코드만, 연결·시간 초과는 메시지(요청 주소와 원인)를 남깁니다. 요청 헤더는 어느 쪽에서도 남기지 않습니다. `@EnableConfigurationProperties`는 `KakaoProperties`를 빈으로 등록해 생성자에 주입되게 합니다.

    **파일**: library/src/main/java/dev/wonslab/library/external/KakaoBookClient.java

    ```java
    package dev.wonslab.library.external;

    import dev.wonslab.library.dto.ExternalBookResponse;
    import dev.wonslab.library.exception.ErrorCode;
    import dev.wonslab.library.exception.LibraryException;
    import java.util.List;
    import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;
    import org.springframework.boot.context.properties.EnableConfigurationProperties;
    import org.springframework.http.HttpHeaders;
    import org.springframework.stereotype.Component;
    import org.springframework.web.client.RestClient;
    import org.springframework.web.client.RestClientException;
    import org.springframework.web.client.RestClientResponseException;

    @Component
    @EnableConfigurationProperties(KakaoProperties.class)
    public class KakaoBookClient implements BookSearchClient {

        private static final Logger log = LoggerFactory.getLogger(KakaoBookClient.class);

        private final RestClient restClient;

        // Boot가 만들어 둔 RestClient.Builder(타임아웃 설정 적용)를 받아 카카오 전용 클라이언트를 만든다
        public KakaoBookClient(RestClient.Builder builder, KakaoProperties properties) {
            this.restClient = builder
                    .baseUrl(properties.baseUrl())
                    .defaultHeader(HttpHeaders.AUTHORIZATION, "KakaoAK " + properties.restApiKey())
                    .build();
        }

        @Override
        public List<ExternalBookResponse> search(String query) {
            try {
                KakaoBookSearchResponse response = restClient.get()
                        .uri("/v3/search/book?query={query}&size=10", query)
                        .retrieve()
                        .body(KakaoBookSearchResponse.class);
                if (response == null || response.documents() == null) {
                    return List.of();
                }
                return response.documents().stream().map(KakaoBookSearchResponse.Document::toExternalBook).toList();
            } catch (RestClientResponseException e) {
                // 카카오의 401 본문은 받은 키를 되돌려 준다("appKey(...) does not exist") — 본문 대신 상태 코드만 남긴다
                log.warn("카카오 책 검색 실패: HTTP {}", e.getStatusCode().value());
                throw new LibraryException(ErrorCode.EXTERNAL_API_ERROR);
            } catch (RestClientException e) {
                // 연결·응답 시간 초과 등 — 메시지에는 요청 주소와 원인만 있고 헤더(키)는 없다
                log.warn("카카오 책 검색 실패: {}", e.getMessage());
                throw new LibraryException(ErrorCode.EXTERNAL_API_ERROR);
            }
        }
    }
    ```

    외부 검색 컨트롤러입니다. 주입받는 타입이 `KakaoBookClient`가 아니라 `BookSearchClient`라는 점이 교체 지점의 핵심입니다. 구현이 하나뿐이라 Spring이 알아서 `KakaoBookClient`를 넣어 줍니다. `@RequestParam String query`는 필수 파라미터라 `query` 없이 부르면 400이 납니다.

    **파일**: library/src/main/java/dev/wonslab/library/controller/ExternalBookController.java

    ```java
    package dev.wonslab.library.controller;

    import dev.wonslab.library.dto.ExternalBookResponse;
    import dev.wonslab.library.external.BookSearchClient;
    import io.swagger.v3.oas.annotations.Operation;
    import io.swagger.v3.oas.annotations.tags.Tag;
    import java.util.List;
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RequestParam;
    import org.springframework.web.bind.annotation.RestController;

    @Tag(name = "외부 도서 검색")
    @RestController
    @RequestMapping("/api/external/books")
    public class ExternalBookController {

        private final BookSearchClient bookSearchClient;

        public ExternalBookController(BookSearchClient bookSearchClient) {
            this.bookSearchClient = bookSearchClient;
        }

        @Operation(summary = "외부 도서 검색 (등록할 도서 후보 찾기)")
        @GetMapping
        public List<ExternalBookResponse> search(@RequestParam String query) {
            return bookSearchClient.search(query);
        }
    }
    ```

    화면 주소 전달 컨트롤러입니다. 과제 2-3의 목록에 5단계에서 만들 `/books/import`를 추가합니다.

    **파일**: library/src/main/java/dev/wonslab/library/controller/SpaForwardController.java

    ```java
    package dev.wonslab.library.controller;

    import org.springframework.stereotype.Controller;
    import org.springframework.web.bind.annotation.GetMapping;

    @Controller
    public class SpaForwardController {

        // React 라우터가 그리는 주소를 새로 고침하거나 직접 열면 index.html을 내려 준다 (/api는 해당 없음)
        @GetMapping({"/books", "/books/import", "/loans", "/members/new"})
        public String forward() {
            return "forward:/index.html";
        }
    }
    ```

컴파일로 확인합니다.

```bash
./mvnw compile        # Windows: mvnw.cmd compile
```

```text
예상 결과
[INFO] BUILD SUCCESS
```

---

## 3. 네트워크 없이 테스트 — MockRestServiceServer

**과제**: `KakaoBookClient`를 **카카오를 부르지 않고** 테스트합니다(K4). 이 단계의 목표는 외부 API 테스트의 세 가지 문제 — 키가 필요하고, 네트워크가 느리거나 끊기고, 카카오의 데이터가 날마다 바뀌는 것 — 를 한 번에 피하는 것입니다.

`@RestClientTest`는 `RestClient.Builder`와 JSON 변환기, 지정한 컴포넌트만 띄우는 슬라이스 테스트입니다. 이때 Builder에는 **`MockRestServiceServer`** 가 연결돼, 클라이언트가 보내는 요청을 실제 네트워크 대신 이 가짜 서버가 받습니다. 테스트는 "이런 요청이 올 것이다(`expect`) → 오면 이렇게 응답하라(`andRespond`)"를 적고, 클라이언트의 반환값을 검증합니다.

| # | 테스트 | 가짜 서버의 응답 | 확인하는 요구사항 |
|---|------|------|------|
| 1 | 검색 결과를 우리 모양(저자 잇기·13자리 ISBN)으로 바꿈 | 고정 JSON 파일 (200) | K2 변환 규칙, `KakaoAK` 키 헤더 전송 |
| 2 | 카카오가 401을 돌려주면 `EXTERNAL_API_ERROR` | 401 + 카카오 오류 JSON | K3 |
| 3 | 응답 시간이 초과되면 `EXTERNAL_API_ERROR` | `SocketTimeoutException` 발생 | K3 |

고정 응답(fixture)은 카카오 응답과 **같은 모양**으로 만들되, 우리가 읽지 않는 필드(`meta`, `contents`, `price`, `translators` 등)도 일부러 넣습니다. 그 필드가 있어도 변환이 깨지지 않는다는 것까지 함께 검증하기 위해서입니다.

??? example "모범 답안 — 고정 응답과 테스트"

    테스트 리소스 디렉터리에 둡니다. 첫 권은 ISBN 두 개가 함께 오는 경우, 둘째 권은 저자가 셋인 경우입니다.

    **파일**: library/src/test/resources/kakao/book-search.json

    ```json
    {
      "meta": {
        "is_end": true,
        "pageable_count": 2,
        "total_count": 2
      },
      "documents": [
        {
          "authors": ["조슈아 블로크"],
          "contents": "자바 플랫폼 모범 사례 완벽 가이드",
          "datetime": "2018-11-01T00:00:00.000+09:00",
          "isbn": "8966262287 9788966262281",
          "price": 36000,
          "publisher": "인사이트",
          "sale_price": 32400,
          "status": "정상판매",
          "thumbnail": "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=cover1",
          "title": "이펙티브 자바",
          "translators": ["이복연"],
          "url": "https://search.daum.net/search?w=bookpage&bookId=1"
        },
        {
          "authors": ["라울-게이브리얼 우르마", "마리오 푸스코", "앨런 마이크로프트"],
          "contents": "",
          "datetime": "2019-08-01T00:00:00.000+09:00",
          "isbn": "9791162242025",
          "price": 38000,
          "publisher": "한빛미디어",
          "sale_price": 34200,
          "status": "정상판매",
          "thumbnail": "",
          "title": "모던 자바 인 액션",
          "translators": ["우정은"],
          "url": "https://search.daum.net/search?w=bookpage&bookId=2"
        }
      ]
    }
    ```

    테스트 클래스입니다. `properties`로 가짜 키를 넣고, 1번 테스트에서 그 값이 `KakaoAK ` 접두어와 함께 헤더로 나갔는지까지 확인합니다. `requestToUriTemplate`은 클라이언트와 같은 방식으로 한글 검색어를 인코딩해 비교합니다. 2번 테스트의 오류 본문은 카카오가 존재하지 않는 키에 실제로 돌려주는 모양입니다.

    **파일**: library/src/test/java/dev/wonslab/library/external/KakaoBookClientTest.java

    ```java
    package dev.wonslab.library.external;

    import static org.assertj.core.api.Assertions.assertThat;
    import static org.assertj.core.api.Assertions.assertThatThrownBy;
    import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
    import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestToUriTemplate;
    import static org.springframework.test.web.client.response.MockRestResponseCreators.withException;
    import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;
    import static org.springframework.test.web.client.response.MockRestResponseCreators.withUnauthorizedRequest;

    import dev.wonslab.library.dto.ExternalBookResponse;
    import dev.wonslab.library.exception.ErrorCode;
    import dev.wonslab.library.exception.LibraryException;
    import java.net.SocketTimeoutException;
    import java.util.List;
    import org.junit.jupiter.api.Test;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.boot.restclient.test.autoconfigure.RestClientTest; // Boot 3.x: org.springframework.boot.test.autoconfigure.web.client.RestClientTest
    import org.springframework.core.io.ClassPathResource;
    import org.springframework.http.MediaType;
    import org.springframework.test.web.client.MockRestServiceServer;

    @RestClientTest(components = KakaoBookClient.class, properties = "kakao.rest-api-key=test-key")
    class KakaoBookClientTest {

        static final String SEARCH_URL = "https://dapi.kakao.com/v3/search/book?query={query}&size=10";

        @Autowired
        KakaoBookClient client;

        @Autowired
        MockRestServiceServer server;   // 실제 카카오 대신 응답하는 가짜 서버 — 네트워크를 쓰지 않는다

        @Test
        void 검색_결과를_저자_이음과_13자리_ISBN으로_바꾼다() {
            server.expect(requestToUriTemplate(SEARCH_URL, "자바"))
                    .andExpect(header("Authorization", "KakaoAK test-key"))
                    .andRespond(withSuccess(new ClassPathResource("kakao/book-search.json"), MediaType.APPLICATION_JSON));

            List<ExternalBookResponse> books = client.search("자바");

            assertThat(books).hasSize(2);
            assertThat(books.get(0).title()).isEqualTo("이펙티브 자바");
            assertThat(books.get(0).isbn()).isEqualTo("9788966262281");
            assertThat(books.get(0).image()).startsWith("https://search1.kakaocdn.net/");
            assertThat(books.get(1).author()).isEqualTo("라울-게이브리얼 우르마, 마리오 푸스코, 앨런 마이크로프트");
            assertThat(books.get(1).isbn()).isEqualTo("9791162242025");
            server.verify();
        }

        @Test
        void 카카오가_401을_돌려주면_EXTERNAL_API_ERROR() {
            server.expect(requestToUriTemplate(SEARCH_URL, "자바"))
                    .andRespond(withUnauthorizedRequest().contentType(MediaType.APPLICATION_JSON)
                            .body("{\"errorType\":\"AccessDeniedError\",\"message\":\"appKey(test-key) does not exist\"}"));

            assertThatThrownBy(() -> client.search("자바"))
                    .isInstanceOfSatisfying(LibraryException.class,
                            e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.EXTERNAL_API_ERROR));
        }

        @Test
        void 응답_시간이_초과되면_EXTERNAL_API_ERROR() {
            server.expect(requestToUriTemplate(SEARCH_URL, "자바"))
                    .andRespond(withException(new SocketTimeoutException("Read timed out")));

            assertThatThrownBy(() -> client.search("자바"))
                    .isInstanceOfSatisfying(LibraryException.class,
                            e -> assertThat(e.getErrorCode()).isEqualTo(ErrorCode.EXTERNAL_API_ERROR));
        }
    }
    ```

전체 테스트를 실행합니다. 과제 2-3의 11개에 3개가 더해져 14개입니다. 네트워크를 끊고 실행해도 결과가 같습니다.

```bash
./mvnw test        # Windows: mvnw.cmd test
```

```text
예상 결과
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 19.19 s -- in dev.wonslab.library.repository.LoanRepositoryTest
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 13.93 s -- in dev.wonslab.library.controller.LoanApiTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.303 s -- in dev.wonslab.library.controller.MemberLoansApiTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.332 s -- in dev.wonslab.library.external.KakaoBookClientTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 1.828 s -- in dev.wonslab.library.LibraryApplicationTests
[INFO] Tests run: 14, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

`KakaoBookClientTest` 3개가 0.1초 안팎에 끝납니다. 실제 카카오를 부르는 테스트였다면 호출마다 수백 밀리초가 걸리고, 키가 없는 PC나 CI에서는 늘 실패했을 것입니다.

---

## 4. 실행해서 확인

이 단계에서는 API를 띄워 실제 카카오를 부르고, 키가 없을 때의 502도 직접 봅니다. 서버가 터미널을 붙잡으므로 curl은 새 터미널에서 실행합니다.

### 4-1. 실제 카카오 호출

1단계에서 만든 `application-local.yml`을 쓰도록 `local` 프로파일을 함께 켭니다.

```bash
cd library
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2,local        # Windows: mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=h2,local
```

```text
예상 결과
... dev.wonslab.library.LibraryApplication   : The following 2 profiles are active: "h2", "local"
... o.s.boot.tomcat.TomcatWebServer          : Tomcat started on port 8090 (http) with context path '/'
```

`profiles are active` 줄에 `"local"`이 보여야 로컬 키 파일이 적용된 것입니다. 새 터미널에서 검색합니다.

```bash
curl -s -w '\n%{http_code}\n' -G http://localhost:8090/api/external/books --data-urlencode "query=자바"
```

```text
예상 결과 (2026-09-29 실측, 값은 카카오 데이터에 따라 다름 — 10건 중 첫 건만 표시)
[{"title":"코딩 자율학습 HTML + CSS + 자바스크립트","author":"김기수","publisher":"길벗","isbn":"9791165219468","image":"https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6052846%3Ftimestamp%3D20250716142640"}, ...]
200
```

키가 맞으면 최대 10건이 이 모양으로 옵니다. `author`가 배열이 아니라 문자열이고, `isbn`이 13자리 하나인지 확인합니다. 결과 값은 카카오의 검색 데이터라 실행하는 날마다 다를 수 있습니다. ISBN이 10자리뿐인 오래된 책은 `isbn`이 빈 문자열로 나오고, 5단계 화면에서 **등록** 버튼이 꺼집니다.

같은 명령에서 502가 나면 서버 터미널의 `WARN` 줄이 원인을 알려 줍니다. 키를 빼고 실행한 경우(`local` 프로파일 없이)를 일부러 만들어 보면 다음과 같습니다.

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2        # Windows: mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=h2
curl -s -w '\n%{http_code}\n' -G http://localhost:8090/api/external/books --data-urlencode "query=자바"
```

```text
예상 결과
{"status":502,"code":"EXTERNAL_API_ERROR","message":"외부 도서 검색 서비스를 호출하지 못했습니다"}
502
```

서버 터미널에는 카카오가 돌려준 상태 코드가 남습니다.

```text
예상 결과
... d.w.library.external.KakaoBookClient     : 카카오 책 검색 실패: HTTP 401
```

사용자(화면)에게는 "외부 서비스를 부르지 못했다"는 우리 오류 코드만, 운영자(로그)에게는 카카오의 상태 코드를 보여 주는 분리입니다. 키 값 자체는 어디에도 찍히지 않습니다. 상태 코드만으로 원인이 좁혀지지 않으면 같은 요청을 curl로 카카오에 직접 보내 오류 본문을 봅니다 — 이때 본문에 키가 되돌아오므로 그 출력은 남에게 공유하지 않습니다.

```bash
curl -s -G https://dapi.kakao.com/v3/search/book --data-urlencode "query=자바" -H "Authorization: KakaoAK 여기에-REST-API-키"
```

카카오가 돌려주는 주요 오류는 아래와 같습니다.

| 카카오 응답 | 뜻 | 확인할 것 |
|------|------|------|
| `401` `cannot find Authorization : KakaoAK header` | 키가 비어 있음 | `local` 프로파일을 켰는지, 환경 변수 이름이 `KAKAO_REST_API_KEY`인지 |
| `401` `wrong appKey(...) format` | 키 형식이 틀림 | 복사할 때 앞뒤 공백·줄바꿈이 섞이지 않았는지 |
| `401` `appKey(...) does not exist` | 없는 키 | REST API 키가 아니라 JavaScript 키·어드민 키를 넣지 않았는지, 앱을 지우지 않았는지 |
| `403` | 이 앱이나 IP에 호출 권한이 없음 | 1-1의 **호출 허용 IP 주소** 설정과 지금 PC의 IP |
| `429` | 쿼터 초과 | 카카오디벨로퍼스의 사용량 |
| `I/O error ... timed out` | 3초 안에 연결되지 않았거나 5초 안에 응답이 없음 | 네트워크·방화벽, `application.yml`의 타임아웃 |

> **이 글의 검증 환경에서**: 모범 답안은 실제 카카오 REST API 키로 검증했습니다(2026-09-29). 위 200 응답과 6단계의 검색·등록·중복 그림은 실제 카카오 데이터이고, 401 → 502 흐름은 키를 뺀 실행으로 확인했습니다. 4-2의 대역 서버는 키 발급 전이나 네트워크가 없을 때 흐름을 확인하는 용도입니다.

### 4-2. 키 없이 흐름 확인 — 로컬 대역 서버

키 발급 전이거나, 카카오가 오류를 돌려줄 때도 화면 흐름을 끝까지 확인할 수 있게 **카카오처럼 응답하는 대역 서버**를 둡니다. 파이썬 표준 라이브러리만으로 만든 스크립트 하나가 카카오와 같은 경로(`/v3/search/book`)에서 고정 응답을 돌려줍니다. 검색어와 관계없이 늘 같은 3건을 돌려주고, 키 헤더가 비어 있으면 카카오처럼 401을 돌려주는 단순한 대역입니다.

대역 서버가 돌려줄 응답입니다. 3단계 고정 응답과 같은 카카오 모양이며, 첫 권은 시드 도서와 ISBN이 같아 409를 확인하는 데 씁니다.

**파일**: library/kakao-stub/book.json

```json
{
  "meta": {
    "is_end": true,
    "pageable_count": 3,
    "total_count": 3
  },
  "documents": [
    {
      "authors": ["조슈아 블로크"],
      "contents": "자바 플랫폼 모범 사례 완벽 가이드",
      "datetime": "2018-11-01T00:00:00.000+09:00",
      "isbn": "8966262287 9788966262281",
      "publisher": "인사이트",
      "thumbnail": "",
      "title": "이펙티브 자바",
      "translators": ["이복연"]
    },
    {
      "authors": ["라울-게이브리얼 우르마", "마리오 푸스코", "앨런 마이크로프트"],
      "contents": "",
      "datetime": "2019-08-01T00:00:00.000+09:00",
      "isbn": "9791162242025",
      "publisher": "한빛미디어",
      "thumbnail": "http://localhost:9999/cover.svg",
      "title": "모던 자바 인 액션",
      "translators": ["우정은"]
    },
    {
      "authors": ["남궁성"],
      "contents": "",
      "datetime": "2016-01-27T00:00:00.000+09:00",
      "isbn": "8994492038 9788994492032",
      "publisher": "도우출판",
      "thumbnail": "",
      "title": "자바의 정석",
      "translators": []
    }
  ]
}
```

두 번째 결과의 표지로 쓸 그림 파일입니다. 나머지 두 권은 `thumbnail`이 비어 있어 화면이 "표지 없음"을 보여 주는지 함께 확인합니다.

**파일**: library/kakao-stub/cover.svg

```text
<svg xmlns="http://www.w3.org/2000/svg" width="80" height="112" viewBox="0 0 80 112">
  <rect width="80" height="112" fill="#1e3a8a"/>
  <text x="40" y="52" font-size="11" fill="#fff" text-anchor="middle">모던 자바</text>
  <text x="40" y="68" font-size="11" fill="#fff" text-anchor="middle">인 액션</text>
</svg>
```

대역 서버 스크립트입니다. 파이썬 내장 `http.server`를 그대로 쓰면 확장자 없는 경로(`/v3/search/book`)를 JSON이 아닌 형식으로 내보내 `RestClient`가 읽지 못하므로, 응답 형식을 직접 지정하는 작은 처리기를 둡니다.

**파일**: library/kakao-stub/stub.py

```python
# 카카오 책 검색 대역 서버 — 검색어와 관계없이 book.json을 돌려주고, 키 헤더가 비어 있으면 카카오처럼 401을 돌려준다
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HERE = Path(__file__).parent
NO_KEY = b'{"errorType":"AccessDeniedError","message":"cannot find Authorization : KakaoAK header"}'


class KakaoStub(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/v3/search/book"):
            if self.headers.get("Authorization", "").strip() in ("", "KakaoAK"):
                self.reply(401, "application/json;charset=UTF-8", NO_KEY)
            else:
                self.reply(200, "application/json;charset=UTF-8", (HERE / "book.json").read_bytes())
        elif self.path == "/cover.svg":
            self.reply(200, "image/svg+xml", (HERE / "cover.svg").read_bytes())
        else:
            self.reply(404, "text/plain", b"not found")

    def reply(self, status, content_type, body):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


print("kakao-stub on http://localhost:9999", flush=True)
ThreadingHTTPServer(("127.0.0.1", 9999), KakaoStub).serve_forever()
```

대역 서버를 띄우고(터미널 1), API를 `kakao.base-url`만 바꿔 실행합니다(터미널 2). 명령줄 인자 `--kakao.base-url=...`은 `application.yml`의 값보다 우선합니다. 대역 서버는 키 값을 검사하지 않으므로 아무 문자열(`stub-key`)이나 넘깁니다. 3단계 테스트가 `MockRestServiceServer`로 한 일을 실행 중인 앱에서 하는 셈입니다.

```bash
cd library
python3 kakao-stub/stub.py        # Windows: python kakao-stub\stub.py
```

```bash
cd library
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2 "-Dspring-boot.run.arguments=--kakao.base-url=http://localhost:9999 --kakao.rest-api-key=stub-key"        # Windows: mvnw.cmd spring-boot:run (뒤 인자는 같음)
```

새 터미널에서 같은 검색을 부릅니다.

```bash
curl -s -w '\n%{http_code}\n' -G http://localhost:8090/api/external/books --data-urlencode "query=자바"
```

```text
예상 결과
[{"title":"이펙티브 자바","author":"조슈아 블로크","publisher":"인사이트","isbn":"9788966262281","image":""},{"title":"모던 자바 인 액션","author":"라울-게이브리얼 우르마, 마리오 푸스코, 앨런 마이크로프트","publisher":"한빛미디어","isbn":"9791162242025","image":"http://localhost:9999/cover.svg"},{"title":"자바의 정석","author":"남궁성","publisher":"도우출판","isbn":"9788994492032","image":""}]
200
```

대역 서버가 준 저자 배열·ISBN 두 개·`thumbnail`이 모두 우리 모양으로 다듬어져 나왔습니다. 확인이 끝나면 두 서버를 `Ctrl+C`로 내립니다.

---

## 5. 화면 — 도서 가져오기

**과제**: `library-ui`에 도서 가져오기 화면(`/books/import`)을 추가합니다(K5·K6). 이 단계의 목표는 과제 2-2에서 만든 구조(`LibraryApi` 인터페이스 → 실제 구현·목업 → 화면)에 **호출 두 개를 더하는 것만으로** 새 기능을 붙이는 것입니다. 화면은 우리 서버의 `/api/external/books`하고만 대화하므로 카카오라는 이름을 쓰지 않습니다 — 화면 문구도 "외부 도서 검색"으로 둡니다.

| 파일 | 요구 사항 |
|------|----------|
| `types.ts` | `ExternalBook` 타입 + `LibraryApi`에 `registerBook(request)`·`searchExternalBooks(query)` 추가 |
| `errors.ts` | `DUPLICATE_ISBN`·`EXTERNAL_API_ERROR` 안내 문구 추가 |
| `http.ts` | `POST /api/books`, `GET /api/external/books?query=` 구현 |
| `mock.ts` | 고정 검색 결과 3건(첫 권은 시드와 같은 ISBN) + 중복 ISBN이면 409 `DUPLICATE_ISBN` |
| `ImportPage.tsx` | 검색창 → 결과 카드(표지 또는 "표지 없음", 제목, 저자·출판사, ISBN, **등록**) → 성공·오류 안내. ISBN이 없는 결과는 **등록** 비활성 |
| `App.tsx` | 메뉴 "도서 가져오기" + `/books/import` 주소 |

화면 오류 안내입니다. 과제 2-2의 표에 두 줄이 더해집니다.

| 오류 코드 (HTTP 상태) | 화면에 보여 줄 안내 |
|------|------|
| `DUPLICATE_ISBN` (409) | 이미 등록된 도서입니다. 도서 목록에서 확인해 주세요. |
| `EXTERNAL_API_ERROR` (502) | 외부 도서 검색을 호출하지 못했습니다. 서버의 API 키 설정과 네트워크를 확인해 주세요. |

??? example "모범 답안 — src/api (4개 파일)"

    타입입니다. `ExternalBook`은 2단계 `ExternalBookResponse`와 필드 이름이 같습니다.

    **파일**: library-ui/src/api/types.ts

    ```ts
    export interface Book {
      id: number
      isbn: string
      title: string
      author: string
    }

    export interface Member {
      id: number
      name: string
      email: string
    }

    export interface Loan {
      id: number
      memberId: number
      bookId: number
      bookTitle: string
      loanDate: string
      dueDate: string
      returnDate: string | null
      status: 'LOANED' | 'RETURNED'
    }

    // 외부 도서 검색 결과 (서버가 제공자 응답에서 필요한 필드만 골라 다듬어 준 모양)
    export interface ExternalBook {
      title: string
      author: string
      publisher: string
      isbn: string
      image: string
    }

    // 화면이 쓰는 API 목록 — 실제 서버(http.ts)와 목업(mock.ts)이 같은 모양을 지킨다
    export interface LibraryApi {
      searchBooks(keyword?: string): Promise<Book[]>
      registerMember(request: { name: string; email: string }): Promise<Member>
      loan(memberId: number, bookId: number): Promise<Loan>
      returnLoan(loanId: number): Promise<Loan>
      memberLoans(memberId: number): Promise<Loan[]>
      registerBook(request: { isbn: string; title: string; author: string }): Promise<Book>
      searchExternalBooks(query: string): Promise<ExternalBook[]>
    }
    ```

    오류 안내입니다. 맨 아래 두 줄이 추가됐습니다.

    **파일**: library-ui/src/api/errors.ts

    ```ts
    // 서버 오류 응답 {status, code, message}를 담는 예외 — 실제 서버·목업이 똑같이 던진다
    export class ApiError extends Error {
      readonly status: number
      readonly code: string

      constructor(status: number, code: string, message: string) {
        super(message)
        this.status = status
        this.code = code
      }
    }

    // 오류 코드 → 사용자에게 보여 줄 한글 안내 (다음 행동까지 알려 준다)
    const MESSAGES: Record<string, string> = {
      BOOK_ALREADY_LOANED: '이미 대출 중인 도서입니다. 반납된 뒤에 다시 대출할 수 있습니다.',
      OVERDUE_MEMBER: '연체 중인 도서가 있어 대출할 수 없습니다. 연체 도서를 먼저 반납해 주세요.',
      LOAN_LIMIT_EXCEEDED: '한 사람이 동시에 빌릴 수 있는 도서는 3권까지입니다.',
      ALREADY_RETURNED: '이미 반납 처리된 대출입니다.',
      MEMBER_NOT_FOUND: '해당 번호의 회원이 없습니다. 회원 번호를 확인해 주세요.',
      BOOK_NOT_FOUND: '해당 도서를 찾을 수 없습니다.',
      DUPLICATE_EMAIL: '이미 가입된 이메일입니다.',
      DUPLICATE_ISBN: '이미 등록된 도서입니다. 도서 목록에서 확인해 주세요.',
      EXTERNAL_API_ERROR: '외부 도서 검색을 호출하지 못했습니다. 서버의 API 키 설정과 네트워크를 확인해 주세요.',
    }

    export function toMessage(error: unknown): string {
      if (error instanceof ApiError) {
        return MESSAGES[error.code] ?? error.message // INVALID_INPUT 등은 서버 메시지 그대로
      }
      return '서버에 연결할 수 없습니다. API 서버가 실행 중인지 확인해 주세요.'
    }
    ```

    실제 서버 구현입니다. 맨 아래 두 호출이 추가됐고, 등록은 과제 2의 도서 등록 API 그대로입니다.

    **파일**: library-ui/src/api/http.ts

    ```ts
    import axios, { isAxiosError } from 'axios'
    import { ApiError } from './errors'
    import type { Book, ExternalBook, LibraryApi, Loan, Member } from './types'

    // baseURL이 ''이면 화면과 같은 주소로 요청한다 (개발 서버 프록시·한 jar 배포 모두 이 값)
    const client = axios.create({ baseURL: import.meta.env.VITE_API_BASE_URL ?? '' })

    // 서버의 오류 JSON을 ApiError로 바꿔, 화면은 code만 보고 분기한다
    client.interceptors.response.use(undefined, (error) => {
      const body = isAxiosError(error) ? error.response?.data : undefined
      if (body?.code) {
        throw new ApiError(body.status, body.code, body.message)
      }
      throw error
    })

    export const httpApi: LibraryApi = {
      searchBooks: (keyword) =>
        client.get<Book[]>('/api/books', { params: { keyword: keyword || undefined } }).then((r) => r.data),
      registerMember: (request) => client.post<Member>('/api/members', request).then((r) => r.data),
      loan: (memberId, bookId) => client.post<Loan>('/api/loans', { memberId, bookId }).then((r) => r.data),
      returnLoan: (loanId) => client.post<Loan>(`/api/loans/${loanId}/return`).then((r) => r.data),
      memberLoans: (memberId) => client.get<Loan[]>(`/api/members/${memberId}/loans`).then((r) => r.data),
      registerBook: (request) => client.post<Book>('/api/books', request).then((r) => r.data),
      searchExternalBooks: (query) =>
        client.get<ExternalBook[]>('/api/external/books', { params: { query } }).then((r) => r.data),
    }
    ```

    목업입니다. 파일 위쪽의 `EXTERNAL_BOOKS`가 외부 검색 대신 돌려줄 고정 결과(서버가 카카오 응답을 다듬은 뒤의 모양)이고, 맨 아래 두 메서드가 추가됐습니다. 목업은 네트워크를 쓰지 않으므로 표지 주소는 비워 둡니다.

    **파일**: library-ui/src/api/mock.ts

    ```ts
    import { ApiError } from './errors'
    import type { Book, ExternalBook, LibraryApi, Loan, Member } from './types'

    // 오늘 기준 날짜를 YYYY-MM-DD로 (스웨덴 로캘이 ISO 형식과 같다)
    const day = (offset = 0) => {
      const d = new Date()
      d.setDate(d.getDate() + offset)
      return d.toLocaleDateString('sv-SE')
    }

    // 외부 도서 검색 대신 돌려줄 고정 결과 — 첫 권은 시드와 ISBN이 같아 409를 확인할 수 있다
    const EXTERNAL_BOOKS: ExternalBook[] = [
      { title: '이펙티브 자바', author: '조슈아 블로크', publisher: '인사이트', isbn: '9788966262281', image: '' },
      { title: '모던 자바 인 액션', author: '라울-게이브리얼 우르마, 마리오 푸스코, 앨런 마이크로프트', publisher: '한빛미디어', isbn: '9791162242025', image: '' },
      { title: '자바의 정석', author: '남궁성', publisher: '도우출판', isbn: '9788994492032', image: '' },
    ]

    // 과제 2의 data.sql과 같은 시드 + 같은 업무 규칙(R3·R4·R5·R7)을 메모리에서 흉내 낸다
    export function createMockApi(): LibraryApi {
      const books: Book[] = [
        { id: 1, isbn: '9788966262281', title: '이펙티브 자바', author: '조슈아 블로크' },
        { id: 2, isbn: '9788960777330', title: '자바 ORM 표준 JPA 프로그래밍', author: '김영한' },
        { id: 3, isbn: '9788966260959', title: '클린 코드', author: '로버트 C. 마틴' },
        { id: 4, isbn: '9791158391409', title: '오브젝트', author: '조영호' },
      ]
      const members: Member[] = [
        { id: 1, name: '김자바', email: 'java@example.com' },
        { id: 2, name: '이연체', email: 'late@example.com' },
      ]
      const loans: Loan[] = [
        { id: 1, memberId: 2, bookId: 4, bookTitle: '오브젝트', loanDate: day(-20), dueDate: day(-6), returnDate: null, status: 'LOANED' },
      ]
      const findMember = (id: number) => {
        if (!members.some((m) => m.id === id)) throw new ApiError(404, 'MEMBER_NOT_FOUND', '회원을 찾을 수 없습니다')
      }

      return {
        async searchBooks(keyword = '') {
          return books.filter((b) => b.title.includes(keyword) || b.author.includes(keyword))
        },
        async registerMember({ name, email }) {
          if (members.some((m) => m.email === email)) throw new ApiError(409, 'DUPLICATE_EMAIL', '이미 가입된 이메일입니다')
          const member = { id: members.length + 1, name, email }
          members.push(member)
          return member
        },
        async loan(memberId, bookId) {
          findMember(memberId)
          const book = books.find((b) => b.id === bookId)
          if (!book) throw new ApiError(404, 'BOOK_NOT_FOUND', '도서를 찾을 수 없습니다')
          const active = loans.filter((l) => l.status === 'LOANED')
          const mine = active.filter((l) => l.memberId === memberId)
          if (active.some((l) => l.bookId === bookId)) throw new ApiError(409, 'BOOK_ALREADY_LOANED', '이미 대출 중인 도서입니다')
          if (mine.some((l) => l.dueDate < day())) throw new ApiError(409, 'OVERDUE_MEMBER', '연체 중인 도서가 있어 대출할 수 없습니다')
          if (mine.length >= 3) throw new ApiError(409, 'LOAN_LIMIT_EXCEEDED', '대출 가능 권수(3권)를 초과했습니다')
          const loan: Loan = {
            id: loans.length + 1, memberId, bookId, bookTitle: book.title,
            loanDate: day(), dueDate: day(14), returnDate: null, status: 'LOANED',
          }
          loans.push(loan)
          return { ...loan }
        },
        async returnLoan(loanId) {
          const loan = loans.find((l) => l.id === loanId)
          if (!loan) throw new ApiError(404, 'LOAN_NOT_FOUND', '대출 기록을 찾을 수 없습니다')
          if (loan.status === 'RETURNED') throw new ApiError(409, 'ALREADY_RETURNED', '이미 반납된 대출입니다')
          loan.status = 'RETURNED'
          loan.returnDate = day()
          return { ...loan }
        },
        async memberLoans(memberId) {
          findMember(memberId)
          return loans.filter((l) => l.memberId === memberId).reverse().map((l) => ({ ...l })) // 최신순
        },
        async registerBook({ isbn, title, author }) {
          if (books.some((b) => b.isbn === isbn)) throw new ApiError(409, 'DUPLICATE_ISBN', '이미 등록된 ISBN입니다')
          const book = { id: books.length + 1, isbn, title, author }
          books.push(book)
          return book
        },
        async searchExternalBooks(query) {
          return EXTERNAL_BOOKS.filter((b) => b.title.includes(query) || b.author.includes(query))
        },
      }
    }
    ```

??? example "모범 답안 — ImportPage.tsx · App.tsx"

    도서 가져오기 화면입니다. 과제 2-2의 대출 화면과 같은 `run()` 흐름을 씁니다. **등록**은 고른 카드의 `isbn·title·author`를 그대로 보내고, 서버가 돌려준 도서 번호로 안내합니다.

    **파일**: library-ui/src/pages/ImportPage.tsx

    ```tsx
    import { useState, type FormEvent } from 'react'
    import { useApi } from '../api'
    import { toMessage } from '../api/errors'
    import type { ExternalBook } from '../api/types'

    export default function ImportPage() {
      const api = useApi()
      const [query, setQuery] = useState('')
      const [results, setResults] = useState<ExternalBook[] | null>(null)
      const [notice, setNotice] = useState('')
      const [error, setError] = useState('')

      // 대출 화면과 같은 순서: 메시지 비우기 → API 호출 → 성공 안내 또는 오류 코드별 안내
      const run = async (action: () => Promise<string>) => {
        setNotice('')
        setError('')
        try {
          setNotice(await action())
        } catch (e) {
          setError(toMessage(e))
        }
      }

      const onSearch = (e: FormEvent) => {
        e.preventDefault()
        if (!query.trim()) return setError('검색어를 입력해 주세요.')
        run(async () => {
          setResults(await api.searchExternalBooks(query.trim()))
          return ''
        })
      }

      // 고른 결과를 과제 2의 도서 등록 API(POST /api/books)로 그대로 보낸다
      const onRegister = (b: ExternalBook) =>
        run(async () => {
          const book = await api.registerBook({ isbn: b.isbn, title: b.title, author: b.author })
          return `'${book.title}'을(를) ${book.id}번 도서로 등록했습니다.`
        })

      return (
        <section>
          <h1 className="mb-1 text-2xl font-bold">도서 가져오기</h1>
          <p className="mb-4 text-sm text-slate-600">외부 도서 검색 결과에서 골라 우리 도서관에 등록합니다.</p>
          <form onSubmit={onSearch} className="mb-4 flex gap-2">
            <input
              aria-label="외부 도서 검색어"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="제목·저자·ISBN"
              className="flex-1 rounded border border-slate-300 px-3 py-2"
            />
            <button className="rounded bg-amber-500 px-4 py-2 text-white hover:bg-amber-600">외부 검색</button>
          </form>
          {error && <p role="alert" className="mb-4 rounded bg-red-50 p-3 text-red-700">{error}</p>}
          {notice && <p role="status" className="mb-4 rounded bg-green-50 p-3 text-green-800">{notice}</p>}
          {results && results.length === 0 && <p className="text-slate-500">검색 결과가 없습니다.</p>}
          <ul aria-label="검색 결과" className="space-y-3">
            {results?.map((b) => (
              <li key={b.isbn || b.title} className="flex gap-4 rounded bg-white p-4 shadow-sm">
                {b.image ? (
                  <img src={b.image} alt={`${b.title} 표지`} className="h-28 w-20 rounded object-cover" />
                ) : (
                  <div className="flex h-28 w-20 items-center justify-center rounded bg-slate-100 text-xs text-slate-400">표지 없음</div>
                )}
                <div className="flex-1">
                  <p className="font-medium">{b.title}</p>
                  <p className="mt-1 text-sm text-slate-600">{b.author} · {b.publisher}</p>
                  <p className="mt-1 font-mono text-xs text-slate-400">ISBN {b.isbn || '없음'}</p>
                </div>
                <button
                  onClick={() => onRegister(b)}
                  disabled={!b.isbn}
                  className="self-center rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:bg-slate-300"
                >
                  등록
                </button>
              </li>
            ))}
          </ul>
        </section>
      )
    }
    ```

    메뉴와 주소입니다. "도서 목록"에 `end`를 붙인 이유는 `NavLink`가 **앞부분이 같은 주소**도 현재 메뉴로 보기 때문입니다. `end`가 없으면 `/books/import`에서 "도서 목록"과 "도서 가져오기"가 함께 강조됩니다.

    **파일**: library-ui/src/App.tsx

    ```tsx
    import { Link, NavLink, Route, Routes } from 'react-router'
    import BooksPage from './pages/BooksPage'
    import HomePage from './pages/HomePage'
    import ImportPage from './pages/ImportPage'
    import LoanPage from './pages/LoanPage'
    import MemberPage from './pages/MemberPage'

    const linkClass = ({ isActive }: { isActive: boolean }) =>
      isActive ? 'font-semibold text-blue-700' : 'text-slate-600 hover:text-blue-700'

    export default function App() {
      return (
        <div className="min-h-screen bg-slate-50 text-slate-900">
          <header className="border-b border-slate-200 bg-white">
            <nav className="mx-auto flex max-w-4xl items-center gap-6 px-6 py-4">
              <Link to="/" className="text-lg font-bold">도서 대여</Link>
              <NavLink to="/books" end className={linkClass}>도서 목록</NavLink>
              <NavLink to="/books/import" className={linkClass}>도서 가져오기</NavLink>
              <NavLink to="/members/new" className={linkClass}>회원 등록</NavLink>
              <NavLink to="/loans" className={linkClass}>대출·반납</NavLink>
              {import.meta.env.VITE_USE_MOCK === 'true' && (
                <span className="ml-auto rounded bg-amber-100 px-2 py-1 text-xs text-amber-800">목업 데이터</span>
              )}
            </nav>
          </header>
          <main className="mx-auto max-w-4xl px-6 py-8">
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/books" element={<BooksPage />} />
              <Route path="/books/import" element={<ImportPage />} />
              <Route path="/members/new" element={<MemberPage />} />
              <Route path="/loans" element={<LoanPage />} />
            </Routes>
          </main>
        </div>
      )
    }
    ```

??? example "모범 답안 — ImportPage.test.tsx"

    화면 테스트입니다. `searchAt()`은 새 목업으로 화면을 그리고 검색까지 해 둡니다. 3번 테스트는 `vi.spyOn(...).mockRejectedValue`로 목업의 검색이 502 `ApiError`를 던지게 바꿔, 외부 API가 실패한 경우의 안내를 확인합니다.

    **파일**: library-ui/src/pages/ImportPage.test.tsx

    ```tsx
    import { render, screen, within } from '@testing-library/react'
    import userEvent from '@testing-library/user-event'
    import { MemoryRouter } from 'react-router'
    import { describe, expect, it, vi } from 'vitest'
    import App from '../App'
    import { ApiContext } from '../api'
    import { ApiError } from '../api/errors'
    import { createMockApi } from '../api/mock'

    // 도서 가져오기 화면을 새 목업과 함께 그리고, 검색어로 외부 검색까지 해 둔다
    async function searchAt(query: string, api = createMockApi()) {
      render(
        <ApiContext value={api}>
          <MemoryRouter initialEntries={['/books/import']}>
            <App />
          </MemoryRouter>
        </ApiContext>,
      )
      const user = userEvent.setup()
      await user.type(screen.getByLabelText('외부 도서 검색어'), query)
      await user.click(screen.getByRole('button', { name: '외부 검색' }))
      return user
    }

    describe('도서 가져오기', () => {
      it('검색 결과에서 고른 도서를 등록한다', async () => {
        const user = await searchAt('자바')
        const results = screen.getByRole('list', { name: '검색 결과' })
        const modern = (await within(results).findByText('모던 자바 인 액션')).closest('li')!
        expect(within(results).getAllByRole('listitem')).toHaveLength(3) // 목업 고정 결과 중 "자바"가 든 3권
        await user.click(within(modern).getByRole('button', { name: '등록' }))
        expect(await screen.findByRole('status')).toHaveTextContent("'모던 자바 인 액션'을(를) 5번 도서로 등록했습니다.")
      })

      it('이미 있는 ISBN을 등록하면 409 안내를 보여 준다', async () => {
        const user = await searchAt('이펙티브')
        const card = (await screen.findByText('이펙티브 자바')).closest('li')!
        await user.click(within(card).getByRole('button', { name: '등록' }))
        expect(await screen.findByRole('alert')).toHaveTextContent('이미 등록된 도서입니다. 도서 목록에서 확인해 주세요.')
      })

      it('외부 API 오류(502)면 키·네트워크 확인 안내를 보여 준다', async () => {
        const api = createMockApi()
        vi.spyOn(api, 'searchExternalBooks').mockRejectedValue(
          new ApiError(502, 'EXTERNAL_API_ERROR', '외부 도서 검색 서비스를 호출하지 못했습니다'),
        )
        await searchAt('자바', api)
        expect(await screen.findByRole('alert')).toHaveTextContent('외부 도서 검색을 호출하지 못했습니다')
      })
    })
    ```

`library-ui`에서 테스트·빌드·린트를 실행합니다. 과제 2-3까지의 9개에 3개가 더해져 12개입니다.

```bash
cd library-ui
npm test -- --reporter=verbose
npm run build
npm run lint
```

```text
예상 결과
 ✓ src/App.test.tsx > 메인 화면 > 신착 도서 3권을 최근 등록 순으로 보여 준다 644ms
 ✓ src/pages/ImportPage.test.tsx > 도서 가져오기 > 검색 결과에서 고른 도서를 등록한다 802ms
 ✓ src/App.test.tsx > 메인 화면 > 검색하면 도서 목록 화면으로 이동해 결과를 보여 준다 338ms
 ✓ src/pages/ImportPage.test.tsx > 도서 가져오기 > 이미 있는 ISBN을 등록하면 409 안내를 보여 준다 209ms
 ✓ src/pages/ImportPage.test.tsx > 도서 가져오기 > 외부 API 오류(502)면 키·네트워크 확인 안내를 보여 준다 144ms
 ...
 ✓ src/App.test.tsx > 회원 등록 > 이메일 형식이 틀리면 요청을 보내지 않고 안내한다 460ms

 Test Files  2 passed (2)
      Tests  12 passed (12)
...
✓ built in 1.13s
```

![Spring·Vitest 테스트 결과](assets/practice/book-search/05-tests.png)

*그림 1. `./mvnw test` 14개와 `npm test` 12개 — 카카오를 부르지 않는 테스트만으로 모두 통과*

위쪽은 `library`의 14개, 아래쪽은 `library-ui`의 12개입니다. 두 테스트 파일이 동시에 실행되므로 Vitest의 줄 순서는 실행할 때마다 섞일 수 있습니다.

목업 모드로 화면만 먼저 확인할 수 있습니다. `npm run dev:mock`으로 띄우고 `http://localhost:5173/books/import`에서 `자바`를 검색하면 고정 결과 3권이 "표지 없음"과 함께 나옵니다.

---

## 6. 한 jar로 전체 흐름 확인

이 단계에서는 과제 2-3처럼 한 jar로 묶어, 화면 → 우리 서버 → 카카오(또는 4-2의 대역 서버) → H2 등록까지 한 번에 확인합니다.

```bash
cd library
./mvnw package        # Windows: mvnw.cmd package
java -jar target/library-0.0.1-SNAPSHOT.jar --spring.profiles.active=h2,local
```

```text
예상 결과
[INFO] Tests run: 14, Failures: 0, Errors: 0, Skipped: 0
[INFO] Copying 4 resources from ../library-ui/dist to target/classes/static
[INFO] BUILD SUCCESS
```

`java -jar`도 `library`에서 실행해야 루트의 `application-local.yml`이 읽힙니다. 4-2의 대역 서버로 확인한다면 `--spring.profiles.active=h2 --kakao.base-url=http://localhost:9999 --kakao.rest-api-key=stub-key`로 실행합니다. 아래 검색·등록 그림은 실제 카카오 응답으로 찍었습니다.

새 터미널에서 새 화면 주소를 직접 열어도 화면이 뜨는지 확인합니다.

```bash
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://localhost:8090/books/import
```

```text
예상 결과
200 text/html
```

브라우저에서 `http://localhost:8090/books/import`를 열고 `이펙티브 자바`로 **외부 검색**을 누릅니다.

![외부 도서 검색 결과 카드](assets/practice/book-search/01-search-results.png)

*그림 2. 검색 결과 — 실제 카카오 응답을 우리 모양으로 다듬어 그린 카드 (표지·저자·출판사·13자리 ISBN)*

카드마다 제목, 이어 붙인 저자·출판사, 13자리 ISBN이 보이고, 표지는 응답의 `thumbnail` 주소로 그렸습니다(`thumbnail`이 빈 결과는 "표지 없음" 자리가 나옵니다). 첫 번째 카드 "Effective Java(이펙티브 자바)"(2판, ISBN 9788966261161)의 **등록**을 누릅니다.

![등록 성공 안내](assets/practice/book-search/02-register-success.png)

*그림 3. 등록 성공 — `POST /api/books`가 H2에 5번 도서로 저장*

"5번 도서로 등록했습니다"의 5는 H2가 매긴 번호입니다(시드 도서가 4권). 메뉴의 **도서 목록**이나 메인의 신착 도서 맨 앞에서 이 도서를 볼 수 있습니다. 이번에는 두 번째 카드 "이펙티브 자바"(3판, ISBN 9788966262281)의 **등록**을 누릅니다.

![중복 ISBN 409 안내](assets/practice/book-search/03-register-409.png)

*그림 4. 중복 등록 — 시드와 같은 ISBN이라 과제 2의 R1이 409 `DUPLICATE_ISBN`을 돌려줌*

시드의 1번 도서와 ISBN이 같아 과제 2의 `BookService`가 R1 위반으로 409를 돌려줬고, 화면이 `DUPLICATE_ISBN`을 한글 안내로 바꿨습니다. 새 기능이 기존 업무 규칙을 그대로 지키는 것이 새 API를 만들지 않고 `POST /api/books`를 재사용한 이유입니다.

마지막으로 키 없이(`--spring.profiles.active=h2`만) 띄워 같은 검색을 하면 502 안내가 나옵니다.

![외부 API 오류 502 안내](assets/practice/book-search/04-external-502.png)

*그림 5. 외부 API 오류 — 실제 카카오의 401 응답을 서버가 502 `EXTERNAL_API_ERROR`로 바꾸고, 화면이 한글 안내로 표시*

이 그림은 대역 서버가 아니라 **실제 카카오**에 키 없이 요청해 받은 401로 찍었습니다. 화면은 카카오의 오류 형식(`errorType`·`message`)을 모르고 우리 서버의 `EXTERNAL_API_ERROR`만 알기 때문에, 카카오가 오류 형식을 바꾸거나 제공자를 통째로 바꿔도 화면 코드는 바뀌지 않습니다. 확인이 끝나면 `Ctrl+C`로 서버를 내립니다.

---

### 자주 나는 에러 → 원인

| 증상 | 원인 | 해결 |
|------|------|------|
| 기동 시 `No qualifying bean of type 'RestClient$Builder'` | Boot 4에서 `spring-boot-starter-restclient` 누락 | 2단계 `pom.xml` 의존성 추가 |
| 테스트 컴파일 시 `package org.springframework.boot.test.autoconfigure.web.client does not exist` | Boot 3.x 자료의 `@RestClientTest` import를 그대로 씀 | `org.springframework.boot.restclient.test.autoconfigure.RestClientTest` + `spring-boot-starter-restclient-test` |
| `No qualifying bean of type 'KakaoProperties'` | `@EnableConfigurationProperties(KakaoProperties.class)` 누락 | `KakaoBookClient` 클래스에 추가 |
| 기동 시 `No qualifying bean of type 'BookSearchClient'` | `KakaoBookClient`에 `@Component`나 `implements BookSearchClient`가 빠짐 | 두 가지 모두 확인 |
| 늘 502, 로그에 `HTTP 401` | 키가 적용되지 않음 — `local` 프로파일 빠짐, `library`가 아닌 곳에서 실행해 `./application-local.yml`을 못 찾음, 또는 키 값이 틀림 | 기동 로그의 `profiles are active`에 `local` 확인, 4-1의 curl로 카카오 오류 본문 확인 |
| 한글 검색만 결과가 이상하거나 400 | 검색어를 문자열 연결로 URI에 넣어 인코딩되지 않음 | `.uri("...?query={query}", query)` 템플릿 변수 사용 |
| 등록 버튼이 꺼진 카드가 있음 | 그 책은 카카오가 10자리 ISBN만 줘 `isbn`이 빈 문자열 | 정상 동작. 도전 과제 3번 |
| 등록이 400 `INVALID_INPUT`(`title: 제목은 100자 이하여야 합니다`) | 카카오 제목·저자가 과제 2의 길이 제한(100자·50자)보다 김 | 다른 결과를 고르거나, 도전 과제 2번 |
| `git status`에 `application-local.yml`이 보임 | `.gitignore` 추가 전에 파일을 만들었거나 이미 `git add`함 | `.gitignore` 확인 후 `git rm --cached application-local.yml`. 이미 커밋해 올렸다면 **카카오디벨로퍼스에서 REST API 키를 새로 만들고 옛 키를 삭제** |
| 대역 서버로 실행했는데 `I/O error ... Connection refused` | 대역 서버가 꺼져 있거나 다른 포트에서 실행됨 | 4-2의 `python3 kakao-stub/stub.py`가 `kakao-stub on http://localhost:9999`를 출력했는지 확인 |

---

## 같은 인사이트 패턴 — 남의 데이터는 경계에서 우리 모양으로

외부에서 들어오는 값을 **경계 한 곳에서 우리 규칙에 맞게 바꾸고**, 안쪽 코드는 우리 모양만 알게 하는 구조는 이 과제 시리즈에 여러 번 나옵니다.

| 경계 | 바깥의 모양 | 바꾸는 곳 | 안쪽이 아는 것 | 페이지 |
|------|------|------|------|------|
| 외부 API 응답 → 서버 | 카카오 JSON (`authors[]`, ISBN 두 개, `thumbnail`, 모르는 필드) | `KakaoBookSearchResponse.Document.toExternalBook()` | `{title, author, publisher, isbn, image}` | 이 페이지 |
| 외부 실패 → 서버 오류 | 401·403·타임아웃 등 카카오 사정 | `KakaoBookClient`의 `catch` | 502 `EXTERNAL_API_ERROR` 하나 | 이 페이지 |
| 외부 제공자 → 서버 | 카카오든 다른 도서 API든 | `BookSearchClient` 구현체 | `search(query)` 하나 | 이 페이지 |
| 서버 오류 → 화면 | `{status, code, message}` | 화면의 `toMessage()` | 사용자가 할 일이 담긴 한글 안내 | [[guide-java-practice-library-ui]] |
| 요청 본문 → 서비스 | 사용자가 보낸 JSON | `@Valid` DTO | 검증된 record | [[guide-java-practice-spring-library]] |
| 응답 필드 추가 → 클라이언트 | 새 필드가 늘어난 JSON | Tolerant Reader | 아는 필드만 | [[concept-api-backward-compatibility]] |

---

## 채점 기준·셀프 체크

제출 전에 아래 항목을 스스로 점검합니다. 괄호 안은 배점입니다(100점).

| 영역 | 기준 | 배점 |
|------|------|------|
| 키 관리 | 키가 코드·`application.yml`·화면 `.env`·jar에 없음, `.gitignore`·`.example` 제공(K1) | 20 |
| 외부 호출 | `RestClient.Builder` 주입, URI 템플릿 변수, 필요한 필드만 읽는 응답 record, 변환 규칙, `BookSearchClient` 뒤에 둠(K2) | 20 |
| 실패 처리 | 타임아웃 설정, 4xx·5xx·타임아웃 → 502 `EXTERNAL_API_ERROR`, 로그에 키 없음(K3) | 20 |
| 테스트 | `MockRestServiceServer` 테스트 3개(네트워크 없이), `./mvnw test` 14개 통과(K4) | 20 |
| 화면 | 검색 → 카드 → 등록, 409·502 한글 안내, 목업 모드 동작, Vitest 3개 추가(K5·K6) | 20 |

- [ ] `git status`에 `application-local.yml`이 보이지 않습니다
- [ ] 발급받은 REST API 키의 앞 몇 글자로 `grep -r`하면 `application-local.yml` 한 곳만 나옵니다 (`library-ui/dist/`와 `target/`, 서버 로그에도 없어야 함)
- [ ] `./mvnw test`가 `Tests run: 14`로 끝나고, 인터넷을 끊어도 같습니다
- [ ] 키 없이 띄우면 `/api/external/books`가 502 `EXTERNAL_API_ERROR`를 돌려주고, 서버 로그에 카카오의 상태 코드가 남습니다
- [ ] `npm test`가 `Tests  12 passed`로 끝납니다
- [ ] 한 jar에서 `/books/import`를 직접 열 수 있고, 같은 도서를 두 번 등록하면 409 안내가 나옵니다

---

## 도전 과제

기본 과제를 마쳤다면 아래 중 하나 이상을 골라 확장해 봅니다. 위에 있을수록 쉽습니다.

| # | 과제 | 배우는 것 |
|---|------|----------|
| 1 | 결과가 10건을 넘으면 **더 보기** 버튼으로 다음 쪽(`page=2`, `meta.is_end`가 `true`면 버튼 숨김) 불러오기 | 외부 API 페이징 파라미터 |
| 2 | 제목 100자·저자 50자를 넘는 결과는 화면에서 잘라 보여 주고, 등록 전에 사용자가 고칠 수 있는 입력 칸으로 바꾸기 | 외부 데이터와 내부 검증 규칙의 충돌 다루기 |
| 3 | 10자리 ISBN만 있는 결과는 ISBN-13으로 변환(앞에 `978`, 검증 숫자 재계산)해 등록할 수 있게 하기 | 외부 데이터 정규화 규칙을 테스트로 고정하기 |
| 4 | `Book` 엔티티에 `publisher`·`imageUrl` 컬럼을 추가하고, 도서 목록·메인 신착 도서에 표지 보여 주기 | 엔티티 변경이 API·화면·목업·테스트로 번지는 범위 |
| 5 | 같은 검색어의 결과를 5분 동안 캐시(`@Cacheable` + Caffeine)해 카카오 호출 수 줄이기 | 외부 호출 비용·쿼터 관리 |
| 6 | 카카오가 5xx·타임아웃일 때만 한 번 더 시도하기(401은 재시도하지 않음) | 재시도할 실패와 하지 않을 실패 구분 |
| 7 | 두 번째 제공자(예: 국립중앙도서관 ISBN 서지 정보 API)로 `BookSearchClient`를 하나 더 구현하고, 설정값 하나로 바꿔 끼우기 — 컨트롤러·화면은 그대로 | 인터페이스로 만든 교체 지점이 실제로 동작하는지 확인 |

---

## 관련 페이지

- [[guide-java-practice-spring-library]] — 과제 2. 이 과제가 재사용한 도서 등록 API와 R1(ISBN 중복)
- [[guide-java-practice-library-ui]] — 과제 2-2. `LibraryApi`·목업·`toMessage` 구조
- [[guide-java-practice-library-merge]] — 과제 2-3. 프록시·한 jar 배포·`SpaForwardController`
- [[guide-java-track4-spring-web]] — Spring 웹 트랙 코스 안내
- [[concept-api-backward-compatibility]] — 외부 JSON을 읽을 때의 Tolerant Reader 계약
- [[java-study-ch06]] — 설정 파일·프로파일(6.3), 외부 설정 우선순위
