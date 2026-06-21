---
title: "TDD 실전 강의 — 28장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 28장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 28장 — 초록 막대 패턴

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

초록 (통과) 단계의 패턴 — 빠르고 안전하게 통과시키는 기법.

---

## 28장 패턴

### 가짜로 구현하기 (Fake It)

**상수 박아 넣기** — 초록을 빠르게. 다음 단계에서 진짜 계산으로 교체.

```java
// 첫 통과
public int sum(int a, int b) { return 5; }   // 가짜 (테스트가 sum(2,3) 이라면)

// 다음
public int sum(int a, int b) { return a + b; }   // 진짜
```

### 삼각측량 (Triangulation)

**두 번째 테스트** 를 추가해 일반화를 강제.

```java
@Test void sum_2_3() { assertEquals(5, sum(2, 3)); }
@Test void sum_4_5() { assertEquals(9, sum(4, 5)); }
// → return 5; 만으로는 통과 X, 일반화 필요
```

### 명백한 구현 (Obvious Implementation)

답이 **자명** 하면 그냥 짜라. 가짜·삼각측량은 의심스러울 때만.

### 한 번에 하나

한 사이클에 **한 변경만**. 두 가지 동시 변경 = 실패 원인 추적 어려움.

---

## 다음 장 예고 — 29장: xUnit 패턴

xUnit 도구의 활용 패턴.
