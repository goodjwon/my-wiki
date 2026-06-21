---
title: Clean Code (Robert C. Martin, 2008)
type: entity
tags: [book, clean-code, uncle-bob, refactoring, naming, function, java]
sources: [clean-code/toc.md]
external:
  - https://www.oreilly.com/library/view/clean-code/9780136083238/
created: 2026-06-20
updated: 2026-06-21
---

# Clean Code — 깨끗한 코드를 어떻게 알아보고 만드는가

## 정의

Robert C. Martin(Uncle Bob)이 정리한 **코드를 "깨끗하게" 만드는 미시 규칙 모음**. 이름·함수·주석·형식·오류 처리부터 동시성까지 — **줄 단위·메서드 단위의 가독성 카탈로그**.

> **본질**: 깨끗한 코드는 "**다른 사람이 이해하기 쉬워야 한다**" 라는 한 줄이 책 전체를 관통한다. 컴파일러는 어떤 코드든 받지만, 사람은 그렇지 않다.

## 책 메타데이터

| 항목 | 값 |
|------|----|
| 저자 | Robert C. Martin (Uncle Bob) — 공동저자 다수 (Michael Feathers, Tim Ottinger, Jeff Langr, Brett Schuchert, Kyle Brown 등) |
| 원서 | *Clean Code: A Handbook of Agile Software Craftsmanship* (Prentice Hall, 2008) |
| 한국어판(추정) | *클린 코드 — 애자일 소프트웨어 장인 정신* (인사이트, 2013, 박재호·이해영 옮김) |
| 분량 | 17장 + 부록 A·B·C, 약 580페이지 |
| 언어 예제 | Java (전반), JUnit·log4j 사례 |
| 후속작 | *The Clean Coder*(2011, 태도·전문성), *Clean Architecture*(2017, 아키텍처), *Clean Agile*(2019) |

## 핵심 메시지 (목차에서 그대로 도출)

| 메시지 | 출처 절 | 풀이 |
|--------|---------|------|
| **나쁜 코드는 곱셈으로 비용을 키운다** | 1장 "나쁜 코드로 치르는 대가" | 한 줄의 나쁜 코드가 다음 줄을 더 나쁘게 만든다. 원대한 재설계는 오지 않는다 |
| **보이스카우트 규칙** | 1장 | "체크아웃할 때보다 깨끗하게 체크인하라". 매 PR에서 약간씩 정리 |
| **우리는 저자다** | 1장 "우리는 저자다" | 코드는 후대(자기 자신 포함)가 읽는 글. 작성 비율 < 읽기 비율 (1:10 추정) |
| **이름이 의도를 드러내야 한다** | 2장 | 이름 짓기에 시간을 아끼지 마라. 책임·계약·도메인을 모두 이름이 말한다 |
| **함수는 작아야 한다 (한 가지만)** | 3장 | "한 함수는 한 가지 일만". 추상화 수준 한 단계만 내려간다 |
| **주석은 나쁜 코드를 보완하지 못한다** | 4장 | 좋은 코드 > 어떤 주석. 주석은 코드가 못 말하는 "왜"만 |
| **명령과 조회를 분리하라 (CQS)** | 3장 | *Effective Java* Item 70·*리팩터링* 11.1과 같은 메시지 |
| **오류 코드보다 예외** | 3·7장 | *Effective Java* Item 69·*리팩터링* 11.12와 같은 메시지 |
| **클래스는 작아야 한다 (SRP)** | 10장 | 단일 책임 원칙 — 책의 가장 자주 인용되는 부분 |
| **TDD의 3법칙 + F.I.R.S.T.** | 9장 | 테스트가 깨끗해야 코드가 깨끗하게 유지된다 |
| **단순한 설계 4 규칙 (켄트 벡)** | 12장 | (1) 모든 테스트 통과 (2) 중복 없음 (3) 의도 표현 (4) 최소 클래스·메서드 |

## 책의 구조 — 3부

목차에 부 구분은 없지만 흐름상 3부로 묶을 수 있다.

| 부 (논리적) | 장 | 목적 |
|-------------|----|----|
| **I. 원칙 (저수준 단위)** | 1·2·3·4·5 | 코드란 무엇 → 이름 → 함수 → 주석 → 형식 |
| **II. 구조 (중수준 단위)** | 6·7·8·9·10·11·12·13 | 객체·자료 → 오류 → 경계 → 단위 테스트 → 클래스 → 시스템 → 창발 → 동시성 |
| **III. 사례 + 카탈로그** | 14·15·16·17 + 부록 | Args 점진 개선·JUnit 분석·SerialDate 리팩터링·**휴리스틱 17장**·동시성 II |
| **부록** | A·B·C | 동시성 II·SerialDate·휴리스틱 교차 참조 |

## 17장 — 냄새와 휴리스틱 (이 책의 가장 자주 인용되는 자산)

책의 마지막 장이자 카탈로그. **C·E·F·G·J·N·T 7개 카테고리, 약 80여 항목.**

| 카테고리 | 개수 | 약어 의미 |
|----------|------|-----------|
| **C** Comments | 5 | 주석 관련 (C1~C5) |
| **E** Environment | 2 | 빌드·테스트 환경 (E1~E2) |
| **F** Functions | 4 | 함수 관련 (F1~F4) |
| **G** General | 36 | 일반 (G1~G36) — **가장 큼** |
| **J** Java | 3 | Java 특화 (J1~J3) |
| **N** Names | 7 | 이름 (N1~N7) |
| **T** Tests | 9 | 테스트 (T1~T9) |

### 자주 인용되는 ⭐ 휴리스틱

| 코드 | 한 줄 | 위키 매핑 |
|------|------|-----------|
| **G5** | 중복 | [[entity-refactoring]] 악취 3.2 |
| **G6** | 추상화 수준 부적절 | [[entity-effective-java]] Item 18·*오브젝트* |
| **G19** | 서술적 변수 (변수 추출) | [[entity-refactoring]] 6.3 |
| **G22** | 논리적 의존성 물리화 | 어서션·검증·@Valid |
| **G23** | If/Else·Switch보다 다형성 | [[entity-refactoring]] 10.4·[[entity-effective-java]] Item 34 |
| **G25** | 매직 숫자→상수 | [[entity-refactoring]] 9.6 |
| **G28** | 조건을 캡슐화 | [[entity-refactoring]] 10.1·10.2 |
| **G30** | 함수는 한 가지만 | 3장 본문·[[entity-refactoring]] 6.1 |
| **G34** | 함수는 추상화 수준 한 단계만 | 3장 본문 |
| **N1** | 서술적 이름 | 2장 본문·[[entity-refactoring]] 6.5 |
| **T5** | 경계 조건 테스트 | [[entity-effective-java]] Item 60 |

## 위키 기존 페이지와의 매핑

| Clean Code 주제 | 장 | 위키 기존 페이지 |
|----------------|----|------------------|
| 이름 짓기 (의도·중복·맥락) | 2장·N1~N7 | (신규 후보 — `concept-naming-conventions`) |
| 함수는 작게·한 가지·CQS·오류→예외 | 3·7장 | [[entity-effective-java]] Item 49·51·70 / [[entity-refactoring]] 6.1·11.1·11.12 |
| 디미터 법칙·자료/객체 비대칭 | 6장 | [[concept-oop]]·[[entity-object]] 6.03 |
| 단위 테스트 / F.I.R.S.T. / TDD 3법칙 | 9장 | [[src-spring-testing-ref]] (신규 후보 — `concept-tdd-laws-and-first`) |
| SRP·응집도·작은 클래스 | 10장 | [[concept-oop]]·[[entity-object]] 5장 |
| 시스템·Main 분리·DI·AOP | 11장 | [[concept-spring-core]] (IoC·AOP) |
| 단순한 설계 4규칙 (Kent Beck) | 12장 | (신규 후보 — `concept-simple-design-rules`) |
| 동시성 방어 원칙 (SRP·자료 사본·독립 스레드) | 13장·부록 A | [[entity-effective-java]] 11장 (Item 78~84) |
| 17장 휴리스틱 G23 (다형성 > switch) | 17장 | [[entity-refactoring]] 10.4 |
| 17장 휴리스틱 G25 (매직 숫자→상수) | 17장 | [[entity-refactoring]] 9.6 |
| 17장 휴리스틱 N1 (서술적 이름) | 17장 | [[entity-refactoring]] 6.5·6.7 |

→ **신규 concept 후보 3개** (작명 규약·TDD 3법칙·단순한 설계 4규칙) — 본문 노트 입력 시 ingest. 백로그 등록.

## 같은 인사이트 패턴 — "사람이 읽기 위한 코드"

Clean Code 전반을 관통하는 원리: **코드의 1차 독자는 컴파일러가 아니라 사람**.

같은 메시지가 위키의 다른 영역에 누적되어 있음:

| 영역 | "사람이 읽는 자산" | 처방 | 참조 |
|------|---------------------|------|------|
| **코드** | 의도가 이름·구조에 드러남 | Clean Code 2·3·10장 | (이 페이지) |
| **API 설계** | 시그니처가 계약을 말함 | Javadoc·CQS·표준 예외 | [[entity-effective-java]] Item 56·70·72 |
| **리팩터링** | 모든 변경에 이름·전제·절차 | 카탈로그 5단 형식 | [[entity-refactoring]] 5장 |
| **OO 설계** | 메시지가 객체를 결정 | 책임 주도 설계 | [[entity-object]] 3장 |
| **AI 에이전트** | 부탁 대신 구조로 의도 명시 | CLAUDE.md·hooks·skills | [[concept-harness-engineering]] |
| **AI 루프** | 메커니즘 자체에 거부 신호 | 테스트·타입 체크·실제 에러 | [[concept-loop-engineering]] |
| **운영 (DB·LB·크론)** | 가정·기본값이 코드에 명시 | `concurrencyPolicy`·`activeDeadlineSeconds`·풀 사이즈 명시 | [[concept-cronjob-concurrency-trap]]·[[concept-db-connection-pool]] |

→ **공통 원리**: **암묵 < 명시**. 가독성·안전성·진화 가능성은 모두 "다음에 보는 사람이 한 번에 알 수 있는가"에 달림.

## 5권 도서 오각형 — OO 설계 학습의 5권 세트

같은 OO/품질 결론을 5권이 서로 다른 단위·시점으로 가리킨다.

| 책 | 관점 | 단위 | 시점 | 언어 |
|----|------|------|------|------|
| [[entity-object]] *오브젝트* | 책임 주도 설계 (목적지) | 객체·협력·역할 | 처음부터 잘 설계 | Java |
| [[entity-effective-java]] *Effective Java* | 90 권고 (매뉴얼) | 메서드·필드·생성자 | 매번 짤 때 | Java |
| [[entity-refactoring]] *리팩터링 2판* | 카탈로그 (가는 길) | 1단계 변환 | 이미 짠 코드 | JS (2판) |
| **(이 책) [[entity-clean-code]] *Clean Code*** | **미시 규칙 + 휴리스틱** | **줄·이름·함수** | **매 라인** | **Java** |
| [[entity-tdd]] *TDD* | 사이클 (만드는 과정) | 사이클 1회 (분) | 코드 짜기 전 | Java + Python |

> ***Clean Code* 의 자리** : OO 원칙을 **줄·이름·함수 단위 가독성** + 17장 휴리스틱으로 정형화. 다른 4권이 객체 (오브젝트), 메서드·필드 (EJ), 1단계 변환 (리팩터링), 1사이클 (TDD) 이라면 *Clean Code* 는 **가장 작은 단위인 줄·이름 + 매 라인 적용**.

**누구에게**:
- *오브젝트* — 3~10년차 설계자
- *Effective Java* — 1~5년차 권고
- *리팩터링* — 레거시 다루는 사람
- ***Clean Code*** — **신입~3년차 가독성 (가장 빠른 효과)**
- *TDD* — 테스트 안 짜는 습관 깨고 싶은 모두

**추천 학습 순서** (5권 전체):
1. ***Clean Code* 2·3·4·10장** — 줄·이름·함수·클래스의 기본기 (가장 빠른 효과)
2. *Effective Java* 2·3·8·10장 — Java 권고 90 개
3. *리팩터링* 3장 (24 악취) + 6장 (기본) — 기존 코드 개선 어휘
4. *오브젝트* 1~5장 — OO 설계 큰 그림
5. *TDD* 1·2부 — 테스트가 설계 끌어내기
6. 5권 교차 참조

## 누구에게·언제 권할 책인가

| 독자 | 효과 |
|------|------|
| **신입~3년차** | 매일 짜는 코드의 **줄 단위 가독성** 이 즉시 좋아짐. 가장 빠른 효과를 보는 책 |
| **코드 리뷰어** | 17장 휴리스틱 코드(G19, N1, T5...) 로 리뷰 어휘 표준화 |
| **신입 교육** | 1·2·3장이 통째로 교육 자료. 보이스카우트 규칙은 팀 문화 |
| **레거시 만지는 사람** | 14·15·16장의 점진 개선 사례 + 17장 휴리스틱 |
| **테스트 입문자** | 9장 F.I.R.S.T.·TDD 3법칙이 가장 짧은 입문 |

## 빠른 진단 — 이 책을 펴야 할 신호

- [ ] 함수가 화면을 넘긴다 (3장 "작게 만들어라")
- [ ] 매개변수 4개 이상 메서드가 흔하다 (3장 함수 인수·*리팩터링* 6.8)
- [ ] 주석으로 코드를 설명하고 있다 (4장)
- [ ] `String userId`/`String status` 같이 도메인이 String/int (2·6장)
- [ ] PR 리뷰에서 "이름이 이상하다"는 코멘트를 자주 본다 (2장·17장 N1)
- [ ] try/catch가 정상 흐름 제어로 쓰임 (7장)
- [ ] 클래스 한 개가 1,000줄 넘는다 (10장 SRP)
- [ ] 테스트 한 개에 assert가 10개 (9장 "테스트 당 assert 하나")
- [ ] `if/switch(type)` 가 여러 곳에 반복 (17장 G23)

위 중 2개+ → 1·2·3·10·17장 우선 발췌.

## 한계·주의

- **2008년 출판** — 일부 코드 스타일(예: SerialDate)·테스트 도구(JUnit 3·4)는 현대(JUnit 5·record·sealed class) 와 차이. 단, 원칙은 100% 유효
- **"무조건적 규칙" 인용 위험** — 책의 일부 권고("주석 거의 다 나쁘다", "함수 4줄 이내")는 맥락을 떼면 도그마. 책 본문이 항상 "단, ..." 단서를 다는 점 유의
- **함수형·반응형 부재** — Stream·CompletableFuture·Reactor 같은 모던 함수형 사고는 다른 책으로 보완 ([[entity-effective-java]] 7장)
- **아키텍처는 거의 안 다룸** — 후속작 *Clean Architecture* 영역
- **17장 휴리스틱은 외울 게 아님** — 펼쳐서 검색하는 사전

## 원본 출처

- `raw/clean-code/toc.md` — 사용자가 입력한 목차 (2026-06-20)
- `raw/clean-code/클린 코드 실전 강의 교재 1~17장.md` — 17편 강의 교재 (사용자 입력 1·2장 + 본 세션 작성 3~17장, 약 5,500줄). 책 본문 직접 인용 아닌 강의용 재구성.
  - 통합 인덱스: [[src-clean-code-lecture]]
- 저자 사이트: https://blog.cleancoder.com/

## 관련 페이지

- [[src-clean-code-lecture]] — 실전 강의 교재 17장 통합 인덱스 (각 장 본문 진입)
- [[entity-object]] — *오브젝트* (OO 설계 큰 그림)
- [[entity-effective-java]] — *Effective Java* (Java 권고 90개)
- [[entity-refactoring]] — *리팩터링 2판* (코드 개선 카탈로그)
- [[concept-oop]] / [[concept-design-patterns]] / [[concept-spring-core]] — 4원칙·패턴·DI
- [[concept-transactional-rollback-policy]] — 7장 오류 처리와 직결
- [[concept-harness-engineering]] / [[concept-loop-engineering]] — "암묵 < 명시" 패턴의 AI 영역 확장
- [[src-spring-testing-ref]] — 9장 단위 테스트의 실무
