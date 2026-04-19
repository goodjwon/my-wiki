---
title: Spring Framework Testing Reference
type: source
tags: [spring, testing, junit, mockMvc, 공식문서]
sources: [spring-testing-ref.md]
created: 2026-04-19
updated: 2026-04-19
---

# Spring Framework Testing Reference

## 개요

Spring Framework 7.0.7 공식 문서의 Testing 핵심 내용. 어노테이션, Mock 객체, MockMvc, 테스트 계층 가이드를 다룬다.

원본: https://docs.spring.io/spring-framework/reference/testing.html

## 수집 범위

| 섹션 | 핵심 내용 |
|------|----------|
| **테스트 어노테이션** | Context, Bean/Mock, Transaction, SQL 관련 |
| **단위 테스트** | MockHttpServletRequest, ReflectionTestUtils |
| **MockMvc** | @WebMvcTest, perform, andExpect 코드 예제 |
| **테스트 계층** | 단위 → 슬라이스 → 통합 → E2E 피라미드 |

## 관련 페이지

- [[src-spring-guide]] — cheese10yun test-guide (실무 테스트 전략)
- [[src-java-study-2024-2025]] — Ch8 테스트와 품질
- [[concept-spring-core]] — Spring Bean, DI와 테스트 가능한 구조
- [[src-spring-data-access-ref]] — @Transactional 테스트 롤백
