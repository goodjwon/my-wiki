# CLAUDE.md
# [프로젝트명] — Agent Harness Constitution

> 이 파일은 프롬프트가 아니다. 에이전트 실행 환경의 헌법이다.
> 매 세션 시작 시 가장 먼저 읽히며, 어떤 모델이든 이 규칙 안에서 동작한다.
> AI가 생성한 내용을 포함하지 않는다. 팀이 직접 관리한다.

---

## 1. Tech Stack

- **Language**: Java 17
- **Framework**: Spring Boot 3.x
- **Architecture**: DDD (Domain-Driven Design)
- **ORM**: JPA + QueryDSL
- **DB**: Oracle (운영) / H2 (테스트)
- **Build**: Gradle
- **Test**: JUnit 5, RestAssured
- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS

---

## 2. 코딩 전 생각하기 (Think Before Coding)

구현 시작 전 반드시:

- 가정을 명시적으로 선언한다. 불확실하면 먼저 질문한다.
- Entity / VO / Aggregate Root 중 어느 것인지 먼저 확인하고 시작한다.
- JPA 연관관계 방향이 불명확하면 멈추고 질문한다.
- 여러 해석이 가능하면 조용히 하나를 고르지 않고 옵션을 제시한다.
- 더 단순한 방법이 있으면 먼저 말하고, 필요할 때 push back한다.

---

## 3. 단순함 우선 (Simplicity First)

- 요청된 것만 구현한다. "나중에 쓸 수도 있는" 메서드 추가 금지.
- 단일 UseCase에 Generic 추상화 만들지 않는다.
- Repository에 쿼리메서드를 추측으로 추가하지 않는다.
- 코드가 100줄인데 30줄로 가능하면 다시 쓴다.
- Ask yourself: "시니어 엔지니어가 이걸 보면 과하다고 할까?" → Yes면 단순화한다.

---

## 4. 외과적 변경 (Surgical Changes)

기존 코드 수정 시:

- Entity 필드명, 패키지 구조를 "더 나은 방향"으로 임의 리팩토링 금지.
- 기존 네이밍 컨벤션이 마음에 안 들어도 맞춘다.
- 내 변경으로 생긴 unused import / 변수만 정리한다.
- 기존 dead code 발견 시 → **언급만 하고 삭제하지 않는다**.
- 모든 변경된 줄은 사용자의 요청에서 추적 가능해야 한다.

---

## 5. 목표 기반 실행 (Goal-Driven Execution)

태스크를 검증 가능한 목표로 변환한다:

- "버그 고쳐줘" → "재현 테스트 작성 → 테스트 통과시키기"
- "API 추가해줘" → "Controller 테스트 먼저 → 구현 → 통과"
- "리팩토링해줘" → "before/after 테스트 동일하게 통과"

멀티스텝 작업 시 계획 먼저:
```
1. Domain 모델 정의  → verify: 단위 테스트 통과
2. Repository 인터페이스  → verify: 컴파일 성공
3. UseCase 구현  → verify: 통합 테스트 통과
4. Controller  → verify: API 테스트 통과
```

---

## 6. DDD 아키텍처 원칙

### 레이어 의존 방향 (역방향 절대 금지)
```
interfaces → application → domain ← infrastructure
```

### 패키지 구조
```
src/main/java/com/example/
├── domain/          # Entity, VO, Repository 인터페이스, Domain Service
├── application/     # UseCase, ApplicationService, DTO
├── infrastructure/  # JPA 구현체, 외부 API 클라이언트, Mapper
└── interfaces/      # Controller, Request/Response, Exception Handler
```

### 핵심 규칙
- **Repository는 인터페이스**: `domain` 패키지에 위치, 구현체는 `infrastructure`에만
- **VO로 원시값 포장**: `String`, `Long`을 도메인 개념으로 직접 노출 금지
  - 예: `String email` → `Email email` (VO)
  - 예: `Long contractId` → `ContractId contractId` (VO)
- **Aggregate 경계 존중**: 다른 Aggregate의 Entity를 직접 참조하지 않고 ID로만 참조
- **Domain Event**: Aggregate 상태 변경 시 도메인 이벤트 발행 고려

---

## 7. ⛔ 절대 금지 트리거 (에이전트가 멈춰야 하는 조건)

다음 행동을 하려 할 때 즉시 멈추고 사용자에게 확인을 요청한다:

```
STOP: migration 파일 수정 또는 삭제
STOP: @Transactional 없이 여러 Aggregate 동시 수정
STOP: Entity를 Controller 레이어에 직접 노출 (DTO 변환 필수)
STOP: main 브랜치 직접 push
STOP: 테스트 없이 서비스 메서드 추가
STOP: infrastructure 패키지에서 domain 패키지 import
STOP: @Autowired 필드 주입 사용 (생성자 주입만 허용)
STOP: N+1 문제가 발생하는 연관관계 설정 (@ManyToOne without fetch strategy)
```

---

## 8. 작업 전 체크리스트

```
[ ] 도메인 모델 변경인가? → Entity/VO/Aggregate 설계 먼저
[ ] 기존 테스트 통과? → ./gradlew test
[ ] 린트 통과? → ./gradlew checkstyleMain
[ ] Migration 스크립트 추가했는가?
[ ] DTO ↔ Domain 변환 레이어 있는가?
[ ] 레이어 의존 방향이 올바른가?
```

---

## 9. 빌드 & 테스트 명령어

```bash
# 전체 빌드
./gradlew build

# 테스트만
./gradlew test

# 린트
./gradlew checkstyleMain

# 특정 테스트 클래스
./gradlew test --tests "com.example.contract.ContractServiceTest"

# 통합 테스트
./gradlew integrationTest
```

---

## 10. 네이밍 컨벤션

| 레이어 | 클래스명 패턴 | 예시 |
|--------|--------------|------|
| Domain Entity | `{도메인명}` | `Contract`, `Bid` |
| Value Object | `{개념명}` | `ContractAmount`, `Email` |
| Repository (인터페이스) | `{도메인명}Repository` | `ContractRepository` |
| UseCase | `{동사}{도메인명}UseCase` | `CreateContractUseCase` |
| Application Service | `{도메인명}Service` | `ContractService` |
| Controller | `{도메인명}Controller` | `ContractController` |
| Request DTO | `{동사}{도메인명}Request` | `CreateContractRequest` |
| Response DTO | `{도메인명}Response` | `ContractResponse` |

---

## 11. 누적된 실패 패턴 (세션마다 업데이트)

> 에이전트가 같은 실수를 반복하면 → 이 섹션에 추가
> "다음엔 잘 해줘" 대신 → 구조적 방지 장치로 전환

| 날짜 | 실패 패턴 | 추가된 방지 규칙 |
|------|-----------|----------------|
| | | |

---

## 12. 세션 시작 시 에이전트 행동

1. `claude-progress.txt` 읽기
2. `git log --oneline -10` 확인
3. 현재 `task-list.md`에서 다음 태스크 파악
4. 위 STOP 트리거 목록 재확인
5. 작업 전 반드시 도메인 레이어부터 설계
