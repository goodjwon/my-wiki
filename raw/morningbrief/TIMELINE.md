# 모닝 브리핑 — 타임라인 (2026-10-05 ~ 2026-11-14)

> 원본: 비공개 저장소 `morningbrief`의 `git log`(커밋 날짜 기준)와 `docs/progress.md`·`docs/BACKLOG.md`.
> 조회 기준일 2026-11-19. 괄호 안은 커밋 해시. 버전 표기는 `pubspec.yaml`의 `버전+빌드`.

## 1. 2026-10-05 ~ 10-24 (요약 — 상세는 위키 src-morningbrief)

| 날짜 | 사실 | 근거 |
|---|---|---|
| 10-05 | 작업 명세·개발 규칙·도메인 모델, GraphRunner | `c064706` |
| 10-07 | 백엔드 Kotlin 전환, 언론사 RSS, Flutter 앱 골격 | `58f859b` `9bb08c7` |
| 10-08 | API 서버 → 배치 + Firestore 게시(A안) | `7dd2797` |
| 10-12 | Spring Batch Job 전환, 배치 허브 매일 06:00 등록 | `e0d0be1` `6f715b0` |
| 10-16 | 복지·정책 토픽(온포켓 피드), 푸시 notifyJob, TestFlight IPA | `2a2c1f3` `806896a` `11185ef` |
| 10-17~18 | 요약 읽음·스크랩, Sign in with Apple, 스토어 자료 | `54c09f4` `990e78e` |
| 10-19~20 | 지난 브리핑 뒤로 가기, 보관 7일 → 30일, 주제 칩 바로 가기 | `ae54d08` `8e29450` `190ec88` |
| 10-21 | 0.1.1(빌드 7) 첫 업데이트 준비 | `0963c54` |
| 10-23 | Android 패키지 `dev.wonslab.morningbrief`, Play 비공개 테스트 트랙에 빌드 7 제출 | `34cca40` `7530224` |
| 10-24 | 백로그: 온포켓 감수 배치 08:30 → 05:00 이동 결정(사용자 작업) | `efda134` |

## 2. 2026-10-25 ~ 10-26 — 온포켓 맞춤 정보(picks) 연결

| 날짜 | 사실 | 근거 |
|---|---|---|
| 10-25 | 온포켓 맞춤 정보 연결 합의: Firebase providerData의 소셜 uid(sub) ↔ 온포켓 회원 socialIds 매칭. 이메일·이메일 해시는 쓰지 않음 | `ea22e43` `67a7fe5`, progress.md |
| 10-25 | 배치: notifyJob 앞 picks 단계(partner/matches 조회 → `users/{uid}/picks` 동기화, firstSeenAt), 07:00 알림에 "새 맞춤 정보 N건", 탈퇴 시 picks 삭제·규칙 | `0449dd3` |
| 10-25 | 동기화 규칙: 조회 실패면 아무것도 지우지 않음, subjects 500개씩, 파트너 키가 없으면 건너뜀 | progress.md(Phase 2 구현) |
| 10-26 | 회사 Mac 배치 작업 디렉터리 `.env`에 파트너 키 추가, jar 교체 | `83f1115` |

## 3. 2026-10-27 — 뉴스 토픽 0건 장애

| 시각(커밋 시각, 07:59만 기록 시각) | 사실 | 근거 |
|---|---|---|
| 10-27 06:00 | 브리핑 뉴스 토픽 7개가 0건, 복지·정책만 게시 | BACKLOG-done.md |
| 원인 | `application.yml`에 `picks:` 블록(들여쓰기 2칸, `brief` 아래)이 `sources.onpocket`과 `rss:` 사이에 끼어, 뒤따르던 `rss:`가 `brief.picks` 아래로 붙음 → `brief.sources.rss` 바인딩이 빔 | `6b50db9` diff |
| 07:55 | picks 블록을 sources 밖(reader 앞)으로 이동 + `RssFeedPropertiesBindingTest`(application.yml을 Binder로 읽어 뉴스 토픽 피드가 비어 있지 않은지 검사) | `6b50db9` |
| 07:59 | 오늘자 브리핑 재게시 | BACKLOG-done.md |
| 08:00 | `DigestGraph.initialQueries`: RSS 토픽의 피드 목록이 비면 `error(...)` — 조용한 0건 대신 실패로 배치 알림 | `403935a` |
| 09:23 | 앱: 오늘 브리핑은 항상 서버에서 읽기(지난 날짜만 캐시 우선) — 같은 날 재게시가 이미 받은 기기에 반영되지 않던 문제, 0.1.1+9 | `9af12b0` |
| 같은 날 | 0.1.1 승인 완료로 새 빌드 제출 불가 → 0.1.2+9 | `507bc30` |

## 4. 2026-10-28 ~ 10-29 — iOS 푸시, 맞춤 정보 화면

| 날짜 | 사실 | 근거 |
|---|---|---|
| 10-28 | 브리핑 맨 위로 버튼, 0.1.2 승인 완료로 0.1.3+10 | `670f806` `7ac6590` |
| 10-28 | Firebase 콘솔에 APNs 인증 키 등록, FCM 단건 테스트 iPhone 수신 확인. 그 전 10-22~10-28 07:00 발송은 iOS에서 `THIRD_PARTY_AUTH_ERROR` | `4224aa6`, BACKLOG.md P0 |
| 10-29 | iOS 상태 표시줄 탭으로 맨 위로(PrimaryScrollController), 0.1.4+11 | `d571e0b` |
| 10-29 | 맞춤 정보 화면(브리핑 머리 아래 카드, 새·D-n, 미연결 안내, 맞춤 알림 탭 → 맞춤 화면), 0.1.5+12. 하단 탭 바가 없어 카드로 진입 | `2a2f4a1`, progress.md |
| 10-29 | firestore.rules picks 규칙 운영 배포(본인 읽기·삭제만, 쓰기는 배치) | `4f6428f` |
| 10-29 | 맞춤 정보 캐시: KST 07:10 이후 하루 한 번만 서버, 당겨서 새로고침은 서버, 0.1.6+13 | `90fbbd0` |
| 10-29 | 맞춤 화면이 BriefScreen을 재사용(읽음·스크랩·덜 보기·맨 위로), 상세는 온포켓 공개 본문(마크다운 → HTML)을 앱 안 읽기 화면으로, 0.1.7+14 | `45cb5a9` |
| 10-29 | 맞춤 섹션을 앱이 태그로 분류하던 방식 → 온포켓이 준 대표 주제(category·categoryLabel·categoryOrder)로. 앱의 분류표·규칙 제거, 0.1.9+16 | `cc9af93` `f07c6a2` `2d6d259` |

## 5. 2026-10-30 ~ 11-01 — 앱 안 온포켓 화면, 1.0.0

| 날짜 | 사실 | 근거 |
|---|---|---|
| 10-30 | 배치: 브리핑 게시 뒤 온포켓 피드(전날 06:00 KST 이후 공개분, limit 200)를 `onpocket/{date}`에 저장(제목·200자 설명·링크·분류, 본문 없음), 30일 보관. 피드 실패면 기존 목록을 덮지 않음. morningBriefJob = digest → publish → onpocket → claims | `dd1c29c`, progress.md |
| 10-30 | 앱: 온포켓 뉴스 화면(날짜별 목록·맞춤·지난 온포켓), BriefScreen 재사용, 0.2.0+17 | `dd691ef` |
| 10-30 | 앱 안 온포켓 맞춤 설정(관심 주제·지역·내 상황·받기 동의). 소셜 ID 토큰 → 온포켓 JWT(기기 메모리만). 새 의존성 sign_in_with_apple(Firebase Apple 로그인 결과로는 identityToken을 꺼낼 수 없음), 0.2.0+18 | `29d1e40`, progress.md |
| 10-30 | 전환 중 뒤로 화살표가 보였다 사라지던 것, 로그인 취소·웹 가입 뒤 이어서, 1.0.0+19, Play 1.0.0 소개글 | `28ae7a6` |
| 10-31 | 전환 애니메이션 중 목록 교체로 생기던 멈춤 → 전환 뒤 교체. 앱 복귀 시 날짜가 바뀌었으면 브리핑 다시 받기. `Navigator.canPop()` → `ModalRoute.isFirst`. 상세 가로 넘침(공백 없는 긴 URL) → `overflow-wrap: anywhere`, 390px 헤드리스로 7건 넘침 → 0건 | progress.md(1.0.0+20~22) |
| 11-01 | 온포켓 칩 한 줄(맞춤·마감 임박·대표 주제, 의도 필터 제거 — 8일치 121건 중 신청·신고 82%), 관심 지역(최대 3)·목록 지역 필터, 1.0.0+23 | `8aaba35`, progress.md |
| 11-01 | App Store가 승인된 1.0.0 트레인에 새 빌드를 받지 않음(90186) → 1.0.1+24 | `797757a` |

## 6. 2026-11-02 ~ 11-06 — 수신 시각, 업데이트 안내, 보안 토픽, H2

| 날짜 | 사실 | 근거 |
|---|---|---|
| 11-02 | 알림 수신 시각별 발송: notifyJob `slot` 파라미터(기본 07:00), 배치 허브에 07:00·06:30·07:30·08:00 작업. 계기: 06:30을 고른 사용자에게 07:00에 알림. 당시 06:30 1명·07:00 8명 | `dc00436` `4120d3a`, BACKLOG.md |
| 11-02 | 온포켓 오늘 화면: 날짜로 끊지 않고 최근 30일 중 안 읽은 글, 읽은 글은 메인에서 빠짐, 1.0.2+25 | `cfb6515` |
| 11-02 | 배치: 온포켓 대표 주제 전체(`GET /public/categories`, 13개)를 `onpocket/{date}.categories`로 함께 저장, 실패해도 목록은 저장. 앱은 빈 주제도 섹션 | `c5cf392` `3d20ce5` |
| 11-02 | 칩 색(주제별)·글 있는 주제 먼저, 오프라인이면 "소식이 없어요" 대신 오류·다시 시도 | progress.md, `58eac93` |
| 11-03 | 업데이트 안내: Android Play 인앱 업데이트(flexible), iOS App Store lookup 버전 비교. 의존성 in_app_update·package_info_plus. lookup 응답 App Store 현재 1.0.4 → 1.0.5+27 | `58eac93` `6ac7ef8`, progress.md |
| 11-04 | 보안 토픽 신설(보안뉴스·데일리시큐·KISA 보호나라 RSS, min 2·max 4), IT·AI 하루 최대 5 → 7건. 날짜만 있는 pubDate는 KST 정오로(0시면 전날 공지가 24시간 창에서 빠짐). 앱은 보안 색만 추가 | `9fc8cd4` `5f748d8` |
| 11-06 | Docker가 필요하던 DB 테스트 3개 Testcontainers → H2(PostgreSQL 모드). 회원 upsert를 `ON CONFLICT … RETURNING` → UPDATE 후 0건이면 INSERT. Mockito null 매처 NPE 수정. `./gradlew check` 58개 전부 통과 | `652b2c3`, progress.md |

## 7. 2026-11-14 — 스토어 정비

| 날짜 | 사실 | 근거 |
|---|---|---|
| 11-14 | Play 빌드 27(1.0.5) 출시를 Play Console 화면으로 확인(콘솔 표시 "11월 2일 오후 8:30"). 트랙은 기록에 없음 | `2d0b191` |
| 11-14 | 스토어 스크린샷 재촬영 6장(가상 브리핑·온포켓 샘플 `integration_test/store_sample.dart`, 온포켓·보안 포함), TestFlight·Play 비공개 테스트 자동 업로드 스크립트(키 없어 실제 업로드는 아직) | `778569e`, progress.md |
| 11-14 | 백로그: App Store 1.0.5는 "배포 준비됨"이라 스크린샷 교체 불가 → 1.0.6 때 스크린샷·보안 칩 색 함께 | `b394843` |

## 8. 기준일 현재 열린 항목(BACKLOG.md 발췌)

- 푸시 탭 시 데이터의 date 브리핑 열기, 피드백 기반 사용자별 정렬, 열람 이벤트 읽음 처리
- 클라우드 이전(Cloud Run Jobs, LLM API 키 전환), 운영자 실패 알림
- 출시 전 법적 검토 메모 항목(뉴스 라이선스·RSS 약관, 개인정보처리방침·해외 이전 고지)
