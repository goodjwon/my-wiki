---
title: "TDD 실전 강의 — 20장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 20장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 테스트 주도 개발 실전 강의 교재

## 20장 — 뒷정리하기

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

- **tearDown** — 테스트 후 자원 정리.
- DB 연결·임시 파일·열린 소켓 정리.

---

## 1. 변경

```python
def run(self):
    self.setUp()
    try:
        method = getattr(self, self.name)
        method()
    finally:
        self.tearDown()

def tearDown(self): pass
```

→ 예외가 나도 tearDown 보장.

---

## JUnit 매핑

`@AfterEach` 가 정확히 이 역할.

---

## 핵심 교훈

setUp + tearDown = 테스트 라이프사이클의 정석. 모든 xUnit 프레임워크의 공통.

---

## 다음 장 예고 — 21장: 셈하기

여러 테스트 실행 + 결과 집계.
