---
title: "리팩터링 2판 실전 강의 — 4장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 4장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 4장 — 테스트 구축하기

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 설명 → 비유 → 현업 예제 → 따라하기 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, JUnit 5, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 자가 테스트 코드가 **리팩터링의 안전망** 인 이유를 안다.
- **테스트 우선** 사고를 익힌다 — "이 동작은 어떻게 깨질 수 있는가" 부터 생각.
- **픽스처(Fixture)** 의 개념과 재사용 패턴.
- **경계 조건(Boundary)** 을 의식적으로 테스트한다.
- 6장부터의 카탈로그를 **언제든 멈출 수 있는 작은 단계** 로 적용할 수 있는 기반.

### 0.2 큰 그림 — 리팩터링과 테스트의 관계

```
[ 자가 테스트 없음 ]            [ 자가 테스트 있음 ]
"두렵다, 손대지 말자"           "한 단계 바꾸고 테스트 → 빨강이면 되돌리기"
긴 코드가 점점 더 커짐           작은 단계의 누적으로 구조 개선
                                  PR 단위가 작아짐 → 리뷰 빨라짐
```

> **비유 — 자가 테스트는 "공사장 안전 헬멧"입니다.**
>
> 헬멧 없이도 공사는 가능하지만, 사고 한 번이면 끝. 헬멧이 있으면 매일 자잘한 사고를 견디며 빠르게 진행할 수 있습니다. **속도의 진짜 기반은 안전**.

### 0.3 핵심 한 줄

> **자가 테스트가 있어야만 리팩터링이 "안전한 작은 단계의 연속" 이 된다.**

테스트가 없으면 "리팩터링" 이 "재작성" 이 되고, "한 시간만 손볼게요" 가 "다음 주에 봅시다" 가 된다.

---

## 1. 자가 테스트 코드의 가치

### 비유 — "통보 받는 농부 vs 매일 확인하는 농부"

- 통보 받는 농부: 잎이 다 시들고 나서야 옆 사람이 알려줌.
- 매일 확인하는 농부: 작은 변화 즉시 발견.

자가 테스트가 후자. **변화 즉시 알 수 있는가** 가 작업 속도를 결정.

### 4가지 핵심 효과

1. **디버깅 시간 단축** — 사고 직후 = 의심 범위 좁음. 며칠 뒤 = 의심 범위 폭발.
2. **변경 두려움 제거** — "테스트가 빨강이면 되돌린다" 라는 안전 백업.
3. **설계의 피드백** — 테스트하기 어려운 구조 = 결합도 높은 구조. 테스트가 설계를 끌어준다.
4. **문서로 작동** — 테스트 코드는 "이 함수는 X 입력에 Y 출력" 을 직접 보여주는 살아 있는 문서.

### Fowler 인용 (취지)

> "테스트는 그 자체로 가치가 있다. 리팩터링은 거기에 얹어지는 보너스다."

---

## 2. 테스트 우선 사고

### 비유 — "여행 짐 싸기 vs 여행 가서 깨닫기"

테스트 우선 = 출발 전 짐 점검. 작성 후 = 도착 후 "아 이거 안 가져왔네".

### 테스트 우선의 3단계 (Beck의 TDD 사이클 요약)

```
RED — 실패하는 작은 테스트 1개 작성
GREEN — 통과시킬 가장 단순한 코드 작성
REFACTOR — 중복 제거·이름 정리 (3장 악취 점검)
```

리팩터링 책에서는 RED·GREEN까지는 가볍게, **REFACTOR 단계** 에 무게.

### 실전 메모

- 테스트가 먼저면 "이 함수의 입력·출력은 무엇인가" 라는 **계약** 부터 생각하게 됨.
- 자연스럽게 **함수가 작아지고 결정적(deterministic)** 으로 변함.
- DB·외부 API 의존이 줄어듦 — 의존을 받는 구조(DI)로 진화.

---

## 3. 테스트할 샘플 코드

이 절은 책 본문에서 자세히 다루는 예제(Province·Producer)를 다루는 자리. 본 강의에서는 **자바/Spring 환경 예제**로 갈음합니다.

### 예제 — 주문 합계 계산

```java
public class Order {
    private final List<OrderItem> items;
    private final DiscountPolicy discountPolicy;

    public Order(List<OrderItem> items, DiscountPolicy discountPolicy) {
        this.items = List.copyOf(items);
        this.discountPolicy = discountPolicy;
    }

    public Money total() {
        Money subtotal = items.stream()
            .map(OrderItem::lineAmount)
            .reduce(Money.ZERO, Money::plus);
        Money discount = discountPolicy.discountFor(subtotal);
        return subtotal.minus(discount);
    }
}
```

이 한 클래스를 테스트하는 과정을 따라가 봅니다.

---

## 4. 첫 번째 테스트

### 따라하기 — 가장 단순한 케이스

```java
class OrderTest {

    @Test
    void 할인_없는_주문의_합계는_품목_합계와_같다() {
        // given
        List<OrderItem> items = List.of(
            new OrderItem("커피", Money.won(4500), 2),
            new OrderItem("케이크", Money.won(6000), 1)
        );
        Order order = new Order(items, DiscountPolicy.NONE);

        // when
        Money total = order.total();

        // then
        assertThat(total).isEqualTo(Money.won(15_000));
    }
}
```

### 첫 테스트의 미덕

- **이름이 동작을 말한다** — 메서드명만 봐도 "할인 없으면 합계 = 품목 합계" 라는 계약을 알 수 있음.
- **given-when-then** 으로 의도 단계가 보임.
- 한 가지 사실만 검증 (`assertThat` 1개).

### 함정 — 첫 테스트가 너무 큰 경우

```java
// ❌
@Test void 모든_케이스() {
    assertThat(...).isEqualTo(...);
    assertThat(...).isEqualTo(...);
    // ... 10개 assertThat
}
```

한 테스트에 5개 검증 = 첫 번째에서 실패하면 나머지는 못 봄. **테스트 하나는 한 동작**.

---

## 5. 테스트 추가하기

같은 클래스의 다양한 케이스를 늘려갑니다.

```java
@Test
void 정액_할인_정책일_때_할인이_적용된다() {
    var items = List.of(new OrderItem("커피", Money.won(5000), 1));
    var order = new Order(items, DiscountPolicy.fixed(Money.won(1000)));

    assertThat(order.total()).isEqualTo(Money.won(4000));
}

@Test
void 정률_할인_정책일_때_퍼센트만큼_할인된다() {
    var items = List.of(new OrderItem("케이크", Money.won(10_000), 1));
    var order = new Order(items, DiscountPolicy.percent(10));

    assertThat(order.total()).isEqualTo(Money.won(9000));
}

@Test
void 품목이_없으면_합계는_0원이다() {
    var order = new Order(List.of(), DiscountPolicy.NONE);

    assertThat(order.total()).isEqualTo(Money.ZERO);
}
```

### 좋은 테스트 추가의 원칙

- **한 테스트 = 한 시나리오 = 한 의도**.
- **이름이 시나리오 자체** — `정률_할인일_때_퍼센트만큼_할인된다`.
- **점진적 추가** — 한 번에 5개 짜지 말고, 1개씩 통과시키며.

---

## 6. 픽스처 수정하기

### 픽스처(Fixture)란

여러 테스트가 공유하는 **초기 상태 준비 코드**. 매번 길게 쓰면 노이즈.

### 안티패턴 — 매 테스트에 같은 셋업 반복

```java
@Test void test1() {
    var items = List.of(new OrderItem("커피", Money.won(4500), 2), ...);   // 3줄
    var order = new Order(items, ...);
    // ...
}

@Test void test2() {
    var items = List.of(new OrderItem("커피", Money.won(4500), 2), ...);   // 같은 3줄
    var order = new Order(items, ...);
    // ...
}
```

### 권장 — 픽스처를 한 곳에

```java
class OrderTest {

    private List<OrderItem> coffeeAndCake;

    @BeforeEach
    void setUp() {
        coffeeAndCake = List.of(
            new OrderItem("커피", Money.won(4500), 2),
            new OrderItem("케이크", Money.won(6000), 1)
        );
    }

    @Test void 할인_없으면_15000원() {
        var order = new Order(coffeeAndCake, DiscountPolicy.NONE);
        assertThat(order.total()).isEqualTo(Money.won(15_000));
    }
}
```

### 더 권장 — 팩터리 메서드

```java
private Order order(DiscountPolicy policy) {
    return new Order(coffeeAndCake, policy);
}

@Test void 정액_할인() {
    assertThat(order(DiscountPolicy.fixed(Money.won(1000))).total())
        .isEqualTo(Money.won(14_000));
}
```

테스트가 한 줄로 줄어듦 = 의도가 한눈에 보임.

### 함정 — 픽스처를 너무 많이 공유

```java
@BeforeEach
void setUp() {
    // 10개 도메인 객체를 미리 만들어둠
    // 각 테스트는 그중 일부만 쓰는데, 무엇을 쓰는지 안 보임
}
```

→ **각 테스트가 자기 픽스처를 명시** 하는 게 더 명료. 픽스처는 **3개 이상 테스트가 정말 같이 쓸 때** 만 공유.

---

## 7. 경계 조건 검사하기

### 정상 케이스만 테스트하면 위험

```java
// 정상 — 통과
assertThat(order(coffeeAndCake, NONE).total()).isEqualTo(Money.won(15_000));

// 경계 — 빠뜨리기 쉬움
// - 품목이 0개?
// - 품목 수량이 0?
// - 할인 금액이 합계보다 큼?
// - 음수 가격?
// - null 매개변수?
```

### 경계 조건 6가지 카테고리

| 카테고리 | 예 |
|----------|----|
| **빈 컬렉션 / null** | 품목 0개, null 정책 |
| **수 경계** | 0, 1, MAX, 음수 |
| **시간 경계** | 자정·연말·윤년·시간대 전환 |
| **문자열 경계** | 빈 문자열, 매우 긴 문자열, 멀티바이트 |
| **부동소수점** | 0.1 + 0.2 == 0.3 같은 함정 ([[entity-effective-java]] Item 60) |
| **동시성** | 동시 호출, 같은 ID 중복 등록 |

### 따라하기 — 경계 테스트 추가

```java
@Test
void 품목이_없으면_합계는_0원() {
    assertThat(order(List.of(), NONE).total()).isEqualTo(Money.ZERO);
}

@Test
void 할인이_합계를_넘으면_0원_바닥() {
    var hugeDiscount = DiscountPolicy.fixed(Money.won(100_000_000));
    assertThat(order(coffeeAndCake, hugeDiscount).total())
        .isEqualTo(Money.ZERO);
}

@Test
void 정책이_null이면_생성자에서_예외() {
    assertThatThrownBy(() -> new Order(coffeeAndCake, null))
        .isInstanceOf(NullPointerException.class);
}
```

### Fowler의 사고 방식

> "코드가 어떻게 깨질 수 있는가 를 즐겁게 상상하라. 그게 좋은 프로그래머의 자질이다."

악의적 시나리오를 즐겁게 생각하기 — 보안·운영 사고를 미리 막는 마인드.

---

## 8. 끝나지 않은 여정

### 자가 테스트는 100% 커버리지가 목적이 아니다

```
[ 비싼 100% ]                  [ 가성비 있는 80% ]
- 모든 라인 커버                - 핵심 비즈니스 로직 100%
- 게터/세터까지 테스트            - 단순 코드는 생략
- 작성·유지 비용 폭증            - 경계·실패 시나리오 풍부
```

### 어디까지 테스트할까

- **버그가 자주 났던 곳** — 다음에 안 나도록 박제
- **결과가 결정적인 코드** (계산·변환·라우팅)
- **외부 의존 경계** — DI 받는 인터페이스를 mocked로

### 외부 의존 처리

```java
// ❌ 테스트 안에서 진짜 DB·외부 API 호출
@Test void test() {
    OrderService service = new OrderService(realRepository, realPaymentGateway);
    // ...
}

// ✅ 의존을 인터페이스로 받고, 테스트에서 가짜 구현 주입
@Test void test() {
    OrderService service = new OrderService(
        new InMemoryRepository(),
        new FakePaymentGateway()
    );
    // ...
}
```

이래야 테스트가 빠르고, 외부 환경 무관하게 안정적.

---

## 9. Spring/JPA 현업 메모

### 단위 vs 통합

| 종류 | 도구 | 언제 |
|------|------|------|
| **단위 테스트** | JUnit + Mockito | 도메인 로직, 순수 함수, 알고리즘 |
| **슬라이스 테스트** | `@WebMvcTest`, `@DataJpaTest` | Controller·Repository 일부만 |
| **통합 테스트** | `@SpringBootTest` | 전체 흐름, 인수 테스트 |

→ 핵심 비즈니스는 **단위** 위주, 슬라이스/통합은 보조. **단위가 많을수록 빠르고 안전**.

### AssertJ 권장

```java
// JUnit 기본
assertEquals(expected, actual);

// AssertJ — 메시지·체이닝·도메인 표현력 압도적
assertThat(order.total())
    .as("정액 1000원 할인 후 합계")
    .isEqualTo(Money.won(14_000));
```

### 트랜잭션·롤백

```java
@SpringBootTest
@Transactional   // 테스트 종료 시 자동 롤백 — 테스트 격리
class OrderIntegrationTest {
    // ...
}
```

`@Transactional` 롤백 정책은 [[concept-transactional-rollback-policy]] 참조.

---

## 핵심 교훈

1. **테스트는 그 자체로 가치** — 리팩터링은 보너스. 둘은 한 세트.
2. **한 테스트 = 한 동작** — 이름이 시나리오를 말한다.
3. **픽스처는 3개 이상 공유될 때만** — 과한 공유는 의도를 가린다.
4. **경계 조건이 진짜 버그의 자리** — 정상만 테스트하면 80% 놓친다.
5. **100% 커버리지가 목적 아님** — 핵심·결정적·과거 사고 부위에 집중.
6. **외부 의존은 인터페이스로 받고 테스트에서 가짜 주입** — 빠르고 안정적.
7. **테스트하기 어려운 코드 = 결합도 높은 코드** — 테스트가 설계를 끌어준다.

---

## 함정 / 주의

- **테스트가 구현 디테일을 알면** 리팩터링할 때 같이 깨짐. 공개 동작만 검증하라.
- **flaky 테스트**(가끔 실패)는 곧 무시당함. 즉시 원인 추적·고정·삭제 중 하나.
- **테스트 코드도 코드** — DRY·이름·작은 함수 모두 적용. 단, 명료성이 DRY보다 우선.
- **느린 테스트**는 CI에 부담. 슬라이스/단위가 빠른 게 핵심.

---

## 체크리스트 (팀 규율로)

- [ ] 리팩터링 PR 전에 **자가 테스트** 가 있는가
- [ ] 한 테스트 = 한 시나리오 = 한 의도인가
- [ ] 테스트 이름이 동작을 한국어로 말하는가
- [ ] **경계 조건** (빈/0/MAX/음수/null/시간) 을 의식적으로 테스트했는가
- [ ] 외부 의존을 **인터페이스 + 가짜 구현** 으로 분리했는가
- [ ] flaky 테스트를 방치하지 않는가
- [ ] CI에서 단위 테스트가 빠르게 도는가 (1분 안 넘김 권장)

---

## 퀴즈

<details><summary>Q1. "테스트는 그 자체로 가치가 있다" 의 의미?</summary>

리팩터링이 없어도, 테스트 자체가 **버그 조기 발견·살아 있는 문서·설계 피드백** 으로 이미 본전 이상의 가치를 제공. 리팩터링 안전망은 그 위에 얹어지는 보너스.

</details>

<details><summary>Q2. 픽스처 과공유가 왜 나쁜가?</summary>

각 테스트가 픽스처 중 **무엇을 쓰는지 안 보이기** 때문. 테스트가 "이 시나리오는 이 데이터" 를 명시할 때 가장 읽기 쉽다. 3개 이상이 정말 같이 쓸 때만 공유.

</details>

<details><summary>Q3. 100% 커버리지가 목적이 아니라면 무엇이 목표?</summary>

**핵심 비즈니스 로직과 과거 사고가 났던 부위가 100%** 인 게 목표. 단순 게터/세터, 단순 컨피그 코드까지 다 테스트하는 건 작성·유지 비용 대비 이득 없음. 가성비 있는 80%가 비현실적 100%보다 낫다.

</details>

<details><summary>Q4. "테스트하기 어려운 코드" 가 알려주는 설계 신호는?</summary>

**결합도가 높다** 는 신호. 의존을 인터페이스로 받지 않고 직접 new 하거나, 외부 시스템을 함수 안에서 부르고 있을 가능성. 이때 *Effective Java* Item 5(의존성 주입)·Item 64(인터페이스 참조)가 해법.

</details>

<details><summary>Q5. flaky 테스트(가끔 실패) 를 방치하면 왜 위험한가?</summary>

팀이 "또 그 테스트네" 하고 무시하기 시작 → 진짜 사고가 났을 때도 빨강 신호를 신뢰하지 않게 됨 → **안전망 자체가 무력화**. 즉시 원인 추적·고정·삭제 셋 중 하나.

</details>

---

## 다음 장 예고 — 5장: 리팩터링 카탈로그 보는 법

6장부터 시작될 **66+ 리팩터링 카탈로그의 형식·선정 기준** 을 잠깐 정리합니다. 짧은 장이지만, 카탈로그 활용 방식을 익히지 않으면 6장 이후가 단순 사전 나열로 보입니다.
