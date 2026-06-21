---
title: "오브젝트 실전 강의 — 5장"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 5장.md]
created: 2026-06-21
updated: 2026-06-21
---

# 오브젝트 실전 강의 교재

## 5장 — 책임 할당하기

> **원서**: 조영호 『오브젝트』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 → 핵심 교훈 → 현업 예제 → 함정 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- **데이터보다 행동을 먼저** 결정한다 (4장 데이터 중심의 반대).
- **협력이라는 문맥** 안에서 책임을 결정한다.
- **GRASP 패턴** (정보 전문가·창조자·낮은 결합도·높은 응집도·다형성·변경 보호) 으로 책임 할당.
- 영화 예매 시스템을 **책임 주도 설계로 다시** 짜며 4장과 비교.

### 0.2 큰 그림 — 책임 주도 설계 (RDD) 의 사고 순서

```
1. 도메인 개념 (목록) → 후보 객체
2. 메시지 흐름 (협력) → 누가 누구에게 요청
3. 책임 할당 (GRASP)  → 그 행동은 누가 가장 잘 알까
4. 객체 (클래스) 도출  → 책임을 묶어 클래스로
```

> **비유 — "공연 무대"** (3장 회고): 협력 (공연 흐름) 이 먼저, 그 안에서 배역 (책임) 이 결정, 그 배역을 맡을 배우 (객체) 가 캐스팅. 처음부터 배우 (객체) 부터 캐스팅하지 않음.

### 0.3 현업에서 왜 중요한가

- 클래스부터 그리는 신입의 흔한 실수 — RDD 가 그 정반대.
- GRASP 9 패턴이 코드 리뷰의 객관적 어휘 (특히 정보 전문가·낮은 결합도).
- *오브젝트* 의 가장 자주 인용되는 장.

---

## 1. 책임 주도 설계를 향해

### 1.1 데이터보다 행동을 먼저 결정하라

4장의 사고:
1. Movie 의 필드는? (`title`, `fee`, `discountConditions`...)
2. Movie 의 getter/setter
3. 행동은 외부 Service 에

5장의 사고:
1. 영화 예매에 필요한 **행동** 은? (요금 계산, 할인 적용, 예매 생성)
2. 그 행동을 **누가 가장 잘 알까** ?
3. 그 객체에 **필요한 데이터만** 넣는다

→ 행동 → 책임 → 데이터의 **거꾸로** 사고.

### 1.2 협력이라는 문맥 안에서 책임을 결정하라

객체의 책임은 **혼자 결정하지 않음**. 어떤 협력 (요청-응답 흐름) 에 참여하느냐에 따라 결정.

3장 복습: `Screening` 이 혼자 요금 못 구하니 `Movie` 에게 요청 → `Movie` 의 책임이 "**요금 계산**" 으로 결정.

---

## 2. 책임 할당을 위한 GRASP 패턴 (9개)

### 2.1 도메인 개념에서 출발하기

도메인 단어 (영화·상영·예매·할인 정책·할인 조건·고객) 를 먼저 종이에 적기. 그 단어들이 **후보 객체**.

### 2.2 정보 전문가 (Information Expert) — 가장 자주 쓰는 패턴

> "**필요한 정보를 가장 많이 알고 있는 객체에게 책임을 할당**".

영화 예매:
- "요금 계산" 책임 → 요금 정보를 가진 **Movie** 에게.
- "할인 적용" 책임 → 할인 정책을 아는 **DiscountPolicy** 에게.
- "조건 만족 검사" 책임 → 조건 데이터를 가진 **DiscountCondition** 에게.

→ 정보가 있는 곳에 책임 — 데이터를 외부로 꺼내 처리하지 마라 (Tell, Don't Ask).

### 2.3 창조자 (Creator)

> "**A 가 B 를 생성한다면, A 는** (1) B 를 가지거나 (2) B 와 밀접하거나 (3) B 의 정보를 가진 경우**".

영화 예매:
- `Screening` 이 `Reservation` 생성 (Screening 이 Reservation 정보 다 알고, 1:1 관계).

### 2.4 낮은 결합도 (Low Coupling)

> "**책임 할당 시 결합도가 낮은 쪽** 을 선택".

여러 책임 할당 후보가 있으면 **이미 의존 관계가 있는 쪽** 또는 **새 의존을 안 만드는 쪽** 선택.

### 2.5 높은 응집도 (High Cohesion)

> "**관련된 책임끼리 한 객체에** 모아 응집도를 높여라".

Movie 가 "요금 계산" + "할인 조건 평가" 둘 다 가지면 응집도는 좋지만 응집도가 떨어지면 분리 (`DiscountPolicy`·`DiscountCondition`).

### 2.6 다형성 (Polymorphism)

> "**타입에 따른 분기는 다형성으로**".

`switch (movieType)` → `DiscountPolicy` 인터페이스 + `AmountDiscountPolicy`·`PercentDiscountPolicy` 구현. 새 정책 = 새 클래스 1개.

### 2.7 순수 가공물 (Pure Fabrication)

> "**도메인 개념이 아닌 인위적 객체** 도 책임 할당에 정당".

예: `OrderRepository`·`DiscountCalculator` 같은 인프라/유틸 클래스. 도메인에는 없지만 책임 분리·재사용을 위해.

### 2.8 간접화 (Indirection)

> "**중개 객체** 를 통해 결합도를 낮춤".

예: A 가 직접 B 를 부르는 대신 A → C → B. C 가 중개.

### 2.9 변경 보호 (Protected Variations)

> "**변경 가능성이 높은 부분 주변에 안정된 인터페이스** 를 둠".

`DiscountPolicy` 인터페이스가 정책 변경의 영향을 막아주는 방어막.

---

## 3. 구현을 통한 검증 — 영화 예매 다시 짜기

### 3.1 DiscountCondition 개선하기 (정보 전문가)

```java
public interface DiscountCondition {
    boolean isSatisfiedBy(Screening screening);
}

public class SequenceCondition implements DiscountCondition {
    private final int sequence;
    public SequenceCondition(int sequence) { this.sequence = sequence; }

    @Override
    public boolean isSatisfiedBy(Screening screening) {
        return screening.isSequence(sequence);   // ← Screening 이 자기 시퀀스 안다 (정보 전문가)
    }
}

public class PeriodCondition implements DiscountCondition {
    private final DayOfWeek dayOfWeek;
    private final LocalTime startTime, endTime;

    @Override
    public boolean isSatisfiedBy(Screening screening) {
        return screening.getWhenScreened().getDayOfWeek().equals(dayOfWeek)
            && startTime.compareTo(screening.getWhenScreened().toLocalTime()) <= 0
            && endTime.compareTo(screening.getWhenScreened().toLocalTime()) >= 0;
    }
}
```

→ 조건이 자기 데이터를 가지고 자기 판단. **Screening 에게 묻기만 함** (Tell, Don't Ask).

### 3.2 타입 분리 + 다형성

```java
public abstract class DiscountPolicy {
    private final List<DiscountCondition> conditions;

    protected DiscountPolicy(DiscountCondition... conditions) {
        this.conditions = Arrays.asList(conditions);
    }

    public Money calculateDiscountAmount(Screening screening) {
        for (DiscountCondition condition : conditions) {
            if (condition.isSatisfiedBy(screening)) {
                return getDiscountAmount(screening);   // 템플릿 메서드
            }
        }
        return Money.ZERO;
    }

    protected abstract Money getDiscountAmount(Screening screening);
}

public class AmountDiscountPolicy extends DiscountPolicy {
    private final Money discountAmount;
    @Override protected Money getDiscountAmount(Screening screening) {
        return discountAmount;
    }
}

public class PercentDiscountPolicy extends DiscountPolicy {
    private final double percent;
    @Override protected Money getDiscountAmount(Screening screening) {
        return screening.getMovieFee().times(percent);
    }
}
```

→ 4장의 switch 분기가 다형성으로. 새 정책 = 새 클래스 1개 (OCP).

### 3.3 Movie 클래스 개선하기

```java
public class Movie {
    private final String title;
    private final Money fee;
    private final DiscountPolicy discountPolicy;   // ← 추상 의존

    public Movie(String title, Money fee, DiscountPolicy policy) { ... }

    public Money calculateMovieFee(Screening screening) {
        return fee.minus(discountPolicy.calculateDiscountAmount(screening));
    }
}
```

→ Movie 가 정책 종류를 모름 (`movieType` enum 사라짐). 추상 `DiscountPolicy` 에만 의존.

### 3.4 변경으로부터 보호 — OCP 충족

새 할인 정책 (예: "회원 등급별") 추가?
```java
public class MembershipDiscountPolicy extends DiscountPolicy {
    @Override protected Money getDiscountAmount(Screening screening) {
        // 회원 등급별 할인
    }
}
```

→ Movie·DiscountCondition·기존 정책 클래스 **무변경**. OCP.

---

## 4. 책임 주도 설계의 대안

### 4.1 메서드 응집도

한 메서드가 너무 많은 일 → 작은 메서드로 분리 → 응집도 ↑.

### 4.2 객체를 자율적으로 만들자

데이터를 묻지 말고 행동을 시켜라 (Tell, Don't Ask). 객체가 자기 결정을 자기 안에서.

---

## 핵심 교훈

1. **행동·책임 먼저, 데이터 나중**. 객체가 자기 데이터를 책임진다.
2. **GRASP** = 책임 할당의 사고 도구 — 정보 전문가·창조자·낮은 결합·높은 응집·다형성·순수 가공물·간접화·변경 보호.
3. **정보 전문가** 가 가장 자주 쓰는 패턴 — 정보 가진 곳에 책임.
4. **타입 코드 + switch = 다형성 신호** (`DiscountPolicy` 인터페이스 + 자식 클래스).
5. **추상 의존** 이 OCP 충족 — 새 구현 추가에 기존 코드 무변경.
6. **협력이 책임 결정의 문맥** — 객체 단독으로 책임 정할 수 없음.

---

## 현업 예제 — Spring 의 책임 주도 설계

### 결제 처리

```java
// 정보 전문가 — Payment 가 자기 검증·승인 결정
@Entity
public class Payment {
    public void approve() {
        if (status != PENDING) throw new IllegalStateException();
        // 자기 데이터로 자기 결정
        this.status = APPROVED;
        registerEvent(new PaymentApprovedEvent(id));
    }
}

// 다형성 — 결제 수단별 정책
public interface PaymentProcessor {
    PaymentResult process(PaymentRequest req);
}

public class CardPaymentProcessor implements PaymentProcessor { ... }
public class VirtualAccountProcessor implements PaymentProcessor { ... }
```

→ 새 결제 수단 = 새 PaymentProcessor 구현. Payment·기존 processor 무변경.

---

## 함정 / 주의

- **GRASP 9 패턴 외우기 X — 사고 도구**. 매번 펼쳐서 적용 후보로.
- **정보 전문가 도그마** 위험 — 정보 가진 객체가 너무 비대해지면 분리 (높은 응집도와 균형).
- **순수 가공물 남발** = 도메인이 빈약해질 위험. Service·Repository·Calculator 폭증 시 의심.
- **다형성을 위한 인터페이스 도입** 도 과하면 추측성 일반화 ([[entity-refactoring]] 3.15).

---

## 체크리스트 (책임 할당 리뷰용)

- [ ] 행동 (메서드) 부터 결정한 뒤 데이터를 정했는가
- [ ] 책임 할당이 정보 전문가에 가까운가
- [ ] 타입 코드 (`switch`) 대신 다형성을 썼는가
- [ ] 추상 의존인가 (`DiscountPolicy` interface) — 구체 의존 (`AmountDiscountPolicy`) 인가
- [ ] 새 정책·새 타입 추가 시 기존 코드 무변경 가능한가 (OCP)

---

## 퀴즈

1. **GRASP 의 정보 전문가** 패턴을 한 문장으로?
2. 4장 데이터 중심 설계와 5장 책임 중심 설계의 **사고 순서** 차이는?
3. switch (movieType) 을 다형성으로 바꾼 직접 효과는?
4. Movie 가 추상 `DiscountPolicy` 에 의존하면 어떤 SOLID 원칙 충족?
5. GRASP 의 **순수 가공물** 이 도메인 객체 아닌 이유?

### 정답·해설

1. **필요한 정보를 가장 많이 가진 객체에게 그 정보로 할 일을 책임지운다**. Movie 가 fee 정보 → 요금 계산 책임. Tell, Don't Ask 의 정형화.
2. **데이터 중심**: 필드 → getter/setter → 외부 Service 가 결정. **책임 중심**: 행동 → 책임 → 그 책임 가진 객체 → 필요 데이터. 정반대 방향.
3. **새 정책 추가가 한 클래스 추가로 끝남**. switch 는 모든 위치 찾아 수정 (산탄총 수술), 다형성은 새 클래스 = `extends DiscountPolicy` 만. OCP 충족.
4. **OCP (개방-폐쇄)** + **DIP (의존성 역전)**. 기존 코드 변경 없이 새 정책 추가 (OCP). 구체 의존이 아니라 추상 의존 (DIP).
5. **도메인 단어가 아니지만 책임 분리·재사용을 위해 인위적으로 만든 객체**. `OrderRepository`·`PriceCalculator` 같은 인프라/유틸. 도메인 단어에만 묶이면 책임 할당이 어려운 경우의 도구.

---

## 다음 장 예고 — 6장: 메시지와 인터페이스

5장에서 객체 사이 협력을 다뤘다면, 6장은 그 협력의 **언어** — 메시지·인터페이스. **묻지 말고 시켜라 (Tell, Don't Ask)**, **의도를 드러내는 인터페이스**, **디미터 법칙**, **명령-쿼리 분리** 의 OO 격언들.
