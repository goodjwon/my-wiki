---
title: VARCHAR 길이 프리픽스 (InnoDB 255 신화 + utf8mb4 시대의 63)
type: concept
tags: [database, mysql, innodb, varchar, utf8mb4, schema-design, performance]
sources:
  - ai-engineering/2bun-coding/varchar-255-prefix.md
external:
  - https://www.youtube.com/watch?v=EbeSOshOgX4
  - https://dev.mysql.com/doc/refman/8.0/en/storage-requirements.html
created: 2026-06-06
updated: 2026-09-28
---

# VARCHAR 길이 프리픽스 — `VARCHAR(255)`의 진짜 이유

## 정의

MySQL InnoDB는 `VARCHAR` 컬럼 값을 디스크에 저장할 때 **실제 문자열 앞에 그 길이를 나타내는 "길이 프리픽스(length prefix)"를 1바이트 또는 2바이트로 붙입니다.** 이 프리픽스가 1바이트로 끝날 수 있는 경계가 255 (`2⁸ - 1`)였기 때문에 과거에 `VARCHAR(255)`가 "마법의 숫자"로 자리잡았습니다.

> 관습(255)은 Latin1 시대의 최적값입니다. **utf8mb4 시대에는 `VARCHAR(63)`이 정확한 경계입니다.**

## 1바이트 vs 2바이트 프리픽스

InnoDB 규칙을 단순화하면 다음과 같습니다.

| 컬럼의 **최대 바이트 수** | 길이 프리픽스 |
|------------------------|--------------|
| ≤ 255 bytes | **1 byte** |
| > 255 bytes | **2 bytes** |

여기서 핵심 — `VARCHAR(N)`의 **N은 "문자 수"이지 "바이트 수"가 아닙니다**. 한 글자가 몇 바이트를 차지하느냐는 문자셋이 결정합니다.

## 문자셋별 경계값

| 문자셋 | 1글자 최대 바이트 | 1바이트 프리픽스로 가능한 최대 `VARCHAR(N)` |
|--------|------------------|---------------------------------------|
| **Latin1** (ASCII 시대) | 1 byte | `VARCHAR(255)` (255 × 1 = 255) ✅ |
| **utf8** (3 byte) | 3 byte | `VARCHAR(85)` (85 × 3 = 255) ✅ |
| **utf8mb4** (현대 표준) | **4 byte** | **`VARCHAR(63)` (63 × 4 = 252)** ✅ |
| utf8mb4 | 4 byte | `VARCHAR(64)` (64 × 4 = 256) → **2바이트 프리픽스** ❌ |

→ **utf8mb4에서 `VARCHAR(64)`와 `VARCHAR(255)`는 둘 다 2바이트 프리픽스**입니다. 관습대로 잡으면 의도와 다른 결과가 나옵니다.

## 성능 영향 — 1바이트 차이가 왜 중요한가

### ① 저장 공간

```
프리픽스 1 byte → 2 byte = 행당 +1 byte
1억 건 × 1 byte = 100 MB
```

작아 보이지만 **테이블 1개·컬럼 1개 기준**입니다. 한 테이블에 VARCHAR 컬럼이 5개면 500MB가 됩니다.

### ② 인덱스 효율 (더 중요)

B-Tree 인덱스 페이지에도 프리픽스가 포함되어 다음 순서로 영향이 번집니다.

- 페이지당 들어갈 키 개수 감소
- → **페이지 스플릿(page split)** 빈도 증가
- → I/O 증가, 캐시 효율 저하
- → 인덱스 검색·삽입 쿼리 성능 저하

대용량 테이블에서는 저장 공간 낭비보다 **인덱스 효율 저하가 체감상 더 큽니다**.

## DB 제품별 차이

| DBMS | 길이 저장 방식 | 255 경계가 있나? |
|------|-------------|---------------|
| **MySQL InnoDB** | 1 or 2 byte length prefix | ✅ 있음 (이 페이지 주제) |
| **PostgreSQL** | **varlena** (가변길이 헤더) | ❌ 없음. 255든 256이든 저장 비용 동일 |
| **SQL Server** | row offset + length | 경계 다름 |
| **Oracle** | length byte (~2 byte 비트필드) | 다른 규칙 |

→ **PostgreSQL 사용자라면 이 최적화가 무의미합니다**. MySQL/MariaDB만 해당됩니다.

## 실무 의사결정 가이드

`VARCHAR` 크기를 정할 때의 우선순위는 다음과 같습니다.

1. **도메인 요구사항 우선** — 이메일은 RFC 5321상 최대 254자입니다. 이름·주소·URL 등 실제 데이터의 자연스러운 상한을 먼저 봅니다.
2. **문자셋 확인** — utf8mb4가 기본이라면 63 경계를 인식합니다.
3. **도메인 상한 ≤ 63** → `VARCHAR(63)`로 1바이트 프리픽스를 확보합니다.
4. **도메인 상한 > 63** → 실제 필요 크기 그대로 둡니다. 억지로 줄이지 않습니다 (데이터 잘림이 훨씬 큰 손해입니다).
5. **PostgreSQL이면 이 페이지 무시**, 도메인 요구만 따릅니다.

### 흔한 컬럼 예시 (utf8mb4 기준)

| 컬럼 | 합리적 선택 | 이유 |
|------|----------|------|
| `username` | `VARCHAR(50)` | 도메인 상한 작고 < 63 |
| `email` | `VARCHAR(254)` 또는 `VARCHAR(320)` | RFC 5321 따름. 63 경계 의미 없음 |
| `phone` | `VARCHAR(20)` | 국제전화 포함 짧음 |
| `slug` | `VARCHAR(63)` | URL slug, 63 경계 활용 ✅ |
| `title` | `VARCHAR(200)` | 도메인이 우선 |
| `password_hash` (bcrypt) | `CHAR(60)` | 고정 길이, VARCHAR 불필요 |

### "본말전도" 주의

> "데이터를 자르는 위험을 감수하면서까지 무조건 숫자를 맞추는 것은 본말전도."

`VARCHAR(63)`이 모든 답은 아닙니다. 이메일을 63자로 자르면 RFC 위반이고 실제 데이터 손실입니다.

## 빠른 점검: 우리 테이블은 1바이트인가 2바이트인가?

```sql
-- utf8mb4 기준 빠른 진단
SELECT
  TABLE_NAME, COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH AS chars,
  CHARACTER_OCTET_LENGTH AS bytes,
  CASE WHEN CHARACTER_OCTET_LENGTH <= 255 THEN '1-byte prefix ✅'
       ELSE '2-byte prefix ⚠️' END AS prefix
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND DATA_TYPE = 'varchar'
ORDER BY CHARACTER_OCTET_LENGTH DESC;
```

> 2바이트 프리픽스라고 다 줄여야 하는 것은 아닙니다. **자주 사용되는 인덱스 컬럼이면서 도메인상 63 이하로도 충분한 경우**에 우선 검토합니다.

## 같은 인사이트 패턴 — "기본값과 가정의 함정"

프레임워크·인프라·관습이 깔아 둔 기본값이나 "당연히 그렇겠지"라는 가정을 검토 없이 받아들이면 조용한 사고로 돌아옵니다. 위키에 누적된 같은 구조의 사례를 한 표로 묶습니다.

| 페이지 | 위험한 기본값·가정 | 결과 | 실무 권장 |
|--------|-------------------|------|----------|
| [[concept-transactional-rollback-policy|트랜잭션 롤백]] | `@Transactional`이 모든 예외를 롤백한다는 가정 (기본은 unchecked 예외·`Error`만 롤백) | 체크 예외에서 커밋되어 데이터 오염 | `rollbackFor = Exception.class` 또는 사내 합성 애너테이션 |
| [[concept-api-backward-compatibility|API 하위 호환]] | 클라이언트 JSON 파서가 미지 필드에 관용적일 것이라는 가정 (라이브러리마다 기본값이 다름) | 응답 필드 하나 추가로 앱 전체 오류 | Tolerant Reader + 응답 구조 wrapping 변경 금지 |
| [[concept-api-versioning|API 버전 관리]] | 버전을 나누면 변경 부담이 끝난다는 가정 | 강제 업데이트가 불가한 환경에서 v1 코드 영구 유지 | 버전은 Controller·DTO에만 + deprecation·sunset 합의 |
| [[concept-jpa-enum-mapping|JPA enum 매핑]] | JPA `@Enumerated` 기본 `ORDINAL` | enum 순서 변경·중간 삽입 시 조용한 데이터 오염 | `EnumType.STRING` + `@Column(length)` 명시 |
| [[concept-cronjob-concurrency-trap|크론잡 동시 실행]] | K8s CronJob `concurrencyPolicy` 기본 `Allow` | 배치 중복 실행 → 정산 2배 | `Forbid` + `activeDeadlineSeconds` |
| [[concept-keepalive-timeout-race|Keep-Alive 타임아웃]] | 웹 서버 keep-alive 기본값이 LB idle 이하 (Gunicorn 2초·Node.js 5초·Tomcat 60초 vs ALB 60초) | 서버가 먼저 끊어 새벽 간헐 502 | 서버 keep-alive > LB idle (+5~15초) |
| [[concept-db-connection-pool|DB 커넥션 풀]] | 풀의 커넥션이 계속 유효하다는 가정 (`maxLifetime`이 DB `wait_timeout`·방화벽/LB idle 제한보다 김) | 이미 끊긴 커넥션 대여 → 산발적 `Connection is closed` | `maxLifetime`을 가장 짧은 인프라 제한보다 몇 초 짧게 + `keepaliveTime` |
| **VARCHAR 길이 (이 페이지)** | 관습적 `VARCHAR(255)` (Latin1 시대의 1바이트 프리픽스 경계) | utf8mb4에서는 2바이트 프리픽스 → 의도와 다른 저장·인덱스 비용 | 도메인 상한 우선 + utf8mb4의 63 경계 인지 |
| [[concept-java-serialization-risk|자바 직렬화]] | `ObjectInputStream`이 데이터를 그냥 읽어 줄 것이라는 신뢰 | 임의 클래스 코드 실행(RCE) | JSON·Protobuf로 대체, 불가피하면 `ObjectInputFilter` 화이트리스트 |
| [[concept-id-reference-vs-object-reference|애그리거트 참조]] | JPA 객체 참조로 애그리거트 경계 관통 | 트랜잭션 번짐·N+1 | 경계 밖은 ID 참조 |

→ 공통 원리: **기본값은 "무난한 값"이 아니라 그 시대 설계자가 정답이라 믿었던 값입니다.** 기본값과 가정을 명시적 설정·계약으로 바꿔 두어야 시대 가정이 깨져도 사고로 번지지 않습니다.

## 원본 출처

- raw: `raw/ai-engineering/2bun-coding/varchar-255-prefix.md`
- 외부: [2분코딩 — DB 컬럼을 255로 잡는 진짜 이유](https://www.youtube.com/watch?v=EbeSOshOgX4)
- 공식: [MySQL — Data Type Storage Requirements](https://dev.mysql.com/doc/refman/8.0/en/storage-requirements.html)

## 관련 페이지

- [[concept-db-connection-pool]] — DB 운영 일반, 같은 "기본값과 가정의 함정" 패턴
- [[concept-cronjob-concurrency-trap]] — 같은 "관습·단일 방어선의 함정" 패턴
- [[concept-jpa-enum-mapping]] — enum STRING 컬럼 길이 설계와 직결
- [[concept-keepalive-timeout-race]] — 같은 "기본값/관습 그대로 두면 사고" 패턴
- [[src-spring-data-access-ref]] — JPA `@Column(length = ...)` 매핑 시 이 경계 고려
- [[src-java-study-2024-2025]] — Ch06 데이터 접근과 SQL
- [[src-kakaopay-ddd]] — VO 설계 시 도메인 길이 제약과 DB 컬럼 길이 정합
