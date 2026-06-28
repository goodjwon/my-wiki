---
title: 하네스 실습 사전 안내 (Module 00 — Prerequisites)
type: synthesis
tags: [harness, claude-code, guide, prerequisites, onboarding, glossary, node, gcp]
sources:
  - harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md
  - harness-engineering/harness_engineering.md
created: 2026-05-31
updated: 2026-06-28
---

# 하네스 실습 사전 안내 (Module 00 — Prerequisites)

[[src-harness-engineering|5모듈 커리큘럼]]을 실제로 따라 하기 전에 읽어야 하는 페이지. **이 페이지에서 막히면 module1을 시작하지 말 것.**

## 대상 학습자 (이 위키 기준)

- **Node.js (Express/Fastify) + React** 개발자
- 나중에 **GCP — App Engine / Cloud Run / Cloud Functions** 로 배포할 계획
- AI 코딩 도구(Claude Code) 사용 중, 같은 실수가 반복돼 답답함을 느낌

> 원본 자료(`raw/harness-engineering/`)는 **Spring Boot + DDD** 기준으로 작성됨. 이 위키의 guide는 그 원본을 **Node 학습자용 step-by-step**으로 옮긴 것. 원칙은 스택 무관.

## 권장 학습 흐름

```
[Step A] 이 페이지 사전 조건 확인 + 실습용 미니 프로젝트 만들기
              ↓
[Step B] Module 01~05 학습 — 모두 임시 프로젝트(harness-playground/)에서 진행
         · 깨져도 부담 없는 환경에서 하네스 개념·도구를 손에 익힘
         · CLAUDE.md, hooks, AGENTS.md, 주간 리뷰 루틴까지 한 번 다 돌려 봄
              ↓
[Step C] 5모듈 종료 후 — 본인 기존 프로젝트로 이식
         · 임시 프로젝트에서 검증된 .claude/, CLAUDE.md, AGENTS.md를
           본인 프로젝트에 복사 + 본인 스택/도메인에 맞춰 커스터마이즈
         · 본인 프로젝트의 첫 베이스라인을 다시 측정 (Module 01 절차 한 번 더)
         · 본인 프로젝트만의 STOP 트리거를 발견하면서 진짜 하네스가 됨
```

핵심: **실습은 임시 프로젝트로, 실전은 본인 프로젝트로.** 처음부터 본인 프로젝트에서 하면 실수·롤백이 부담스럽다.

## 시간 예상

| 모듈 | 학습 + 실습 | 비고 |
|------|-----------|------|
| 00 (이 페이지) | 30분 | 사전 조건 + 용어 |
| 01 Failure Audit·베이스라인 | 1시간 | git log 분석 + 태스크 3개 실행 |
| 02 CLAUDE.md 작성 | 1.5시간 | 템플릿 커스터마이징 + Before/After |
| 03 Hooks | 1.5시간 | 스크립트 설치·검증 + 자기검증 루프 |
| 04 멀티 에이전트 | 2시간 | AGENTS.md + Planner/Coder/Critic 드라이런 |
| 05 진화·리뷰 | 1시간 + **매주 반복** | 첫 주간 리뷰는 1시간, 이후 30분/주 |

## 사전 조건 (도구·환경)

### 필수 (모두 필요)

| 도구              | 용도                                                          | 확인 명령                     | 권장 버전   |
| --------------- | ----------------------------------------------------------- | ------------------------- | ------- |
| **Node.js**     | 본인 프로젝트 + hook 일부                                           | `node --version`          | 20 LTS+ |
| **npm**         | 패키지 매니저                                                     | `npm --version`           | 10+     |
| **git**         | 변경 이력 분석 + 하네스 자산 커밋                                        | `git --version`           | 2.40+   |
| **Claude Code** | 이 커리큘럼의 실행 도구                                               | `claude --version`        | 최신      |
| **실습용 프로젝트**    | 임시 프로젝트 권장. 본 페이지 아래 [실습용 미니 프로젝트 만들기](#실습용-미니-프로젝트-만들기-react--express-풀스택) 참고 | `ls ~/harness-playground` | —       |

### Claude Code 설치 (안 돼 있다면)

```bash
# 권장: npm
npm install -g @anthropic-ai/claude-code

# 또는 macOS / Linux 설치 스크립트
curl -fsSL https://claude.ai/install.sh | sh
```

설치 후 본인 프로젝트로 이동해서 한 번 실행 → 로그인:
```bash
cd <본인-node-프로젝트>
claude
```

### 권장 (있으면 좋음)

| 도구 | 용도 |
|------|------|
| **ESLint** | 코드 린트 (module3의 lint-fix.sh가 호출) |
| **Prettier** | 코드 포맷 |
| **Jest / Vitest** | 테스트 러너 (자기검증 루프) |
| **gcloud CLI** | 나중 GCP 배포 시 |

빠르게 설치:
```bash
npm install --save-dev eslint prettier jest
```

## 실습용 미니 프로젝트 만들기 (React + Express 풀스택)

5모듈 학습 동안 **깨져도 부담 없는** 미니 풀스택 프로젝트. 다음 Step을 그대로 따라가면 약 10분에 완성. **각 Step 끝에 git commit 메시지 제공.**

최종 구조:
```
~/harness-playground/
├── api/        # Express 백엔드 (User CRUD API)
├── web/        # React 프론트 (User 목록 화면)
└── .git/
```

### Step A-1: 모노레포 골격 + git 초기화 (1분)

```bash
mkdir -p ~/harness-playground && cd ~/harness-playground

# 최상위 메타
cat > package.json << 'EOF'
{
  "name": "harness-playground",
  "private": true,
  "version": "0.0.1",
  "workspaces": ["api", "web"],
  "scripts": {
    "dev:api": "npm --workspace api run dev",
    "dev:web": "npm --workspace web run dev",
    "test": "npm --workspace api test",
    "lint": "npm --workspace api run lint && npm --workspace web run lint"
  }
}
EOF

cat > .gitignore << 'EOF'
node_modules/
dist/
.env
.env.*
!.env.example
coverage/
*.log
.DS_Store
EOF

cat > README.md << 'EOF'
# harness-playground

하네스 엔지니어링 5모듈 학습용 미니 풀스택.

- api/  : Express + Zod (in-memory User CRUD)
- web/  : Vite + React (User 목록 화면)

## 실행
- npm install
- npm run dev:api   # http://localhost:3000
- npm run dev:web   # http://localhost:5173
- npm test
EOF

git init
git add .
git commit -m "chore: harness-playground 모노레포 초기화"
```

### Step A-2: api/ — Express 백엔드 (3분)

```bash
cd ~/harness-playground
mkdir -p api/src && cd api

cat > package.json << 'EOF'
{
  "name": "api",
  "version": "0.0.1",
  "private": true,
  "type": "commonjs",
  "scripts": {
    "dev": "node --watch src/server.js",
    "start": "node src/server.js",
    "test": "jest",
    "lint": "eslint src",
    "format": "prettier --write src"
  }
}
EOF

npm install express zod cors
npm install --save-dev jest supertest eslint prettier

cat > src/app.js << 'EOF'
const express = require('express');
const cors = require('cors');
const { z } = require('zod');

const app = express();
app.use(cors());
app.use(express.json());

// in-memory store (실습용)
const users = [
  { id: 1, email: 'alice@example.com', name: 'Alice' },
  { id: 2, email: 'bob@example.com', name: 'Bob' },
];

const UserInput = z.object({
  email: z.string().email(),
  name: z.string().min(1),
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

app.get('/users', (req, res) => {
  res.json(users);
});

app.post('/users', (req, res) => {
  const parsed = UserInput.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }
  const user = { id: users.length + 1, ...parsed.data };
  users.push(user);
  res.status(201).json(user);
});

module.exports = app;
EOF

cat > src/server.js << 'EOF'
const app = require('./app');
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`api listening on ${port}`));
EOF

cat > src/app.test.js << 'EOF'
const request = require('supertest');
const app = require('./app');

describe('GET /health', () => {
  it('returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('POST /users', () => {
  it('rejects invalid email', async () => {
    const res = await request(app).post('/users').send({ email: 'bad', name: 'X' });
    expect(res.status).toBe(400);
  });
  it('creates a user', async () => {
    const res = await request(app).post('/users').send({ email: 'c@d.com', name: 'Carol' });
    expect(res.status).toBe(201);
    expect(res.body.id).toBeDefined();
  });
});
EOF

cat > eslint.config.js << 'EOF'
module.exports = [
  {
    files: ['src/**/*.js'],
    languageOptions: { ecmaVersion: 2022, sourceType: 'commonjs', globals: { process: 'readonly', console: 'readonly' } },
    rules: { 'no-unused-vars': 'warn', 'no-empty': ['error', { allowEmptyCatch: false }] },
  },
];
EOF

cat > .prettierrc.json << 'EOF'
{ "singleQuote": true, "semi": true, "printWidth": 100 }
EOF

cat > .env.example << 'EOF'
PORT=3000
EOF

cd ..
git add api
git commit -m "feat(api): Express User CRUD + Zod 검증 + 테스트"
```

### Step A-3: web/ — React 프론트 (3분)

> ⚠️ **한 번에 붙여넣지 말 것.** 첫 줄 `npm create vite` 는 대화형 프롬프트(패키지 설치 확인 `Ok to proceed? (y)`, Vite 버전·롤다운 선택 등)가 뜰 수 있다. 아래 `cat ... << EOF` heredoc·`npm install` 과 한꺼번에 붙여넣으면 **프롬프트 대기 중 뒷줄이 응답으로 먹혀** 스캐폴딩이 깨진다. **블록 1을 먼저 끝내고(프롬프트엔 Enter / y), 그다음 블록 2를 붙여넣을 것.**

**블록 1 — React 스캐폴딩 + 설치** (프롬프트가 뜨면 Enter / y 로 진행)

```bash
cd ~/harness-playground

# Vite React 템플릿 — 프로젝트명(web)·템플릿을 인자로 줘 질문을 최소화
npm create vite@latest web -- --template react

cd web
npm install
cd ..
```

**블록 2 — 화면 코드 작성 + 커밋** (블록 1이 완전히 끝난 뒤 붙여넣기)

```bash
cd ~/harness-playground/web

# User 목록 화면
cat > src/App.jsx << 'EOF'
import { useEffect, useState } from 'react';
import './App.css';

const API = 'http://localhost:3000';

export default function App() {
  const [users, setUsers] = useState([]);
  const [form, setForm] = useState({ email: '', name: '' });
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${API}/users`).then((r) => r.json()).then(setUsers).catch(() => setError('API 연결 실패'));
  }, []);

  async function addUser(e) {
    e.preventDefault();
    setError(null);
    const res = await fetch(`${API}/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    });
    if (!res.ok) {
      const body = await res.json();
      setError(JSON.stringify(body.error));
      return;
    }
    const created = await res.json();
    setUsers((prev) => [...prev, created]);
    setForm({ email: '', name: '' });
  }

  return (
    <main style={{ fontFamily: 'system-ui', padding: 24, maxWidth: 640, margin: '0 auto' }}>
      <h1>Harness Playground — Users</h1>

      <form onSubmit={addUser} style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        <input
          placeholder="email"
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
        />
        <input
          placeholder="name"
          value={form.name}
          onChange={(e) => setForm({ ...form, name: e.target.value })}
        />
        <button type="submit">추가</button>
      </form>

      {error && <p style={{ color: 'crimson' }}>에러: {error}</p>}

      <ul>
        {users.map((u) => (
          <li key={u.id}>
            #{u.id} — {u.name} ({u.email})
          </li>
        ))}
      </ul>
    </main>
  );
}
EOF

# 기본 main.jsx는 Vite가 생성한 그대로 유지

cd ..
git add web
git commit -m "feat(web): React 사용자 목록 + 추가 폼"
```

### Step A-4: 동작 확인 (2분)

> ⚠️ **API와 프론트는 두 터미널에서 동시에 떠 있어야 한다.** `npm run dev:web` 은 포그라운드 장기 실행 서버라, 같은 블록에 두고 붙여넣으면 거기서 멈춰 뒷줄(서버 정리 등)이 실행되지 않는다. 아래처럼 **블록 1(API 검증) → 블록 2(프론트, 다른 터미널) → 블록 3(정리)** 순서로.

**블록 1 — 의존성 설치 + API 검증** (터미널 ①)

```bash
cd ~/harness-playground
npm install                          # 워크스페이스(api·web) 전체 설치

npm run dev:api &                    # API 백그라운드로 띄우기
sleep 2                              # 부팅 대기 (느리면 3~5로)
curl http://localhost:3000/health    # → {"status":"ok",...}
curl http://localhost:3000/users     # → [{"id":1,...}, {"id":2,...}]

cd api && npm test && cd ..          # 백 테스트 3개 통과해야 정상
```

→ API는 백그라운드로 **계속 떠 있게 둔다** (프론트가 호출해야 하므로).

**블록 2 — 프론트 띄우기** (터미널 ② — 새 탭/창)

```bash
cd ~/harness-playground
npm run dev:web
# → 브라우저로 http://localhost:5173 접속, 사용자 목록 보이면 OK.
#   확인 끝나면 이 터미널에서 Ctrl+C 로 종료.
```

**블록 3 — API 정리** (터미널 ① 로 돌아와)

```bash
kill %1 2>/dev/null                   # 백그라운드 API 종료
```

### Step A-5: Claude Code 한 번 실행 (1분)

```bash
cd ~/harness-playground
claude
```

첫 메시지로 다음을 그대로 붙여넣어 동작 확인:

```
이 프로젝트 구조를 확인하고 api/와 web/이 각각 어떤 역할인지 한 줄씩 요약해줘.
```

응답이 오면 정상. `/exit` 으로 종료.

```bash
git log --oneline
# → 3개의 커밋이 보여야 정상 (최신순):
#   feat(web): React 사용자 목록 + 추가 폼
#   feat(api): Express User CRUD + Zod 검증 + 테스트
#   chore: harness-playground 모노레포 초기화
```

여기까지 통과하면:

1. **추천 순서**: 먼저 [[guide-harness-demo]] (5분 데모, 하네스 있음 vs 없음 직접 체험) → [[guide-harness-module1]]
2. **바로 본격**: [[guide-harness-module1]] 로 진입

**본인 프로젝트가 따로 있어도 module1~5는 이 playground에서 진행**, 5모듈 종료 후 본인 프로젝트로 이식 ([5모듈 종료 후 이식](#5모듈-종료-후--본인-기존-프로젝트로-이식)).

---

### 미래 (Module 05 이후 GCP 배포)

이 커리큘럼 자체에서는 GCP 명령을 쓰지 않지만, 나중을 위해 알아두면 좋은 것:
- **Cloud Functions** (서버리스 함수)
- **Cloud Run** (컨테이너 기반)
- **App Engine** (PaaS)

→ 하네스의 STOP 트리거에 "프로덕션 환경변수 노출 금지", "`gcloud deploy` 직접 실행 금지" 같은 GCP 친화 규칙을 추가하게 된다 (module5).

## 5분 요약: 하네스 엔지니어링이 뭔가

**한 줄로**: AI에게 "잘 해줘"라고 부탁하는 대신, AI가 잘못된 일을 **구조적으로 못 하게 만드는 시스템**을 갖추는 일.

**왜 필요한가**: 프롬프트(부탁)는 무시될 수 있지만, hook(코드 실행 직전 검사)은 **물리적으로 막는다**. "표지판 vs 중앙분리대"의 차이.

**Node + GCP 학습자에게 구체적으로**:
- "`.env` 파일을 commit하지 마"라고 매번 부탁할 필요 없음 → guard.sh가 차단
- "테스트 없이 함수 추가하지 마"라고 매번 부탁할 필요 없음 → CLAUDE.md + 자기검증 루프
- "GCP 시크릿 키를 console.log 하지 마" → guard.sh가 차단
- "`gcloud deploy` 직접 실행하지 마" → guard.sh가 차단

**5개 모듈은 누적형**:
```
Module 1 (실패 패턴 찾기)
   → Module 2 (CLAUDE.md 규칙으로 적기)
       → Module 3 (Hooks로 강제)
           → Module 4 (여러 에이전트로 역할 분담)
               → Module 5 (매주 진화시키기)
```

자세한 이론: [[concept-harness-engineering]]

## 핵심 용어 사전

처음 등장할 때 막힐 만한 용어들. 본문에서 만나면 여기로 돌아오라.

### 하네스·에이전트 일반

| 용어 | 풀이 |
|------|------|
| **하네스(Harness)** | 원래는 말·소에게 채우는 마구. 여기서는 **AI 에이전트를 둘러싼 환경 전체** — 규칙 파일 + 자동화 스크립트 + 검증 루프. |
| **에이전트(Agent)** | 챗봇과 달리 도구(파일 읽기·쓰기, 명령 실행)를 써서 여러 단계 작업을 자율 수행하는 AI. Claude Code가 대표. |
| **프롬프트(Prompt)** | AI에게 그때그때 건네는 단발성 지시. 이 자료에서는 "부탁"이라 부름. |
| **컨텍스트 윈도우** | 모델이 한 번에 "볼 수 있는" 텍스트의 최대 분량. |
| **컨텍스트 희석** | 대화가 길어지면 초반 지시의 영향력이 옅어지는 현상. |

### CLAUDE.md 관련

| 용어 | 풀이 |
|------|------|
| **CLAUDE.md** | Claude Code가 **프로젝트 루트에서 자동으로 읽는** 규칙 파일. 매 세션 시작 시 가장 먼저 로드. 곧 "에이전트 헌법". |
| **AGENTS.md** | CLAUDE.md와 같은 역할이지만 **모델 불가지론적** — Codex/Gemini 등 다른 에이전트도 읽는 공용 표준. |
| **STOP 트리거** | "에이전트가 X를 하려 하면 즉시 멈춰라"의 규칙 목록. CLAUDE.md 섹션 7에 적음. |
| **Karpathy 4원칙** | Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution. Andrej Karpathy가 자신의 CLAUDE.md에서 정리한 4가지. |

### Hooks 관련

| 용어 | 풀이 |
|------|------|
| **Hook(훅)** | 에이전트 라이프사이클의 특정 시점에 **자동 실행되는 사용자 스크립트**. |
| **PreToolUse / PostToolUse** | 각각 "도구 실행 직전 / 직후"에 발동. 차단은 주로 PreToolUse. |
| **`.claude/settings.json`** | 프로젝트의 Claude Code 설정 파일. hooks 등록 위치. (없으면 만든다) |
| **`.claude/hooks/`** | 사용자가 만든 hook 스크립트(`*.sh`)를 두는 폴더. |
| **exit code** | 스크립트의 종료 코드. **0이 아니면** Claude Code가 도구 실행을 막음. |
| **Back-pressure** | 테스트 실패 같은 하류 결과가 상류 에이전트로 되돌아와 다음 행동을 압박. |

### 멀티 에이전트

| 용어 | 풀이 |
|------|------|
| **Planner / Coder / Critic** | 역할이 분리된 3개 에이전트. 계획 수립 / 코드 작성 / 비판 검증. |
| **컨텍스트 방화벽** | 잡음·중간 산출물이 다른 작업으로 새지 않도록 별도 컨텍스트로 격리하는 것. |
| **CONDITIONAL REJECT** | Critic의 판정 중 "조건부 반려" — 수정하면 통과 가능. |
| **claude-progress.txt** | 새 세션이 가장 먼저 읽는 진행 기록 파일. 컨텍스트 인계용. |

### 진화·운영

| 용어 | 풀이 |
|------|------|
| **Drift(드리프트)** | 작업이 길어질수록 에이전트 출력이 처음 의도에서 점점 벗어나는 현상. |
| **Rippable Harness** | "**떼어낼 수 있는**" 하네스. 모델이 좋아지면 일부 규칙은 오히려 짐이 되므로 버려야. |
| **주간 하네스 리뷰** | 매주 실패 패턴을 모아 규칙·스크립트로 전환하는 정기 점검. |

### 원본의 DDD 용어 (참고만)

원본 Spring 자료가 자주 쓰는 용어. **Node 학습자는 단어만 알아두면 OK**, 직접 적용 안 해도 됨.

| 원본 용어 | Node 친화 대응 |
|----------|-------------|
| Entity | Mongoose/Prisma 모델 클래스 |
| Value Object (VO) | 검증 로직이 있는 간단 객체 (Zod/Joi 스키마 등) |
| Aggregate | 함께 묶이는 도메인 객체 그룹 |
| Repository | DB 접근 모듈 (services/users.repo.js 같은) |
| N+1 문제 | ORM에서 1+N개의 쿼리가 나가는 성능 문제 |
| @Autowired 필드 주입 | (Node에서는 거의 무관) |

### 출처 인물

| 인물 | 누구 |
|------|------|
| **Andrej Karpathy** | 전 OpenAI/Tesla AI 디렉터. 자신의 CLAUDE.md 공개로 "선언 층" 패턴을 정립. |
| **Mitchell Hashimoto** | HashiCorp 창업자. "실패할 때마다 시스템을 엔지니어링하라"는 피드백 루프 원칙 제시. |
| **OpenAI Harness Engineering** | OpenAI 내부 5개월 실험 ("100만 줄 생성, 인간 코드 0줄"). 컨텍스트·라이프사이클 인프라 패턴 공개. |

## 명령어 치환표 (Spring 원본 → Node)

원본 자료에서 Spring/Gradle 명령이 나오면 다음으로 치환:

| 원본 (Spring·Gradle) | Node 대응 |
|---------------------|----------|
| `./gradlew test` | `npm test` |
| `./gradlew test --tests "X"` | `npm test -- X` (Jest), `npx vitest run X` (Vitest) |
| `./gradlew checkstyleMain` | `npx eslint .` |
| `./gradlew build` | `npm run build` |
| `./gradlew compileJava` | `npx tsc --noEmit` (TS) / 별도 없음 (JS) |
| `./gradlew integrationTest` | `npm run test:integration` (정의해 두기) |
| `migration 파일 (V1__*.sql)` | DB 마이그레이션 도구 (Prisma migrate, Knex, Sequelize 등) |
| `application.properties` | `.env` 파일 |
| `@Autowired` | (Node에서는 보통 require/import 직접 사용) |

## 어디서 시작? — 학습자 유형별 진입

| 유형 | 시작 |
|------|------|
| **Claude Code 처음 — 환경부터 모름** | [사전 조건](#사전-조건-도구환경) → Claude Code 설치 → [실습용 미니 프로젝트 만들기](#실습용-미니-프로젝트-만들기-react--express-풀스택) → [[guide-harness-module1]] |
| **Claude Code는 써봤지만 하네스는 처음** | [용어 사전](#핵심-용어-사전) 훑기 → [실습용 미니 프로젝트 만들기](#실습용-미니-프로젝트-만들기-react--express-풀스택) → [[concept-harness-engineering]] → [[guide-harness-module1]] |
| **이미 CLAUDE.md를 만져 봄** | 미니 프로젝트는 스킵 가능. 본인 프로젝트에 `harness-learn` 브랜치 만들고 [[guide-harness-module1]] 베이스라인부터. |

## 5모듈 종료 후 — 본인 기존 프로젝트로 이식

임시 프로젝트(`~/harness-playground`)에서 5모듈을 다 돌렸다면 다음 흐름으로 본인 프로젝트에 적용:

```bash
# 1. 본인 프로젝트로 이동, 안전한 별도 브랜치
cd <본인-기존-프로젝트>
git checkout -b harness-bootstrap

# 2. 임시 프로젝트의 하네스 자산 복사
cp ~/harness-playground/CLAUDE.md .
cp ~/harness-playground/AGENTS.md .
cp -r ~/harness-playground/.claude .

# 3. 본인 스택/도메인에 맞춰 커스터마이즈
#    - CLAUDE.md 섹션 1 (Tech Stack)을 실제 의존성으로
#    - 섹션 6 (프로젝트 구조)을 실제 디렉터리 트리로
#    - 섹션 7 (STOP)에서 임시 프로젝트에만 해당하는 규칙 제거
#    - guard.sh의 마이그레이션 패턴을 본인 ORM에 맞춤

# 4. 본인 프로젝트의 첫 베이스라인을 다시 측정
#    (Module 01 절차 한 번 더, 본인 git log 기준)

# 5. 본인 프로젝트만의 STOP 트리거를 발견하며 진짜 하네스가 됨
#    (몇 주 동안 주간 리뷰 반복)

git add CLAUDE.md AGENTS.md .claude
git commit -m "harness: playground에서 하네스 자산 가져오기"
# PR 만들어 팀 리뷰 후 main 머지
```

핵심: **임시에서 배운 형식 + 본인 프로젝트에서 발견한 내용** = 진짜 하네스. 형식만 복사하고 끝내면 죽은 자산.

## 막힐 때 (공통 FAQ)

### Q. `.claude/settings.json`이 없는데요
없으면 만들면 된다. 빈 JSON `{}`으로 시작해서 hooks 블록만 추가:
```bash
mkdir -p .claude
echo '{}' > .claude/settings.json
```

### Q. hook 스크립트가 실행 안 돼요
```bash
chmod +x .claude/hooks/*.sh
ls -la .claude/hooks/  # 실행 권한(x)이 있는지 확인
```

### Q. `git log` 결과가 적어요 / git 저장소가 아니에요
```bash
cd <본인-프로젝트>
git init
git add .
git commit -m "chore: 초기 커밋"
```

### Q. CLAUDE.md를 두긴 했는데 Claude가 진짜 읽었는지 모르겠어요
세션 시작 후 첫 메시지로 확인:
```
CLAUDE.md 섹션 7의 STOP 트리거 첫 두 항목을 그대로 인용해줘.
```
인용해주면 읽은 것. 못 하면 위치(프로젝트 루트인지)나 권한 확인.

### Q. 자기검증 루프에서 `npm test`가 환경 문제로 실패해요
환경 문제 vs 코드 문제를 먼저 분리:
1. 본인이 직접 명령 실행 → 환경 OK?
2. 환경 문제면 ▶ Claude에게 위임 X (먼저 환경 고치기)
3. 코드 문제면 ▶ 자기검증 루프가 잡아야 함

### Q. AGENTS.md vs CLAUDE.md, 둘 다 만들어야 하나요
한 프로젝트에서 한 모델(Claude만)만 쓴다면 **CLAUDE.md만** 필요. 여러 모델(Claude + Codex 등)을 섞으면 AGENTS.md 추가.

### Q. 본인 프로젝트가 작아서(개인 프로젝트) DDD 같은 게 부담스러워요
**무시해도 된다.** 원본 템플릿의 DDD 섹션은 module2에서 본인 Node 패턴(컨트롤러/서비스/리포지토리, 또는 hooks/api/lib)으로 교체. 핵심은 4원칙 + STOP 트리거 + 누적 실패 패턴.

### Q. 나중에 GCP/Cloud Functions 배포할 건데 지금 뭘 미리 해두면 좋아요
module2 CLAUDE.md 작성 시 다음을 STOP 트리거에 미리 적어두면 좋다:
```
STOP: .env*, *credentials.json, *service-account.json 커밋 시도
STOP: gcloud deploy / gcloud functions deploy 직접 실행
STOP: console.log(process.env.*) 디버그 코드 잔존
STOP: API 응답에 password / secret / token 필드 노출
```
module3에서 이걸 guard.sh로 자동 차단으로 격상.

## 관련 페이지

- [[src-harness-engineering]] — 전체 커리큘럼
- [[concept-harness-engineering]] — 이론 배경 (마구 비유, 시대 진화, 4원칙)
- [[guide-harness-module1]] — 첫 모듈 (Node 친화 step-by-step)
- [[concept-claude-md]] / [[concept-claude-hooks]] / [[concept-multi-agent-pattern]] — 각 층 이론
