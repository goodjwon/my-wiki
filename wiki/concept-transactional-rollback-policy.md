---
title: "@Transactional 롤백 정책 — 왜 RuntimeException에만 롤백할까"
type: concept
tags: [spring, transaction, exception, java, checked-exception, rollback]
sources:
  - 2bun-coding/transactional-rollback-exception.md
external:
  - https://www.youtube.com/watch?v=L3IFezsV5VI
  - https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative/rolling-back.html
created: 2026-06-06
updated: 2026-06-06
---

# `@Transactional` 롤백 정책 — 왜 RuntimeException에만 롤백할까

## 정의

Spring의 `@Transactional` 기본 동작은 **`RuntimeException`(언체크 예외)과 `Error`에서만 자동 롤백**한다. `IOException`·`SQLException`같은 **체크 예외에서는 트랜잭션이 그대로 commit**된다. 이는 버그가 아니라 1990년대 Java 예외 철학을 충실히 반영한 설계.

> 어노테이션 한 줄로 우리는 매일 **30년 전 Java 설계자의 결정을 제어**하고 있다.

## 함정 케이스

```java
@Transactional
public void saveAndUpload(Order order) throws IOException {
    orderRepository.save(order);              // DB INSERT 성공
    fileStorage.upload(order.getReceipt());   // ❌ IOException 발생
    // 컨트롤러까지 IOException이 전파됨
}
```

기대: 예외가 났으니 `order`도 롤백되겠지.
실제: **`order`는 그대로 DB에 남아있음.** `IOException`은 체크 예외라 Spring이 commit 진행.

## 자바의 예외 2분류 철학

| 종류 | 의미 (Java 설계자의 의도) | 예시 |
|------|----------------------|------|
| **Checked Exception** | 외부 요인에 의한 실패, **복구 가능·예측 가능** | `IOException`, `SQLException`, `InterruptedException` |
| **Unchecked Exception** (RuntimeException) | **코드가 잘못된 결과 (프로그래밍 에러)** — 진행 불가 | `NullPointerException`, `IllegalStateException`, `IllegalArgumentException` |
| **Error** | JVM·시스템 수준의 치명적 문제 | `OutOfMemoryError`, `StackOverflowError` |

Spring은 이 철학을 그대로 수용:
- 체크 예외 = 복구 가능 → 트랜잭션 **유지 (commit)**
- 언체크 예외/Error = 복구 불가 → **자동 롤백**

근거 — Spring 공식 문서 인용:
> "any unchecked exceptions (`RuntimeException` and `Error`) will trigger a rollback. Checked exceptions will not."

## 실무와의 괴리

현대 실무에서는 이 가정이 거의 안 맞는다:

| 상황 | Java 철학상 | 실무 기대 |
|------|-----------|----------|
| `IOException` (파일 업로드 실패) | 복구 가능 → commit | **롤백 원함** |
| `SQLException` (DB 통신 실패) | 복구 가능 → commit | **롤백 원함** |
| 외부 API `IOException` | 복구 가능 → commit | **롤백 원함** |

→ **99%의 경우 모든 예외에서 롤백이 정답.**

## 해결책 — `rollbackFor`

### 방법 1: 메서드별 명시

```java
@Transactional(rollbackFor = Exception.class)
public void saveAndUpload(Order order) throws IOException {
    orderRepository.save(order);
    fileStorage.upload(order.getReceipt());
}
```

`rollbackFor = Exception.class`는 "체크·언체크 가리지 않고 모든 `Exception`에서 롤백". 실무 표준 패턴.

### 방법 2: 메타 어노테이션 (프로젝트 전역 표준)

매번 적기 번거롭다면 사내 어노테이션을 만들어 표준화:

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Transactional(rollbackFor = Exception.class)
public @interface Tx { }
```

사용:
```java
@Tx
public void saveAndUpload(Order order) throws IOException { ... }
```

### 방법 3: AspectJ로 클래스/패키지 단위 적용

대규모 프로젝트에서는 AOP로 일괄 적용. CLAUDE.md 같은 코딩 헌법에 표준 명시.

### `noRollbackFor` — 반대 옵션

특정 비즈니스 예외는 롤백을 막고 싶을 때:

```java
@Transactional(
    rollbackFor = Exception.class,
    noRollbackFor = { ItemNotFoundException.class }
)
```

예: "재고 부족 알림은 던지지만, 이 알림 자체는 트랜잭션과 무관" 같은 케이스.

## 현대 트렌드 — 체크 예외 회의

| 언어/패러다임 | 체크 예외 입장 |
|-------------|--------------|
| **Java (1995)** | 체크/언체크 분리 도입 |
| **Spring (2003~)** | Java 철학 그대로 수용 |
| **C# (.NET)** | 체크 예외 개념 없음 |
| **Kotlin (2011)** | **체크 예외 폐지** |
| **Scala** | 체크 예외 무력화 |
| **모던 Java 코드** | 체크 예외를 `RuntimeException`으로 wrap 후 throw가 관행 |

→ **Java 자체도 체크 예외에서 멀어지는 중.** Spring 트랜잭션의 디폴트는 시대에 뒤처진 측면이 있다.

## CLAUDE.md STOP 트리거 후보

이 함정을 구조적으로 막으려면 [[concept-claude-md|CLAUDE.md]] 섹션 7에:

```
STOP: @Transactional을 rollbackFor 없이 사용 (체크 예외 그냥 commit 위험)
  → @Transactional(rollbackFor = Exception.class) 또는 사내 @Tx 사용
```

또는 lint-fix.sh / Checkstyle 룰로 강제 가능 (커스텀 규칙).

## 같은 인사이트 패턴 — "프레임워크 기본값은 절대값이 아니다"

| 페이지 | 위험한 기본값 | 실무 권장 |
|--------|------------|----------|
| **이 페이지** | `@Transactional`이 체크 예외 commit | `rollbackFor = Exception.class` |
| [[concept-cronjob-concurrency-trap]] | K8s `concurrencyPolicy: Allow` | `Forbid` + `activeDeadlineSeconds` |
| [[concept-keepalive-timeout-race]] | 웹 서버 keep-alive 짧음 | 서버 > LB |
| [[concept-db-connection-pool]] | 무한 수명 커넥션 | `maxLifetime` < DB `wait_timeout` |
| [[concept-varchar-length-prefix]] | 관습적 `VARCHAR(255)` | utf8mb4에선 `VARCHAR(63)` 또는 도메인 |

→ 공통 원리: **"프레임워크·인프라의 기본값은 그 시대 설계자가 정답이라 믿었던 값일 뿐이다."** 시간이 지나면 시대 가정이 깨진다. 매번 의심하라.

## 빠른 진단 — 우리 프로젝트는 안전한가

```bash
# rollbackFor 없는 @Transactional 찾기
grep -rn "@Transactional" src/main/java/ \
  --include="*.java" \
  | grep -v "rollbackFor" \
  | grep -v "noRollbackFor"
```

결과가 많다면 메타 어노테이션(`@Tx`) 도입 후 일괄 치환 검토.

## 원본 출처

- raw: `raw/2bun-coding/transactional-rollback-exception.md`
- 외부: [2분코딩 — @Transactional은 왜 RuntimeException에만 롤백할까요?](https://www.youtube.com/watch?v=L3IFezsV5VI)
- 공식: [Spring — Rolling back a declarative transaction](https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative/rolling-back.html)

## 관련 페이지

- [[src-spring-data-access-ref]] — Spring `@Transactional` 전체 동작
- [[concept-spring-core]] — Spring AOP·트랜잭션 동작 원리
- [[entity-effective-java]] — *Effective Java* Item 70(복구 가능 → checked, 프로그래밍 오류 → runtime)의 자바 예외 철학이 이 정책의 뿌리. Item 71(검사 예외 남용 회피)도 같은 맥락
- [[src-java-study-2024-2025]] — Ch02 Java 문법(예외), Ch06 데이터 접근
- [[src-kakaopay-ddd]] — Application Layer 트랜잭션 경계 설계
- [[concept-cronjob-concurrency-trap]] / [[concept-keepalive-timeout-race]] — 같은 "기본값 함정" 패턴
- [[concept-claude-md]] — STOP 트리거로 구조적 방어
