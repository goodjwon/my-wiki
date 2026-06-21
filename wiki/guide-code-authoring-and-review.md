---
title: 코드 작성·점검 가이드 (5권 도서 종합)
type: synthesis
tags: [guide, code-quality, code-review, 5-books, prompt]
sources: [object/, effective_java/, refactoring/, clean-code/, tdd/]
created: 2026-06-21
updated: 2026-06-21
---

# 코드 작성·점검 가이드 — 5권 도서 종합

## 무엇인가

OO 설계 5권 도서 ([[entity-object]] · [[entity-effective-java]] · [[entity-refactoring]] · [[entity-clean-code]] · [[entity-tdd]]) 의 핵심 원칙을 **코드 작성 + 코드 점검** 두 워크플로로 압축한 단일 가이드.

활용:
1. **AI 프롬프트** — Claude·ChatGPT 에 이 페이지 본문을 컨텍스트로 주고 "이 원칙으로 코드 짜줘" / "리뷰해줘".
2. **슬래시 명령** — `/code-guide` (작성 가이드)·`/code-check` (현재 diff 점검) — 이 페이지를 베이스로.
3. **PR 리뷰 어휘** — "G19", "Item 18", "리팩터링 6.1" 같은 표준 어휘로 합의 빠름.
4. **신입 교육** — 한 페이지로 5권 책의 핵심 점검 어휘 습득.

> **실습 환경 먼저** — Java 17 + JUnit 5 + Python + Node 셋업은 [[guide-java-book-study-lab]] 참조. 이 가이드는 환경이 준비된 후의 **작성·점검 워크플로**.

→ 위키 누적의 진짜 가치 = **여러 책의 결론을 한 워크플로** 로.

---

## 1. 5권 원칙 한 페이지 종합

### 1.1 5권 오각형 — 각 책의 자리

| 책 | 단위 | 시점 | 한 줄 메시지 |
|----|------|------|------|
| [[entity-object]] *오브젝트* | 객체·협력 | 처음부터 잘 설계 | "메시지가 객체를 결정한다" |
| [[entity-effective-java]] *Effective Java* | 메서드·필드 | 매번 짤 때 | "Java 90 권고를 매번 적용" |
| [[entity-refactoring]] *리팩터링* | 1단계 변환 | 이미 짠 코드 | "24 악취 → 66 카탈로그" |
| [[entity-clean-code]] *Clean Code* | 줄·이름·함수 | 매 라인 | "다음 사람이 읽기 쉬워야" |
| [[entity-tdd]] *TDD* | 사이클 | 코드 짜기 전 | "빨강 → 초록 → 리팩터" |

### 1.2 6원칙 — 5권을 관통하는 공통 골격

| # | 원칙 | 근거 |
|---|------|------|
| 1 | **객체 협력 > 클래스 단독** | 오브젝트 1~7장 |
| 2 | **추상에 의존, 구체 X** | OCP·DIP, EJ Item 5·64, 오브젝트 8·9장 |
| 3 | **합성 > 상속** | EJ Item 18, 리팩터링 12.10, 오브젝트 11장 |
| 4 | **불변 우선** | EJ Item 17, TDD 2장 (값 객체) |
| 5 | **단순한 설계 4규칙** (모든 테스트·중복 X·의도·최소) | Clean Code 12장 (Kent Beck) |
| 6 | **테스트가 안전망 + 설계 도구** | TDD 전체, Clean Code 9장 |

---

## 2. 코드 작성 체크리스트 (Writing)

새 코드 짤 때·PR 올리기 전 자기 점검.

### 2.1 함수 (`Clean Code` 3장 + EJ 49~56 + 리팩터링 6장)

- [ ] 함수가 **한 화면 (15줄) 이내** 인가
- [ ] 들여쓰기 **2단계 이하** 인가
- [ ] **한 가지** 일만 하는가 — 빈 줄로 단락 구분이 2개+ = 추출 후보
- [ ] **이름이 동작** 을 정확히 드러내는가 (`is*`/`has*` boolean·`to*`/`from*` 변환)
- [ ] 매개변수 **0~3개** 인가 — 4개+ = record/객체화
- [ ] **boolean 플래그** 매개변수 X — enum 또는 분리
- [ ] **부수효과** 없는가 (이름이 약속한 일만)
- [ ] **명령-쿼리 분리 (CQS)** — 반환 + 상태 변경 동시 X

### 2.2 객체·클래스 (`오브젝트` 4·5·10·11장 + EJ 17·18·20·25)

- [ ] **데이터 먼저 X — 행동·책임 먼저** 결정했나
- [ ] **getter/setter 자동 생성** 으로 모든 필드 노출 X
- [ ] **불변** 가능한가 (final 필드, record)
- [ ] **상속 대신 합성** 검토했나 — Stack extends Vector 함정
- [ ] 도메인 객체에 **`@Data`/`@Setter`** 무지성 X — 의미 있는 메서드만 노출
- [ ] **SRP** — 클래스가 변경 이유가 하나
- [ ] **응집도 높음** — 일부 메서드가 일부 필드만 쓰면 분리 신호
- [ ] 인터페이스 의존인가 — 구체 클래스 직접 의존 X

### 2.3 의존성 (`오브젝트` 8·9장 + EJ 5·64 + Spring DI)

- [ ] **생성자 주입** 인가 — 세터·정적·싱글턴 X
- [ ] `new Repository()` 같이 **직접 생성** 안 하고 받는가
- [ ] **추상 (인터페이스)** 에 의존하는가
- [ ] 도메인 객체가 **Spring 없이 만들어지는가** (POJO)
- [ ] 단일 구현 인터페이스 — 추측성 일반화 의심 ([[entity-refactoring]] 3.15)

### 2.4 예외·null (`Clean Code` 7장 + EJ 69~77)

- [ ] **unchecked 예외** 우선 — checked 신중
- [ ] 예외 메시지에 **인자 값·상태** 포함
- [ ] `@Transactional` 안 변경에 unchecked 던지는가 (자동 롤백)
- [ ] **컬렉션 반환은 null X 빈 컬렉션** — Optional 은 단건만
- [ ] **빈 catch 블록** 없는가 — 무시는 명시 + 로그
- [ ] 외부 라이브러리 예외를 도메인 wrapper 로 변환했는가

### 2.5 도메인 모델 (`오브젝트` + DDD 정신)

- [ ] **빈혈 도메인 모델** 아닌가 (객체가 자기 결정)
- [ ] **Tell, Don't Ask** — 데이터 꺼내 외부 처리 X
- [ ] 도메인 메서드 이름이 **도메인 전문가 용어**
- [ ] **타입 코드 + switch** 대신 다형성
- [ ] **기본형 집착** X — `UserId` record, `Money` 값 객체

### 2.6 테스트 (`TDD` + Clean Code 9장)

- [ ] **테스트가 코드보다 먼저** (TDD) 또는 동시
- [ ] **F.I.R.S.T.** — Fast·Independent·Repeatable·Self-validating·Timely
- [ ] **한 테스트 = 한 동작 = 한 개념**
- [ ] **경계 조건** 테스트 (0·1·MAX·null·빈)
- [ ] `Thread.sleep` 의존 X — 명시적 동기화
- [ ] **flaky 테스트** 방치 X

### 2.7 동시성 (EJ 78~84 + Clean Code 13장)

- [ ] Spring 빈 필드가 **가변 + 공유** X
- [ ] `synchronized` 영역에 **I/O·콜백** X
- [ ] `Executors.newCachedThreadPool()` 직접 사용 X — 명시적 `ThreadPoolExecutor`
- [ ] `HashMap`·`ArrayList` 멀티스레드 공유 X — `ConcurrentHashMap`·`CopyOnWriteArrayList`
- [ ] `SimpleDateFormat`·`Random` 공유 X — `DateTimeFormatter`·`ThreadLocalRandom`

---

## 3. 코드 점검 체크리스트 (Review)

PR 리뷰 어휘 — 5권 표준 코드로 합의 빠르게.

### 3.1 24 코드 악취 ([[entity-refactoring]] 3장)

| 코드 | 악취 | 처방 |
|------|------|------|
| 3.1 | 기이한 이름 | 6.5/6.7 이름 바꾸기 |
| 3.2 | 중복 코드 | 6.1 함수 추출 |
| 3.3 | 긴 함수 | 6.1·6.11 |
| 3.4 | 긴 매개변수 목록 (4+) | 6.8 객체화 |
| 3.5 | 전역 데이터 | 6.6 캡슐화 |
| 3.7 | 뒤엉킨 변경 | 6.11 단계 쪼개기 |
| 3.8 | 산탄총 수술 | 8.1·8.2 옮기기 |
| 3.9 | 기능 편애 | 8.1 함수 옮기기 |
| 3.10 | 데이터 뭉치 | 7.5 클래스 추출 |
| 3.11 | 기본형 집착 | 7.3 객체로 |
| 3.12 | 반복되는 switch | 10.4 다형성 |
| 3.17 | 메시지 체인 | 7.7 위임 숨기기 |
| 3.20 | 거대한 클래스 | 7.5 |
| 3.22 | 데이터 클래스 (빈혈) | 8.1 행동 끌어오기 |
| 3.23 | 상속 포기 | 12.10 위임으로 |

### 3.2 Clean Code 17장 ⭐ 휴리스틱 (자주 인용)

| 코드 | 한 줄 | PR 코멘트 예 |
|------|------|---------|
| G5 | 중복 | "G5 — 함수 추출 검토" |
| G19 | 서술적 변수 | "G19 — 복잡한 식을 변수로" |
| G23 | If/Switch → 다형성 | "G23 적용 가능, Strategy 검토" |
| G25 | 매직 숫자 → 상수 | "G25 — 200을 의미 있는 상수로" |
| G28 | 조건 캡슐화 | "G28 — `isReady()` 같은 메서드로" |
| G30 | 함수 한 가지 | "G30 위배" |
| G34 | 추상화 수준 한 단계 | "G34 — 두 수준이 섞임" |
| N1 | 서술적 이름 | "N1 — `data` 보다 의미 있는 이름" |
| N7 | 이름으로 부수효과 설명 | "N7 — 이 함수가 이메일도 보내는데 이름은 검증만" |
| T5 | 경계 조건 테스트 | "T5 — 빈 컬렉션·null 테스트 추가" |

### 3.3 Effective Java ⭐ 핵심 20 (메서드·필드 단위)

| Item | 적용 시점 |
|------|----------|
| 1 | `new` 대신 `of`·`from`·`valueOf` |
| 5 | 의존성 주입 (생성자) |
| 9 | try-with-resources |
| 11 | equals 재정의 시 hashCode 도 |
| 17 | 불변 클래스 우선 (record 활용) |
| 18 | 상속보다 컴포지션 |
| 20 | 추상 클래스보다 인터페이스 |
| 31 | PECS — Producer Extends, Consumer Super |
| 34 | int 상수 대신 enum |
| 39 | 명명 패턴 대신 애너테이션 |
| 45 | 스트림은 신중히 (가독성 1순위) |
| 48 | 병렬화는 측정 후 |
| 49 | 매개변수 첫 줄 검증 |
| 50 | 가변 객체 방어적 복사 |
| 64 | 인터페이스로 참조 |
| 67 | 최적화는 측정 후 |
| 77 | 예외 무시 금지 |
| 78 | 공유 가변 데이터 동기화 |
| 79 | 과도한 동기화 회피 (락 안 콜백 X) |
| 85 | 자바 직렬화 대안 우선 |

### 3.4 GRASP — 책임 할당 ([[lecture-object-ch5]])

| 패턴 | 질문 |
|------|------|
| 정보 전문가 | "이 일에 필요한 정보를 누가 가장 많이 아는가?" |
| 창조자 | "A 가 B 를 생성한다면 A 는 B 의 정보를 가지는가?" |
| 낮은 결합도 | "결합도가 낮은 후보를 골랐는가?" |
| 높은 응집도 | "관련 책임이 한 객체에 모였는가?" |
| 다형성 | "타입에 따른 분기를 다형성으로?" |
| 변경 보호 | "변경 가능성 높은 부분에 안정 인터페이스?" |

---

## 4. 워크플로별 사용 방법

### 4.1 AI 프롬프트로 (Claude·ChatGPT)

**프롬프트 템플릿 (작성)**:

```
나는 Java/Spring 백엔드 개발자다. 다음 5권 도서의 원칙을 기준으로 코드를 작성해주세요:
- 오브젝트 (책임 주도 설계, 협력 우선)
- Effective Java (90 권고, 메서드 단위)
- 리팩터링 (24 악취 회피)
- Clean Code (작은 함수, 의도 드러나는 이름)
- TDD (테스트가 안전망)

특히 다음 원칙 준수:
1. 함수는 작게·한 가지·CQS
2. 추상 의존·생성자 주입
3. 매개변수 0~3개·boolean 플래그 회피
4. 불변 우선 (record)
5. 도메인 객체에 행동 (빈혈 X)
6. 테스트 함께 작성

[요구사항]: <여기에 작성할 코드 요구사항>
```

**프롬프트 템플릿 (점검)**:

```
다음 코드를 5권 도서 원칙으로 점검해주세요. 발견 사항을 다음 형식으로 보고:

| 위치 | 코드 | 점검 | 처방 |
|------|------|------|------|
| 라인 N | <코드> | <악취 코드 G5·EJ Item 18·리팩터링 3.11 등> | <구체 처방> |

점검 기준:
- 리팩터링 24 악취 (3.1~3.24)
- Clean Code 17장 휴리스틱 (특히 G19·G23·G25·G30·G34·N1·T5)
- Effective Java ⭐ 20 (Item 5·17·18·49·64·77 등)
- 오브젝트 책임 주도 + Tell, Don't Ask
- TDD F.I.R.S.T.

[코드]:
```

### 4.2 슬래시 명령 (Claude Code)

- **`/code-guide`** — 코드 작성 가이드 보기 (이 페이지 컨텍스트)
- **`/code-check`** — 현재 git diff 를 5권 원칙으로 점검

### 4.3 PR 리뷰 어휘

리뷰 코멘트에 표준 코드 인용:

```
이 부분 G23 적용 검토 — switch 가 3 곳 반복, Strategy 패턴으로
```

```
EJ Item 49 — public 메서드 첫 줄에 매개변수 검증 추가
```

```
리팩터링 3.4 (긴 매개변수 목록) → 6.8 매개변수 객체로
```

→ **합의가 빠름** — 코드 한 줄이 책 한 권 인용.

### 4.4 신입 교육

한 페이지로 5권 책의 점검 어휘 습득. 인턴·신입에게:
- "PR 올리기 전 이 페이지의 작성 체크리스트 확인"
- "리뷰 시 17장 휴리스틱 코드로 코멘트"
- "한 달 후 자기 PR 돌아보며 어떤 항목 위반했는지 확인"

---

## 5. 분야별 빠른 인덱스

### 함수 작성
- [[lecture-clean-code-ch3]] (함수)
- [[lecture-refactoring-ch6]] (기본 리팩터링)
- [[lecture-effective-java-ch8]] (메서드)

### 클래스 설계
- [[lecture-object-ch4]] (설계 품질·트레이드오프)
- [[lecture-object-ch5]] (책임 할당·GRASP)
- [[lecture-clean-code-ch10]] (클래스)
- [[lecture-effective-java-ch4]] (클래스·인터페이스)

### 의존성·DI
- [[lecture-object-ch8]] (의존성 관리)
- [[lecture-object-ch9]] (유연한 설계·OCP·DIP)
- [[concept-spring-core]] (Spring DI)

### 예외 처리
- [[lecture-clean-code-ch7]] (오류 처리)
- [[lecture-effective-java-ch10]] (예외)
- [[concept-transactional-rollback-policy]] (Spring 롤백)

### 테스트
- [[lecture-clean-code-ch9]] (단위 테스트·F.I.R.S.T.)
- [[lecture-tdd-ch1]] ~ [[lecture-tdd-ch17]] (1부 화폐 진화)
- [[src-spring-testing-ref]] (JUnit 5·MockMvc)

### 동시성
- [[lecture-clean-code-ch13]] (동시성 방어 원칙)
- [[lecture-effective-java-ch11]] (Item 78~84)

### 리팩터링 카탈로그
- [[lecture-refactoring-ch3]] (24 악취)
- [[lecture-refactoring-ch6]] ~ [[lecture-refactoring-ch12]] (66 기법)

---

## 6. 같은 인사이트 패턴 — "이름 있는 메커니즘이 즉흥보다 안전"

5권 모두에 누적된 공통 원리. 이 가이드 자체도 이 패턴의 적용:

| 영역 | 즉흥적 | 이름 있는 메커니즘 | 참조 |
|------|--------|---------------------|------|
| **코드 변경** | "그냥 고친다" | 리팩터링 66 카탈로그 + 테스트 | (이 가이드) |
| **PR 리뷰** | "왠지 별로다" | "G19·EJ Item 18·리팩터링 3.11" | (이 가이드) |
| **AI 에이전트** | "잘 해줘" 부탁 | CLAUDE.md·hooks·skills | [[concept-harness-engineering]] |
| **AI 루프** | 즉흥 프롬프트 | 루프 자체 코드 | [[concept-loop-engineering]] |
| **자기검증** | 사람이 테스트 | back-pressure hook | [[concept-claude-hooks]] |
| **트랜잭션** | "알아서 처리하겠지" | `@Transactional` + `rollbackFor` 명시 | [[concept-transactional-rollback-policy]] |

→ **공통 원리**: 안전한 시스템은 **이름·전제·절차가 명시된 메커니즘** 의 누적. "잘 알아서 한다" 는 가정은 어디서나 위험.

---

## 7. 관련 페이지

- **[[guide-java-book-study-lab]] — 5권 실습 환경 가이드 (Java 17·JUnit 5·Python·Node)** ← 이 가이드의 환경 전제
- 5권 entity: [[entity-object]] / [[entity-effective-java]] / [[entity-refactoring]] / [[entity-clean-code]] / [[entity-tdd]]
- 5권 강의 교재 인덱스: [[src-object-lecture]] / [[src-effective-java-lecture]] / [[src-refactoring-lecture]] / [[src-clean-code-lecture]] / [[src-tdd-lecture]]
- 위키 작성 표준 (이 가이드의 작성 원칙): [[guide-wiki-authoring-standards]]
- 위키 워크플로: [[concept-ingest]] / [[concept-query]] / [[concept-lint]]
- 같은 패턴 다른 영역: [[concept-harness-engineering]] / [[concept-loop-engineering]] / [[concept-claude-hooks]]
