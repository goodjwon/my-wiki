---
title: "TDD 실전 강의 — 21장"
type: source
tags: [book, tdd, kent-beck, lecture]
sources: [tdd/테스트 주도 개발 실전 강의 교재 21장.md]
created: 2026-06-20
updated: 2026-06-21
---

# 테스트 주도 개발 실전 강의 교재

## 21장 — 셈하기

> **대상**: Java/Spring 백엔드 입문~중급 수강생

---

## 0. 학습 목표

- **TestResult** 도입 — 실행 결과 집계.
- "통과 N, 실패 M" 보고.
- 테스트 프레임워크도 결국 “상태를 모으는 객체”가 필요하다는 점을 이해한다.

### 0.2 큰 그림

```
[이전 장]
TestCase.run() 이 테스트를 실행만 함
      ↓
[21장]
TestResult 가 실행 횟수와 실패 횟수를 모음
      ↓
[다음 장]
실패도 result 에 기록
```

> **비유 — 경기 스코어보드**
>
> 선수들이 뛰는 것만으로는 관중이 경기 흐름을 알 수 없습니다. 점수판이 있어야 “몇 번 뛰었고, 몇 번 실패했는지”를 압니다. `TestResult`는 테스트 프레임워크의 스코어보드입니다.

---

## 1. RED — 실행 횟수를 보고하고 싶다

먼저 원하는 사용법을 적는다.

```python
test = WasRun("testMethod")
result = TestResult()
test.run(result)
print(result.summary())   # "1 run, 0 failed" 를 기대
```

아직 `TestResult`가 없고, `run()`도 result를 받지 않으므로 실패한다. 이번 장의 빨강은 “실행 결과를 외부로 꺼낼 수 없다”는 설계 결핍이다.

---

## 2. GREEN — TestResult 도입

```python
class TestResult:
    def __init__(self):
        self.runCount = 0
    def summary(self):
        return f"{self.runCount} run, 0 failed"

class TestCase:
    def run(self, result):
        result.runCount += 1
        self.setUp()
        try:
            method = getattr(self, self.name)
            method()
        finally:
            self.tearDown()
```

실행:

```bash
python3 testcase.py
```

기대 결과:

```text
1 run, 0 failed
```

---

## 3. REFACTOR — 프레임워크의 책임 분리

이제 책임이 나뉜다.

| 객체 | 책임 |
|------|------|
| `TestCase` | 테스트 메서드를 찾아 실행한다 |
| `WasRun` | 실제 테스트 대상 역할을 한다 |
| `TestResult` | 실행 횟수와 결과를 보고한다 |

`TestCase`가 문자열을 직접 출력하지 않고 `TestResult`에 기록하게 만든 점이 중요하다. 출력 형식이 바뀌어도 실행 로직은 바뀌지 않는다.

## 4. 체크리스트

- [ ] `TestResult`가 실행 횟수를 가진 독립 객체인가
- [ ] `TestCase.run(result)`가 결과 객체에 기록하는가
- [ ] 출력 문자열 생성 책임이 `TestResult.summary()`에 모였는가
- [ ] 다음 장에서 실패 횟수를 추가할 자리가 보이는가

## 5. 퀴즈

**Q1. `TestResult`를 따로 만든 이유는?**

**A.** 실행과 보고 책임을 분리하기 위해서다. `TestCase`는 실행만 알고, 결과 집계·문자열 표현은 `TestResult`가 맡는다.

**Q2. 이 장의 설계 인사이트는?**

**A.** 작은 프레임워크도 “일하는 객체”와 “결과를 모으는 객체”를 분리하면 확장하기 쉬워진다. 다음 장에서 실패 횟수를 추가해도 실행 흐름을 크게 흔들지 않는다.

---

## 다음 장 예고 — 22장: 실패 처리

테스트 실패도 result에 집계.
