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
