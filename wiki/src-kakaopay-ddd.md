---
title: 카카오페이 여신코어 DDD 구축기
type: source
tags: [ddd, spring, kotlin, 도메인설계, 카카오페이]
sources: [kakaopay-ddd.md]
created: 2026-04-19
updated: 2026-04-19
---

# 카카오페이 여신코어 DDD 구축기

## 개요

카카오페이 후불결제(BNPL) 여신코어시스템을 DDD(Domain Driven Design)로 내재화한 실무 경험기. Bounded Context, Aggregate Root, Command 패턴, DomainEntity/JpaEntity 분리를 Kotlin + Spring Boot로 구현한 사례를 다룬다.

원본: https://tech.kakaopay.com/post/backend-domain-driven-design/

## 핵심 설계 원칙

| 원칙 | 내용 |
|------|------|
| **Bounded Context** | Gradle module 단위, 명시적 경계 |
| **Aggregate Root** | 트랜잭션 경계, Root를 통해서만 내부 접근 |
| **도메인 기능 독점** | 각 도메인의 기능은 타도메인에서 수행 불가 |
| **DomainEntity ↔ JpaEntity 분리** | DB 구조에 종속되지 않는 도메인 설계 |
| **Command 패턴** | `CreateCommand`, `ConfirmOverdueCommand` 등 |
| **Biz-component** | 여러 도메인 걸친 공통 기능 분리 |

## 주목할 점

- **유비쿼터스 언어**가 프로젝트 성공의 핵심 — 기획자·여신전문가·개발자 공통 언어
- 도메인 기능을 먼저 단위테스트로 검증한 뒤 Application 조합
- PlantUML로 비즈니스 흐름을 가시화하고 팀 리뷰
- JPA Entity `internal` 선언으로 도메인 경계 강제 (다만 배치에서 중복 Entity 문제)

## 관련 페이지

- [[concept-oop]] — DDD의 기반이 되는 객체지향 원칙
- [[concept-spring-core]] — Spring DI/Bean으로 도메인 모듈 조합
- [[src-spring-guide]] — cheese10yun의 Spring 실무 가이드 (domain-guide 참고)
- [[entity-spring-boot]] — Spring Boot 프레임워크
- [[src-java-study-2024-2025]] — Java 스터디 Ch2 OOP, Ch4 디자인패턴과 연결
