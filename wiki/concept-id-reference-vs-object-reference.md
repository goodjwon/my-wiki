---
title: ID 참조 vs 객체 참조 — 애그리거트 경계를 넘는 연결 방식
type: concept
tags: [ddd, aggregate, jpa, 트랜잭션, 객체설계]
sources: [object-dependency/id-reference-vs-object-reference.md]
created: 2026-08-10
updated: 2026-08-10
---

# ID 참조 vs 객체 참조

## 정의

객체가 연관 객체를 **메모리 주소(객체 참조)** 로 직접 쥘 것인가, **식별자 필드(예: `Long shopId`)** 로만 연결할 것인가의 선택입니다. 핵심 규칙은 한 줄입니다.

> **애그리거트 내부는 객체 참조로 빠르게 탐색하되, 애그리거트 경계를 가로지르는 협력은 오직 식별자(ID) 참조로만 연결합니다.**

경계를 어디에 긋는지는 [[concept-aggregate-boundary]], 끊어진 협력을 잇는 방법은 [[concept-domain-event-eventual-consistency]]에서 다룹니다.

## 객체 참조가 경계를 넘으면 무너지는 것

| 증상 | 메커니즘 | 결과 |
|------|----------|------|
| 트랜잭션 경계가 번짐 | 주문 완료 처리 중 무심코 가게 객체까지 같은 트랜잭션에서 수정 | 가게 행 잠금 장기화 → 같은 가게 주문 사용자 대기 |
| 조회가 무거워짐 | 연관이 얽힌 상태의 즉시 로딩 | 거대 조인 쿼리 |
| 조회가 무거워짐 (2) | 지연 로딩으로 회피 시 | N+1 쿼리 |

객체 참조는 초기 설계에서 직관적이고 빠르지만, 규모가 커지면 **쓰기 단위가 도메인 경계를 넘어 번지는 것** 자체가 동시성 병목의 원인이 됩니다.

## Before / After

객체 참조 (경계를 넘는 직접 연결):

```java
@Entity
public class Order {
    @ManyToOne(fetch = FetchType.LAZY)
    private Shop shop;                 // 다른 애그리거트를 주소로 직접 참조

    public void place() {
        if (!shop.isOpen()) {          // 편리하지만 —
            throw new IllegalStateException("영업 중이 아닙니다");
        }
        // 주문 트랜잭션 안에서 shop 변경까지 가능해져 버림
    }
}
```

ID 참조 (경계는 식별자로만):

```java
@Entity
public class Order {
    private Long shopId;               // 식별자만 보관 — 주소에 닿을 수 없음

    public void place() {
        // shop 객체가 없으므로 가게 검증은 여기서 불가능 → 아래 도메인 서비스로
        this.status = OrderStatus.PLACED;
    }
}
```

이렇게 하면 주문의 쓰기 단위가 자기 테이블로 압축되어, 다른 도메인 테이블의 쓰기 잠금을 건드리는 일이 설계 수준에서 사라집니다.

## 트레이드오프 — 빈약한 도메인 모델 함정

식별자로 바꾸는 순간, 객체 그래프를 타고 돌던 검증 로직이 컴파일 에러를 냅니다. 이 공백을 서비스 레이어에 리포지토리를 여러 개 주입해 절차지향으로 메우면 도메인이 빈껍데기(Anemic Domain Model)가 됩니다. 정석은 **별도 도메인 서비스로 중재**하는 것입니다.

```java
@Component
public class OrderValidator {          // 도메인 서비스 — 여러 애그리거트에 걸친 검증만 담당
    private final ShopRepository shopRepository;

    public void validate(Order order) {
        Shop shop = shopRepository.findById(order.getShopId())
                .orElseThrow(() -> new NoSuchElementException("가게 없음"));
        if (!shop.isOpen()) {
            throw new IllegalStateException("영업 중이 아닙니다");
        }
    }
}
```

검증 규칙 자체는 도메인 층에 남고, 애플리케이션 서비스는 `orderValidator.validate(order)` 한 줄만 호출합니다.

## 판단 기준 요약

| 관계 | 연결 방식 | 이유 |
|------|----------|------|
| 애그리거트 내부 (Order ↔ OrderLineItem) | 객체 참조 | 같은 라이프사이클·같은 트랜잭션 — 강결합이 정당 |
| 애그리거트 경계 밖 (Order → Shop, Menu) | ID 참조 | 트랜잭션·잠금·조회를 도메인 단위로 격리 |

## 같은 인사이트 패턴 — "편한 기본값은 규모에서 함정이 된다"

| 페이지 | 편한 기본값 | 규모에서의 함정 | 실무 권장 |
|--------|------------|----------------|----------|
| **이 페이지** | JPA `@ManyToOne` 객체 참조 | 트랜잭션 번짐·N+1·잠금 대기 | 경계 밖은 ID 참조 |
| [[concept-transactional-rollback-policy]] | `@Transactional` 기본 롤백 정책 | 체크 예외가 commit됨 | `rollbackFor = Exception.class` |
| [[concept-db-connection-pool]] | 무한 수명 커넥션 | DB `wait_timeout`과 충돌 | `maxLifetime` < `wait_timeout` |
| [[concept-varchar-length-prefix]] | 관습적 `VARCHAR(255)` | utf8mb4에서 인덱스 한계 초과 | `VARCHAR(63)` 또는 도메인 길이 |
| [[concept-cronjob-concurrency-trap]] | `concurrencyPolicy` 기본 `Allow` | 중복 실행 | `Forbid` + `activeDeadlineSeconds` |

→ 공통 원리: **직관적이라서 선택되는 기본 연결·기본 설정은 소규모에서만 무해합니다.** 규모의 어느 지점에서 무너지는지 알고, 무너지기 전에 경계를 다시 긋습니다.

## 빠른 진단

- "주문 저장했는데 가게 테이블 잠금이 잡혀 있다" → 트랜잭션이 경계를 넘고 있습니다.
- "목록 조회 한 번에 쿼리가 수십 개" → 경계 넘는 연관의 지연 로딩 (N+1).
- "연관 엔티티 하나 바꿨더니 컴파일 에러가 도메인 전체로 번진다" → 객체 참조 결합도가 경계를 넘은 상태.
- "서비스 레이어에 리포지토리가 5개씩 주입된다" → 빈약한 도메인 — 도메인 서비스 도입 시점.

## 원본 출처

- raw: `raw/object-dependency/id-reference-vs-object-reference.md` (블로그 글 유래 영속 개념 노트)
- 원 영상: 조영호, "우아한객체지향: 의존성을 이용해 설계 진화시키기" (우아한테크세미나, 2019)

## 관련 페이지

- [[concept-aggregate-boundary]] — 경계를 어디에 긋는가 (라이프사이클 기준)
- [[concept-domain-event-eventual-consistency]] — 끊어진 트랜잭션 연쇄를 이벤트로 잇기
- [[src-kakaopay-ddd]] — Aggregate Root = 트랜잭션 경계의 실무 사례
- [[entity-object]] — 조영호 *오브젝트* — 의존성 관리(8장)의 책 배경
- [[concept-db-connection-pool]] — 잠금 대기가 커넥션 풀 고갈로 이어지는 인프라 측면
