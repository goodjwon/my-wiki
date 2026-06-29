---
title: "Java 학습 경로 — 전체 지도 (기초→Spring→실전)"
type: synthesis
tags: [java, study, learning-path, curriculum, index]
sources: [java-study/]
created: 2026-06-29
updated: 2026-06-29
---

# Java 학습 경로 — 전체 지도

> [[src-java-study-2024-2025]]의 97개 문서를 **구독자가 위에서 아래로 따라가며 배우는 5개 트랙**으로 재구성했다. 각 트랙은 *개요 → 학습 순서 → 핵심 개념 → 💡 이론·방법론 팁 → 🛠 미니프로젝트 → 정리* 순서로, 읽고 바로 손으로 따라 할 수 있게 짰다.

**학습 원칙**: 문법을 외우는 게 아니라 **왜 그렇게 동작하는지 설명**할 수 있는 상태를 목표로. 각 트랙 끝의 🛠 미니프로젝트로 굳힌다.

---

## 🗺️ 5개 트랙

| 트랙 | 무엇을 | 묶은 챕터 | 🛠 미니프로젝트 |
|------|--------|----------|----------------|
| **[[guide-java-track1-basics]]** | Java 기초 다지기 | 1 환경 · 2 문법/객체 · 3 컬렉션/함수형 | 객체지향 실전·알고리즘 |
| **[[guide-java-track2-design]]** | 객체지향 설계로 응용 | 4 설계/패턴 · 9 JVM | 전략 패턴 리팩터링 |
| **[[guide-java-track3-io-network]]** | 입출력과 네트워크 | 10 예외/파일/네트워크 | 파일 처리 시스템 |
| **[[guide-java-track4-spring-web]]** | Spring 웹 애플리케이션 | 5 Spring · 6 데이터/SQL · 7 인증 · 8 테스트 | 도서 주문·대여 시스템 |
| **[[guide-java-track5-deep-dive]]** | 심화·워크북·종합 | 11 부록 (+9 워크북) | 종합 토이프로젝트 |

---

## 🧭 학습 흐름

```
T1 기초 ──> T2 설계 ──> T3 입출력 ──> T4 Spring ──> T5 실전
 (문법·OOP)  (패턴·JVM)   (예외·네트워크)  (웹·DB·인증·테스트)  (종합 프로젝트)
   │            │             │               │                  │
  🛠 OOP       🛠 전략패턴     🛠 파일처리      🛠 도서 주문/대여    🛠 토이 프로젝트
```

- **T1→T2→T3**는 순수 Java로 객체지향·예외까지. **T4**에서 Spring으로 웹을 만들고, **T5**에서 종합한다.
- 각 트랙은 앞 트랙을 전제로 한다. 건너뛰지 말고 체크리스트를 채우며 진행.

---

## 💡 이 경로의 특징

- **이론·방법론 연결**: 각 트랙에 💡 팁 박스로 위키의 5권 도서 강의([[entity-object]]·[[entity-effective-java]]·[[entity-refactoring]]·[[entity-clean-code]]·[[entity-tdd]])와 개념 페이지를 연결하고, "자세히 →" 링크로 바로 깊이 들어갈 수 있게 했다.
- **미니프로젝트 중심**: 모든 트랙이 🛠 실습으로 끝난다. 풀이 원문은 `raw/java-study/`에.
- **TDD 흐름 권장**: 미니프로젝트는 빨강→초록→리팩터로. 작은 단위 검증이 막힘을 줄인다.

---

## 원본·관련 페이지

- [[src-java-study-2024-2025]] — 원본 교재 (97개 문서 전체 카탈로그)
- 트랙: [[guide-java-track1-basics]] · [[guide-java-track2-design]] · [[guide-java-track3-io-network]] · [[guide-java-track4-spring-web]] · [[guide-java-track5-deep-dive]]
- 방법론: [[guide-code-authoring-and-review]] · [[entity-tdd]] · [[entity-refactoring]]
