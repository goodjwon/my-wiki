# gather (언제볼래) — 자료 인덱스

> 원본 위치: 비공개 앱 저장소 `gather-project`(로컬 `~/VsCodeProjects/gather-project`). 조회 기준일 2026-11-19.
> 읽은 원본: README.md, docs/requirements.md(기획 요구사항), docs/release/NEXT.md·APP_STORE_CONNECT.md·PLAY_CONSOLE.md·TESTFLIGHT.md,
> functions/src(domain.ts·app.ts·store.ts), clients/openapi.json·generate.sh, `git log`(커밋 86개, 2026-11-07 ~ 2026-11-14).
> 공개 위키용 원본이라 GCP 프로젝트 ID, 서비스 계정, 키 파일 경로, 계정 메일은 일부러 넣지 않았다.

링크 하나로 단톡방에서 "언제·어디서·뭐 먹을지"를 정하는 서비스. 주최자는 Flutter 앱으로 모임을 만들고, 참여자는 설치·가입 없이 웹 링크에서 답한다. 서버는 Cloud Functions(TypeScript) 한 곳이 도메인 규칙을 모두 갖는다.

| 파일 | 내용 |
|---|---|
| `TIMELINE.md` | git log 기반 날짜별 사실(2026-11-07 착수 ~ 2026-11-19 App Store 기록) |
| `TECH_NOTES.md` | 구조·도메인 모델·날짜 점수·API 계약·저장 설계의 사실 요약 |

연관 원본: `raw/app-release-ship/README.md` — 언제볼래를 포함한 앱 3개의 배포 자동화(`/ship`) 메모. 이 앱 저장소의 `scripts/upload-testflight.sh`·`scripts/upload-play.sh`(2026-11-12~13)가 그 이전 단계의 앱 단위 업로드 스크립트다.

## 상태 기록의 출처 주의

- 2026-11-14 커밋 `7abc6af` 기준: App Store 1.0.0(6) "심사 대기 중"(2.1 정보 요청 대응 후 재제출).
- 2026-11-19: APP_STORE_CONNECT.md 변경 이력에 "중국 판매 때문에 배포가 막혀 중국을 해지 → 한국만 판매, 출시 확인(배포 준비됨 = 라이브)" 행이 추가돼 있다. **이 행은 조회 시점에 커밋되지 않은 작업 트리 변경**이다.
- Google Play: NEXT.md(2026-11-13) 기준 1.0.0(5)가 비공개 테스트 트랙, 1.0.0(10) 업로드 대기.
