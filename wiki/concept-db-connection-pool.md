---
title: DB 커넥션 풀 (Connection Pool)
type: concept
tags: [database, jdbc, hikaricp, performance, spring-data]
sources:
  - 2bun-coding/getconnection-pool.md
external:
  - https://www.youtube.com/shorts/El5lOXM1r5E
  - https://github.com/brettwooldridge/HikariCP
created: 2026-06-06
updated: 2026-06-06
---

# DB 커넥션 풀 (Connection Pool)

## 정의

데이터베이스 연결(TCP + 인증)을 매 요청마다 새로 만들지 않고, **미리 만들어둔 연결을 풀에 두고 빌려·돌려쓰는** 구조. JDBC에서 `DataSource.getConnection()`이 빠른 핵심 이유.

## 왜 필요한가

- DB 커넥션 1개를 새로 만들 때 → **TCP 3-way handshake + (TLS 핸드셰이크) + DB 인증** 비용 발생 (수 ms ~ 수십 ms).
- 풀 없이 매번 생성 시: 초당 1,000건 요청 → **매초 누적 9초 분량의 네트워크 대기** (영상 예시).
- 풀 사용 시: 첫 초기화 한 번만 지불, 이후 `getConnection()`은 **O(1) 대여**.

## 3단계 흐름: 빌리고 → 쓰고 → 돌려주기

```
앱 → pool.getConnection()  // 빌림 (idle 큐에서 즉시 반환)
앱 → conn.executeQuery()   // 사용
앱 → conn.close()          // 진짜 close가 아니라 풀로 "반납"
```

**핵심 오해**: `Connection.close()`는 실제 TCP 종료가 아니다. HikariCP 같은 풀은 `Connection`을 **프록시**로 감싸서, `close()` 호출 시 `pool.returnObject()`로 라우팅한다. 그래서 다음 요청이 3-way handshake 없이 즉시 재사용 가능.

## HikariCP의 3가지 타이머

풀 안의 커넥션을 무한정 유지하면 **DB가 먼저 끊어버린 좀비 커넥션**을 풀이 살아있다고 오판해 빌려주는 장애가 발생한다. 이를 막는 3개 설정:

| 설정 | 역할 | 권장 |
|------|------|------|
| **`maxLifetime`** | 한 커넥션의 최대 수명. 초과 시 풀이 미리 폐기·재생성 | DB `wait_timeout`보다 **반드시 짧게** (예: DB 8시간이면 풀 30분) |
| **`idleTimeout`** | idle 상태 커넥션이 풀에서 제거되는 시간 | `maxLifetime`보다 작게 |
| **`keepaliveTime`** | idle 커넥션에 주기적으로 ping을 보내 살아있는지 확인 | 0(끔) 또는 maxLifetime의 1/3~1/2 |

**가장 중요한 규칙**: `hikari.maxLifetime < db.wait_timeout`

이 규칙을 어기면 → DB가 이미 끊은 연결을 풀이 "정상"이라 판단 → 애플리케이션에 빌려줌 → `SQLException: Connection is closed` 같은 산발적 장애.

## 커넥션 누수(Leak) 감지

타이머로도 못 막는 누수 케이스 — **앱 코드가 `close()`를 까먹은 경우** — 를 잡기 위한 설정:

```properties
spring.datasource.hikari.leak-detection-threshold=10000  # 10초
```

- 커넥션을 빌려간 뒤 N ms가 지나도 반환되지 않으면 **경고 로그 + 스택 트레이스**가 찍힘
- 어느 코드 경로에서 누수가 시작됐는지 추적 가능
- 운영 환경에서는 약간의 오버헤드가 있으므로 개발·스테이징에서 켜고 패턴 확인 후 운영 임계값 결정

> 출처 인용 (`raw/2bun-coding/getconnection-pool.md`):
> "이 옵션을 설정하면 커넥션을 빌려 간 뒤 일정 시간이 지나도 반환되지 않을 때 경고 로그를 남기며, 어디서 누수가 발생했는지 스택 트레이스까지 찍어줍니다."

## Spring Boot 설정 예시 (HikariCP)

Spring Boot 2.x+는 HikariCP가 **기본 풀**. `application.yml`:

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
      max-lifetime: 1800000              # 30분 (DB wait_timeout보다 짧게)
      idle-timeout: 600000               # 10분
      keepalive-time: 0                  # 사용 안 함
      leak-detection-threshold: 60000    # 60초 (개발·스테이징 권장)
      pool-name: HikariPool-myapp
```

## 풀 크기 vs 타이머 — 우선순위

흔한 오해: "풀 크기를 키우면 성능이 좋아진다."

실제 운영에서 시스템 장애의 더 큰 원인은:

| 원인 | 빈도 | 사이즈로 해결됨? |
|------|------|----------------|
| 좀비 커넥션 (maxLifetime 미설정) | 🔴 매우 잦음 | ❌ 더 많아짐 |
| 커넥션 누수 (close() 누락) | 🟠 잦음 | ❌ 임시 완화일 뿐 |
| 실제 동시성 부족 (풀 크기) | 🟢 가끔 | ✅ 도움 |

→ **타이머·누수 설정이 풀 크기보다 우선**. (영상 핵심 메시지)

## 핵심 요약 (영상 인용)

> 커넥션 풀의 본질은
> ① **TCP 연결을 재사용하여 핸드셰이크 비용을 없애고**,
> ② **타이머로 죽은 커넥션을 걸러내며**,
> ③ **누수를 감시하는 것.**

## 원본 출처

- raw: `raw/2bun-coding/getconnection-pool.md`
- 외부: [2분코딩 — getConnection()이 빠른 이유, 풀 안에서 벌어지는 일](https://www.youtube.com/shorts/El5lOXM1r5E)
- 공식: [HikariCP GitHub](https://github.com/brettwooldridge/HikariCP)

## 관련 페이지

- [[src-spring-data-access-ref]] — Spring Data Access 레퍼런스 (Transaction, JDBC, JPA)
- [[src-java-study-2024-2025]] — Ch06 데이터 접근과 SQL, Ch10 입출력과 네트워크
- [[concept-spring-core]] — Spring DataSource는 IoC 컨테이너가 관리
- [[entity-effective-java]] — *Effective Java* Item 9 (try-finally보다 try-with-resources)의 정석 사례. `try (var conn = dataSource.getConnection())` 패턴이 곧 풀 반납 자동화
- [[src-kakaopay-ddd]] — DDD에서 Repository ↔ DataSource 의존 경계
