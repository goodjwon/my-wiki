---
title: "SOLID 5원칙 — 오브젝트 책 관점의 심화"
type: concept
tags: [solid, oop, design, srp, ocp, lsp, isp, dip, object, robert-c-martin]
sources: [object/오브젝트 실전 강의 교재 9장.md, object/오브젝트 실전 강의 교재 13장.md]
created: 2026-07-04
updated: 2026-07-04
---

# SOLID 5원칙 — 오브젝트 책 관점의 심화

## 정의

SOLID 는 객체지향 설계의 5가지 원칙(SRP·OCP·LSP·ISP·DIP)을 Robert C. Martin 이 묶은 두문자입니다. 다섯 원칙은 각각 독립된 규칙이 아니라 하나의 질문에 대한 다섯 방향의 답입니다 — **"변경이 왔을 때 코드 수정 범위를 어떻게 최소로 만들 것인가."** [[concept-oop]] 의 SOLID 요약 표가 한 줄 암기용이라면, 이 페이지는 조영호 *오브젝트* 9장(OCP·DIP)·13장(LSP)의 관점을 축으로 원칙별 Before/After 와 원칙 간 관계까지 다루는 심화 페이지입니다.

규모 있는 주방을 떠올려 봅시다. 각 조리대는 요리 한 종류만 맡고, 새 메뉴가 생기면 기존 조리대를 뜯는 대신 새 레시피 카드를 한 장 더 꽂습니다. 어떤 보조 요리사가 투입되더라도 같은 레시피 카드를 받으면 같은 맛을 내야 하고, 홀 직원에게는 주문서 양식만 건네지 조리 매뉴얼 전체를 외우게 하지 않습니다. 헤드 셰프는 특정 납품업체 이름이 아니라 "1등급 한우" 라는 규격으로 발주합니다.

이 주방의 규칙이 그대로 다섯 원칙입니다. 조리대 하나가 요리 한 종류만 맡는 배치가 SRP 이고, 레시피 카드를 꽂아 메뉴를 늘리는 방식이 OCP 입니다. 누가 와도 같은 카드로 같은 맛을 내야 한다는 요구가 LSP 이고, 홀 직원에게 주문서 양식만 건네는 절제가 ISP 이며, 업체 이름 대신 규격으로 발주하는 습관이 DIP 입니다.

> **출처 구분** — *오브젝트* 는 OCP·DIP(9장)와 LSP(13장)를 본문에서 직접 다루지만, **SRP·ISP 는 책이 정면으로 다루지 않습니다**. 이 페이지의 SRP·ISP 절은 Robert C. Martin 원전(*Agile Software Development: PPP*, 2002 / ISP 논문, 1996) 기준으로 보완한 서술입니다.

## 5원칙 종합 표

| 원칙 | 한 줄 정의 | 위반 신호 | 해결 수단 |
|------|-----------|----------|----------|
| **SRP** (단일 책임) | 클래스의 변경 이유는 하나여야 | 한 클래스가 서로 다른 이유(정책·저장·알림)로 반복 수정됨 | 변경 이유별 클래스 분리 |
| **OCP** (개방-폐쇄) | 확장에 열리고 변경에 닫혀야 | 새 기능마다 기존 switch/if 에 분기 추가 | 추상화 + 컴파일타임 의존 고정 |
| **LSP** (리스코프 치환) | 자식은 부모 자리를 대체할 수 있어야 | 자식이 예외를 던지거나 클라이언트가 `instanceof` 분기 | 행동 호환 검증, 안 되면 합성 |
| **ISP** (인터페이스 분리) | 클라이언트가 안 쓰는 메서드에 의존하게 강제하지 말아야 | 빈 구현·`UnsupportedOperationException` 스텁 | 클라이언트 기대별 인터페이스 분리 |
| **DIP** (의존성 역전) | 상위·하위 모두 추상에 의존해야 | 도메인 코드가 인프라 구체 클래스를 import | 추상 소유권을 상위 패키지로 |

## 1. SRP — 단일 책임 원칙 (Martin 원전 보완)

> "A class should have only one reason to change." — Robert C. Martin, *Agile Software Development: PPP* (2002). 이후 *Clean Architecture* (2017)에서 "모듈은 단 하나의 액터에 대해서만 책임진다" 로 재정의.

핵심은 "기능 1개" 가 아니라 **변경 이유 1개**입니다. 주문 정책 변경·저장 방식 변경·알림 채널 변경이 모두 한 클래스를 건드리면 위반입니다.

```java
// Before — 변경 이유 3개가 한 클래스에
public class OrderProcessor {
    public void process(Order order) {
        validate(order);                      // 이유 1: 주문 정책 변경
        jdbcTemplate.update("INSERT ...");    // 이유 2: 저장 방식 변경
        mailSender.send(order.buyerEmail());  // 이유 3: 알림 채널 변경
    }
}

// After — 이유별 분리, OrderProcessor 는 흐름 조율만
public class OrderProcessor {
    private final OrderValidator validator;
    private final OrderRepository repository;
    private final OrderNotifier notifier;
    public void process(Order order) {
        validator.validate(order);
        repository.save(order);
        notifier.notifyPlaced(order);
    }
}
```

→ *오브젝트* 의 언어로 옮기면 SRP 는 "책임 주도 설계에서 응집도 높은 책임 할당"과 같은 이야기입니다. [[entity-object]] 의 "행동이 상태를 결정한다"가 책임의 경계를 긋는 기준이 됩니다.

## 2. OCP — 개방-폐쇄 원칙 (오브젝트 9장)

> "확장에는 열려 있고, 변경에는 닫혀 있어야 한다." — Bertrand Meyer, *Object-Oriented Software Construction* (1988). Martin 이 다형성 기반으로 재해석해 SOLID 에 편입.

*오브젝트* 9장의 강조점은 실천법입니다 — **컴파일타임 의존성(추상)은 고정하고, 런타임 의존성(구체 객체)만 교체합니다**. OCP 의 도구는 추상화이고, 추상화 없이는 열 수도 닫을 수도 없습니다([[lecture-object-ch9]] §1).

```java
// Before — 새 정책마다 기존 switch 수정 (변경에 열려 있음)
public class Movie {
    public Money discount(MovieType type) {
        return switch (type) {
            case AMOUNT -> fee.minus(discountAmount);
            case PERCENT -> fee.minus(fee.times(percent));
        };  // 멤버십 정책 추가 → 이 코드 수정
    }
}

// After — 컴파일타임엔 추상만, 새 정책은 새 클래스로 (확장에 열림)
public class Movie {
    private final DiscountPolicy policy;   // 추상에 고정
    public Money discount() { return policy.calculate(this); }
}
class MembershipPolicy implements DiscountPolicy { /* Movie 무변경 추가 */
    public Money calculate(Movie movie) { return Money.won(2000); }
}
```

→ 단, 9장의 경고를 함께 기억해야 합니다 — **유연성은 필요할 때만**. 사용 사례 1개로 인터페이스를 도입하면 추측성 일반화([[entity-refactoring]] 악취 3.15)입니다.

## 3. LSP — 리스코프 치환 원칙 (오브젝트 13장)

> "Let φ(x) be a property provable about objects x of type T. Then φ(y) should be true for objects y of type S where S is a subtype of T." — Barbara Liskov & Jeannette Wing, *A Behavioral Notion of Subtyping* (ACM TOPLAS, 1994). 1987년 Liskov 기조연설에서 출발.

*오브젝트* 13장의 강조점은 **클라이언트 관점의 행동 호환성**입니다. is-a 가 문법적으로 성립해도(서브클래싱), 클라이언트가 부모에게 기대하는 행동 약속을 자식이 지키지 못하면(서브타이핑 실패) 다형성이 무너집니다. 계약으로 말하면 자식의 사전조건은 부모와 같거나 더 완화, 사후조건은 같거나 더 강화여야 합니다.

```java
// Before — 자식이 부모보다 엄격한 사전조건 강제 (13장 현업 예제)
public class PremiumAccount extends Account {
    @Override
    public void deposit(Money amount) {
        if (amount.lessThan(Money.won(10000)))
            throw new IllegalArgumentException();  // 부모엔 없던 제약 — LSP 위배
        super.deposit(amount);
    }
}
// 클라이언트: void run(Account a) { a.deposit(Money.won(5000)); }  ← Premium 이면 폭발

// After — 상속 대신 합성: 정책 차이를 Strategy 로 분리
public class Account {
    private final DepositPolicy policy;   // Standard / Premium 정책 주입
    public void deposit(Money amount) {
        policy.check(amount);              // 계약 차이는 정책 객체의 명시적 책임
        this.balance = this.balance.plus(amount);
    }
}
```

→ `Square extends Rectangle` 예제는 [[concept-oop]] 에 이미 있으므로 여기서는 계좌 예제로 통일했습니다. `UnsupportedOperationException` 을 던지는 자식, 클라이언트의 `instanceof` 분기가 대표 위반 신호입니다.

## 4. ISP — 인터페이스 분리 원칙 (Martin 원전 보완)

> "Clients should not be forced to depend upon interfaces that they do not use." — Robert C. Martin, *The Interface Segregation Principle* (1996, Xerox 프린터 시스템 컨설팅에서 도출).

*오브젝트* 가 ISP 를 정면으로 다루지는 않지만, 13장 §3.4 "클라이언트의 기대에 따라 계층 분리하기"가 정확히 같은 처방입니다 — 인터페이스의 크기는 구현체가 아니라 **클라이언트의 기대**가 정합니다.

```java
// Before — 읽기 전용 클라이언트도 쓰기 메서드에 의존 강제
public interface CacheStore<K, V> {
    V get(K key);
    void put(K key, V value);
    void evictAll();   // 조회 화면 코드가 이 메서드까지 알게 됨
}

// After — 클라이언트 기대별 분리 (13장 §3.4 ReadableMap/WritableMap 구도)
public interface ReadableStore<K, V> {
    V get(K key);
}
interface WritableStore<K, V> extends ReadableStore<K, V> {
    void put(K key, V value);
    void evictAll();
}
// 조회 클라이언트는 ReadableStore 만 의존 → 쓰기 API 변경이 전파되지 않음
```

→ 위반의 냄새는 구현체 쪽에서 납니다 — 인터페이스 메서드 절반이 빈 구현이거나 `UnsupportedOperationException` 스텁이면 인터페이스가 뚱뚱한 것입니다.

## 5. DIP — 의존성 역전 원칙 (오브젝트 9장)

> "상위 모듈이 하위 모듈에 의존해서는 안 되며, 둘 다 추상에 의존해야 한다. 추상이 구체에 의존해서는 안 되며, 구체가 추상에 의존해야 한다." — Robert C. Martin. *오브젝트* 9장 §4 가 같은 정의를 패키지 구조까지 확장.

*오브젝트* 9장의 강조점은 **의존성 화살표의 방향**과 **추상의 소유권**입니다. 상위 수준(도메인)이 하위 수준(인프라)을 알면 하위의 변경이 상위로 역류합니다. 인터페이스를 하위 패키지에 두면 역전이 무효가 되므로, 추상은 상위 패키지가 소유해야 합니다.

```java
// Before — 도메인이 인프라 구체를 직접 의존 (화살표: domain → infrastructure)
public class SettlementService {
    private final JpaLedgerRepository repository = new JpaLedgerRepository();
}

// After — 추상은 domain 패키지 소유, 구체가 추상을 구현 (화살표 역전)
// domain 패키지
public class SettlementService {
    private final LedgerRepository repository;   // domain 이 소유한 추상
    public SettlementService(LedgerRepository repository) { this.repository = repository; }
}
// infrastructure 패키지 — infrastructure → domain 방향으로만 의존
class JpaLedgerRepository implements LedgerRepository { /* JPA 세부 */ }
```

→ Spring `@Configuration` + `@Bean` 이 이 구도의 자동화입니다 — 컨테이너가 생성과 주입을 맡아 도메인은 추상만 봅니다([[concept-spring-core]]).

## 원칙 간 관계 — 다섯이 하나의 기계

다섯 원칙은 서로의 전제이자 수단입니다.

| 관계 | 풀이 |
|------|------|
| **SRP → OCP** | SRP 가 변경 이유의 축을 하나로 좁혀 줘야, OCP 가 "무엇에 대해 닫을지"가 명확해집니다 |
| **DIP → OCP** | 의존 방향을 추상으로 뒤집는 DIP 가 OCP 의 실현 수단입니다. 구체에 의존한 채로는 확장이 곧 수정입니다 |
| **LSP → OCP** | OCP 는 새 구현이 기존 계약대로 행동한다는 가정 위에 섭니다. LSP 가 깨지면 클라이언트에 `instanceof` 분기가 생겨 폐쇄가 무너집니다 — **LSP 는 OCP 의 전제** |
| **ISP → DIP** | DIP 로 추상에 의존하더라도 그 추상이 뚱뚱하면 무관한 변경이 전파됩니다. ISP 가 의존할 추상의 폭을 클라이언트 기대만큼 좁혀 줍니다 |

→ 요약하면 **SRP 가 축을 긋고, ISP 가 폭을 좁히고, DIP 가 방향을 뒤집고, LSP 가 행동을 보증해야, 비로소 OCP(수정 없는 확장)가 성립합니다**. SOLID 의 목적지는 OCP 하나이고 나머지 넷은 그 조건입니다.

## 같은 인사이트 패턴 — "변경의 방향을 미리 설계에 반영"

| 영역 | 변경을 어디에 흡수하는가 | 강제 수단 | 참조 |
|------|--------------------------|----------|------|
| **SOLID (이 페이지)** | 새 요구를 "새 클래스 추가"로 흡수, 기존 코드는 무변경 | 추상화 + 의존 방향 규율 | — |
| **전략 패턴 (디자인 패턴)** | 교체될 알고리즘을 인터페이스 뒤로 격리 | 런타임 객체 교체 | [[concept-design-patterns]] |
| **제네릭 PECS** | API 매개변수의 읽기/쓰기 방향을 시그니처에 새김 | 컴파일러 타입 검사 | [[concept-generics-pecs]] |

→ 공통 원리는 같습니다 — **어떤 변경이 올지 예측해 그 방향을 설계 구조에 미리 새겨 두면, 변경이 실제로 왔을 때 코드 수정이 아니라 "추가"나 "교체"로 끝납니다**. SOLID 는 이를 클래스·패키지 규율로, 전략 패턴은 객체 교체로, PECS 는 타입 시스템으로 강제합니다.

## 빠른 진단 체크리스트

- [ ] 최근 3번의 수정에서 같은 클래스를 서로 다른 이유로 고쳤는가 (SRP 위반)
- [ ] 새 유형 추가 시 기존 switch/if 를 수정했는가 (OCP 위반)
- [ ] 자식 클래스가 부모에 없던 예외·제약을 추가했는가, 클라이언트에 `instanceof` 가 있는가 (LSP 위반)
- [ ] 인터페이스 구현체에 빈 메서드나 `UnsupportedOperationException` 스텁이 있는가 (ISP 위반)
- [ ] 도메인 패키지가 인프라 구체 클래스를 import 하는가, 인터페이스가 구현체와 같은 패키지에 있는가 (DIP 위반)
- [ ] 반대로 — 사용 사례 1개뿐인데 인터페이스부터 도입했는가 (추측성 일반화, 9장의 경고)

## 원본 출처

- raw: `raw/object/오브젝트 실전 강의 교재 9장.md` (OCP·DIP·생성과 사용 분리)
- raw: `raw/object/오브젝트 실전 강의 교재 13장.md` (서브클래싱 vs 서브타이핑·LSP·계약)
- Liskov & Wing, [A Behavioral Notion of Subtyping (ACM TOPLAS, 1994)](https://dl.acm.org/doi/10.1145/197320.197383) — LSP 원문
- Robert C. Martin, *Agile Software Development: Principles, Patterns, and Practices* (2002) — SRP·ISP·DIP 원전, [SRP 정리 (Wikipedia)](https://en.wikipedia.org/wiki/Single-responsibility_principle)
- Bertrand Meyer, *Object-Oriented Software Construction* (1988) — OCP 최초 정의

## 관련 페이지

- [[lecture-object-ch9]] — 유연한 설계 (OCP·DIP 의 원 재료, Factory·DI 까지)
- [[lecture-object-ch13]] — 서브클래싱과 서브타이핑 (LSP 의 원 재료, 계약에 의한 설계)
- [[concept-oop]] — OOP 4원칙 + SOLID 한 줄 요약 표 (이 페이지의 입문판)
- [[entity-object]] — 조영호 *오브젝트* (책 전체 지도, 이 페이지는 그중 9·13장 응축)
- [[guide-code-authoring-and-review]] — 코드 작성·리뷰 가이드 (원칙 2 "추상에 의존"·LSP 위배 High 심각도)
- [[concept-design-patterns]] — 전략·팩터리 등 SOLID 를 구조로 정형화한 23패턴
- [[concept-generics-pecs]] — 공변/반공변을 타입으로 강제 (LSP 계약 규칙의 타입 시스템 판)
- [[concept-spring-core]] — Spring DI 컨테이너 = DIP·OCP 의 산업 표준 구현
- [[entity-effective-java]] — Item 18 (상속보다 합성)·Item 20 (인터페이스 우선) 이 LSP·DIP 의 실전 권고
