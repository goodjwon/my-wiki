---
title: "TDD 실전 강의 — 31장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 31장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 31장 — 리팩토링

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

TDD 의 R(Refactor) 단계에서 자주 쓰는 리팩토링.

---

## TDD 에서 자주 쓰는 리팩토링

### 차이점 일치 (Reconcile Differences)

비슷한 코드 두 곳 → **점진적으로 같게** 만들고 추출.

### 변화 격리 (Isolate Change)

변경할 부분을 **메서드·임시 변수로** 격리 후 변경. → [[entity-refactoring]] 6.3 변수 추출.

### 데이터 마이그레이션 (Migrate Data)

내부 표현 변경 시 두 표현 동시 유지 → 호출자 점진 이전 → 옛 표현 제거.

### 메서드 추출 (Extract Method)

가장 자주 쓰는 리팩토링. [[entity-refactoring]] 6.1.

### 메서드 인라인 (Inline Method)

너무 작은 메서드 → 인라인. [[entity-refactoring]] 6.2.

### 인터페이스 추출 (Extract Interface)

구체 클래스 의존을 인터페이스 의존으로 → 테스트 가능성 ↑.

### 메서드 이동 (Move Method)

데이터에 더 가까운 클래스로 이동. [[entity-refactoring]] 8.1.

### 메서드 객체 (Method Object)

긴 메서드 → 새 클래스 + execute() 메서드. [[entity-refactoring]] 11.9 함수→명령.

### 매개변수 추가 (Add Parameter)

새 의존성 도입 시 매개변수 추가.

### 매개변수를 메서드로 변경

객체 자신의 데이터로 유도 가능하면 매개변수 제거. [[entity-refactoring]] 11.5.

---

## 핵심 통찰

리팩토링 카탈로그는 결국 *리팩터링* 책 그대로. TDD 의 R 단계에서 적용. 8·9장의 *Effective Java* 권고도 함께.

---

## 다음 장 예고 — 32장: TDD 마스터하기

책 전체 마치며. 마스터로 가는 길.
