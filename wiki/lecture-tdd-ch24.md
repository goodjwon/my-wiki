---
title: "TDD 실전 강의 — 24장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 24장.md]
created: 2026-06-20
updated: 2026-06-21
---

# 테스트 주도 개발 실전 강의 교재

## 24장 — xUnit 회고

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

- 2부 (18~23장) 통찰 정리.
- **자기 회귀** — 테스트 프레임워크가 자기 자신을 테스트.
- xUnit 코어를 JUnit 5 사용 경험과 연결한다.

---

## 2부 핵심 통찰

1. **단순한 추상화 6개** (TestCase·TestSuite·TestResult·run·setUp·tearDown) 가 xUnit 의 전부.
2. **컴포지트 패턴** — TestSuite + TestCase 가 같은 인터페이스.
3. **자기 회귀** — TDD 로 xUnit 만들면서 그 xUnit으로 자기 자신 테스트.
4. **JUnit·NUnit·PyUnit·MSTest** 모두 같은 코어 — Kent Beck 의 모델이 표준.

## 따라하기 — 2부 최종 코드가 해야 하는 일

2부를 끝낸 뒤 `testcase.py`는 최소한 다음 흐름을 설명할 수 있어야 한다.

```python
class TestCase:
    def __init__(self, name):
        self.name = name

    def run(self, result):
        result.testStarted()
        self.setUp()
        try:
            method = getattr(self, self.name)
            method()
        except Exception:
            result.testFailed()
        self.tearDown()

class TestSuite:
    def __init__(self):
        self.tests = []

    def add(self, test):
        self.tests.append(test)

    def run(self, result):
        for test in self.tests:
            test.run(result)
```

확인할 질문:

- `TestCase` 하나와 `TestSuite` 여러 개가 같은 `run(result)` 메시지를 받는가?
- 실패한 테스트가 있어도 다음 테스트가 계속 실행되는가?
- `setUp()`과 `tearDown()`이 테스트마다 한 번씩 실행되는가?

## 초보자용 복습 순서

| 순서 | 다시 볼 장 | 손으로 확인할 것 |
|------|------------|------------------|
| 1 | 18장 | 문자열 이름으로 메서드를 찾아 실행 |
| 2 | 19~20장 | `setUp`/`tearDown` 호출 순서 |
| 3 | 21~22장 | `TestResult`가 run/fail 카운트 집계 |
| 4 | 23장 | `TestSuite`가 여러 테스트를 같은 방식으로 실행 |
| 5 | 24장 | JUnit 5 어노테이션과 개념 매핑 |

---

## JUnit 5 매핑

| 책 | JUnit 5 |
|----|---------|
| `TestCase` | `@Test` 메서드 |
| `setUp()` | `@BeforeEach` |
| `tearDown()` | `@AfterEach` |
| `TestSuite` | `@Nested` 또는 `@Suite` |
| `TestResult` | `TestExecutionListener` |

## 체크리스트

- [ ] xUnit의 핵심 객체 3개(`TestCase`, `TestSuite`, `TestResult`)를 말할 수 있는가
- [ ] `setUp`/`tearDown`이 왜 테스트 독립성을 지키는지 설명할 수 있는가
- [ ] “테스트 프레임워크를 테스트한다”는 자기 회귀 구조를 이해했는가
- [ ] JUnit 5의 `@Test`, `@BeforeEach`, `@AfterEach`가 책의 어떤 개념인지 매핑할 수 있는가

## 퀴즈

**Q1. TestSuite가 필요한 이유는?**

**A.** 테스트를 하나씩 직접 실행하지 않고, 여러 `TestCase`를 같은 인터페이스로 묶어 실행하기 위해서다. 이것이 컴포지트 패턴의 작은 사례다.

**Q2. 2부의 가장 큰 인사이트는?**

**A.** 우리가 매일 쓰는 JUnit도 `run`, fixture, result, suite 같은 아주 작은 추상화의 조합이라는 점이다. 도구를 내부 구조로 이해하면 테스트 작성도 덜 막연해진다.

---

## 다음 장 예고 — 25장: 테스트 주도 개발 패턴

3부 시작. TDD 의 **패턴 카탈로그** — 실전에서 자주 마주치는 상황별 처방.
