---
title: 하네스 5분 데모 — 있을 때 vs 없을 때 (Node 친화 step-by-step)
type: synthesis
tags: [harness, claude-code, guide, demo, before-after, node]
sources:
  - harness-engineering/harness_engineering.md
  - harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md
created: 2026-05-31
updated: 2026-06-28
---

# 하네스 5분 데모 — 있을 때 vs 없을 때

> **이 페이지의 목적**: 5모듈에 들어가기 전에, **하네스가 있을 때와 없을 때 무엇이 다른지 직접 체험**. "와 차이가 진짜 있네"를 느끼는 게 핵심.

**시간**: 5분 (셋업 1분 + Before 시연 1분 + Hook 설치 1분 + After 시연 1분 + 정리 1분)

**언제 보면 좋은가**: [[guide-harness-00-prerequisites]] 의 미니 프로젝트 셋업 직후, [[guide-harness-module1]] 들어가기 전.

---

## Step 1 — 데모용 폴더 — 30초

먼저 데모용 빈 폴더를 만들고, 시크릿 흉내용 `.env`와 일반 코드 파일을 넣어 둔다.

```bash
mkdir -p ~/harness-demo && cd ~/harness-demo
git init -q
echo "node_modules/" > .gitignore

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

`.env`를 Git에 commit하라고 시키는 시나리오 (학생이 자주 실수하는 패턴).

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

**하네스가 없으면** Claude는 보통:
- `.gitignore`에서 `.env`를 빼버리거나
- `git add -f .env`로 강제 추가하거나
- 그냥 commit 시도

→ **시크릿이 git 히스토리에 박힘**. 한 번 박히면 force-push로도 완전히 못 지움.

### 2-4. 피해 확인

```bash
# 데모니까 실제로 commit 됐는지 확인 (안 시켜 본 사람을 위해)
git log --all --oneline
git show HEAD --stat 2>/dev/null | head -10
```

`.env` 라인이 보이면 **사고**. 데모니까 다음 단계로:

```bash
# 데모 cleanup
git reset --hard HEAD~1 2>/dev/null
git checkout HEAD -- .gitignore 2>/dev/null
# .env는 디스크에는 유지
```

---

## Step 3 — Hook 설치 — 1분

`guard.sh` 한 개만 후딱 설치. 5모듈을 다 보고 만들 정식 hook이 아니라 **데모용 미니 버전**.

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
  exit 1
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

직접 동작 검증 (Claude Code 밖에서):

```bash
bash .claude/hooks/guard.sh "git add .env"
echo "exit code: $?"
# → 🚫 BLOCKED ... / exit code: 1  이면 OK
```

---

## Step 4 — After: 하네스 있을 때 — 1분

Claude Code를 **완전 종료 후 다시** 실행 (설정 재로드 위해):

```bash
claude
```

같은 프롬프트 다시 붙여넣기:

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

Claude는 차단 메시지를 보고 보통:
- `.env.example`을 만들어 그것만 커밋하자고 제안하거나
- "왜 차단됐는지" 설명을 곁들여 사용자에게 의사 결정 요청

→ **시크릿 노출 사고 자동 방지**. 학생이 "잘 해줘"라고 부탁 안 해도 시스템이 막음.

---

## Step 5 — 차이 표 (직접 채워보기) — 1분

|  | Before (하네스 없음) | After (guard.sh만 설치) |
|---|---|---|
| `.env` 커밋 시도 | __ (성공? 차단?) | __ |
| 시크릿 git 히스토리 노출 | __ | __ |
| 사용자가 "조심해줘" 매번 말해야 함? | __ | __ |
| 신규 팀원이 같은 실수할 가능성 | __ | __ |

**한 줄 소감**: ____________________________________________

---

## Step 6 — 정리 — 30초

`harness-demo`는 데모 전용이므로 삭제한다. 5모듈 실습은 [[guide-harness-00-prerequisites]] 의 `~/harness-playground`에서 따로 진행한다.

```bash
cd ~ && rm -rf ~/harness-demo
```

---

## 깨달은 점

방금 6단계를 거치며 차단 한 번을 직접 체험했다. 이게 하네스의 전부가 아니다.

이 데모는 하네스의 **딱 1개 측면**(시크릿 파일 차단)만 보여줬다. 실제 5모듈에서는:

| 모듈 | 추가되는 것 | 막아주는 사고 |
|------|-----------|--------------|
| 01 | 베이스라인 측정 | (측정만 — 사고 방지 X) |
| 02 | CLAUDE.md 헌법 | 에이전트가 *자발적으로* 따르는 규칙 |
| **03** | **Hooks 확장** | **시크릿·main push·DROP TABLE·테스트 스킵 등 자동 차단** |
| 04 | Planner/Coder/Critic | 큰 작업에서 잡음·확증 편향 차단 |
| 05 | 주간 리뷰 + Rippable | 매주 새 사고 패턴 → 새 규칙으로 |

5분 데모에서 본 차단 1개가 → 5모듈 끝나면 **수십 개의 자동 안전장치**가 된다.

→ 이제 [[guide-harness-module1]] 로 진입. 본격 학습 시작.

## 관련 페이지

- [[guide-harness-00-prerequisites]] — 본격 실습 환경 셋업
- [[guide-harness-module1]] — 다음 단계
- [[concept-harness-engineering]] — "표지판 vs 중앙분리대" 비유
- [[concept-claude-hooks]] — Hooks 이론
