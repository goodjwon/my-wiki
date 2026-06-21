---
title: "TDD 실전 강의 — 22장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 22장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 22장 — 실패 처리하기

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

- 테스트 예외를 잡아 **실패로 집계** — 다음 테스트 실행 계속.
- F.I.R.S.T. 의 I (독립성) — 한 테스트 실패가 다른 테스트 멈추지 않음.

---

## 1. 변경

```python
def run(self, result):
    result.runCount += 1
    try:
        self.setUp()
        try:
            method = getattr(self, self.name)
            method()
        except:
            result.failureCount += 1
        finally:
            self.tearDown()
    except:
        result.failureCount += 1

def summary(self):
    return f"{self.runCount} run, {self.failureCount} failed"
```

→ setUp 실패도 처리. 모든 테스트 격리.

---

## 다음 장 예고 — 23장: 얼마나 달콤한지

여러 테스트를 한 번에 — TestSuite 도입.
