---
title: On Pocket News 개발기 (2026-02 ~ 2026-10)
type: source
tags: [on-pocket-news, spring-boot, kotlin, react, firestore, cloud-run, privacy, personalization, harness-engineering]
sources: []
external:
  - https://pocket.wonslab.dev
  - https://blog.wonslab.dev/2026-10-10-on-pocket-news-intro/
  - https://blog.wonslab.dev/2026-10-10-on-pocket-news-privacy-local-collection/
created: 2026-10-24
updated: 2026-10-24
---

# On Pocket News 개발기 — 룰 기반 정책 추천과 1인 서비스의 개인정보 개편

## 출처

- 이 페이지는 블로그 글 2편(서비스 소개, 개인정보·수집 개편기)과 1:1로 대응하는 지식 원본입니다.
- 사실 원본은 on-pocket-news 저장소(CONSTITUTION.md, CLAUDE.md, docs/exec-plans/active/BACKLOG.md, docs/exec-plans/evidence/2026-10-10/TEST_EVIDENCE.md, docs/references/OPERATIONS.md, 코드, git 이력 571커밋)입니다. raw/ 사본은 두지 않았고, 블로그 글의 주장은 2026-10-24 기준 저장소와 한 문장씩 대조했습니다.
- 법 조항은 국가법령정보센터의 개인정보 보호법 현행본(2026-09-11 시행)과 대조했습니다.

## 서비스 한 줄

정부·지자체 정책 중 내 상황(지역, 가족, 관심사)에 맞는 것만 골라 읽기 쉽게 전달하는 1인 서비스입니다. 이 문장이 CONSTITUTION.md 제1조 "내 주머니 속 정책 뉴스"이고, 주소는 [pocket.wonslab.dev](https://pocket.wonslab.dev)(2026-10-19 연결)입니다.

| 축 | 선택 | 비고 |
|----|------|------|
| API | Spring Boot 3 + Kotlin | 회원·추천·콘텐츠·작업 배분 |
| 수집 에이전트 | Python 3.11 + FastAPI | 로컬 PC에서 실행 |
| 웹 | React 18 + Vite + TypeScript | 사용자 화면 + 관리자 화면 |
| DB | Firestore(운영), MongoDB(로컬) | 저장소 전략 inmemory/mongodb/firestore |
| 호스팅 | Cloud Run(min 0, max 1) + Firebase Hosting | max 1은 인메모리 중복 체크 때문 |

## 아키텍처 — 수집은 로컬, 클라우드는 서비스만

2026-10-10 개편(`e3dd21a`)으로 복지로 수집기를 Kotlin 서버에서 `agent/welfare_collector.py`로 옮겼습니다. 서버는 `/agents/{id}/collect/` 아래 세 가지만 답합니다. `json-api-sites`는 수집할 차례인 사이트를, `unknown-urls`는 처음 보는 URL을 알려 주고, `done`은 완료를 기록합니다. 처음 보는 글만 상세 API를 부르므로 data.go.kr 개발계정 한도(100건/일)를 아낍니다. 운영은 `APP_COLLECTION_SERVER_SIDE=false`로 폴백 크롤·기관 탐색·STALE 자동 복구를 하지 않습니다.

추천은 전부 룰 기반입니다. `RecommendationEngine`은 지역 일치율(시군구 1.0 > 시도 0.95 > 전국 0.5), 생애 단계, 대상 독자와 '내 상황', 관심 토픽, 마감 임박 가산(D-1 이내 +25, D-7 이내 +15), 주제당 최대 2건의 다양성 필터로 점수를 매깁니다. 마감 알림 메일은 D-7·D-1에 수신 동의 회원에게만 보내며 `NOTIFICATION_ENABLED` 기본값은 false입니다.

## 타임라인

| 날짜 | 사건 | 근거 |
|------|------|------|
| 2026-02-16 | 저장소 시작 | `55bf10f` |
| 2026-03-20 | EUC-KR 인코딩 자동 감지·본문 길이 필터 | `3445e37` |
| 2026-03-24 | 로컬 직접 배포 금지 규칙 명시(개발용 API 주소 운영 유출 사고 후) | `4bfe48d` |
| 2026-04-11 | 헌법(CONSTITUTION.md)·역할 문서(AGENTS.md) 도입, 하네스 문서 구조 전환 | `08f0465` `9aa0cc9` |
| 2026-04-12 | 384건 일괄 감수 사고 → 일괄 처리 금지 규칙 | `e47df9d` |
| 2026-04-21 | 에이전트 페어링 토큰 인증 | `f99abb6` |
| 2026-04-22 | Gemini 자동 호출 전면 제거, 상세 URL 화이트리스트, 사이트 분석가 페르소나 | `c90fbb2` `0d76c22` |
| 2026-04-24 | 복지로(지자체) JSON_API 수집 전환 | `d2dc8f7` |
| 2026-05-03 | 기관 레벨링 L1 전국·L2 지자체·L3 비대상, 메뉴 URL 차단 | `0070887` `62590af` |
| 2026-10-05 | 중앙부처 복지 수집기, Cloud Run max 3→1, 페르소나 기준선 14%→44% | `800aa3a` `be3bb0b` `54dbf41` |
| 2026-10-07 | 미감수 254건 1건씩 감수, 판례 추가 | `90ae12a` |
| 2026-10-09 | '내 상황' 입력·수집일 표시·경량 피드 API, 운영 재측정 58%, 이미지 3회분 보존 | `af064e3` `dd51a22` |
| 2026-10-10 | 개인정보 개편·시군구 코드표(62%)·중복 필터·수집 로컬 이관 | `54dea2c`~`e3dd21a` |
| 2026-10-19 | 커스텀 도메인 연결, 구글·애플 로그인 | `c42116f` `77662bd` |
| 2026-10-20 | 예외 신설: batch-hub `onpocket-review` 헤드리스 감수(1건씩, 하루 최대 30건) | `4e77cb5` |

## 사고와 규칙 — 실패가 문서가 된 경로

| 사고 | 증상 | 남은 규칙 |
|------|------|-----------|
| 로컬 빌드 배포(2026-03) | `VITE_API_BASE_URL=localhost:8080` 빌드가 운영에 올라감 | 배포는 `git push` → CI만 (CLAUDE.md §3-3) |
| 일괄 감수(2026-04-12) | 384건이 편집본=원문·태그 없음으로 감수 완료, 쓰레기 약 280건 노출 | 감수·사이트 분석 1건씩, 스크립트 일괄 처리 금지 (§3-5b) |
| L3 기관 자동 등록(2026-05-03) | 미감수 180건 중 179건이 연구·체육 기관 메뉴 페이지 | 기관 레벨링 + `MenuIndexUrlBlocklist` |
| 다중 인스턴스(2026-10-05) | 인메모리 중복 체크가 갈라져 복지로 같은 URL 123건 중복 | Cloud Run max-instances=1 고정 |
| 이미지 누적(2026-10-05) | Artifact Registry 7.3GB, 버전 254개 | 최근 9버전(빌드 3회) + 1일 경과 삭제 |
| 알림 기본값(2026-10-10) | 수신 미동의 가입자도 `notificationEnabled=true`, 기존 테스트가 이 기본값을 정답으로 검증 | 가입 시 동의 값을 따르고, 발송 조건은 `notificationEnabled && consentMarketing` 이중 조건 (`e80ec86`) |

마지막 사고는 화면 증적(Playwright 자동 조작·캡처)을 만들다 발견했습니다. 테스트 158건이 모두 통과한 상태였으므로, "테스트 통과"가 아니라 "실제 화면 증적"을 완료 기준으로 둔 규칙이 이 버그를 잡았습니다.

## 개인정보 개편 핵심 (2026-10-10)

| 조항(개인정보 보호법) | 구현 | 근거 |
|------|------|------|
| 제22조의2 아동의 개인정보 보호 | 만 14세 이상 확인 필수, 서버에서도 검증 | `54dea2c` |
| 제23조 민감정보의 처리 제한 | '내 상황'을 하나라도 고르면 `consentSensitive` 필수, 미동의면 저장 거부 | `54dea2c` |
| 제29조 안전조치의무 | 이름·전화번호 AES-256-GCM, 키는 Secret Manager | `9d8de2b` |
| 제30조 처리방침 공개 | 운영 주체 wonslab, 위탁(Google Cloud·Firebase) 등 현행화 | `bab29ea` |
| 제35·36조 열람·정정 | 내 정보 화면에서 조회·수정 | `bab29ea` |
| 제21조 파기 | 탈퇴 시 회원·매칭 이력 즉시 삭제, 기관 등록 요청은 요청자 이름만 익명화 | `bab29ea` |

암호화는 `PiiCipher`가 `enc:v1:` + base64(IV 12바이트 + 암호문)로 저장하고, 접두어가 없으면 평문으로 보고 그대로 돌려줍니다. 서버가 시작하며 회원을 읽을 때 평문 회원을 찾아 암호화해 다시 저장하므로 별도 마이그레이션 스크립트가 없습니다. 이메일 인증은 6자리 코드 10분, 1회용 가입 토큰 30분, 이메일당 1시간 5회 요청, 5회 오답 시 코드 폐기이며 SMTP 계정이 없으면 자동으로 꺼집니다.

중복 필터는 네 겹입니다. 목록 상태 파라미터(`pageIndex`·`searchKrwd` 등)를 지운 URL, 같은 사이트의 같은 제목(공백·기호 무시), 제목·출처 줄을 뺀 본문 해시, 그리고 감수에서 지운 글의 묘비(tombstone) 키를 비교합니다. 묘비는 저장소에 남으므로 재시작 뒤에도 되살아나지 않습니다.

## 블로그 글과의 1:1 대응

| 블로그 글 절 | 위키 절 | 대조 결과 |
|------|------|------|
| 소개 · 왜 만들었나 / 무엇을 하는 서비스인가 | 서비스 한 줄, 아키텍처 | 일치 |
| 소개 · 구조 표 | 서비스 한 줄 | 일치. 근거 없던 "복지로 2,400여 건"은 10-24 블로그에서 삭제(저장소 기록: 지자체 목록 상한 1,000건 + 중앙부처 461건) |
| 소개 · 지킨 원칙 세 가지 | 사고와 규칙 | 일치. 2026-10-20 헤드리스 감수 예외는 10-24 블로그에 한 문장으로 반영 |
| 소개 · 지금까지 한 일 | 타임라인 | 10-24 블로그 정정 완료: 인코딩 감지·짧은 본문 폐기 2026-03, 페어링 인증 2026-04, 지자체 복지로 연동 2026-04(10월 초는 중앙부처) |
| 소개 · AI와 함께 만든다는 것 | 사고와 규칙 | 일치 |
| 개편기 1. 개인정보보호법 | 개인정보 개편 핵심 | 일치(조항 번호·제목 법령 원문 확인) |
| 개편기 2. 강원 고성군 / 3. 중복 기사 | 개인정보 개편 핵심 | 일치 |
| 개편기 4. 클라우드 비용 | 아키텍처, 사고와 규칙 | 일치 |
| 개편기 5. AI와 같이 일하는 방식 · 숫자 | 사고와 규칙 | 일치(158·50·23건, 14%→62%, 254건) |

## 같은 인사이트 패턴 — "통과 신호는 의도를 증명하지 않는다"

| 영역 | 거짓 통과 신호 | 진짜 거부 신호 | 참조 |
|------|---------------|---------------|------|
| 감수 파이프라인 | 384건이 "감수 완료" 상태 | 1건씩 본문을 읽고 판단 | (이 페이지) |
| 알림 기본값 | 단위 테스트 전부 통과 | 실제 화면 증적 | (이 페이지) |
| 하네스 | 프롬프트로 한 약속 | 사고 이력을 CLAUDE.md 금지 규칙으로 누적 | [[concept-harness-engineering]] |
| AI 루프 | 에이전트의 자기 보고 | 테스트·타입 체크·실제 에러 | [[concept-loop-engineering]] |
| 앱 출시 | 리뷰 없이 머지 | qa-reviewer → tester 게이트 생략 금지 | [[src-workout-history-launch]] |
| 기본값 | "무난한" 기본값 | 명시적 설정·계약 | [[concept-cronjob-concurrency-trap]] |

자동화가 "완료"라고 말하는 순간은 의견이고, 사람이 화면과 본문으로 확인한 결과가 사실입니다.

## 빠른 진단

- [ ] 개인정보를 받는 기능마다 근거 조항과 서버 검증이 짝지어 있는가
- [ ] 암호화를 켜도 기존 평문 데이터가 깨지지 않는가(접두어 + 점진 마이그레이션)
- [ ] 동의 여부가 저장 기본값이 아니라 발송·처리 조건에 걸려 있는가
- [ ] 클라우드가 외부 호출을 하지 않도록 설정 하나로 끌 수 있는가
- [ ] 완료 기준에 실제 화면 증적이 들어 있는가

## 원본 출처

- 서비스: <https://pocket.wonslab.dev>
- 블로그: 아래 "이 개념을 다룬 글" 2편
- 저장소: CONSTITUTION.md, CLAUDE.md §3, docs/exec-plans/active/BACKLOG.md, docs/exec-plans/evidence/2026-10-10/TEST_EVIDENCE.md, docs/references/OPERATIONS.md
- 법령: 국가법령정보센터 [개인정보 보호법](https://www.law.go.kr/법령/개인정보보호법)

## 관련 페이지

- [[concept-harness-engineering]] — 사고를 규칙 문서로 누적하는 방식의 일반론
- [[concept-loop-engineering]] — 루프 안의 거부 신호
- [[concept-claude-md]] — CLAUDE.md·헌법 문서 체계
- [[src-workout-history-launch]] — 같은 1인 개발, 게이트 생략 금지
- [[src-morningbrief]] — 경량 피드 API(`/public/feed`)를 소비하는 자매 서비스
- [[concept-cronjob-concurrency-trap]] — "기본값과 가정의 함정" 패턴 허브

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [On Pocket News — 내 주머니 속 정책 뉴스를 만든 이유와 과정](https://blog.wonslab.dev/2026-10-10-on-pocket-news-intro/)
- [1인 서비스에 개인정보보호법 입히기 — On Pocket News 개편기](https://blog.wonslab.dev/2026-10-10-on-pocket-news-privacy-local-collection/)
