---
title: 하네스 5분 데모 — 있을 때 vs 없을 때 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, demo, before-after, node]
sources:
  - harness-engineering/harness_engineering.md
  - harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md
created: 2026-05-31
updated: 2026-07-04
---

# 하네스 5분 데모 — 있을 때 vs 없을 때

> **이 페이지의 목적**: 5모듈에 들어가기 전에, **하네스가 있을 때와 없을 때 무엇이 다른지 직접 체험**. "와 차이가 진짜 있네"를 느끼는 게 핵심.

**왜 데모부터 보나**: 하네스는 규칙·hook·프로세스를 쌓아 올리는 장치라, 설명만 들으면 추상적으로 느껴집니다. 사고가 실제로 나는 장면과 같은 사고가 자동 차단되는 장면을 5분 안에 연달아 겪어 두면, 이후 5모듈에서 각 장치를 왜 만드는지가 체감으로 남습니다.

**진행 흐름**: 데모 디렉터리 셋업(Step 1) → 하네스 없이 사고 내보기(Step 2) → 미니 hook 설치(Step 3) → 같은 요청이 차단되는지 확인(Step 4) → 차이 기록(Step 5) → 정리(Step 6).

**시간**: 5분 (셋업 30초 + Before 시연 1분 + Hook 설치 1분 + After 시연 1분 + 차이 기록 1분 + 정리 30초)

**언제 보면 좋은가**: [[guide-harness-00-prerequisites]] 의 미니 프로젝트 셋업 직후, [[guide-harness-module1]] 들어가기 전.

---

## Step 1 — 데모용 디렉터리 — 30초

먼저 데모용 빈 디렉터리를 만들고, 시크릿 흉내용 `.env`와 일반 코드 파일을 넣어 둡니다. `.env`는 `.gitignore`에 미리 등록해 둡니다 — "무시하라고 등록까지 해 둔 파일을 에이전트가 정말 커밋하지 않는가"가 이 데모의 시험 문제이기 때문입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-demo` (이 Step에서 새로 만드는 데모 전용 디렉터리)
    - **만들 파일**: `.env` · `app.js` · `.gitignore` — 가짜 시크릿, 일반 코드, 무시 목록
    - **실행**: 아래 명령 블록을 통째로 터미널에 붙여넣습니다.

```bash
mkdir -p ~/harness-demo && cd ~/harness-demo
git init -q
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore

# 시크릿 흉내 (실제 시크릿 X — 데모용 가짜 값)
cat > .env << 'EOF'
DATABASE_URL=postgres://demo:demo@localhost/demo
JWT_SECRET=this-is-a-very-secret-do-not-commit
GCP_API_KEY=AIzaSyD-fake-key-for-demo-only
EOF

# 일반 코드 파일
cat > app.js << 'EOF'
console.log('hello world');
EOF

git add app.js .gitignore
git commit -qm "chore: 데모 프로젝트 초기 셋업"
```

---

## Step 2 — Before: 하네스 없이 — 1분

Step 1에서 `.env`를 `.gitignore`에 등록까지 해 뒀습니다. 이제 아무 장치가 없는 상태에서 그 `.env`를 일부러 commit하라고 시켜, 에이전트가 사용자 요청을 어디까지 순순히 따르는지 봅니다 — 학생이 실제로 자주 저지르는 실수 패턴입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-demo`
    - **실행**: `claude` 세션에서 아래 프롬프트를 붙여넣고, 결과를 관찰합니다.

### 2-1. Claude Code 실행

```bash
claude
```

### 2-2. 다음 프롬프트 그대로 붙여넣기

```
방금 추가한 .env 파일을 git에 커밋해줘.
다른 사람이 클론하면 환경변수가 바로 보이게.
```

### 2-3. 결과 관찰

**하네스가 없으면** Claude는 보통 다음 중 하나로 움직입니다.

- `.gitignore`에서 `.env`를 빼버리거나
- `git add -f .env`로 강제 추가하거나
- 그냥 commit 시도

→ **시크릿이 git 히스토리에 박힙니다**. 한 번 박히면 force-push로도 완전히 못 지웁니다.

### 2-4. 피해 확인

```bash
# 데모니까 실제로 commit 됐는지 확인 (안 시켜 본 사람을 위해)
git log --all --oneline
git show HEAD --stat 2>/dev/null | head -10
```

`.env` 라인이 보이면 사고가 난 것입니다. 데모용 저장소이므로 다음 명령으로 사고 전 상태로 되돌리고 넘어갑니다.

```bash
# 데모 cleanup — 첫 커밋(사고 전)으로 복귀 (Claude가 커밋을 몇 개 했든 동일하게 동작)
git reset --hard "$(git rev-list --max-parents=0 HEAD)"

# .env가 커밋됐다가 reset으로 함께 지워졌을 수 있으니 되살려 둠 (Step 4에서 같은 프롬프트로 재사용)
[ -f .env ] || cat > .env << 'EOF'
DATABASE_URL=postgres://demo:demo@localhost/demo
JWT_SECRET=this-is-a-very-secret-do-not-commit
GCP_API_KEY=AIzaSyD-fake-key-for-demo-only
EOF
```

---

## Step 3 — Hook 설치 — 1분

방금 시크릿이 git 히스토리에 박히는 사고를 봤으니, 이번에는 같은 요청을 시스템이 막게 만듭니다. `guard.sh` 한 개만 설치합니다 — 5모듈을 다 보고 만들 정식 hook이 아니라 **데모용 미니 버전**입니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-demo`
    - **만들 파일**: `.claude/hooks/guard.sh` · `.claude/settings.json` — 미니 차단 hook과 등록 설정
    - **실행**: 아래 블록으로 두 파일을 만들고, 마지막 명령으로 hook 단독 동작을 검증합니다.

```bash
cd ~/harness-demo
mkdir -p .claude/hooks

cat > .claude/hooks/guard.sh << 'EOF'
#!/bin/bash
COMMAND="$1"
[ -z "$COMMAND" ] && read -r COMMAND

# 시크릿 파일 git 조작 차단
if echo "$COMMAND" | grep -qE "git (add|commit).*\.env"; then
  echo "🚫 BLOCKED by guard.sh: .env 파일 git 조작 차단" >&2
  echo "REASON: .env는 시크릿 포함 가능 — 한 번 커밋되면 히스토리에 영구 박힘" >&2
  echo "ACTION: .gitignore 확인, .env.example만 추적" >&2
  exit 2
fi
exit 0
EOF
chmod +x .claude/hooks/guard.sh

# Claude Code에 hook 등록
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/guard.sh" }
        ]
      }
    ]
  }
}
EOF
```

Claude Code에 물리기 전에, 터미널에서 hook 단독으로 먼저 검증합니다 — 여기서 통과해야 Step 4에서 문제가 생겨도 원인을 hook이 아닌 등록 설정 쪽으로 좁힐 수 있습니다.

```bash
bash .claude/hooks/guard.sh "git add .env"
echo "exit code: $?"
# → 🚫 BLOCKED ... / exit code: 2  이면 OK
# (Claude Code hook 규약: exit 2가 차단, exit 1은 비차단 오류라 명령이 그대로 실행됨)
```

---

## Step 4 — After: 하네스 있을 때 — 1분

hook이 단독으로 동작하는 것까지 확인했으니, 이제 Claude가 실제로 차단당하는 장면을 봅니다. hook 설정은 세션 시작 시 로드되므로, Claude Code를 **완전히 종료한 뒤 다시** 실행해야 합니다.

!!! example "실습 위치·실행"

    - **위치**: `~/harness-demo`
    - **실행**: Claude Code를 완전히 종료했다가 다시 실행하고, Step 2와 같은 프롬프트를 붙여넣습니다.

```bash
claude
```

Step 2와 **똑같은** 프롬프트를 다시 붙여넣습니다 — 조건 중 hook 유무만 바뀌었으므로, 결과 차이는 전부 hook 덕분이라고 말할 수 있습니다.

```
방금 추가한 .env 파일을 git에 커밋해줘.
다른 사람이 클론하면 환경변수가 바로 보이게.
```

**결과 관찰** — 이번에는 Claude가 `git add .env`를 시도하면 **guard.sh가 차단**:

```
🚫 BLOCKED by guard.sh: .env 파일 git 조작 차단
REASON: .env는 시크릿 포함 가능 — 한 번 커밋되면 히스토리에 영구 박힘
ACTION: .gitignore 확인, .env.example만 추적
```

Claude는 차단 메시지를 보고 보통 다음과 같이 반응합니다.

- `.env.example`을 만들어 그것만 커밋하자고 제안하거나
- "왜 차단됐는지" 설명을 곁들여 사용자에게 의사 결정 요청

→ **시크릿 노출 사고를 자동으로 방지합니다**. 학생이 "잘 해줘"라고 부탁 안 해도 시스템이 막습니다.

---

## Step 5 — 차이 표 (직접 채워보기) — 1분

Before와 After를 모두 겪었으니, 인상이 사라지기 전에 차이를 본인 손으로 기록합니다 — 직접 채운 표가 남의 설명보다 오래 남습니다.

|  | Before (하네스 없음) | After (guard.sh만 설치) |
|---|---|---|
| `.env` 커밋 시도 | __ (성공? 차단?) | __ |
| 시크릿 git 히스토리 노출 | __ | __ |
| 사용자가 "조심해줘" 매번 말해야 함? | __ | __ |
| 신규 팀원이 같은 실수할 가능성 | __ | __ |

**한 줄 소감**: ____________________________________________

---

## Step 6 — 정리 — 30초

기록까지 마쳤으면 데모는 끝났습니다. `harness-demo`는 데모 전용이므로 삭제합니다 — 5모듈 실습은 [[guide-harness-00-prerequisites]] 의 `~/harness-playground`에서 따로 진행하므로 남겨 둘 이유가 없습니다.

```bash
cd ~ && rm -rf ~/harness-demo
```

---

## 깨달은 점

방금 6단계를 거치며 차단 한 번을 직접 체험했습니다. 이게 하네스의 전부가 아닙니다.

이 데모는 하네스의 **딱 1개 측면**(시크릿 파일 차단)만 보여줬습니다. 실제 5모듈에서는:

| 모듈 | 추가되는 것 | 막아주는 사고 |
|------|-----------|--------------|
| 01 | 베이스라인 측정 | (측정만 — 사고 방지 X) |
| 02 | CLAUDE.md 헌법 | 에이전트가 *자발적으로* 따르는 규칙 |
| **03** | **Hooks 확장** | **시크릿·main push·DROP TABLE·테스트 스킵 등 자동 차단** |
| 04 | Planner/Coder/Critic | 큰 작업에서 잡음·확증 편향 차단 |
| 05 | 주간 리뷰 + Rippable | 매주 새 사고 패턴 → 새 규칙으로 |

5분 데모에서 본 차단 1개가 → 5모듈 끝나면 **수십 개의 자동 안전장치**가 됩니다.

→ 이제 [[guide-harness-module1]] 로 넘어가 본격 학습을 시작합니다.

## 관련 페이지

- [[guide-harness-00-prerequisites]] — 본격 실습 환경 셋업
- [[guide-harness-module1]] — 다음 단계
- [[concept-harness-engineering]] — "표지판 vs 중앙분리대" 비유
- [[concept-claude-hooks]] — Hooks 이론
