---
title: Effective Java 12장 핵심 요약 (모찌모찝 블로그)
type: source
tags: [book, java, effective-java, summary]
sources: [effective_java/개발서적 이펙티브 자바(Effective Java) 핵심 요약 및 정리 - 조슈아 블로크.md]
external:
  - https://mozzi-devlog.tistory.com/88
created: 2026-06-20
updated: 2026-06-20
---

# Effective Java 12장 한 페이지 요약 (블로그 클리핑)

## 출처

| 항목 | 값 |
|------|----|
| 원본 글 | https://mozzi-devlog.tistory.com/88 |
| 저자 | 모찌모찝 |
| 게시 | 2025-07-31 |
| raw 보관 | `raw/effective_java/개발서적 이펙티브 자바(Effective Java) 핵심 요약 및 정리 - 조슈아 블로크.md` |
| 참고 | https://ekis.github.io/effective-java-3rd-edition (영문 사본) |

[[entity-effective-java]] 책 카드의 부속 요약 페이지. 풀 텍스트로 보려면 [[src-effective-java-lecture]] (강의 교재 11장 인덱스).

## 12장 한 줄 요약

| 장 | 한 줄 |
|----|------|
| 1. 시작하며 | 명확·예측 가능·유지보수 편한 코드 — 90개 "아이템"으로 정리 |
| 2. 객체 생성과 소멸 | **new 대신 정적 팩터리·빌더**, 캐싱, **try-with-resources** 자원 관리, 싱글턴은 **enum** |
| 3. 모든 객체의 공통 메서드 | `equals`+`hashCode` **함께** 재정의, `toString` 의미 있게, `Comparable` 구현 |
| 4. 클래스와 인터페이스 | 필드 `private`, **불변 객체** 우선, **상속보다 컴포지션**, **인터페이스 우선** |
| 5. 제네릭 | **Raw Type 금지**, 와일드카드 `? extends`/`? super`, 제네릭+배열 혼용 주의 |
| 6. Enum과 Annotation | 상수는 **enum**, EnumSet/EnumMap, 명명 패턴 대신 **애너테이션** |
| 7. 람다와 스트림 | 익명 클래스 → **람다 → 메서드 참조**, 스트림은 단방향·불변성 주의 |
| 8. 메서드 | **단일 책임**, varargs 신중, API·반환값 견고·이해 쉽게 |
| 9. 일반 기법 | 지역변수 최소화, **for-each** 우선, float/double 금지, **표준 라이브러리** 우선 |
| 10. 예외 처리 | 예외는 **예외 상황만**, checked vs unchecked 구분, 원인 기록·문서화 |
| 11. 동시성 | 동기화·**불변 객체**, Atomic, ThreadLocal/volatile, **표준 라이브러리 우선** |
| 12. 직렬화 | **불필요한 직렬화 피해라**, 필수면 커스텀 + transient |

## 키포인트 (블로그 결론)

- *Effective Java* 는 자바를 **'실제로 더 잘 사용하기 위한'** 실용적 조언 모음
- 모든 조언이 JDK·국제 표준·대규모 실무에서 검증된 원칙
- 각 챕터/아이템을 한 번 익힌 뒤, 코드 짤 때마다 곁에 두고 참조

## 같은 주제 다른 자료

| 자료 | 어디서 보강되나 |
|------|-----------------|
| [[src-effective-java-lecture]] | 같은 12장을 강의용으로 자세히 (총 3,500+줄) — 비유·코드·Spring/JPA 연결·체크리스트·퀴즈 |
| [[entity-effective-java]] | 책 카드 + 90 아이템 인덱스 + ⭐ 현업 최핵심 20개 |
| 영문 사본 | https://ekis.github.io/effective-java-3rd-edition |

## 관련 페이지

- [[entity-effective-java]] — 책 카드 (상위)
- [[src-effective-java-lecture]] — 강의 교재 본문 (더 깊이)
- [[entity-object]] — *오브젝트* (같은 OO 설계 주제, 다른 관점)
