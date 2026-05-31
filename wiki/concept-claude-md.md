---
title: CLAUDE.md — 에이전트 헌법
type: concept
tags: [claude-code, harness, claude-md, karpathy]
sources: [harness-engineering/harness-kit/module2/CLAUDE.md, harness-engineering/harness-engineering-tutor-prompt.md, harness-engineering/하네스엔지니어링_슬라이드해설_강의교안.md]
created: 2026-05-30
updated: 2026-05-30
---

# CLAUDE.md — 에이전트 헌법

## 정의

프로젝트 루트에 두는 **에이전트 실행 환경의 헌법** 파일. Claude Code가 세션 시작 시 가장 먼저 읽으며, 모든 모델이 이 규칙 안에서 동작한다. AI가 생성한 내용을 포함하지 않고 팀이 직접 관리한다.

> 이 파일은 프롬프트가 아니다. 에이전트 실행 환경의 헌법이다.

`AGENTS.md`는 같은 개념의 **모델 불가지론적** 버전. 한 프로젝트만 쓴다면 `CLAUDE.md` 우선, 멀티 모델 환경이면 `AGENTS.md` 병용.

## Karpathy 4원칙

### 1. Think Before Coding (코딩 전 생각하기)
- 가정을 명시적으로 선언. 불확실하면 먼저 질문한다.
- 더 단순한 방법이 있으면 먼저 말하고, 필요할 때 push back.
- 여러 해석이 가능하면 조용히 하나를 고르지 말고 옵션을 제시한다.

### 2. Simplicity First (단순함 우선)
- 요청된 것만 구현. "나중에 쓸 수도 있는" 메서드 추가 금지.
- 100줄이 30줄로 가능하면 다시 쓴다.
- "시니어 엔지니어가 보면 과하다고 할까?" → Yes면 단순화.

### 3. Surgical Changes (외과적 변경)
- 기존 네이밍/패키지를 "더 나은 방향"으로 임의 리팩토링 금지.
- 내 변경으로 생긴 unused import/변수만 정리.
- 기존 dead code는 **언급만 하고 삭제하지 않는다**.
- 모든 변경된 줄은 사용자 요청에서 추적 가능해야 한다.

### 4. Goal-Driven Execution (목표 기반 실행)
- 태스크를 검증 가능한 목표로 변환: `"버그 고쳐줘" → "재현 테스트 작성 → 테스트 통과시키기"`
- 멀티스텝 작업 시 계획 먼저:
```
1. Domain 모델 정의   → verify: 단위 테스트 통과
2. Repository 인터페이스 → verify: 컴파일 성공
3. UseCase 구현       → verify: 통합 테스트 통과
4. Controller         → verify: API 테스트 통과
```

## 절대 금지 트리거 (STOP 조건)

에이전트가 다음 행동을 하려 할 때 **즉시 멈추고 사용자에게 확인을 요청한다**:

```
STOP: migration 파일 수정 또는 삭제
STOP: @Transactional 없이 여러 Aggregate 동시 수정
STOP: Entity를 Controller 레이어에 직접 노출 (DTO 변환 필수)
STOP: main 브랜치 직접 push
STOP: 테스트 없이 서비스 메서드 추가
STOP: infrastructure 패키지에서 domain 패키지 import
STOP: @Autowired 필드 주입 사용 (생성자 주입만 허용)
STOP: N+1 문제가 발생하는 연관관계 설정
```

이 STOP 트리거 중 일부는 [[concept-claude-hooks]]의 guard.sh로 **물리적으로 차단**할 수 있다 (예: main 브랜치 직접 push, migration 삭제).

## 누적된 실패 패턴 섹션

CLAUDE.md 하단에는 반드시 다음 표를 둔다 — 에이전트가 같은 실수를 반복하면 추가:

| 날짜 | 실패 패턴 | 추가된 방지 규칙 |
|------|-----------|----------------|

"다음엔 잘 해줘" 대신 → **구조적 방지 장치로 전환**한다 ([[concept-harness-engineering]]의 핵심 원칙 #2).

## Spring Boot DDD 통합 예시

`raw/harness-engineering/harness-kit/module2/CLAUDE.md`는 다음 섹션을 포함:

1. **Tech Stack** — Java 17 / Spring Boot 3.x / JPA + QueryDSL / Oracle / Gradle
2. **Karpathy 4원칙** — 위 4원칙을 DDD 관점에서 구체화 (Entity/VO/Aggregate Root 확인 등)
3. **DDD 아키텍처 원칙**:
   - 레이어 의존 방향: `interfaces → application → domain ← infrastructure`
   - VO로 원시값 포장: `String email` → `Email email`
   - Aggregate 경계 존중: 다른 Aggregate는 ID로만 참조
4. **절대 금지 트리거** (위 STOP 목록)
5. **작업 전 체크리스트**:
```
[ ] 도메인 모델 변경인가? → Entity/VO/Aggregate 설계 먼저
[ ] 기존 테스트 통과? → ./gradlew test
[ ] 린트 통과? → ./gradlew checkstyleMain
[ ] Migration 스크립트 추가했는가?
[ ] DTO ↔ Domain 변환 레이어 있는가?
[ ] 레이어 의존 방향이 올바른가?
```
6. **빌드 & 테스트 명령어**
7. **네이밍 컨벤션 표**
8. **누적된 실패 패턴**
9. **세션 시작 시 에이전트 행동**:
```
1. claude-progress.txt 읽기
2. git log --oneline -10 확인
3. 현재 task-list.md에서 다음 태스크 파악
4. 위 STOP 트리거 목록 재확인
5. 작업 전 반드시 도메인 레이어부터 설계
```

## 분량 가이드

- 500줄 이하 유지 (길수록 컨텍스트 윈도우 압박)
- 절대 금지(STOP)와 검증 가능한 목표(verify)에 분량 집중
- 일반적 코딩 가이드는 줄이고, **이 프로젝트 고유의 함정**에 집중

## 관련 페이지

- [[concept-harness-engineering]] — 상위 개념
- [[concept-claude-hooks]] — CLAUDE.md의 STOP 규칙을 물리적으로 강제
- [[concept-multi-agent-pattern]] — AGENTS.md (모델 불가지론적 버전)
- [[src-harness-engineering]] — 5모듈 커리큘럼
- [[guide-project-docs-setup]] — CLAUDE.md 템플릿 + 셋업 절차
- [[src-kakaopay-ddd]] — DDD 모델링 근거 (Entity/VO/Aggregate)
