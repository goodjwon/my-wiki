---
title: "리팩터링 2판 실전 강의 — 10장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 10장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 10장 — 조건부 로직 간소화

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 절차 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- `if`/`switch` 조건문의 **7가지 간소화 기법**.
- ★ **조건부 로직을 다형성으로(10.4)** — 책의 가장 중요한 ★ 중 하나.
- 깊은 중첩을 푸는 **보호 구문(Guard Clauses)**.
- `null`/특이 케이스를 객체로 표현.

### 0.2 큰 그림

```
[ 조건문 자체 ]                  [ 깊은 중첩 ]                  [ 다형성·특이 ]
 10.1 조건문 분해                 10.3 보호 구문                  10.4 조건부 로직 → 다형성 ★
 10.2 조건식 통합                 10.7 제어 플래그 → 탈출문        10.5 특이 케이스 추가
                                                                   10.6 어서션 추가
```

> **비유 — 조건문은 "도시의 신호등"입니다.**
>
> 신호등이 너무 많으면 길이 막힘 (조건문 통합·분해). 신호등 대신 우회로(보호 구문)로 빠르게 정리. 결국 핵심은 신호등 없이 **각 차로마다 다른 길**(다형성).

### 0.3 현업에서 왜 중요한가

- 분기 폭발 = 새 기능 추가 비용 폭증.
- "반복되는 switch" (악취 3.12)·"긴 함수" (3.3)·"기본형 집착" (3.11) 모두 10장 처방.
- *오브젝트* 5장(책임 할당)·12장(다형성)과 직결.

---

## 10.1 조건문 분해하기 (Decompose Conditional)

### 한 줄 정의

복잡한 `if/else` 의 **조건과 본문을 각각 함수로 추출**.

```java
// Before
if (date.isBefore(SUMMER_START) || date.isAfter(SUMMER_END)) {
    charge = quantity * winterRate + winterServiceCharge;
} else {
    charge = quantity * summerRate;
}

// After
if (notSummer(date)) {
    charge = winterCharge(quantity);
} else {
    charge = summerCharge(quantity);
}

private boolean notSummer(LocalDate d) { ... }
private Money winterCharge(int q) { ... }
private Money summerCharge(int q) { ... }
```

### 동기

- 조건과 본문 모두 의도가 함수 이름으로 드러남.
- 본문이 길수록 효과 큼.

### 절차

1. 조건식을 함수 추출(6.1).
2. then/else 본문 각각 함수 추출.

---

## 10.2 조건식 통합하기 (Consolidate Conditional Expression)

### 한 줄 정의

**같은 결과** 를 내는 여러 조건문을 하나로.

```java
// Before
if (employee.seniority < 2) return 0;
if (employee.monthsDisabled > 12) return 0;
if (employee.isPartTime) return 0;
return ...;

// After
if (isNotEligibleForDisability(employee)) return 0;
return ...;

private boolean isNotEligibleForDisability(Employee e) {
    return e.seniority < 2 || e.monthsDisabled > 12 || e.isPartTime;
}
```

### 동기

- 같은 결과를 묶으면 **공통 의도** 가 드러남.
- 함수 추출 가능.

---

## 10.3 중첩 조건문을 보호 구문으로 바꾸기 (Replace Nested Conditional with Guard Clauses)

### 한 줄 정의

여러 단계 중첩 `if/else` 를 **앞쪽에서 빠져나오는** 보호 구문 패턴으로.

```java
// Before — 화살표 모양
double getPayAmount() {
    double result;
    if (isDead) {
        result = deadAmount();
    } else {
        if (isSeparated) {
            result = separatedAmount();
        } else {
            if (isRetired) {
                result = retiredAmount();
            } else {
                result = normalPayAmount();
            }
        }
    }
    return result;
}

// After — 평탄화 + 의도가 한눈에
double getPayAmount() {
    if (isDead) return deadAmount();
    if (isSeparated) return separatedAmount();
    if (isRetired) return retiredAmount();
    return normalPayAmount();
}
```

### 동기

- 중첩이 깊으면 **정상 경로** 가 안 보임.
- 보호 구문 = "예외 상황은 앞에서 빠지고, 정상 본문은 깔끔하게".

### 흔한 오해 — "단일 반환점(single return)"

전통적으로 "메서드 끝에 return 하나만" 이 권장됐지만, **현대에는 보호 구문이 더 명료** 하다는 합의. Fowler도 같은 입장.

---

## 10.4 조건부 로직을 다형성으로 바꾸기 (Replace Conditional with Polymorphism) ★

### 한 줄 정의

같은 분기 조건이 여러 곳에 반복되면 **타입별 클래스 + 메서드 오버라이딩** 으로.

```java
// Before — switch가 여러 곳에 (악취 3.12)
public class Employee {
    private String type;   // "engineer" / "manager" / "salesman"

    public int payAmount() {
        switch (type) {
            case "engineer": return monthlySalary;
            case "salesman": return monthlySalary + commission;
            case "manager":  return monthlySalary + bonus;
            default: throw new IllegalStateException();
        }
    }

    public int vacationDays() {
        switch (type) {   // 같은 분기 반복
            case "engineer": return 12;
            case "salesman": return 15;
            case "manager":  return 20;
            default: throw new IllegalStateException();
        }
    }
}

// After — 타입별 서브클래스
public abstract class Employee {
    protected int monthlySalary;
    public abstract int payAmount();
    public abstract int vacationDays();
}

public class Engineer extends Employee {
    public int payAmount()    { return monthlySalary; }
    public int vacationDays() { return 12; }
}

public class Salesman extends Employee {
    public int payAmount()    { return monthlySalary + commission; }
    public int vacationDays() { return 15; }
}

public class Manager extends Employee {
    public int payAmount()    { return monthlySalary + bonus; }
    public int vacationDays() { return 20; }
}
```

### 동기

- 새 타입 추가 = **새 클래스 1개**. 기존 switch 다 안 찾아도 됨 → 산탄총 수술 (3.8) 사라짐.
- OCP(개방-폐쇄 원칙) 실현.

### 절차

1. 다형성을 위한 클래스 계층 준비 (없으면 추출 — 12.6 타입 코드를 서브클래스로).
2. 각 분기를 해당 서브클래스의 메서드 오버라이딩으로 옮김.
3. 원본 switch 제거.
4. 부모 메서드를 추상으로(또는 기본 구현).

### 1장 단계 7

`switch(play.type)` 를 `Performance` 서브클래스(`Tragedy`/`Comedy`)로 바꾼 변환이 정확히 이 리팩터링.

### Effective Java 연결

Item 34(int 상수 대신 enum) + Item 18(상속 vs 컴포지션). enum + Strategy 조합도 자주 쓰임.

### *오브젝트* 연결

5장(책임 할당)·12장(다형성)의 직접 적용.

---

## 10.5 특이 케이스 추가하기 (Introduce Special Case)

### 한 줄 정의

특정 값(`null`·"unknown")에 대한 **공통 처리** 를 별도 객체로.

```java
// Before — null 체크가 여러 곳
if (customer == null) name = "occupant";
else name = customer.name();

if (customer == null) bill = 0;
else bill = customer.billingPlan();

// After — Null Object 패턴
public class NullCustomer extends Customer {
    public String name() { return "occupant"; }
    public double billingPlan() { return 0; }
}

Customer customer = findCustomerOrNullObject(id);
String name = customer.name();   // null 체크 불필요
double bill = customer.billingPlan();
```

### 동기

- `null` 체크 반복 제거.
- 특이 케이스의 의미가 코드에 명시.
- *Null Object Pattern* (GoF 패턴 변형).

### 함정

- 모든 null을 객체화하면 과함. **여러 곳에서 같은 null 처리가 반복** 될 때만.

---

## 10.6 어서션 추가하기 (Introduce Assertion)

### 한 줄 정의

코드의 **숨겨진 가정** 을 어서션으로 명시.

```java
// Before — 가정이 주석에만
// discountRate는 항상 0~1 사이
double applyDiscount(double price) {
    return price * (1 - discountRate);
}

// After
double applyDiscount(double price) {
    assert discountRate >= 0 && discountRate <= 1
        : "discountRate must be in [0, 1] but was " + discountRate;
    return price * (1 - discountRate);
}
```

### 동기

- 가정이 명시적 → 깨졌을 때 즉시 발견.
- 살아 있는 문서.

### 함정 (Java 특수)

- Java `assert` 는 **기본 비활성** (`-ea` 옵션 필요). 운영 환경에서 검증 안 됨.
- 진짜 검증이 필요하면 `if + throw new IllegalArgumentException` — *Effective Java* Item 49와 같은 결.

### 실전 권장

- private 메서드 = `assert` (개발·테스트만)
- public 메서드 = `Objects.requireNonNull` / `if-throw` (항상 검증)

---

## 10.7 제어 플래그를 탈출문으로 바꾸기 (Replace Control Flag with Break)

### 한 줄 정의

루프 종료용 boolean 플래그를 **`break`/`return`** 으로.

```java
// Before
boolean found = false;
for (String s : list) {
    if (!found) {
        if (s.equals(target)) found = true;
        // ...
    }
}

// After
for (String s : list) {
    if (s.equals(target)) break;
    // ...
}

// 더 좋게 — Effective Java Item 59
boolean found = list.contains(target);
```

### 동기

- 제어 플래그가 흐름을 가림.
- `break`/`return` 이 의도 명료.

---

## 10장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| 조건과 본문이 복잡 | **조건문 분해(10.1)** |
| 같은 결과 조건 여러 개 | **조건식 통합(10.2)** |
| 중첩 if/else | **보호 구문(10.3)** |
| 같은 switch가 여러 곳 | **조건부 로직 → 다형성(10.4) ★** |
| null/특이 값 처리 반복 | **특이 케이스 추가(10.5)** — Null Object |
| 코드의 숨은 가정 | **어서션 추가(10.6)** — private만, public은 throw |
| 루프의 제어 플래그 | **탈출문으로(10.7)** |

### 종합 체크리스트 (코드 리뷰용)

- [ ] 같은 `switch(type)` 가 3+ 곳에 있는가 → **다형성(10.4)**
- [ ] 중첩 if/else 가 3단계 이상인가 → **보호 구문(10.3)**
- [ ] null 체크가 여러 곳에 반복되는가 → **Null Object(10.5)**
- [ ] 매개변수 검증을 `assert` 로만 하고 있는가 → **public은 if-throw**

### 종합 퀴즈

<details><summary>Q1. 다형성으로 바꾸기(10.4)가 책의 ★인 이유?</summary>

OO의 핵심을 가장 직접적으로 보여주는 리팩터링. switch는 새 타입마다 모든 분기 찾아 추가 (산탄총 수술), 다형성은 새 타입 = 새 클래스 1개로 끝 (OCP). 객체지향이 "왜 좋은가" 의 가장 구체적 사례.

</details>

<details><summary>Q2. "단일 반환점" 전통 권고와 보호 구문(10.3)이 충돌하는데, 왜 보호 구문이 더 권장되나?</summary>

단일 반환점은 옛 C 시대의 자원 정리 패턴에서 왔지만, 현대 언어는 GC + try-with-resources로 그 문제가 사라짐. 보호 구문이 정상 경로의 의도를 가장 명료하게 드러내므로 가독성에서 압도적.

</details>

<details><summary>Q3. Java <code>assert</code>가 public API 검증에 부적합한 이유?</summary>

기본 비활성 (`-ea` JVM 옵션이 있어야만 작동). 운영 환경에서 비활성이면 검증 안 됨. public 메서드는 항상 검증돼야 하므로 `Objects.requireNonNull` 같은 명시적 throw 필요. assert는 private/디버깅용.

</details>

<details><summary>Q4. Null Object 패턴(10.5)을 항상 도입하지 말라는 이유?</summary>

null 체크가 1~2곳뿐이면 패턴 도입 비용이 더 큼 — 새 클래스, 팩터리, equals 처리 등. **여러 곳에서 같은 null 처리가 반복** 될 때만 가성비 있음.

</details>

---

## 다음 장 예고 — 11장: API 리팩터링

공개 인터페이스(메서드·생성자) 의 13가지 설계 개선. **CQS(질의-변경 분리)** ★, 플래그 인수 제거, 객체 통째로 넘기기, **생성자 → 팩터리**, 오류 코드 ↔ 예외. API는 한 번 공개되면 영원하므로 가장 신중해야 할 장.
