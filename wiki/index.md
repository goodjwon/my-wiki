---
title: Wons Wiki — 개인 지식 위키
updated: 2026-09-28

---

# Wons Wiki

개발하며 배운 개념과 원칙을 영속적으로 정리하는 개인 지식 위키입니다. 실습은 직접 실행해 검증한 결과만 싣습니다.

시사성 있는 글은 [블로그](https://blog.wonslab.dev)에 발행하고, 이 위키에는 두고두고 재활용할 개념을 모읍니다.

## 처음이라면

| 목적 | 시작 페이지 |
|------|------------|
| Java를 처음부터 순서대로 배우고 싶다면 | [[guide-java-learning-path]] — 기초부터 Spring·실전까지 5개 트랙 지도 |
| 설계·리팩터링·테스트 명저를 함께 읽고 싶다면 | [[guide-java-book-study-lab]] — 5권 도서 읽는 순서·비교·실습 환경 |
| AI 에이전트 하네스를 바로 체험하고 싶다면 | [[guide-harness-demo]] — 하네스가 있을 때와 없을 때를 5분 안에 비교 |
| 운영 장애의 공통 원인이 궁금하다면 | [[concept-db-connection-pool]] — "기본값과 가정의 함정" 패턴의 대표 사례 |

## Java·Spring

### 학습 경로와 챕터

- [[guide-java-learning-path]] — Java 학습 전체 지도 (기초→설계→입출력→Spring→실전)
- 1단계 Java Core: [[java-study-ch00]] 안내 · [[java-study-ch01]] 환경과 실행 · [[java-study-ch02]] 문법과 객체 · [[java-study-ch03]] 컬렉션과 함수형 · [[java-study-ch04]] 설계와 패턴 · [[java-study-ch05]] 입출력과 네트워크
- 2단계 Spring·웹: [[java-study-ch06]] Spring과 프로젝트 실행 · [[java-study-ch07]] 데이터 접근과 SQL · [[java-study-ch08]] 서버와 인증
- 3단계 고급·품질: [[java-study-ch09]] 테스트와 품질 · [[java-study-ch10]] JVM과 성능 · [[java-study-ch11]] 부록

### 학습 코스와 실습 과제

- [[guide-java-track1-basics]] — T1. Java 기초 다지기
- [[guide-java-track2-design]] — T2. 객체지향 설계
- [[guide-java-practice-core]] — 과제 1. 주문 처리 콘솔 앱 (컬렉션·전략·옵저버·미니 IoC)
- [[guide-java-track3-io-network]] — T3. 입출력과 네트워크
- [[guide-java-track4-spring-web]] — T4. Spring 웹
- [[guide-java-practice-spring-library]] — 과제 2. 도서 대여 REST API (Spring Boot + JPA + H2)
- [[guide-java-practice-library-ui]] — 과제 2-2. 도서 대여 화면 (React + Vite, 목업 모드)
- [[guide-java-practice-library-merge]] — 과제 2-3. API와 화면 병합 (Vite 프록시·CORS·Playwright·한 jar 배포)
- [[guide-java-track5-deep-dive]] — T5. 심화·워크북·종합
- [[guide-java-practice-layered-quotation]] — 과제 3. 견적·계약 업무 (4계층 + Command/Query 분리 + MyBatis)

### 개념 레퍼런스

- [[concept-spring-core]] — Spring 핵심 개념 (IoC, DI, Bean, MVC, AOP)
- [[concept-transactional-rollback-policy]] — @Transactional은 RuntimeException만 자동 롤백하는 이유와 rollbackFor 패턴
- [[concept-api-versioning]] — Spring 7.0의 API 버전 관리 1급 지원
- [[concept-api-backward-compatibility]] — API 하위 호환성과 JSON Tolerant Reader 계약
- [[concept-jspecify-null-safety]] — JSR 305를 대체하는 JSpecify 기반 null 안전성
- [[concept-jpa-enum-mapping]] — `@Enumerated` 기본값 ORDINAL의 함정
- [[concept-functional-interfaces]] — 표준 함수형 인터페이스 6종과 Spring 활용
- [[concept-generics-pecs]] — 한정적 와일드카드와 PECS 원칙
- [[concept-java-serialization-risk]] — Java 직렬화의 위험과 방어

### 도구와 원본

- [[entity-jvm]] — 바이트코드 실행·메모리 관리·GC
- [[entity-querydsl]] — 타입 안전 동적 쿼리 프레임워크
- [[entity-spring-framework]] — Java/Kotlin 엔터프라이즈 프레임워크 (최신 7.0)
- [[entity-spring-boot]] — 독립 실행형 Spring 애플리케이션 프레임워크
- [[entity-spring-initializr]] — Spring Boot 프로젝트 생성 도구
- [[src-spring-framework-7]] — Spring Framework 7.0 릴리스 노트 요약
- [[src-spring-data-access-ref]] — Spring 트랜잭션·JDBC·JPA 레퍼런스 요약
- [[src-java-study-2024-2025]] — Java 스터디 원본 자료 (12챕터)

## 개발방법론

### 개념

- [[concept-oop]] — 객체지향 4원칙 (캡슐화·상속·다형성·추상화)
- [[concept-design-patterns]] — 실무에서 자주 쓰는 디자인 패턴 8가지
- [[concept-naming-conventions]] — 이름은 문서이자 계약입니다
- [[concept-tdd-laws-and-first]] — TDD 3법칙과 좋은 테스트의 F.I.R.S.T. 속성
- [[concept-simple-design-rules]] — Kent Beck의 단순 설계 4규칙
- [[concept-grasp]] — GRASP 책임 할당 9패턴
- [[concept-solid]] — SOLID 5원칙 심화
- [[concept-design-by-contract]] — 계약에 의한 설계와 Java 실현 수단
- [[concept-domain-model-kinds]] — 분석·설계·구현 모델의 구분

### 5권 도서 (책 카드 · 강의 인덱스)

| 도서 | 책 카드 | 장별 강의 |
|------|--------|----------|
| Clean Code (Robert C. Martin) | [[entity-clean-code]] | [[src-clean-code-lecture]] — 17장 |
| Effective Java 3판 (Joshua Bloch) | [[entity-effective-java]] | [[src-effective-java-lecture]] — 11장 |
| 리팩터링 2판 (Martin Fowler) | [[entity-refactoring]] | [[src-refactoring-lecture]] — 12장 |
| 오브젝트 (조영호) | [[entity-object]] | [[src-object-lecture]] — 15장 + 부록 |
| 테스트 주도 개발 (Kent Beck) | [[entity-tdd]] | [[src-tdd-lecture]] — 32장 + 부록 |

### DDD

- [[src-kakaopay-ddd]] — 카카오페이 여신코어 DDD 구축기
- [[concept-id-reference-vs-object-reference]] — 애그리거트 경계를 넘는 연결은 ID 참조로
- [[concept-aggregate-boundary]] — 애그리거트 경계를 라이프사이클 기준으로 긋기
- [[concept-domain-event-eventual-consistency]] — 도메인 이벤트와 최종 일관성

### 실습

- [[guide-java-book-study-lab]] — 5권 도서 공통 가이드 (읽는 순서·비교·실습 환경)
- [[guide-code-authoring-and-review]] — 코드 작성 체크리스트와 리뷰 어휘

## DB·운영·인프라

"기본값과 가정의 함정"이 반복되는 운영 사례를 모았습니다.

- [[concept-db-connection-pool]] — DB 커넥션 풀과 HikariCP 타이머·누수 감지
- [[concept-varchar-length-prefix]] — VARCHAR(255) 관습의 진짜 이유와 utf8mb4 경계
- [[concept-keepalive-timeout-race]] — LB와 서버의 Keep-Alive 타임아웃 불일치로 생기는 502
- [[concept-cronjob-concurrency-trap]] — 크론잡 중복 실행과 Forbid 정책의 함정
- [[concept-http-hol-blocking]] — HTTP 1.1→2→3 진화와 HOL 블로킹

## 앱 개발·출시

- [[concept-local-first-append-only]] — Local-first + Append-only: 기록이 진실이고 통계는 파생입니다
- [[concept-wall-clock-state-machine]] — 벽시계 앵커 기반 타이머 상태기계
- [[concept-thin-client-idempotent-sync]] — 얇은 클라이언트와 멱등 동기화
- [[src-workout-history-launch]] — Workout History 앱 출시기 (설계 원칙·시행착오·에이전트 개발)

## 하네스·AI 에이전트

### 개념

- [[concept-harness-engineering]] — 부탁 대신 구조로 AI 에이전트를 제어합니다
- [[concept-claude-md]] — CLAUDE.md 에이전트 헌법과 STOP 트리거
- [[concept-claude-hooks]] — Claude Code Hooks로 규칙을 시스템이 강제
- [[concept-multi-agent-pattern]] — Planner / Coder / Critic 멀티 에이전트
- [[concept-loop-engineering]] — 사람의 확인을 시스템 루프로 대체
- [[concept-advisor-worker]] — 판단과 구현을 분리해 위임하는 Advisor–Worker 패턴
- [[concept-graph-engineering]] — 제어 흐름을 노드·엣지로 명시하는 그래프 엔지니어링
- [[comparison-advisor-worker-vs-graph]] — 역할 분할과 그래프, 개선이 아니라 축이 다릅니다

### 원문 정리

- [[src-harness-engineering]] — 하네스 엔지니어링 실습 키트 (5모듈 커리큘럼)
- [[src-loop-engineering]] — Loop 엔지니어링 원문
- [[src-ai-advisor-worker]] — Advisor–Worker 원문
- [[src-graph-engineering]] — 그래프 엔지니어링 원문

### 하네스 코스

- [[guide-harness-00-prerequisites]] — 사전 안내 (환경·용어·FAQ)
- [[guide-harness-demo]] — 5분 데모: 하네스가 있을 때와 없을 때
- [[guide-harness-module1]] — M1. 실패 감사와 베이스라인 측정
- [[guide-harness-module2]] — M2. CLAUDE.md 작성과 STOP 트리거
- [[guide-harness-module3]] — M3. Hooks와 자기검증 루프
- [[guide-harness-module4]] — M4. 멀티 에이전트와 컨텍스트 관리
- [[guide-harness-module5]] — M5. 주간 리뷰와 Rippable 구조

### 에이전트 패턴 실습

- [[guide-loop-engineering-demo]] — Loop 엔지니어링: 메아리방 루프와 거부 신호 루프 비교
- [[guide-advisor-worker-demo]] — Advisor–Worker 기본: 도구 제한과 검증 게이트
- [[guide-advisor-worker-advanced]] — Advisor–Worker 심화: 재위임·병렬 위임·모델 티어링
- [[guide-graph-engineering-demo]] — 그래프 엔지니어링: 블랙박스 에이전트와 명시적 그래프 비교

### AI 도구·동향

- [[entity-claude-design]] — Anthropic의 AI 디자인 도구
- [[src-copilot-token-pricing]] — GitHub Copilot 토큰 종량제 전환과 비용 관리

## 위키 운영

### 개념

- [[concept-compounding-knowledge]] — 새 정보가 기존 지식과 결합하며 복리로 쌓입니다
- [[concept-memex]] — 개인 지식 저장·연결 장치 Memex의 비전
- [[entity-vannevar-bush]] — Memex를 제안한 공학자
- [[concept-wiki-workflow]] — LLM 위키 워크플로 (Ingest·Query·Lint)

### 도구와 원문

- [[entity-obsidian]] — 로컬 마크다운 지식 관리 앱과 주변 도구
- [[src-llm-wiki-pattern]] — LLM으로 개인 위키를 구축·유지하는 패턴

### 운영 가이드

- [[guide-deploy-mkdocs-firebase]] — MkDocs Material + Firebase Hosting 무료 배포
- [[guide-project-docs-setup]] — 프로젝트별 문서 시스템 셋업 (CLAUDE.md·ADR·트러블슈팅)
- [[guide-wiki-authoring-standards]] — 위키 작성 표준 (다이어그램·분량·셀프 체크)
