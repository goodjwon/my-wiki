# 언제볼래 — 타임라인 (2026-11-07 ~ 2026-11-19)

> 원본: 비공개 저장소 gather-project의 `git log`(2026-11-19 조회)와 docs/release/*.md. 커밋 해시는 앞 7자리.
> 사실만 적는다. 해석은 wiki/src-gather.md.

| 날짜 | 사건 | 근거 |
|---|---|---|
| 2026-11-07 | 기획 요구사항 작성(최종 목표 "링크 하나로 3분 안에 확정"), 모노레포 초기 구성 + HTML 화면 데모 | requirements.md 머리, `0dccbc1` |
| 2026-11-07 | 데모: 장소는 주최자가 정하는 것이 기본, 참여자 대안 장소 추천(PLC-07) | `b67b156` |
| 2026-11-07 | MVP 구현: Spring Boot 3·Java 21 서버, React 웹, Flutter 앱, OpenAPI → TS·Dart 클라이언트 생성, 로컬 MongoDB·운영 Firestore | `1529649`(175 files) |
| 2026-11-07 | Cloud Run 서울 배포, CDS·지연 초기화로 콜드 스타트 단축 시도 | `7376fa0` |
| 2026-11-07 | GraalVM 네이티브 이미지 시도(로컬 기동 0.09초) → 빌드에 8GB 이상 들어 같은 날 철회, GitHub Actions + JVM 이미지로 | `b405bd6` `de40def` |
| 2026-11-07 | 디자인 규칙(데님·오트밀·브릭, Pretendard), 앱 아이콘 | `9b1470c` |
| 2026-11-08 | 공개 주소 gather.wonslab.dev, 웹 첫 화면을 소개·지원 페이지로, 처리방침 보강, 앱 1.0.0+2·+3 | `5c07433` `ecf98a5` `94a267d` `5f3a369` |
| 2026-11-09 | 응답 ID에서 기기 토큰 원문 제거(`{slug}_{sha256 22자}`), 옛 ID는 읽을 때 이전 | `c18a98e` `58e44b2` |
| 2026-11-09 | 저장소를 Firestore 하나로(MongoDB·Docker 제거) | `4b2a97c` |
| 2026-11-10 | 카톡 공유를 버튼 달린 카드 하나로(앱 SDK·웹 JS), 카카오 키는 빌드 때 주입, 앱 1.0.0+5 | `84df8db` `7b6794f` `ce521a6` |
| 2026-11-11 | 서버를 TypeScript Cloud Functions로 이전(이유: Cloud Run JVM 콜드 스타트 7~11초). 저장 문서·응답 JSON이 Java와 같음, 테스트 19개. `clients/openapi.json`을 손으로 고치는 계약으로 | `ed81fea` |
| 2026-11-11 | Java 서버·Cloud Run 정리 | `d14b710` |
| 2026-11-11 | Play 신규 등록(1.0.0(5) 비공개 테스트) 런북, iOS 아이폰 전용·1.0.0+6, App Store 첫 심사 제출 | `7fd1e51` `773a2a0` `97ba43e`, ASC 변경 이력 |
| 2026-11-12 | 날짜 콕콕 찍기(고른 날만, 1년·30개까지), 확정 전 후보 날짜 고치기(같은 링크), 불참 사유(RSP-08), TestFlight 7~10 | `3249442` `6e52515` `870cf8c` `c10f214` `c2bdeb1` |
| 2026-11-12 | TestFlight 업로드 스크립트 | `57d7e28` |
| 2026-11-13 | Play 터미널 업로드 스크립트, 이어받기 문서 NEXT.md | `c34b567` `7e06d24` |
| 2026-11-13 | 약속 분류 복수 선택(최대 3개), 확정 시각 표시, TestFlight 11 | `6eea53a` `c3d2aa6` `cfe5f3a` |
| 2026-11-14 | App Store 1.0.0(6) "Guideline 2.1 - Information Needed" 거절 → 실기기 녹화 + 영문 심사 메모로 회신·재제출, "1.0 심사 대기 중" | `ba26de2` `8f12d7c` `7abc6af` |
| 2026-11-19 | ASC 변경 이력(커밋 전): 중국 판매 때문에 배포가 막혀 중국 해지 → 한국만 판매, 출시 확인(배포 준비됨 = 라이브) | APP_STORE_CONNECT.md 작업 트리 |

## 숫자

| 항목 | 값 | 근거 |
|---|---|---|
| 커밋 | 86개(2026-11-07 ~ 11-14) | `git log --oneline \| wc -l` |
| API 경로 | 17개, OpenAPI 3.1.0 | clients/openapi.json |
| 함수 테스트 | domain.test.ts 17개 + api.test.ts 7개(`test(` 기준, 2026-11-19) | functions/test |
| 앱 빌드 | 1.0.0(2)~(11). 심사 제출은 (6), Play 비공개 테스트는 (5) | NEXT.md, 커밋 메시지 |
