---
title: Wons Wiki 인덱스
updated: 2026-05-31

---

# Wons Wiki Index

## Sources
- [[src-llm-wiki-pattern]] — LLM으로 개인 지식베이스(위키)를 점진적으로 구축·유지하는 패턴 제안
- [[src-spring-boot]] — Spring Boot 공식 소개 페이지 클리핑 (v4.0.5)
- [[src-spring-framework-7]] — Spring Framework 7.0 릴리스 노트 (베이스라인·제거·신규 기능)
- [[src-claude-design-review]] — Claude Design 기능 리뷰 영상 요약 (아키모링 쏘지)
- [[src-java-study-2024-2025]] — [2024-2025] Java 스터디 자료 (Notion DB, 12챕터 91페이지)
- [[src-my-links]] — 나의 링크 (Notion 북마크 모음, 24건 본문 포함)
- [[src-spring-guide]] — Spring Guide (cheese10yun) 실무 가이드 6종
- [[src-kakaopay-ddd]] — 카카오페이 여신코어 DDD 구축기 (Bounded Context, Aggregate, Command)
- [[src-spring-data-access-ref]] — Spring Data Access 레퍼런스 (Transaction, JDBC, JPA)
- [[src-spring-web-mvc-ref]] — Spring Web MVC 레퍼런스 (Controller, REST, 예외처리)
- [[src-spring-testing-ref]] — Spring Testing 레퍼런스 (MockMvc, 어노테이션, 테스트 피라미드)
- [[src-harness-engineering]] — 하네스 엔지니어링 실습 키트 (Karpathy × OpenAI × Hashimoto, 5모듈 커리큘럼)
- [[src-copilot-token-pricing]] — GitHub Copilot 토큰 종량제 전환 (2026-06-01) — 비용 폭증·예산 상한·하네스 적용 후보

## Entities
- [[entity-vannevar-bush]] — Memex를 제안한 공학자, 개인 지식 관리의 사상적 기원
- [[entity-obsidian]] — 로컬 마크다운 기반 지식 관리 앱, LLM Wiki의 뷰어 역할
- [[entity-qmd]] — 마크다운용 로컬 하이브리드 검색 엔진 (BM25 + 벡터)
- [[entity-dataview]] — Obsidian 플러그인, frontmatter 기반 동적 쿼리 엔진
- [[entity-marp]] — 마크다운 기반 슬라이드 덱 형식
- [[entity-obsidian-web-clipper]] — 웹 기사를 마크다운으로 클리핑하는 브라우저 확장
- [[entity-spring-framework]] — Java/Kotlin 엔터프라이즈 프레임워크 (최신 7.0)
- [[entity-spring-boot]] — Spring 기반 독립 실행형 Java 프레임워크 (v4.0.5)
- [[entity-spring-initializr]] — Spring Boot 프로젝트 부트스트랩 웹 도구
- [[entity-claude-design]] — Anthropic의 AI 디자인 도구 (디자인 시스템·프로토타이핑·슬라이드덱)
- [[entity-jvm]] — Java Virtual Machine, 바이트코드 실행·메모리 관리·GC
- [[entity-querydsl]] — Java 타입 안전 쿼리 프레임워크, 동적 쿼리 조합

## Concepts
- [[concept-compounding-knowledge]] — 새 정보가 기존 지식과 결합하며 복리적으로 가치 증가
- [[concept-memex]] — Bush(1945)의 개인 지식 저장·연결 장치 비전
- [[concept-ingest]] — 새 소스를 위키에 통합하는 핵심 워크플로
- [[concept-query]] — 위키에 질의하고 답변을 합성·재편입하는 워크플로
- [[concept-lint]] — 위키 건강 상태 점검·정비 워크플로
- [[concept-api-versioning]] — Spring 7.0의 API 버전 관리 1급 지원
- [[concept-api-backward-compatibility]] — API 하위 호환성과 JSON Tolerant Reader 계약 (Gson/Jackson/kotlinx.serialization 비교)
- [[concept-jspecify-null-safety]] — JSR 305을 대체하는 JSpecify 기반 null 안전성 표준
- [[concept-oop]] — 객체지향 프로그래밍 4원칙 (캡슐화·상속·다형성·추상화)
- [[concept-design-patterns]] — Java 디자인 패턴 8가지 (전략·템플릿·팩토리·싱글톤·옵저버·프록시·어댑터·파사드)
- [[concept-spring-core]] — Spring 핵심 개념 (IoC, DI, Bean, MVC, AOP)
- [[concept-transactional-rollback-policy]] — @Transactional 롤백 정책: RuntimeException만 자동 롤백 + rollbackFor 패턴 + Java 예외 철학
- [[concept-harness-engineering]] — 하네스 엔지니어링: 부탁 대신 구조로 AI 에이전트 제어
- [[concept-claude-md]] — CLAUDE.md 에이전트 헌법 (Karpathy 4원칙 + STOP 트리거)
- [[concept-claude-hooks]] — Claude Code Hooks (guard.sh + lint-fix.sh 시스템 강제)
- [[concept-multi-agent-pattern]] — Planner / Coder / Critic 3-tier 멀티 에이전트
- [[concept-db-connection-pool]] — DB 커넥션 풀: getConnection()이 빠른 이유 + HikariCP 3타이머 + Leak 감지
- [[concept-keepalive-timeout-race]] — LB ↔ 서버 Keep-Alive 타임아웃 불일치로 인한 새벽 502 race condition
- [[concept-varchar-length-prefix]] — VARCHAR 길이 프리픽스: 255 신화의 진짜 이유 + utf8mb4 시대의 63 경계
- [[concept-cronjob-concurrency-trap]] — 크론잡 중복 실행과 Forbid 함정: concurrencyPolicy + activeDeadlineSeconds 조합
- [[concept-http-hol-blocking]] — HTTP 진화와 HOL 블로킹: 1.1 Keep-Alive → 2 멀티플렉싱 → 3 QUIC over UDP

## Synthesis
_아직 종합 분석이 없습니다._

## Synthesis
- [[guide-deploy-mkdocs-firebase]] — 위키 외부 배포 가이드 (MkDocs Material + Firebase Hosting, 무료)
- [[guide-project-docs-setup]] — 프로젝트별 문서 시스템 셋업 가이드 (CLAUDE.md 템플릿, ADR, API, 트러블슈팅)
- [[guide-harness-00-prerequisites]] — 하네스 실습 사전 안내 (Node + GCP 학습자용 환경/용어/FAQ)
- [[guide-harness-demo]] — 하네스 5분 데모: 있을 때 vs 없을 때 직접 체험 (.env 커밋 차단 시연)
- [[guide-harness-module1]] — 하네스 Module 01 실습: Failure Audit + 베이스라인 측정 (Node step-by-step)
- [[guide-harness-module2]] — 하네스 Module 02 실습: CLAUDE.md 작성 + STOP 트리거 + Before/After (Node step-by-step)
- [[guide-harness-module3]] — 하네스 Module 03 실습: guard.sh/lint-fix.sh + 자기검증 루프 (Node step-by-step)
- [[guide-harness-module4]] — 하네스 Module 04 실습: AGENTS.md + Planner/Coder/Critic 사이클 (Node step-by-step)
- [[guide-harness-module5]] — 하네스 Module 05 실습: 저장소 구조화 + 주간 리뷰 + Rippable + M1↔M5 비교 (Node step-by-step)

## Comparisons
_아직 비교 분석이 없습니다._
