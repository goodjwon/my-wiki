---
title: 크론잡 중복 실행과 Forbid 함정 (concurrencyPolicy + activeDeadlineSeconds)
type: concept
tags: [kubernetes, cronjob, batch, concurrency, sre, troubleshooting]
sources:
  - 2bun-coding/cronjob-concurrency-trap.md
external:
  - https://www.youtube.com/watch?v=JhBiSdXpvk4
  - https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
created: 2026-06-06
updated: 2026-06-06
---

# 크론잡 중복 실행과 Forbid 함정

## 정의

스케줄된 배치 작업(Cron / Kubernetes CronJob)이 **이전 실행이 끝나기 전에 다음 스케줄이 도래**할 때 발생하는 동시 실행 문제와, 이를 단순히 차단(`Forbid`)했을 때 생기는 **Hang 무한 스킵** 함정. 둘 다 막으려면 **`Forbid` + `activeDeadlineSeconds`** 조합이 필수.

> 핵심 인사이트: 단일 안전장치는 또 다른 사고를 부른다. **두 가지 방어선이 함께** 필요.

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

코드엔 버그 없음. **인프라 기본값이 사고의 원인.**

## 환경별 기본 동작

| 환경 | 동시 실행 기본값 | 위험 |
|------|--------------|------|
| **Linux `cron`** | 이전 완료 여부 확인 X | 중복 실행 |
| **Kubernetes CronJob** | `concurrencyPolicy: Allow` | 중복 실행 |
| **Spring `@Scheduled`** | 단일 스레드 풀에서는 자동 직렬화 (다중 인스턴스에서는 위험) | 멀티 인스턴스 환경에서 중복 |
| **systemd timer** | 별다른 락 없음 | 중복 가능 |

## 1차 방어선: 중복 실행 차단

### Linux Cron — `flock`

파일 락으로 동일 작업 중복 방지:

```bash
# /etc/cron.d/settlement
0 * * * * appuser flock -n /var/lock/settlement.lock /usr/local/bin/settlement.sh
```

- `-n` (`--nonblock`): 락 못 잡으면 즉시 종료 (다음 주기에 다시 시도)
- 옵션 `-w 30`: 최대 30초 대기 후 포기
- 스크립트 종료 시 락 자동 해제

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

`concurrencyPolicy` 3가지:

| 값 | 동작 | 적합 상황 |
|----|------|---------|
| **`Allow`** (기본) | 중복 실행 허용 | 멱등하고 빠른 작업 |
| **`Forbid`** | 이전 실행 중이면 새 실행 스킵 | **정산·집계 등 멱등하지 않은 작업** |
| **`Replace`** | 이전 작업 죽이고 새로 시작 | 항상 "최신 1회"만 의미 있는 작업 |

## 2차 방어선: Hang 방지 (`Forbid`의 함정)

`Forbid`만 걸면 새로운 사고:

```
09:00 — 1차 시작
09:35 — DB 데드락으로 Hang. Pod는 살아있지만 진전 없음
10:00 — 2차 스케줄 도래 → Forbid → 스킵
11:00 — 다음도 스킵
...
다음 날 — 운영자가 알아챘을 때 이미 12시간 배치 손실 ⚠️
```

→ **`activeDeadlineSeconds`** 로 한 작업의 최대 수명 제한:

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

`activeDeadlineSeconds` 동작:
- Job 시작 후 N초 경과하면 **SIGTERM → 30초 대기 → SIGKILL**
- 다음 스케줄이 정상 실행될 수 있는 상태로 정리
- 단점: 정상이지만 오래 걸리는 작업도 죽음 → **평균 + 안전 마진**으로 설정

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

`Forbid`로 스킵된 경우 **알람**이 없으면 12시간 손실 같은 함정에 빠진다.

- **Pod 이벤트 감시**: `JobAlreadyActive` (스킵 발생 시 이 reason)
- **Prometheus 메트릭**:
  - `kube_cronjob_status_last_successful_time` 가 예상보다 오래 멈춰있나
  - `kube_job_failed{...}` 증가
- **Slack/PagerDuty 알람**: 스킵 N회 연속이면 페이지
- **별도 헬스체크 잡**: 매 시간 "배치가 N분 이내 성공했나" 확인 → 실패 시 알람

## 같은 패턴 — "단일 방어선의 함정"

이 페이지의 인사이트는 다른 인프라 사고와 같은 구조:

| 영역 | 단일 방어 | 그 함정 | 2차 방어 (조합) |
|------|---------|--------|--------------|
| **크론잡** | `Forbid` (중복 차단) | Hang → 무한 스킵 | `activeDeadlineSeconds` |
| **[[concept-db-connection-pool|DB 풀]]** | 풀 자체 사용 | 좀비 커넥션 → 장애 | `maxLifetime` |
| **[[concept-keepalive-timeout-race|LB-서버]]** | Keep-Alive 사용 | 타임아웃 불일치 → 502 | 서버 timeout > LB |
| **[[concept-varchar-length-prefix|VARCHAR(255) 관습]]** | 255로 통일 | utf8mb4 → 2-byte prefix | 도메인 + 63 경계 인지 |

→ **공통 원리**: 어떤 자동화·캐시·차단·관습도 **반드시 부작용을 동반**한다. 단일 안전장치를 절대시하지 말고 **그 자체의 실패 모드까지 방어**해야 한다.

## 진단 체크리스트 — 우리 배치는 안전한가

1. `kubectl get cronjob -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.concurrencyPolicy}{"\t"}{.spec.jobTemplate.spec.activeDeadlineSeconds}{"\n"}{end}'`
2. `concurrencyPolicy` 가 **`Allow`** (또는 미지정) 인 CronJob 발견 → 멱등성 확인 후 `Forbid` 검토
3. `activeDeadlineSeconds` 미지정 → 평균 실행 시간 측정 후 **2~3배 + 안전 마진**으로 설정
4. 모니터링: 최근 성공 시각이 정상 주기 안에 있는가
5. 알람: 스킵 N회 연속 또는 실패 1회 시 페이지

## 원본 출처

- raw: `raw/2bun-coding/cronjob-concurrency-trap.md`
- 외부: [2분코딩 — 배치가 두 번 돌았는데, 아무도 몰랐어요](https://www.youtube.com/watch?v=JhBiSdXpvk4)
- 공식: [Kubernetes CronJob 문서](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## 관련 페이지

- [[concept-db-connection-pool]] — 같은 "타이머 조합" 방어 패턴
- [[concept-keepalive-timeout-race]] — 같은 "기본값 그대로 두면 사고" 패턴
- [[concept-varchar-length-prefix]] — 같은 "관습은 부작용을 동반한다" 패턴
- [[src-spring-data-access-ref]] — Spring Batch의 `@Scheduled` 멀티 인스턴스 운영 맥락
- [[concept-harness-engineering]] — 인프라 기본값에 대한 "구조적 방어"
