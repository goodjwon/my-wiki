---
title: Clean Code 실전 강의 교재 17장 인덱스
type: source
tags: [book, clean-code, uncle-bob, lecture, curriculum]
sources: [clean-code/]
created: 2026-06-20
updated: 2026-06-21
---

# Clean Code 실전 강의 교재 — 17장 인덱스

## 무엇인가

Robert C. Martin *Clean Code* (Prentice Hall, 2008) 의 **1~17장** 을 Java/Spring 백엔드 입문~중급 수강생용 강의 교재로 풀어 쓴 자료. 총 **약 5,500줄**. 각 장 형식:

- 0. 도입 (학습 목표·큰 그림 ASCII·시그니처 비유·현업에서 왜 중요한가)
- 본문 (각 절별 한 줄 정의 → 비유 → Before/After → 함정 → Spring 현업)
- 종합 (핵심 교훈 + 체크리스트 + Q/A 분리 퀴즈)
- 다음 장 예고

→ 책 카드는 [[entity-clean-code]].

## 실습 환경과 장별 루틴

먼저 [[guide-java-book-study-lab]]의 Java 17 + JUnit 5 환경을 준비한다. Clean Code 강의는 거대한 프로젝트보다 **작은 함수 하나, 이름 하나, 테스트 하나**를 고치는 식으로 따라가는 편이 효과적이다.

각 장은 같은 순서로 적용한다.

1. Before 코드를 읽고 “읽는 사람이 추측해야 하는 부분”을 표시한다.
2. 이름 변경, 함수 추출, 조건 캡슐화처럼 가장 작은 정리를 하나 고른다.
3. After 코드를 작성하고 테스트를 실행한다.
4. 코드가 더 짧아졌는지보다 의도가 더 잘 보이는지 확인한다.
5. 장 끝 체크리스트를 자기 코드 한 파일에 적용한다.

## 17편 인덱스 — 각 장 본문으로 바로 진입

| 장 | 주제 | 본문 | 핵심 ⭐ |
|----|------|------|---------|
| **1장** | 깨끗한 코드 (마인드셋) | [[lecture-clean-code-ch1]] | 보이스카우트 |
| **2장** | 의미 있는 이름 | [[lecture-clean-code-ch2]] | 의도 표현·기억력 |
| **3장** | 함수 | [[lecture-clean-code-ch3]] | **작게·한 가지·CQS** |
| **4장** | 주석 | [[lecture-clean-code-ch4]] | 좋은 8 vs 나쁜 16 |
| **5장** | 형식 맞추기 | [[lecture-clean-code-ch5]] | 신문 기사 패턴 |
| **6장** | 객체와 자료 구조 | [[lecture-clean-code-ch6]] | **디미터·Tell-Don't-Ask** |
| **7장** | 오류 처리 | [[lecture-clean-code-ch7]] | **unchecked·null 금지** |
| **8장** | 경계 | [[lecture-clean-code-ch8]] | 학습 테스트·Adapter |
| **9장** | 단위 테스트 | [[lecture-clean-code-ch9]] | **TDD 3법칙·F.I.R.S.T.** |
| **10장** | 클래스 | [[lecture-clean-code-ch10]] | **SRP·응집도** |
| **11장** | 시스템 | [[lecture-clean-code-ch11]] | **DI·AOP** |
| **12장** | 창발성 | [[lecture-clean-code-ch12]] | **Kent Beck 4규칙** |
| **13장** | 동시성 | [[lecture-clean-code-ch13]] | 방어 원칙 4 |
| **14장** | 점진적 개선 (Args 사례) | [[lecture-clean-code-ch14]] | 다시 짜기 vs 점진 |
| **15장** | JUnit 들여다보기 | [[lecture-clean-code-ch15]] | 좋은 코드도 더 좋게 |
| **16장** | SerialDate 리팩터링 | [[lecture-clean-code-ch16]] | 특성화 테스트 |
| **17장** | 냄새와 휴리스틱 | [[lecture-clean-code-ch17]] | **66 휴리스틱 카탈로그** |

→ 총 **66 휴리스틱 + 단순 설계 4규칙**, **약 5,500줄**.

## 강의 교재 형식 (일관된 5단)

```
## N장 — 제목

> 대상: Java/Spring 백엔드 입문~중급
> 형식: 개념 → 비유 → Before/After → 함정 → 체크리스트 → 퀴즈
> 전제: Java 17+, Spring Boot 3.x

## 0. 이 장을 시작하기 전에
  0.1 학습 목표
  0.2 큰 그림 (ASCII 그림 + 비유)
  0.3 현업에서 왜 중요한가

## N.M 절
  ### 한 줄 정의
  ### 비유 — "..."
  ### Before / After
  ### 동기 / 절차 / 함정
  ### Spring/JPA 현업

## 핵심 교훈 / 함정 / 체크리스트

## 퀴즈 (Q/A 분리)
**Q1. ...**

**A.** ...

## 다음 장 예고
```

## 시그니처 비유 (장별)

- **1장**: 코드는 **요구사항을 정밀하게 적은 글**
- **2장**: 이름은 **표지판**
- **3장**: 함수는 **공구 한 자루**
- **4장**: 주석은 **사과문**
- **5장**: 형식은 **글의 단락**
- **6장**: 객체 vs 자료 = **사람 vs 서식**
- **7장**: 오류 처리는 **비상 대피로**
- **8장**: 경계는 **국경**
- **9장**: 단위 테스트는 **헬스장**
- **10장**: 클래스는 **방**
- **11장**: 시스템은 **도시**
- **12장**: 4규칙은 **건축 검사 체크리스트**
- **13장**: 동시성은 **공유 도마**
- **14~16장**: 사례 워크스루 — 초안·점진·레거시
- **17장**: 휴리스틱은 **주방의 점검 체크리스트**

## 책 전체 6원칙 (12장 마지막 + 17장 종합)

1. **모든 테스트 통과** (12장 1규칙)
2. **중복 없음** (12장 2규칙·G5)
3. **의도 표현** (2·3·12장)
4. **최소 클래스·메서드** (12장 4규칙·SRP)
5. **함수는 작게·한 가지** (3장·G30·G34)
6. **보이스카우트** (1·15장)

## 활용 가이드

| 목적 | 추천 진입점 |
|------|-------------|
| 입문~1년차 빠른 진입 | 1·2·3·4·10장 (마인드셋·이름·함수·주석·클래스) |
| 코드 리뷰 어휘 | 17장 휴리스틱 코드 (G19·G23·N1·T5 등) |
| 신입 교육 자료 | 1·2·3장 + 14장 (점진 정련 사례) |
| 인터뷰 준비 | 9장 (TDD·F.I.R.S.T.) + 12장 (4규칙) |
| 자기 코드 진단 | 17장 66 휴리스틱 + 6장 디미터 |

## Spring/JPA 연결 사례

| 강의 교재 | Spring/JPA 실무 |
|----------|-----------------|
| 3장 함수 | `@Valid` 진입 검증·`@Transactional` 트랜잭션 경계 |
| 6장 객체와 자료 | DTO record / Entity 분리 |
| 7장 오류 처리 | `@ControllerAdvice` + `DataAccessException` unchecked |
| 9장 테스트 | `@WebMvcTest`·`@DataJpaTest`·`@SpringBootTest` 슬라이스 |
| 10장 클래스 SRP | Service 거대화 (1,000줄+) 회피 |
| 11장 시스템 | `@Configuration`·`@Bean`·`@Component`·`@Aspect` |
| 13장 동시성 | 빈 가변 필드 위험·`@Async`·`@Scheduled` |
| 17장 G23 | `enum` + Strategy / Spring 의 `@ConditionalOnX` |

## 위키 기존 페이지와의 연결

- [[entity-clean-code]] — 책 카드 (상위)
- [[entity-effective-java]] — Java 매일의 권고
- [[entity-refactoring]] — 코드 개선 카탈로그
- [[entity-object]] — OO 책임 주도 설계
- [[concept-oop]] / [[concept-design-patterns]] / [[concept-spring-core]] / [[concept-transactional-rollback-policy]]
- [[src-spring-testing-ref]] — 9장 단위 테스트 실무

## 한계·주의

- **사용자 강사용 내부 교재** 성격 — 인용·재배포 전 확인
- **Java 17 + Spring Boot 3.x** 가정
- 책 본문 직접 인용 아닌 강의용 재구성
- "주석은 다 나쁨" 같은 도그마는 본문이 단서 ("단, ...") 를 다는 점 유의

## 관련 페이지

- [[entity-clean-code]] — 책 카드 (상위)
- [[entity-effective-java]] / [[src-effective-java-lecture]] — 같은 패턴 강의 교재
- [[entity-refactoring]] / [[src-refactoring-lecture]] — 같은 패턴 강의 교재
- [[entity-object]] / [[entity-tdd]] — 5권 오각형 비교 (entity 마다 동일 표)
- [[guide-java-book-study-lab]] — 5권 공통 실습 환경
