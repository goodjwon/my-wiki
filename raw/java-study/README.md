# Java 스터디 — 원본 교재 (raw)

2024~2025 Notion 스터디 원본 모음. 위키 게시본은 `wiki/guide-java-learning-path.md`(3단계 로드맵)에서 학습 순서로 읽는다.

## 자료 구성

- `java-study-chNN-주제.md` (12편) — 챕터 본문 원본. **번호 `NN`은 학습 순서**(= 위키 게시본 `wiki/java-study-chNN.md`와 동일)로 재정렬돼 있다.
- `java-study-notion-db-catalog.md` — Notion DB 카탈로그 (원본 문서 목록)
- `java-study-refresh-checklist.md` — 원본 갱신 체크리스트

## 챕터 순서 (= 학습 순서)

번호순으로 읽으면 "언어 → 프레임워크 → 고급"으로 이어진다.

### 1단계 — Java Core (순수 언어)

| 파일 | 주제 |
|------|------|
| `java-study-ch00-안내.md` | 안내 |
| `java-study-ch01-환경과실행.md` | 환경과 실행 |
| `java-study-ch02-Java문법과객체.md` | Java 문법과 객체 |
| `java-study-ch03-컬렉션과함수형.md` | 컬렉션과 함수형 |
| `java-study-ch04-객체지향설계와패턴.md` | 객체지향 설계와 패턴 |
| `java-study-ch05-입출력과네트워크.md` | 입출력과 네트워크 |

### 2단계 — Spring & 웹 백엔드

| 파일 | 주제 |
|------|------|
| `java-study-ch06-Spring과프로젝트실행.md` | Spring과 프로젝트 실행 |
| `java-study-ch07-데이터접근과SQL.md` | 데이터 접근과 SQL |
| `java-study-ch08-서버와인증.md` | 서버와 인증 |

### 3단계 — 고급·품질

| 파일 | 주제 |
|------|------|
| `java-study-ch09-테스트와품질.md` | 테스트와 품질 |
| `java-study-ch10-JVM과성능.md` | JVM과 성능 |
| `java-study-ch11-부록.md` | 부록 |

## 원본 교재(Notion) 장번호 매핑 (추적용)

학습 순서로 재정렬하면서 일부 챕터 번호가 Notion 원본과 달라졌다. 원본 대조가 필요할 때 참고한다.

| 현재 번호 | 주제 | Notion 원본 장 |
|----------|------|---------------|
| ch00~ch04 | 안내·환경·문법·컬렉션·객체지향설계 | 0~4 (동일) |
| **ch05** | 입출력과 네트워크 | **원본 10장** |
| **ch06** | Spring과 프로젝트 실행 | 원본 5장 |
| **ch07** | 데이터 접근과 SQL | 원본 6장 |
| **ch08** | 서버와 인증 | 원본 7장 |
| **ch09** | 테스트와 품질 | 원본 8장 |
| **ch10** | JVM과 성능 | 원본 9장 |
| ch11 | 부록 | 11 (동일) |

> 입출력/네트워크는 순수 Java에 속하므로 학습상 Core(1단계) 마지막으로 당겼고(원본 10장 → ch05), 그만큼 원본 5~9장(Spring~JVM)이 한 칸씩 뒤로 밀렸다.

## 위키 게시본

각 raw 파일은 위키 `java-study-chNN.md`로 게시되며, 본문의 "다음 장" 링크가 번호순(ch00 → ch01 → … → ch11)으로 이어진다. 전체 흐름과 트랙(미니프로젝트 동선)은 `wiki/guide-java-learning-path.md` 참조.
