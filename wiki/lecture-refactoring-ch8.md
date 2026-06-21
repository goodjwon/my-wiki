---
title: "리팩터링 2판 실전 강의 — 8장"
type: source
tags: [book, refactoring, fowler, lecture]
sources: [refactoring/리팩터링 실전 강의 교재 8장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 리팩터링 실전 강의 교재

## 8장 — 기능 이동

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 절차 → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 함수·필드·문장을 **올바른 자리** 로 옮기는 9가지 기법.
- **산탄총 수술** (악취 3.8)·**기능 편애** (3.9) 의 처방.
- 명령형 반복문을 **파이프라인** 으로 바꾸는 모던 자바 패턴.

### 0.2 큰 그림

```
[ 위치 이동 ]                   [ 문장 단위 ]                  [ 형태 변환 ]
 8.1 함수 옮기기 ★              8.3 문장을 함수로 옮기기         8.7 반복문 쪼개기
 8.2 필드 옮기기                 8.4 문장을 호출한 곳으로 옮기기  8.8 반복문을 파이프라인으로
                                  8.5 인라인 코드를 함수 호출로     8.9 죽은 코드 제거
                                  8.6 문장 슬라이드
```

> **비유 — 8장은 "주방의 도구 자리 정리"입니다.**
>
> 같은 도구가 5개 주방에 흩어져 있으면 사고. 자기 자리로 모아야 한 변경이 한 곳에서 끝남.

### 0.3 현업에서 왜 중요한가

- PR이 5+ 파일 같이 수정해야 한다면 **산탄총 수술** — 8.1·8.2가 처방.
- *Effective Java* Item 18(컴포지션)·Item 64(인터페이스 참조) 의 실전 적용.

---

## 8.1 함수 옮기기 (Move Function) ★

### 한 줄 정의

함수를 **그 데이터에 더 가까운 클래스/모듈** 로 옮긴다.

```java
// Before — Account 안의 함수가 사실은 AccountType 데이터를 더 씀
public class Account {
    private final AccountType type;
    public double overdraftCharge() {
        if (type.isPremium()) {
            int baseCharge = 10;
            return baseCharge + (type.discountFactor() * 5);
        }
        return 20;
    }
}

// After — AccountType 안으로 이동
public class AccountType {
    public double overdraftCharge() {
        if (isPremium()) {
            int baseCharge = 10;
            return baseCharge + (discountFactor() * 5);
        }
        return 20;
    }
}

public class Account {
    public double overdraftCharge() { return type.overdraftCharge(); }
}
```

### 동기

- **기능 편애** (악취 3.9) 의 직접 처방.
- 데이터와 행동이 같은 자리 — 응집도 ↑, 결합도 ↓.
- **산탄총 수술** (3.8) 줄임 — 한 변경이 한 클래스에서 끝남.

### 절차

1. 옮길 함수가 쓰는 **외부 의존** 파악.
2. 후보 클래스가 정해지지 않았다면 결정.
3. 새 위치에 함수 복사.
4. 원본 함수가 새 함수를 호출하게.
5. 모든 호출자를 새 위치로 이전.
6. 원본 함수 제거.

### IDE

- IntelliJ: `F6` — Move. 의존성·임포트 자동 처리.

### Spring 현업

```java
// Before — Service가 너무 많은 일
@Service
public class OrderService {
    public Money calculateDiscount(Order order, Coupon coupon) {
        // 100줄
    }
}

// After — 도메인으로 이동
public class Coupon {
    public Money apply(Money subtotal) { ... }
}

@Service
public class OrderService {
    public Money calculateDiscount(Order order, Coupon coupon) {
        return coupon.apply(order.subtotal());
    }
}
```

---

## 8.2 필드 옮기기 (Move Field)

### 한 줄 정의

필드를 **그것을 더 많이 쓰는 클래스** 로 이동.

```java
// Before
public class Customer {
    private final Plan plan;
    private double discountRate;   // ← 사실은 Plan에 속하는 값
}

// After
public class Plan {
    private double discountRate;
}
public class Customer {
    private final Plan plan;
    public double discountRate() { return plan.discountRate(); }
}
```

### 동기

- 데이터가 잘못된 자리에 있으면 **함수 옮기기** 도 막힘.
- 필드 정리가 함수 정리의 전 단계인 경우가 많음.

### 절차

1. 옮길 필드를 캡슐화(6.6) — getter/setter 거치게.
2. 새 위치에 필드 + 접근자 만들기.
3. 원본 접근자가 새 위치로 위임.
4. 호출자를 새 위치로 이전.
5. 원본 필드 제거.

---

## 8.3 문장을 함수로 옮기기 (Move Statements into Function)

### 한 줄 정의

호출 직전·직후의 **고정된 문장** 을 호출되는 함수 안으로 흡수.

```java
// Before — 모든 호출자가 같은 헤더 출력 후 함수 호출
result.add("<p>title:</p>");
result.add(emitPhotoData(photo));

// After
result.add(emitPhotoData(photo));   // 함수 안에서 title도 출력

public List<String> emitPhotoData(Photo photo) {
    var lines = new ArrayList<String>();
    lines.add("<p>title:</p>");
    lines.add("<p>" + photo.title() + "</p>");
    // ...
    return lines;
}
```

### 동기

- 같은 코드가 호출자마다 반복 → 중복 (악취 3.2).
- 함수의 책임이 모호 → 명확.

---

## 8.4 문장을 호출한 곳으로 옮기기 (Move Statements to Callers)

### 한 줄 정의

함수 안의 일부 문장이 호출자마다 다른 동작을 해야 하면 **밖으로 꺼냄**. 8.3의 반대.

```java
// Before — 모든 호출자가 같은 행동을 강요받음
public void render(Photo p) {
    renderHeader();   // 모두 같은 헤더 — OK
    renderBody(p);    // 일부는 다른 body를 원함
    renderFooter();
}

// After — body는 호출자가
public void renderWrapped(Runnable body) {
    renderHeader();
    body.run();
    renderFooter();
}
```

### 동기

- 함수의 **공통 부분만** 추출하고 차이는 호출자에 위임.
- 8.3의 결과가 과하면 8.4로 되돌리기.

---

## 8.5 인라인 코드를 함수 호출로 바꾸기 (Replace Inline Code with Function Call)

### 한 줄 정의

같은 일을 하는 **기존 함수가 있으면** 인라인 코드 대신 그 함수 호출.

```java
// Before
boolean exists = false;
for (String s : list) if (s.equals(target)) { exists = true; break; }

// After
boolean exists = list.contains(target);   // 표준 라이브러리 활용
```

### 동기

- 표준 라이브러리·기존 헬퍼 재사용.
- 의도가 한 줄로.

### *Effective Java* 연결

Item 59(라이브러리를 익히고 사용하라).

---

## 8.6 문장 슬라이드하기 (Slide Statements)

### 한 줄 정의

관련 있는 코드를 **가까이 모으기**.

```java
// Before — 변수 선언과 사용이 멀리 떨어짐
int pricingPlan = retrievePricingPlan();
int order = retrieveOrder();
double baseCharge = pricingPlan.base;
double charge;
// ... 10줄 ...
double chargePerUnit = pricingPlan.unit;

// After — 한 묶음으로
int pricingPlan = retrievePricingPlan();
double baseCharge = pricingPlan.base;
double chargePerUnit = pricingPlan.unit;
int order = retrieveOrder();
double charge;
// ...
```

### 동기

- 함수 추출의 전 단계 — 묶여 있어야 추출 가능.
- 가독성 ↑ — 관련된 정보가 한 시야에.

### 절차

1. 옮길 문장의 부작용·의존성 점검 (앞뒤 코드와 충돌 없는지).
2. 한 문장씩 이동.
3. 테스트.

---

## 8.7 반복문 쪼개기 (Split Loop)

### 한 줄 정의

한 반복문이 두 가지 일을 하면 **두 반복문** 으로.

```java
// Before
double averageAge = 0;
double totalSalary = 0;
for (Person p : people) {
    averageAge += p.age;
    totalSalary += p.salary;
}
averageAge /= people.size();

// After
double totalSalary = 0;
for (Person p : people) totalSalary += p.salary;

double averageAge = 0;
for (Person p : people) averageAge += p.age;
averageAge /= people.size();
```

### 동기

- 한 반복문 = 한 일 → 각 일을 **함수 추출(6.1)** 로 옮길 수 있게 됨.
- "성능이 떨어지지 않나?" — 보통 무시 가능. 측정 후 핫스팟이면 합치기.

### 1장 단계 5

`totalAmount`/`totalPoints` 두 누적을 한 루프에서 빼낸 변환이 정확히 8.7.

---

## 8.8 반복문을 파이프라인으로 바꾸기 (Replace Loop with Pipeline)

### 한 줄 정의

명령형 반복문을 **stream 파이프라인** 으로.

```java
// Before
List<String> names = new ArrayList<>();
for (Person p : people) {
    if (p.age >= 18) names.add(p.name.toUpperCase());
}

// After
List<String> names = people.stream()
    .filter(p -> p.age >= 18)
    .map(p -> p.name.toUpperCase())
    .toList();
```

### 동기

- 의도(필터·매핑·집계)가 **각 단계 이름** 으로 드러남.
- 부작용 없는 파이프라인은 병렬화 후보.

### 함정 (Effective Java Item 45·46과 같은 결)

- **외부 변수 수정** 이 있으면 파이프라인 부적합.
- **break/continue** 필요하면 그대로 반복문.
- **가독성이 더 떨어지면** 반복문 유지.

---

## 8.9 죽은 코드 제거하기 (Remove Dead Code)

### 한 줄 정의

호출되지 않는 코드는 **즉시 삭제**. "혹시 모르니" 두지 마라.

### 동기

- 죽은 코드는 읽는 사람의 인지 부담.
- "안 쓰이는데?" 라고 의심하다 시간 낭비.
- Git이 다 기억하니 필요하면 복구.

### IDE

- IntelliJ: `Code → Inspect Code` → Unused declarations 일괄 검출.

### 함정

- **리플렉션·SpEL·동적 호출** 로 쓰이는 코드는 정적 검사가 못 잡음. 검색·로깅 후 확인.

---

## 8장 종합 정리

### 한눈에 보는 결정 가이드

| 상황 | 선택 |
|------|------|
| 함수가 자기 클래스 데이터 안 쓰고 다른 클래스 씀 | **함수 옮기기(8.1) ★** |
| 필드가 잘못된 자리에 있어 함수 이동을 막음 | **필드 옮기기(8.2)** |
| 호출자마다 같은 헤더/푸터 반복 | **문장을 함수로 옮기기(8.3)** |
| 함수 안에 호출자마다 달라야 할 코드 | **문장을 호출한 곳으로(8.4)** |
| 같은 일 하는 표준 함수 있음 | **인라인 코드를 함수 호출로(8.5)** |
| 관련 코드가 흩어져 추출 못 함 | **문장 슬라이드(8.6)** |
| 한 반복문이 두 일 함 | **반복문 쪼개기(8.7)** |
| 명령형 반복문이 의도를 가림 | **반복문을 파이프라인으로(8.8)** |
| 호출되지 않는 코드 | **죽은 코드 제거(8.9)** |

### 종합 체크리스트 (코드 리뷰용)

- [ ] 다른 클래스 getter를 줄줄 부르는 함수 → 8.1 함수 옮기기
- [ ] PR이 5+ 파일 동시 수정 → 8.1·8.2로 산탄총 수술 해소 가능?
- [ ] 한 반복문이 누적·필터·매핑 다 함 → 8.7로 분리
- [ ] 명령형 반복문을 파이프라인으로 정리 가능?
- [ ] "혹시 모르니" 두는 죽은 코드 → 즉시 삭제

### 종합 퀴즈

**Q1. 함수 옮기기와 필드 옮기기의 우선순위?**

**A.** 보통 **필드 옮기기 먼저**. 데이터가 잘못된 자리에 있으면 함수가 그 데이터를 찾아가는 위장 호출이 생겨 함수 옮기기 분석을 흐림. 데이터 정리 후 함수 정리.

**Q2. 반복문을 파이프라인(8.8)으로 항상 바꾸면 안 되는 이유?**

**A.** (1) 외부 변수 수정이 있으면 함수형 파이프라인이 깨짐, (2) break/continue 같은 흐름 제어가 필요하면 반복문이 더 명료, (3) 가독성이 떨어지는 경우. *Effective Java* Item 45와 같은 결.

**Q3. 죽은 코드를 "Git이 기억하니까" 즉시 지울 수 있는 이유?**

**A.** 복구 비용 < 유지 비용. 죽은 코드는 매번 읽는 사람의 인지 부담을 추가하고 잘못된 의존을 부른다. Git 히스토리에 있으면 필요 시 한 줄 명령으로 되살림.

**Q4. 반복문 쪼개기(8.7)의 성능 우려는?**

**A.** 데이터를 두 번 순회 → 약간 느림. 하지만 **거의 모든 경우 무시 가능** (Big-O 같음, 상수만 2배). 측정 후 진짜 핫스팟이면 합치고, 아니면 가독성 우선. 책 2.8·Item 67과 같은 정신.

---

## 다음 장 예고 — 9장: 데이터 조직화

자료구조 자체를 다듬는 6가지 기법 — 변수 쪼개기, 필드 이름, 파생 변수→질의 함수, **참조↔값 쌍**, 매직 리터럴. 작지만 사고 잦은 영역.
