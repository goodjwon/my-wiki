---
title: DB 커넥션 풀 (Connection Pool)
type: concept
tags: [database, jdbc, hikaricp, performance, spring-data]
sources:
  - ai-engineering/2bun-coding/getconnection-pool.md
external:
  - https://www.youtube.com/shorts/El5lOXM1r5E
  - https://github.com/brettwooldridge/HikariCP
created: 2026-06-06
updated: 2026-09-28
---

# DB 커넥션 풀 (Connection Pool)

## 정의

데이터베이스 연결(TCP + 인증)을 매 요청마다 새로 만들지 않고, **미리 만들어둔 연결을 풀에 두고 빌려·돌려쓰는** 구조입니다. JDBC에서 `DataSource.getConnection()`이 빠른 핵심 이유입니다.

## 왜 필요한가

- DB 커넥션 1개를 새로 만들 때마다 **TCP 3-way handshake + (TLS 핸드셰이크) + DB 인증** 비용(수 ms ~ 수십 ms)이 듭니다.
- 풀 없이 매번 생성하면 초당 1,000건 요청에서 **매초 누적 9초 분량의 네트워크 대기**가 생깁니다 (영상 예시).
- 풀을 쓰면 첫 초기화 비용만 한 번 지불하고, 이후 `getConnection()`은 **O(1) 대여**로 끝납니다.

## 3단계 흐름: 빌리고 → 쓰고 → 돌려주기

```
앱 → pool.getConnection()  // 빌림 (idle 큐에서 즉시 반환)
앱 → conn.executeQuery()   // 사용
앱 → conn.close()          // 진짜 close가 아니라 풀로 "반납"
```

**핵심 오해**: `Connection.close()`는 실제 TCP 종료가 아닙니다. HikariCP 같은 풀은 `Connection`을 **프록시**로 감싸서, `close()` 호출 시 `pool.returnObject()`로 라우팅합니다. 그래서 다음 요청이 3-way handshake 없이 즉시 재사용할 수 있습니다.

## HikariCP의 3가지 타이머

HikariCP는 커넥션을 무한정 들고 있지 않습니다. 기본값으로도 30분이 지나면 커넥션을 폐기·재생성합니다. 진짜 함정은 **풀이 정한 수명보다 DB나 네트워크 장비(방화벽·NAT·LB)가 먼저 커넥션을 끊는 경우**입니다. 이때 풀은 이미 끊긴 좀비 커넥션을 살아 있다고 오판해 빌려줍니다. 이를 막는 3개 설정은 다음과 같습니다(기본값은 HikariCP 공식 README 기준).

| 설정 | 역할 | 기본값 | 권장 |
|------|------|--------|------|
| **`maxLifetime`** | 한 커넥션의 최대 수명. 초과하면 반납 시점에 폐기·재생성 (사용 중인 커넥션은 끊지 않음) | 30분 (최소 30초) | DB `wait_timeout`·인프라 idle 제한 중 **가장 짧은 값보다 몇 초 짧게** |
| **`idleTimeout`** | idle 커넥션이 풀에서 제거되기까지의 시간 (`minimumIdle` < `maximumPoolSize`일 때만 동작) | 10분 (최소 10초) | `maxLifetime`보다 작게 |
| **`keepaliveTime`** | idle 커넥션에 주기적으로 생존 확인을 보내 DB·네트워크 장비의 idle 끊김을 방지 | 2분 (HikariCP 6.2.1부터, 이전 버전은 0 = 끔) | 인프라 idle 제한보다 짧게 (최소 30초, 분 단위 권장) |

Spring Boot 3.5는 HikariCP 6.3, Spring Boot 4.0은 HikariCP 7.0을 관리하므로 최신 Boot에서는 `keepaliveTime` 2분이 기본으로 켜져 있습니다. Spring Boot 3.4 이하(HikariCP 5.x)라면 기본값이 0이라 직접 켜야 합니다.

**가장 중요한 규칙**: `hikari.maxLifetime < min(db.wait_timeout, 방화벽·LB idle timeout)`

이 규칙을 어기면 DB나 중간 장비가 이미 끊은 연결을 풀이 정상이라 판단해 애플리케이션에 빌려주고, `SQLException: Connection is closed` 같은 산발적 장애가 납니다. MySQL `wait_timeout` 기본값(8시간)만 보면 30분 기본값으로 충분해 보이지만, 클라우드 NAT·방화벽의 idle 제한은 수 분 단위인 경우가 많아 그쪽이 먼저 걸립니다. LB↔서버 사이의 같은 구조는 [[concept-keepalive-timeout-race]]에서 다룹니다.

## 커넥션 누수(Leak) 감지

타이머로도 못 막는 누수, 즉 **앱 코드가 `close()`를 빠뜨린 경우**를 잡기 위한 설정입니다.

```properties
spring.datasource.hikari.leak-detection-threshold=10000  # 10초
```

- 커넥션을 빌려간 뒤 N ms가 지나도 반환되지 않으면 **경고 로그 + 스택 트레이스**를 남깁니다.
- 어느 코드 경로에서 누수가 시작됐는지 추적할 수 있습니다.
- 운영 환경에서는 약간의 오버헤드가 있으므로, 개발·스테이징에서 켜고 패턴을 확인한 뒤 운영 임계값을 정합니다.

> 출처 인용 (`raw/ai-engineering/2bun-coding/getconnection-pool.md`):
> "이 옵션을 설정하면 커넥션을 빌려 간 뒤 일정 시간이 지나도 반환되지 않을 때 경고 로그를 남기며, 어디서 누수가 발생했는지 스택 트레이스까지 찍어줍니다."

## Spring Boot 설정 예시 (HikariCP)

Spring Boot 2.x 이후 HikariCP가 **기본 풀**입니다. `application.yml` 예시는 다음과 같습니다.

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: app
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 10              # 풀 최대 크기
      minimum-idle: 5                    # 항상 유지할 최소 idle
      connection-timeout: 30000          # getConnection() 대기 최대 30s
      max-lifetime: 1800000              # 30분 (DB·인프라 idle 제한보다 짧게)
      idle-timeout: 600000               # 10분
      keepalive-time: 120000             # 2분 (HikariCP 6.2.1+ 기본값)
      leak-detection-threshold: 60000    # 60초 (개발·스테이징 권장)
      pool-name: HikariPool-myapp
```

## 풀 크기 vs 타이머 — 우선순위

흔한 오해: "풀 크기를 키우면 성능이 좋아집니다."

실제 운영에서 시스템 장애의 더 큰 원인은 다음과 같습니다.

| 원인 | 빈도 | 사이즈로 해결됨? |
|------|------|----------------|
| 좀비 커넥션 (`maxLifetime`이 인프라 idle 제한보다 김) | 🔴 매우 잦음 | ❌ 더 많아짐 |
| 커넥션 누수 (close() 누락) | 🟠 잦음 | ❌ 임시 완화일 뿐 |
| 실제 동시성 부족 (풀 크기) | 🟢 가끔 | ✅ 도움 |

→ **타이머·누수 설정이 풀 크기보다 우선**입니다. (영상 핵심 메시지)

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
| **DB 커넥션 풀 (이 페이지)** | 풀의 커넥션이 계속 유효하다는 가정 (`maxLifetime`이 DB `wait_timeout`·방화벽/LB idle 제한보다 김) | 이미 끊긴 커넥션 대여 → 산발적 `Connection is closed` | `maxLifetime`을 가장 짧은 인프라 제한보다 몇 초 짧게 + `keepaliveTime` |
| [[concept-varchar-length-prefix|VARCHAR 길이]] | 관습적 `VARCHAR(255)` (Latin1 시대의 1바이트 프리픽스 경계) | utf8mb4에서는 2바이트 프리픽스 → 의도와 다른 저장·인덱스 비용 | 도메인 상한 우선 + utf8mb4의 63 경계 인지 |
| [[concept-java-serialization-risk|자바 직렬화]] | `ObjectInputStream`이 데이터를 그냥 읽어 줄 것이라는 신뢰 | 임의 클래스 코드 실행(RCE) | JSON·Protobuf로 대체, 불가피하면 `ObjectInputFilter` 화이트리스트 |
| [[concept-id-reference-vs-object-reference|애그리거트 참조]] | JPA 객체 참조로 애그리거트 경계 관통 | 트랜잭션 번짐·N+1 | 경계 밖은 ID 참조 |

→ 공통 원리: **기본값은 "무난한 값"이 아니라 그 시대 설계자가 정답이라 믿었던 값입니다.** 기본값과 가정을 명시적 설정·계약으로 바꿔 두어야 시대 가정이 깨져도 사고로 번지지 않습니다.

## 핵심 요약 (영상 인용)

> 커넥션 풀의 본질은
> ① **TCP 연결을 재사용하여 핸드셰이크 비용을 없애고**,
> ② **타이머로 죽은 커넥션을 걸러내며**,
> ③ **누수를 감시하는 것.**

## 원본 출처

- raw: `raw/ai-engineering/2bun-coding/getconnection-pool.md`
- 외부: [2분코딩 — getConnection()이 빠른 이유, 풀 안에서 벌어지는 일](https://www.youtube.com/shorts/El5lOXM1r5E)
- 공식: [HikariCP README — Configuration](https://github.com/brettwooldridge/HikariCP) — `maxLifetime`·`idleTimeout`·`keepaliveTime` 기본값
- 공식: [HikariCP CHANGES](https://github.com/brettwooldridge/HikariCP/blob/dev/CHANGES) — 6.2.1의 `keepaliveTime` 기본값 2분 변경

## 관련 페이지

- [[src-spring-data-access-ref]] — Spring Data Access 레퍼런스 (Transaction, JDBC, JPA)
- [[src-java-study-2024-2025]] — Ch06 데이터 접근과 SQL, Ch10 입출력과 네트워크
- [[concept-spring-core]] — Spring DataSource는 IoC 컨테이너가 관리
- [[entity-effective-java]] — *Effective Java* Item 9 (try-finally보다 try-with-resources)의 정석 사례. `try (var conn = dataSource.getConnection())` 패턴이 곧 풀 반납 자동화
- [[src-kakaopay-ddd]] — DDD에서 Repository ↔ DataSource 의존 경계
- [[concept-keepalive-timeout-race]] — 같은 "두 타이머 불일치 → 끊긴 연결 재사용" 구조의 LB↔서버판
- [[concept-http-hol-blocking]] — 같은 "연결 재사용 비용" 메커니즘의 HTTP 계층판
- [[concept-cronjob-concurrency-trap]] — 같은 "기본값과 가정의 함정"·"단일 방어선의 함정" 패턴
- [[concept-varchar-length-prefix]] — 같은 DB 운영 영역의 관습적 기본값 함정
