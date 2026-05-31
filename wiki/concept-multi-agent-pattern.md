---
title: 멀티 에이전트 — Planner / Coder / Critic
type: concept
tags: [claude-code, harness, multi-agent, agents-md, context-engineering]
sources: [harness-engineering/harness-kit/module4/, harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md]
created: 2026-05-30
updated: 2026-05-30
---

# 멀티 에이전트 — Planner / Coder / Critic

## 정의

하나의 거대한 에이전트 대신 **역할이 분리된 여러 에이전트가 협업**하는 패턴. 단순한 프론트/백 분리가 아니라 **컨텍스트 윈도우 오염 방지**가 목적이다.

> 컨텍스트 방화벽으로서의 서브에이전트
> 메인 태스크와 무관한 세부 구현은 서브에이전트에 위임,
> 서브에이전트는 결과만 메인으로 반환 (중간 과정 노이즈 차단).

## 3-tier 컨텍스트 인프라

| 층위 | 파일 | 역할 |
|------|------|------|
| **전역** | `CLAUDE.md` / `AGENTS.md` | 모든 세션이 읽는 헌법 |
| **태스크** | 스킬 파일 (`.claude/skills/*.md`) | 특정 태스크 유형에만 로드되는 가이드 |
| **세션** | `claude-progress.txt` | 세션 간 인계 메모 |

## 세 역할

### Planner Agent

**역할**: 태스크 분해 및 실행 계획 수립.

책임:
- 사용자 요구사항을 `task-list.md`의 원자 단위 태스크로 분해
- 각 태스크에 복잡도와 verify 기준 명시
- 의존관계 파악 및 순서 결정

출력 형식:
```markdown
## Task: [태스크명]
- ID: TASK-{번호}
- 복잡도: LOW / MEDIUM / HIGH
- 의존: [선행 태스크 ID 또는 없음]
- verify: [검증 방법]
- 구현 범위: [변경될 파일/클래스]
```

**금지**: 직접 코드 작성 금지, 구현 세부사항 가정 금지.

### Coder Agent

**역할**: 단일 태스크 단위 구현.

책임:
- Planner가 분해한 태스크를 하나씩 구현
- 구현 전 CLAUDE.md 체크리스트 확인
- 자기검증 루프 실행 (컴파일 → 테스트 → 보고)
- 완료 후 task-list.md 상태 업데이트

**작업 단위 원칙**:
- 한 번에 하나의 태스크만 처리
- verify 기준 충족 후에만 다음으로 이동
- 컨텍스트 윈도우 80% 이상 사용 시 → Planner 보고 후 세션 인계

**금지**: 태스크 범위를 벗어난 "개선", verify 없는 "완료" 선언.

### Critic Agent

**역할**: 구현 결과 독립적 검증 및 구조적 리뷰.

책임:
- DDD 원칙 관점에서 검토
- 아키텍처 위반 시 CONDITIONAL REJECT
- 보안/성능 이슈 지적

검토 체크리스트:
```
[ ] 레이어 의존 방향 올바른가?
[ ] Entity가 Controller에 노출되지 않았는가?
[ ] Aggregate 경계가 지켜졌는가?
[ ] 테스트가 의미 있는 케이스를 커버하는가?
[ ] N+1 문제가 없는가?
[ ] 트랜잭션 경계가 적절한가?
[ ] 불필요한 코드가 추가되지 않았는가?
```

판정 형식:
```
APPROVE: 구현이 DDD 원칙과 요구사항을 모두 만족함

CONDITIONAL REJECT: 조건부 거절
  - 문제: [구체적 위반 사항]
  - 수정 요청: [구체적 수정 방법]
  - 재검토 후 APPROVE 가능

REJECT: 근본적 재설계 필요
  - 이유: ...
  - 권장 접근 방법: ...
```

### Critic 패턴 변형: 모델 교차 검증

OpenAI 사례에서는 **Claude + Codex가 3라운드 토론** 후 CONDITIONAL REJECT 권한을 부여하는 패턴이 등장. 단일 모델의 자기검증보다 모델 간 교차 검증이 강하다.

## AGENTS.md — 모델 불가지론적 표준

`CLAUDE.md`는 Claude Code 전용이지만 `AGENTS.md`는 Claude/Codex/Gemini 등 어떤 모델이든 읽을 수 있는 공용 표준. 멀티 모델 환경(예: Coder는 Claude, Critic은 Codex)에서 필수.

→ 한 프로젝트만 쓴다면 `CLAUDE.md` 우선. 멀티 모델이면 `AGENTS.md` 병용 ([[concept-claude-md]] 참조).

## 세션 인계 프로토콜

### 새 세션 시작 시
```bash
1. cat AGENTS.md            # 역할 재확인
2. cat claude-progress.txt  # 현재 상태 파악
3. git log --oneline -5     # 최근 커밋 확인
4. cat task-list.md         # 남은 태스크 확인
5. ./gradlew test -q        # 현재 테스트 상태 확인
```

### 세션 종료 시
```bash
1. claude-progress.txt 업데이트
2. task-list.md 현재 태스크 상태 업데이트
3. 미완료 태스크가 있으면 "중단 지점" 명시
4. 다음 세션을 위한 컨텍스트 메모 작성
```

이 종료 절차는 [[concept-claude-hooks]]의 Stop hook으로 자동화 가능.

목표: 새 컨텍스트 윈도우에서 **5초 안에 현재 상태 파악**.

## 컨텍스트 소진 기준

- 컨텍스트 80% 이상 사용 → 현재 태스크 완료 후 새 세션
- 컨텍스트 90% 이상 사용 → 즉시 progress 저장 후 세션 종료

## 관련 페이지

- [[concept-harness-engineering]] — 상위 개념
- [[concept-claude-md]] — AGENTS.md / CLAUDE.md 비교
- [[concept-claude-hooks]] — 세션 인계 자동화 (Stop hook)
- [[src-harness-engineering]] — Module 04 전체 자료
