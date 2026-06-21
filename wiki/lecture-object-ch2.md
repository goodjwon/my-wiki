---
title: "오브젝트 실전 강의 — 2장"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 2장.md]
created: 2026-06-21
updated: 2026-06-21
---

# 오브젝트 실전 강의 교재

## 2장 — 객체지향 프로그래밍

> **원서**: 조영호 『오브젝트: 코드로 이해하는 객체지향 설계』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 코드 → 핵심 교훈 → 현업 예제 → 함정 → 체크리스트 → 퀴즈(정답 분리) **전제 환경**: Java 17+

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 도메인 개념을 클래스로 옮기고, **협력하는 객체들**로 시스템을 구성한다.
- **상속·다형성·추상화**로 변경에 유연한 설계를 만든다.
- **컴파일타임 의존성과 런타임 의존성의 분리**가 유연성의 비결임을 이해한다.

### 0.2 큰 그림 — 협력의 사슬

영화 예매에서 객체들은 메시지를 주고받으며 협력합니다.

```
Screening(상영) ──"예매해줘"──▶ Movie(영화) ──"할인액 계산해줘"──▶ DiscountPolicy(할인 정책)
                                                                       └─"조건 맞아?"─▶ DiscountCondition
```

각 객체는 자기 책임만 수행하고, 다음 객체에게 **메시지**로 위임합니다.

> **비유 — "극단의 공연"**: `DiscountPolicy`는 "할인 정책"이라는 **배역(역할)**입니다. 금액 할인·비율 할인이라는 **배우(구체 클래스)**가 그 배역을 연기합니다. 대본(코드)에는 "할인 정책"이라고만 적혀 있고, 공연(실행)마다 어떤 배우가 무대에 설지가 정해집니다.

### 0.3 현업에서 왜 중요한가

- 할인 정책의 다형성 구조는 그대로 **전략 패턴 + Spring 의존성 주입**입니다.
- "Movie가 추상(DiscountPolicy)에 의존하고, 구체 정책은 외부에서 주입"이 곧 DI의 본질입니다.

---

## 1. 영화 예매 시스템 — 요구사항 요약

- **영화(Movie)**: 제목·상영시간·기본 요금·할인 정책을 가진다.
- **상영(Screening)**: 특정 영화를 언제·몇 회차로 트는지. 예매의 단위.
- **예매(Reservation)**: 누가·어떤 상영을·몇 명·얼마에 예매했는지.
- **할인**: 정책(할인 방식: 금액/비율)과 조건(언제 할인되나: 순번/기간)으로 결정. 영화당 정책은 하나, 조건은 여러 개.

---

## 2. 객체지향을 향해 — 협력하는 자율적 객체들

### 비유 — "각자 자기 일만, 내부는 비공개"

1장의 교훈을 잇습니다. 각 객체는 **private 데이터 + public 메서드(메시지)**로, 자기 일을 스스로 처리하고 내부는 감춥니다.

```java
// 값 객체 (불변) — 요금 (이펙티브 자바 17, TDD 2장 Money와 같은 흐름)
public class Money {
    public static final Money ZERO = Money.wons(0);
    private final BigDecimal amount;

    public static Money wons(long amount) { return new Money(BigDecimal.valueOf(amount)); }
    private Money(BigDecimal amount) { this.amount = amount; }
    public Money plus(Money other)  { return new Money(amount.add(other.amount)); }
    public Money minus(Money other) { return new Money(amount.subtract(other.amount)); }
    public Money times(double pct)  { return new Money(amount.multiply(BigDecimal.valueOf(pct))); }
    public boolean isLessThan(Money other) { return amount.compareTo(other.amount) < 0; }
}
```

```java
// 상영: 자신이 아는 것(영화, 순번, 시간)으로 예매를 만든다
public class Screening {
    private Movie movie;
    private int sequence;
    private LocalDateTime whenScreened;

    public Reservation reserve(Customer customer, int audienceCount) {
        return new Reservation(customer, this, calculateFee(audienceCount), audienceCount);
    }
    private Money calculateFee(int audienceCount) {
        return movie.calculateMovieFee(this).times(audienceCount);  // 영화에게 위임(메시지)
    }
    // sequence/whenScreened는 묻는 메서드만 제공(필요한 만큼만 노출)
    public boolean isSequence(int sequence) { return this.sequence == sequence; }
    public LocalDateTime getWhenScreened() { return whenScreened; }
}
```

`Screening`은 요금을 **직접 계산하지 않습니다.** "이 상영의 요금이 얼마냐"를 `Movie`에게 물을 뿐(`calculateMovieFee`). 책임이 제자리에 있습니다.

---

## 3. 할인 요금 구하기 — 정책과 조건

### 3.1 할인 정책: 추상 클래스 + 템플릿 메서드

할인 정책들의 **공통 흐름**(조건을 만족하면 할인, 아니면 0원)은 부모가, **구체적 할인 계산**은 자식이 맡습니다.

```java
// 추상 클래스: 공통 알고리즘 골격(TEMPLATE METHOD)
public abstract class DiscountPolicy {
    private List<DiscountCondition> conditions = new ArrayList<>();
    public DiscountPolicy(DiscountCondition... conditions) {
        this.conditions = Arrays.asList(conditions);
    }
    // 골격: 조건 중 하나라도 만족하면 할인액 계산을 자식에게 위임
    public Money calculateDiscountAmount(Screening screening) {
        for (DiscountCondition each : conditions) {
            if (each.isSatisfiedBy(screening)) {
                return getDiscountAmount(screening);   // 빈칸 → 자식이 채움
            }
        }
        return Money.ZERO;
    }
    protected abstract Money getDiscountAmount(Screening screening);  // 자식이 구현
}
```

```java
// 금액 할인: 정해진 금액만큼
public class AmountDiscountPolicy extends DiscountPolicy {
    private Money discountAmount;
    public AmountDiscountPolicy(Money amount, DiscountCondition... cs) { super(cs); this.discountAmount = amount; }
    @Override protected Money getDiscountAmount(Screening s) { return discountAmount; }
}
// 비율 할인: 기본 요금의 N%
public class PercentDiscountPolicy extends DiscountPolicy {
    private double percent;
    public PercentDiscountPolicy(double percent, DiscountCondition... cs) { super(cs); this.percent = percent; }
    @Override protected Money getDiscountAmount(Screening s) { return s.getMovieFee().times(percent); }
}
```

### 3.2 할인 조건: 인터페이스로 역할 정의

```java
public interface DiscountCondition {
    boolean isSatisfiedBy(Screening screening);
}
// 순번 조건: 특정 회차
public class SequenceCondition implements DiscountCondition {
    private int sequence;
    public SequenceCondition(int sequence) { this.sequence = sequence; }
    @Override public boolean isSatisfiedBy(Screening s) { return s.isSequence(sequence); }
}
// 기간 조건: 특정 요일·시간대
public class PeriodCondition implements DiscountCondition {
    private DayOfWeek dayOfWeek; private LocalTime start, end;
    @Override public boolean isSatisfiedBy(Screening s) {
        return s.getWhenScreened().getDayOfWeek().equals(dayOfWeek)
            && !s.getWhenScreened().toLocalTime().isBefore(start)
            && !s.getWhenScreened().toLocalTime().isAfter(end);
    }
}
```

### 3.3 Movie는 추상에만 의존한다

```java
public class Movie {
    private String title;
    private Money fee;
    private DiscountPolicy discountPolicy;   // 구체가 아니라 '추상'에 의존!

    public Money calculateMovieFee(Screening screening) {
        return fee.minus(discountPolicy.calculateDiscountAmount(screening));
    }
}
```

---

## 4. 상속과 다형성

### 4.1 컴파일타임 의존성 ≠ 런타임 의존성 (유연성의 비결)

- **코드(컴파일타임)**에서 `Movie`는 추상 클래스 `DiscountPolicy`만 압니다.
- **실행(런타임)**에는 `AmountDiscountPolicy`나 `PercentDiscountPolicy` **인스턴스와 협력**합니다.

```java
// 어떤 정책과 협력할지는 '생성 시점에' 외부에서 결정 → 코드를 바꾸지 않고 행동을 바꾼다
Movie avatar = new Movie("아바타", Money.wons(10000),
        new AmountDiscountPolicy(Money.wons(800),
                new SequenceCondition(1), new PeriodCondition(DayOfWeek.MONDAY, ...)));
```

> **비유 다시**: 대본엔 "할인 정책"이라고만(컴파일타임), 공연마다 다른 배우가 무대에(런타임). **이 둘의 거리가 멀수록 유연**하지만, 코드는 이해하기 어려워집니다(트레이드오프).

### 4.2 다형성 — 같은 메시지, 다른 메서드

`Movie`는 `discountPolicy.calculateDiscountAmount(...)`라는 **같은 메시지**를 보내지만, 실제 실행되는 메서드는 런타임 객체에 따라 다릅니다(**동적 바인딩**). `Movie`는 누가 응답하는지 몰라도 됩니다.

### 4.3 차이에 의한 프로그래밍

새 정책은 부모(`DiscountPolicy`)와 **다른 부분만** 채워 추가합니다(`getDiscountAmount`만 구현). 공통 흐름은 재사용합니다.

---

## 5. 추상화와 유연성

### 5.1 추상화의 힘 — 새 정책 추가가 쉽다

"할인 없음" 정책이 필요해지면? 기존 코드를 건드리지 않고 클래스 하나만 추가합니다.

```java
public class NoneDiscountPolicy extends DiscountPolicy {
    @Override protected Money getDiscountAmount(Screening s) { return Money.ZERO; }
}
```

`Movie`도, 다른 정책도 그대로입니다(**개방-폐쇄 원칙**: 확장에 열림, 수정에 닫힘).

### 5.2 추상 클래스 vs 인터페이스 (트레이드오프)

- 추상 클래스: 공통 **구현(상태·골격)**을 물려줄 때. 단일 상속 제약.
- 인터페이스: 순수한 **역할(계약)**만 정의할 때. 다중 구현 가능.
- `DiscountPolicy`는 공통 알고리즘 골격이 있어 추상 클래스가, `DiscountCondition`은 역할만 있어 인터페이스가 적절했습니다.

> **이펙티브 자바 연결**: 아이템 20(인터페이스 우선) + 골격 구현. 책임이 "구현 공유"냐 "역할 정의"냐로 선택이 갈립니다.

### 5.3 코드 재사용 — 상속보다 합성

`Movie`는 `DiscountPolicy`를 **상속하지 않고 포함(합성)**합니다. 그래서 실행 중에 정책을 갈아 끼울 수 있고, 부모 구현 변경에 취약하지 않습니다.

```java
// 합성(has-a): Movie가 DiscountPolicy를 '가진다'
private DiscountPolicy discountPolicy;
```

> **교차 연결**: 이펙티브 자바 18(상속보다 컴포지션), 리팩터링 11장(합성으로 변경), 그리고 오브젝트 11장에서 본격적으로 다룹니다.

---

## 핵심 교훈

1. 도메인 개념을 클래스로, 시스템을 **협력하는 자율적 객체들**로 구성한다.
2. `Movie`는 **추상(DiscountPolicy)에 의존**하고, 구체 정책은 외부에서 주입 → 유연.
3. **컴파일타임 의존성과 런타임 의존성을 분리**하는 것이 다형성·유연성의 핵심.
4. 공통 흐름은 추상(템플릿 메서드)으로, 차이는 자식으로(차이에 의한 프로그래밍).
5. 재사용은 **상속보다 합성**. 역할은 인터페이스, 공통 구현은 추상 클래스.

---

## 현업 예제 — 이것이 곧 전략 패턴 + Spring DI

```java
// 전략(정책)을 인터페이스/추상으로 정의하고, 구현을 주입받는다 = 2장의 구조 그대로
@Service
public class PricingService {
    private final DiscountPolicy discountPolicy;   // 추상에 의존
    public PricingService(DiscountPolicy discountPolicy) {  // 생성자 주입
        this.discountPolicy = discountPolicy;
    }
}
// 운영에선 @Primary/@Qualifier로 구체 정책 선택, 테스트에선 가짜 정책 주입
```

> Movie ↔ DiscountPolicy 관계가 그대로 Spring의 "추상 의존 + 구체 주입"입니다. 이펙티브 자바 5(의존성 주입)와 같은 그림.

---

## 함정 / 주의

- **유연성은 공짜가 아니다.** 컴파일타임/런타임 의존성이 멀어질수록 코드 추적이 어려워집니다. 변경 압력이 있을 때만 추상화하세요(9장 "유연성은 필요할 때만").
- **추상 클래스 vs 인터페이스를 습관으로 고르지 마라.** "구현 공유가 필요한가, 역할만 필요한가"로 판단.
- 템플릿 메서드의 `protected` 추상 메서드는 **상속 계약**입니다. 함부로 늘리면 자식이 깨집니다(EJ 19).

---

## 체크리스트 (설계 리뷰용)

- [ ] 각 객체가 자기 책임만 수행하고 나머지는 **메시지로 위임**하는가
- [ ] 핵심 클래스가 **구체가 아닌 추상**에 의존하는가
- [ ] 구체 구현을 **외부에서 주입**받는가(컴파일/런타임 의존성 분리)
- [ ] 새 종류 추가가 **기존 코드 수정 없이** 가능한가(OCP)
- [ ] 재사용에 상속 대신 **합성**을 우선 고려했는가
- [ ] 추상 클래스/인터페이스 선택이 "구현 공유 vs 역할"로 정당한가

---

## 퀴즈

1. `Movie`가 구체 정책이 아니라 추상 `DiscountPolicy`에 의존하면 무엇이 좋아지는가?
2. "컴파일타임 의존성과 런타임 의존성이 다르다"를 영화 예매 예로 설명하라.
3. `DiscountPolicy`는 추상 클래스, `DiscountCondition`은 인터페이스로 한 이유는?
4. "할인 없음" 정책 추가가 기존 코드를 건드리지 않는 이유는 어떤 원칙인가?
5. 이 장의 구조가 Spring의 무엇과 같은가?

### 정답·해설

1. `Movie`를 수정하지 않고 **정책을 갈아 끼울 수 있습니다.** 구체 정책에 대한 의존이 사라져 결합도가 낮아지고, 새 정책 추가·테스트 대체가 쉬워집니다.
2. 코드에서 `Movie`는 추상 `DiscountPolicy`만 알지만(컴파일타임), 실행 중에는 `AmountDiscountPolicy` 같은 **구체 인스턴스와 협력**합니다(런타임). 이 분리가 유연성을 만듭니다.
3. `DiscountPolicy`는 "조건 만족 시 할인" 같은 **공통 알고리즘 골격(구현)**을 물려주므로 추상 클래스가, `DiscountCondition`은 "만족하는가?"라는 **역할(계약)**만 정의하므로 인터페이스가 적절합니다.
4. **개방-폐쇄 원칙(OCP)**. 추상에 의존하므로, 새 구현(클래스)을 추가하기만 하면 되고 기존 코드는 수정하지 않습니다.
5. **전략 패턴 + 의존성 주입.** 추상에 의존하고 구체 구현을 외부에서 주입받는 구조로, 이펙티브 자바 아이템 5와 같은 그림입니다.

---

## 다음 장 예고 — 3장: 역할, 책임, 협력

2장에서 코드로 만든 구조를, 더 근본 개념인 **협력·책임·역할**의 관점에서 재정리합니다. "메시지가 객체를 결정한다", "행동이 상태를 결정한다", "역할은 대체 가능한 배역"이라는, 객체지향 설계의 사고 틀을 다룹니다.