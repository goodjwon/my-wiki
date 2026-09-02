---
title: 애그리거트 경계 — 라이프사이클 기준으로 긋기
type: concept
tags: [ddd, aggregate, 도메인설계, 트랜잭션, jpa]
sources: [object-dependency/aggregate-boundary-lifecycle.md]
created: 2026-08-10
updated: 2026-08-10
---

# 애그리거트 경계 (Aggregate Boundary)

## 정의

애그리거트(Aggregate)는 **데이터 변경과 일관성을 함께 보장해야 하는 논리적 최소 단위**입니다. 문제는 "어디까지를 한 애그리거트로 묶을 것인가"인데, 가장 믿을 만한 기준은 **데이터의 라이프사이클과 수정 빈도**입니다.

| 판정 | 기준 | 예시 | 연결 방식 |
|------|------|------|----------|
| 한 애그리거트 | 생성·삭제 생명주기 일치 + 항상 한 단위로 취급 | 주문(Order)과 주문 항목(OrderLineItem) | 내부 객체 참조 — 강결합 정당 |
| 별도 애그리거트 | 독립적으로 수정·관리되는 자산 | 가게·메뉴 (관리자가 주문과 무관하게 수정) | ID 참조만 ([[concept-id-reference-vs-object-reference]]) |

## 코드로 보는 경계

한 애그리거트 내부 — 함께 태어나고 함께 사라지므로 강하게 묶습니다:

```java
@Entity
public class Order {                       // 애그리거트 루트
    @OneToMany(mappedBy = "order",
               cascade = CascadeType.ALL,  // 주문이 죽으면 항목도 죽음 — 같은 생명주기
               orphanRemoval = true)
    private List<OrderLineItem> lineItems = new ArrayList<>();

    private Long shopId;                   // 경계 밖(가게)은 식별자만
    private Long deliveryId;               // 경계 밖(배송)도 식별자만
}
```

`cascade` + `orphanRemoval`이 정당한 곳이 곧 애그리거트 내부이고, 그 바깥은 식별자 필드로만 잇습니다.

## 실전 해체 사례 — 주문 도메인 4분할

원본 글의 커머스 사례에서는 하나로 뭉쳐 있던 주문 도메인을 라이프사이클 기준으로 해체해 네 개의 독립 애그리거트로 분할했습니다.

| 애그리거트 | 라이프사이클 주도자 | 수정 시점 |
|-----------|--------------------|----------|
| 주문 (Order + OrderLineItem) | 구매자 | 주문 생성·취소 |
| 가게 (Shop) | 관리자 | 영업 정보 변경 — 주문과 무관 |
| 메뉴 (Menu) | 관리자 | 가격·품절 변경 — 주문과 무관 |
| 배송 (Delivery) | 배송 시스템 | 배송 상태 전이 — 주문 완료 후 |

## 왜 중요한가 — 경계 선긋기 = 동시성 격리

경계를 라이프사이클로 정확히 그으면, 각 애그리거트의 **쓰기 단위가 자기 테이블로 압축**됩니다. 하나의 트랜잭션이 다른 도메인 테이블의 쓰기 잠금을 건드리는 일이 사라지므로, 동시성 병목이 코드 튜닝이 아니라 **경계 설계 수준에서** 격리됩니다.

경계로 나뉜 애그리거트들이 다시 협력해야 할 때(주문 완료 → 배송 적재 → 정산)는 [[concept-domain-event-eventual-consistency]]의 도메인 이벤트로 잇습니다.

## 같은 인사이트 패턴 — "경계를 명시해야 격리가 생긴다"

| 영역 | 경계가 흐리면 | 경계를 그으면 | 참조 |
|------|--------------|--------------|------|
| **애그리거트** | 한 트랜잭션이 여러 도메인 테이블 잠금 | 쓰기 단위가 자기 테이블로 압축 | (이 페이지) |
| Bounded Context | 도메인 기능이 타 도메인에서 수행됨 | Gradle module 단위 명시적 경계 | [[src-kakaopay-ddd]] |
| 트랜잭션 경계 | 롤백 범위가 암묵적 | `@Transactional` 정책 명시 | [[concept-transactional-rollback-policy]] |
| LB ↔ 서버 | 타임아웃 계약이 암묵적 가정 | 서버 > LB 명시 계약 | [[concept-keepalive-timeout-race]] |

→ 공통 원리: **격리는 저절로 생기지 않고, 경계를 명시적으로 긋는 설계 행위에서 나옵니다.** 경계가 암묵적이면 언젠가 서로의 영역을 잠그거나 끊습니다.

## 빠른 진단

- "이 엔티티를 지우면 저 엔티티도 같이 지워야 하나?"가 애매하다 → 라이프사이클 기준으로 경계 재검토.
- 관리자 화면 수정이 주문 트랜잭션과 잠금 경합한다 → 독립 수정 자산이 같은 애그리거트에 묶여 있음.
- `cascade = ALL`이 경계 밖 엔티티에 걸려 있다 → 가장 위험한 신호 — 삭제가 도메인을 넘어 전파됩니다.

## 원본 출처

- raw: `raw/object-dependency/aggregate-boundary-lifecycle.md` (블로그 글 유래 영속 개념 노트)
- 원 영상: 조영호, "우아한객체지향: 의존성을 이용해 설계 진화시키기" (우아한테크세미나, 2019)

## 관련 페이지

- [[concept-id-reference-vs-object-reference]] — 경계를 넘는 연결은 ID로
- [[concept-domain-event-eventual-consistency]] — 경계로 나뉜 애그리거트 간 협력
- [[src-kakaopay-ddd]] — Aggregate Root·Bounded Context 실무 구현 (Kotlin + Spring Boot)
- [[entity-object]] — 조영호 *오브젝트* — 책임 주도 설계의 책 배경
