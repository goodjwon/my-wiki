---
title: "Java 학습 경로 — 3단계 로드맵 (Core → Spring → 고급)"
type: synthesis
tags: [java, study, learning-path, curriculum, index]
sources: [java-study/]
created: 2026-06-29
updated: 2026-09-28
---

# Java 학습 경로 — 3단계 로드맵

> [[src-java-study-2024-2025]]의 원본 교재를 **"언어 → 프레임워크 → 고급"** 세 단계로 재구성했습니다. 앞 단계가 뒷 단계의 전제이므로 [[java-study-ch00]]의 안내부터 순서대로 따라갑니다.

**역할 구분**: 챕터는 주제별 본문(찾아보기·순서대로 읽기 모두 가능)이고, 트랙은 같은 내용을 손에 익히는 실습 중심 학습 동선입니다.

**학습 원칙**: 문법을 외우는 게 아니라 **왜 그렇게 동작하는지 설명**할 수 있는 상태를 목표로 합니다. 각 트랙 끝의 실습으로 굳히고, 실습은 빨강→초록→리팩터(TDD) 흐름으로 진행합니다.

---

## 🗺️ 단계 ↔ 챕터 ↔ 트랙 ↔ 마무리 실습

| 단계 | 챕터 | 트랙(학습 코스) | 마무리 실습(과제) |
|------|------|----------------|------------------|
| 1단계 Java Core | [[java-study-ch01]] 환경과 실행 · [[java-study-ch02]] Java 문법과 객체 · [[java-study-ch03]] 컬렉션과 함수형 | [[guide-java-track1-basics]] | 챕터 실전문제 (2.9·3.8) |
| 1단계 Java Core | [[java-study-ch04]] 객체지향 설계와 패턴 | [[guide-java-track2-design]] | 🧪 [[guide-java-practice-core]] |
| 1단계 Java Core | [[java-study-ch05]] 입출력과 네트워크 | [[guide-java-track3-io-network]] | 챕터 실전문제 (5.8·5.9) |
| 2단계 Spring & 웹 | [[java-study-ch06]] Spring과 프로젝트 실행 · [[java-study-ch07]] 데이터 접근과 SQL · [[java-study-ch08]] 서버와 인증 (+ [[java-study-ch09]] 테스트와 품질) | [[guide-java-track4-spring-web]] | 🧪 [[guide-java-practice-spring-library]] |
| 3단계 고급·품질 | [[java-study-ch09]] 테스트와 품질 · [[java-study-ch10]] JVM과 성능 · [[java-study-ch11]] 부록 | [[guide-java-track5-deep-dive]] | 🧪 [[guide-java-practice-layered-quotation]] |

T4는 Spring과 함께 테스트(ch09)를 다루므로 괄호 안 챕터는 3단계 소속이지만 T4에서 먼저 만납니다.

---

## 원본·관련 페이지

- [[src-java-study-2024-2025]] — 원본 교재 (97개 문서 전체 카탈로그)
- 방법론: [[guide-code-authoring-and-review]] · [[entity-tdd]] · [[entity-refactoring]] · [[entity-object]] · [[entity-effective-java]] · [[entity-clean-code]]
- 레퍼런스: 챕터에서 만난 주제를 더 깊이 팔 때는 개념([[concept-spring-core]]·[[concept-transactional-rollback-policy]])과 도구([[entity-spring-boot]]·[[entity-jvm]]) 페이지를 찾아봅니다.
