# task-list.md
# 에이전트 태스크 목록

> **Planner Agent**가 관리하는 파일입니다.
> 각 태스크는 원자 단위 (2시간 이내 완료 가능) 여야 합니다.
> 상태: 🔲 대기 / 🔄 진행중 / ✅ 완료 / ❌ 블로킹

---

## 현재 스프린트: [스프린트명/기능명]

**목표**: [한 줄로 최종 목표 기술]
**기한**: [날짜]
**담당 에이전트**: Planner → Coder → Critic

---

## 태스크 목록

### TASK-001: [태스크명]
- **상태**: 🔲 대기
- **복잡도**: LOW / MEDIUM / HIGH
- **의존**: 없음
- **verify**: `./gradlew test --tests "..."`
- **구현 범위**:
  - `src/domain/.../`
  - `src/application/.../`
- **완료 기준**:
  - [ ] 단위 테스트 통과
  - [ ] Critic Agent APPROVE
- **메모**: 

---

### TASK-002: [태스크명]
- **상태**: 🔲 대기
- **복잡도**: MEDIUM
- **의존**: TASK-001 완료 후
- **verify**: `./gradlew integrationTest`
- **구현 범위**:
  - `src/application/.../`
  - `src/interfaces/.../`
- **완료 기준**:
  - [ ] 통합 테스트 통과
  - [ ] API 스펙 문서 업데이트
  - [ ] Critic Agent APPROVE
- **메모**:

---

### TASK-003: [태스크명]
- **상태**: 🔲 대기
- **복잡도**: HIGH
- **의존**: TASK-002 완료 후
- **verify**: `./gradlew test && ./gradlew integrationTest`
- **구현 범위**:
  - `src/infrastructure/.../`
  - `src/main/resources/db/migration/`
- **완료 기준**:
  - [ ] Migration 파일 정상 적용
  - [ ] 전체 테스트 통과
  - [ ] Critic Agent APPROVE
- **메모**:

---

## 완료된 태스크

| ID | 태스크명 | 완료일 | Critic 판정 |
|----|---------|--------|------------|
| | | | |

---

## 블로킹 이슈

| 이슈 | 태스크 | 원인 | 해결방법 |
|------|--------|------|---------|
| | | | |

---

## Planner 작성 가이드

```
새 기능 태스크 분해 예시:

사용자 요구: "입찰 참가자격 사전심사 기능 추가"

분해 결과:
TASK-001: PreQualification 도메인 엔티티 설계 (LOW)
TASK-002: PreQualificationRepository 인터페이스 정의 (LOW)  
TASK-003: PreQualificationJpaRepository 구현 (MEDIUM)
TASK-004: RequestPreQualificationUseCase 구현 (MEDIUM)
TASK-005: PreQualificationController API 추가 (MEDIUM)
TASK-006: Migration 파일 생성 (LOW)
TASK-007: 통합 테스트 작성 (MEDIUM)
```
