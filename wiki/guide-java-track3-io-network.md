---
title: "Java 학습 경로 T3 — 입출력과 네트워크"
type: synthesis
tags: [java, study, learning-path, track3, io, network, exception]
sources: [java-study/]
created: 2026-06-29
updated: 2026-06-29
---

# Java 학습 경로 T3 — 입출력과 네트워크

> **이 트랙의 목표**: 프로그램이 바깥 세계(파일·네트워크·DB)와 주고받는 법을 익힌다. 핵심은 **예외를 숨기지 않고 다루는 것** — 입출력은 항상 실패할 수 있기 때문이다.
>
> **선수 트랙**: [[guide-java-track2-design]]. **다음 트랙**: [[guide-java-track4-spring-web]].

이 트랙은 [[src-java-study-2024-2025]] 10장 재구성. **실제 학습·실습은 챕터 레슨에서 따라 한다** → [[java-study-ch05]].

> 이 페이지는 **코스 안내**다(흐름·핵심·미니프로젝트·이론 팁). 코드와 상세 설명은 위 챕터 레슨을 펴고 따라 하면 된다.

---

## 📚 학습 순서 (ch10)

| 순서 | 문서 | 한 줄 |
|------|------|------|
| 5.0 | 입출력과 네트워크 개요 | 바깥 세계와의 경계는 늘 실패 가능 |
| 5.1 | Java 예외 종류 정리 | Checked vs Unchecked, 언제 무엇을 |
| 5.2 | 예외와 사용자 정의 예외 | 의미 있는 예외로 도메인 표현 |
| 5.3 / 5.4 | 파일 읽기·쓰기, 여러 형식 처리 | try-with-resources로 자원 닫기 |
| 5.5 | 네트워크 프로그래밍 기초 | 소켓, 클라이언트-서버 |
| 5.6 | JDBC 기초 | DB와 직접 대화 (T4에서 추상화) |
| 5.7 | 파일 처리 설계 실습 | 🛠 워밍업 |
| 5.8 / 5.9 | 파일 처리 실전문제 | 🛠 아래 미니프로젝트 |

---

## 🧩 핵심 개념 한눈에

| 개념 | 한 줄 정의 | 자주 하는 실수 |
|------|----------|--------------|
| Checked 예외 | 컴파일러가 처리를 강제 | 무의미한 `throws Exception` 전파 |
| Unchecked 예외 | 런타임 (프로그래밍 오류) | 잡아서 무시(silent fail) |
| try-with-resources | 자원 자동 닫기 | `finally`에서 수동 close 누락 |
| 사용자 정의 예외 | 도메인 의미를 타입으로 | 문자열 메시지로만 구분 |
| HOL 블로킹 | 앞선 요청이 뒤를 막음 | HTTP 버전 진화의 핵심 동인 |

---

## 💡 이론·방법론 연결 (팁)

> 💡 **예외 — "빈 catch는 거짓말"**
> 입출력은 실패가 정상이다. 잡아서 삼키면 디버깅 지옥이 된다. 의미 있는 예외로 바꿔 던지거나 로깅하라.
> → 자세히: [[entity-effective-java]] (Item 69~77, 예외) · [[concept-transactional-rollback-policy]] (예외와 롤백)

> 💡 **자원 — try-with-resources를 기본값으로**
> 파일·소켓·커넥션은 반드시 닫아야 한다. `try (var in = ...)` 형태가 누락을 원천 차단한다.
> → 자세히: [[lecture-clean-code-ch8]] (경계) · [[entity-effective-java]] (Item 9)

> 💡 **네트워크 — 왜 HTTP는 계속 진화했나**
> 5.5 소켓을 배우면 "왜 Keep-Alive·멀티플렉싱·QUIC이 나왔나"가 보인다. HOL 블로킹이 그 출발점.
> → 자세히: [[concept-http-hol-blocking]] · [[concept-keepalive-timeout-race]]

> 💡 **방법론 — 실전문제는 경계 테스트부터**
> 파일 처리는 "빈 파일·없는 파일·깨진 형식"이 진짜 난이도. 정상 케이스보다 경계부터 테스트로 박아라.
> → 자세히: [[lecture-tdd-ch4]] · [[entity-tdd]]

---

## 🛠 미니프로젝트 — 파일 처리 시스템

1. **파일 처리 실전문제 1 (5.8)** — 텍스트 파일 읽어 가공·저장. 예외·자원 닫기를 정석으로.
2. **형식별 파일 처리 (5.9)** — CSV·JSON 등 형식별 분기를 전략 패턴(T2)으로 깔끔하게.
3. **오프라인 게임 파일 처리 시스템 (11.9)** — 세이브/로드를 파일로. 손상 파일 복구 시나리오까지.

**따라하는 법**:
```text
1) 입력 경계 정의: 빈 파일·없는 파일·잘못된 형식 케이스 나열
2) 각 경계마다 실패 테스트 (TDD 빨강)
3) try-with-resources로 정상 경로 구현 (초록)
4) 예외를 사용자 정의 예외로 의미화 (리팩터)
5) 형식 분기는 전략 패턴으로 분리 (T2 복습)
```
실습 본문·풀이 → [[java-study-ch05]](5.8·5.9) · [[java-study-ch11]](11.9).

---

## ✅ 트랙 정리 체크리스트

- [ ] Checked/Unchecked 예외를 상황에 맞게 고른다
- [ ] try-with-resources로 자원 누수를 막는다
- [ ] 의미 있는 사용자 정의 예외를 설계한다
- [ ] 소켓 기반 클라이언트-서버를 한 번 만들어봤다
- [ ] HTTP가 왜 진화했는지(HOL) 설명할 수 있다
- [ ] 🛠 파일 처리 미니프로젝트를 경계 테스트부터 완성했다

→ 다 체크되면 **[[guide-java-track4-spring-web]]**(Spring 웹 애플리케이션)로.

---

## 관련 페이지

- [[src-java-study-2024-2025]] — 원본 교재 (전체 카탈로그)
- [[concept-http-hol-blocking]] · [[concept-keepalive-timeout-race]] — 네트워크 진화
- [[entity-effective-java]] — 예외·자원 관리 디테일
- [[lecture-clean-code-ch8]] — 경계(boundary) 다루기
- [[guide-java-track2-design]] · [[guide-java-track4-spring-web]] — 이전·다음 트랙
