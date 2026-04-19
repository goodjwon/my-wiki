# 카카오페이 여신코어 DDD로 구축하기
원본: https://tech.kakaopay.com/post/backend-domain-driven-design/

## 시작하며

카카오페이 후불결제(BNPL)의 여신코어시스템을 DDD(Domain Driven Design, 도메인 주도 설계)로 구축한 경험을 공유. 여신비즈니스가 시스템으로 구현되는 과정에서 DDD를 어떻게 활용하였는지, 코드레벨에서는 어떤 구조로 설계하고 구현하였는지 다룬다.

## DDD 핵심 개념

- **도메인(Domain)**: 소프트웨어가 해결하고자 하는 문제 영역
- **유비쿼터스 언어(Ubiquitous Language)**: 도메인 전문가와 개발자가 공통으로 사용하는 언어
- **바운디드 컨텍스트(Bounded Context)**: 도메인을 명확하게 구분 짓는 경계
- **애그리거트(Aggregate)**: 도메인 모델의 일관성을 유지하기 위해 관련된 객체들을 묶어 관리하는 단위
- **엔티티(Entity)**: 고유한 식별자를 가지며 상태와 행동을 갖는 객체
- **밸류오브젝트(Value Object)**: 고유한 식별자 없이 불변성을 가지는 객체

## 왜 DDD를 선택했나

> 프로젝트팀이 DDD를 선택한 가장 큰 이유는, **정책이 명확한 도메인을 견고하게 설계/구현하는 데** 있다.

- 여신시스템은 비즈니스 복잡성이 높아 개발자가 도메인을 깊이 이해해야 함
- 여신전문가, 기획자, 개발자가 도메인 지식의 눈높이를 맞춰야 함
- 도메인 기능 기반 Application Level 구현으로 정책 관련 코드가 일원화됨

## 설계 과정

### Step1: Bounded Context & Aggregate Root

- 비즈니스를 나열하고 효율적으로 관리할 도메인을 설계
- 비즈니스 중심이 되는 Domain Model을 Aggregate Root로 선정
- **Bounded Context Rule**: 명시적 경계, 하위 도메인 분할, Gradle module 단위
- **Aggregate Root Rule**: 트랜잭션 경계, Root를 통해서만 내부 접근

### Step2: Domain Model & Function

- 도메인 모델의 프로퍼티와 기능 정의
- **각 도메인의 기능은 타도메인에서 수행할 수 없고 해당 도메인을 통해서만 실행**
- 나눌 수 있는 최대한 작은 단위로 설계

### Step3: Application Design

- PlantUML로 비즈니스 흐름을 가시화
- 함께 모여 리뷰하며 도메인 기능 간 호출 흐름 설계
- 설계 과정이 코딩 시간과 커뮤니케이션 비용을 단축

## 구현 구조

### Package 구조

```
ㄴ gaia-domain
    ㄴ gaia-user-domain
    ㄴ gaia-account-domain
    ㄴ gaia-credit-limit-domain
ㄴ gaia-core-app
```

### 핵심 패턴

- Application → DomainEntity (Command) → DomainRepository → JPA Entity → DB
- JPA Entity 직접 접근 차단 → 도메인 설계가 DB 구조에 종속되지 않음
- 도메인 객체의 기능검증은 단위테스트로 보장

### Command 패턴 예시

```kotlin
// Application에서 도메인 사용
Account.CreateCommand(
    userExternalId = userExternalId,
    creditLimitTotalAmount = amount,
).let(Account::create)
 .let(accountDomainRepository::save)
 .getOrThrow()
```

### 도메인 Entity 컨벤션

- 생성자 `internal` — factory method로만 생성
- 변경 가능한 properties는 `var` + `internal set`
- public Command class를 통한 public method 제공

### Biz-component

- 여러 도메인에 걸친 공통 기능(납부 등)은 Biz-component로 분리
- API, 배치 등에서 공통 사용 → 중복 구현 방지

## 아쉬웠던 점: JPA Entity 중복 관리

- 도메인 모듈 내 JPA Entity가 `internal`로 선언되어 배치에서 직접 사용 불가
- 배치 전용 JPA Entity를 중복으로 만들어야 했음
- `public`으로 열면 설계 규칙 위반 가능성 → 현재 방법 유지하되 개선 고민 중

## 핵심 교훈

- DDD 도입 초기에는 팀 전체의 이해도 구축에 시간 필요 → 필수적 투자
- **유비쿼터스 언어** 정립이 프로젝트 성공의 핵심 키
- 이미 핵심 기능이 정의된 프로젝트에서 DDD로 설계 완성도를 높이는 것이 효과적
- 견고한 아키텍처는 향후 시스템 확장과 변화에 유연하게 대응할 기반

## 참고자료

- Domain-Driven Design Tackling Complexity in the Heart of Software (Eric Evans)
