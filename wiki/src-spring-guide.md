---
title: Spring Guide (cheese10yun)
type: source
tags: [spring, spring-boot, 가이드, 실무]
sources: [spring-guide.md]
created: 2026-04-19
updated: 2026-04-19
---

# Spring Guide (cheese10yun)

## 개요

cheese10yun의 Spring Boot 실무 가이드 모음. GitHub 저장소에서 6개 가이드 문서를 수집했다.

원본: https://github.com/cheese10yun/spring-guide

## 가이드 목록

| 문서 | 핵심 내용 |
|------|----------|
| **directory-guide** | 패키지 구조, 레이어 분리, 네이밍 컨벤션 |
| **domain-guide** | 도메인 객체 설계, 엔티티/VO 구분, 비즈니스 로직 배치 |
| **exception-guide** | 예외 처리 전략, 커스텀 예외, `@ControllerAdvice` |
| **service-guide** | 서비스 레이어 설계, 트랜잭션 경계, 책임 분리 |
| **api-call-guide** | 외부 API 호출 패턴, RestTemplate/WebClient |
| **test-guide** | 테스트 전략, 단위/통합/슬라이스 테스트, Mock 활용 |

## 핵심 메시지

> 실무에서 반복되는 구조적 결정을 가이드로 표준화하면, 팀 전체의 코드 품질이 일관되게 올라간다.

## 관련 페이지

- [[concept-spring-core]] — IoC, DI, Bean, MVC 핵심 개념
- [[concept-oop]] — 도메인 설계의 기반이 되는 객체지향 원칙
- [[concept-design-patterns]] — 가이드에서 활용되는 디자인 패턴
- [[entity-spring-boot]] — Spring Boot 프레임워크
- [[src-java-study-2024-2025]] — Java 스터디 교재와 상호 보완
