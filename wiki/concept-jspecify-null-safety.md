---
title: JSpecify Null Safety
type: concept
tags: [Spring, Java, null-safety, JSpecify]
sources: [Spring Framework Versions.md]
created: 2026-04-18
updated: 2026-04-18
---

# JSpecify Null Safety

Spring Framework 7.0에서 기존 JSR 305 기반 nullness 어노테이션을 대체하여 채택된 null 안전성 표준.

## JSR 305 대비 개선점

| 항목 | JSR 305 | JSpecify |
|------|---------|----------|
| 명세 | 비공식/불완전 | 명확하게 정의됨 |
| 패키지 | split-package 문제 | 깔끔한 단일 의존성 |
| 제네릭 타입 | 미지원 | **지원** |
| 배열/vararg 요소 | 미지원 | **지원** |
| Kotlin 통합 | 제한적 | 개선됨 |
| 도구 지원 | 제한적 | 향상됨 |

## Spring에서의 적용

- Spring Framework 코드베이스 전체가 JSpecify로 마이그레이션됨
- Spring 기반 애플리케이션에도 JSpecify 사용 권장
- Kotlin API의 nullability가 변경될 수 있음 (JSpecify 해석 차이로 인해)

## 마이그레이션 주의사항

- `MethodParameter#isOptional`의 동작이 미세하게 변경됨
- JSR 305 전용 지원 제거로 `@Nullable` 파라미터 체크가 로컬 어노테이션만 확인

## 참고
- [JSpecify 공식 문서](https://jspecify.dev/docs/user-guide/)
- [Null-safe applications with Spring Boot 4 블로그](https://spring.io/blog/2025/11/12/null-safe-applications-with-spring-boot-4)

## 관련 페이지

- [[entity-spring-framework]]
- [[src-spring-framework-7]]
