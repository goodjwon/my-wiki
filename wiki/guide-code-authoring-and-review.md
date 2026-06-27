---
title: 코드 작성·점검 가이드
type: synthesis
tags: [guide, code-quality, code-review, prompt]
sources: [object/, effective_java/, refactoring/, clean-code/, tdd/]
created: 2026-06-21
updated: 2026-06-23
---

# 코드 작성·점검 가이드

## 무엇인가

**코드 작성 + 코드 점검** 두 워크플로를 한 페이지로 압축한 가이드. 함수·객체·의존성·예외·테스트·동시성의 실무 체크리스트와 PR 리뷰 어휘를 담았다.

활용:
1. **AI 프롬프트** — Claude·ChatGPT 에 이 페이지 본문을 컨텍스트로 주고 "이 원칙으로 코드 짜줘" / "리뷰해줘".
2. **슬래시 명령** — `/code-guide` (작성 가이드)·`/code-check` (현재 diff 점검) — 이 페이지를 베이스로.
3. **PR 리뷰 어휘** — "G19", "Item 18", "리팩터링 6.1" 같은 표준 어휘로 합의 빠름.
4. **신입 교육** — 한 페이지로 핵심 점검 어휘 습득.

> **실습 환경 먼저** — Java 17 + JUnit 5 + Python + Node 셋업은 [[guide-java-book-study-lab]] 참조. 이 가이드는 환경이 준비된 후의 **작성·점검 워크플로**.

> 💡 이 가이드는 OO 설계 도서 5권의 결론을 한 워크플로로 압축한 것. 각 항목의 근거 도서·장은 본문 캡션과 표에 표시했고, 책별 요약은 맨 아래 **7. 참고** 섹션 참조.

---

## 1. 6가지 핵심 설계 원칙

코드 작성·점검 전체를 관통하는 골격.

| # | 원칙 | 근거 |
|---|------|------|
| 1 | **객체 협력 > 클래스 단독** | 오브젝트 1~7장 |
| 2 | **추상에 의존, 구체 X** | OCP·DIP, EJ Item 5·64, 오브젝트 8·9장 |
| 3 | **합성 > 상속** | EJ Item 18, 리팩터링 12.10, 오브젝트 11장 |
| 4 | **불변 우선** | EJ Item 17, TDD 2장 (값 객체) |
| 5 | **단순한 설계 4규칙** (모든 테스트·중복 X·의도·최소) | Clean Code 12장 (Kent Beck) |
| 6 | **테스트가 안전망 + 설계 도구** | TDD 전체, Clean Code 9장 |

---

## 2. 코드 작성 체크리스트 (Writing)

새 코드 짤 때·PR 올리기 전 자기 점검.

### 2.1 함수
*근거: Clean Code 3장 · EJ 49~56 · 리팩터링 6장*

- [ ] 함수가 **한 화면 (15줄) 이내** 인가
- [ ] 들여쓰기 **2단계 이하** 인가
- [ ] **한 가지** 일만 하는가 — 빈 줄로 단락 구분이 2개+ = 추출 후보
- [ ] **이름이 동작** 을 정확히 드러내는가 (`is*`/`has*` boolean·`to*`/`from*` 변환)
- [ ] 매개변수 **0~3개** 인가 — 4개+ = record/객체화
- [ ] **boolean 플래그** 매개변수 X — enum 또는 분리
- [ ] **부수효과** 없는가 (이름이 약속한 일만)
- [ ] **명령-쿼리 분리 (CQS)** — 반환 + 상태 변경 동시 X

### 2.2 객체·클래스
*근거: 오브젝트 4·5·10·11장 · EJ 17·18·20·25*

- [ ] **데이터 먼저 X — 행동·책임 먼저** 결정했나
- [ ] **getter/setter 자동 생성** 으로 모든 필드 노출 X
- [ ] **불변** 가능한가 (final 필드, record)
- [ ] **상속 대신 합성** 검토했나 — Stack extends Vector 함정
- [ ] 도메인 객체에 **`@Data`/`@Setter`** 무지성 X — 의미 있는 메서드만 노출
- [ ] **SRP** — 클래스가 변경 이유가 하나
- [ ] **응집도 높음** — 일부 메서드가 일부 필드만 쓰면 분리 신호
- [ ] 인터페이스 의존인가 — 구체 클래스 직접 의존 X

### 2.3 의존성
*근거: 오브젝트 8·9장 · EJ 5·64 · Spring DI*

- [ ] **생성자 주입** 인가 — 세터·정적·싱글턴 X
- [ ] `new Repository()` 같이 **직접 생성** 안 하고 받는가
- [ ] **추상 (인터페이스)** 에 의존하는가
- [ ] 도메인 객체가 **Spring 없이 만들어지는가** (POJO)
- [ ] 단일 구현 인터페이스 — 추측성 일반화 의심 ([[entity-refactoring]] 3.15)

### 2.4 예외·null
*근거: Clean Code 7장 · EJ 69~77*

- [ ] **unchecked 예외** 우선 — checked 신중
- [ ] 예외 메시지에 **인자 값·상태** 포함
- [ ] `@Transactional` 안 변경에 unchecked 던지는가 (자동 롤백)
- [ ] **컬렉션 반환은 null X 빈 컬렉션** — Optional 은 단건만
- [ ] **빈 catch 블록** 없는가 — 무시는 명시 + 로그
- [ ] 외부 라이브러리 예외를 도메인 wrapper 로 변환했는가

### 2.5 도메인 모델
*근거: 오브젝트 · DDD 정신*

- [ ] **빈혈 도메인 모델** 아닌가 (객체가 자기 결정)
- [ ] **Tell, Don't Ask** — 데이터 꺼내 외부 처리 X
- [ ] 도메인 메서드 이름이 **도메인 전문가 용어**
- [ ] **타입 코드 + switch** 대신 다형성
- [ ] **기본형 집착** X — `UserId` record, `Money` 값 객체

### 2.6 테스트
*근거: TDD · Clean Code 9장*

- [ ] **테스트가 코드보다 먼저** (TDD) 또는 동시
- [ ] **F.I.R.S.T.** — Fast·Independent·Repeatable·Self-validating·Timely
- [ ] **한 테스트 = 한 동작 = 한 개념**
- [ ] **경계 조건** 테스트 (0·1·MAX·null·빈)
- [ ] `Thread.sleep` 의존 X — 명시적 동기화
- [ ] **flaky 테스트** 방치 X

### 2.7 동시성
*근거: EJ 78~84 · Clean Code 13장*

- [ ] Spring 빈 필드가 **가변 + 공유** X
- [ ] `synchronized` 영역에 **I/O·콜백** X
- [ ] `Executors.newCachedThreadPool()` 직접 사용 X — 명시적 `ThreadPoolExecutor`
- [ ] `HashMap`·`ArrayList` 멀티스레드 공유 X — `ConcurrentHashMap`·`CopyOnWriteArrayList`
- [ ] `SimpleDateFormat`·`Random` 공유 X — `DateTimeFormatter`·`ThreadLocalRandom`

---

## 3. 코드 점검 체크리스트 (Review)

PR 리뷰 어휘 — 표준 코드로 합의 빠르게.

### 3.1 코드 악취 (24가지)
*근거: [[entity-refactoring]] 3장 · 악취별 신호·예시·현업 매핑: [[lecture-refactoring-ch3]]*

| 묶음 | 코드 | 악취 | 주 처방 (기법·번호) |
|------|------|------|------|
| 이름·중복 | 3.1 | 기이한 이름 (Mysterious Name) | 변수 이름 바꾸기(6.7) · 함수 선언 바꾸기(6.5) |
| 이름·중복 | 3.2 | 중복 코드 (Duplicated Code) | 함수 추출하기(6.1) |
| 이름·중복 | 3.24 | 주석 (Comments) | 함수 추출하기(6.1) · 함수 선언 바꾸기(6.5) |
| 크기·분산 | 3.3 | 긴 함수 (Long Function) | 함수 추출하기(6.1) · 단계 쪼개기(6.11) |
| 크기·분산 | 3.4 | 긴 매개변수 목록 (Long Parameter List) | 매개변수 객체 만들기(6.8) |
| 크기·분산 | 3.20 | 거대한 클래스 (Large Class) | 클래스 추출하기(7.5) |
| 데이터 | 3.5 | 전역 데이터 (Global Data) | 변수 캡슐화하기(6.6) |
| 데이터 | 3.6 | 가변 데이터 (Mutable Data) | 변수 캡슐화하기(6.6) · 참조를 값으로 바꾸기(9.4) |
| 데이터 | 3.10 | 데이터 뭉치 (Data Clumps) | 클래스 추출하기(7.5) · 매개변수 객체 만들기(6.8) |
| 데이터 | 3.11 | 기본형 집착 (Primitive Obsession) | 기본형을 객체로 바꾸기(7.3) · enum |
| 데이터 | 3.16 | 임시 필드 (Temporary Field) | 클래스 추출하기(7.5) · 특이 케이스 추가하기(10.5) |
| 데이터 | 3.22 | 데이터 클래스 (Data Class, 빈혈) | 함수 옮기기(8.1) · 세터 제거하기(11.7) |
| 결합·분산 | 3.7 | 뒤엉킨 변경 (Divergent Change) | 단계 쪼개기(6.11) · 클래스 추출하기(7.5) |
| 결합·분산 | 3.8 | 산탄총 수술 (Shotgun Surgery) | 함수 옮기기(8.1) · 필드 옮기기(8.2) |
| 결합·분산 | 3.9 | 기능 편애 (Feature Envy) | 함수 옮기기(8.1) · 함수 추출하기(6.1) |
| 결합·분산 | 3.17 | 메시지 체인 (Message Chains) | 위임 숨기기(7.7) |
| 결합·분산 | 3.18 | 중개자 (Middle Man) | 중개자 제거하기(7.8) |
| 결합·분산 | 3.19 | 내부자 거래 (Insider Trading) | 함수 옮기기(8.1) · 위임 숨기기(7.7) |
| 추상화 | 3.13 | 반복문 (Loops) | 반복문을 파이프라인으로 바꾸기(8.8) · 반복문 쪼개기(8.7) |
| 추상화 | 3.14 | 성의 없는 요소 (Lazy Element) | 함수 인라인(6.2) · 클래스 인라인(7.6) |
| 추상화 | 3.15 | 추측성 일반화 (Speculative Generality) | 인라인(6.2/7.6) · 계층 합치기(12.9) · YAGNI |
| 상속 | 3.12 | 반복되는 switch (Repeated Switches) | 조건부 로직을 다형성으로 바꾸기(10.4) |
| 상속 | 3.21 | 대안 클래스 (Alternative Classes) | 함수 선언 바꾸기(6.5) · 슈퍼클래스 추출하기(12.8) |
| 상속 | 3.23 | 상속 포기 (Refused Bequest) | 서브클래스를 위임으로 바꾸기(12.10) · 메서드 내리기(12.4) |

→ 거의 모든 악취가 **6장(기본)·7장(캡슐화)·8장(이동)** 카탈로그로 해결된다. 한 코드에 여러 악취가 겹치는 게 보통 — 가장 큰 것부터.

### 3.2 휴리스틱 — 자주 인용 ⭐
*근거: Clean Code 17장 · 전체 G1~G36·N·T·C·E 목록: [[lecture-clean-code-ch17]]*

| 코드 | 한 줄 | PR 코멘트 예 |
|------|------|---------|
| G5 | 중복 (DRY) | "G5 — 함수 추출 검토" |
| G9 | 죽은 코드 즉시 삭제 | "G9 — 안 쓰는 코드/주석 코드 삭제" |
| G14 | 기능 욕심 (다른 클래스 데이터를 더 씀) | "G14 — 이 로직 X 클래스로 (8.1 함수 옮기기)" |
| G15 | 선택자 인수 (boolean 플래그) | "G15 — boolean 매개변수 분리 또는 enum" |
| G19 | 서술적 변수 | "G19 — 복잡한 식을 변수로" |
| G23 | If/Switch → 다형성 | "G23 적용 가능, Strategy 검토" |
| G25 | 매직 숫자 → 상수 | "G25 — 200을 의미 있는 상수로" |
| G28 | 조건 캡슐화 | "G28 — `isReady()` 같은 메서드로" |
| G30 | 함수는 한 가지만 | "G30 위배 — 함수 분리" |
| G34 | 추상화 수준 한 단계만 | "G34 — 두 수준이 섞임" |
| G36 | 추이적 탐색 피하기 (디미터) | "G36 — `a.getB().getC()` 체인" |
| N1 | 서술적 이름 | "N1 — `data` 보다 의미 있는 이름" |
| N7 | 이름으로 부수효과 설명 | "N7 — 검증 함수가 이메일도 보냄" |
| T5 | 경계 조건 테스트 | "T5 — 빈 컬렉션·null 테스트 추가" |

### 3.3 Effective Java 핵심 20 ⭐
*근거: Effective Java (90 Item 중 핵심 20 선별) · 장별 상세: [[entity-effective-java]]*

| 장 | Item | 항목 (공식 제목) | 실무 포인트 |
|----|------|------|------|
| 2 객체 생성·파괴 | 1 | 정적 팩터리 메서드 고려 | `new` 대신 `of`·`from`·`valueOf` |
| 2 객체 생성·파괴 | 5 | 의존 객체 주입 | 자원 직접 명시 X, 생성자 주입 |
| 2 객체 생성·파괴 | 9 | try-with-resources | try-finally보다 우선 |
| 3 공통 메서드 | 11 | equals 재정의 시 hashCode도 | 한 쪽만 재정의 금지 |
| 4 클래스·인터페이스 | 17 | 변경 가능성 최소화 | 불변 클래스 우선 (record) |
| 4 클래스·인터페이스 | 18 | 상속보다 컴포지션 | Stack extends Vector 함정 |
| 4 클래스·인터페이스 | 20 | 추상 클래스보다 인터페이스 | 다중 구현·믹스인 가능 |
| 5 제네릭 | 31 | 한정적 와일드카드 (PECS) | Producer-Extends, Consumer-Super |
| 6 열거·애너테이션 | 34 | int 상수 대신 enum | 타입 안전 + switch 제거 |
| 6 열거·애너테이션 | 39 | 명명 패턴보다 애너테이션 | `@Test` 식 메타데이터 |
| 7 람다·스트림 | 45 | 스트림은 주의해서 | 가독성 1순위, 남용 X |
| 7 람다·스트림 | 48 | 스트림 병렬화 주의 | 측정 후, 함부로 X |
| 8 메서드 | 49 | 매개변수 유효성 검사 | public 메서드 첫 줄 |
| 8 메서드 | 50 | 적시에 방어적 복사 | 가변 객체 저장·반환 시 |
| 9 일반 프로그래밍 | 64 | 인터페이스로 객체 참조 | `List` 타입으로 선언 |
| 9 일반 프로그래밍 | 67 | 최적화는 신중히 | 측정 먼저 |
| 10 예외 | 77 | 예외를 무시하지 말 것 | 빈 catch 블록 금지 |
| 11 동시성 | 78 | 공유 가변 데이터 동기화 | `synchronized`·`volatile` |
| 11 동시성 | 79 | 과도한 동기화 회피 | 락 안에서 외부 콜백 X |
| 12 직렬화 | 85 | 자바 직렬화 대안 우선 | JSON·protobuf |

### 3.4 GRASP — 책임 할당 (9패턴)
*근거: [[lecture-object-ch5]]*

| 패턴 | 책임 할당 질문 |
|------|------|
| 정보 전문가 (Information Expert) | "이 일에 필요한 정보를 누가 가장 많이 아는가?" — 출발점, 가장 자주 쓰는 패턴 |
| 창조자 (Creator) | "A 가 B 를 포함·기록·긴밀히 사용하거나 B 의 정보를 가지면, A 가 B 를 생성" |
| 컨트롤러 (Controller) | "UI·시스템 이벤트를 받아 도메인에 위임하는 첫 책임을 어느 객체가 지는가?" |
| 낮은 결합도 (Low Coupling) | "결합도가 더 낮은 할당 후보를 골랐는가?" |
| 높은 응집도 (High Cohesion) | "관련 책임이 한 객체에 모여 있는가? (비대해지면 분리)" |
| 다형성 (Polymorphism) | "타입에 따른 분기(switch)를 다형성으로 바꿨는가?" |
| 순수 가공물 (Pure Fabrication) | "도메인에 없는 책임을 인위적 객체(Service·Repository)에 두되 남발하지 않았는가?" |
| 간접화 (Indirection) | "두 객체의 직접 결합을 중간 객체로 낮췄는가?" |
| 변경 보호 (Protected Variations) | "변경 가능성 높은 지점을 안정된 인터페이스로 감쌌는가?" |

→ **정보 전문가**가 출발점. 단 정보 객체가 비대해지면 **높은 응집도**와 균형 — 9패턴은 외울 규칙이 아니라 사고 도구.

---

## 4. 사용 방법

이 가이드와 두 슬래시 명령(`/code-guide`·`/code-check`)을 **① 이 프로젝트 · ② 다른 Claude Code 프로젝트 · ③ 다른 AI** 환경별로 쓰는 법.

> **명령의 작동 원리** — 두 명령은 이 가이드 본문을 베이스로 동작한다. my-wiki 프로젝트 안에선 `wiki/` 파일을 직접 읽고, **다른 프로젝트에선 `wiki/` 가 없으므로 자동으로 `https://wiki.wonslab.dev/...` 를 WebFetch** 한다(그때만 인터넷 필요). 그래서 명령 파일만 있으면 어디서든 동작한다.

### 4.1 이 프로젝트(my-wiki)에서 — 슬래시 명령

- **`/code-guide`** — 코드 작성 가이드 (이 페이지 컨텍스트)
- **`/code-check`** — 현재 git diff 를 5권 원칙으로 점검

```
/code-guide function      # 함수 작성에 집중
/code-check staged        # staged 변경만 점검
/code-check main          # main 대비 현재 브랜치 diff
```

### 4.2 다른 Claude Code 프로젝트로 — 명령 이식

다른 프로젝트(회사·사이드)에서도 두 명령을 쓰려면 명령 파일만 옮기면 된다.

**방법 A — 명령 파일 전체를 복붙 (가장 확실·오프라인 OK) ⭐**

아래 두 코드블록을 그대로 복사해 새 프로젝트에 저장하면 끝. my-wiki 클론도 별도 설치도 불필요.

**① `.claude/commands/code-guide.md` 만들고 ↓ 전체 붙여넣기**

````markdown
---
description: 5권 도서 원칙으로 코드 작성 가이드 — 새 코드 짤 때 체크리스트
argument-hint: <대상 영역> (예: function, class, exception, test, all)
---

# /code-guide — 코드 작성 가이드

대상: `$ARGUMENTS`

위키의 [[guide-code-authoring-and-review]] 를 베이스로 5권 도서 (오브젝트·Effective Java·리팩터링·Clean Code·TDD) 원칙으로 코드 작성을 안내한다.

## 절차

### 1. 가이드 본문 로드

먼저 가이드 본문을 로드:
- **로컬 my-wiki 프로젝트**: `wiki/guide-code-authoring-and-review.md` 직접 읽기
- **다른 프로젝트** (`wiki/` 디렉터리 없음): WebFetch 로 `https://wiki.wonslab.dev/guide-code-authoring-and-review/` fetch

우선 활용 섹션:
- **2. 코드 작성 체크리스트** (Writing)
- **1. 6가지 핵심 설계 원칙** — 객체 협력·추상 의존·합성>상속·불변·단순 설계·테스트

### 2. 대상 영역 분기

`$ARGUMENTS` 가 비어있으면 **전체 작성 체크리스트** 7 카테고리 적용.

영역별:
- `function` — 2.1 함수 (Clean Code 3장 + EJ 49~56 + 리팩터링 6장)
- `class` — 2.2 객체·클래스 (오브젝트 4·5·10·11장 + EJ 17·18·20)
- `dependency` — 2.3 의존성 (오브젝트 8·9장 + EJ 5·64)
- `exception` — 2.4 예외·null (Clean Code 7장 + EJ 69~77)
- `domain` — 2.5 도메인 모델 (오브젝트 + DDD)
- `test` — 2.6 테스트 (TDD + Clean Code 9장)
- `concurrency` — 2.7 동시성 (EJ 78~84 + Clean Code 13장)
- `all` 또는 생략 — 전체

### 3. 사용자 요구사항 청취

"어떤 코드를 작성할 것인가" 사용자 입력 받기:
- 도메인 (주문·결제·인증 등)
- 기술 스택 (Spring Boot 3·JPA·WebFlux 등)
- 제약 사항 (성능·테스트 가능성 등)

### 4. 코드 작성 + 원칙 인용

작성하면서 어떤 원칙을 적용했는지 **인라인 주석 또는 별도 보고**:

```java
// EJ Item 5 — 생성자 주입
public OrderService(OrderRepository repo, PaymentGateway gateway) {
    this.repo = repo;
    this.gateway = gateway;
}

// Clean Code G19 — 서술적 변수
public Money totalFee(Order order) {
    Money baseAmount = order.items().stream().map(OrderItem::amount).reduce(Money.ZERO, Money::plus);
    Money discount = discountPolicy.apply(order);
    return baseAmount.minus(discount);
}
```

### 5. 자기 점검 + 보고

작성 완료 후 체크리스트 자기 점검 결과 표로 보고:

| 카테고리 | 항목 | 결과 |
|---------|------|------|
| 함수 | 한 화면 이내 | ✅ |
| 함수 | 한 가지 일 | ✅ |
| ... | ... | ... |

위반 항목이 있으면 트레이드오프 명시.

## 참조 페이지

**my-wiki 프로젝트에서**: 위키 링크로 직접 읽기
- [[guide-code-authoring-and-review]] — 본 가이드 (전체 체크리스트)
- [[guide-java-book-study-lab]] — 실습 환경 (Java 17·JUnit 5)
- 5권 entity: [[entity-object]]·[[entity-effective-java]]·[[entity-refactoring]]·[[entity-clean-code]]·[[entity-tdd]]

**다른 프로젝트에서**: WebFetch URL
- https://wiki.wonslab.dev/guide-code-authoring-and-review/ — 본 가이드
- https://wiki.wonslab.dev/guide-java-book-study-lab/ — 실습 환경
- https://wiki.wonslab.dev/entity-object/ ·  /entity-effective-java/ · /entity-refactoring/ · /entity-clean-code/ · /entity-tdd/

## 사용 예

```
/code-guide                # 전체 체크리스트로 작성 안내
/code-guide function       # 함수 작성에만 집중
/code-guide test           # TDD + F.I.R.S.T. 로 테스트 작성
/code-guide class          # 클래스 설계
```
````

**② `.claude/commands/code-check.md` 만들고 ↓ 전체 붙여넣기**

````markdown
---
description: 5권 도서 원칙으로 코드 점검 — 현재 diff 또는 지정 파일을 24 악취·EJ 20·Clean Code 휴리스틱으로
argument-hint: <대상> (예: 파일 경로, "diff", "staged", 생략 시 git diff HEAD)
---

# /code-check — 코드 점검

대상: `$ARGUMENTS`

위키의 [[guide-code-authoring-and-review]] 를 베이스로 5권 도서 원칙 (24 악취·EJ 20 핵심·Clean Code 17장 휴리스틱·GRASP·오브젝트 책임 주도) 으로 코드를 점검한다.

## 절차

### 1. 대상 코드 수집

`$ARGUMENTS` 분기:
- 비어있으면 → `git diff HEAD` (워킹 트리 변경)
- `diff` → `git diff HEAD`
- `staged` → `git diff --cached`
- 파일 경로 → 그 파일 통째
- `main` / `<branch>` → `git diff <branch>...HEAD`

### 2. 가이드 본문 로드

먼저 가이드 본문 로드:
- **로컬 my-wiki 프로젝트**: `wiki/guide-code-authoring-and-review.md` 직접 읽기
- **다른 프로젝트** (`wiki/` 디렉터리 없음): WebFetch 로 `https://wiki.wonslab.dev/guide-code-authoring-and-review/`

다음 섹션의 **3. 코드 점검 체크리스트** 활용:
- 3.1 리팩터링 24 악취
- 3.2 Clean Code 17장 ⭐ 휴리스틱 (G19·G23·G25·G30·G34·N1·T5 등)
- 3.3 EJ ⭐ 20 (Item 5·17·18·49·64·77·78·79·85)
- 3.4 GRASP 책임 할당

### 3. 점검 + 표 보고

각 발견을 표준 형식으로:

| 위치 | 코드 | 점검 | 처방 | 우선순위 |
|------|------|------|------|---------|
| `OrderService.java:42` | `public boolean process(Order o, boolean async, boolean retry)` | 리팩터링 3.4 (긴 매개변수) + EJ Item 51 (boolean 플래그) | `process(Order, ProcessOption)` 매개변수 객체화 | 🔴 High |
| `User.java:18` | `public List<Order> getOrders() { return orders; }` | EJ Item 50 (방어적 복사) | `return List.copyOf(orders)` | 🟡 Medium |
| `PriceCalculator.java:55` | `if (type == 1) ... else if (type == 2) ...` | 리팩터링 3.12 + Clean Code G23 | 다형성 (Strategy) 또는 enum + switch | 🟡 Medium |
| `OrderService.java:88` | `} catch (Exception e) {}` | Clean Code Item 77 | 최소 로그 + 의도 주석 또는 처리 | 🔴 High |

### 4. 우선순위 분류

| 우선순위 | 기준 | 예 |
|---------|------|-----|
| 🔴 **High** | 운영 사고 직결·보안·LSP 위배 | 빈 catch·SQL injection·전역 가변·LSP 위배 |
| 🟡 **Medium** | 가독성·유지보수·결합도 폭증 | 긴 함수·boolean 플래그·기본형 집착·중복 |
| 🟢 **Low** | 스타일·미시 정련 | 이름·서술적 변수·가짜 메서드 인라인 |

### 5. 종합 요약

점검 후:
- **발견 N건** (High X·Medium Y·Low Z)
- **반복 패턴** — 같은 악취가 여러 곳이면 묶어 보고
- **다음 단계 제안** — 즉시 수정 / PR 코멘트 / 별도 리팩터링 작업

### 6. 자동 수정 옵션 (선택)

사용자가 "수정해" 요청하면:
- High 우선순위만 자동 수정 후 보고
- Medium 은 제안만 (수정 트레이드오프 큼)
- Low 는 스킵
- 수정 후 빌드·테스트 통과 확인

## 참조 페이지

**my-wiki 프로젝트에서**: 위키 링크로 직접
- [[guide-code-authoring-and-review]] — 본 점검 체크리스트
- 24 악취: [[lecture-refactoring-ch3]]
- 17장 휴리스틱: [[lecture-clean-code-ch17]]
- EJ ⭐ 20: [[entity-effective-java]]
- GRASP: [[lecture-object-ch5]]

**다른 프로젝트에서**: WebFetch URL
- https://wiki.wonslab.dev/guide-code-authoring-and-review/
- https://wiki.wonslab.dev/lecture-refactoring-ch3/ — 24 악취
- https://wiki.wonslab.dev/lecture-clean-code-ch17/ — 17장 휴리스틱
- https://wiki.wonslab.dev/entity-effective-java/ — EJ ⭐ 20
- https://wiki.wonslab.dev/lecture-object-ch5/ — GRASP

## 사용 예

```
/code-check                       # 현재 diff
/code-check staged                # staged 변경만
/code-check src/main/...Service.java  # 특정 파일
/code-check main                  # main 대비 현재 브랜치 diff
```

## 안전 규칙

- **점검 결과 보고만** — 사용자가 명시 요청해야 자동 수정.
- **위반 ≠ 무조건 잘못** — 트레이드오프 명시. 도그마 X.
- **운영 사고 직결 (High)** 만 강하게 권고. Medium·Low 는 검토 후보.
- *Effective Java* Item·*리팩터링* 카탈로그 번호 등 **출처 명시** — "왜 그렇게 해야 하는지" 추적 가능.
````

저장 후 Claude Code 를 다시 열면 사용 가능.

> ⚠️ 위 두 블록은 **스냅샷**이다. 원본은 GitHub(방법 B). 명령을 고쳤다면 이 블록도 함께 갱신해야 어긋나지 않는다.

**방법 B — `curl` 로 최신본 내려받기 (GitHub, 인터넷 필요)**

```bash
mkdir -p .claude/commands
curl -fsSL https://raw.githubusercontent.com/goodjwon/my-wiki/main/.claude/commands/code-guide.md \
  -o .claude/commands/code-guide.md
curl -fsSL https://raw.githubusercontent.com/goodjwon/my-wiki/main/.claude/commands/code-check.md \
  -o .claude/commands/code-check.md
```

항상 최신 — 이쪽이 **원본**(방법 A 블록보다 우선). 단 GitHub 접근 필요.

### 4.3 다른 AI(ChatGPT·Cursor·Gemini)에서 — 프롬프트·본문

슬래시 명령이 없는 도구에선 (a) 이 페이지 본문을 첫 메시지 컨텍스트로 주거나 (b) 아래 프롬프트 템플릿을 복붙.

**(a) 본문 컨텍스트**

```
1. https://wiki.wonslab.dev/guide-code-authoring-and-review/ 열기 → 본문 전체 복사
2. AI 첫 메시지: "다음은 내가 따를 코드 작성·점검 원칙이다. 이 컨텍스트로 작업해줘. [본문 붙여넣기]"
3. 이후 "이 원칙으로 OrderService 짜줘" / "이 코드 점검해줘"
```

**(b) 프롬프트 템플릿 — 작성**

```
나는 Java/Spring 백엔드 개발자다. 다음 5권 도서의 원칙을 기준으로 코드를 작성해주세요:
- 오브젝트 (책임 주도 설계, 협력 우선)
- Effective Java (90 권고, 메서드 단위)
- 리팩터링 (24 악취 회피)
- Clean Code (작은 함수, 의도 드러나는 이름)
- TDD (테스트가 안전망)

특히 다음 원칙 준수:
1. 함수는 작게·한 가지·CQS
2. 추상 의존·생성자 주입
3. 매개변수 0~3개·boolean 플래그 회피
4. 불변 우선 (record)
5. 도메인 객체에 행동 (빈혈 X)
6. 테스트 함께 작성

[요구사항]: <여기에 작성할 코드 요구사항>
```

**(b) 프롬프트 템플릿 — 점검**

```
다음 코드를 5권 도서 원칙으로 점검해주세요. 발견 사항을 다음 형식으로 보고:

| 위치 | 코드 | 점검 | 처방 |
|------|------|------|------|
| 라인 N | <코드> | <악취 코드 G5·EJ Item 18·리팩터링 3.11 등> | <구체 처방> |

점검 기준:
- 리팩터링 24 악취 (3.1~3.24)
- Clean Code 17장 휴리스틱 (특히 G19·G23·G25·G30·G34·N1·T5)
- Effective Java ⭐ 20 (Item 5·17·18·49·64·77 등)
- 오브젝트 책임 주도 + Tell, Don't Ask
- TDD F.I.R.S.T.

[코드]:
```

### 4.4 환경별 비교

| 방법 | 적용 도구 | 설치 | 오프라인 | 최신성 |
|------|----------|------|----------|--------|
| **4.1** 슬래시 (이 프로젝트) | Claude Code (my-wiki) | 0 | ✅ | ✅ |
| **4.2-A** 전체 복붙 | 다른 Claude Code | 0 (복붙) | ✅ | ⚠️ 스냅샷 (수동 갱신) |
| **4.2-B** curl | 다른 Claude Code | 2 파일 다운 | ❌ GitHub 필요 | ✅ 항상 최신 |
| **4.3** 프롬프트·본문 | ChatGPT·Cursor·Gemini 등 모두 | 0 | 본문 저장 시 ✅ | ❌ 수동 |

### 4.5 PR 리뷰 어휘

리뷰 코멘트에 표준 코드 인용:

```
이 부분 G23 적용 검토 — switch 가 3 곳 반복, Strategy 패턴으로
```

```
EJ Item 49 — public 메서드 첫 줄에 매개변수 검증 추가
```

```
리팩터링 3.4 (긴 매개변수 목록) → 6.8 매개변수 객체로
```

→ **합의가 빠름** — 코드 한 줄이 책 한 권 인용.

### 4.6 신입 교육

한 페이지로 핵심 점검 어휘 습득. 인턴·신입에게:
- "PR 올리기 전 이 페이지의 작성 체크리스트 확인"
- "리뷰 시 17장 휴리스틱 코드로 코멘트"
- "한 달 후 자기 PR 돌아보며 어떤 항목 위반했는지 확인"

---

## 5. 분야별 빠른 인덱스

### 함수 작성
- [[lecture-clean-code-ch3]] (함수)
- [[lecture-refactoring-ch6]] (기본 리팩터링)
- [[lecture-effective-java-ch8]] (메서드)

### 클래스 설계
- [[lecture-object-ch4]] (설계 품질·트레이드오프)
- [[lecture-object-ch5]] (책임 할당·GRASP)
- [[lecture-clean-code-ch10]] (클래스)
- [[lecture-effective-java-ch4]] (클래스·인터페이스)

### 의존성·DI
- [[lecture-object-ch8]] (의존성 관리)
- [[lecture-object-ch9]] (유연한 설계·OCP·DIP)
- [[concept-spring-core]] (Spring DI)

### 예외 처리
- [[lecture-clean-code-ch7]] (오류 처리)
- [[lecture-effective-java-ch10]] (예외)
- [[concept-transactional-rollback-policy]] (Spring 롤백)

### 테스트
- [[lecture-clean-code-ch9]] (단위 테스트·F.I.R.S.T.)
- [[lecture-tdd-ch1]] ~ [[lecture-tdd-ch17]] (1부 화폐 진화)
- [[src-spring-testing-ref]] (JUnit 5·MockMvc)

### 동시성
- [[lecture-clean-code-ch13]] (동시성 방어 원칙)
- [[lecture-effective-java-ch11]] (Item 78~84)

### 리팩터링 카탈로그
- [[lecture-refactoring-ch3]] (24 악취)
- [[lecture-refactoring-ch6]] ~ [[lecture-refactoring-ch12]] (66 기법)

---

## 6. 같은 인사이트 패턴 — "이름 있는 메커니즘이 즉흥보다 안전"

여러 책에 공통으로 누적된 원리. 이 가이드 자체도 그 적용:

| 영역 | 즉흥적 | 이름 있는 메커니즘 | 참조 |
|------|--------|---------------------|------|
| **코드 변경** | "그냥 고친다" | 리팩터링 66 카탈로그 + 테스트 | (이 가이드) |
| **PR 리뷰** | "왠지 별로다" | "G19·EJ Item 18·리팩터링 3.11" | (이 가이드) |
| **AI 에이전트** | "잘 해줘" 부탁 | CLAUDE.md·hooks·skills | [[concept-harness-engineering]] |
| **AI 루프** | 즉흥 프롬프트 | 루프 자체 코드 | [[concept-loop-engineering]] |
| **자기검증** | 사람이 테스트 | back-pressure hook | [[concept-claude-hooks]] |
| **트랜잭션** | "알아서 처리하겠지" | `@Transactional` + `rollbackFor` 명시 | [[concept-transactional-rollback-policy]] |

→ **공통 원리**: 안전한 시스템은 **이름·전제·절차가 명시된 메커니즘** 의 누적. "잘 알아서 한다" 는 가정은 어디서나 위험.

---

## 7. 참고 — 근거가 된 도서

이 가이드가 압축한 5권. 각 책의 자리와 관점:

| 책 | 단위 | 시점 | 한 줄 메시지 |
|----|------|------|------|
| [[entity-object]] *오브젝트* | 객체·협력 | 처음부터 잘 설계 | "메시지가 객체를 결정한다" |
| [[entity-effective-java]] *Effective Java* | 메서드·필드 | 매번 짤 때 | "Java 90 권고를 매번 적용" |
| [[entity-refactoring]] *리팩터링* | 1단계 변환 | 이미 짠 코드 | "24 악취 → 66 카탈로그" |
| [[entity-clean-code]] *Clean Code* | 줄·이름·함수 | 매 라인 | "다음 사람이 읽기 쉬워야" |
| [[entity-tdd]] *TDD* | 사이클 | 코드 짜기 전 | "빨강 → 초록 → 리팩터" |

---

## 8. 관련 페이지

- **[[guide-java-book-study-lab]] — 5권 실습 환경 가이드 (Java 17·JUnit 5·Python·Node)** ← 이 가이드의 환경 전제
- 5권 entity: [[entity-object]] / [[entity-effective-java]] / [[entity-refactoring]] / [[entity-clean-code]] / [[entity-tdd]]
- 5권 강의 교재 인덱스: [[src-object-lecture]] / [[src-effective-java-lecture]] / [[src-refactoring-lecture]] / [[src-clean-code-lecture]] / [[src-tdd-lecture]]
- 위키 작성 표준 (이 가이드의 작성 원칙): [[guide-wiki-authoring-standards]]
- 위키 워크플로: [[concept-ingest]] / [[concept-query]] / [[concept-lint]]
- 같은 패턴 다른 영역: [[concept-harness-engineering]] / [[concept-loop-engineering]] / [[concept-claude-hooks]]
