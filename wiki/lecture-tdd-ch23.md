---
title: "TDD 실전 강의 — 23장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 23장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 23장 — 얼마나 달콤한지

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

- **TestSuite** — 여러 테스트를 하나로 묶어 실행.
- 컴포지트 패턴.

---

## 1. 변경

```python
class TestSuite:
    def __init__(self):
        self.tests = []
    def add(self, test):
        self.tests.append(test)
    def run(self, result):
        for test in self.tests:
            test.run(result)
```

→ TestCase 와 TestSuite 가 같은 `run(result)` 인터페이스 — **컴포지트**.

---

## 핵심 교훈

xUnit 의 코어 (TestCase·TestResult·TestSuite·setUp·tearDown) 가 단 6장 안에 완성. **단순한 구조의 누적이 강력한 도구**.

---

## 다음 장 예고 — 24장: xUnit 회고

2부 전체 회고.
