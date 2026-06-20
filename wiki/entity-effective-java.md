---
title: Effective Java (Joshua Bloch, 3판 2018)
type: entity
tags: [book, java, jvm, effective-java, joshua-bloch, oop, concurrency]
sources: [effective_java/]
external:
  - https://www.oreilly.com/library/view/effective-java-3rd/9780134686097/
  - https://ekis.github.io/effective-java-3rd-edition
created: 2026-06-20
updated: 2026-06-20
---

# Effective Java — 자바를 "잘" 쓰는 90가지 원칙

## 정의

Joshua Bloch(JDK 컬렉션·`java.lang` 핵심 설계자) 가 자바 API를 만들며 쌓은 **90개 권고**를 "아이템" 단위로 모은 책. 한 권 통째로 읽기보다 **언제든 펼쳐 보는 참조서** 로 쓰는 게 일반적.

> **본질**: "자바로 짤 수 있는가"에서 "자바로 잘 짜는가"로의 관점 전환. 언어 문법보다 **API 설계·성능·안전성**의 누적된 지혜.

## 책 메타데이터

| 항목 | 값 |
|------|----|
| 저자 | Joshua Bloch (전 Sun, 카네기 멜런 교수) |
| 원서 | *Effective Java*, 3rd Edition (Addison-Wesley, 2018) |
| 한국어판 | *이펙티브 자바* 3판 (인사이트, 2018, 이복연 옮김) |
| 분량 | 약 400페이지, 12장 + 90 아이템 |
| 기준 자바 | Java 7~9 (3판 시점). Java 21까지도 유효 |
| 영문 텍스트 사본 | https://ekis.github.io/effective-java-3rd-edition |
| 선행 도서 | 자바 기본 문법·OOP 이해 (1~2년차 이상) |
| 후속 도서 | *Java Concurrency in Practice* (Goetz) — 11장 심화 |

## 핵심 메시지 (90개를 관통하는 6원칙)

| # | 원칙 | 관련 장·아이템 |
|---|------|----------------|
| 1 | **불변을 기본값으로** | Item 17(불변 클래스), 76(실패 원자성), 11장 동시성, 12장 직렬화 |
| 2 | **인터페이스에 의존** | Item 20(인터페이스 > 추상 클래스), 64(인터페이스로 참조), DI |
| 3 | **표준을 우선** | Item 44(표준 함수형 인터페이스), 59(라이브러리), 72(표준 예외) |
| 4 | **검증·계약을 명시** | Item 49(매개변수 검증), 56(Javadoc), 74(@throws), 82(스레드 안전성 문서) |
| 5 | **합성 > 상속** | Item 18(상속 대신 컴포지션), 87(커스텀 직렬화), 4장 |
| 6 | **측정 후 최적화** | Item 48(병렬 스트림), 67(최적화는 신중히) |

90개 아이템 중 어느 하나를 잊어도 이 6가지를 체화하면 90%를 가져간다.

## 12장 흐름

| 장 | 주제 | 아이템 | 강의 교재 |
|----|------|--------|-----------|
| 1 | 들어가며 | — | (없음) |
| 2 | 객체 생성과 파괴 | Item 1~9 | `raw/effective_java/이펙티브 자바 실전 강의 교재 2장.md` |
| 3 | 모든 객체의 공통 메서드 | Item 10~14 | `raw/effective_java/...3장.md` |
| 4 | 클래스와 인터페이스 | Item 15~25 | `...4장.md` |
| 5 | 제네릭 | Item 26~33 | `...5장.md` |
| 6 | 열거 타입과 애너테이션 | Item 34~41 | `...6 장.md` |
| 7 | 람다와 스트림 | Item 42~48 | `...7장.md` |
| 8 | 메서드 | Item 49~56 | `...8장.md` |
| 9 | 일반적인 프로그래밍 원칙 | Item 57~68 | `...9장.md` |
| 10 | 예외 | Item 69~77 | `...10장.md` |
| 11 | 동시성 | Item 78~84 | `...11장.md` |
| 12 | 직렬화 | Item 85~90 | `...12장.md` |

→ 각 장 위키 인덱스는 [[src-effective-java-lecture]].
→ 12장 한 페이지 핵심 요약은 [[src-effective-java-summary]].

## ⭐ 현업 최핵심 아이템 (강의 교재에서 ⭐ 표시한 것 종합)

| Item | 제목 | 왜 핵심인가 |
|------|------|-------------|
| **1** | 생성자 대신 정적 팩터리 메서드를 고려하라 | `of`/`from`/`valueOf`가 표준 — 이름으로 의도 표현 |
| **2** | 빌더를 고려하라 | 인자 4개+ 객체의 표준 — Lombok `@Builder`/record |
| **5** | 자원을 직접 명시하지 말고 의존성 주입을 사용하라 | Spring DI의 이론적 근거 |
| **9** | try-finally보다는 try-with-resources를 사용하라 | 자원 누수 예방의 정석 |
| **11** | equals 재정의하려거든 hashCode도 재정의하라 | JPA 엔티티 사고 단골 |
| **17** | 변경 가능성을 최소화하라 (불변 클래스) | 동시성·실패 원자성 모두 |
| **18** | 상속보다는 컴포지션을 사용하라 | OOP 설계의 핵심 — *오브젝트* 11장과 직결 |
| **20** | 추상 클래스보다는 인터페이스를 우선하라 | DI·테스트 가능성 |
| **31** | 한정적 와일드카드를 사용하라 (PECS) | Producer Extends Consumer Super — 제네릭 API 설계 |
| **34** | int 상수 대신 열거 타입을 사용하라 | 도메인 상수 모델링 |
| **39** | 명명 패턴보다 애너테이션을 사용하라 | `@Component`/`@Transactional`이 곧 이 원칙 |
| **45** | 스트림은 주의해서 사용하라 | 가독성 1순위 |
| **48** | 스트림 병렬화는 신중히 | 측정 없는 `.parallel()` 금지 |
| **64** | 객체는 인터페이스를 사용해 참조하라 | DI·교체 가능성 |
| **67** | 최적화는 신중히 하라 | Knuth "premature optimization is the root of all evil" |
| **77** | 예외를 무시하지 말라 | 빈 catch = 화재경보기 제거 |
| **78** | 공유 가변 데이터는 동기화해 사용하라 | Spring 빈의 가변 필드 위험 |
| **79** | 과도한 동기화는 피하라 | 락 안에서 외부 콜백 = 데드락 |
| **85** | 자바 직렬화의 대안을 찾으라 | RCE 취약점의 근원 — JSON/Protobuf 우선 |
| **90** | 직렬화 프록시 사용을 검토하라 | 어쩔 수 없는 자바 직렬화의 최선 |

## 위키 기존 페이지와의 매핑

| Effective Java 주제 | 장·Item | 위키 기존 페이지 |
|---------------------|---------|------------------|
| OOP 4원칙 (캡슐화·상속·다형성·추상화) | 2·4·12장 | [[concept-oop]] |
| 디자인 패턴 (Factory/Builder/Strategy/Template) | 2·5·15장 | [[concept-design-patterns]] |
| Spring DI = Item 5 의존성 주입 | Item 5 | [[concept-spring-core]] |
| try-with-resources = Item 9 | Item 9 | [[concept-db-connection-pool]] (HikariCP getConnection 패턴) |
| 책임 주도 설계 + 합성 > 상속 | Item 18 | [[entity-object]] (11장 합성과 유연한 설계) |
| `@Transactional` checked vs unchecked | Item 70 | [[concept-transactional-rollback-policy]] |
| JPA 엔티티 equals/hashCode 함정 | Item 11 | [[concept-spring-core]] (관련) |
| EnumType.STRING (ORDINAL 위험) | Item 34·35 | (신규 후보 — `concept-jpa-enum-mapping`) |
| 표준 함수형 인터페이스 | Item 44 | (신규 후보 — `concept-functional-interfaces`) |
| 한정적 와일드카드 (PECS) | Item 31 | (신규 후보 — `concept-generics-pecs`) |
| 자바 직렬화 RCE | Item 85·88·90 | (신규 후보 — `concept-java-serialization-risk`) |

→ **신규 concept 후보 4개** — 본문 노트·실무 사례 입력 시 ingest. 백로그 등록.

## 같은 인사이트 패턴 — "공개 API는 영원하다"

Effective Java 전반을 관통하는 또 하나의 원칙: **한 번 공개된 결정은 영원히 가져간다**. 그래서 신중해야 한다.

| 위키 페이지 | 어떤 "공개 결정"의 영구성 | 함정 |
|-------------|-------------------------|------|
| (이 페이지) Item 51·56·64 | 메서드 시그니처·Javadoc·반환 타입 | 한 번 공개되면 호환성 깨뜨릴 수 없음 |
| Item 86 (직렬화) | 직렬화 형태 | `serialVersionUID` 관리 부담 영구 |
| [[concept-api-versioning]] | API 엔드포인트·DTO 스키마 | 버전 분기·deprecation 비용 |
| [[concept-api-backward-compatibility]] | JSON Tolerant Reader 계약 | 필드 추가/제거 시 깨짐 |
| [[concept-varchar-length-prefix]] | DB 스키마 (VARCHAR 길이) | 마이그레이션 비용 |

→ **공통 원리**: 공개 인터페이스(API·시그니처·스키마·직렬 형태)는 결정 시점에 신중을 다해야 한다. 후일 변경 비용이 사용자 수·데이터 양에 비례해 폭증.

## *오브젝트*와의 관계

같은 OO 설계 주제를 **두 책이 보완 관계**로 다룬다.

| 측면 | Effective Java | [[entity-object]] |
|------|----------------|-------------------|
| 관점 | **API 설계자**의 권고 90개 | **책임 주도 설계** 관점에서 처음부터 다시 |
| 단위 | 작은 단위 (메서드·필드·생성자) | 큰 단위 (객체·협력·역할) |
| 비중 | 자바 언어·표준 라이브러리 70% | OO 설계 원칙 100% |
| 깊이 | 90 아이템 (얕고 넓음) | 1 시나리오 깊이 (영화 예매·핸드폰 과금) |
| 누구에게 | 1~5년차 자바 개발자 | 3~10년차 설계·리뷰어 |
| 함께 읽으면 | "각 메서드·필드를 어떻게" | "왜 그렇게 객체를 나눠야" |

> **추천 순서**: 신입~1년차는 *Effective Java* 2·3·8·10장 발췌 → 3~5년차에 *오브젝트* 1~5장 → 그 뒤 두 책 교차 참조.

## 누구에게·언제 권할 책인가

| 독자 | 효과 |
|------|------|
| **1~3년차 자바 개발자** | "왜 이렇게 짜야 하나" 가 비로소 연결됨. 코드 리뷰에서 자주 지적받는 항목들의 출처 |
| **5년차+ 리뷰어** | 리뷰 코멘트에 "Effective Java Item N" 으로 합의된 근거 인용 가능 |
| **API 라이브러리 만드는 사람** | 시그니처·문서화·예외 설계의 표준 매뉴얼 |
| **Spring·JPA만 익숙한 사람** | 프레임워크 위의 코드가 왜 그렇게 짜였는지(`@Bean`=Item 3, `@Autowired`=Item 5, `@Transactional`=Item 39) 이해 |

## 빠른 진단 — 이 책을 펴야 할 신호

- [ ] `equals`/`hashCode` 둘 중 하나만 재정의한 경험이 있다 (Item 11)
- [ ] 자원을 `try-finally`로 닫고 있다 (Item 9 → try-with-resources)
- [ ] 인자 5개 이상 메서드가 흔하다 (Item 2 → 빌더, Item 51 → 매개변수 객체)
- [ ] `null`을 반환해 호출자가 NPE 위험에 노출된 적 있다 (Item 54·55)
- [ ] 빈 catch 블록을 본 적 있다 (Item 77)
- [ ] `new Thread()`를 직접 만들거나 `Executors.newCachedThreadPool()`을 무지성 쓰고 있다 (Item 80)
- [ ] 자바 직렬화로 받은 객체를 외부 입력에 노출하고 있다 (Item 85·88)

위 중 2개 이상이면 해당 Item을 우선 발췌해서 읽는 게 가성비 최고.

## 한계·주의

- **자바 7~9 기준**이라 record(Java 14+)·sealed class(Java 17+)·pattern matching 같은 신문법은 안 다룸. 단, 권고 원칙 자체는 그대로 유효.
- **함수형 강조 부족**: 7장(람다·스트림)이 있지만, Scala/Kotlin 수준의 함수형 사고는 다른 책으로 보완 필요.
- **현업 풀스택 관점 부족**: API 설계 관점이라 분산 시스템·MSA·관측성은 다른 책 영역.
- **90개를 다 외울 필요 없다**: 위 "6원칙"과 "⭐ 현업 최핵심 20개"가 80%.

## 원본 출처

- `raw/effective_java/이펙티브 자바 실전 강의 교재 2장.md` ~ `12장.md` — 강의용 교재 11편 (Item 1~90 전체 커버)
- `raw/effective_java/개발서적 이펙티브 자바...핵심 요약 및 정리 - 조슈아 블로크.md` — 모찌모찝 블로그 1장 요약 (출처: https://mozzi-devlog.tistory.com/88)
- 영문 사본: https://ekis.github.io/effective-java-3rd-edition

## 관련 페이지

- [[src-effective-java-summary]] — 12장 한 페이지 요약 (블로그 출처)
- [[src-effective-java-lecture]] — 강의 교재 11장 인덱스 (각 장 본문 링크)
- [[entity-object]] — *오브젝트* (한국어 OO 설계 표준, 같은 주제 다른 관점)
- [[entity-refactoring]] — *리팩터링 2판* (90 아이템이 매일 짤 때의 권고라면, 리팩터링은 이미 짠 코드의 카탈로그)
- [[concept-oop]] — OOP 4원칙 (책의 2·4·12장 직접 연결)
- [[concept-design-patterns]] — 디자인 패턴 (Factory·Builder·Strategy·Template)
- [[concept-spring-core]] — Spring DI (Item 5의 실무 구현)
- [[concept-transactional-rollback-policy]] — `@Transactional` 롤백 정책 (Item 70)
- [[concept-db-connection-pool]] — HikariCP (Item 9 try-with-resources 사례)
- [[concept-api-versioning]] / [[concept-api-backward-compatibility]] — "공개 API는 영원하다" 패턴
