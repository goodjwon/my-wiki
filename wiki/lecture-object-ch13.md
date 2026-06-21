---
title: "오브젝트 실전 강의 — 13장"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 13장.md]
created: 2026-06-21
updated: 2026-06-21
---

# 오브젝트 실전 강의 교재

## 13장 — 서브클래싱과 서브타이핑

> **원서**: 조영호 『오브젝트』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 → 핵심 교훈 → 현업 예제 → 함정 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- **타입** 의 세 관점 (개념·언어·OO).
- **서브클래싱 (코드 재사용)** vs **서브타이핑 (타입 호환)** 의 차이.
- **리스코프 치환 원칙 (LSP)** — 자식이 부모를 대체할 수 있어야.
- **계약에 의한 설계** 와 서브타이핑의 관계.

### 0.2 큰 그림 — 상속의 두 의도

```
[ 서브클래싱 ]                    [ 서브타이핑 ]
 코드 재사용 목적                   타입 호환 목적 (is-a)
 자식이 부모 코드 가져옴            자식이 부모 대체 가능 (LSP)
 LSP 보장 안 됨                    LSP 보장
 위험                              안전
```

> **비유 — "혈연 vs 자격증"**
>
> 서브클래싱 = 부모의 성씨를 물려받기 (이름 같음, 행동 다를 수 있음).
> 서브타이핑 = 자격증 통과 (어떤 자격 보장, 누구든 합격하면 대체).

### 0.3 현업에서 왜 중요한가

- 무지성 `extends` 가 LSP 위배 → 다형성 깨짐.
- *Effective Java* Item 10 (equals)·Item 18 (상속 신중) 와 직결.
- SOLID 의 L (Liskov Substitution Principle).

---

## 1. 타입

### 1.1 개념 관점의 타입

> **공통 속성·행동** 을 가진 객체 집합. 예: "포유류" = 새끼를 낳고 젖을 먹임.

### 1.2 프로그래밍 언어 관점의 타입

> **컴파일러가 검사하는 분류**. 예: `int`, `String`, `Customer`.

### 1.3 객체지향 패러다임 관점의 타입

> **같은 메시지를 받을 수 있는 객체 집합**. 인터페이스 단위.

---

## 2. 타입 계층

### 2.1 타입 사이의 포함관계

- 더 일반적 (포유류) ⊃ 더 구체적 (개).
- 부모 타입이 자식 타입을 **포함** (집합론적).

### 2.2 객체지향 프로그래밍과 타입 계층

자바 `extends`/`implements` 가 타입 계층 형성. 부모 타입 변수에 자식 객체 대입 가능 (업캐스팅).

---

## 3. 서브클래싱과 서브타이핑

### 3.1 언제 상속을 사용해야 하는가?

상속 정당화의 두 조건 (둘 다 만족):
1. **타입 계층 (is-a)** — 자식이 부모의 **종류**.
2. **행동 호환** — 자식이 부모의 모든 행동을 약속대로 수행.

### 3.2 is-a 관계

"자식 is-a 부모" 가 성립해야:
- `Square is-a Rectangle`? — 수학적으로 yes, but 행동 호환 X (사각형 setWidth 가 정사각형 깨뜨림).
- `Stack is-a Vector`? — 코드 재사용 yes, but 행동 호환 X (LIFO 깨짐).

→ is-a 만으로는 부족. **행동 호환** 필수.

### 3.3 행동 호환성

자식이 부모의 **모든 행동 약속** 을 지켜야:
- 메서드 시그니처 호환 (반환·매개변수·예외).
- 사전조건·사후조건 호환 (계약).
- 불변식 유지.

### 3.4 클라이언트의 기대에 따라 계층 분리하기

같은 클래스도 클라이언트별로 다른 인터페이스 노출:

```java
public interface ReadableMap<K, V> {
    V get(K key);
    boolean containsKey(K key);
}

public interface WritableMap<K, V> extends ReadableMap<K, V> {
    void put(K key, V value);
    void remove(K key);
}
```

→ 읽기 전용 클라이언트는 `ReadableMap` 만 의존. ISP (Interface Segregation Principle).

### 3.5 서브클래싱과 서브타이핑 차이

- **서브클래싱**: 코드 재사용 목적. `extends` 사용. LSP 보장 X.
- **서브타이핑**: 타입 호환 목적. `implements` 가 명시적. LSP 필수.

---

## 4. 리스코프 치환 원칙 (LSP)

### 4.1 정의 (Barbara Liskov, 1987)

> **자식 타입의 객체는 부모 타입의 객체로 대체할 수 있어야** 한다. 프로그램 정확성 유지하면서.

### 4.2 클라이언트와 대체 가능성

```java
void process(Rectangle r) {
    r.setWidth(5);
    r.setHeight(4);
    assert r.area() == 20;   // ← LSP 가정
}

Square s = new Square(...);
process(s);   // Square 가 Rectangle 자리 대체 — 가능?
              // setWidth(5) 후 setHeight(4) 하면 정사각형이 깨지거나 면적 16 — assert 실패
```

→ `Square extends Rectangle` 이 LSP 위배. is-a 가 성립해도.

### 4.3 is-a 관계 다시 살펴보기

is-a 의 **OO 적 의미** = **행동 호환** + 타입 호환. 단순히 "종류" 라는 의미 X.

### 4.4 LSP 는 유연한 설계의 기반

LSP 가 깨지면 클라이언트가 자식 타입 알아야 → 다형성 무력화.

### 4.5 타입 계층과 LSP

- LSP 만족 = 다형성 자유.
- LSP 위반 = `instanceof` 분기 필요 → OO 가 절차로 회귀.

---

## 5. 계약에 의한 설계와 서브타이핑

### 5.1 계약 (Contract)

메서드의 약속 — 사전조건·사후조건·불변식 (부록 A 에서 자세히).

### 5.2 서브타입과 계약

자식이 부모 대체하려면:
- **사전조건** = 부모와 같거나 **더 완화**.
- **사후조건** = 부모와 같거나 **더 강화**.
- **불변식** = 부모 것 유지.

→ "**자식은 더 받아들이고 더 보장한다**" — 공변/반공변 규칙.

---

## 핵심 교훈

1. **타입 = 같은 메시지를 받는 객체 집합** (OO 관점).
2. **서브클래싱 vs 서브타이핑** — 의도가 다름. 코드 재사용 vs 타입 호환.
3. **LSP** = 자식이 부모 대체 가능. 위배 시 다형성 무력화.
4. **is-a 의 OO 의미** = 행동 호환 + 타입 호환. 단순 분류 X.
5. **계약** = 사전·사후·불변 — 자식이 더 받아들이고 더 보장.

---

## 현업 예제 — JPA Entity 상속의 LSP

### 안티패턴

```java
@Entity @Inheritance(strategy = SINGLE_TABLE)
public class Account { ... }

@Entity
public class PremiumAccount extends Account {
    @Override
    public void deposit(Money amount) {
        if (amount.lessThan(Money.won(10000))) {
            throw new IllegalArgumentException();   // 부모보다 더 엄격한 사전조건 — LSP 위배
        }
        super.deposit(amount);
    }
}

// 클라이언트
void process(Account a) {
    a.deposit(Money.won(5000));   // PremiumAccount 면 예외 — 의도하지 않은 동작
}
```

→ `process` 가 모든 Account 를 같은 방식으로 처리한다고 가정. PremiumAccount 가 예외 던지면 클라이언트 깨짐. LSP 위배.

### 권장

- **상속 대신 합성** — `Account` + `MembershipPolicy` (Strategy).
- 또는 인터페이스 분리 (ISP).

---

## 함정 / 주의

- **is-a 만 보고 상속 결정** = LSP 위배 위험.
- **부모보다 엄격한 사전조건** = 가장 흔한 LSP 위배.
- **`UnsupportedOperationException` 던지는 자식** = 명백한 LSP 위배 (Stack·Properties 사례).
- **자식 타입 검사 (`instanceof`)** = 다형성 활용 실패 신호.

---

## 체크리스트

- [ ] 상속 사용 시 LSP 점검 — 자식이 부모를 대체 가능한가
- [ ] 자식이 부모보다 엄격한 사전조건을 강제하는가 (위배)
- [ ] 자식이 부모의 메서드 일부를 거부 (`UnsupportedOperationException`) 하는가
- [ ] 클라이언트가 `instanceof` 분기로 자식 구분하는가 (다형성 실패)
- [ ] 코드 재사용 목적이면 합성으로 갈아탈 수 있는가

---

## 퀴즈

1. **서브클래싱과 서브타이핑** 의 의도 차이는?
2. **LSP** 를 한 문장으로?
3. `Square extends Rectangle` 이 왜 LSP 위배인가?
4. **계약에 의한 설계** 에서 자식의 사전·사후조건 규칙은?
5. `UnsupportedOperationException` 던지는 자식이 LSP 명백 위배인 이유?

### 정답·해설

1. **서브클래싱** = 코드 재사용 (부모 코드 가져옴). **서브타이핑** = 타입 호환 (LSP 보장). 의도가 다름. 자바 `extends` 는 둘 다 가능 — 잘못 쓰면 서브클래싱 의도로 시작했다가 LSP 위배.
2. **자식 타입 객체는 부모 타입 객체로 대체 가능해야** (프로그램 정확성 유지하면서). 클라이언트는 실제 객체 타입 몰라도 됨.
3. **setWidth(5) 후 setHeight(4) 면 면적 20** 이 Rectangle 의 행동 약속. Square 는 width 와 height 가 같아야 한다는 불변식 — setHeight 가 width 도 바꿔야 약속 위배. 행동 호환 X.
4. **사전조건** = 부모와 같거나 더 **완화** (더 많이 받아들임). **사후조건** = 부모와 같거나 더 **강화** (더 많이 보장). 자식이 더 받고 더 주는 관계 — 공변/반공변.
5. **부모 메서드의 행동 약속** (예: `add(x)` 가 컬렉션에 추가) 을 자식이 거부 = 클라이언트 가정 깨뜨림. 클라이언트가 자식 타입 알아야 호출 가능 → 다형성 무력화.

---

## 다음 장 예고 — 14장: 일관성 있는 협력

15장의 디자인 패턴 전제. 같은 객체 협력 패턴을 반복 발견 → 일관된 협력 패턴으로 정형화. 패턴이 자연 도입되는 흐름.
