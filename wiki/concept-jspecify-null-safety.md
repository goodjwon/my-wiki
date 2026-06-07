---
title: JSpecify Null Safety
type: concept
tags: [Spring, Java, Kotlin, null-safety, JSpecify, npe]
sources: [spring/Spring Framework Versions.md]
external:
  - https://jspecify.dev/
  - https://jspecify.dev/docs/user-guide/
  - https://spring.io/blog/2025/11/12/null-safe-applications-with-spring-boot-4
created: 2026-04-18
updated: 2026-06-07
---

# JSpecify Null Safety

Java의 **null 안전성 표준** — `null` 가능 여부를 어노테이션으로 명시하여 컴파일러·정적 분석 도구·Kotlin이 NPE를 사전에 잡게 한다. Spring Framework 7.0이 기존 JSR 305를 버리고 JSpecify로 전면 마이그레이션.

- **공식**: https://jspecify.dev/
- **GitHub**: https://github.com/jspecify/jspecify
- **참여**: Google, Spring, Square, JetBrains, Oracle, VMware 등

## 왜 또 하나의 null 표준?

Java는 모든 참조 타입이 `null` 가능 — `String` 변수가 `null`일 수 있는지 시그니처만 봐서는 모름. 그래서 여러 라이브러리가 어노테이션으로 의도를 표현:

| 어노테이션 | 출처 | 문제 |
|----------|------|------|
| `@Nullable` / `@NonNull` | **JSR 305** (Findbugs) | 명세 비공식·불완전, split-package |
| `@Nullable` / `@NotNull` | IntelliJ | IDE 종속 |
| `@Nullable` / `@NonNull` | Eclipse | 다른 의미 |
| `@Nonnull` / `@CheckForNull` | Findbugs | 거의 dead |
| `@Nullable` / `@NonNull` | Android Support | Android 한정 |

→ **같은 이름인데 의미가 미묘하게 다르고**, 제네릭·배열 요소 표현 불가, Kotlin 통합 한계.

JSpecify는 이 혼란을 끝내려는 업계 표준.

## JSpecify vs JSR 305

| 항목 | JSR 305 | JSpecify |
|------|---------|----------|
| 명세 상태 | 비공식·중단 (since 2012) | **공식 사양 (2024 → 1.0)** |
| 패키지 충돌 | split-package (`javax.annotation`) | **단일 깔끔 의존성** |
| 제네릭 타입 인자 | ❌ 미지원 | ✅ 지원 |
| 배열/varargs 요소 | ❌ 미지원 | ✅ 지원 |
| Kotlin 통합 | 제한적 | **개선** |
| 도구 지원 | 제한적 | 광범위 |
| 라이선스 | 불명확 | Apache 2.0 |
| 유지보수 | 사실상 중단 | 활발 |

## 핵심 어노테이션

```java
import org.jspecify.annotations.*;

public class UserService {
    // 1) 메서드 파라미터 nullable
    public User findByEmail(@Nullable String email) {
        if (email == null) throw new IllegalArgumentException();
        return repo.findByEmail(email);
    }

    // 2) 반환값 nullable
    public @Nullable User findById(Long id) {
        return repo.findById(id).orElse(null);
    }

    // 3) 제네릭 타입 인자 — JSR 305로 표현 불가했던 것
    public List<@Nullable String> getOptionalNames() {
        return List.of("Alice", null, "Bob");
    }

    // 4) 배열 요소
    public @Nullable String[] tagList() { ... }
}
```

## `@NullMarked` — 한 번에 적용

매번 `@NonNull` 적기 번거롭다면 패키지·클래스 단위로 "기본 NonNull" 선언:

```java
// package-info.java
@NullMarked
package com.example.service;
```

→ 이 패키지의 모든 타입은 **기본 non-null**, `@Nullable`만 명시.

```java
@NullMarked
public class UserService {
    public User findById(Long id) { ... }                 // non-null (기본)
    public @Nullable User findByEmail(String email) { }   // nullable (명시)
    public List<String> names() { ... }                   // List<String> 모두 non-null
    public List<@Nullable String> mixed() { ... }         // null 요소 가능
}
```

대부분 코드를 `@NullMarked`로 두고 예외만 `@Nullable` 명시하는 게 실무 패턴.

## Spring 7.0의 적용

### 코드베이스 전체 마이그레이션

Spring Framework 7.0 소스가 JSpecify로 전환됨:
- 모든 패키지에 `@NullMarked` 적용
- `@Nullable`만 예외 표시
- JSR 305 의존성 제거

→ **Spring 라이브러리를 호출하는 우리 코드도 JSpecify 인식**. IDE가 `null` 반환 가능성을 즉시 표시.

### Kotlin 통합 개선

```kotlin
// Spring의 @Nullable 메서드 호출
val user: User? = userService.findById(1L)  // Kotlin이 User?로 인식 (nullable)
user?.let { ... }                            // 안전 호출
```

JSR 305에서는 Kotlin이 일부 어노테이션을 무시하거나 platform type으로 처리 → NPE 가능. JSpecify로 가면 정확히 인식.

## 마이그레이션 주의사항 (Spring 6 → 7)

| 변경 | 영향 |
|------|------|
| `MethodParameter#isOptional` 동작 변화 | reflection 사용 시 미세 동작 차이 |
| JSR 305 전용 지원 제거 | `@Nullable` (javax) → JSpecify로 교체 필요 |
| Kotlin API nullability 변경 | 일부 메서드의 `T?` ↔ `T` 변화 |

### 권장 마이그레이션 단계

1. **의존성 추가** — `org.jspecify:jspecify:1.0.0`
2. **패키지에 `@NullMarked` 적용** — 한 번에 패키지 단위
3. **`@Nullable` import 일괄 교체** — `javax.annotation.Nullable` → `org.jspecify.annotations.Nullable`
4. **NullAway / ErrorProne으로 점검** — CI에 통합
5. **Kotlin 코드 점검** — IDE가 새 nullability를 반영하는지

## 정적 분석 도구 통합

| 도구 | 통합 |
|------|------|
| **NullAway** (Uber) | Gradle/Maven 플러그인. CI에서 NPE 가능성 차단 |
| **ErrorProne** (Google) | bug 패턴 검사 |
| **Checker Framework** | 가장 엄격한 type checker |
| **IntelliJ IDEA** | 인라인 경고 |
| **Eclipse JDT** | null 분석기 |

### Gradle 설정 예

```groovy
plugins {
    id 'net.ltgt.errorprone' version '4.0.1'
}

dependencies {
    implementation 'org.jspecify:jspecify:1.0.0'
    errorprone 'com.uber.nullaway:nullaway:0.11.0'
    errorprone 'com.google.errorprone:error_prone_core:2.27.0'
}

tasks.withType(JavaCompile) {
    options.errorprone.check 'NullAway', net.ltgt.gradle.errorprone.CheckSeverity.ERROR
    options.errorprone.option 'NullAway:AnnotatedPackages', 'com.example'
}
```

→ NPE 가능성이 있는 코드는 **컴파일 실패** 처리.

## 실무 ROI

NPE는 운영 장애의 단골 원인:
- `NullPointerException` — Java 운영 에러 1위
- "billion-dollar mistake" (Tony Hoare, 1965년 null 도입 회고)
- Kotlin·Rust·Swift 등 현대 언어가 null safety를 타입 시스템에 내장한 이유

JSpecify + NullAway 도입 효과:
- 컴파일 시 NPE 패턴 차단 → 런타임 장애 ↓
- 코드 가독성 ↑ (nullable 여부가 시그니처에 명시)
- Kotlin과의 매끄러운 상호 운용

## 같은 인사이트 패턴

| 영역 | "암묵적 가정이 사고가 된다" |
|------|--------------------------|
| **이 페이지** | `null` 가능 여부를 시그니처에 안 적으면 NPE |
| [[concept-api-backward-compatibility]] | "응답 미지 필드 무시"가 명세에 없으면 사고 |
| [[concept-transactional-rollback-policy]] | "체크 예외에서도 롤백"이 명시 안 되면 commit |
| [[concept-keepalive-timeout-race]] | "서버 timeout > LB"가 명시 안 되면 502 |

→ **시그니처·계약·설정에 의도를 명시하는 것이 안전한 시스템의 기본.**

## 학습 자료

- [JSpecify 공식 user guide](https://jspecify.dev/docs/user-guide/)
- [Spring Blog — Null-safe applications with Spring Boot 4](https://spring.io/blog/2025/11/12/null-safe-applications-with-spring-boot-4)
- [NullAway 가이드](https://github.com/uber/NullAway)

## 원본 출처

- raw: `raw/spring/Spring Framework Versions.md`
- 공식: [JSpecify](https://jspecify.dev/)
- 공식 가이드: [JSpecify User Guide](https://jspecify.dev/docs/user-guide/)
- Spring 블로그: [Null-safe applications with Spring Boot 4](https://spring.io/blog/2025/11/12/null-safe-applications-with-spring-boot-4)

## 관련 페이지

- [[entity-spring-framework]] — Spring Framework 7.0 전체 변화
- [[src-spring-framework-7]] — 7.0 릴리스 노트 소스
- [[concept-api-versioning]] — Spring 7.0 또 다른 신규 기능
- [[concept-spring-core]] — Spring 핵심 개념
- [[concept-api-backward-compatibility]] — 같은 "명시적 계약" 패턴
