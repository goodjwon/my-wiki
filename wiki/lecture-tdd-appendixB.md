---
title: "TDD 실전 강의 — 부록B"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 부록B.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 부록 B — 피보나치

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 짧은 TDD 사이클 사례

---

## 0. 학습 목표

피보나치 함수를 TDD 로 — **가장 짧은** 사이클 사례.

---

## 사이클

### Step 1 — fib(0) = 0

```java
@Test void fib_0() { assertEquals(0, fib(0)); }

int fib(int n) { return 0; }   // 가짜
```

### Step 2 — fib(1) = 1

```java
@Test void fib_1() { assertEquals(1, fib(1)); }

int fib(int n) {
    if (n == 0) return 0;
    return 1;
}
```

### Step 3 — fib(2) = 1

이미 통과 — 추가 변경 X.

### Step 4 — fib(3) = 2

```java
@Test void fib_3() { assertEquals(2, fib(3)); }

int fib(int n) {
    if (n < 2) return n;
    return fib(n-1) + fib(n-2);
}
```

→ 통과 + 일반화.

---

## 통찰

- 매우 짧은 사이클 (분 단위) 의 누적이 도메인 솔루션.
- 가짜 → 진짜 의 점진 일반화.
- 삼각측량 (Step 2·4) 으로 일반화 강제.

---

## 다음 — 마치는 글 (Fowler)
