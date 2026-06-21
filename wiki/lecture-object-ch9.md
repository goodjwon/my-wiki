---
title: "오브젝트 실전 강의 — 9장"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 9장.md]
created: 2026-06-21
updated: 2026-06-21
---

# 오브젝트 실전 강의 교재

## 9장 — 유연한 설계

> **원서**: 조영호 『오브젝트』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 → 핵심 교훈 → 현업 예제 → 함정 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 8장의 의존성 관리를 **SOLID 의 OCP·DIP** 로 체계화.
- **생성과 사용 분리** — 객체 생성을 별도 책임으로.
- **Factory 패턴** + **DI** 의 조합.
- "**유연성은 필요할 때만**" — 추측성 일반화 회피.

### 0.2 큰 그림 — 유연성의 도구 사다리

```
[ 1단 ]                    [ 2단 ]                    [ 3단 ]
 OCP (개방-폐쇄)            DIP (의존성 역전)           생성/사용 분리
 추상 의존                  추상 ↔ 구체 의존 뒤집기      Factory + DI
 새 구현 추가에 무변경
```

> **비유 — "콘센트 표준"**
>
> 콘센트 (인터페이스) 가 표준이면 어떤 가전 (구현) 도 꽂힘. 새 가전 = 새 플러그 X, 기존 표준 사용. OCP·DIP 가 같은 정신.

### 0.3 현업에서 왜 중요한가

- SOLID 5원칙 중 OCP·DIP 의 깊이.
- Spring `@Configuration` + `@Bean` 이 정확히 9장의 구현.
- 추측성 일반화 (악취 [[entity-refactoring]] 3.15) 의 정확한 경계.

---

## 1. 개방-폐쇄 원칙 (OCP)

### 1.1 정의

> **확장에는 열려 있고, 변경에는 닫혀 있어야** (Bertrand Meyer, 1988).

- **확장에 열림** = 새 기능 (구현·정책) 추가 가능.
- **변경에 닫힘** = 기존 코드는 수정 안 함.

### 1.2 컴파일타임 의존성을 고정시키고 런타임 의존성을 변경하라

OCP 의 실천:
- 코드 (컴파일타임) 는 **추상** 에 의존 → 고정.
- 실제 객체 (런타임) 는 새 구현으로 **교체** → 변경.

```java
public class Movie {
    private DiscountPolicy policy;   // 컴파일타임 — 추상
}

// 새 정책 추가 — Movie 무변경
public class MembershipPolicy extends DiscountPolicy { ... }
```

### 1.3 추상화가 핵심이다

OCP 의 도구 = **추상화 (인터페이스·추상 클래스)**. 추상에 의존해야 새 구현 추가가 OCP 충족.

---

## 2. 생성과 사용 분리

### 2.1 객체 생성은 별도 책임

```java
// ❌ 생성 + 사용 섞임
public class OrderService {
    private final OrderRepository repo = new JpaOrderRepository(...);   // 생성
    public void process(Order o) {
        repo.save(o);   // 사용
    }
}

// ✅ 분리
public class OrderService {
    private final OrderRepository repo;
    public OrderService(OrderRepository repo) { this.repo = repo; }   // 받음
    public void process(Order o) { repo.save(o); }   // 사용
}

// 생성 책임은 외부
new OrderService(new JpaOrderRepository(...));   // 또는 Spring @Configuration
```

### 2.2 Factory 추가하기

생성 책임이 복잡하면 **Factory** 클래스:

```java
public class MovieFactory {
    public Movie createMovie(MovieType type, ...) {
        return switch (type) {
            case AMOUNT -> new Movie(..., new AmountDiscountPolicy(...));
            case PERCENT -> new Movie(..., new PercentDiscountPolicy(...));
            case NONE -> new Movie(..., new NoneDiscountPolicy());
        };
    }
}
```

→ Movie 사용자는 Factory 만 호출. 정책 종류 모름.

### 2.3 순수한 가공물에게 책임 할당하기

Factory 는 도메인 단어 아닌 **순수 가공물** (GRASP 패턴). 도메인에 없어도 책임 분리·재사용 가치로 정당.

---

## 3. 의존성 주입 (DI)

### 3.1 세 가지 형태

| 형태 | 예 | 권장도 |
|------|----|--------|
| **생성자 주입** | `new Service(repo)` | ★★★ 권장 |
| **세터 주입** | `service.setRepo(repo)` | ★ 선택적 의존만 |
| **메서드 매개변수** | `service.process(order, repo)` | ★★ 임시 협력 |

### 3.2 숨겨진 의존성은 나쁘다

```java
// ❌ 숨김 — 정적 호출
public class OrderService {
    public void process(Order o) {
        SecurityContext.getCurrentUser();   // 정적 — 의존성 코드에 안 보임
    }
}

// ✅ 명시
public class OrderService {
    private final SecurityContext context;
    public OrderService(SecurityContext context) { this.context = context; }
}
```

→ 생성자에 모든 의존이 명시. 사용자가 한눈에 인지. 테스트 자유.

---

## 4. 의존성 역전 원칙 (DIP)

### 4.1 정의

> **상위 모듈이 하위 모듈에 의존하면 안 된다. 둘 다 추상에 의존해야**.
> **추상이 구체에 의존하면 안 된다. 구체가 추상에 의존해야**.

### 4.2 추상화와 의존성 역전

```
[ 전통 ]                          [ DIP ]
 OrderService → JpaRepository      OrderService → OrderRepository
   (상위)         (하위 구체)         (상위)         (추상)
                                                    ↑
                                    JpaRepository implements OrderRepository
                                       (하위 구체)
```

→ 화살표 방향이 뒤집힘 (역전).

### 4.3 의존성 역전 원칙과 패키지

같은 패키지에 추상 (인터페이스) + 구체 둘 다 두면 의존성 역전이 의미 없음. **추상은 상위 패키지에, 구체는 하위 패키지에**:

```
domain/                  # OrderService, OrderRepository (interface)
infrastructure/jpa/      # JpaOrderRepository (구체)
infrastructure/redis/    # RedisOrderRepository (구체)
```

→ domain 패키지는 infrastructure 를 모름. 의존성 화살표 = infrastructure → domain.

---

## 5. 유연성에 대한 조언

### 5.1 유연한 설계는 유연성이 필요할 때만 옳다

> **사용 사례 1개로 인터페이스·추상 클래스 도입 = 추측성 일반화** (악취 [[entity-refactoring]] 3.15).

YAGNI 정신. **변경이 잦다는 증거** 가 있을 때 추상화.

### 5.2 협력과 책임이 중요하다

추상화·OCP·DIP 는 도구. 진짜 목표는 **좋은 협력 + 책임 할당**. 도구가 목표를 가리지 않도록.

---

## 핵심 교훈

1. **OCP** — 확장에 열림, 변경에 닫힘. 추상 의존이 도구.
2. **DIP** — 추상이 구체에 의존 X, 구체가 추상에 의존.
3. **생성과 사용 분리** — Factory + DI 의 조합.
4. **명시적 의존성** (생성자 주입) — 숨김 의존 회피.
5. **유연성은 필요할 때만** — 사용 사례 1개로 추상화 X.

---

## 현업 예제 — Spring @Configuration

```java
@Configuration
public class AppConfig {

    @Bean
    public OrderRepository orderRepository(DataSource ds) {
        return new JpaOrderRepository(ds);   // 구체 생성
    }

    @Bean
    public OrderService orderService(OrderRepository repo) {
        return new OrderService(repo);   // 추상 주입
    }
}
```

→ Spring 컨테이너가 **생성 책임** (Factory) + **DI 책임** 을 자동화. OrderService 는 추상에만 의존, 생성 모름.

---

## 함정 / 주의

- **인터페이스 첫 도입 도그마** — 구현이 1개뿐이면 의미 없음. *Effective Java* Item 20 (인터페이스 우선) 도 다중 구현 가능성 있을 때.
- **DI 컨테이너 (Spring) 없이 테스트 불가** = 너무 의존. 도메인 객체는 Spring 없이도 테스트 가능해야.
- **모든 곳에 Factory** = 과한 설계. 단순 생성은 직접 `new` OK.
- **DIP 의 패키지 분리** 가 모놀리스에는 과할 수 있음 — 충분히 큰 시스템에 도입.

---

## 체크리스트

- [ ] 새 구현 추가 시 기존 코드 무변경인가 (OCP)
- [ ] 도메인 객체가 인프라 (DB·HTTP) 에 직접 의존하는가 (DIP 위배)
- [ ] 생성 코드와 사용 코드가 분리되어 있는가
- [ ] 단일 구현 인터페이스를 도입하지 않았는가 (추측성 일반화)
- [ ] Spring 없이 도메인 객체를 테스트 가능한가

---

## 퀴즈

1. **OCP** 를 한 문장으로?
2. **DIP** 가 의존성 화살표를 뒤집는다는 의미?
3. **생성과 사용 분리** 의 이점?
4. "유연성은 필요할 때만" 의 실천 기준?
5. Spring `@Configuration` 이 9장의 어떤 원리?

### 정답·해설

1. **확장에 열림, 변경에 닫힘**. 새 기능 추가는 새 클래스로 (확장), 기존 코드는 수정 안 함 (닫힘). 도구는 추상화.
2. **전통은 상위 → 하위 구체**. DIP 는 **상위 → 추상 ← 구체 (역전)**. 구체가 추상을 구현 (의존). 결과: 상위 모듈이 하위 구체에 결합 X.
3. **(1) 사용 코드가 단순** — 생성 책임 X. **(2) 생성 정책 교체 자유** — 운영/테스트/다른 환경. **(3) 테스트 mock 주입 가능**.
4. **사용 사례 2개 이상 + 변경 잦다는 증거**. 1개로 인터페이스 도입 = 추측성 일반화. *리팩터링* "3의 법칙" — 세 번째에 추상화.
5. **생성과 사용 분리** + **DI** + **Factory**. `@Configuration` + `@Bean` 이 Factory, 컨테이너가 DI 자동. 사용자 (Service) 는 추상에만 의존.

---

## 다음 장 예고 — 10장: 상속과 코드 재사용

상속을 통한 재사용의 매력 — 그러나 함정. **취약한 기반 클래스 문제**, **DRY 의 함정**, **차이에 의한 프로그래밍**. 11장 "합성과 유연한 설계" 의 전제.
