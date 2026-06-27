---
title: "오브젝트 실전 강의 — 12장"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 12장.md]
created: 2026-06-21
updated: 2026-06-27
---

# 오브젝트 실전 강의 교재

## 12장 — 다형성

> **원서**: 조영호 『오브젝트』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 → 핵심 교훈 → 현업 예제 → 함정 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- **다형성의 메커니즘** — 업캐스팅·동적 바인딩.
- **메서드 위임** — 같은 메시지에 객체별 다른 응답.
- **self vs super** — 메서드 탐색의 시작점 차이.
- **상속과 위임 (delegation)** 의 관계.

### 0.2 큰 그림 — 다형성의 4 단계

```
1. 같은 메시지 (호출 코드)
   ↓
2. 정적 타입 (컴파일러가 알기)
   ↓
3. 업캐스팅 (자식 → 부모 타입 자동 변환)
   ↓
4. 동적 바인딩 (런타임에 실제 객체의 메서드 호출)
```

> **비유 — "전화 한 통, 받는 사람마다 다른 대응"**
>
> 똑같이 "할인 적용해줘"라고 전화를 걸어도, 받는 사람이 누구냐에 따라 대응이 달라집니다. 어떤 직원은 정해진 금액만큼 깎아 주고, 어떤 직원은 비율로 깎아 주며, 또 어떤 직원은 회원 등급을 따져 깎아 줍니다. 거는 사람은 누가 전화를 받을지 알지 못한 채 똑같은 말만 건넵니다.
>
> 객체지향의 다형성도 같은 구조입니다. 똑같은 전화가 메시지에 해당하고, 전화를 받는 직원들이 amount·percent·membership 정책 객체에 해당합니다. 호출자는 같은 메시지를 보낼 뿐, 실제로 어떤 객체가 응답할지는 런타임에 결정됩니다.

### 0.3 현업에서 왜 중요한가

- 다형성의 메커니즘 (업캐스팅·동적 바인딩) 을 모르면 OO 가 마법으로 보임.
- Spring AOP·프록시·동적 디스패치 모두 같은 원리.
- 의도하지 않은 메서드 호출 (`super` 함정 등) 진단에 필수.

---

## 1. 다형성이란

다형성 = **같은 메시지에 객체별 다른 응답**. 그리스어 "여러 (poly) 모양 (morphos)".

종류:
- **포함 다형성 (Subtype)**: 상속·인터페이스 — 12장 주제.
- **매개변수 다형성**: 제네릭.
- **임시 다형성**: 오버로딩 (같은 이름 다른 시그니처).
- **강제 다형성**: 형변환.

→ OO 의 다형성 = 포함 다형성 (subtype polymorphism).

---

## 2. 상속의 양면성

### 2.1 데이터 관점의 상속

자식 객체 = 부모 필드 + 자식 필드 묶음. 자식 인스턴스 안에 부모 데이터 영역 포함.

### 2.2 행동 관점의 상속

자식이 부모의 메서드 사용. 자식이 오버라이드한 메서드는 자식 것, 안 한 메서드는 부모 것.

→ 행동 관점이 다형성의 핵심.

---

## 3. 업캐스팅과 동적 바인딩

### 3.1 같은 메시지, 다른 메서드

```java
DiscountPolicy policy = new AmountDiscountPolicy(...);   // 업캐스팅
policy.calculateDiscountAmount(screening);   // 컴파일타임: DiscountPolicy.calculateDiscountAmount
                                              // 런타임: AmountDiscountPolicy.calculateDiscountAmount
```

### 3.2 업캐스팅 (Upcasting)

> **자식 타입 → 부모 타입으로 자동 변환**. 안전 (자식은 부모의 모든 멤버 가짐).

```java
DiscountPolicy p = new AmountDiscountPolicy();   // OK
```

다운캐스팅 (부모 → 자식) 은 명시적 + 위험:
```java
AmountDiscountPolicy a = (AmountDiscountPolicy) p;   // 런타임 ClassCastException 위험
```

### 3.3 동적 바인딩 (Dynamic Binding)

> **런타임에 실제 객체의 메서드를 결정**. 정적 타입이 아니라 실제 타입 기준.

자바 메서드 호출 = 거의 모두 동적 바인딩. 예외: `static`·`final`·`private` 메서드.

---

## 4. 동적 메서드 탐색과 다형성

### 4.1 자동적인 메시지 위임

객체가 받은 메시지에 메서드가 없으면 부모로 위임:

```java
public class Phone {
    public Money calculate() { ... }
}

public class NightlyDiscountPhone extends Phone {
    // calculate 오버라이드 X
}

new NightlyDiscountPhone().calculate();   // → 자식에 없으니 부모 calculate 호출 (자동 위임)
```

### 4.2 동적인 문맥

탐색 순서:
1. 메시지 받은 객체의 **실제 클래스** 에서 메서드 찾기.
2. 없으면 **부모 클래스** 로.
3. 없으면 부모의 부모로... `Object` 까지.
4. 끝까지 없으면 `NoSuchMethodError`.

### 4.3 이해할 수 없는 메시지

자바는 컴파일타임에 거의 다 잡음. 동적 언어 (Smalltalk·Ruby) 는 런타임 `doesNotUnderstand`.

### 4.4 self vs super

- `this` (`self`) : 메서드 탐색의 시작점 = **실제 객체의 클래스**.
- `super` : 메서드 탐색의 시작점 = **부모 클래스**.

```java
public class Parent {
    public void greet() { System.out.println("Parent"); }
}

public class Child extends Parent {
    @Override
    public void greet() {
        super.greet();   // 부모 호출 (탐색 시작점 = Parent)
        System.out.println("Child");
    }
}

new Child().greet();
// Parent
// Child
```

---

## 5. 상속 대 위임

### 5.1 위임과 self 참조

자바 상속의 메서드 호출 = 본질적으로 self 참조의 자동 위임.

```java
public class Phone {
    public Money calculate() {
        return getRate().times(seconds);   // this.getRate() — self 참조
    }
    protected Money getRate() { return regularRate; }
}

public class NightlyPhone extends Phone {
    @Override
    protected Money getRate() {
        if (isNight()) return nightRate;
        return super.getRate();
    }
}

new NightlyPhone().calculate();
// Phone.calculate() 의 getRate() 가 NightlyPhone.getRate() 로 위임 (self = NightlyPhone)
```

→ 상속의 본질 = self 참조 + 동적 위임.

### 5.2 프로토타입 기반의 객체지향 언어

JavaScript 같은 프로토타입 언어:
- 클래스 없음
- 객체 → 객체로 직접 위임 (prototype chain)
- 더 동적

자바 같은 클래스 기반 = 위임이 클래스 계층으로 정형화.

---

## 핵심 교훈

1. **다형성** = 같은 메시지에 객체별 다른 응답.
2. **업캐스팅 + 동적 바인딩** = 다형성의 메커니즘.
3. **메서드 탐색** = 실제 객체 → 부모 → ... → Object. 없으면 NoSuchMethodError.
4. **self vs super** — 탐색 시작점. self 가 다형성, super 가 부모 명시.
5. **상속의 본질** = self 참조의 동적 위임.

---

## 현업 예제 — Spring 의 다형성

### 인터페이스 다형성

```java
public interface NotificationSender {
    void send(Notification n);
}

public class EmailSender implements NotificationSender { ... }
public class SmsSender implements NotificationSender { ... }

@Service
public class NotificationService {
    private final List<NotificationSender> senders;   // 다형성 컬렉션

    public void notifyAll(Notification n) {
        senders.forEach(s -> s.send(n));   // 다형 dispatch
    }
}
```

→ Spring 이 모든 `NotificationSender` 구현체 자동 주입. 새 sender = 새 클래스 1개.

### AOP 프록시 다형성

Spring AOP 가 `@Transactional` 메서드를 프록시로 감싸 트랜잭션 관리. 호출자는 원본 객체와 프록시를 구분 못 함 (다형성).

---

## 함정 / 주의

- **`super.method()` 함정** — 부모 메서드 변경에 자식 영향. *Effective Java* Item 18 의 InstrumentedHashSet 사례.
- **`private` / `static` / `final` 메서드** = 동적 바인딩 X — 오버라이드 불가.
- **다운캐스팅 남발** = OO 의 신호 — 다형성 활용 의심.
- **`instanceof` + 분기** = 다형성 회피 신호 → 다형성으로 옮기기 ([[entity-refactoring]] 10.4).

---

## 체크리스트

- [ ] 메시지 수신자가 인터페이스 (추상) 인가 — 구체 클래스 직접 X
- [ ] `super.method()` 호출이 부모 구현 디테일 의존 X
- [ ] `instanceof` 분기가 다형성으로 옮길 후보인가
- [ ] 다운캐스팅 후 메서드 호출 = 다형성 활용 실패

---

## 퀴즈

1. **업캐스팅과 동적 바인딩** 의 관계는?
2. **메서드 탐색 순서** 는?
3. **self 와 super 의 탐색 시작점 차이** 는?
4. 자바에서 동적 바인딩이 안 되는 메서드 종류 3가지?
5. **상속의 본질** 을 한 문장으로?

### 정답·해설

1. **업캐스팅** = 자식 → 부모 타입 변환 (컴파일타임). **동적 바인딩** = 실제 객체의 메서드 호출 (런타임). 업캐스팅으로 호출자가 추상 타입만 알게 + 동적 바인딩으로 실제 구현 호출 → 다형성.
2. **실제 객체의 클래스 → 부모 클래스 → 부모의 부모 → ... → Object**. 없으면 NoSuchMethodError. 자바는 거의 다 컴파일타임에 잡음.
3. **self (this)** = 실제 객체의 클래스에서 탐색 시작. **super** = 부모 클래스에서 탐색 시작. self 가 다형성 표현 (실제 객체), super 가 부모 명시 호출.
4. **`private`** (외부 호출 안 됨), **`static`** (클래스 메서드), **`final`** (오버라이드 금지). 이 셋은 컴파일타임에 결정.
5. **self 참조의 자동 위임**. 자식이 메서드 없으면 부모로 위임 (자동). 부모 메서드의 self 호출은 자식으로 위임 (동적). 이 두 위임의 결합이 상속의 행동 메커니즘.

---

## 다음 장 예고 — 13장: 서브클래싱과 서브타이핑

상속이 두 가지 다른 의도 — **서브클래싱** (코드 재사용) vs **서브타이핑** (타입 호환). 둘이 같다고 가정하면 LSP 위배. **리스코프 치환 원칙** 의 깊이.
