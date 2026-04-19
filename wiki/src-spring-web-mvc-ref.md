---
title: Spring Framework Web MVC Reference
type: source
tags: [spring, mvc, controller, rest-api, 공식문서]
sources: [spring-web-mvc-ref.md]
created: 2026-04-19
updated: 2026-04-19
---

# Spring Framework Web MVC Reference

## 개요

Spring Framework 7.0.7 공식 문서의 Web MVC 핵심 내용. Annotated Controllers, @RequestBody, ResponseEntity, 전역 예외 처리 패턴을 다룬다.

원본: https://docs.spring.io/spring-framework/reference/web.html

## 수집 범위

| 섹션 | 핵심 내용 |
|------|----------|
| **Annotated Controllers** | @Controller, @RestController, 핵심 어노테이션 테이블 |
| **@RequestBody** | HttpMessageConverter, @Valid 검증, 코드 예제 |
| **ResponseEntity** | 상태코드/헤더/바디 커스터마이징, 파일 다운로드 |
| **예외 처리** | @ExceptionHandler, @ControllerAdvice 전역 패턴 |

## 관련 페이지

- [[concept-spring-core]] — MVC 구조 (DispatcherServlet, Controller, Service, Repository)
- [[src-spring-guide]] — cheese10yun 실무 가이드 (exception-guide, api-call-guide)
- [[src-kakaopay-ddd]] — DDD에서 Application → Domain 호출 구조
- [[src-spring-data-access-ref]] — 데이터 접근 계층 연결
