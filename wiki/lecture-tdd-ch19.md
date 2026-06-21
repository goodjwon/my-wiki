---
title: "TDD 실전 강의 — 19장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 19장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 19장 — 테이블 차리기

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: setUp 도입

---

## 0. 학습 목표

- **setUp** — 테스트마다 같은 초기 상태 보장.
- 독립성 (F.I.R.S.T. 의 I) 의 기반.

---

## 1. RED → GREEN

```python
class TestCase:
    def setUp(self): pass
    def run(self):
        self.setUp()
        method = getattr(self, self.name)
        method()

class WasRun(TestCase):
    def setUp(self):
        self.wasRun = None
        self.wasSetUp = 1
    def testMethod(self):
        self.wasRun = 1
```

→ setUp 이 매 run 마다 호출. 테스트 간 독립성 확보.

---

## JUnit 매핑

- `setUp()` → `@BeforeEach`
- `tearDown()` → `@AfterEach`
- 클래스 범위 → `@BeforeAll` / `@AfterAll`

---

## 다음 장 예고 — 20장: 뒷정리하기

tearDown — 테스트 후 자원 정리.
