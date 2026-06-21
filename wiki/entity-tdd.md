---
title: 테스트 주도 개발 (Kent Beck, 2002)
type: entity
tags: [book, tdd, kent-beck, test-driven, xunit]
sources: [tdd/]
external:
  - https://www.oreilly.com/library/view/test-driven-development/0321146530/
created: 2026-06-20
updated: 2026-06-21
---

# 테스트 주도 개발 — Kent Beck

## 정의

Kent Beck 이 정리한 **TDD 의 원전**. 화폐(돈) 예제로 1·2·3·R·G·R 사이클을 직접 보여주고, xUnit 자체를 TDD 로 만들고, 마지막에 패턴 카탈로그.

> **본질**: "**빨강 → 초록 → 리팩터**" 의 짧은 사이클이 좋은 설계를 **창발** 시킨다.

## 책 메타데이터

| 항목 | 값 |
|------|----|
| 저자 | Kent Beck (XP·JUnit 창시자) |
| 원서 | *Test-Driven Development: By Example* (Addison-Wesley, 2002) |
| 한국어판(추정) | *테스트 주도 개발* (인사이트, 2014, 김창준·강규영 옮김) |
| 분량 | 3부 32장 + 부록 A·B + 마치는 글 (Fowler) |
| 언어 예제 | Java (1부), Python (2부) |
| 관련작 | *XP Explained* (Beck), *Extreme Programming Adventures in C#* |

## 핵심 메시지 (목차에서 그대로 도출)

| 메시지 | 출처 | 풀이 |
|--------|------|------|
| **빨강 → 초록 → 리팩터** | 책 전체 골격 | 실패하는 테스트 → 빠른 통과 → 정련. 분 단위 사이클 |
| **할 일 목록** | 1·25장 | 흐름 끊지 말고 새 아이디어는 목록에 |
| **가짜로 구현하기 (Fake It)** | 1·28장 | 상수 박아 빠른 초록, 다음 단계에서 진짜 |
| **삼각측량** | 28장 | 두 번째 테스트로 일반화 강제 |
| **두 모자** | 5·14장 | 새 기능 / 리팩터링 — 한 번에 하나 |
| **xUnit 6 추상화** | 18~24장 | TestCase·TestSuite·TestResult·run·setUp·tearDown 으로 전부 |
| **설계가 창발** | 책 전체 | 처음부터 완벽 X, 사이클의 누적 결과 |
| **테스트도 코드** | 9장 + Clean Code 9장 | 깨끗한 테스트 = 깨끗한 코드의 안전망 |

## 책의 구조 — 3부 + 부록

| 부 | 장 | 목적 |
|----|----|----|
| **1부 화폐 예제** | 1~17 | Money 클래스 진화 — 다중 통화·equals·정적 팩터리·Expression·Bank 까지 |
| **2부 xUnit 예시** | 18~24 | xUnit (테스트 프레임워크) 자체를 TDD 로 — 자기 회귀 |
| **3부 TDD 패턴** | 25~32 | 일반·빨강·테스팅·초록·xUnit·디자인·리팩토링·마스터 패턴 |
| **부록** | A·B | 영향도·피보나치 |
| **마치는 글** | Fowler | TDD 관·균형·실용주의 |

## 1부 — 도메인 진화 사이클 정리

| 장 | 변환 | 도입 |
|----|------|------|
| 1 | `Dollar.times` 부작용 | 빨강 |
| 2 | 새 객체 반환 (불변) | 값 객체 |
| 3 | equals | 동등성 |
| 4 | private 필드 | 캡슐화 |
| 5 | `Franc` 추가 | 의도된 중복 |
| 6 | `Money` 슈퍼클래스 | 추출 |
| 7 | 통화 비교 | LSP 첫 마주침 |
| 8 | 정적 팩터리 (`Money.dollar()`) | EJ Item 1 |
| 9~11 | times 통합, 자식 제거 | 단일 `Money` |
| 12 | $5+$5 → `plus` | Expression |
| 13 | `Bank.reduce` | 환율 정책 분리 |
| 14 | `Pair` | 컬렉션 키 |
| 15 | $5 + 10 CHF | 1장 첫 할 일 완성 |
| 16 | times 추상화 | 컴포지트 완성 |
| 17 | 회고 | 1부 통찰 |

→ 17장 분량의 작은 단계가 정교한 도메인 모델 (Money·Bank·Expression·Sum) 을 만듦.

## 위키 기존 페이지와의 매핑

| TDD 주제 | 위키 페이지 |
|---------|-------------|
| equals/hashCode (3·14장) | [[entity-effective-java]] Item 10·11 |
| 값 객체 불변 (2·11장) | Item 17 |
| 정적 팩터리 (8장) | Item 1 |
| 서브클래스 제거 (11장) | [[entity-refactoring]] 12.7 |
| 슈퍼클래스 추출 (6장) | [[entity-refactoring]] 12.8 |
| 컴포지트·Strategy (12·16장) | [[concept-design-patterns]] |
| 책임 주도 설계 발견 | [[entity-object]] |
| 단순 설계 4규칙 | [[entity-clean-code]] 12장 |
| 자가 테스트 + 리팩터링 | [[entity-refactoring]] 4장 |
| TDD 3법칙 + F.I.R.S.T. | [[entity-clean-code]] 9장 |

## 같은 인사이트 패턴 — "사이클 안의 거부 신호"

TDD 의 **빨강(실패하는 테스트)** = 사이클 안에 들어가 있는 **거부 신호**. 위키의 다른 영역에 같은 패턴 누적.

| 영역 | 거부 신호 | 사이클 |
|------|-----------|--------|
| **TDD** | 실패 테스트 (빨강) | 빨강 → 초록 → 리팩터 |
| **자기검증 자동화** | 테스트·타입체크·`exit 1` | back-pressure 루프 |
| **AI 루프** | 테스트·타입체크·실제 에러 | [[concept-loop-engineering]] "거부 신호 없는 루프 = 메아리방" |
| **Hooks** | `guard.sh` exit 1 | [[concept-claude-hooks]] |
| **멀티 에이전트** | Critic의 REJECT | [[concept-multi-agent-pattern]] |
| **트랜잭션** | unchecked 예외 자동 롤백 | [[concept-transactional-rollback-policy]] |
| **DB 풀** | Leak 감지 + timeout | [[concept-db-connection-pool]] |

→ **공통 원리**: 자동 사이클은 **거부 신호** 가 있어야 발산 안 함. TDD 가 가장 오래된 사례.

## 5권 도서 오각형 — OO 설계 학습의 5권 세트

같은 OO/품질 결론을 5권이 서로 다른 단위·시점으로 가리킨다.

| 책 | 관점 | 단위 | 시점 | 언어 |
|----|------|------|------|------|
| [[entity-object]] *오브젝트* | 책임 주도 설계 (목적지) | 객체·협력·역할 | 처음부터 잘 설계 | Java |
| [[entity-effective-java]] *Effective Java* | 90 권고 (매뉴얼) | 메서드·필드·생성자 | 매번 짤 때 | Java |
| [[entity-refactoring]] *리팩터링 2판* | 카탈로그 (가는 길) | 1단계 변환 | 이미 짠 코드 | JS (2판) |
| [[entity-clean-code]] *Clean Code* | 미시 규칙 + 휴리스틱 | 줄·이름·함수 | 매 라인 | Java |
| **(이 책) [[entity-tdd]] *TDD*** | **사이클 (만드는 과정)** | **사이클 1회 (분)** | **코드 짜기 전** | **Java + Python** |

> ***TDD* 의 독특함**: 다른 4권이 코드의 **결과** (객체·메서드·줄·1단계 변환) 를 다룬다면, *TDD* 는 코드를 **만드는 과정** 자체를 다룸. 다른 4권은 "잘 쓰인 코드는 어떤 모습" 을 그리고, *TDD* 는 "그 모습에 어떻게 도달할까" 를 그림. 5권이 자연스럽게 한 세트.

## 누구에게·언제 권할 책인가

| 독자 | 효과 |
|------|------|
| **TDD 입문자** | 1부 (17장) 가 가장 효과적인 손 익히기 |
| **테스트 작성 두려운 개발자** | "테스트도 코드" 라는 관점 + 분 단위 사이클 |
| **레거시 코드 다루는 사람** | TDD 사이클 + 특성화 테스트 (*Clean Code* 16장) |
| **신입 교육** | 1부 1·2장 + 3부 25·28장 가 짧고 강력 |
| **JUnit 사용자** | 2부 (xUnit 자체) 가 도구 이해 깊이 ↑ |

## 빠른 진단 — 이 책을 펴야 할 신호

- [ ] 코드 짜고 나서 테스트 작성하는 습관 (Test-After)
- [ ] 테스트 작성이 부담스러워 미루는 경향
- [ ] 한 PR 에 여러 기능 + 리팩터링 섞임 (두 모자 위배)
- [ ] flaky 테스트 방치
- [ ] 작은 단계로 분해하기 어려워 큰 변경 한 번에
- [ ] Mock 남발로 테스트가 구현 디테일 검증

위 중 2개+ → 1·2·3·4·5장 (1부 시작) + 25·28장 (패턴) 우선.

## 한계·주의

- **2002년 출판** — Java 5 이전. 일부 코드 스타일은 현대 (record·sealed) 와 차이
- **모든 코드에 TDD 100% 적용은 어려움** — UI·통합·성능은 다른 도구
- **Fowler 의 마치는 글** 이 균형 잡힌 시각 — Test-First vs Test-After, Mock 의존도
- **숙련도가 결정적** — 책 읽기만으로는 부족, 직접 코딩 필수

## 원본 출처

- `raw/tdd/toc.md` — 사용자가 입력한 목차 (2026-06-20)
- `raw/tdd/테스트 주도 개발 실전 강의 교재 1~32장.md + 부록A·B + 마치는글.md` — 35편 강의 교재 (사용자 입력 1·2장 + 본 세션 작성 3~32·부록·마치는글)
  - 통합 인덱스: [[src-tdd-lecture]]
- 책 본문 직접 인용 아닌 강의용 재구성

## 관련 페이지

- [[src-tdd-lecture]] — 실전 강의 교재 통합 인덱스
- [[entity-object]] — *오브젝트* (OO 설계 큰 그림)
- [[entity-effective-java]] — *Effective Java* (Java 권고 90개)
- [[entity-refactoring]] — *리팩터링* (개선 카탈로그)
- [[entity-clean-code]] — *Clean Code* (가독성·휴리스틱)
- [[concept-design-patterns]] — TDD가 자연 도입하는 패턴
- [[concept-loop-engineering]] — "사이클 안의 거부 신호" 패턴 (AI 영역 확장)
- [[concept-claude-hooks]] — 자기검증 자동화
- [[src-spring-testing-ref]] — JUnit 5·MockMvc 실무
