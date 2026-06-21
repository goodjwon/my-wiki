---
title: "TDD 실전 강의 — 27장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 27장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 27장 — 테스팅 패턴

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

테스트 코드 작성 시 자주 쓰는 패턴.

---

## 27장 패턴

### 자식 테스트

큰 테스트가 너무 큼 → **작은 자식 테스트들로 분해**. 각각 통과시키면 부모 자동 통과.

### 가짜 객체 (Mock Object)

협력 객체를 **가짜 구현** 으로 대체. 테스트 단위 격리. → JUnit + Mockito.

### 셀프 션트 (Self Shunt)

테스트 클래스가 **자기 자신** 을 협력 객체로 사용. 가벼운 mock.

### 로그 문자열

부작용 추적이 필요할 때 **호출 순서를 문자열로** 기록. "begin end" 같은 형식으로 검증.

### 크래시 테스트 더미

호출되면 **즉시 예외** 던지는 가짜. "이 경로는 절대 안 와야" 검증.

### 깨진 테스트

종료 시 **테스트 1개를 일부러 깨진 상태로**. 다음 날 시작 시 "여기부터" 가 명확.

### 깨끗한 체크인

팀 작업 시 **푸시 전 모든 테스트 통과**. 다른 사람이 빨강 받지 않게.

---

## JUnit + Mockito 매핑

```java
// 가짜 객체
@Mock private OrderRepository repo;

// 셀프 션트
class OrderServiceTest implements PaymentGateway {
    private int chargedAmount;
    @Override public PaymentResult charge(Money amount, Card card) {
        this.chargedAmount = amount.value();
        return PaymentResult.SUCCESS;
    }
}
```

---

## 다음 장 예고 — 28장: 초록 막대 패턴

초록 (통과) 단계에 자주 쓰는 빠른 통과 기법.
