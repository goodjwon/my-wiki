---
title: Keep-Alive 타임아웃 race condition (LB ↔ 서버 502)
type: concept
tags: [networking, load-balancer, keep-alive, race-condition, troubleshooting, aws]
sources:
  - 2bun-coding/502-keepalive-timeout-race.md
external:
  - https://www.youtube.com/watch?v=a-KFzdW_Ybw
created: 2026-06-06
updated: 2026-06-06
---

# Keep-Alive 타임아웃 race condition (LB ↔ 서버 502)

## 정의

로드 밸런서(LB)와 백엔드 서버가 TCP 커넥션을 **Keep-Alive**로 재사용할 때, 두 쪽의 idle 타임아웃이 다르면 **서버가 먼저 커넥션을 끊는 순간 LB가 그 커넥션으로 요청을 보내는 경쟁 상태(race condition)** 가 발생해 502 Bad Gateway가 간헐적으로 발생하는 현상.

[[concept-db-connection-pool|DB 커넥션 풀의 maxLifetime < wait_timeout]] 규칙과 **정확히 같은 구조** — 다만 LB↔서버 레이어에서.

## 현상

| 증상 | 패턴 |
|------|------|
| 502 Bad Gateway | 간헐적, 재현 어려움 |
| 발생 시각 | 트래픽 적은 **새벽 시간대** |
| 서버 메트릭 | CPU·메모리·디스크 모두 여유 |
| 서버 애플리케이션 로그 | **에러 없음** (서버 입장에선 정상 종료) |
| LB 로그 | 502 카운트 증가 |
| 낮 시간 | **발생 안 함** (요청이 끊이지 않아 커넥션 계속 재사용) |

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

낮 시간에는 매 초마다 요청이 들어와 idle 타임아웃에 도달하지 않으므로 발생 안 함.

## 흔한 기본값 비교

| 컴포넌트 | 기본 idle timeout |
|---------|------------------|
| **AWS ALB** (Application LB, L7) | **60초** |
| **AWS NLB** (Network LB, L4) | **350초** |
| AWS CLB (Classic) | 60초 |
| nginx (upstream keepalive_timeout) | 60초 |
| **Gunicorn** | **2초** ⚠️ |
| **Node.js (http.Server)** | **5초** ⚠️ |
| Tomcat | 20초 |
| Spring Boot Embedded Tomcat | 20초 |

→ 대부분의 웹 서버가 **LB보다 짧다**. 기본값 그대로 두면 거의 항상 race condition 발생 가능.

## 해결 — 절대 규칙

> **서버 Keep-Alive 타임아웃 > LB idle 타임아웃**

LB가 **항상 먼저** 커넥션을 끊게 만들면, 서버가 종료한 커넥션으로 LB가 요청 보내는 상황 자체가 발생 안 함. AWS 공식 권장 사항.

권장 마진: 서버 = LB + **5~10초 여유**.

### 설정 예시

**Gunicorn**:
```bash
gunicorn --keep-alive 75 app:app    # ALB(60s) + 15s 여유
```

**Node.js (Express/Fastify)**:
```javascript
const server = app.listen(3000);
server.keepAliveTimeout = 75_000;   // 75초
server.headersTimeout = 80_000;     // keepAliveTimeout보다 길게
```

**nginx (백엔드 역할)**:
```nginx
keepalive_timeout 75s;
```

**Spring Boot (Embedded Tomcat)**:
```yaml
server:
  tomcat:
    connection-timeout: 75s
    keep-alive-timeout: 75s
    max-keep-alive-requests: 100
```

## 함정 — LB 종류 변경 시 재발

ALB(60s) → **NLB(350s)** 로 마이그레이션할 때 서버 타임아웃을 ALB 기준(75초)으로만 맞춰뒀다면:

```
변경 후: NLB(350s) > 서버(75s) → 다시 서버가 먼저 끊음 → 502 재발
```

→ LB 종류·설정 바뀔 때마다 **서버 타임아웃도 재검토**. 운영 체크리스트에 포함.

## 같은 패턴의 race condition들

이 "긴 타임아웃 ↔ 짧은 타임아웃" 불일치는 인프라 전반에서 반복:

| 레이어 | 긴 쪽 | 짧은 쪽 | 규칙 |
|-------|------|--------|------|
| **LB ↔ 웹 서버** | LB idle | 서버 keep-alive | 서버 > LB |
| **풀 ↔ DB** ([[concept-db-connection-pool]]) | DB `wait_timeout` | HikariCP `maxLifetime` | 풀 < DB |
| **클라이언트 ↔ API Gateway** | 클라이언트 타임아웃 | Gateway 응답 타임아웃 | 클라이언트 > Gateway |
| **앱 ↔ 캐시(Redis)** | Redis idle | 클라이언트 connect timeout | 클라이언트 < Redis |

→ 공통 원리: **"먼저 끊는 쪽"이 명확히 한쪽으로 정해져야 race 없음**.

## 진단 체크리스트

새벽 502가 의심되면:

1. **시간대 패턴 확인**: 502 발생 시각 분포가 트래픽 저점과 일치하는가?
2. **서버 로그 확인**: 애플리케이션 에러 없는데 LB만 502? → 인프라 의심
3. **LB idle timeout 확인**: ALB 콘솔 또는 `aws elbv2 describe-load-balancer-attributes`
4. **서버 keep-alive 확인**: 사용 중인 웹서버 기본값 (대부분 LB보다 짧음)
5. **불일치 보정**: 서버 타임아웃을 LB + 15초로 설정
6. **롤링 배포 후 메트릭 모니터링**: 다음 새벽 502 카운트 0인지

## 원본 출처

- raw: `raw/2bun-coding/502-keepalive-timeout-race.md`
- 외부: [2분코딩 — 새벽마다 502가 뜨는데 서버는 멀쩡해요](https://www.youtube.com/watch?v=a-KFzdW_Ybw)
- AWS 공식: [ALB target group attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-attributes.html)

## 관련 페이지

- [[concept-db-connection-pool]] — 같은 "두 타이머 불일치 → race" 패턴
- [[src-java-study-2024-2025]] — Ch10 입출력과 네트워크 (Keep-Alive 기초)
- [[src-spring-data-access-ref]] — Spring Boot Tomcat 타임아웃 설정 맥락
- [[concept-harness-engineering]] — 인프라 설정 불일치도 결국 "환경 설계" 문제
