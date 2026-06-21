---
title: "Clean Code 실전 강의 — 10장"
type: source
tags: [book, clean-code, uncle-bob, lecture]
sources: [clean-code/클린 코드 실전 강의 교재 10장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 클린 코드 실전 강의 교재

## 10장 — 클래스

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- **클래스 체계** — 표준 멤버 순서.
- **클래스는 작아야 한다** — 함수와 같은 규율, 다른 단위.
- **단일 책임 원칙(SRP)** — 가장 자주 인용되는 OO 원칙.
- **응집도(Cohesion)** — 작은 클래스 여럿이 나오는 자연스러운 결과.
- **변경하기 쉬운 클래스** — 변경으로부터 격리.

### 0.2 큰 그림

```
[ 체계 ]                  [ 크기·응집 ]                    [ 변경 격리 ]
 10.1 클래스 체계          10.2 클래스는 작아야 한다         10.3 변경 격리
   캡슐화                  10.2.1 SRP                       10.3.1 OCP·DIP
                          10.2.2 응집도
                          10.2.3 작은 클래스 여럿
```

> **비유 — 클래스는 "방"입니다.**
>
> 한 방에 너무 많은 물건이 있으면 (거대 클래스) 찾기 어렵고 정리 안 됨. 방을 작게 여러 개 (작은 클래스 여럿) — 침실·서재·주방·욕실 — 이 더 명료. **응집도 높은 작은 방**.

### 0.3 현업에서 왜 중요한가

- *Effective Java* Item 15·17·18·20·25 (접근 최소화·불변·컴포지션·인터페이스·정적 멤버 클래스) 와 일관.
- *오브젝트* 4·5장 (책임 주도 설계) 와 직결.
- Spring `@Service` 가 1,000줄 넘어가는 사고 단골 — 10장이 처방.

---

## 10.1 클래스 체계

### 표준 순서 (Java 관례)

```java
public class Foo {
    // 1. static 공개 상수
    public static final int MAX = 100;

    // 2. static 비공개 변수
    private static int counter;

    // 3. 인스턴스 비공개 변수
    private String name;
    private int age;

    // 4. 생성자
    public Foo(String name) { ... }

    // 5. public 메서드 (대중을 위한)
    public void doSomething() { ... }

    // 6. private 메서드 (호출하는 public 메서드 바로 아래에 둠 — 내려가기 규칙)
    private void helper() { ... }
}
```

### 캡슐화

- 변수·유틸 메서드는 **private 기본**.
- 테스트를 위해 **protected/package-private** 까지 풀어도 OK (그 이상은 신중).
- **public 필드는 거의 없어야**.

---

## 10.2 클래스는 작아야 한다!

### 한 줄 정의

함수와 같은 규율 — 작아야 한다. **얼마나 작아야?** 측정 단위가 다름.

- 함수: **줄 수**
- 클래스: **책임 수** (메서드 수가 아님)

### 10.2.1 단일 책임 원칙 (SRP)

> "클래스는 **변경할 이유가 하나** 여야 한다."

`SuperDashboard` 라는 GUI 클래스에 70+ public 메서드 — 너무 많은 책임. SRP 위배.

**처방**: 작은 클래스 여럿으로 분리.

### Naming 가이드

- 이름이 **모호** ("Processor", "Manager", "Super") → 책임 모호 신호.
- 이름이 **and / or / but** 으로 책임을 묘사하면 → 분리 후보.

### 10.2.2 응집도 (Cohesion)

> 한 클래스의 모든 메서드가 그 클래스의 모든 인스턴스 변수를 사용 → **최대 응집**.

```java
// 응집도 높음
public class Stack {
    private List<Integer> elements;
    public void push(int e) { elements.add(e); }     // elements 사용
    public int pop() { return elements.removeLast(); } // elements 사용
    public int size() { return elements.size(); }    // elements 사용
}
```

응집도가 떨어지면 → 일부 메서드가 일부 변수만 사용 → **사실 두 클래스가 한 곳에 있음**.

### 10.2.3 응집도를 유지하면 작은 클래스 여럿이 나온다

큰 함수를 작은 함수로 추출하면 → 일부 변수가 일부 함수만 사용 → **그 묶음이 새 클래스**.

```java
// 작게 추출하다 보면 자연스럽게 발견:
// "이 5개 함수와 2개 변수는 사실 별도 클래스"
// → 클래스 추출
```

→ [[entity-refactoring]] 7.5 클래스 추출과 동일한 흐름.

---

## 10.3 변경하기 쉬운 클래스

### 한 줄 정의

**OCP (개방-폐쇄 원칙)** — 새 기능 추가는 확장으로, 기존 코드 변경은 최소.

### 10.3.1 변경으로부터 격리

**구체 클래스 의존 → 인터페이스 의존** (DIP, Dependency Inversion).

```java
// Before — Sql 구체 클래스 의존
public class Portfolio {
    private TokyoStockExchange exchange;   // 외부 API에 직접 결합
    public Money value() {
        return exchange.getCurrentValue(symbol);
    }
}

// After — 인터페이스 의존
public class Portfolio {
    private StockExchange exchange;
    public Portfolio(StockExchange exchange) { this.exchange = exchange; }
    public Money value() {
        return exchange.getCurrentValue(symbol);
    }
}

public interface StockExchange {
    Money getCurrentValue(String symbol);
}

// 테스트
public class FixedStockExchange implements StockExchange {
    public Money getCurrentValue(String symbol) { return Money.won(100); }
}
```

→ 테스트 자유, 외부 API 교체 자유. *Effective Java* Item 64 (인터페이스 참조) 와 같은 결.

---

## 핵심 교훈

1. **클래스 크기는 책임 수** 로 잰다 (메서드 수 X).
2. **SRP** — 변경 이유가 하나.
3. **응집도** 가 떨어지면 새 클래스 추출 신호.
4. **인터페이스 의존** 으로 변경 격리 + 테스트 자유.
5. **이름이 모호** 하면 책임이 모호.

---

## 함정 / 주의

- "작은 클래스" 도그마 → 너무 잘게 쪼개면 오히려 추적 어려움. **응집도 + 변경 이유** 기준.
- DI 컨테이너 (Spring) 없이 인터페이스 의존만 도입하면 객체 그래프 복잡도 폭증.
- SRP가 "클래스 메서드 5개 이하" 같은 숫자 규칙 아님 — **변경 이유** 가 본질.

---

## 체크리스트 (코드 리뷰용)

- [ ] 클래스 이름이 모호(Manager·Processor) 한가
- [ ] 한 클래스에 변경 이유가 둘 이상인가
- [ ] 일부 메서드가 일부 변수만 사용하는가 (응집도 낮음)
- [ ] 구체 클래스에 직접 의존하는가 → 인터페이스 검토
- [ ] 테스트 시 mock 주입이 어려운가 (= 결합도 신호)
- [ ] Service가 1,000줄 넘는가

---

## 퀴즈

**Q1. 클래스 크기를 "메서드 수" 가 아닌 "책임 수" 로 재는 이유?**

**A.** 메서드 5개여도 그 5개가 서로 다른 책임이면 SRP 위배. 메서드 30개여도 모두 한 책임의 다양한 면이면 응집된 큰 클래스. **변경 이유의 수** 가 본질.

**Q2. 응집도가 낮은 클래스를 어떻게 발견?**

**A.** **일부 메서드가 일부 변수만 사용** 하는 패턴. 그 묶음 (일부 메서드 + 일부 변수) 이 사실 별도 클래스의 후보. *리팩터링* 7.5 클래스 추출이 자연 처방.

**Q3. SRP의 "변경 이유 하나" 가 실무에서 의미하는 바?**

**A.** 한 클래스가 **두 가지 이해관계자** 의 요구로 변경되면 SRP 위배. 예: Report 클래스가 회계 요구로도, 마케팅 요구로도 변경됨 → 두 클래스로 분리.

**Q4. 인터페이스 의존이 "변경 격리" 인 이유?**

**A.** 구현체가 바뀌어도 인터페이스가 같으면 호출자 코드 무변경. 테스트 시 mock 구현 주입 자유. *Effective Java* Item 64·*리팩터링* 12.10·[[concept-spring-core]] DI 와 같은 메시지.

**Q5. Spring `@Service` 가 1,000줄 넘으면 거의 확실히 어떤 악취인가?**

**A.** **거대 클래스** ([[entity-refactoring]] 3.20) + SRP 위배. 한 서비스가 여러 비즈니스 사용 사례를 다 처리 중. 사용 사례별로 작은 서비스 여러 개로 분리.

---

## 다음 장 예고 — 11장: 시스템

**제작과 사용의 분리, 의존성 주입, 횡단 관심사(AOP)** — 큰 그림. 도시처럼 시스템도 추상화 계층으로 관리해야 한다는 메시지. Spring 의 IoC·AOP 가 정확히 이 장의 구현체.
