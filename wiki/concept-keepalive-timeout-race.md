---
title: Keep-Alive 타임아웃 race condition (LB ↔ 서버 502)
type: concept
tags: [networking, load-balancer, keep-alive, race-condition, troubleshooting, aws]
sources:
  - ai-engineering/2bun-coding/502-keepalive-timeout-race.md
external:
  - https://www.youtube.com/watch?v=a-KFzdW_Ybw
created: 2026-06-06
updated: 2026-09-28
---

# Keep-Alive 타임아웃 race condition (LB ↔ 서버 502)

## 정의

로드 밸런서(LB)와 백엔드 서버가 TCP 커넥션을 **Keep-Alive**로 재사용할 때, 두 쪽의 idle 타임아웃이 다르면 **서버가 먼저 커넥션을 끊는 순간 LB가 그 커넥션으로 요청을 보내는 경쟁 상태(race condition)** 가 생겨 502 Bad Gateway가 간헐적으로 나는 현상입니다.

[[concept-db-connection-pool|DB 커넥션 풀의 maxLifetime < wait_timeout]] 규칙과 **정확히 같은 구조**이며, 레이어만 LB↔서버로 바뀝니다.

## 현상

| 증상 | 패턴 |
|------|------|
| 502 Bad Gateway | 간헐적, 재현 어려움 |
| 발생 시각 | 트래픽 적은 **새벽 시간대** |
| 서버 메트릭 | CPU·메모리·디스크 모두 여유 |
| 서버 애플리케이션 로그 | **에러 없음** (서버 입장에선 정상 종료) |
| LB 로그 | 502 카운트 증가 |
| 낮 시간 | **발생하지 않음** (요청이 끊이지 않아 커넥션을 계속 재사용) |

## 원인 메커니즘

```
시각 0: LB와 서버가 Keep-Alive 커넥션 맺음
       LB idle timeout = 60s
       서버 keep-alive timeout = 2s (Gunicorn 기본)

시각 2s 직전: 서버가 "2초 idle 됐네" → FIN 보내려 함
시각 2s 직전: LB가 "60초 아직 안 됐네, 살아있음" → 새 요청 전송

→ 서버 FIN과 LB 요청이 동시 전송 → race condition
→ LB는 응답 못 받음 → 502 Bad Gateway
```

낮 시간에는 매초 요청이 들어와 idle 타임아웃에 도달하지 않으므로 발생하지 않습니다.

## 흔한 기본값 비교

웹 서버와 LB의 기본 idle 타임아웃을 나란히 놓으면 다음과 같습니다.

| 컴포넌트 | 기본 idle timeout |
|---------|------------------|
| **AWS ALB** (Application LB, L7) | **60초** |
| **AWS NLB** (Network LB, L4) | **350초** |
| AWS CLB (Classic) | 60초 |
| nginx (upstream keepalive_timeout) | 60초 |
| **Gunicorn** | **2초** ⚠️ |
| **Node.js (http.Server)** | **5초** ⚠️ |
| Tomcat (배포판 `server.xml`) | 20초 (`connectionTimeout` 설정값, `keepAliveTimeout`이 이를 따름) |
| Tomcat (코드 기본값) | 60초 |
| **Spring Boot Embedded Tomcat** | **60초** ⚠️ (`server.tomcat.*` 미설정 시 Tomcat 코드 기본값) |

→ 대부분의 웹 서버가 **LB보다 짧거나 같습니다**. Spring Boot 내장 Tomcat은 `server.tomcat.connection-timeout`·`keep-alive-timeout`에 기본값을 두지 않아 Tomcat 코드 기본값 60초가 적용되고, `keepAliveTimeout`은 `connectionTimeout`을 따릅니다. ALB와 똑같은 60초라 먼저 끊는 쪽이 정해지지 않으므로 역시 race가 날 수 있습니다. 기본값 그대로 두면 거의 항상 race condition 위험이 있습니다.

## 해결 — 절대 규칙

> **서버 Keep-Alive 타임아웃 > LB idle 타임아웃**

LB가 **항상 먼저** 커넥션을 끊게 만들면, 서버가 종료한 커넥션으로 LB가 요청을 보내는 상황 자체가 생기지 않습니다. AWS 공식 권장 사항이기도 합니다.

권장 마진은 서버 = LB + **5~15초 여유**입니다.

### 설정 예시

**Gunicorn**
```bash
gunicorn --keep-alive 75 app:app    # ALB(60s) + 15s 여유
```

**Node.js (Express/Fastify)**
```javascript
const server = app.listen(3000);
server.keepAliveTimeout = 75_000;   // 75초
server.headersTimeout = 80_000;     // keepAliveTimeout보다 길게
```

**nginx (백엔드 역할)**
```nginx
keepalive_timeout 75s;
```

**Spring Boot (Embedded Tomcat)**
```yaml
server:
  tomcat:
    connection-timeout: 75s
    keep-alive-timeout: 75s
    max-keep-alive-requests: 100
```

## 함정 — LB 종류 변경 시 재발

ALB(60s)에서 **NLB(350s)** 로 마이그레이션할 때 서버 타임아웃을 ALB 기준(75초)으로만 맞춰 두었다면 다음처럼 됩니다.

```
변경 후: NLB(350s) > 서버(75s) → 다시 서버가 먼저 끊음 → 502 재발
```

→ LB 종류·설정이 바뀔 때마다 **서버 타임아웃도 재검토**해야 합니다. 운영 체크리스트에 넣어 둡니다.

## 같은 패턴의 race condition들

이 "긴 타임아웃 ↔ 짧은 타임아웃" 불일치는 인프라 전반에서 반복됩니다.

| 레이어 | 긴 쪽 | 짧은 쪽 | 규칙 |
|-------|------|--------|------|
| **LB ↔ 웹 서버** | LB idle | 서버 keep-alive | 서버 > LB |
| **풀 ↔ DB** ([[concept-db-connection-pool]]) | DB `wait_timeout`·방화벽 idle | HikariCP `maxLifetime` | 풀 < DB·인프라 |
| **클라이언트 ↔ API Gateway** | 클라이언트 타임아웃 | Gateway 응답 타임아웃 | 클라이언트 > Gateway |
| **앱 ↔ 캐시(Redis)** | Redis idle | 클라이언트 connect timeout | 클라이언트 < Redis |

→ 공통 원리: **"먼저 끊는 쪽"이 명확히 한쪽으로 정해져야 race가 없습니다**.

## 같은 인사이트 패턴 — "기본값과 가정의 함정"

프레임워크·인프라·관습이 깔아 둔 기본값이나 "당연히 그렇겠지"라는 가정을 검토 없이 받아들이면 조용한 사고로 돌아옵니다. 위키에 누적된 같은 구조의 사례를 한 표로 묶습니다.

| 페이지 | 위험한 기본값·가정 | 결과 | 실무 권장 |
|--------|-------------------|------|----------|
| [[concept-transactional-rollback-policy|트랜잭션 롤백]] | `@Transactional`이 모든 예외를 롤백한다는 가정 (기본은 unchecked 예외·`Error`만 롤백) | 체크 예외에서 커밋되어 데이터 오염 | `rollbackFor = Exception.class` 또는 사내 합성 애너테이션 |
| [[concept-api-backward-compatibility|API 하위 호환]] | 클라이언트 JSON 파서가 미지 필드에 관용적일 것이라는 가정 (라이브러리마다 기본값이 다름) | 응답 필드 하나 추가로 앱 전체 오류 | Tolerant Reader + 응답 구조 wrapping 변경 금지 |
| [[concept-api-versioning|API 버전 관리]] | 버전을 나누면 변경 부담이 끝난다는 가정 | 강제 업데이트가 불가한 환경에서 v1 코드 영구 유지 | 버전은 Controller·DTO에만 + deprecation·sunset 합의 |
| [[concept-jpa-enum-mapping|JPA enum 매핑]] | JPA `@Enumerated` 기본 `ORDINAL` | enum 순서 변경·중간 삽입 시 조용한 데이터 오염 | `EnumType.STRING` + `@Column(length)` 명시 |
| [[concept-cronjob-concurrency-trap|크론잡 동시 실행]] | K8s CronJob `concurrencyPolicy` 기본 `Allow` | 배치 중복 실행 → 정산 2배 | `Forbid` + `activeDeadlineSeconds` |
| **Keep-Alive 타임아웃 (이 페이지)** | 웹 서버 keep-alive 기본값이 LB idle 이하 (Gunicorn 2초·Node.js 5초·Tomcat 60초 vs ALB 60초) | 서버가 먼저 끊어 새벽 간헐 502 | 서버 keep-alive > LB idle (+5~15초) |
| [[concept-db-connection-pool|DB 커넥션 풀]] | 풀의 커넥션이 계속 유효하다는 가정 (`maxLifetime`이 DB `wait_timeout`·방화벽/LB idle 제한보다 김) | 이미 끊긴 커넥션 대여 → 산발적 `Connection is closed` | `maxLifetime`을 가장 짧은 인프라 제한보다 몇 초 짧게 + `keepaliveTime` |
| [[concept-varchar-length-prefix|VARCHAR 길이]] | 관습적 `VARCHAR(255)` (Latin1 시대의 1바이트 프리픽스 경계) | utf8mb4에서는 2바이트 프리픽스 → 의도와 다른 저장·인덱스 비용 | 도메인 상한 우선 + utf8mb4의 63 경계 인지 |
| [[concept-java-serialization-risk|자바 직렬화]] | `ObjectInputStream`이 데이터를 그냥 읽어 줄 것이라는 신뢰 | 임의 클래스 코드 실행(RCE) | JSON·Protobuf로 대체, 불가피하면 `ObjectInputFilter` 화이트리스트 |
| [[concept-id-reference-vs-object-reference|애그리거트 참조]] | JPA 객체 참조로 애그리거트 경계 관통 | 트랜잭션 번짐·N+1 | 경계 밖은 ID 참조 |

→ 공통 원리: **기본값은 "무난한 값"이 아니라 그 시대 설계자가 정답이라 믿었던 값입니다.** 기본값과 가정을 명시적 설정·계약으로 바꿔 두어야 시대 가정이 깨져도 사고로 번지지 않습니다.

## 진단 체크리스트

새벽 502가 의심되면 다음 순서로 확인합니다.

1. **시간대 패턴 확인**: 502 발생 시각 분포가 트래픽 저점과 일치하는가?
2. **서버 로그 확인**: 애플리케이션 에러 없이 LB만 502를 기록하는가? 그렇다면 인프라를 의심합니다.
3. **LB idle timeout 확인**: ALB 콘솔 또는 `aws elbv2 describe-load-balancer-attributes`로 확인합니다.
4. **서버 keep-alive 확인**: 사용 중인 웹 서버의 기본값을 봅니다 (대부분 LB보다 짧거나 같음).
5. **불일치 보정**: 서버 타임아웃을 LB + 15초로 설정합니다.
6. **롤링 배포 후 메트릭 모니터링**: 다음 새벽 502 카운트가 0인지 확인합니다.

## 원본 출처

- raw: `raw/ai-engineering/2bun-coding/502-keepalive-timeout-race.md`
- 외부: [2분코딩 — 새벽마다 502가 뜨는데 서버는 멀쩡해요](https://www.youtube.com/watch?v=a-KFzdW_Ybw)
- AWS 공식: [ALB target group attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-attributes.html)
- Tomcat 공식: [HTTP Connector — connectionTimeout·keepAliveTimeout](https://tomcat.apache.org/tomcat-11.0-doc/config/http.html) — 코드 기본값 60초, 배포판 `server.xml`은 20초
- Spring Boot 공식: [Common Application Properties — server.tomcat.*](https://docs.spring.io/spring-boot/appendix/application-properties/index.html) — `connection-timeout`·`keep-alive-timeout` 기본값 없음(Tomcat 기본값 사용)

## 관련 페이지

- [[concept-db-connection-pool]] — 같은 "두 타이머 불일치 → race" 패턴
- [[concept-http-hol-blocking]] — Keep-Alive가 등장한 HTTP/1.1 맥락과 이후 HTTP/2·3의 진화
- [[concept-cronjob-concurrency-trap]] — 같은 "기본값 그대로 두면 사고" 패턴
- [[concept-varchar-length-prefix]] — 같은 "관습적 기본값" 패턴
- [[src-java-study-2024-2025]] — Ch10 입출력과 네트워크 (Keep-Alive 기초)
- [[src-spring-data-access-ref]] — Spring Boot Tomcat 타임아웃 설정 맥락
- [[concept-harness-engineering]] — 인프라 설정 불일치도 결국 "환경 설계" 문제
- [[concept-aggregate-boundary]] — 도메인 설계 영역의 같은 "경계를 명시해야 격리가 생긴다" 패턴
