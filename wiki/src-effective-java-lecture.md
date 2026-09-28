---
title: Effective Java 실전 강의 교재 11장 인덱스
type: source
tags: [book, java, effective-java, lecture, curriculum]
sources: [effective_java/]
created: 2026-06-20
updated: 2026-09-28
---

# Effective Java 실전 강의 교재 — 11장 인덱스

## 무엇인가

*Effective Java* 3판 **2~12장(Item 1~90 전체)** 을 Java/Spring 백엔드 입문~중급 수강생용 강의 교재로 풀어 쓴 자료입니다. 한 장당 500~800줄, 총 **약 5,200줄**입니다. 각 아이템은 다음 요소로 구성됩니다.

- **한 줄 요약**
- **비유** (주방·메뉴판·컨베이어·도마 등 일관된 시그니처)
- **문제 코드** → **해법 코드**
- **Spring/JPA 현업 예제**
- **함정**
- **체크리스트** (코드 리뷰용)
- 장 끝: **결정 가이드 표** + **종합 체크리스트** + **펼침형 퀴즈**

→ 책 카드는 [[entity-effective-java]]입니다.

## 실습 환경과 장별 루틴

실습 환경(Java 17 + JUnit 5)과 5권 공통 루틴(읽기 → 빨강 → 초록 → 정련 → 기록)은 [[guide-java-book-study-lab]]에 있습니다. Effective Java 강의는 각 Item을 작은 API 선택으로 보고, 호출부가 어떻게 읽히고 깨지는지 확인하는 데 초점을 둡니다.

## 11장 인덱스 + 아이템 — 각 장 본문으로 바로 진입

| 장 | 주제 | 아이템 | 본문 | ⭐ 현업 최핵심 20 |
|----|------|--------|------|----------------|
| **2장** | 객체 생성과 파괴 | Item 1~9 | [[lecture-effective-java-ch2]] | **1**(정적 팩터리), **2**(빌더), **5**(DI), **9**(try-with-resources) |
| **3장** | 모든 객체의 공통 메서드 | Item 10~14 | [[lecture-effective-java-ch3]] | **11**(equals+hashCode) |
| **4장** | 클래스와 인터페이스 | Item 15~25 | [[lecture-effective-java-ch4]] | **17**(불변), **18**(컴포지션), **20**(인터페이스) |
| **5장** | 제네릭 | Item 26~33 | [[lecture-effective-java-ch5]] | **31**(PECS) |
| **6장** | 열거 타입과 애너테이션 | Item 34~41 | [[lecture-effective-java-ch6]] | **34**(enum), **39**(애너테이션) |
| **7장** | 람다와 스트림 | Item 42~48 | [[lecture-effective-java-ch7]] | **45**(스트림 신중), **48**(병렬화 주의) |
| **8장** | 메서드 | Item 49~56 | [[lecture-effective-java-ch8]] | — (49 매개변수 검증·50 방어적 복사는 핵심 20 밖의 권장 항목) |
| **9장** | 일반적인 프로그래밍 원칙 | Item 57~68 | [[lecture-effective-java-ch9]] | **64**(인터페이스 참조), **67**(최적화) |
| **10장** | 예외 | Item 69~77 | [[lecture-effective-java-ch10]] | **77**(예외 무시 금지) |
| **11장** | 동시성 | Item 78~84 | [[lecture-effective-java-ch11]] | **78**(동기화), **79**(과도 동기화 회피) |
| **12장** | 직렬화 | Item 85~90 | [[lecture-effective-java-ch12]] | **85**(자바 직렬화 대안), **90**(직렬화 프록시) |

→ 총 **90 아이템**, **5,200+ 줄**, **⭐ 20개 현업 최핵심**입니다(목록 정본은 [[entity-effective-java]]의 ⭐ 현업 최핵심 아이템 표). 각 장에는 학습 목표·비유·코드 Before/After·Spring/JPA 현업 예제·체크리스트·퀴즈가 포함됩니다.

## 강의 교재 형식 (일관된 5단)

```
## N장 — 제목

> 대상: Java/Spring 백엔드 입문~중급 수강생
> 형식: 개념 → 비유 → 현업 → 따라하기 → 함정 → 체크리스트 → 퀴즈
> 전제: Java 17+, Spring Boot 4.x (start.spring.io 기본값)

## 0. 이 장을 시작하기 전에
  0.1 학습 목표
  0.2 큰 그림 (ASCII 그림 + 비유)
  0.3 현업에서 왜 중요한가

## 아이템 N. 제목 [⭐ 표시]
  ### 한 줄 요약
  ### 비유 — "..."
  ### 문제 (안티패턴 코드)
  ### 해법 (권장 코드)
  ### Spring/JPA 현업 예제
  ### 함정
  ### 체크리스트

## N장 종합 정리
  ### 한눈에 보는 결정 가이드 (표)
  ### 종합 체크리스트 (코드 리뷰용)
  ### 종합 퀴즈 (Q/A 분리 — **Q.** 질문 + **A.** 답변)

## 다음 장 예고 — N+1장
```

## 시그니처 비유 (일관성)

- **2장**: 객체는 **주방의 그릇** (만들기·돌려쓰기·치우기)
- **3장**: equals/hashCode는 **도서관 사서**(같은 사람인데 서랍 번호 다르면 못 찾음)
- **6장**: enum은 **정식 메뉴판**, 애너테이션은 **스티커**
- **7장**: 람다는 **주문서**, 스트림은 **컨베이어 벨트** (벨트 위 손짓 = 부작용 금지)
- **8장**: 메서드는 **식당의 한 코스 요리** (입구 검사·몸통 시그니처·출구 반환)
- **10장**: 예외는 **응급실 트리아지** (진짜 응급만, 무시 금지)
- **11장**: 동시성은 **공용 주방의 도마 한 장**
- **12장**: 자바 직렬화는 **비밀번호 없는 우편물** (봉투 안 폭탄 그대로 폭발)

→ 비유는 강의에서 학습자가 "기억의 손잡이" 로 쓸 수 있게 일관되게 설계했습니다.

## Spring/JPA 연결 사례 (전 장 통틀어)

| 강의 교재 아이템 | Spring/JPA 실무 |
|------------------|-----------------|
| Item 1 정적 팩터리 | `ResponseEntity.ok()`, `List.of()`, `LocalDate.now()` |
| Item 3 싱글턴 | `@Bean`, `@Component` |
| Item 5 의존성 주입 | 생성자 주입 `@Autowired` |
| Item 9 try-with-resources | `try (var conn = dataSource.getConnection())` |
| Item 17 불변 | record DTO, `java.time` |
| Item 18 컴포지션 | Service가 Repository를 필드로 |
| Item 34 enum | JPA `@Enumerated(EnumType.STRING)` |
| Item 39 애너테이션 | `@Transactional`, `@Component`, `@Test` |
| Item 49 매개변수 검증 | `@Valid` + Bean Validation |
| Item 64 인터페이스 참조 | `JpaRepository<T, ID>` |
| Item 70 checked vs unchecked | `@Transactional` 롤백 정책 |
| Item 73 추상화 수준 | Spring의 `DataAccessException` 자동 번역 |
| Item 78 동기화 | Spring 빈 가변 필드 위험 |
| Item 80 ExecutorService | `@Async` + `TaskExecutor` |
| Item 85 직렬화 대안 | Jackson JSON 기본, Redis 캐시 직렬화 |

## 같은 인사이트 패턴 — "이 책의 6원칙"

[[entity-effective-java]]에서 추출한 "90개를 관통하는 6원칙":

1. **불변을 기본값으로** (Item 17·76 + 11·12장)
2. **인터페이스에 의존** (Item 20·64)
3. **표준을 우선** (Item 44·59·72)
4. **검증·계약을 명시** (Item 49·56·74·82)
5. **합성 > 상속** (Item 18·87 + 4장)
6. **측정 후 최적화** (Item 48·67)

→ 90개를 다 외울 필요는 없습니다. 6원칙이 80%를 가져갑니다.

## 활용 가이드

| 목적 | 추천 진입점 |
|------|-------------|
| 입문~1년차 빠른 진입 | 2장 + 4장(17·18) + 8장(49·54) + 10장(77) |
| 코드 리뷰 근거 인용 | 각 장 끝의 "종합 체크리스트" |
| 신입 교육 자료 | 각 아이템의 "비유·문제·해법·Spring/JPA" 4 섹션 발췌 |
| 인터뷰 준비 | "종합 퀴즈" Q를 먼저 보고 A 가리기 |
| 자기 학습 검증 | 체크리스트로 자기 코드베이스 진단 |

## 한계·주의

- **사용자 강사용 내부 교재** 성격이 강합니다 — 인용·재배포 전에 확인합니다
- **Java 17+** 가정 — 각 장 본문의 전제 환경 표기는 Spring Boot 3.x이며, 현재 기준(Spring Boot 4.x)과 다른 부분은 조정해 읽습니다
- **3판 기준**: record(Java 14+) 등 신문법은 일부만 언급합니다
- **모든 아이템을 강의 자료로 푸는 것은 비효율적입니다** — ⭐ 표시한 핵심부터 봅니다

## 관련 페이지

- [[entity-effective-java]] — 책 카드 (상위)
- [[entity-object]] — *오브젝트* (같은 OO 주제, 다른 관점)
- [[concept-oop]] / [[concept-design-patterns]] / [[concept-spring-core]] / [[concept-transactional-rollback-policy]] / [[concept-db-connection-pool]] — 강의 교재에서 인용되는 위키 페이지들
- [[guide-java-book-study-lab]] — 5권 공통 실습 환경
