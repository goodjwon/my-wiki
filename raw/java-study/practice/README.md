# Java·Spring 실습 과제 — 원본 추적 (비공개 층)

위키 실습 과제 3편의 소재가 된 저장소. **독자 콘텐츠에는 저장소명·고유명사를 노출하지 않는다** (2026-07-03 결정 유지, 2026-09-28 사용자 요청: 고유명사 회피 + 패키지 `dev.wonslab` 통일).
과제 페이지는 저장소 코드를 학습 크기로 축약·재작성한 자족형이며, 원본은 참조만 했다(원본 저장소 무변경).

| 위키 페이지 | 원본 저장소 | 기준 커밋 (2026-09-28 클론) | 원본 구성 |
|-------------|-------------|------------------------------|-----------|
| `wiki/guide-java-practice-core.md` | https://github.com/goodjwon/day-by-java | `f3cedbd` | 장별 예제 ch2~ch7 (컬렉션·IoC·디자인 패턴·Spring Security JWT), Maven |
| `wiki/guide-java-practice-spring-library.md` | https://github.com/goodjwon/day_by_spring | `cab90d7` | 도서관 시스템 (Spring Boot 3.5.5, JPA, H2 프로파일, SpringDoc), Maven |
| `wiki/guide-java-practice-layered-quotation.md` | https://github.com/goodjwon/s2b-prototype-orm | `b7e2290` | 조달 업무 교육용 (4계층 + Command/Query + MyBatis, H2), Gradle KTS |

- 패키지 교체: `com.example.*`, `kr.s2b.*` → `dev.wonslab.*`
- 검증: 과제 페이지의 코드 블록만으로 프로젝트를 새로 만들어 테스트·H2 실행·스크린샷까지 실측 (2026-09-28).

## 모범 답안 소스 보관 (2026-09-28)

검증에 쓴 프로젝트를 각 원본 저장소의 별도 브랜치 `wiki-practice-2026-09-28` 의 `practice/` 폴더에 커밋·푸시했고, 사용자 허용으로 각 저장소 main에도 fast-forward 반영했다(2026-09-28).

| 과제 | 저장소 · 경로 | 커밋 |
|------|---------------|------|
| 과제 1 | day-by-java · `practice/order-console/` | `ff82a51` |
| 과제 2 | day_by_spring · `practice/library-api/` (Boot 4.1.1) | `8a993a4` |
| 과제 3 | s2b-prototype-orm · `practice/quotation-layered/` (Boot 4.1.1 + MyBatis 4.1.0) | `38c3d59` |

## 과제 2-2·2-3 추가 (2026-09-29)

| 위키 페이지 | 원본 저장소 | 기준 커밋 | 비고 |
|-------------|-------------|-----------|------|
| `wiki/guide-java-practice-library-ui.md` | https://github.com/goodjwon/day_by_spring_sm_ui (비공개) | `9f0a0b6` | React 19 + Vite + TS + Tailwind UI를 과제 2 API 범위로 축약. 원본 `.env.production`(시크릿 포함)은 사용하지 않음 |
| `wiki/guide-java-practice-library-merge.md` | 위 UI + day_by_spring | — | API 추가 `GET /api/members/{id}/loans`, Vite 프록시·CORS·Playwright·한 jar 배포 |

모범 답안 소스 보관 (2026-09-29, main에 커밋·푸시):
- 과제 2-2: day_by_spring_sm_ui · `practice/library-ui/` — `6a11200`
- 과제 2-3: day_by_spring · `practice/library-fullstack/` (API `library/` + 화면 `library-ui/`) — `a111b34`
