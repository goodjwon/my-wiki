---
title: Workout History (운동기록 - 3초 홈트 트래커)
type: entity
tags: [workout-history, flutter, swiftui, compose, 앱, 사이드프로젝트, local-first]
sources: [workout-history/TECH_NOTES.md, workout-history/TIMELINE.md]
external:
  - https://wonslab.dev/workout-history/
  - https://apps.apple.com/kr/app/id6802307567
created: 2026-09-03
updated: 2026-09-03
---

# Workout History

"3초 안에 기록하는" 맨몸운동 중심 운동 기록 앱입니다. 팔굽혀펴기·스쿼트·플랭크 같은 운동을 "하는 순간" 탭 카운트와 타이머가 기록으로 남기고, 계정·인터넷 없이 완전히 동작합니다. 2026-07-20 백로그 첫 줄에서 2026-08-19 심사 제출, 2026-08-21 App Store 출시까지 45일이 걸렸습니다.

> 포지셔닝 한 줄: **"기록하지 마세요. 운동하세요 — 기록은 저절로 남습니다."**

## 기본 정보

| 항목 | 내용 |
|------|------|
| 플랫폼 | iOS · Android(Flutter 한 벌) + Apple Watch(SwiftUI) · Wear OS(Compose) |
| 가격 | 무료 (프로 기능은 후속) |
| 계정·서버 | 없음 — 모든 데이터는 기기 안 SQLite |
| 출시 | iOS 2026-08-21 (1.0) → 1.0.x 운영 중 · Android는 Play 테스트 트랙 |
| 소개 | https://wonslab.dev/workout-history/ |
| 개발 | 1인 + Claude Code 에이전트 6역할 |

## 스택

| 층 | 선택 | 이유 |
|----|------|------|
| 폰 UI·상태 | Flutter/Dart 3 · Riverpod | 한 벌로 iOS·Android. Riverpod Provider가 ViewModel 역할, 다른 상태관리 도입 금지 |
| 로컬 DB | Drift(SQLite) | 로컬 우선의 진실 저장소. 타입 안전 쿼리·스트림 |
| 라우팅·모델 | go_router · freezed | 표준 조합 |
| Apple Watch | SwiftUI + WatchConnectivity | Flutter는 워치 미지원. 화면 3개짜리 얇은 클라이언트는 네이티브가 더 싸다 |
| Wear OS | Jetpack Compose | 같은 JSON 메시지 스키마로 폰과 통신 |
| 구조 | feature-first + presentation/domain/data 3분할 | Domain은 순수 Dart — 아키텍처 테스트로 Flutter import를 잠금 |

## 흔들리지 않은 설계 원칙 6개

| # | 원칙 | 요지 | 자세히 |
|---|------|------|--------|
| 1 | Local-first | 읽기·쓰기는 로컬 즉시, 네트워크·헬스는 전부 백그라운드 | [[concept-local-first-append-only]] |
| 2 | Append-only + 파생값 | 기록 수정 금지·삭제는 tombstone, 스트릭·통계는 저장하지 않고 계산 | [[concept-local-first-append-only]] |
| 3 | 단일 타이머 상태기계 | 세트 휴식·루틴 인터벌·런 타이머가 한 엔진, 벽시계 기준 복원 | [[concept-single-timer-state-machine]] |
| 4 | 워치는 얇은 클라이언트 | 진실은 폰, 워치는 스냅샷 캐시 + 미전송 큐, 멱등 수신 | [[concept-thin-watch-client]] |
| 5 | 성능 예산 | 콜드 스타트 <1.5s, 기록 저장(탭→햅틱) <100ms — 위반은 리뷰 블로커 | 이 페이지 아래 절 |
| 6 | 기록은 행위의 산물 | 탭·타이머·센서·헬스만 기록을 만든다, 임의 수동 입력 UI 없음 | [[concept-record-as-product-of-action]] |

## 성능 예산 — 원칙 5

| 예산 | 값 | 지키는 방법 |
|------|----|------------|
| 콜드 스타트 | <1.5s | 헬스·걸음수 조회는 첫 프레임 이후(이벤트 루프 양보 후) |
| 기록 저장 | 탭→햅틱 <100ms | 로컬 DB 즉시 쓰기, 파생값은 별도 스트림에서 갱신 |
| 스트릭 조회 | <50ms (성능 테스트) | 400일 윈도우 캡 — 캐시 대신 상한 |
| 중복 저장 | 0건 | 첫 `await` 이전 동기 구간에서 in-flight 가드 |

예산은 숫자로 문서에 박혀 있고, 리뷰어 에이전트가 위반을 블로커로 판정합니다. "빠르게"가 아니라 "1.5초"여야 기계가 판정할 수 있습니다.

## 색·햅틱·음성 — 신호는 항상 하나

| 신호 | 색 | 뜻 |
|------|----|----|
| 운동(해라) | 오렌지 `#FF6B45` | work 세그먼트, 카운트 링 |
| 휴식(쉬어라) | 아쿠아 `#3ECFB2` | rest 세그먼트, 카운트다운 |

색·햅틱·음성이 같은 의미를 가리키도록 고정해, 화면을 보지 않아도 지금 무엇을 해야 하는지 알 수 있게 했습니다. UI는 다크 고정입니다.

## 개발 프로세스

Claude Code 에이전트 6역할로 판단과 구현을 분리했습니다.

| 역할 | 담당 |
|------|------|
| advisor | 범위·설계 결정, 문서 정합, "열린 결정" 확정 |
| app-developer | 도메인·데이터·엔진·DB·네이티브(워치·헬스) |
| ui-developer | 화면·디자인 토큰·애니메이션·접근성 |
| qa-reviewer | 머지 전 품질 게이트(블로커 0까지 반복) |
| tester | 회귀 시나리오 실행·버그 재현 |
| release-manager | 버전·체인지로그·제출 Go/No-Go |

규칙 세 가지 — 판단/구현 분리, 게이트 생략 금지, **문서가 진실**(코드가 문서와 어긋나면 문서 수정 논의부터). [[concept-advisor-worker]]의 2역할을 6역할로 확장한 실전 사례입니다.

## 출시 이력

| 날짜 | 사건 |
|------|------|
| 2026-07-20 | 백로그 시작 |
| 2026-08-02 | 원칙 6 "기록은 행위의 산물" 확정 — 수동 입력 UI 전면 삭제 |
| 2026-08-17 | 개념 모델 확정·애플 개발자 등록·번들 ID 교체·ASC 앱 생성(하루) |
| 2026-08-19 | 심사 제출 |
| 2026-08-21 | iOS 1.0 승인·출시 |
| 2026-08-30 | 1.0.4 — 화면 재정합·홈 개편 |
| 2026-09-03 | 1.0.6 심사 제출 — 세트 이어하기·부분 저장 |

## 원본 출처

- raw/workout-history/TECH_NOTES.md — 설계 원칙·함정
- raw/workout-history/TIMELINE.md — 이정표·삽질 로그

## 관련 페이지

- [[src-workout-history-tech-notes]] — 원본 노트 요약
- [[concept-local-first-append-only]] — 원칙 1·2
- [[concept-single-timer-state-machine]] — 원칙 3
- [[concept-thin-watch-client]] — 원칙 4
- [[concept-record-as-product-of-action]] — 원칙 6
- [[concept-advisor-worker]] — 개발 프로세스의 바탕 패턴
- [[concept-claude-md]] — "문서가 진실" 규칙을 담는 헌법 파일
