---
title: "Java 학습 경로 T4 — Spring 웹 애플리케이션"
type: synthesis
tags: [java, study, learning-path, track4, spring, jpa, security, test]
sources: [java-study/]
created: 2026-06-29
updated: 2026-06-29
---

# Java 학습 경로 T4 — Spring 웹 애플리케이션

> **이 트랙의 목표**: 앞선 트랙의 객체지향·예외·DB 지식을 모아 **실제로 도는 웹 애플리케이션**을 만든다. IoC/DI로 조립하고, JPA·Querydsl로 데이터에 접근하고, 인증을 붙이고, 테스트로 지킨다.
>
> **선수 트랙**: [[guide-java-track3-io-network]]. **다음 트랙**: [[guide-java-track5-deep-dive]].

이 트랙은 [[src-java-study-2024-2025]] 5·6·7·8장 재구성. **실제 학습·실습은 챕터 레슨에서 따라 한다** → [[java-study-ch06]] · [[java-study-ch07]] · [[java-study-ch08]] · [[java-study-ch09]].

> 이 페이지는 **코스 안내**다(흐름·핵심·미니프로젝트·이론 팁). 코드와 상세 설명은 위 챕터 레슨을 펴고 따라 하면 된다.

---

## 📚 학습 순서

### 1단계 — Spring과 프로젝트 실행 (ch05)
| 순서 | 문서 | 한 줄 |
|------|------|------|
| 6.0 | Spring 핵심: IoC·DI·Bean·MVC | 객체 조립을 컨테이너에 위임 (→ [[concept-spring-core]]) |
| 6.1 / 6.2 | 실습 환경·Maven 구성 | 빌드·의존성 관리 |
| 6.3 | 프로파일 설정 | dev/prod 환경 분리 |

### 2단계 — 데이터 접근과 SQL (ch06)
| 순서 | 문서 | 한 줄 |
|------|------|------|
| 7.0~7.3 | DB 설계·SQL·쿼리 최적화 | 정규화·인덱스·실행계획 |
| 7.4~7.10 | Querydsl 도입~페이징 | 타입 안전 동적 쿼리 (→ [[entity-querydsl]]) |
| 7.12 | SQL 연습 문제 | 🛠 손풀기 |

### 3단계 — 서버와 인증 (ch07)
| 순서 | 문서 | 한 줄 |
|------|------|------|
| 8.0 | Tomcat 실행과 설정 | 서블릿 컨테이너 |
| 8.1~8.3 | Spring Security·토큰 인증 | 인증 흐름, JWT |

### 4단계 — 테스트와 품질 (ch08)
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
> T2의 싱글톤·팩토리를 직접 만들지 말고 스프링 빈으로. 생성자 주입이 테스트·불변성에 유리하다.
> → 자세히: [[concept-spring-core]] · [[entity-spring-boot]]

> 💡 **트랜잭션 — 롤백은 기본값을 의심하라**
> `@Transactional`은 RuntimeException만 자동 롤백한다. Checked 예외는 안 한다 — "기본값과 가정의 함정".
> → 자세히: [[concept-transactional-rollback-policy]]

> 💡 **DB — 기본값이 곧 사고**
> 커넥션 풀 크기, VARCHAR 길이, 인덱스 — 기본값을 그대로 두면 새벽에 터진다.
> → 자세히: [[concept-db-connection-pool]] · [[concept-varchar-length-prefix]]

> 💡 **API — 깨지지 않게 진화시키기**
> 응답 형식을 바꿀 땐 하위 호환·버전 관리를 의식하라. T3의 미니프로젝트가 API로 확장될 때 중요.
> → 자세히: [[concept-api-versioning]] · [[concept-api-backward-compatibility]]

> 💡 **방법론 — 테스트가 품질의 바닥을 받친다**
> 8장은 단위 테스트부터. 통합 테스트로 도배하면 느려서 안 돌리게 된다.
> → 자세히: [[entity-tdd]] · [[lecture-clean-code-ch8]]

---

## 🛠 미니프로젝트 — 도서 주문·대여 시스템

1. **도서 주문 및 대여 시스템 (11.22)** — 회원·도서·주문·대여를 엔티티로. 주문 생성+재고 차감을 **한 트랜잭션**으로(T4 핵심).
2. **레거시 실습 (11.20)** — 기존 코드를 점진적으로 개선. 테스트로 안전망을 깔고 리팩터.

**따라하는 법**:
```text
1) 도메인 모델링: 엔티티·관계·경계 정의
2) 리포지토리부터 통합 테스트 1개 (빨강)
3) 서비스에 @Transactional, 주문+재고를 원자적으로 (초록)
4) Querydsl로 조회 쿼리 정리, 커넥션 풀·인덱스 점검 (리팩터)
5) Spring Security로 회원 인증 붙이기
6) curl로 API 수동 검증 (8.3)
```
실습 본문·시나리오 → [[java-study-ch11]](11.22·11.20).

---

## ✅ 트랙 정리 체크리스트

- [ ] 생성자 주입으로 빈을 조립한다
- [ ] `@Transactional`의 롤백 규칙을 설명할 수 있다
- [ ] Querydsl로 동적 쿼리를 타입 안전하게 짠다
- [ ] 커넥션 풀·VARCHAR 등 기본값을 점검한다
- [ ] Spring Security로 인증을 붙여봤다
- [ ] 🛠 도서 주문·대여 시스템을 트랜잭션 단위로 완성했다

→ 다 체크되면 **[[guide-java-track5-deep-dive]]**(심화·워크북)로.

---

## 관련 페이지

- [[src-java-study-2024-2025]] — 원본 교재 (전체 카탈로그)
- [[concept-spring-core]] · [[entity-spring-boot]] — Spring 핵심
- [[entity-querydsl]] · [[concept-transactional-rollback-policy]] — 데이터 접근
- [[concept-db-connection-pool]] · [[concept-varchar-length-prefix]] — DB 운영 함정
- [[concept-api-versioning]] · [[concept-api-backward-compatibility]] — API 진화
- [[guide-java-track3-io-network]] · [[guide-java-track5-deep-dive]] — 이전·다음 트랙
