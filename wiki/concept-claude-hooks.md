---
title: Claude Code Hooks — 시스템 레벨 강제
type: concept
tags: [claude-code, hooks, harness, automation]
sources: [harness-engineering/harness-kit/module3/, harness-engineering/harness_engineering.md, harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md]
created: 2026-05-30
updated: 2026-06-13
---

# Claude Code Hooks — 시스템 레벨 강제

## 정의

Claude Code의 에이전트 라이프사이클 이벤트에 **셸 스크립트를 주입**하여 위험한 행동을 차단하거나 자동 검증을 트리거하는 메커니즘. 프롬프트(부탁)를 시스템 구조(강제)로 전환하는 핵심 도구.

공식 문서: https://docs.anthropic.com/claude-code/hooks

## 에이전트 라이프사이클 이벤트

| 이벤트 | 시점 | 용도 |
|--------|------|------|
| **PreToolUse** | 도구 실행 직전 | 위험 명령 차단 (guard.sh) |
| **PostToolUse** | 도구 실행 직후 | 자동 포맷, 린트, 검증 (lint-fix.sh) |
| **Stop** | 세션 종료 시 | 진행 상황 저장 (update-progress.sh) |

## 설정 파일 예시

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/guard.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/lint-fix.sh" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/update-progress.sh" }
        ]
      }
    ]
  }
}
```

## guard.sh — 위험 명령 차단

Bash 실행 전 명령어를 검사해 차단/경고하는 스크립트. 종료 코드 1로 종료하면 실행이 막힌다.

핵심 패턴:

```bash
#!/bin/bash
COMMAND="$1"
if [ -z "$COMMAND" ]; then
  read -r COMMAND
fi

block() {
  echo "🚫 BLOCKED by guard.sh: $1" >&2
  echo "REASON: $2" >&2
  echo "ACTION: $3" >&2
  exit 1
}

# 1. Migration 파일 수정/삭제
if echo "$COMMAND" | grep -qE "(rm|del|delete|DROP|truncate).*migration"; then
  block "Migration 파일 조작" \
    "migration은 한 번 적용 후 수정 불가" \
    "새 migration V{버전}__description.sql 생성"
fi

# 2. 프로덕션 DB 직접 조작
if echo "$COMMAND" | grep -qE "DROP TABLE|DROP DATABASE|TRUNCATE"; then
  block "위험한 DDL" "프로덕션 데이터 삭제 위험" "Migration 파일로만 변경"
fi

# 3. main 브랜치 직접 push
if echo "$COMMAND" | grep -qE "git push.*origin main|git push.*origin master"; then
  block "main 브랜치 직접 push" "main은 PR로만 업데이트" "feature 브랜치 + PR"
fi

# 4. 강제 push
if echo "$COMMAND" | grep -qE "git push.*(-f|--force)"; then
  block "강제 push" "히스토리 파괴 위험" "팀 리드 승인 필요"
fi

# 5. 시크릿 노출
if echo "$COMMAND" | grep -qE "cat.*\.env|echo.*SECRET|echo.*PASSWORD|echo.*API_KEY"; then
  block "민감 정보 노출" "로그 노출 위험" "Vault 또는 application.properties"
fi

exit 0
```

전체 구현은 `raw/harness-engineering/harness-kit/module3/guard.sh` 참조.

## lint-fix.sh — Post-Tool Hook

파일 수정 후 자동으로 포맷/린트를 돌려 스타일 규칙 위반을 잡는다.

```bash
# 예시: Java 프로젝트
./gradlew checkstyleMain --quiet
# 또는 Node.js
npx prettier --write . && npx eslint --fix .
```

## Back-pressure 메커니즘

타입체크, 테스트, 커버리지 결과를 에이전트의 **자기검증 도구**로 연결한다. PostToolUse에서 `./gradlew test`를 돌리고 실패 시 에이전트가 스스로 수정하는 루프 완성.

```
Edit 파일 → PostToolUse → ./gradlew test → 실패 → 에이전트가 stderr 보고 재수정
```

> **Loop 엔지니어링 관점**: back-pressure는 [[concept-loop-engineering]]에서 말하는 **"루프 안에 거부할 수 있는 무언가"** 의 가장 구체적인 구현이다. 테스트 실패라는 거부 신호가 없으면, 에이전트는 자기 출력에 동의하는 메아리방이 된다. Hooks가 "사이클 안의 reject"를 코드로 보장한다.

## CLAUDE.md와의 역할 분담

[[concept-claude-md]]는 **선언** (무엇을 기대하는가), Hooks는 **강제** (위반 시 막는다).

| STOP 규칙 (CLAUDE.md) | guard.sh로 강제 가능? |
|----------------------|----------------------|
| Migration 파일 삭제 | ✅ `rm .*migration` 차단 |
| main 직접 push | ✅ `git push origin main` 차단 |
| @Autowired 필드 주입 | ❌ 코드 검사 필요 (lint-fix.sh에서 checkstyle 룰로) |
| Entity Controller 노출 | ❌ 정적 분석 필요 (ArchUnit 테스트로) |

→ CLAUDE.md에는 모든 규칙을 적되, Hook으로 강제 가능한 것은 우선 자동화한다.

## Hooks 진화 패턴

실습 중 발생한 새 실패를 즉시 guard.sh 규칙으로 추가:

```bash
# [2026-05-30] 실패: 에이전트가 .env.production 직접 수정 시도
if echo "$COMMAND" | grep -qE "\.env\.production"; then
  block "프로덕션 환경변수 수정" "운영 시크릿 변경 위험" "Vault 사용"
fi
```

"다음엔 잘 해줘" 대신 → 구조적 방지로 전환 ([[concept-harness-engineering]] 원칙 #2).

## 관련 페이지

- [[concept-harness-engineering]] — 상위 개념
- [[concept-loop-engineering]] — back-pressure가 "거부할 수 있는 무언가"의 구현임을 다룸
- [[concept-claude-md]] — Hooks와 짝을 이루는 선언 층
- [[concept-multi-agent-pattern]] — 세션 인계 (Stop hook이 claude-progress.txt 업데이트)
- [[src-harness-engineering]] — Module 03 전체 자료
