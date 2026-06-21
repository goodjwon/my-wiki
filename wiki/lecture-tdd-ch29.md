---
title: "TDD 실전 강의 — 29장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 29장.md]
created: 2026-06-20
updated: 2026-06-21
---

# 테스트 주도 개발 실전 강의 교재

## 29장 — xUnit 패턴

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

xUnit 도구의 활용 패턴을 익힌다. 18~24장에서 만든 작은 프레임워크를 JUnit 5 사용법으로 번역해, 실무 테스트에서 어떤 선택을 해야 하는지 판단한다.

### 0.2 큰 그림

```
[테스트 메서드]  무엇을 검증할지
[픽스처]        어떤 상태에서 시작할지
[단언]          무엇이 맞는지
[예외 테스트]    실패 조건도 계약으로 고정
[전체 테스트]    모든 테스트가 함께 돌아야 신뢰
```

---

## 29장 패턴

### 단언 (Assertion)

각 테스트 끝의 검증. AssertJ의 chain으로 가독성을 높인다.

```java
@Test
void 주문_금액은_음수일_수_없다() {
    assertThatThrownBy(() -> new Money(-1, "KRW"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("amount");
}
```

초보자 기준: 실패 메시지를 읽었을 때 무엇이 틀렸는지 바로 보여야 좋은 단언이다.

### 픽스처 (Fixture)

테스트의 초기 상태. `@BeforeEach` 로 공통, 너무 큰 픽스처는 분해.

```java
class OrderServiceTest {
    private FakePaymentGateway paymentGateway;
    private OrderService orderService;

    @BeforeEach
    void setUp() {
        paymentGateway = new FakePaymentGateway();
        orderService = new OrderService(paymentGateway);
    }
}
```

픽스처가 커지면 테스트 하나를 읽기 위해 머릿속에 외워야 할 상태가 늘어난다. 공통화보다 가독성이 우선이다.

### 외부 픽스처

DB·파일 같은 외부 자원. `@BeforeAll` + tearDown 으로 비용 분산.

주의: 외부 픽스처는 빠른 단위 테스트를 느리게 만든다. DB가 필요하면 `@DataJpaTest`처럼 범위를 좁히고, 순수 도메인 규칙은 POJO 테스트로 남긴다.

### 테스트 메서드

`@Test` 한 개 = 한 시나리오 = 한 동작.

```java
@Test
void 초대권이_있으면_티켓_가격을_내지_않는다() {
    // given
    Audience audience = Audience.withInvitation();
    Ticket ticket = new Ticket(10_000L);

    // when
    long paid = audience.buy(ticket);

    // then
    assertThat(paid).isZero();
}
```

### 예외 테스트

예외 발생 자체를 검증. `assertThrows()` / `assertThatThrownBy()`.

예외 테스트는 “에러가 난다”가 아니라 “이 입력은 계약 위반이다”를 문서화한다.

### 전체 테스트

CI 에서 **모든 테스트 매번 실행**. 부분 실행은 신뢰 깨짐.

```bash
./mvnw test
```

빠른 단위 테스트가 느린 통합 테스트에 묻히면 자주 실행하지 않게 된다. 초보 단계에서는 `src/test/java`에 빠른 테스트를 먼저 충분히 쌓는 편이 좋다.

## 체크리스트

- [ ] 단언 실패 메시지가 원인을 바로 말하는가
- [ ] 픽스처가 테스트 의도를 가리지 않는가
- [ ] 테스트 하나가 한 동작만 검증하는가
- [ ] 예외 테스트가 계약 위반을 문서화하는가
- [ ] 전체 테스트를 한 명령으로 실행할 수 있는가

## 퀴즈

**Q1. 픽스처를 너무 크게 만들면 왜 초보자에게 특히 위험한가?**

**A.** 테스트 본문 밖의 상태를 많이 기억해야 해서, 실패 원인을 추적하기 어렵다. 공통화보다 테스트 본문의 명확성이 우선이다.

**Q2. 예외 테스트가 주는 설계 인사이트는?**

**A.** 정상 흐름뿐 아니라 “받지 않을 입력”도 객체의 계약이다. 예외 테스트는 그 계약을 실행 가능한 문서로 만든다.

---

## 다음 장 예고 — 30장: 디자인 패턴

TDD 가 어떤 GoF 패턴을 자연스럽게 끌어내는지.
