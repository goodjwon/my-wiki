---
title: "리팩터링 2판 실전 강의 — 12장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 12장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 12장 — 상속 다루기

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 절차 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 상속 계층을 **위·아래로 다듬는** 11가지 기법.
- **타입 코드 → 서브클래스(12.6)** 와 그 반대 **서브클래스 제거(12.7)**.
- 가장 중요한 ★★ — **서브클래스/슈퍼클래스를 위임으로(12.10·12.11)** — 상속 → 합성 전환.
- 상속의 **양날의 검** 인식 — LSP 위반·취약한 기반 클래스 문제.

### 0.2 큰 그림 — 위·아래·횡

```
[ 위로 올리기 ]                  [ 아래로 내리기 ]              [ 횡 변환 ]
 12.1 메서드 올리기               12.4 메서드 내리기              12.6 타입 코드 → 서브클래스
 12.2 필드 올리기                 12.5 필드 내리기                12.7 서브클래스 제거 (반대)
 12.3 생성자 본문 올리기                                          12.8 슈퍼클래스 추출
 12.9 계층 합치기                                                  12.10 서브클래스 → 위임 ★★
                                                                   12.11 슈퍼클래스 → 위임 ★
```

> **비유 — 상속은 "가문"입니다.**
>
> 가문의 자산(메서드·필드) 을 어느 세대로 옮길지(올리기·내리기), 멀어진 친척과 합칠지(슈퍼클래스 추출), 가문을 떠나 **계약으로 협력** 할지(위임으로) — 12장의 결정들.

### 0.3 현업에서 왜 중요한가

- 상속을 잘못 쓰면 **취약한 기반 클래스** — 부모 변경이 자식 다 깨뜨림.
- LSP 위반은 가장 잡기 어려운 버그.
- *Effective Java* Item 18(상속 대신 컴포지션)·19(상속 고려 설계)·20(인터페이스 우선) 의 실전.
- *오브젝트* 11장(합성과 유연한 설계)·13장(서브클래싱과 서브타이핑) 직접 적용.

---

## 12.1 메서드 올리기 (Pull Up Method)

### 한 줄 정의

**여러 자식 클래스에 중복된 메서드** 를 부모로.

```java
// Before
public class Engineer extends Employee {
    public Money monthlyPayout() { return baseSalary; }
}
public class Manager extends Employee {
    public Money monthlyPayout() { return baseSalary; }   // 중복
}

// After
public abstract class Employee {
    public Money monthlyPayout() { return baseSalary; }
}
```

### 동기

- **중복 코드** (악취 3.2) 제거의 정석.
- 부모가 책임지면 새 자식이 자동 상속.

### 절차

1. 자식들의 메서드 시그니처·본문 비교 (완전히 같아야).
2. 다르면 통합 가능한 형태로 먼저 맞춤.
3. 부모로 복사.
4. 자식들에서 제거.

---

## 12.2 필드 올리기 (Pull Up Field)

### 한 줄 정의

같은 필드가 여러 자식에 → 부모로.

### 절차

12.1과 동일. 보통 12.2가 먼저, 그 다음 12.1.

---

## 12.3 생성자 본문 올리기 (Pull Up Constructor Body)

### 한 줄 정의

여러 자식 생성자에 공통 본문 → 부모 생성자에서 처리, 자식은 `super(...)` 호출.

---

## 12.4 메서드 내리기 (Push Down Method)

### 한 줄 정의

부모에 있지만 **일부 자식만 쓰는 메서드** 를 그 자식으로 내림.

### 동기

- **상속 포기** (악취 3.23) 처방의 한 형태.
- 부모가 자식별 차이까지 알 필요 없게 됨.

---

## 12.5 필드 내리기 (Push Down Field)

### 한 줄 정의

12.4의 필드 버전.

---

## 12.6 타입 코드를 서브클래스로 바꾸기 (Replace Type Code with Subclasses)

### 한 줄 정의

`type` 필드로 분기하는 클래스를 **타입별 서브클래스** 로.

```java
// Before
public class Employee {
    private String type;   // "engineer" / "manager"

    public Money payout() {
        return switch (type) {
            case "engineer" -> baseSalary;
            case "manager"  -> baseSalary.plus(bonus);
            default -> throw new IllegalStateException();
        };
    }
}

// After
public abstract class Employee {
    public abstract Money payout();
}
public class Engineer extends Employee {
    public Money payout() { return baseSalary; }
}
public class Manager extends Employee {
    public Money payout() { return baseSalary.plus(bonus); }
}
```

### 동기

- **반복되는 switch** (3.12) 처방의 구조 변경 — 10.4 다형성 변환의 **선행 단계**.
- 새 타입 = 새 클래스.

### 함정

- 객체의 타입이 **런타임에 바뀌어야** 한다면 상속 부적합 → State/Strategy 패턴 (12.10 후속).

---

## 12.7 서브클래스 제거하기 (Remove Subclass)

### 한 줄 정의

차이가 없어진 서브클래스를 **부모의 필드/메서드** 로 흡수. 12.6의 반대.

```java
// Before
public class Person {
    public String genderCode() { return "X"; }
}
public class Male extends Person {
    public String genderCode() { return "M"; }
}
public class Female extends Person {
    public String genderCode() { return "F"; }
}

// After — 굳이 클래스로 나눌 가치 X
public class Person {
    private final Gender gender;   // enum
    public String genderCode() { return gender.code(); }
}
```

### 동기

- **성의 없는 요소** (3.14)·**추측성 일반화** (3.15) 처방.
- 단순 enum이 더 명료.

---

## 12.8 슈퍼클래스 추출하기 (Extract Superclass)

### 한 줄 정의

서로 다른 두 클래스에 비슷한 부분이 보이면 **공통 부모** 추출.

```java
// Before
public class Department { ... }
public class Employee { ... }
// 둘 다 name·annualCost 가짐

// After
public abstract class Party {
    protected String name;
    public abstract Money annualCost();
}
public class Department extends Party { ... }
public class Employee extends Party { ... }
```

### 동기

- 중복 제거.
- 다형성 가능해짐 — `Party` 타입으로 일관 처리.

### Effective Java 연결

Item 20: 슈퍼클래스가 **인터페이스** 면 더 좋음. 추상 클래스보다 우선.

---

## 12.9 계층 합치기 (Collapse Hierarchy)

### 한 줄 정의

부모와 자식 사이에 의미 있는 차이가 없으면 **한 클래스** 로.

### 동기

- 12.7과 비슷한 의도 (단계가 다름).
- 추측성 일반화 제거.

---

## 12.10 서브클래스를 위임으로 바꾸기 (Replace Subclass with Delegate) ★★

### 한 줄 정의

상속을 **합성** 으로 바꿈 — `extends` 대신 필드로 들고 위임.

```java
// Before
public class Booking { ... }
public class PremiumBooking extends Booking { ... }   // 일부 케이스만

// After
public class Booking {
    private final PremiumDelegate premium;   // null이면 일반

    public boolean hasTalkback() {
        return premium != null
            ? premium.hasTalkback()
            : show.hasOwnTalkback();
    }
}

public class PremiumDelegate {
    public boolean hasTalkback() { return true; }
    public Money price(Money basePrice) { return basePrice.plus(extension); }
}
```

### 동기

- **상속의 함정 회피** — LSP·취약한 기반 클래스·다중 상속 제한.
- **런타임에 동작 교체 가능** (`premium = new ...` 또는 null).
- *Effective Java* Item 18 "상속 대신 컴포지션" 의 실전 변환.

### 절차

1. 위임할 인터페이스 정의.
2. 부모 클래스에 위임 객체 필드 추가.
3. 자식 동작을 위임 객체로 옮김.
4. 부모 메서드에서 "위임 있으면 위임, 없으면 기본" 분기.
5. 자식 클래스 제거.

### 함정

- 위임 객체가 부모의 protected 필드에 접근해야 할 수 있음 → 시그니처 조정 필요.
- 모든 상속을 위임으로 바꿀 필요는 없음. **취약성·다중 변종** 시.

### *오브젝트* 연결

11장(합성과 유연한 설계) — 핸드폰 과금 사례가 정확히 12.10의 적용.

---

## 12.11 슈퍼클래스를 위임으로 바꾸기 (Replace Superclass with Delegate) ★

### 한 줄 정의

자식이 부모를 **`extends` 대신 필드로** 들고 필요한 메서드만 위임.

```java
// Before
public class Stack extends ArrayList { ... }   // List의 모든 메서드 노출됨

// After
public class Stack {
    private final List delegate = new ArrayList();
    public void push(Object o) { delegate.add(o); }
    public Object pop() { return delegate.remove(delegate.size() - 1); }
    // ArrayList의 add(index, ...) 같은 부적절한 메서드는 노출 X
}
```

### 동기

- **불필요한 인터페이스 상속** (취약한 기반 클래스의 한 형태) 회피.
- `Stack extends ArrayList` → 외부가 `stack.add(0, x)` 같은 LIFO 깨뜨리는 메서드 호출 가능.
- 위임은 **필요한 메서드만 의도적으로 노출**.

### Effective Java 연결

Item 18 "상속 대신 컴포지션" 의 가장 자주 인용되는 사례 — `java.util.Properties extends Hashtable` 의 실패.

### *오브젝트* 연결

11.01 "java.util.Properties와 java.util.Stack" 사례와 동일.

---

## 12장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| 자식들에 중복 메서드 | **메서드 올리기(12.1)** |
| 자식들에 중복 필드 | **필드 올리기(12.2)** |
| 일부 자식만 쓰는 부모 메서드 | **메서드 내리기(12.4)** |
| `type` 필드 분기 | **타입 코드 → 서브클래스(12.6)** |
| 차이 사라진 서브클래스 | **서브클래스 제거(12.7)** |
| 두 클래스에 비슷한 부분 | **슈퍼클래스 추출(12.8)** |
| 부모-자식 의미 차이 없음 | **계층 합치기(12.9)** |
| 상속의 함정·런타임 교체 필요 | **서브클래스 → 위임(12.10) ★★** |
| 부모의 메서드 다 노출되면 위험 | **슈퍼클래스 → 위임(12.11) ★** |

### 종합 체크리스트 (코드 리뷰용)

- [ ] 상속 계층에 중복된 코드가 자식 여럿에 있는가
- [ ] 부모에 있지만 일부 자식만 쓰는 메서드/필드가 있는가
- [ ] `type` 필드로 분기하는 거대 switch가 있는가
- [ ] `extends ArrayList`/`extends HashMap` 같이 상속으로 자료구조를 확장하고 있는가 → **위임으로 전환 검토**
- [ ] 자식이 부모 메서드를 `UnsupportedOperationException` 던지며 무시하는가 → 상속 포기, 위임으로

### 종합 퀴즈

<details><summary>Q1. 12.10·12.11이 ★ 인 이유? — Effective Java Item 18과의 관계?</summary>

상속의 가장 큰 함정(취약한 기반 클래스·LSP 위반·다중 상속 제한·런타임 교체 불가) 을 합성으로 우회. *Effective Java* Item 18 "상속 대신 컴포지션" 의 가장 직접적 적용 절차. *오브젝트* 11장의 핵심 변환과 동일.

</details>

<details><summary>Q2. 타입 코드 → 서브클래스(12.6) 후 객체의 타입이 런타임에 바뀌어야 한다면?</summary>

상속으로는 불가 — 한 번 정해진 자바 객체의 클래스는 못 바꿈. **State 또는 Strategy 패턴** (필드로 정책 객체를 들고 교체) 이 답. 12.10 (서브클래스 → 위임) 으로 자연스럽게 연결.

</details>

<details><summary>Q3. <code>java.util.Stack extends Vector</code> 의 실패 사례는 어떤 악취·어떤 리팩터링?</summary>

**상속 포기** (악취 3.23) — Stack이 LIFO를 보장해야 하는데, Vector의 `add(int, E)` 같은 메서드가 노출되어 LIFO를 깨뜨림. 처방은 **12.11 슈퍼클래스 → 위임**. Properties도 같은 사례 (Hashtable의 임의 키 추가).

</details>

<details><summary>Q4. 메서드 올리기(12.1)와 슈퍼클래스 추출(12.8)의 차이?</summary>

12.1은 **이미 같은 부모를 둔 자식들** 에서 중복 메서드를 부모로. 12.8은 **부모-자식 관계가 없는 두 클래스** 에 비슷한 부분을 보고 새 부모를 추출. 추출이 먼저, 올리기가 나중인 게 자연스러운 순서.

</details>

---

## 다음 단계 — 책 전체 마치며

### 카탈로그 활용 사이클 (4장 + 5장 + 6~12장)

```
1. 코드 본다
2. 3장 24 악취로 진단
3. 5장 카탈로그 사용법으로 후보 리팩터링 결정
4. 4장 테스트로 안전망 확인 (없으면 먼저 구축)
5. 6~12장 절차 따라 작은 단계로 적용
6. 단계마다 테스트 → 초록이면 다음
7. 한 PR = 한 리팩터링 = 한 의도
```

### 책 전체 6원칙

1. **자가 테스트가 모든 리팩터링의 전제** (4장)
2. **24 악취가 트리거** (3장)
3. **이름·전제·절차가 있는 변경** (5장)
4. **모든 리팩터링은 쌍** — 양방향 도구 (5장)
5. **CQS·불변 우선** (11·12장)
6. **상속보다 합성** (12.10·12.11)

### 다음 책으로

- ***Effective Java*** — 매일 짤 때의 90 권고 ([[entity-effective-java]])
- ***오브젝트*** — 책임 주도 설계의 한국어 표준 ([[entity-object]])
- ***Working Effectively with Legacy Code*** (Feathers) — 모듈·서비스 단위 리팩터링
- ***Domain-Driven Design*** (Evans / Vernon) — 도메인 모델링

> 강의 교재 12장 완료. 같은 형식으로 4권 도서 ingest 패턴이 자리잡음.
