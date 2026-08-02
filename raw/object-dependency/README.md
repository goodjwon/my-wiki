# object-dependency — 객체 의존성·ID 참조 설계

블로그 글 [객체 참조의 덫을 깨다: ID 참조와 이벤트로 진화하는 의존성 설계](https://blog.wonslab.dev/2026-07-19-object-dependency-id-reference/)에서 추출한 영속 개념 소스 노트 모음. 원 트리거 영상은 조영호의 "우아한객체지향: 의존성을 이용해 설계 진화시키기"(우아한테크세미나, 2019, https://www.youtube.com/watch?v=dJ5C4qRqAgA).

트렌드성 발행 글의 본문 서사(성능 병목 사례·측정 수치)는 제외하고, 다른 글·작업에서 재참조할 **영속 개념**만 소스 노트로 남겼다.

## 자료 구성

| 파일 | 개념 | 한 줄 요약 |
|------|------|-----------|
| `id-reference-vs-object-reference.md` | ID 참조 vs 객체 참조 | 애그리거트 경계를 넘는 협력은 객체 참조 대신 식별자(ID)로 연결해 트랜잭션 경계 번짐을 막는다 |
| `aggregate-boundary-lifecycle.md` | 애그리거트 경계 | 함께 생성·삭제되는 데이터는 한 애그리거트, 독립 라이프사이클은 분리 — 경계를 라이프사이클로 긋는다 |
| `domain-event-eventual-consistency.md` | 도메인 이벤트·최종 일관성 | ID 참조로 끊긴 트랜잭션 연쇄를 도메인 이벤트 구독으로 이어 최종 일관성으로 수렴시킨다 |

## 읽기 순서

1. `id-reference-vs-object-reference.md` — 왜 객체 참조를 끊는가(문제)
2. `aggregate-boundary-lifecycle.md` — 어디서 끊는가(경계 기준)
3. `domain-event-eventual-consistency.md` — 끊은 뒤 협력은 어떻게(해법)

## 비고

- 이 디렉터리는 **원본 소스(raw) 층**이다. 여기 노트는 개념 요약 + 출처만 담은 소스 노트이며, `wiki/` 페이지로의 승격(concept-* 생성·교차참조·비교표)은 위키 세션 몫이다.
- 기존 `raw/object/`(오브젝트 실전 강의 교재)와 별개 소스 — 이쪽은 블로그 글 유래라 디렉터리를 분리했다.
