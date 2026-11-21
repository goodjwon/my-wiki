# dongne-climate — 자료 인덱스

동네기후(local-climate) 앱의 개발 기록 원본 노트. 앱 ID `dev.wonslab.local.climate`.
"오늘 날씨, 원래 이랬나?"에 답하려고 오늘 날씨를 최근 10년 같은 날짜와 비교하는 1인 개발 앱이다.

> 원본 위치: 앱 저장소 `~/VsCodeProjects/wonrae`(GitHub goodjwon/local-climate, 루트 폴더명만 옛 이름 유지).
> 조회 기준일: 2026-11-19, 기준 커밋 `16dc1d1`(2026-11-18). 이 디렉터리는 공개 가능한 사실만 옮긴 요약이며,
> 설계 문서 원본(docs/00~10, domain.md)은 앱 저장소가 유일한 정본이다.

## 자료 구성

| 파일 | 내용 |
|---|---|
| `TIMELINE.md` | git log 기반 날짜별 사실(2026-11-15 ~ 11-18, 36커밋)과 출시 상태 |
| `TECH_NOTES.md` | 구조·데이터 흐름·도메인 규칙·결정 기록(앱 저장소 docs/00·03·08·domain.md, 커밋 본문 발췌) |

## 앱 저장소에서 참조한 파일

- `README.md`, `CLAUDE.md` — 앱 개요, 원칙, 운영 체크리스트, 앱 배포(TestFlight) 절
- `docs/00-design-summary.md` — 동기 2개, 핵심 결정 표, 데이터 소스
- `docs/03-architecture.md` — 구성 요소, batch-hub 실행, Firestore 설계, Hosting 경로
- `docs/domain.md` — 도메인 모델(SkyJudge·NormalCalculator·Deviation·YearStats 등)과 규칙
- `docs/07-color-and-message.md` — 기후 줄무늬 색, 환경 메시지 순서
- `docs/08-open-decisions.md` — 확정·미확정 결정
- `local-climate-app/build/store-screens/*.png` — 스토어 스크린샷(실데이터, 2026-11-19 09:38 생성, 생성 스크립트 `tools/store-screens.sh`는 기준일 현재 미커밋)
