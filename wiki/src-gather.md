---
title: 언제볼래 개발기 (2026-11-07 ~ 2026-11-19)
type: source
tags: [gather, 언제볼래, cloud-functions, firestore, flutter, react, openapi, app-release, app-store-review]
sources:
  - gather/README.md
  - gather/TIMELINE.md
  - gather/TECH_NOTES.md
external:
  - https://gather.wonslab.dev/
  - https://blog.wonslab.dev/2026-11-19-gather-intro/
created: 2026-11-19
updated: 2026-11-19
---

# 언제볼래 개발기 — 도메인은 서버 한 곳, 화면은 얇게

## 출처

- 사실 원본은 비공개 앱 저장소 gather-project입니다. 원본 노트는 `raw/gather/README.md`(자료 구성·상태 기록 주의), `raw/gather/TIMELINE.md`(git log 날짜별 사실), `raw/gather/TECH_NOTES.md`(구조·점수·저장 설계)입니다. 조회 기준일은 2026-11-19입니다.
- 배포 자동화 맥락은 `raw/app-release-ship/README.md`에 있습니다. 그 문서의 `/ship` 대상 앱 3개 중 하나가 언제볼래입니다.

## 앱 한 줄

링크 하나를 단톡방에 던지면 앱 설치 없이 "언제·어디서·뭐 먹을지"가 정해지게 하는 서비스입니다. 기획 문서의 최종 목표는 "3분 안에 확정"이고, 모든 기능은 이 문장에서 거꾸로 도출했다고 적혀 있습니다.

| 역할 | 채널 | 하는 일 |
|------|------|---------|
| 주최자 | Flutter 앱(iOS 아이폰 전용·Android) | 분류 선택, 후보 날짜(기간·요일 또는 날짜 콕콕), 장소 고정 여부, 확정 |
| 참여자 | 웹 링크(설치·가입 없음) 또는 앱 | 이름 + 날짜별 참석·미정·불참, 출발 동네, 음식 취향, 불참 사유 |
| 서버 | Cloud Functions(TypeScript) | 후보 칸 생성, 날짜 점수, 중간 지점·추천, 상태 전이, 공유 미리보기 |

## 구조 결정

| 결정 | 내용 | 이유(원본 기록) |
|------|------|-----------------|
| 도메인 1곳 | 앱·웹은 결과를 그리기만 하고 규칙은 서버만 가짐 | 두 화면이 같은 결과를 보장 |
| 애그리거트 2개 | 모임과 응답을 문서로 분리 | 한 모임에 50명이 몰려도 쓰기 경합 없음(NFR-S1) |
| 유일성을 문서 ID로 | 응답 ID = `{slug}_{sha256(기기토큰) 22자}` | Firestore에 유일성 제약이 없음. 11-09 토큰 원문을 해시로 교체 |
| 도메인 1개, 경로로 나눔 | Hosting이 `/api/**`·`/g/**`를 함수로 rewrite | CORS 없음, 카카오 콘솔 도메인 등록 1번 |
| 서버 교체 | Spring Boot(Cloud Run) → TypeScript Cloud Functions(11-11) | JVM 콜드 스타트 7~11초가 응답 화면 2초 목표를 넘김 |
| 계약 우선 | `clients/openapi.json`을 손으로 고치고 TS·Dart 클라이언트 생성 | 서버 언어를 바꿔도 클라이언트 통신 코드 무변경 → [[concept-api-contract-server-swap]] |

날짜 점수는 `2·가능 + 1·애매 − 100·필수참석자불참`이고, 정렬은 전원 가능 여부 → 점수 → 날짜 순입니다. 결과 화면은 상위 3개 날짜와 날짜별 "못 오는 사람" 이름을 함께 보여 줍니다. 주최자가 한 명을 빼고 진행할지 판단하게 하려는 설계입니다.

## 콜드 스타트 — 세 번의 시도

| 날짜 | 시도 | 결과 |
|------|------|------|
| 11-07 | Cloud Run JVM + CDS·지연 초기화 | 첫 요청 7~11초 |
| 11-07 | GraalVM 네이티브 이미지 | 로컬 기동 0.09초. 빌드에 8GB 이상이 필요해 같은 날 철회 |
| 11-11 | Node(Cloud Functions) | 채택. 부족하면 최소 인스턴스 1대(유료) 검토로 남김 |

## 심사 — 2.1 정보 요청

| 날짜 | 상태 | 근거 |
|------|------|------|
| 11-11 | App Store 1.0.0(6) 첫 제출, Play 1.0.0(5) 비공개 테스트 | ASC·Play 런북 |
| 11-14 | "Guideline 2.1 - Information Needed" 거절 → 실기기 녹화 + 영문 메모(목적·사용법·외부 서비스·지역·규제 업종)로 회신·재제출 → 심사 대기 중 | `7abc6af` |
| 11-19 | 런북 변경 이력(커밋 전): 중국 판매 때문에 배포가 막혀 판매 국가를 한국만으로 → 출시 확인 | APP_STORE_CONNECT.md 작업 트리 |

2.1은 빌드 결함이 아니라 정보 요청입니다. 빌드는 그대로 두고 메모만 채워 재제출했습니다. 로그인이 없는 앱이라 "데모 계정 없음, 계정 삭제 대상 없음"을 메모에 명시한 점이 특징입니다.

## 같은 인사이트 패턴 — "제출한 것과 같은 것을 유지한다"

| 페이지 | 바뀌는 쪽 | 고정하는 쪽 | 장치 |
|--------|-----------|-------------|------|
| **언제볼래 (이 페이지)** | 서버 언어·런타임 | API 모양·저장 문서 | 손으로 고치는 OpenAPI 계약, 심사 중 필드 추가만 허용 |
| [[concept-api-backward-compatibility]] | 서버 응답 | 클라이언트 파서 | Tolerant Reader 계약 |
| 앱 배포 자동화(`raw/app-release-ship/README.md`) | 프로덕션 출시 시점 | 테스터가 확인한 바이너리 | prod는 다시 빌드하지 않고 테스트 빌드를 승격 |
| [[concept-api-contract-server-swap]] | 서버 구현 전체 | 계약 파일 + 생성 클라이언트 | 같은 흐름을 두 서버에 돌려 응답 비교 |

## 빠른 진단

- [ ] 도메인 규칙이 서버 한 곳에만 있습니까(앱·웹에 점수 계산이 없습니까)?
- [ ] Firestore처럼 유일성 제약이 없는 저장소에서 규칙을 문서 ID로 보장합니까?
- [ ] 외부에 보이는 ID에 신원(토큰 원문)이 들어가지 않습니까?
- [ ] 심사 중인 빌드가 쓰는 API 모양을 서버 배포가 깨지 않습니까?

## 원본 출처

- raw: `raw/gather/README.md`, `raw/gather/TIMELINE.md`, `raw/gather/TECH_NOTES.md`
- 연관 raw: `raw/app-release-ship/README.md`
- 공개 페이지: https://gather.wonslab.dev/

## 관련 페이지

- [[concept-api-contract-server-swap]] — 이 앱에서 나온 재사용 패턴(계약 고정 후 서버 교체)
- [[concept-aggregate-boundary]] — 모임·응답 애그리거트를 나눈 기준과 같은 축
- [[src-morningbrief]] — 같은 계정·번들 ID 규칙으로 낸 앞선 1인 앱
- [[src-workout-history-launch]] — 수동 제출 시절의 출시 회고

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [언제볼래 — 단톡방 약속을 링크 하나로 정하는 앱을 만든 이유와 과정](https://blog.wonslab.dev/2026-11-19-gather-intro/)
