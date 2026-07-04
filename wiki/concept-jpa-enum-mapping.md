---
title: "JPA Enum 매핑 — @Enumerated(STRING)과 ordinal 함정"
type: concept
tags: [java, jpa, hibernate, enum, effective-java, database]
sources: [effective_java/이펙티브 자바 실전 강의 교재 6 장.md]
created: 2026-07-04
updated: 2026-07-04
---

# JPA Enum 매핑 — `@Enumerated(STRING)`과 ordinal 함정

## 정의

열거 타입(enum)은 정해진 상수 집합만 값으로 허용하는 자바 타입입니다. *Effective Java* Item 34는 `int`/`String` 상수 대신 enum을 쓰라고 권고하고, Item 35는 enum의 선언 순서 번호인 `ordinal()`에 의미를 부여하지 말라고 권고합니다. 이 두 권고가 실무에서 가장 크게 터지는 지점이 JPA입니다. 엔티티의 enum 필드를 DB 컬럼에 매핑하는 방식을 지정하는 애너테이션 `@Enumerated`의 기본값이 **선언 순서 숫자를 저장하는 `ORDINAL`** 이라서, enum 순서를 바꾸는 순간 기존 데이터의 의미가 통째로 어긋납니다. 이 페이지는 Item 34·35의 핵심과 JPA 기본값 함정, 그리고 `EnumType.STRING` 전환 시 주의점을 정리합니다.

> **비유 — 줄 선 순번으로 월급을 매기는 회사**
>
> 어느 회사가 직원 명부에 이름 대신 아침 조회 때 줄 선 순번만 적어 둡니다. 처음에는 아무 문제가 없습니다. 그런데 어느 날 신입이 줄 중간에 끼어들자, 명부의 3번이 가리키는 사람이 어제와 오늘이 달라집니다. 명부는 한 글자도 바뀌지 않았는데 의미가 바뀐 것입니다.
>
> `ORDINAL` 저장이 정확히 이 구조입니다. DB에는 숫자만 남고, 그 숫자가 누구를 가리키는지는 자바 코드의 선언 순서가 결정합니다. 코드에서 상수 순서를 바꾸거나 중간에 삽입하면, DB의 숫자는 그대로인데 가리키는 상수가 달라집니다.

## Item 34 — int 상수 대신 열거 타입을 사용하라

관련 상수 묶음을 `int`/`String`으로 관리하는 방식(int enum 패턴)과 enum의 차이를 먼저 표로 비교합니다.

| 항목 | int 상수 패턴 | enum |
|------|--------------|------|
| 타입 안전성 | 없음 — 사과 자리에 오렌지 값이 통과 | 컴파일 시점 차단 |
| 잘못된 값(99 등) | 그대로 통과 | 존재하지 않는 상수 — 컴파일 에러 |
| 출력 가독성 | 의미 없는 숫자 | 상수 이름 (`toString` 기본 제공) |
| 동작 캡슐화 | 불가 | 필드·메서드·상수별 구현 가능 |
| 순회 | 수동 관리 | `values()` 제공 |

문제가 되는 int 상수 패턴과 enum 해법을 코드로 비교하면 다음과 같습니다.

```java
// ❌ int enum 패턴: 값이 같아 구분도 안 되고, 컴파일러가 오용을 못 막음
public static final int APPLE_FUJI   = 0;
public static final int ORANGE_NAVEL = 0;

// ✅ enum: 타입이 다르면 컴파일 에러
public enum Apple  { FUJI, PIPPIN, GRANNY_SMITH }
public enum Orange { NAVEL, TEMPLE, BLOOD }
```

enum의 진짜 힘은 **데이터와 동작을 상수에 캡슐화**하는 데 있습니다. 계약 상태 enum에 상태 전이 규칙까지 담은 현업형 예제입니다.

```java
public enum ContractStatus {
    DRAFT, ACTIVE, SUSPENDED, CLOSED;

    private static final Map<ContractStatus, Set<ContractStatus>> ALLOWED = Map.of(
        DRAFT,     Set.of(ACTIVE),
        ACTIVE,    Set.of(SUSPENDED, CLOSED),
        SUSPENDED, Set.of(ACTIVE, CLOSED),
        CLOSED,    Set.of()
    );

    public boolean canTransitionTo(ContractStatus next) {
        return ALLOWED.getOrDefault(this, Set.of()).contains(next);
    }
}
```

"DRAFT → CLOSED" 같은 금지 전이를 도메인이 스스로 막습니다. 이 enum을 JPA 엔티티에 저장하는 순간 아래 함정이 시작됩니다.

## Item 35 — ordinal 메서드 대신 인스턴스 필드를 사용하라

`ordinal()`은 enum 상수가 선언된 순서를 0부터 반환하는 메서드입니다. Bloch는 이 메서드가 `EnumSet`·`EnumMap` 같은 범용 자료구조의 내부 구현용이지, 애플리케이션 코드가 쓸 것이 아니라고 못 박습니다. 순서에 의미를 실었다가 깨지는 예와 해법입니다.

```java
// ❌ ordinal 의존: 중간에 상수를 삽입하면 모든 값이 밀림
public enum Ensemble {
    SOLO, DUET, TRIO;
    public int numberOfMusicians() { return ordinal() + 1; }
}

// ✅ 값은 인스턴스 필드에 명시
public enum Ensemble {
    SOLO(1), DUET(2), TRIO(3), QUARTET(4);
    private final int n;
    Ensemble(int n) { this.n = n; }
    public int numberOfMusicians() { return n; }
}
```

"순서에 의미를 싣지 말라"는 이 원칙을 DB 저장으로 확장하면, `ORDINAL` 저장 금지가 곧바로 따라 나옵니다.

## JPA `@Enumerated` 기본값 함정 — ORDINAL은 조용히 데이터를 오염시킨다

Jakarta Persistence 명세에서 `@Enumerated`의 value 기본값은 `EnumType.ORDINAL`입니다. 즉 애너테이션을 생략하거나 `@Enumerated`만 붙이면 **선언 순서 숫자**가 DB에 저장됩니다. 함정이 되는 코드와 안전한 코드를 비교합니다.

```java
// ❌ Before: 기본값 ORDINAL — DB에 0, 1, 2, 3이 저장됨
@Entity
public class Contract {
    @Id @GeneratedValue
    private Long id;

    private ContractStatus status;          // @Enumerated 생략 = ORDINAL
}

// ✅ After: STRING — DB에 "DRAFT", "ACTIVE" 등 이름이 저장됨
@Entity
public class Contract {
    @Id @GeneratedValue
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private ContractStatus status;
}
```

두 방식이 DB에 실제로 남기는 값을 비교하면 차이가 명확합니다.

| enum 상수 | ORDINAL 저장 값 | STRING 저장 값 |
|-----------|----------------|----------------|
| `DRAFT` | `0` | `'DRAFT'` |
| `ACTIVE` | `1` | `'ACTIVE'` |
| `SUSPENDED` | `2` | `'SUSPENDED'` |
| `CLOSED` | `3` | `'CLOSED'` |

### 사고 시나리오 — 중간 삽입 한 줄이 전체 데이터를 재해석한다

`ACTIVE` 앞에 `PENDING`(승인 대기)을 추가하는 흔한 요구사항이 들어왔다고 합시다. 코드는 `DRAFT, PENDING, ACTIVE, SUSPENDED, CLOSED` 한 줄 수정이지만, ORDINAL로 저장된 기존 데이터는 다음처럼 전부 다른 상태로 읽힙니다.

| DB 값 | 변경 전 의미 | 변경 후 읽히는 의미 | 결과 |
|-------|-------------|--------------------|------|
| `0` | DRAFT | DRAFT | 무사 |
| `1` | ACTIVE | **PENDING** | 활성 계약이 승인 대기로 둔갑 |
| `2` | SUSPENDED | **ACTIVE** | 정지 계약이 활성으로 둔갑 |
| `3` | CLOSED | **SUSPENDED** | 종료 계약이 정지로 둔갑 |

가장 위험한 점은 **예외가 전혀 나지 않는다**는 것입니다. 숫자 1은 여전히 유효한 ordinal이므로 JPA는 아무 경고 없이 다른 상수로 역직렬화하고, 사고는 정산·통계가 어긋난 뒤에야 발견됩니다. STRING이었다면 이름으로 매칭하므로 순서 변경·중간 삽입에 전혀 영향받지 않습니다.

### STRING의 대가 — 이름 변경은 마이그레이션이 필요하다

STRING도 공짜는 아닙니다. 저장 값이 `name()`(상수 이름 그대로)이므로, 상수 이름을 바꾸면 기존 데이터가 매칭에 실패해 이번에는 **시끄럽게** 깨집니다(`IllegalArgumentException`). 그래서 이름 변경은 반드시 DB 마이그레이션과 한 세트로 배포해야 합니다.

```sql
-- 상수 SUSPENDED → ON_HOLD 로 개명하는 배포와 함께 실행
UPDATE contract SET status = 'ON_HOLD' WHERE status = 'SUSPENDED';
```

조용히 오염되는 ORDINAL보다, 즉시 예외로 드러나는 STRING 쪽이 실패 모드로서 압도적으로 안전합니다. 두 방식의 트레이드오프를 정리합니다.

| 항목 | ORDINAL | STRING |
|------|---------|--------|
| 저장 공간 | 작음 (Hibernate 6 기준 `TINYINT`) | 큼 (`VARCHAR`, MySQL은 `ENUM` 컬럼) |
| 순서 변경·중간 삽입 | **조용한 데이터 오염** | 영향 없음 |
| 상수 이름 변경 | 영향 없음 | 예외 발생 — UPDATE 마이그레이션 필요 |
| DB 값 가독성 | 숫자만 보임 | 사람이 바로 읽음 |
| 실무 권장 | 사용 금지 | **기본 선택** + `@Column(length)` 명시 |

Hibernate 6 공식 문서 기준으로 `@Enumerated(STRING)`은 대부분의 DB에서 `VARCHAR` + `CHECK` 제약으로, MySQL에서는 네이티브 `ENUM` 컬럼 타입으로 매핑됩니다. PostgreSQL의 네이티브 enum 타입을 쓰려면 `@JdbcTypeCode(SqlTypes.NAMED_ENUM)`을 별도 지정하는 선택지도 있습니다(Hibernate 6.2+).

## 같은 인사이트 패턴 — "기본값과 가정의 함정"

이 함정은 위키에 누적 중인 "기본값과 가정의 함정" 패턴의 신규 사례입니다. 프레임워크·인프라가 깔아 둔 기본값을 검토 없이 받아들이면 조용한 사고로 돌아온다는 공통 구조를 가집니다.

| 페이지 | 위험 |
|--------|------|
| **이 페이지** | JPA `@Enumerated` 기본 `ORDINAL` — enum 선언 순서가 곧 데이터 |
| [[concept-api-backward-compatibility]] | 클라이언트 JSON 라이브러리 기본값 차이 |
| [[concept-transactional-rollback-policy]] | `@Transactional` 체크 예외 commit |
| [[concept-cronjob-concurrency-trap]] | K8s `concurrencyPolicy: Allow` |
| [[concept-keepalive-timeout-race]] | 웹 서버 keep-alive 짧음 |
| [[concept-db-connection-pool]] | 무한 수명 커넥션 |
| [[concept-varchar-length-prefix]] | 관습적 `VARCHAR(255)` |

→ 공통 교훈: **기본값은 "무난한 값"이 아니라 "역사적 이유가 있는 값"입니다.** `ORDINAL`이 기본인 것도 초기 JPA가 공간 효율을 우선한 결과일 뿐, 오늘의 안전한 선택이라는 뜻이 아닙니다.

## 빠른 진단 — 지금 내 코드 점검

아래 항목으로 프로젝트를 바로 점검할 수 있습니다.

- [ ] 엔티티의 모든 enum 필드에 `@Enumerated(EnumType.STRING)`이 붙어 있는가 (생략 = ORDINAL)
- [ ] `git grep -l "@Enumerated" | xargs grep -L "STRING"` 으로 ORDINAL 사용처를 검출했는가
- [ ] enum 컬럼에 `@Column(length = ...)`으로 최대 이름 길이를 명시했는가 ([[concept-varchar-length-prefix]] 참고)
- [ ] enum 상수 이름 변경 시 `UPDATE` 마이그레이션을 같은 배포에 포함했는가
- [ ] `ordinal()`을 애플리케이션 로직·저장·정렬 기준에 쓰고 있지 않은가 (Item 35)
- [ ] 도메인 상수를 `int`/`String`으로 관리하는 곳이 남아 있지 않은가 (Item 34)

## 원본 출처

- 강의 교재: `raw/effective_java/이펙티브 자바 실전 강의 교재 6 장.md` (Item 34·35) — 위키 정리본 [[lecture-effective-java-ch6]]
- 명세: [Jakarta Persistence 3.1 — @Enumerated javadoc](https://jakarta.ee/specifications/persistence/3.1/apidocs/jakarta.persistence/jakarta/persistence/enumerated) — "Default: jakarta.persistence.EnumType.ORDINAL" 확인
- 공식 문서: [Hibernate 6 Introduction — Mapping enums](https://docs.hibernate.org/orm/6.6/introduction/html_single/Hibernate_Introduction.html) — ORDINAL=`TINYINT`+CHECK, STRING=`VARCHAR`+CHECK(MySQL은 `ENUM`), `SqlTypes.NAMED_ENUM` 확인
- 서적: *Effective Java* 3판, Joshua Bloch — Item 34·35

## 관련 페이지

- [[entity-effective-java]] — 책 전체 개요 (이 페이지는 "위키 기존 페이지와의 매핑" 표의 신규 후보였던 항목)
- [[lecture-effective-java-ch6]] — 6장 강의 교재 정리 (Item 34~41 전체)
- [[concept-transactional-rollback-policy]] — 같은 "Spring/JPA 기본값 함정" 계열
- [[concept-varchar-length-prefix]] — enum STRING 컬럼 길이 설계와 직결되는 DB 스키마 함정
- [[concept-api-backward-compatibility]] — "기본값과 가정의 함정" 패턴 원조 비교표 보유 페이지
