---
title: 테스트 주도 개발 실전 강의 교재 35편 인덱스
type: source
tags: [book, tdd, kent-beck, lecture, curriculum]
sources: [tdd/]
created: 2026-06-20
updated: 2026-06-20
---

# TDD 실전 강의 교재 — 35편 인덱스 (32장 + 부록 2 + 마치는 글)

## 무엇인가

Kent Beck *Test-Driven Development: By Example* (2002) 의 **3부 32장 + 부록 A·B + 마치는 글** 을 Java/Spring 백엔드 입문~중급 수강생용 강의 교재로 풀어 쓴 자료.

→ 책 카드는 [[entity-tdd]].

## 35편 인덱스

### 1부 화폐 예제 (17편)

| 장 | 주제 | 본문 |
|----|------|------|
| 1 | Money 객체 — 시작 | [[lecture-tdd-ch1]] |
| 2 | 타락한 객체 (부작용 제거) | [[lecture-tdd-ch2]] |
| 3 | 모두를 위한 평등 (equals) | [[lecture-tdd-ch3]] |
| 4 | 프라이버시 (private) | [[lecture-tdd-ch4]] |
| 5 | 솔직히 말하자면 (Franc 추가) | [[lecture-tdd-ch5]] |
| 6 | 돌아온 평등 (슈퍼클래스 추출) | [[lecture-tdd-ch6]] |
| 7 | 사과와 오렌지 (통화 비교) | [[lecture-tdd-ch7]] |
| 8 | 객체 만들기 (정적 팩터리) | [[lecture-tdd-ch8]] |
| 9 | times 슈퍼클래스화 | [[lecture-tdd-ch9]] |
| 10 | times 통합 | [[lecture-tdd-ch10]] |
| 11 | 자식 클래스 제거 (Money 단일) | [[lecture-tdd-ch11]] |
| 12 | 드디어 더하기 (Expression 도입) | [[lecture-tdd-ch12]] |
| 13 | Bank 도입 (환율) | [[lecture-tdd-ch13]] |
| 14 | Pair (컬렉션 키) | [[lecture-tdd-ch14]] |
| 15 | $5 + 10 CHF (드디어 완성) | [[lecture-tdd-ch15]] |
| 16 | times 추상화 | [[lecture-tdd-ch16]] |
| 17 | Money 회고 | [[lecture-tdd-ch17]] |

### 2부 xUnit 예시 (7편)

| 장 | 주제 | 본문 |
|----|------|------|
| 18 | xUnit 첫걸음 | [[lecture-tdd-ch18]] |
| 19 | 테이블 차리기 (setUp) | [[lecture-tdd-ch19]] |
| 20 | 뒷정리 (tearDown) | [[lecture-tdd-ch20]] |
| 21 | 셈하기 (TestResult) | [[lecture-tdd-ch21]] |
| 22 | 실패 처리 | [[lecture-tdd-ch22]] |
| 23 | TestSuite | [[lecture-tdd-ch23]] |
| 24 | xUnit 회고 | [[lecture-tdd-ch24]] |

### 3부 TDD 패턴 (8편)

| 장 | 주제 | 본문 |
|----|------|------|
| 25 | TDD 패턴 (일반) | [[lecture-tdd-ch25]] |
| 26 | 빨강 막대 패턴 | [[lecture-tdd-ch26]] |
| 27 | 테스팅 패턴 | [[lecture-tdd-ch27]] |
| 28 | 초록 막대 패턴 | [[lecture-tdd-ch28]] |
| 29 | xUnit 패턴 | [[lecture-tdd-ch29]] |
| 30 | 디자인 패턴 | [[lecture-tdd-ch30]] |
| 31 | 리팩토링 | [[lecture-tdd-ch31]] |
| 32 | TDD 마스터하기 | [[lecture-tdd-ch32]] |

### 부록 (3편)

| 절 | 주제 | 본문 |
|----|------|------|
| 부록 A | 영향도 (개발자·코드·설계·팀·비즈니스) | [[lecture-tdd-appendixA]] |
| 부록 B | 피보나치 (짧은 사이클 사례) | [[lecture-tdd-appendixB]] |
| 마치는 글 | Martin Fowler — TDD 균형 | [[lecture-tdd-afterword]] |

## 5권 도서 오각형

| 책 | 단위 | 시점 |
|----|------|------|
| *오브젝트* | 객체 | 처음부터 |
| *Effective Java* | 메서드·필드 | 매번 짤 때 |
| *리팩터링* | 변환 | 이미 짠 코드 |
| *Clean Code* | 줄·이름 | 매 라인 |
| ***TDD*** | **사이클** | **코드 짜기 전** |

→ 5권이 한 세트. TDD 가 "**과정**" 을 담당.

## 활용 가이드

| 목적 | 추천 진입점 |
|------|-------------|
| TDD 입문 | 1부 1·2·3·4·5장 — 짧고 강력 |
| JUnit 깊이 | 2부 18~24장 — xUnit 자체 |
| 패턴 사전 | 3부 25·28·30장 |
| Fowler 시각 | 마치는 글 |

## 관련 페이지

- [[entity-tdd]] — 책 카드 (상위)
- [[entity-effective-java]] / [[entity-refactoring]] / [[entity-clean-code]] / [[entity-object]] — 5권 사각형
- [[src-spring-testing-ref]] — JUnit 5 실무
