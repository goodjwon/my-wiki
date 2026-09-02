---
title: Workout History 기술 노트 (설계 원칙 6개와 함정)
type: source
tags: [workout-history, flutter, local-first, 앱설계, 모바일]
sources: [workout-history/TECH_NOTES.md, workout-history/TIMELINE.md]
external:
  - https://wonslab.dev/workout-history/
created: 2026-09-03
updated: 2026-09-03
---

# Workout History 기술 노트

## 개요

직접 만들어 출시한 운동 기록 앱 [[entity-workout-history]]의 설계 원칙 6개를 "왜 그렇게 정했고, 무엇을 막아 줬나" 기준으로 정리한 원본 노트의 요약입니다. 원본은 비공개 앱 저장소의 설계 문서이고, 이 위키에는 클래스·테이블·파일명을 뺀 개념 수준만 옮겼습니다.

## 원칙 6개 한눈에

| # | 원칙 | 한 줄 이유 | 위키 개념 페이지 |
|---|------|-----------|----------------|
| 1 | Local-first | 3초 기록은 네트워크 왕복 하나로 깨진다 | [[concept-local-first-append-only]] |
| 2 | Append-only + 파생값 | 파생값을 저장하는 순간 "언제 다시 계산하나"가 버그가 된다 | [[concept-local-first-append-only]] |
| 3 | 단일 타이머 상태기계 | 타이머 세 개면 백그라운드 복원을 세 번 디버깅한다 | [[concept-single-timer-state-machine]] |
| 4 | 워치는 얇은 클라이언트 | 워치에 DB를 두면 충돌 해결이 필요해진다 | [[concept-thin-watch-client]] |
| 5 | 성능 예산 | 콜드 스타트 <1.5s · 저장 <100ms, 위반은 리뷰 블로커 | [[entity-workout-history]] |
| 6 | 기록은 행위의 산물 | 수동 입력이 있으면 스트릭은 자기기만 도구가 된다 | [[concept-record-as-product-of-action]] |

## 원본에서 건진 함정 4가지

| 함정 | 증상 | 교훈 |
|------|------|------|
| "하루"의 경계 | 저장은 UTC, 판정은 로컬 자정 — 섞이면 스트릭이 하루 어긋남 | 시계를 주입해 자정·타임존을 테스트로 고정 |
| 증분 앵커 전진 | 전부 건너뛴 배치가 앵커를 밀어 이후 영영 0건 | 앵커는 실제로 가져온 것이 있을 때만 전진 |
| 이어하기 시드 | 시간형 타이머에 시드까지 넣으면 이중 차감 | 반복형은 시드, 시간형은 "남은 시간" 타깃 |
| 시뮬레이터 워치 세션 | 폰↔워치 세션이 붙지 않음 | 워치 앱에 데모 스냅샷 내장으로 스크린샷 |

## 개발 프로세스

Claude Code 에이전트 6역할(advisor · app-developer · ui-developer · qa-reviewer · tester · release-manager)로 판단과 구현을 분리했습니다. 게이트(리뷰→테스트) 생략 금지, 문서가 진실, 용어 사전으로 동의어 금지 — [[concept-advisor-worker]]의 6역할 확장 사례입니다.

## 원본 파일 위치

- raw/workout-history/TECH_NOTES.md — 설계 원칙·함정 원문
- raw/workout-history/TIMELINE.md — 출시 여정 이정표·삽질 로그

## 관련 페이지

- [[entity-workout-history]] — 앱 카드(스택·원칙 목차·출시 이력)
- [[concept-local-first-append-only]] — 원칙 1·2
- [[concept-single-timer-state-machine]] — 원칙 3
- [[concept-thin-watch-client]] — 원칙 4
- [[concept-record-as-product-of-action]] — 원칙 6
- [[concept-advisor-worker]] — 개발 프로세스의 바탕 패턴
