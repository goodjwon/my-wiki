---
title: 객체지향 프로그래밍 (OOP)
type: concept
tags: [java, oop, design, encapsulation, inheritance, polymorphism, abstraction]
sources: [java-study/java-study-ch02-Java문법과객체.md]
external:
  - https://docs.oracle.com/javase/tutorial/java/concepts/
created: 2026-04-18
updated: 2026-06-07
---

# 객체지향 프로그래밍 (OOP)

## 정의

상태(state)와 행위(behavior)를 객체 단위로 묶고, **책임(responsibility)을 객체들 사이에 분배**하는 프로그래밍 패러다임. Java/C#/Kotlin/Python/Ruby 등의 핵심 설계 철학.

> **본질**: "함수가 데이터를 처리한다"에서 "객체가 자기 데이터에 책임을 진다"로 관점 전환.

## 4대 원칙

| 원칙 | 정의 | 흔한 오해 | 진짜 핵심 |
|------|------|----------|----------|
| **캡슐화** | 상태 + 그 상태를 다루는 행위를 한 곳에 묶기 | getter/setter 자동 생성 | **잘못된 상태 변경을 막는 것** |
| **상속** | 기존 클래스의 멤버를 재사용 + 확장 | 모든 재사용 = 상속 | **is-a 관계가 분명할 때만** |
| **다형성** | 같은 메시지에 객체별로 다른 응답 | 타입 캐스팅 많이 쓰기 | **호출자가 구체 타입을 모르는 것** |
| **추상화** | 본질만 드러내고 세부를 숨김 | 인터페이스 많이 만들기 | **변경 가능성이 큰 지점을 분리** |

## 1. 캡슐화

### 안 좋은 예
```java
public class Account {
    public long balance;  // 외부에서 직접 수정 가능
}
Account a = new Account();
a.balance = -1_000_000;  // ❌ 음수 잔액! 객체가 유효하지 않은 상태
```

### 캡슐화된 예
```java
public class Account {
    private long balance;
    public void deposit(long amount) {
        if (amount <= 0) throw new IllegalArgumentException();
        this.balance += amount;
    }
    public void withdraw(long amount) {
        if (this.balance < amount) throw new InsufficientFundsException();
        this.balance -= amount;
    }
    public long balance() { return balance; }
}
```

→ **invariant(불변 조건)** 를 객체 내부에서 보장. 외부에서 깰 수 없음.

> "getter/setter 자동 생성 = 캡슐화"는 가장 흔한 오해. setter가 있으면 사실상 `public` 필드와 같음. **잘못된 상태를 만들 수 없는 메서드 인터페이스**가 진짜 캡슐화.

## 2. 상속

### is-a 관계 (적절)
```java
class Animal { void breathe() {...} }
class Dog extends Animal { void bark() {...} }
// Dog "is a" Animal — 모든 개는 동물이다. ✅
```

### is-a 관계 X (부적절)
```java
class Stack<E> extends ArrayList<E> { ... }  // ❌ Stack은 List가 아니다
// Stack에 get(index)이 노출되면 안 됨. has-a 관계.
```

### 상속의 함정

> "**상속보다 합성**(Composition over Inheritance)" — Joshua Bloch, _Effective Java_

| 상속 | 합성 |
|------|------|
| 컴파일 시 결합 (강함) | 런타임 교체 가능 |
| 부모 변경이 모든 자식에 전파 | 한 곳만 수정 |
| `final` 클래스는 불가 | 모든 클래스 가능 |
| 다중 상속 불가 (Java) | 여러 컴포넌트 조합 가능 |

```java
// 상속 (강결합)
class TimestampedSet<E> extends HashSet<E> { ... }

// 합성 (유연)
class TimestampedSet<E> {
    private final Set<E> inner = new HashSet<>();
    public boolean add(E e) { inner.add(e); ts.put(e, now()); return true; }
}
```

## 3. 다형성

### 두 종류

| 종류 | 시점 | Java 구현 |
|------|------|----------|
| **컴파일 시** (Static) | 컴파일러가 결정 | 메서드 오버로딩 |
| **런타임** (Dynamic) | 객체 실제 타입이 결정 | 메서드 오버라이딩 + 인터페이스 |

### 다형성의 진짜 가치

```java
// 호출자는 PaymentProcessor만 안다 — 구체 타입은 모른다
public class OrderService {
    private final PaymentProcessor payment;  // 인터페이스
    public void placeOrder(Order o) {
        payment.charge(o);  // KakaoPayProcessor? TossPayProcessor? 알 필요 X
    }
}

interface PaymentProcessor { void charge(Order o); }
class KakaoPayProcessor implements PaymentProcessor { ... }
class TossPayProcessor implements PaymentProcessor { ... }
```

→ **호출자가 구체 구현을 모르는 상태**가 진짜 다형성의 가치. 새 결제 수단 추가 시 `OrderService` 안 바뀜 = **개방-폐쇄 원칙(OCP)**.

→ 이게 [[concept-spring-core|Spring DI]]가 작동하는 이유.

## 4. 추상화

### 인터페이스 vs 추상 클래스

| | `interface` | `abstract class` |
|---|------------|----------------|
| 메서드 시그니처만 | ✅ | ✅ |
| 구현 메서드 | default 메서드 (Java 8+) | ✅ |
| 필드 | `public static final`만 | 모든 종류 |
| 다중 "상속" | ✅ (interface 여러 개 가능) | ❌ |

### 인터페이스가 가치 있는 지점

> 인터페이스는 **실제로 교체 가능성이 있는 지점**에만.

```java
// 오버엔지니어링 ❌
interface UserService { ... }
class UserServiceImpl implements UserService { ... }
// 구현체가 단 하나뿐인데 인터페이스를 만든 케이스 — 의미 없음

// 합리적 ✅
interface NotificationSender { void send(Notification n); }
class EmailSender implements NotificationSender { ... }
class SlackSender implements NotificationSender { ... }
class SmsSender implements NotificationSender { ... }
```

## SOLID 원칙 (OOP 설계의 5대 원칙)

| 약자 | 이름 | 한 줄 |
|------|------|------|
| **S** | Single Responsibility | 한 클래스는 한 가지 변경 이유만 |
| **O** | Open/Closed | 확장에는 열려있고, 수정에는 닫혀 있어야 |
| **L** | Liskov Substitution | 자식이 부모를 대체할 수 있어야 |
| **I** | Interface Segregation | 작은 인터페이스 여러 개 > 큰 인터페이스 하나 |
| **D** | Dependency Inversion | 구체가 아니라 추상에 의존하라 |

### 가장 자주 어기는 LSP 예

```java
class Rectangle { int w, h; void setW(int v) {...}; void setH(int v) {...}; int area() {...} }
class Square extends Rectangle {
    @Override void setW(int v) { this.w = v; this.h = v; }
    // ❌ Rectangle의 "width 따로 height 따로 설정 가능"이라는 계약 깸
}
Rectangle r = new Square();
r.setW(5); r.setH(10);
assert r.area() == 50;  // 실패! Square 때문에 100
```

→ Square `is-a` Rectangle 처럼 보이지만 **부모 계약을 깬다**. 상속 대신 별도 타입으로.

## 핵심 판단 기준

- 객체 설계 시 **"무엇을 가지고 있는가"보다 "무엇을 책임지는가"** (책임 주도 설계)
- **상속보다 합성**이 거의 항상 안전
- 인터페이스는 **실제 교체 가능성이 있는 곳**에만
- 생성자는 "이 객체가 유효한 상태로 시작한다는 약속"

## 실무 연결

| 적용 | 어떻게 OOP가 작동하나 |
|------|---------------------|
| [[concept-spring-core|Spring DI]] | 다형성 + 추상화. Bean은 인터페이스를 보고 의존 |
| 전략 패턴 | 다형성 (런타임에 알고리즘 교체) |
| [[concept-design-patterns|디자인 패턴]] | OOP 원칙의 정형화 |
| [[src-kakaopay-ddd|도메인 모델링 (DDD)]] | 캡슐화 (Aggregate가 invariant 보장) |
| 테스트 가능한 구조 | 의존성 역전 (DIP) → mock 주입 가능 |

## 함정 — OOP가 항상 정답은 아니다

- **단순 데이터 처리** → 함수형이 더 명확
- **수치 계산·트랜스포메이션** → 함수형 또는 절차형
- **모든 것을 클래스로** → 오버엔지니어링

> "**객체지향은 도구지 종교가 아니다.**" Kotlin·Scala 같은 현대 언어가 OOP + 함수형 혼합으로 가는 이유.

## 원본 출처

- raw: `raw/java-study/java-study-ch02-Java문법과객체.md`
- 공식: [Oracle — OOP Concepts](https://docs.oracle.com/javase/tutorial/java/concepts/)
- 추천: _Effective Java_ (Joshua Bloch)

## 관련 페이지

- [[concept-design-patterns]] — OOP 원칙을 구조화한 23패턴
- [[concept-spring-core]] — Spring에서 OOP가 실현되는 구조
- [[src-kakaopay-ddd]] — DDD = OOP를 도메인에 적용한 설계법
- [[src-java-study-2024-2025]] — Java 스터디 Ch02
- [[entity-jvm]] — 객체 생성·소멸이 일어나는 런타임
