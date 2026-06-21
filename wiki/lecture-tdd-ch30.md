---
title: "TDD 실전 강의 — 30장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 30장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 30장 — 디자인 패턴

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

TDD 가 자연스럽게 끌어내는 GoF 패턴들.

---

## TDD 에서 자주 등장하는 패턴

### Command

요청을 객체로. *Effective Java* Item 39 애너테이션·*리팩터링* 11.9 함수→명령.

### Value Object

불변 + equals + hashCode. 1~17장 Money 가 정확히 이 패턴. *EJ* Item 17.

### Null Object

null 처리 대신 빈 동작 객체. *리팩터링* 10.5.

### Template Method

부모가 알고리즘 골격, 자식이 단계 구현. xUnit 의 `run` (setUp → 메서드 → tearDown) 이 사례.

### Pluggable Object

if/switch 대신 객체 주입. Strategy 의 변형.

### Pluggable Selector

리플렉션으로 메서드 호출 — JUnit 의 `@Test` 메서드 발견.

### Factory Method

생성 의도를 메서드 이름으로. *EJ* Item 1·*리팩터링* 11.8.

### Imposter

같은 인터페이스의 다른 구현 — 가짜 객체·Mock 의 본질.

### Composite

부분 + 전체가 같은 인터페이스 — TestSuite + TestCase, Money + Sum.

### Collecting Parameter

여러 메서드가 같은 인자에 값 누적 — TestResult 가 그 사례.

### Singleton

이 책에서는 **권장 안 함** — 테스트 어려움.

---

## 핵심 통찰

> TDD를 충실히 하면 **패턴이 저절로 등장**. 처음부터 패턴 이름으로 설계 X.

[[concept-design-patterns]] / *리팩터링* / *오브젝트* 와 같은 메시지.

---

## 다음 장 예고 — 31장: 리팩토링

TDD 의 R 단계 — 자주 쓰는 리팩토링.
