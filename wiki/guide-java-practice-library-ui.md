---
title: "과제 2-2. 도서 대여 화면 — React + Vite"
type: synthesis
tags: [java, study, practice, react, vite, typescript, tailwind, vitest, frontend]
sources: [java-study/practice/]
created: 2026-09-29
updated: 2026-09-29
---

# 과제 2-2. 도서 대여 화면 — React + Vite

> **이 과제의 목표**: [[guide-java-practice-spring-library]](과제 2)에서 만든 도서 대여 API를 사람이 쓰는 **웹 화면**으로 옮깁니다. React·Vite·TypeScript로 메인·도서 목록·회원 등록·대출·반납 화면을 만들고, API 서버 없이도 돌아가는 **목업 모드**와 **컴포넌트 테스트**까지 갖춥니다. 실제 API와 연결하는 일은 다음 과제 [[guide-java-practice-library-merge]]에서 합니다.
>
> **선수 학습**: 과제 2의 API 명세와 오류 응답 모양 `{"status", "code", "message"}` — 이 과제의 화면은 그 명세를 그대로 따릅니다. Node.js 20 이상이 설치돼 있어야 합니다(`node -v`로 확인).

---

## 과제 개요

과제 2의 사서는 curl과 Swagger UI로 대출을 처리했습니다. 이번에는 사서가 브라우저에서 버튼으로 같은 일을 하도록 화면을 만듭니다. 핵심은 **화면이 서버의 오류 코드(`BOOK_ALREADY_LOANED` 등)를 받아 사람이 읽을 한글 안내로 바꿔 보여 주는 것**, 그리고 **서버 없이도 개발·테스트할 수 있게 API 호출 부분을 갈아 끼울 수 있게 만드는 것**입니다.

| 항목 | 내용 |
|------|------|
| 결과물 | 화면 4개(메인, 도서 목록·검색, 회원 등록, 대출·반납)를 가진 단일 페이지 앱(SPA) |
| 기술 | Vite 8 · React 19 · TypeScript 6 · React Router 8 · axios · Tailwind CSS 4 · Vitest 5 + Testing Library |
| 예상 소요 | 3~5시간 (단계별 모범 답안을 보면 1.5시간) |
| 프로젝트 | `library-ui` — 과제 2의 `library` 디렉터리와 **같은 위치(형제)** 에 만듭니다 |

두 프로젝트를 형제로 두는 이유는 다음 과제에서 Maven 빌드가 `../library-ui`를 찾아 화면을 jar에 함께 담기 때문입니다.

```text
practice/
├── library/        과제 2 — Spring Boot API (포트 8090)
└── library-ui/     이 과제 — React 화면 (개발 서버 포트 5173)
```

### 학습 목표

| # | 목표 | 확인 방법 |
|---|------|----------|
| 1 | Vite로 React + TypeScript 프로젝트를 만들고 Tailwind CSS를 붙일 수 있습니다 | `npm run build` 통과 |
| 2 | 서버 응답을 TypeScript 타입으로 선언하고, axios 호출을 한 모듈에 모을 수 있습니다 | `src/api/` 구조 |
| 3 | 같은 인터페이스를 지키는 목업 구현으로 서버 없이 화면을 실행할 수 있습니다 | `npm run dev:mock` |
| 4 | 서버 오류 코드를 한글 안내로 바꿔 보여 줄 수 있습니다 | 중복 대출 시 안내 문구 |
| 5 | Testing Library로 사용자 관점(버튼 클릭·문구 확인)의 컴포넌트 테스트를 쓸 수 있습니다 | `npm test` 9개 통과 |

---

## 요구사항

화면 요구사항입니다. 번호(S0~S6)는 본문과 채점 기준에서 같은 뜻으로 씁니다.

| 번호 | 화면 | 요구사항 |
|------|------|---------|
| S0 | 메인 (`/`) | 짧은 소개 문구와 검색창, **신착 도서** 3권(최근 등록 순) 카드, 화면별 **바로가기**를 보여 줍니다. 검색하면 `/books?keyword=검색어`로 이동합니다 |
| S1 | 도서 목록 (`/books`) | 전체 도서를 표(번호·제목·저자·ISBN)로 보여 줍니다. 검색어를 넣고 **검색**을 누르면 제목·저자 부분 일치 결과만 남깁니다. 검색어는 주소의 `?keyword=`에서 읽으므로, 메인에서 검색해 들어와도 같은 결과가 나옵니다 |
| S2 | 회원 등록 (`/members/new`) | 이름·이메일을 받아 가입시키고 "N번 회원으로 가입되었습니다"를 보여 줍니다. 이름이 비었거나 이메일 형식이 틀리면 **요청을 보내지 않고** 안내합니다 |
| S3 | 대출·반납 (`/loans`) | 회원 번호를 입력하고 도서를 목록에서 골라 **대출**합니다. 성공하면 반납 기한을 안내합니다 |
| S4 | 대출·반납 (`/loans`) | **대출 목록 보기**로 회원의 대출 목록(대출 번호·도서·대출일·반납 기한·상태)을 봅니다. 대출 중인 행에는 **반납** 버튼이 있고, 기한이 지난 대출은 "연체"로 표시합니다 |
| S5 | 공통 | 서버 오류는 `code`를 보고 아래 한글 안내로 바꿔 보여 줍니다. 서버에 연결할 수 없으면 서버 실행 여부를 확인하라고 안내합니다 |
| S6 | 공통 | `VITE_USE_MOCK=true`로 실행하면 서버 없이 메모리 목업 데이터로 모든 화면이 동작합니다 |

S5의 오류 코드별 안내 문구입니다. 서버 메시지("이미 대출 중인 도서입니다")는 무엇이 틀렸는지만 말하므로, 화면에서는 **사용자가 다음에 할 일**까지 덧붙입니다.

| 오류 코드 (HTTP 상태) | 화면에 보여 줄 안내 |
|------|------|
| `BOOK_ALREADY_LOANED` (409) | 이미 대출 중인 도서입니다. 반납된 뒤에 다시 대출할 수 있습니다. |
| `OVERDUE_MEMBER` (409) | 연체 중인 도서가 있어 대출할 수 없습니다. 연체 도서를 먼저 반납해 주세요. |
| `LOAN_LIMIT_EXCEEDED` (409) | 한 사람이 동시에 빌릴 수 있는 도서는 3권까지입니다. |
| `ALREADY_RETURNED` (409) | 이미 반납 처리된 대출입니다. |
| `MEMBER_NOT_FOUND` (404) | 해당 번호의 회원이 없습니다. 회원 번호를 확인해 주세요. |
| `BOOK_NOT_FOUND` (404) | 해당 도서를 찾을 수 없습니다. |
| `DUPLICATE_EMAIL` (409) | 이미 가입된 이메일입니다. |
| 그 밖의 코드 (`INVALID_INPUT` 등) | 서버가 보낸 `message` 그대로 |

### 화면과 API의 대응

각 화면이 부르는 API입니다. 마지막 줄의 **회원별 대출 목록 API는 과제 2에 없습니다.** S4를 만들려면 "이 회원이 무엇을 빌렸는가"를 물을 API가 필요하기 때문입니다. 이 과제에서는 목업으로만 구현하고, 실제 API는 다음 과제 [[guide-java-practice-library-merge]] 3단계에서 Spring에 추가합니다 — 과제 2 도전 과제 1번과 같은 API입니다.

| 화면 동작 | 메서드 · 경로 | 과제 2에 있는가 |
|------|------|------|
| 메인 신착 도서 | `GET /api/books` (번호가 큰 3권을 화면에서 고름) | 있음 |
| 도서 목록·검색 | `GET /api/books?keyword=` | 있음 |
| 회원 등록 | `POST /api/members` | 있음 |
| 대출 | `POST /api/loans` | 있음 |
| 반납 | `POST /api/loans/{id}/return` | 있음 |
| 회원별 대출 목록 | `GET /api/members/{id}/loans` | **없음 → 과제 2-3에서 추가** |

---

## 1. 프로젝트 생성

이 단계에서는 Vite의 React + TypeScript 템플릿으로 빈 프로젝트를 만들고, 과제에 필요한 라이브러리를 설치합니다. `practice/` 디렉터리(과제 2의 `library`가 있는 곳)에서 실행합니다.

```bash
npm create vite@latest library-ui -- --template react-ts --no-immediate
cd library-ui
npm install
```

```text
예상 결과
◇  Scaffolding project in .../practice/library-ui...
└  Done. Now run:
  cd library-ui
  npm install
  npm run dev
...
found 0 vulnerabilities
```

`--no-immediate`는 생성 직후 개발 서버를 바로 띄우지 말라는 옵션입니다. 이어서 화면 라우팅·HTTP 호출 라이브러리와, 개발용(`-D`) 스타일·테스트 도구를 설치합니다.

```bash
npm install axios react-router
npm install -D tailwindcss @tailwindcss/vite vitest jsdom @testing-library/react @testing-library/user-event @testing-library/jest-dom
```

설치된 주요 버전입니다(2026-09-29 기준 `npm ls`로 확인한 값). 새 버전이 나와 있어도 이 과제의 코드는 대부분 그대로 동작하고, 달라지는 부분은 "자주 나는 에러"에 정리했습니다.

| 패키지 | 버전 | 역할 |
|------|------|------|
| `vite` | 8.3.1 | 개발 서버·번들러 |
| `react` · `react-dom` | 19.3.0 | 화면 라이브러리 |
| `typescript` | 6.0 | 타입 검사 (`npm run build`의 `tsc -b`) |
| `react-router` | 8.4.0 | 주소별 화면 전환 (v7부터 `react-router-dom` 대신 이 패키지 하나) |
| `axios` | 1.20.0 | HTTP 호출 |
| `tailwindcss` · `@tailwindcss/vite` | 4.3.3 | 유틸리티 클래스 CSS (v4는 Vite 플러그인 방식) |
| `vitest` · `jsdom` | 5.0.2 · 30.1 | 테스트 실행기·브라우저 흉내 환경 |
| `@testing-library/react` · `user-event` · `jest-dom` | 16.3 · 14.6 · 7.0 | 사용자 관점 테스트 도구 |
| `oxlint` | 1.86 | 템플릿 기본 린터 (현재 템플릿은 ESLint 대신 oxlint를 씀) |

템플릿이 넣어 둔 예시 파일(로고·예시 CSS)은 쓰지 않으므로 지웁니다.

```bash
rm -rf src/assets src/App.css public/icons.svg        # Windows: Remove-Item -Recurse src/assets, src/App.css, public/icons.svg
```

과제를 모두 마쳤을 때의 최종 구조입니다. 이 트리를 지도로 삼아 단계마다 파일을 채웁니다.

```text
library-ui/
├── .env.mock                  목업 모드 환경 변수
├── index.html                 (템플릿 제공, 언어·제목만 수정)
├── package.json               (스크립트 2개 추가)
├── vite.config.ts             Tailwind 플러그인 + Vitest 설정
└── src/
    ├── main.tsx               라우터로 App 감싸기
    ├── App.tsx                상단 메뉴 + 주소별 화면
    ├── App.test.tsx           컴포넌트 테스트 9개
    ├── index.css              Tailwind 불러오기
    ├── api/
    │   ├── types.ts           응답 타입 + LibraryApi 인터페이스
    │   ├── errors.ts          ApiError + 오류 코드별 한글 안내
    │   ├── http.ts            실제 서버 구현 (axios)
    │   ├── mock.ts            메모리 목업 구현
    │   └── index.ts           둘 중 하나를 고르는 Context
    ├── pages/
    │   ├── HomePage.tsx       S0
    │   ├── BooksPage.tsx      S1
    │   ├── MemberPage.tsx     S2
    │   └── LoanPage.tsx       S3·S4
    └── test/setup.ts          테스트 공통 준비
```

---

## 2. 빌드·실행 설정

코드보다 설정을 먼저 두는 이유는, 이후 단계마다 실행할 `npm run dev:mock`·`npm test`가 **어떤 모드로, 어떤 도구로** 도는지 처음부터 정해 두기 위해서입니다.

Vite 설정 파일입니다. `tailwindcss()` 플러그인이 Tailwind를 붙이고, `test` 항목이 Vitest 설정입니다. 첫 줄의 `reference`는 `test` 항목의 타입을 TypeScript에 알려 줍니다. `include`를 `src` 아래 `*.test.tsx`로 좁히는 이유는 다음 과제에서 만들 Playwright 테스트(`e2e/`)를 Vitest가 집어 가지 않게 하기 위해서입니다.

**파일**: vite.config.ts

```ts
/// <reference types="vitest/config" />
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  test: {
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    include: ['src/**/*.test.tsx'],
  },
})
```

전역 CSS는 Tailwind 한 줄로 바꿉니다. 템플릿의 예시 스타일은 모두 지우고 이 한 줄만 남깁니다. Tailwind v4는 `tailwind.config.js` 없이 이 줄만으로 동작합니다.

**파일**: src/index.css

```css
@import "tailwindcss";
```

HTML 뼈대는 템플릿 파일에서 `lang`과 `<title>`만 한국어로 바꿉니다.

**파일**: index.html

```html
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>도서 대여</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

목업 모드용 환경 변수 파일입니다. Vite는 `--mode mock`으로 실행하면 `.env.mock` 파일을 읽고, `VITE_`로 시작하는 변수만 화면 코드의 `import.meta.env`에 넣어 줍니다. 명령 앞에 변수를 붙이는 방식(`VITE_USE_MOCK=true npm run dev`)은 Windows에서 문법이 달라서, 파일 + 모드로 통일합니다.

**파일**: .env.mock

```text
VITE_USE_MOCK=true
```

`package.json`에 스크립트 두 개를 추가합니다. `npm pkg set`은 JSON을 직접 고치지 않고 값을 넣어 주는 명령이라 OS와 관계없이 같습니다.

```bash
npm pkg set scripts.dev:mock="vite --mode mock" scripts.test="vitest run"
```

추가된 스크립트의 뜻입니다.

| 스크립트 | 명령 | 용도 |
|------|------|------|
| `npm run dev` | `vite` (템플릿 제공) | 개발 서버 — 실제 API 모드 (다음 과제에서 사용) |
| `npm run dev:mock` | `vite --mode mock` | 개발 서버 — 목업 모드 (이 과제에서 사용) |
| `npm test` | `vitest run` | 테스트 1회 실행 후 종료 |
| `npm run build` | `tsc -b && vite build` (템플릿 제공) | 타입 검사 + 배포용 파일을 `dist/`에 생성 |
| `npm run lint` | `oxlint` (템플릿 제공) | 코드 규칙 검사 |

---

## 3. API 계층 — 타입·오류·실제 구현·목업

**과제**: `src/api/` 아래에 서버와 대화하는 코드를 모두 모읍니다. 이 단계의 목표는 **화면 컴포넌트가 axios도, 목업도 직접 알지 못하게** 하는 것입니다. 화면은 `LibraryApi` 인터페이스만 보고, 그 뒤에 실제 서버 구현(`http.ts`)이 붙을지 목업(`mock.ts`)이 붙을지는 `index.ts` 한 곳에서 정합니다. 과제 2에서 서비스가 리포지토리 인터페이스만 보고 구현은 Spring Data가 만들어 준 것과 같은 구조입니다.

| 파일 | 요구 사항 |
|------|----------|
| `types.ts` | `Book`·`Member`·`Loan` 타입 (과제 2의 `BookResponse`·`MemberResponse`·`LoanResponse`와 필드 이름 일치) + 화면이 쓰는 5개 호출을 담은 `LibraryApi` 인터페이스 |
| `errors.ts` | 오류 응답 `{status, code, message}`를 담는 `ApiError` 클래스 + 요구사항 표대로 코드를 한글 안내로 바꾸는 `toMessage(error)` |
| `http.ts` | axios로 `LibraryApi` 구현. `baseURL`은 `VITE_API_BASE_URL`, 없으면 빈 문자열. 서버 오류 응답은 `ApiError`로 바꿔 던짐 |
| `mock.ts` | 메모리 배열로 `LibraryApi` 구현. 시드는 과제 2의 `data.sql`과 같게, 규칙 R3·R4·R5·R7 위반 시 서버와 **같은 상태·코드**의 `ApiError`를 던짐 |
| `index.ts` | `VITE_USE_MOCK`가 `'true'`면 목업, 아니면 실제 구현을 기본값으로 가진 React Context + `useApi()` 훅 |

힌트는 세 가지입니다.

- `baseURL`을 `http://localhost:8090`처럼 박아 두지 않고 **빈 문자열**을 기본값으로 두면, 요청이 화면과 같은 주소(`/api/...`)로 나갑니다. 다음 과제의 개발 서버 프록시와 한 jar 배포가 모두 이 값으로 동작합니다.
- axios는 4xx·5xx 응답을 예외로 던집니다. **응답 인터셉터** 한 곳에서 `error.response.data`에 `code`가 있으면 `ApiError`로 바꿔 던지면, 화면 코드는 `ApiError` 하나만 알면 됩니다.
- 템플릿의 `tsconfig.app.json`은 `erasableSyntaxOnly`가 켜져 있어 `enum`과 생성자 매개변수 속성(`constructor(public code: string)`)을 쓸 수 없습니다. 필드를 선언하고 생성자에서 대입합니다.

??? example "모범 답안 — src/api (5개 파일)"

    응답 타입과 화면이 쓰는 API 목록입니다. 날짜는 서버가 `"2026-09-29"` 같은 문자열로 보내므로 `string`으로 받습니다.

    **파일**: src/api/types.ts

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

    // 화면이 쓰는 API 목록 — 실제 서버(http.ts)와 목업(mock.ts)이 같은 모양을 지킨다
    export interface LibraryApi {
      searchBooks(keyword?: string): Promise<Book[]>
      registerMember(request: { name: string; email: string }): Promise<Member>
      loan(memberId: number, bookId: number): Promise<Loan>
      returnLoan(loanId: number): Promise<Loan>
      memberLoans(memberId: number): Promise<Loan[]>
    }
    ```

    오류 예외와 한글 안내 표입니다. `toMessage`는 `ApiError`가 아닌 예외(서버가 꺼져 있어 응답 자체가 없는 경우)를 연결 실패로 봅니다.

    **파일**: src/api/errors.ts

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
    }

    export function toMessage(error: unknown): string {
      if (error instanceof ApiError) {
        return MESSAGES[error.code] ?? error.message // INVALID_INPUT 등은 서버 메시지 그대로
      }
      return '서버에 연결할 수 없습니다. API 서버가 실행 중인지 확인해 주세요.'
    }
    ```

    실제 서버 구현입니다. `keyword || undefined`는 빈 검색어일 때 `?keyword=` 파라미터를 아예 빼서 서버가 전체 목록을 돌려주게 합니다.

    **파일**: src/api/http.ts

    ```ts
    import axios, { isAxiosError } from 'axios'
    import { ApiError } from './errors'
    import type { Book, LibraryApi, Loan, Member } from './types'

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
    }
    ```

    목업 구현입니다. `createMockApi()`를 부를 때마다 **시드 상태의 새 목업**이 만들어지므로, 테스트마다 깨끗한 데이터로 시작할 수 있습니다. 검사 순서(도서 대출 중 → 연체 → 권수)는 과제 2 `LoanService`와 같습니다.

    **파일**: src/api/mock.ts

    ```ts
    import { ApiError } from './errors'
    import type { Book, LibraryApi, Loan, Member } from './types'

    // 오늘 기준 날짜를 YYYY-MM-DD로 (스웨덴 로캘이 ISO 형식과 같다)
    const day = (offset = 0) => {
      const d = new Date()
      d.setDate(d.getDate() + offset)
      return d.toLocaleDateString('sv-SE')
    }

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
      }
    }
    ```

    구현을 고르는 Context입니다. 화면은 `useApi()`로 꺼내 쓰고, 테스트는 `<ApiContext value={...}>`로 원하는 목업을 끼워 넣습니다. 배포용 빌드에서는 `VITE_USE_MOCK` 값이 빌드 시점에 상수로 바뀌어, 쓰이지 않는 목업 코드가 결과물에서 빠집니다.

    **파일**: src/api/index.ts

    ```ts
    import { createContext, useContext } from 'react'
    import { httpApi } from './http'
    import { createMockApi } from './mock'
    import type { LibraryApi } from './types'

    // VITE_USE_MOCK=true면 목업, 아니면 실제 서버. 테스트는 Provider로 목업을 끼워 넣는다
    export const ApiContext = createContext<LibraryApi>(
      import.meta.env.VITE_USE_MOCK === 'true' ? createMockApi() : httpApi,
    )

    export const useApi = () => useContext(ApiContext)
    ```

아직 화면이 없으므로 타입 검사만 합니다. `tsc -b`는 파일을 만들지 않고 타입 오류만 찾아 줍니다.

```bash
npx tsc -b
```

```text
예상 결과
(아무것도 출력되지 않으면 타입 오류가 없는 것입니다)
```

---

## 4. 화면 — 라우팅과 페이지 4개

**과제**: 주소별로 화면을 바꾸는 `App`과 페이지 컴포넌트 4개를 만듭니다. 이 단계의 목표는 **모든 페이지가 같은 흐름(입력 → `useApi()` 호출 → 성공 안내 또는 `toMessage`로 오류 안내)을 따르게** 하는 것입니다.

| 파일 | 요구 사항 |
|------|----------|
| `main.tsx` | `App`을 `BrowserRouter`로 감싸서 렌더링 |
| `App.tsx` | 상단 메뉴(제목 "도서 대여"는 메인으로 가는 `Link`, 화면 메뉴는 `NavLink` 3개) + `Routes`로 `/`·`/books`·`/members/new`·`/loans` 연결. 목업 모드면 메뉴 오른쪽에 "목업 데이터" 표시 |
| `HomePage.tsx` | S0. 검색은 `useNavigate()`로 `/books?keyword=...`에 이동, 신착 도서는 `searchBooks()` 결과를 번호 역순으로 3권 |
| `BooksPage.tsx` | S1. 검색어를 `useSearchParams()`로 주소에서 읽고, **검색** 버튼을 누르면 주소의 검색어를 바꿈 |
| `MemberPage.tsx` | S2. `<form noValidate>`로 브라우저 기본 검증을 끄고 직접 검증 |
| `LoanPage.tsx` | S3·S4. 도서 선택 목록은 `searchBooks()`로 채움. 대출·반납 후에는 대출 목록을 다시 조회 |

검색어를 페이지 안의 `useState`가 아니라 **주소**(`?keyword=`)에 두는 것이 이 단계의 요점입니다. 그래야 메인에서 검색해 들어와도, 결과 화면을 새로 고치거나 주소를 복사해 보내도 같은 검색 결과가 나옵니다. React Router의 `useSearchParams()`가 주소의 검색어를 읽고 바꾸는 훅입니다.

안내 문구 요소에는 역할을 붙입니다 — 오류는 `role="alert"`, 성공은 `role="status"`. 화면 낭독기가 문구를 읽어 주고, 6단계의 테스트가 이 역할로 문구를 찾습니다. 입력 칸은 `<label>`로 감싸 이름을 붙이면 테스트에서 `getByLabelText('회원 번호')`처럼 사용자가 보는 이름으로 찾을 수 있습니다.

??? example "모범 답안 — main.tsx · App.tsx"

    진입점입니다. 템플릿 파일에 `BrowserRouter` 감싸기만 추가합니다.

    **파일**: src/main.tsx

    ```tsx
    import { StrictMode } from 'react'
    import { createRoot } from 'react-dom/client'
    import { BrowserRouter } from 'react-router'
    import App from './App.tsx'
    import './index.css'

    createRoot(document.getElementById('root')!).render(
      <StrictMode>
        <BrowserRouter>
          <App />
        </BrowserRouter>
      </StrictMode>,
    )
    ```

    메뉴와 주소별 화면입니다. `NavLink`는 현재 주소와 맞는 메뉴에 `isActive`를 알려 줘 굵게 표시할 수 있습니다. 왼쪽 제목 "도서 대여"는 강조할 필요가 없어 `NavLink`가 아닌 `Link`로 메인(`/`)에 연결합니다. `/books?keyword=자바`처럼 뒤에 검색어가 붙어도 경로는 `/books`이므로 같은 `BooksPage`가 그려집니다.

    **파일**: src/App.tsx

    ```tsx
    import { Link, NavLink, Route, Routes } from 'react-router'
    import BooksPage from './pages/BooksPage'
    import HomePage from './pages/HomePage'
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
              <NavLink to="/books" className={linkClass}>도서 목록</NavLink>
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
              <Route path="/members/new" element={<MemberPage />} />
              <Route path="/loans" element={<LoanPage />} />
            </Routes>
          </main>
        </div>
      )
    }
    ```

??? example "모범 답안 — pages (4개 파일)"

    메인 화면입니다. 신착 도서를 위해 새 API를 만들지 않고, 목록 API 결과를 번호 역순으로 정렬해 앞의 3권만 씁니다 — 번호는 등록 순서대로 커지기 때문입니다. 검색은 서버에 묻지 않고 `navigate()`로 도서 목록 화면에 검색어를 넘기기만 합니다. `URLSearchParams`는 `자바` 같은 한글을 주소에 쓸 수 있는 형태(`%EC%9E%90...`)로 바꿔 줍니다.

    **파일**: src/pages/HomePage.tsx

    ```tsx
    import { useEffect, useState, type FormEvent } from 'react'
    import { Link, useNavigate } from 'react-router'
    import { useApi } from '../api'
    import { toMessage } from '../api/errors'
    import type { Book } from '../api/types'

    const MENUS = [
      { to: '/books', title: '도서 목록', description: '전체 도서를 보고 제목·저자로 검색합니다' },
      { to: '/members/new', title: '회원 등록', description: '이름과 이메일로 새 회원을 가입시킵니다' },
      { to: '/loans', title: '대출·반납', description: '회원 번호로 대출하고, 대출 목록에서 반납합니다' },
    ]

    export default function HomePage() {
      const api = useApi()
      const navigate = useNavigate()
      const [input, setInput] = useState('')
      const [latest, setLatest] = useState<Book[]>([])
      const [error, setError] = useState('')

      // 신착 도서 = 번호가 큰(나중에 등록된) 도서 3권 — 새 API 없이 목록 API 결과로 계산한다
      useEffect(() => {
        api.searchBooks().then(
          (books) => setLatest([...books].sort((a, b) => b.id - a.id).slice(0, 3)),
          (e) => setError(toMessage(e)),
        )
      }, [api])

      // 검색어를 주소(/books?keyword=...)에 실어 도서 목록 화면으로 보낸다
      const onSubmit = (e: FormEvent) => {
        e.preventDefault()
        navigate(`/books?${new URLSearchParams({ keyword: input.trim() })}`)
      }

      return (
        <section className="space-y-8">
          <div className="rounded bg-white p-8 shadow-sm">
            <h1 className="text-2xl font-bold">우리 동네 작은 도서관</h1>
            <p className="mt-2 text-slate-600">읽고 싶은 책을 찾고, 회원 번호 하나로 빌리고 반납하세요. 대출 기간은 14일입니다.</p>
            <form onSubmit={onSubmit} className="mt-6 flex gap-2">
              <input
                aria-label="검색어"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="제목 또는 저자로 도서 검색"
                className="flex-1 rounded border border-slate-300 px-3 py-2"
              />
              <button className="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">검색</button>
            </form>
          </div>

          <div>
            <h2 className="mb-3 text-lg font-semibold">신착 도서</h2>
            {error && <p role="alert" className="rounded bg-red-50 p-3 text-red-700">{error}</p>}
            <ul aria-label="신착 도서" className="grid gap-4 sm:grid-cols-3">
              {latest.map((b) => (
                <li key={b.id} className="rounded bg-white p-4 shadow-sm">
                  <p className="font-medium">{b.title}</p>
                  <p className="mt-1 text-sm text-slate-600">{b.author}</p>
                  <p className="mt-2 font-mono text-xs text-slate-400">{b.isbn}</p>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="mb-3 text-lg font-semibold">바로가기</h2>
            <div className="grid gap-4 sm:grid-cols-3">
              {MENUS.map((m) => (
                <Link key={m.to} to={m.to} className="rounded border border-slate-200 bg-white p-4 hover:border-blue-400">
                  <span className="font-medium text-blue-700">{m.title}</span>
                  <span className="mt-1 block text-sm text-slate-600">{m.description}</span>
                </Link>
              ))}
            </div>
          </div>
        </section>
      )
    }
    ```

    도서 목록입니다. 입력 중인 글자(`input`)와 실제 검색어(`keyword`)를 나눠, 글자를 칠 때마다가 아니라 **검색** 버튼을 누를 때만 서버에 묻습니다. 실제 검색어는 주소에 있으므로 **검색** 버튼은 `setParams()`로 주소만 바꾸고, 주소가 바뀌면 `useEffect`가 다시 조회합니다. 검색어가 있을 때는 표 위에 결과 권수를 보여 줍니다.

    **파일**: src/pages/BooksPage.tsx

    ```tsx
    import { useEffect, useState, type FormEvent } from 'react'
    import { useSearchParams } from 'react-router'
    import { useApi } from '../api'
    import { toMessage } from '../api/errors'
    import type { Book } from '../api/types'

    export default function BooksPage() {
      const api = useApi()
      const [params, setParams] = useSearchParams()
      const keyword = params.get('keyword') ?? '' // 검색어는 주소(?keyword=)가 기억한다
      const [input, setInput] = useState(keyword)
      const [books, setBooks] = useState<Book[]>([])
      const [error, setError] = useState('')

      // 주소의 검색어가 바뀔 때마다 다시 조회한다 — 검색어가 없으면 전체 목록
      useEffect(() => {
        api.searchBooks(keyword).then(setBooks, (e) => setError(toMessage(e)))
      }, [api, keyword])

      const onSubmit = (e: FormEvent) => {
        e.preventDefault()
        setParams(input.trim() ? { keyword: input.trim() } : {})
      }

      return (
        <section>
          <h1 className="mb-4 text-2xl font-bold">도서 목록</h1>
          <form onSubmit={onSubmit} className="mb-4 flex gap-2">
            <input
              aria-label="검색어"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="제목 또는 저자"
              className="flex-1 rounded border border-slate-300 px-3 py-2"
            />
            <button className="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">검색</button>
          </form>
          {keyword && <p className="mb-2 text-sm text-slate-600">'{keyword}' 검색 결과 {books.length}권</p>}
          {error && <p role="alert" className="mb-4 rounded bg-red-50 p-3 text-red-700">{error}</p>}
          <table className="w-full border-collapse bg-white text-left shadow-sm">
            <thead className="bg-slate-100 text-sm">
              <tr>
                <th className="p-3">번호</th>
                <th className="p-3">제목</th>
                <th className="p-3">저자</th>
                <th className="p-3">ISBN</th>
              </tr>
            </thead>
            <tbody>
              {books.map((b) => (
                <tr key={b.id} className="border-t border-slate-200">
                  <td className="p-3">{b.id}</td>
                  <td className="p-3 font-medium">{b.title}</td>
                  <td className="p-3">{b.author}</td>
                  <td className="p-3 font-mono text-sm text-slate-500">{b.isbn}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {books.length === 0 && !error && <p className="mt-4 text-slate-500">검색 결과가 없습니다.</p>}
        </section>
      )
    }
    ```

    회원 등록입니다. 서버도 같은 검증을 하지만(400 `INVALID_INPUT`), 뻔한 입력 실수는 요청 전에 막아 사용자가 바로 고칠 수 있게 합니다.

    **파일**: src/pages/MemberPage.tsx

    ```tsx
    import { useState, type FormEvent } from 'react'
    import { useApi } from '../api'
    import { toMessage } from '../api/errors'
    import type { Member } from '../api/types'

    const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    export default function MemberPage() {
      const api = useApi()
      const [name, setName] = useState('')
      const [email, setEmail] = useState('')
      const [error, setError] = useState('')
      const [created, setCreated] = useState<Member | null>(null)

      const onSubmit = async (e: FormEvent) => {
        e.preventDefault()
        setCreated(null)
        // 서버도 검증하지만(400 INVALID_INPUT), 뻔한 실수는 요청 전에 막는다
        if (!name.trim()) return setError('이름을 입력해 주세요.')
        if (!EMAIL.test(email)) return setError('이메일 형식이 올바르지 않습니다.')
        try {
          setCreated(await api.registerMember({ name: name.trim(), email }))
          setError('')
        } catch (err) {
          setError(toMessage(err))
        }
      }

      return (
        <section className="max-w-md">
          <h1 className="mb-4 text-2xl font-bold">회원 등록</h1>
          <form onSubmit={onSubmit} noValidate className="space-y-3 rounded bg-white p-6 shadow-sm">
            <label className="block">
              <span className="text-sm text-slate-600">이름</span>
              <input value={name} onChange={(e) => setName(e.target.value)}
                className="mt-1 w-full rounded border border-slate-300 px-3 py-2" />
            </label>
            <label className="block">
              <span className="text-sm text-slate-600">이메일</span>
              <input type="email" value={email} onChange={(e) => setEmail(e.target.value)}
                className="mt-1 w-full rounded border border-slate-300 px-3 py-2" />
            </label>
            <button className="w-full rounded bg-blue-600 py-2 text-white hover:bg-blue-700">가입</button>
          </form>
          {error && <p role="alert" className="mt-4 rounded bg-red-50 p-3 text-red-700">{error}</p>}
          {created && (
            <p role="status" className="mt-4 rounded bg-green-50 p-3 text-green-800">
              {created.name}님이 {created.id}번 회원으로 가입되었습니다.
            </p>
          )}
        </section>
      )
    }
    ```

    대출·반납입니다. 버튼 세 개(대출·반납·대출 목록 보기)가 모두 `run()`을 거치게 해서, 메시지를 비우고 → 호출하고 → 성공이나 오류를 보여 주는 순서를 한곳에 둡니다. 상태 표시에서 "연체"는 서버가 저장한 상태가 아니라 "대출 중 + 기한 경과"로 화면이 계산합니다 — 과제 2에서 연체를 별도 상태로 두지 않은 것과 같은 판단입니다.

    **파일**: src/pages/LoanPage.tsx

    ```tsx
    import { useEffect, useState, type FormEvent } from 'react'
    import { useApi } from '../api'
    import { toMessage } from '../api/errors'
    import type { Book, Loan } from '../api/types'

    const today = () => new Date().toLocaleDateString('sv-SE')

    function statusLabel(loan: Loan) {
      if (loan.status === 'RETURNED') return <span className="text-slate-500">반납 완료</span>
      if (loan.dueDate < today()) return <span className="font-semibold text-red-600">연체</span>
      return <span className="text-blue-700">대출 중</span>
    }

    export default function LoanPage() {
      const api = useApi()
      const [books, setBooks] = useState<Book[]>([])
      const [memberId, setMemberId] = useState('1')
      const [bookId, setBookId] = useState('')
      const [loans, setLoans] = useState<Loan[] | null>(null)
      const [notice, setNotice] = useState('')
      const [error, setError] = useState('')

      useEffect(() => {
        api.searchBooks().then(setBooks, (e) => setError(toMessage(e)))
      }, [api])

      // 모든 버튼이 같은 순서를 따른다: 메시지 비우기 → API 호출 → 성공 안내 또는 오류 코드별 안내
      const run = async (action: () => Promise<string>) => {
        setNotice('')
        setError('')
        try {
          setNotice(await action())
        } catch (e) {
          setError(toMessage(e))
        }
      }
      const refresh = async (id: number) => setLoans(await api.memberLoans(id))

      const onLoan = (e: FormEvent) => {
        e.preventDefault()
        if (!(Number(memberId) > 0)) return setError('회원 번호를 입력해 주세요.')
        if (!bookId) return setError('대출할 도서를 선택해 주세요.')
        run(async () => {
          const loan = await api.loan(Number(memberId), Number(bookId))
          await refresh(loan.memberId)
          return `'${loan.bookTitle}' 대출 완료 — 반납 기한 ${loan.dueDate}`
        })
      }
      const onReturn = (loan: Loan) =>
        run(async () => {
          await api.returnLoan(loan.id)
          await refresh(loan.memberId)
          return `'${loan.bookTitle}' 반납 완료`
        })
      const onShow = () =>
        run(async () => {
          await refresh(Number(memberId))
          return ''
        })

      return (
        <section>
          <h1 className="mb-4 text-2xl font-bold">대출·반납</h1>
          <form onSubmit={onLoan} className="mb-4 flex flex-wrap items-end gap-3 rounded bg-white p-6 shadow-sm">
            <label className="block">
              <span className="text-sm text-slate-600">회원 번호</span>
              <input type="number" min="1" value={memberId} onChange={(e) => setMemberId(e.target.value)}
                className="mt-1 block w-28 rounded border border-slate-300 px-3 py-2" />
            </label>
            <label className="block flex-1">
              <span className="text-sm text-slate-600">도서</span>
              <select value={bookId} onChange={(e) => setBookId(e.target.value)}
                className="mt-1 block w-full rounded border border-slate-300 px-3 py-2">
                <option value="">도서를 선택하세요</option>
                {books.map((b) => (
                  <option key={b.id} value={b.id}>{b.id}. {b.title}</option>
                ))}
              </select>
            </label>
            <button className="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">대출</button>
            <button type="button" onClick={onShow}
              className="rounded border border-slate-300 px-4 py-2 hover:bg-slate-100">대출 목록 보기</button>
          </form>
          {error && <p role="alert" className="mb-4 rounded bg-red-50 p-3 text-red-700">{error}</p>}
          {notice && <p role="status" className="mb-4 rounded bg-green-50 p-3 text-green-800">{notice}</p>}
          {loans && (
            <table className="w-full border-collapse bg-white text-left shadow-sm">
              <caption className="p-3 text-left font-semibold">회원 {memberId}번의 대출 목록</caption>
              <thead className="bg-slate-100 text-sm">
                <tr>
                  <th className="p-3">대출 번호</th>
                  <th className="p-3">도서</th>
                  <th className="p-3">대출일</th>
                  <th className="p-3">반납 기한</th>
                  <th className="p-3">상태</th>
                  <th className="p-3"></th>
                </tr>
              </thead>
              <tbody>
                {loans.map((l) => (
                  <tr key={l.id} className="border-t border-slate-200">
                    <td className="p-3">{l.id}</td>
                    <td className="p-3 font-medium">{l.bookTitle}</td>
                    <td className="p-3">{l.loanDate}</td>
                    <td className="p-3">{l.dueDate}</td>
                    <td className="p-3">{statusLabel(l)}</td>
                    <td className="p-3">
                      {l.status === 'LOANED' && (
                        <button onClick={() => onReturn(l)}
                          className="rounded border border-slate-300 px-3 py-1 text-sm hover:bg-slate-100">반납</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>
      )
    }
    ```

화면까지 타입 검사를 통과하는지 확인합니다.

```bash
npx tsc -b
```

```text
예상 결과
(아무것도 출력되지 않으면 타입 오류가 없는 것입니다)
```

---

## 5. 목업 모드로 실행하기

이 단계에서는 API 서버 없이 화면을 띄워 S0~S6을 눈으로 확인합니다. 개발 서버가 터미널을 붙잡으므로, 끝나면 `Ctrl+C`로 내립니다.

```bash
npm run dev:mock
```

```text
예상 결과
  VITE v8.3.1   mock   ready in 165 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

`ready` 줄의 `mock`이 현재 모드입니다. 브라우저에서 `http://localhost:5173/`을 엽니다.

![메인 화면 (목업 모드)](assets/practice/ui/05-home.png)

*그림 1. 메인 화면 — 소개 문구와 검색창, 신착 도서 3권, 화면별 바로가기*

첫 화면은 메인(S0)입니다. 가운데 **신착 도서**에는 목업 도서 4권 중 번호가 큰 3권(오브젝트·클린 코드·자바 ORM 표준 JPA 프로그래밍)이 최근 등록 순으로 나옵니다. 아래 **바로가기** 카드는 상단 메뉴와 같은 화면으로 이동합니다. 오른쪽 위의 "목업 데이터" 표시는 `.env.mock`의 `VITE_USE_MOCK=true`가 적용됐다는 뜻입니다.

검색창에 `자바`를 넣고 **검색**을 누릅니다.

![메인에서 검색한 결과 (목업 모드)](assets/practice/ui/06-search-result.png)

*그림 2. 검색 결과 — 메인의 검색이 도서 목록 화면(`/books?keyword=자바`)으로 이어짐*

화면이 도서 목록으로 바뀌고, 주소는 `http://localhost:5173/books?keyword=%EC%9E%90%EB%B0%94`가 됩니다. `%EC%9E%90%EB%B0%94`는 `자바`를 주소에 쓸 수 있게 바꾼 값이고, 브라우저에 따라 주소창에는 `자바`로 풀어서 보여 줍니다. 검색창에는 `자바`가 그대로 들어 있고, 표 위의 "'자바' 검색 결과 2권" 아래로 제목에 "자바"가 들어간 2권만 남았습니다(S0 → S1). 이 상태에서 새로 고침해도 같은 결과가 나오는 것은 검색어가 주소에 있기 때문입니다.

상단 메뉴의 **도서 목록**을 누르면 검색어 없이 `/books`로 이동해 전체 목록이 보입니다.

![도서 목록 화면 (목업 모드)](assets/practice/ui/01-book-list.png)

*그림 3. 도서 목록 — 검색어가 없으면 목업의 시드 도서 4권 전체*

검색어가 없으므로 과제 2의 `data.sql`과 같은 도서 4권이 번호순으로 모두 보입니다(S1). 검색창에 다른 검색어를 넣고 **검색**을 누르면 주소의 `?keyword=`가 바뀌면서 목록이 다시 걸러집니다.

상단 메뉴의 **대출·반납**으로 이동해 회원 번호 `1`, 도서 `1. 이펙티브 자바`를 고르고 **대출**을 누릅니다.

![대출 성공 화면](assets/practice/ui/02-loan-form.png)

*그림 4. 대출 성공 — 초록 안내에 반납 기한, 아래에 회원 1번의 대출 목록*

초록 안내의 반납 기한이 오늘로부터 14일 뒤(과제 2의 R6)이고, 아래 대출 목록에 방금 빌린 도서가 "대출 중"과 **반납** 버튼으로 나타납니다(S3·S4). 대출 번호가 2인 이유는 시드의 연체 대출이 1번을 먼저 차지했기 때문입니다 — 과제 2 서버와 같은 동작입니다.

같은 상태에서 **대출**을 한 번 더 누릅니다.

![중복 대출 409 안내](assets/practice/ui/03-loan-409.png)

*그림 5. 중복 대출 — 목업이 409 `BOOK_ALREADY_LOANED`를 던지고, 화면이 한글 안내로 바꿔 보여 줌*

목업이 서버와 같은 `ApiError(409, 'BOOK_ALREADY_LOANED', ...)`를 던지고, `toMessage()`가 요구사항 표의 안내 문구로 바꿨습니다(S5). 이어서 대출 목록의 **반납**을 누르면 상태가 "반납 완료"로 바뀝니다. 회원 번호를 `2`로 바꿔 대출을 시도하면 연체 안내가, **대출 목록 보기**를 누르면 빨간 "연체" 표시가 붙은 시드 대출이 보입니다.

목업 데이터는 메모리에만 있으므로 **브라우저를 새로 고치면 시드 상태로 돌아갑니다.** 과제 2 서버를 재시작하면 `create-drop`으로 DB가 초기화되던 것과 같은 성격입니다.

---

## 6. 테스트

**과제**: 5단계에서 손으로 확인한 흐름을 Vitest + Testing Library 테스트로 고정합니다. 이 단계의 목표는 **"화면을 띄워 눌러 본 것"을 "명령 한 번으로 다시 확인되는 것"으로 바꾸는 것**입니다. 테스트는 목업을 끼워 실행하므로 서버가 필요 없습니다.

| # | 테스트 | 확인하는 요구사항 |
|---|------|------|
| 1 | 신착 도서 3권을 최근 등록 순으로 보여 줌 | S0 신착 도서 |
| 2 | 메인에서 검색하면 도서 목록 화면으로 이동해 결과를 보여 줌 | S0 검색 → S1 |
| 3 | 시드 도서 4권을 표로 보여 줌 | S1 목록 |
| 4 | 검색어로 걸러 냄 | S1 검색 |
| 5 | 대출하면 완료 안내와 "대출 중" 행 | S3 |
| 6 | 같은 도서를 다시 빌리면 409 안내 | S5 (`BOOK_ALREADY_LOANED`) |
| 7 | 연체 회원 대출 시 안내 | S5 (`OVERDUE_MEMBER`) |
| 8 | 반납하면 "반납 완료" | S4 |
| 9 | 이메일 형식 오류면 요청을 보내지 않음 → 고치면 가입 | S2 |

Testing Library는 컴포넌트 내부 상태가 아니라 **사용자가 보는 것**(버튼 이름, 라벨, 안내 문구)으로 요소를 찾습니다. 그래서 내부 구현을 바꿔도 화면 동작이 같으면 테스트가 깨지지 않습니다. `userEvent`는 실제 사용자처럼 글자를 한 자씩 입력하고 클릭합니다.

??? example "모범 답안 — 테스트 2개 파일"

    테스트 공통 준비 파일입니다. `jest-dom`은 `toBeInTheDocument()`·`toHaveTextContent()` 같은 화면용 검증 메서드를 추가하고, `cleanup`은 테스트가 끝날 때마다 그린 화면을 지웁니다.

    **파일**: src/test/setup.ts

    ```ts
    import '@testing-library/jest-dom/vitest'
    import { cleanup } from '@testing-library/react'
    import { afterEach } from 'vitest'

    afterEach(cleanup) // 테스트마다 렌더한 화면을 지운다
    ```

    화면 테스트입니다. `renderAt()`은 테스트마다 **새 목업**을 `ApiContext`로 끼우고, `MemoryRouter`로 원하는 주소에서 시작합니다. 2번 테스트는 메인(`/`)에서 시작해 검색 버튼 하나로 화면이 바뀌는지를, 9번 테스트는 `vi.spyOn`으로 목업의 `registerMember` 호출 여부를 감시해 "요청을 보내지 않았다"를 확인합니다.

    **파일**: src/App.test.tsx

    ```tsx
    import { render, screen, within } from '@testing-library/react'
    import userEvent from '@testing-library/user-event'
    import { MemoryRouter } from 'react-router'
    import { describe, expect, it, vi } from 'vitest'
    import App from './App'
    import { ApiContext } from './api'
    import { createMockApi } from './api/mock'

    // 테스트마다 새 목업(시드 상태)을 끼워 화면을 그린다
    function renderAt(path: string) {
      const api = createMockApi()
      render(
        <ApiContext value={api}>
          <MemoryRouter initialEntries={[path]}>
            <App />
          </MemoryRouter>
        </ApiContext>,
      )
      return { api, user: userEvent.setup() }
    }

    // 대출 화면에서 회원 번호·도서를 골라 대출 버튼을 누른다
    async function loan(user: ReturnType<typeof userEvent.setup>, memberId: string, bookTitle: string) {
      await screen.findByRole('option', { name: `1. 이펙티브 자바` })
      await user.clear(screen.getByLabelText('회원 번호'))
      await user.type(screen.getByLabelText('회원 번호'), memberId)
      await user.selectOptions(screen.getByLabelText('도서'), screen.getByRole('option', { name: new RegExp(bookTitle) }))
      await user.click(screen.getByRole('button', { name: '대출' }))
    }

    describe('메인 화면', () => {
      it('신착 도서 3권을 최근 등록 순으로 보여 준다', async () => {
        renderAt('/')
        const latest = screen.getByRole('list', { name: '신착 도서' })
        expect(await within(latest).findByText('오브젝트')).toBeInTheDocument()
        expect(within(latest).getAllByRole('listitem')).toHaveLength(3)
        expect(within(latest).queryByText('이펙티브 자바')).not.toBeInTheDocument() // 가장 먼저 등록된 1번 도서는 빠진다
      })

      it('검색하면 도서 목록 화면으로 이동해 결과를 보여 준다', async () => {
        const { user } = renderAt('/')
        await user.type(screen.getByLabelText('검색어'), '자바')
        await user.click(screen.getByRole('button', { name: '검색' }))
        expect(await screen.findByRole('heading', { name: '도서 목록' })).toBeInTheDocument()
        expect(await screen.findByText("'자바' 검색 결과 2권")).toBeInTheDocument()
        expect(screen.getAllByRole('row')).toHaveLength(3) // 머리글 1 + 도서 2
      })
    })

    describe('도서 목록', () => {
      it('시드 도서 4권을 표로 보여 준다', async () => {
        renderAt('/books')
        expect(await screen.findByText('이펙티브 자바')).toBeInTheDocument()
        expect(screen.getAllByRole('row')).toHaveLength(5) // 머리글 1 + 도서 4
      })

      it('검색어로 제목·저자를 걸러 낸다', async () => {
        const { user } = renderAt('/books')
        await screen.findByText('클린 코드')
        await user.type(screen.getByLabelText('검색어'), '자바')
        await user.click(screen.getByRole('button', { name: '검색' }))
        expect(await screen.findByText('자바 ORM 표준 JPA 프로그래밍')).toBeInTheDocument()
        expect(screen.queryByText('클린 코드')).not.toBeInTheDocument()
      })
    })

    describe('대출·반납', () => {
      it('대출하면 완료 안내와 대출 중 행이 보인다', async () => {
        const { user } = renderAt('/loans')
        await loan(user, '1', '이펙티브 자바')
        expect(await screen.findByRole('status')).toHaveTextContent("'이펙티브 자바' 대출 완료")
        const row = screen.getByRole('row', { name: /이펙티브 자바/ })
        expect(within(row).getByText('대출 중')).toBeInTheDocument()
      })

      it('이미 대출 중인 도서를 다시 빌리면 409 안내를 보여 준다', async () => {
        const { user } = renderAt('/loans')
        await loan(user, '1', '이펙티브 자바')
        await screen.findByRole('status')
        await user.click(screen.getByRole('button', { name: '대출' }))
        expect(await screen.findByRole('alert')).toHaveTextContent('이미 대출 중인 도서입니다. 반납된 뒤에 다시 대출할 수 있습니다.')
      })

      it('연체 회원은 대출할 수 없다는 안내를 보여 준다', async () => {
        const { user } = renderAt('/loans')
        await loan(user, '2', '클린 코드')
        expect(await screen.findByRole('alert')).toHaveTextContent('연체 중인 도서가 있어 대출할 수 없습니다')
      })

      it('반납하면 상태가 반납 완료로 바뀐다', async () => {
        const { user } = renderAt('/loans')
        await loan(user, '1', '클린 코드')
        const row = await screen.findByRole('row', { name: /클린 코드/ })
        await user.click(within(row).getByRole('button', { name: '반납' }))
        expect(await screen.findByRole('status')).toHaveTextContent("'클린 코드' 반납 완료")
        expect(within(screen.getByRole('row', { name: /클린 코드/ })).getByText('반납 완료')).toBeInTheDocument()
      })
    })

    describe('회원 등록', () => {
      it('이메일 형식이 틀리면 요청을 보내지 않고 안내한다', async () => {
        const { api, user } = renderAt('/members/new')
        const register = vi.spyOn(api, 'registerMember')
        await user.type(screen.getByLabelText('이름'), '박새내기')
        await user.type(screen.getByLabelText('이메일'), 'new-at-example.com')
        await user.click(screen.getByRole('button', { name: '가입' }))
        expect(screen.getByRole('alert')).toHaveTextContent('이메일 형식이 올바르지 않습니다.')
        expect(register).not.toHaveBeenCalled()

        await user.clear(screen.getByLabelText('이메일'))
        await user.type(screen.getByLabelText('이메일'), 'new@example.com')
        await user.click(screen.getByRole('button', { name: '가입' }))
        expect(await screen.findByRole('status')).toHaveTextContent('박새내기님이 3번 회원으로 가입되었습니다.')
      })
    })
    ```

테스트를 실행합니다. `--reporter=verbose`를 붙이면 테스트 이름이 한 줄씩 출력됩니다.

```bash
npm test -- --reporter=verbose
```

```text
예상 결과
 ✓ src/App.test.tsx > 메인 화면 > 신착 도서 3권을 최근 등록 순으로 보여 준다 168ms
 ✓ src/App.test.tsx > 메인 화면 > 검색하면 도서 목록 화면으로 이동해 결과를 보여 준다 82ms
 ✓ src/App.test.tsx > 도서 목록 > 시드 도서 4권을 표로 보여 준다 17ms
 ✓ src/App.test.tsx > 도서 목록 > 검색어로 제목·저자를 걸러 낸다 51ms
 ✓ src/App.test.tsx > 대출·반납 > 대출하면 완료 안내와 대출 중 행이 보인다 113ms
 ✓ src/App.test.tsx > 대출·반납 > 이미 대출 중인 도서를 다시 빌리면 409 안내를 보여 준다 99ms
 ✓ src/App.test.tsx > 대출·반납 > 연체 회원은 대출할 수 없다는 안내를 보여 준다 75ms
 ✓ src/App.test.tsx > 대출·반납 > 반납하면 상태가 반납 완료로 바뀐다 103ms
 ✓ src/App.test.tsx > 회원 등록 > 이메일 형식이 틀리면 요청을 보내지 않고 안내한다 155ms

 Test Files  1 passed (1)
      Tests  9 passed (9)
```

![Vitest 실행 결과](assets/practice/ui/04-vitest.png)

*그림 6. `npm test -- --reporter=verbose` — 9개 테스트 모두 통과*

`describe` 이름 > `it` 이름 순서로 한 줄씩 찍히므로, 결과만 읽어도 어떤 요구사항이 지켜지는지 알 수 있습니다. 밀리초 숫자는 PC마다 다릅니다.

마지막으로 배포용 빌드와 린트를 확인합니다. `npm run build`는 타입 검사(`tsc -b`)를 먼저 하고, 통과하면 `dist/`에 배포용 파일을 만듭니다.

```bash
npm run build
npm run lint
```

```text
예상 결과
vite v8.3.1 building client environment for production...
✓ 155 modules transformed.
dist/index.html                   0.46 kB │ gzip:   0.31 kB
dist/assets/index-BmvtXgMr.css   13.17 kB │ gzip:   3.38 kB
dist/assets/index-CXhSjJ8L.js   320.39 kB │ gzip: 103.52 kB
✓ built in 608ms

> library-ui@0.0.0 lint
> oxlint
```

`oxlint`는 문제가 없으면 아무것도 출력하지 않고 끝납니다. 파일 이름의 해시(`BmvtXgMr` 등)는 내용이 바뀔 때마다 달라집니다 — 브라우저가 옛 파일을 캐시해 두어도 새 배포에서 새 파일을 받게 하는 장치입니다.

### 자주 나는 에러 → 원인

| 증상 | 원인 | 해결 |
|------|------|------|
| 화면이 스타일 없이 검은 글자로만 보임 | `index.css`에 `@import "tailwindcss";`가 없거나 `vite.config.ts`에 `tailwindcss()` 플러그인 누락 | 2단계 두 파일 확인 후 개발 서버 재시작 |
| 목업 모드인데 "서버에 연결할 수 없습니다" | `npm run dev`(실제 API 모드)로 실행 | `npm run dev:mock`으로 실행 — 메뉴 오른쪽에 "목업 데이터"가 보여야 함 |
| `.env.mock`을 고쳤는데 반영되지 않음 | 환경 변수는 개발 서버 기동 시점에 읽음 | `Ctrl+C` 후 다시 실행 |
| `tsc -b`에서 `This syntax is not allowed when 'erasableSyntaxOnly' is enabled` | `enum`이나 `constructor(public code: string)` 사용 | 필드를 선언하고 생성자에서 대입 (`errors.ts` 참고) |
| `Cannot find module 'react-router-dom'` | v6 이전 자료의 import를 그대로 씀 | v7부터는 `react-router` 하나에서 `BrowserRouter`·`NavLink` 등을 가져옴 |
| 테스트에서 `toBeInTheDocument is not a function` | `setup.ts`의 jest-dom import 누락, 또는 `vite.config.ts`의 `setupFiles` 경로 오타 | 6단계 `setup.ts`와 2단계 설정 확인 |
| 테스트에서 `Found multiple elements with the role "alert"` | `cleanup`이 없어 앞 테스트의 화면이 남아 있음 | `setup.ts`의 `afterEach(cleanup)` 확인 |
| 테스트에서 `Unable to find an element with the text` | 목록이 비동기로 채워지기 전에 `getBy...`로 찾음 | 처음 나타나는 요소는 `await screen.findBy...`로 기다림 |
| 메인에서 검색했는데 도서 목록이 전체로 나옴 | `BooksPage`가 검색어를 `useState('')`로 따로 들고 있어 주소의 `?keyword=`를 읽지 않음 | `useSearchParams()`로 주소에서 읽기 (4단계 모범 답안) |
| 메인 화면의 검색 버튼이 아무 반응 없음 | `<form onSubmit>` 대신 버튼 `onClick`만 달았거나 `e.preventDefault()` 누락으로 페이지 전체가 새로 고쳐짐 | 폼 제출에서 `preventDefault()` 후 `navigate()` |

---

## 채점 기준·셀프 체크

제출 전에 아래 항목을 스스로 점검합니다. 괄호 안은 배점입니다(100점).

| 영역 | 기준 | 배점 |
|------|------|------|
| 화면 기능 | S0~S4 동작 — 메인(신착 도서·검색 이동), 목록·검색, 회원 등록, 대출, 대출 목록·반납·연체 표시 | 30 |
| 오류 처리 | 오류 코드별 한글 안내(S5), 연결 실패 안내, 입력 검증 실패 시 요청을 보내지 않음 | 20 |
| API 계층 분리 | 화면 컴포넌트에 axios·URL이 없음, `LibraryApi` 인터페이스 하나로 실제 구현·목업 교체(S6) | 20 |
| 타입 | 응답 타입이 과제 2의 DTO 필드와 일치, `npm run build`(`tsc -b`) 통과 | 10 |
| 테스트 | Testing Library 테스트 8개 이상(메인·목록·검색·대출·409·반납·검증), `npm test` 통과 | 20 |

- [ ] `npm test`가 `Tests  9 passed`로 끝납니다
- [ ] `npm run build`와 `npm run lint`가 오류 없이 끝납니다
- [ ] `npm run dev:mock`으로 띄운 메인에서 `자바`를 검색하면 주소가 `/books?keyword=...`로 바뀌고 2권이 보입니다
- [ ] `npm run dev:mock`으로 띄운 화면에서 대출 → 중복 대출 안내 → 반납이 됩니다
- [ ] `src/pages/` 파일에 `axios`나 `/api/`라는 글자가 없습니다
- [ ] 목업의 오류 `code`가 과제 2 `ErrorCode`의 상수 이름과 같습니다

---

## 도전 과제

기본 과제를 마쳤다면 아래 중 하나 이상을 골라 확장해 봅니다. 위에 있을수록 쉽습니다.

| # | 과제 | 배우는 것 |
|---|------|----------|
| 1 | 도서 등록 화면(`/books/new`) — ISBN 13자리 검증, `DUPLICATE_ISBN` 안내 | 폼 검증 복습, 오류 코드 추가 |
| 2 | 도서 목록 각 행에 **대출하기** 링크 → `/loans?bookId=3`으로 이동하면 도서가 미리 선택됨 | `useSearchParams` 복습 (`BooksPage`의 `keyword`와 같은 방식) |
| 3 | 요청 중에는 버튼을 비활성화하고 "처리 중…" 표시 — 두 번 누르기 방지 | 로딩 상태, 중복 요청 방지 |
| 4 | 목업에 `setTimeout`으로 300ms 지연을 넣고, 테스트가 여전히 통과하는지 확인 | `findBy`가 기다리는 원리 |
| 5 | `toMessage`만 따로 테스트하는 `errors.test.ts` — 모든 코드와 연결 실패 경우 | 순수 함수 단위 테스트 |
| 6 | 대출 목록을 [TanStack Query](https://tanstack.com/query) 같은 서버 상태 라이브러리로 바꾸고, 대출·반납 후 자동 갱신 | 캐시 무효화 |

---

## 관련 페이지

- [[guide-java-practice-spring-library]] — 과제 2. 이 화면이 부르는 도서 대여 REST API
- [[guide-java-practice-library-merge]] — 과제 2-3. 이 화면을 실제 API와 연결하고 한 jar로 배포
- [[guide-java-track4-spring-web]] — Spring 웹 트랙 코스 안내
- [[java-study-ch06]] — Spring Boot 프로젝트·프로파일 (API 쪽 설정)
- [[java-study-ch09]] — 테스트 전략 (단위·통합·E2E의 역할 나누기)
