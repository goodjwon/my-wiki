---
title: "Java 학습 경로 T4 — Spring 웹 애플리케이션"
type: synthesis
tags: [java, study, learning-path, track4, spring, jpa, security, test]
sources: [java-study/]
created: 2026-06-29
updated: 2026-09-29
---

# Java 학습 경로 T4 — Spring 웹 애플리케이션

> **이 트랙의 목표**: 앞선 트랙의 객체지향·예외·DB 지식을 모아 **실제로 도는 웹 애플리케이션**을 만듭니다. IoC/DI로 조립하고, JPA·Querydsl로 데이터에 접근하고, 인증을 붙이고, 테스트로 지킵니다.
>
> **선수 트랙**: [[guide-java-track3-io-network]]. **다음 트랙**: [[guide-java-track5-deep-dive]].

이 트랙은 [[src-java-study-2024-2025]]의 ch06~ch09(Spring·데이터 접근·서버와 인증·테스트)를 재구성한 것입니다. **실제 학습·실습은 챕터 레슨에서 따라 합니다** → [[java-study-ch06]] · [[java-study-ch07]] · [[java-study-ch08]] · [[java-study-ch09]].

> 이 페이지는 **코스 안내**입니다(흐름·핵심·미니프로젝트·이론 팁). 코드와 상세 설명은 위 챕터 레슨을 펴고 따라 하면 됩니다.

---

## 📚 학습 순서

### ① Spring과 프로젝트 실행 (ch06)
| 순서 | 문서 | 한 줄 |
|------|------|------|
| 6.0 | Spring 핵심: IoC·DI·Bean·MVC | 객체 조립을 컨테이너에 위임 (→ [[concept-spring-core]]) |
| 6.1 / 6.2 | 실습 환경·Maven 구성 | 빌드·의존성 관리 |
| 6.3 | 프로파일 설정 | dev/prod 환경 분리 |

### ② 데이터 접근과 SQL (ch07)
| 순서 | 문서 | 한 줄 |
|------|------|------|
| 7.0~7.3 | DB 설계·SQL·쿼리 최적화 | 정규화·인덱스·실행계획 |
| 7.4~7.10 | Querydsl 도입~페이징 | 타입 안전 동적 쿼리 (→ [[entity-querydsl]]) |
| 7.12 | SQL 연습 문제 | 🛠 손풀기 |

### ③ 서버와 인증 (ch08)
| 순서 | 문서 | 한 줄 |
|------|------|------|
| 8.0 | Tomcat 실행과 설정 | 서블릿 컨테이너 |
| 8.1~8.3 | Spring Security·토큰 인증 | 인증 흐름, JWT |

### ④ 테스트와 품질 (ch09)

> 📌 ch09는 [[guide-java-learning-path]]에서 "3단계 — 고급·품질"에 속하지만, 이 트랙에서는 Spring 웹 개발과 함께 다룹니다. 지식 계층(무엇에 속하나)과 학습 동선(언제 손에 익히나)이 다르기 때문입니다 — API를 만들자마자 테스트로 확인하는 습관을 붙이려는 배치입니다.

| 순서 | 문서 | 한 줄 |
|------|------|------|
| 9.0~9.2 | 테스트 전략·계산기 테스트 | 단위→통합 피라미드 |
| 9.3 | curl 수동 검증 | API 손으로 찔러보기 |

---

## 🧩 핵심 개념 한눈에

| 개념 | 한 줄 정의 | 자주 하는 실수 |
|------|----------|--------------|
| IoC/DI | 객체 생성·연결을 컨테이너가 | 필드 주입 남발(생성자 주입 권장) |
| 트랜잭션 | 여러 변경을 원자적으로 | RuntimeException만 자동 롤백을 모름 |
| Querydsl | 타입 안전 동적 쿼리 | 문자열 JPQL로 런타임 에러 |
| 커넥션 풀 | 커넥션 재사용 | 풀 크기·타임아웃 기본값 방치 |
| 테스트 피라미드 | 단위 多, 통합 少, E2E 最少 | 느린 통합 테스트로 도배 |

---

## 💡 이론·방법론 연결 (팁)

> 💡 **설계 — 객체 조립은 컨테이너에**
> T2의 싱글톤·팩토리를 직접 만들지 말고 스프링 빈으로 등록합니다. 생성자 주입이 테스트·불변성에 유리합니다.
> → 자세히: [[concept-spring-core]] · [[entity-spring-boot]]

> 💡 **트랜잭션 — 롤백은 기본값부터 의심하기**
> `@Transactional`은 RuntimeException만 자동 롤백하고, Checked 예외는 롤백하지 않습니다. "기본값과 가정의 함정"입니다.
> → 자세히: [[concept-transactional-rollback-policy]]

> 💡 **DB — 기본값이 곧 사고**
> 커넥션 풀 크기, VARCHAR 길이, 인덱스 — 기본값을 그대로 두면 새벽에 터집니다.
> → 자세히: [[concept-db-connection-pool]] · [[concept-varchar-length-prefix]]

> 💡 **API — 깨지지 않게 진화시키기**
> 응답 형식을 바꿀 땐 하위 호환·버전 관리를 의식하세요. T3의 미니프로젝트가 API로 확장될 때 중요합니다.
> → 자세히: [[concept-api-versioning]] · [[concept-api-backward-compatibility]]

> 💡 **방법론 — 테스트가 품질의 바닥을 받친다**
> ch09는 단위 테스트부터 시작합니다. 통합 테스트로 도배하면 느려서 안 돌리게 됩니다.
> → 자세히: [[entity-tdd]] · [[lecture-clean-code-ch8]]

---

## 🧪 트랙 마무리 — 과제 2. 도서 대여 REST API

이 트랙의 Spring·JPA·트랜잭션·예외 처리·테스트를 [[guide-java-practice-spring-library]]에서 프로젝트 하나로 확인합니다. 도서·회원·대출 REST API를 계층별로 구현하고, 대출 업무 규칙(중복 대출·연체·권수 제한)을 409 응답으로 표현한 뒤, H2 콘솔·Swagger·curl 시나리오와 테스트 9개로 검증합니다.

이어서 [[guide-java-practice-library-ui]]에서 이 API를 쓰는 화면을 만들고, [[guide-java-practice-library-merge]]에서 둘을 합쳐 한 jar로 배포합니다. 마지막으로 [[guide-java-practice-library-book-search]]에서 카카오 책 검색 API를 `RestClient`로 연동해 도서를 가져와 등록합니다.

**보충 연습** (챕터 실전문제, 시간이 남으면):

- 11.22 도서 주문 및 대여 시스템 — 주문 생성과 재고 차감을 한 트랜잭션으로 → [[java-study-ch11]]
- 11.20 레거시 실습 — 테스트로 안전망을 깔고 점진적으로 개선 → [[java-study-ch11]]
- 8.3 인증 curl 왕복 — 과제 2에 Spring Security를 붙이는 확장 → [[java-study-ch08]]

---

## ✅ 트랙 정리 체크리스트

- [ ] 생성자 주입으로 빈을 조립합니다
- [ ] `@Transactional`의 롤백 규칙을 설명할 수 있습니다
- [ ] Querydsl로 동적 쿼리를 타입 안전하게 짭니다
- [ ] 커넥션 풀·VARCHAR 등 기본값을 점검합니다
- [ ] Spring Security로 인증을 붙여봤습니다
- [ ] 🧪 과제 2를 완성하고 curl 시나리오의 409·400·404 응답을 직접 확인했습니다

→ 다 체크되면 **[[guide-java-track5-deep-dive]]**(심화·워크북·종합)로 넘어갑니다.

---

## 관련 페이지

- [[src-java-study-2024-2025]] — 원본 교재 (전체 카탈로그)
- [[concept-spring-core]] · [[entity-spring-boot]] — Spring 핵심
- [[entity-querydsl]] · [[concept-transactional-rollback-policy]] — 데이터 접근
- [[concept-db-connection-pool]] · [[concept-varchar-length-prefix]] — DB 운영 함정
- [[concept-api-versioning]] · [[concept-api-backward-compatibility]] — API 진화
- [[guide-java-track3-io-network]] · [[guide-java-track5-deep-dive]] — 이전·다음 트랙
- [[guide-java-practice-library-ui]] · [[guide-java-practice-library-merge]] · [[guide-java-practice-library-book-search]] — 과제 2 이어서: 화면 만들기, API 병합, 외부 API 연동
