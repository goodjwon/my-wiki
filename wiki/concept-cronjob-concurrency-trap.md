---
title: 크론잡 중복 실행과 Forbid 함정 (concurrencyPolicy + activeDeadlineSeconds)
type: concept
tags: [kubernetes, cronjob, batch, concurrency, sre, troubleshooting]
sources:
  - ai-engineering/2bun-coding/cronjob-concurrency-trap.md
external:
  - https://www.youtube.com/watch?v=JhBiSdXpvk4
  - https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
created: 2026-06-06
updated: 2026-09-28
---

# 크론잡 중복 실행과 Forbid 함정

## 정의

스케줄된 배치 작업(Cron / Kubernetes CronJob)이 **이전 실행이 끝나기 전에 다음 스케줄이 도래**할 때 발생하는 동시 실행 문제와, 이를 단순히 차단(`Forbid`)했을 때 생기는 **Hang 무한 스킵** 함정입니다. 둘 다 막으려면 **`Forbid` + `activeDeadlineSeconds`** 조합이 필수입니다.

> 핵심 인사이트: 단일 안전장치는 또 다른 사고를 부릅니다. **두 가지 방어선이 함께** 필요합니다.

## 사고 시나리오

```
스케줄: 매시 정각 (0 * * * *)
배치 평균 실행 시간: 40분

09:00 — 1차 배치 시작
09:30 — 1차 진행 중 (월말 데이터 양 많음 → 평소보다 느림)
10:00 — 2차 스케줄 도래
       → 기본값 (Allow): 1차와 2차가 동시 실행
       → 같은 정산 데이터를 두 번 INSERT
       → 정산 금액 2배 사고 💥
```

코드엔 버그가 없습니다. **인프라 기본값이 사고의 원인입니다.**

## 환경별 기본 동작

| 환경 | 동시 실행 기본값 | 위험 |
|------|--------------|------|
| **Linux `cron`** | 이전 완료 여부 확인 없음 | 중복 실행 |
| **Kubernetes CronJob** | `concurrencyPolicy: Allow` | 중복 실행 |
| **Spring `@Scheduled`** | 단일 스레드 풀에서는 자동 직렬화 (다중 인스턴스에서는 위험) | 멀티 인스턴스 환경에서 중복 |
| **systemd timer** | 별다른 락 없음 | 중복 가능 |

## 1차 방어선: 중복 실행 차단

### Linux Cron — `flock`

파일 락으로 동일 작업의 중복 실행을 막습니다.

```bash
# /etc/cron.d/settlement
0 * * * * appuser flock -n /var/lock/settlement.lock /usr/local/bin/settlement.sh
```

- `-n` (`--nonblock`): 락을 못 잡으면 즉시 종료하고 다음 주기에 다시 시도합니다.
- 옵션 `-w 30`: 최대 30초 대기한 뒤 포기합니다.
- 스크립트가 끝나면 락은 자동으로 해제됩니다.

### Kubernetes CronJob — `Forbid`

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: settlement
spec:
  schedule: "0 * * * *"
  concurrencyPolicy: Forbid          # 이전 작업 끝날 때까지 새 작업 스킵
  jobTemplate: ...
```

`concurrencyPolicy`의 3가지 값은 다음과 같습니다.

| 값 | 동작 | 적합 상황 |
|----|------|---------|
| **`Allow`** (기본) | 중복 실행 허용 | 멱등하고 빠른 작업 |
| **`Forbid`** | 이전 실행 중이면 새 실행 스킵 | **정산·집계 등 멱등하지 않은 작업** |
| **`Replace`** | 이전 작업 죽이고 새로 시작 | 항상 "최신 1회"만 의미 있는 작업 |

## 2차 방어선: Hang 방지 (`Forbid`의 함정)

`Forbid`만 걸면 새로운 사고가 납니다.

```
09:00 — 1차 시작
09:35 — DB 데드락으로 Hang. Pod는 살아있지만 진전 없음
10:00 — 2차 스케줄 도래 → Forbid → 스킵
11:00 — 다음도 스킵
...
다음 날 — 운영자가 알아챘을 때 이미 12시간 배치 손실 ⚠️
```

→ **`activeDeadlineSeconds`** 로 한 작업의 최대 수명을 제한합니다.

```yaml
spec:
  schedule: "0 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      activeDeadlineSeconds: 3300    # 55분 (다음 스케줄 5분 전 강제 종료)
      backoffLimit: 0                # 실패 시 재시도 X (다음 주기에 맡김)
      template:
        spec:
          containers: ...
```

`activeDeadlineSeconds`는 다음처럼 동작합니다.

- Job 시작 후 N초가 지나면 Job을 실패 처리하고 실행 중인 Pod를 종료합니다 (Pod에는 **SIGTERM → 유예 시간(기본 30초) → SIGKILL**).
- 다음 스케줄이 정상 실행될 수 있는 상태로 정리됩니다.
- 단점은 정상이지만 오래 걸리는 작업도 죽는다는 점입니다. **평균 + 안전 마진**으로 설정합니다.

## 권장 조합 (Kubernetes 정산 배치 예시)

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: settlement-monthly
spec:
  schedule: "0 1 1 * *"                # 매월 1일 01:00
  concurrencyPolicy: Forbid            # 1차 방어
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 5
  startingDeadlineSeconds: 200         # 200초 이상 늦으면 이번 회 스킵 (좀비 방지)
  jobTemplate:
    spec:
      activeDeadlineSeconds: 14400     # 4시간 (월말 데이터 양 고려)
      backoffLimit: 0
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: settlement
              image: registry.local/settlement:1.2.3
              resources:
                requests: { cpu: "1",   memory: "2Gi" }
                limits:   { cpu: "2",   memory: "4Gi" }
              env:
                - name: BATCH_ID
                  valueFrom:
                    fieldRef: { fieldPath: metadata.name }
```

## 모니터링 — 사고가 났는지 어떻게 아는가

`Forbid`로 스킵된 경우 **알람**이 없으면 12시간 손실 같은 함정에 빠집니다.

- **CronJob 이벤트 감시**: 스킵이 발생하면 `JobAlreadyActive` reason의 이벤트가 남습니다.
- **Prometheus 메트릭**:
  - `kube_cronjob_status_last_successful_time`이 예상보다 오래 멈춰 있는지 봅니다.
  - `kube_job_failed{...}` 증가를 봅니다.
- **Slack/PagerDuty 알람**: 스킵이 N회 연속이면 페이지를 보냅니다.
- **별도 헬스체크 잡**: 매시간 배치가 N분 이내에 성공했는지 확인하고, 실패하면 알람을 보냅니다.

## 같은 패턴 — "단일 방어선의 함정"

이 페이지의 인사이트는 다른 인프라 사고와 같은 구조입니다.

| 영역 | 단일 방어 | 그 함정 | 2차 방어 (조합) |
|------|---------|--------|--------------|
| **크론잡** | `Forbid` (중복 차단) | Hang → 무한 스킵 | `activeDeadlineSeconds` |
| **[[concept-db-connection-pool|DB 풀]]** | 풀 자체 사용 | 인프라가 먼저 끊은 좀비 커넥션 → 장애 | `maxLifetime` + `keepaliveTime` |
| **[[concept-keepalive-timeout-race|LB-서버]]** | Keep-Alive 사용 | 타임아웃 불일치 → 502 | 서버 timeout > LB |
| **[[concept-varchar-length-prefix|VARCHAR(255) 관습]]** | 255로 통일 | utf8mb4 → 2-byte prefix | 도메인 + 63 경계 인지 |

→ **공통 원리**: 어떤 자동화·캐시·차단·관습도 **반드시 부작용을 동반**합니다. 단일 안전장치를 절대시하지 말고 **그 자체의 실패 모드까지 방어**해야 합니다.

## 같은 인사이트 패턴 — "기본값과 가정의 함정"

프레임워크·인프라·관습이 깔아 둔 기본값이나 "당연히 그렇겠지"라는 가정을 검토 없이 받아들이면 조용한 사고로 돌아옵니다. 위키에 누적된 같은 구조의 사례를 한 표로 묶습니다.

| 페이지 | 위험한 기본값·가정 | 결과 | 실무 권장 |
|--------|-------------------|------|----------|
| [[concept-transactional-rollback-policy|트랜잭션 롤백]] | `@Transactional`이 모든 예외를 롤백한다는 가정 (기본은 unchecked 예외·`Error`만 롤백) | 체크 예외에서 커밋되어 데이터 오염 | `rollbackFor = Exception.class` 또는 사내 합성 애너테이션 |
| [[concept-api-backward-compatibility|API 하위 호환]] | 클라이언트 JSON 파서가 미지 필드에 관용적일 것이라는 가정 (라이브러리마다 기본값이 다름) | 응답 필드 하나 추가로 앱 전체 오류 | Tolerant Reader + 응답 구조 wrapping 변경 금지 |
| [[concept-api-versioning|API 버전 관리]] | 버전을 나누면 변경 부담이 끝난다는 가정 | 강제 업데이트가 불가한 환경에서 v1 코드 영구 유지 | 버전은 Controller·DTO에만 + deprecation·sunset 합의 |
| [[concept-jpa-enum-mapping|JPA enum 매핑]] | JPA `@Enumerated` 기본 `ORDINAL` | enum 순서 변경·중간 삽입 시 조용한 데이터 오염 | `EnumType.STRING` + `@Column(length)` 명시 |
| **크론잡 동시 실행 (이 페이지)** | K8s CronJob `concurrencyPolicy` 기본 `Allow` | 배치 중복 실행 → 정산 2배 | `Forbid` + `activeDeadlineSeconds` |
| [[concept-keepalive-timeout-race|Keep-Alive 타임아웃]] | 웹 서버 keep-alive 기본값이 LB idle 이하 (Gunicorn 2초·Node.js 5초·Tomcat 60초 vs ALB 60초) | 서버가 먼저 끊어 새벽 간헐 502 | 서버 keep-alive > LB idle (+5~15초) |
| [[concept-db-connection-pool|DB 커넥션 풀]] | 풀의 커넥션이 계속 유효하다는 가정 (`maxLifetime`이 DB `wait_timeout`·방화벽/LB idle 제한보다 김) | 이미 끊긴 커넥션 대여 → 산발적 `Connection is closed` | `maxLifetime`을 가장 짧은 인프라 제한보다 몇 초 짧게 + `keepaliveTime` |
| [[concept-varchar-length-prefix|VARCHAR 길이]] | 관습적 `VARCHAR(255)` (Latin1 시대의 1바이트 프리픽스 경계) | utf8mb4에서는 2바이트 프리픽스 → 의도와 다른 저장·인덱스 비용 | 도메인 상한 우선 + utf8mb4의 63 경계 인지 |
| [[concept-java-serialization-risk|자바 직렬화]] | `ObjectInputStream`이 데이터를 그냥 읽어 줄 것이라는 신뢰 | 임의 클래스 코드 실행(RCE) | JSON·Protobuf로 대체, 불가피하면 `ObjectInputFilter` 화이트리스트 |
| [[concept-id-reference-vs-object-reference|애그리거트 참조]] | JPA 객체 참조로 애그리거트 경계 관통 | 트랜잭션 번짐·N+1 | 경계 밖은 ID 참조 |

→ 공통 원리: **기본값은 "무난한 값"이 아니라 그 시대 설계자가 정답이라 믿었던 값입니다.** 기본값과 가정을 명시적 설정·계약으로 바꿔 두어야 시대 가정이 깨져도 사고로 번지지 않습니다.

## 진단 체크리스트 — 우리 배치는 안전한가

1. `kubectl get cronjob -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.concurrencyPolicy}{"\t"}{.spec.jobTemplate.spec.activeDeadlineSeconds}{"\n"}{end}'`
2. `concurrencyPolicy`가 **`Allow`**(또는 미지정)인 CronJob을 찾으면, 멱등성을 확인한 뒤 `Forbid`를 검토합니다.
3. `activeDeadlineSeconds`가 없으면 평균 실행 시간을 측정해 **2~3배 + 안전 마진**으로 설정합니다.
4. 모니터링: 최근 성공 시각이 정상 주기 안에 있는지 확인합니다.
5. 알람: 스킵 N회 연속 또는 실패 1회에 페이지를 보냅니다.

## 원본 출처

- raw: `raw/ai-engineering/2bun-coding/cronjob-concurrency-trap.md`
- 외부: [2분코딩 — 배치가 두 번 돌았는데, 아무도 몰랐어요](https://www.youtube.com/watch?v=JhBiSdXpvk4)
- 공식: [Kubernetes CronJob 문서](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## 관련 페이지

- [[concept-db-connection-pool]] — 같은 "타이머 조합" 방어 패턴
- [[concept-keepalive-timeout-race]] — 같은 "기본값 그대로 두면 사고" 패턴
- [[concept-varchar-length-prefix]] — 같은 "관습은 부작용을 동반한다" 패턴
- [[concept-transactional-rollback-policy]] / [[concept-jpa-enum-mapping]] — 같은 "기본값과 가정의 함정" 패턴의 Spring·JPA판
- [[src-spring-data-access-ref]] — Spring Batch의 `@Scheduled` 멀티 인스턴스 운영 맥락
- [[concept-harness-engineering]] — 인프라 기본값에 대한 "구조적 방어"
