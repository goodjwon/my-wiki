---
title: 도메인 이벤트와 최종 일관성 — 애그리거트 간 비동기 협력
type: concept
tags: [ddd, domain-event, eventual-consistency, spring, 트랜잭션]
sources: [object-dependency/domain-event-eventual-consistency.md]
created: 2026-08-10
updated: 2026-08-10
---

# 도메인 이벤트와 최종 일관성

## 정의

애그리거트를 ID 참조로 분리하면([[concept-id-reference-vs-object-reference]]) 조회·잠금 문제는 풀리지만, 예전에 한 트랜잭션으로 흐르던 **상태 연쇄**(결제 완료 → 배송 적재 → 정산 갱신)가 끊깁니다. 이 공백을 메우는 것이 **도메인 이벤트(Domain Event)** 입니다.

1. 주문 애그리거트는 결제 승인이 끝나면 **자기 트랜잭션만 깔끔히 커밋**하고 "주문 완료" 이벤트를 발행합니다.
2. 정산·배송 시스템은 그 이벤트를 **구독**해 각자 **독립 트랜잭션**으로 후속 작업을 처리합니다.
3. 시스템 간 상태는 즉시가 아니라 **최종 일관성(Eventual Consistency)** 으로 수렴합니다. 정산 서버가 잠깐 죽어도 사용자의 주문 완료는 즉시 성공합니다.

## Spring 구현 — 커밋 이후에 전파하기

핵심은 **주문 트랜잭션이 실제로 커밋된 뒤에만** 후속 작업이 시작되게 하는 것입니다. `@TransactionalEventListener`가 그 역할을 합니다.

```java
// 발행 측 — 주문 애플리케이션 서비스
@Service
public class OrderService {
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public void completePayment(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.complete();                                  // 자기 애그리거트만 변경
        eventPublisher.publishEvent(new OrderCompletedEvent(orderId));
    }
}
```

```java
// 구독 측 — 배송 도메인
@Component
public class DeliveryEventHandler {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)  // 독립 트랜잭션
    public void on(OrderCompletedEvent event) {
        deliveryService.register(event.orderId());
    }
}
```

`AFTER_COMMIT`이 없으면 주문 트랜잭션이 롤백돼도 배송이 적재되는 유령 데이터가 생깁니다. `REQUIRES_NEW`가 없으면 배송 실패가 이미 커밋된 주문 흐름의 예외로 역류합니다.

## 트레이드오프 — 은총알 아님

| 함정 | 내용 | 대응 |
|------|------|------|
| 실시간 일관성 필수 도메인 | 금융 잔액·한도 차감은 원자적으로 맞아야 함 | 단일 로컬 트랜잭션 유지 — 최종 일관성으로 미루면 Saga 보상 비용이 수십 배 |
| 추적성 하락 | 비동기 리스너가 늘면 IDE 탐색으로 호출–수신을 못 이음 | 분산 추적(Zipkin, Elastic APM) 인프라 필요 |
| 과잉 도입 | 처음부터 Kafka/RabbitMQ 브로커 장착 | 아래 점진 도입 경로 |

## 점진 도입 경로

| 단계 | 수단 | 얻는 것 |
|------|------|--------|
| 1 | 모놀리식 내 `ApplicationEvent` (동기) | 코드 결합만 먼저 절단 — 인프라 추가 없음 |
| 2 | `@TransactionalEventListener` + `@Async` | 트랜잭션·스레드 분리 |
| 3 | 메시지 브로커 (Kafka, RabbitMQ) | 시스템 간 내구성·재시도 — 트래픽 한계에 닿았을 때 |

## 같은 인사이트 패턴 — "직접 참조 대신 신호로 협력한다"

| 영역 | 직접 결합 방식 | 신호 협력 방식 | 참조 |
|------|---------------|---------------|------|
| **도메인 이벤트** | 한 트랜잭션에서 타 도메인 테이블 직접 갱신 | 커밋 후 이벤트 발행 → 독립 트랜잭션 구독 | (이 페이지) |
| 애그리거트 연결 | 객체 참조로 메모리 주소 공유 | 식별자(ID)만 보관 | [[concept-id-reference-vs-object-reference]] |
| 에이전트 오케스트레이션 | 단일 에이전트가 전 단계 직접 수행 | 노드 간 스테이트 전이로 협력 | [[concept-graph-engineering]] |
| 멀티 에이전트 인계 | 대화 컨텍스트 통짜 공유 | progress 파일·브리프로 신호 전달 | [[concept-multi-agent-pattern]] |

→ 공통 원리: **협력자끼리 내부(메모리·트랜잭션·컨텍스트)를 직접 공유하면 한쪽의 실패·잠금이 전체로 전파됩니다.** 명시적 신호(이벤트·ID·스테이트)로만 잇면 각자의 실패가 각자의 경계 안에 갇힙니다.

## 빠른 진단

- "정산 서버 장애인데 주문까지 실패한다" → 상태 연쇄가 동기 트랜잭션에 묶여 있음 — 이벤트 분리 후보.
- "이벤트 리스너가 돌았는데 원본 트랜잭션은 롤백됐다" → `AFTER_COMMIT` 누락.
- "잔액 차감을 이벤트로 미뤘더니 보상 로직이 본 로직보다 크다" → 실시간 일관성 도메인에 과잉 적용.
- "어떤 리스너가 이 이벤트를 받는지 못 찾겠다" → 추적성 비용 — 분산 추적 도입 또는 이벤트 수 재검토.

## 원본 출처

- raw: `raw/object-dependency/domain-event-eventual-consistency.md` (블로그 글 유래 영속 개념 노트)
- 원 영상: 조영호, "우아한객체지향: 의존성을 이용해 설계 진화시키기" (우아한테크세미나, 2019)
- 공식: [Spring — @TransactionalEventListener](https://docs.spring.io/spring-framework/reference/data-access/transaction/event.html)

## 관련 페이지

- [[concept-id-reference-vs-object-reference]] — 트랜잭션 연쇄가 끊긴 원인
- [[concept-aggregate-boundary]] — 이벤트로 협력하는 애그리거트들의 경계
- [[concept-transactional-rollback-policy]] — 커밋·롤백 시점 이해가 `AFTER_COMMIT` 설계의 전제
- [[src-kakaopay-ddd]] — 도메인 간 협력의 실무 맥락 (Biz-component)
- [[concept-graph-engineering]] — 에이전트 세계의 같은 구조 (스테이트 전이 협력)
