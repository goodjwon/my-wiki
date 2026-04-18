---
title: API Versioning (Spring)
type: concept
tags: [Spring, API, 버저닝, 웹]
sources: [Spring Framework Versions.md]
created: 2026-04-18
updated: 2026-04-18
---

# API Versioning

Spring Framework 7.0에서 도입된 API 버전 관리 1급 지원 기능.

## 서버 측
- 요청의 API 버전을 기준으로 컨트롤러 메서드 매핑 및 함수형 엔드포인트 라우팅
- 버전 해석(resolve), 파싱, 검증 방식 커스터마이징 가능
- 버전 deprecated 표시로 클라이언트 알림

## 클라이언트 측
- `RestClient`, `WebClient`, HTTP 인터페이스 클라이언트에서 요청에 API 버전 설정 가능

## 테스트
- `WebTestClient`, MockMvc에서 버전 지정 테스트 지원

## 지원 범위
- Spring MVC (서블릿 기반)
- Spring WebFlux (리액티브)

## 참고
- [API Versioning in Spring 블로그](https://spring.io/blog/2025/09/16/api-versioning-in-spring)

## 관련 페이지

- [[entity-spring-framework]]
- [[src-spring-framework-7]]
