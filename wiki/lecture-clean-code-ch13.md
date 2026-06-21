---
title: "Clean Code 실전 강의 — 13장"
type: source
tags: [book, clean-code, uncle-bob, lecture]
sources: [clean-code/클린 코드 실전 강의 교재 13장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 클린 코드 실전 강의 교재

## 13장 — 동시성

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 동시성의 **필요성과 미신** 을 분간.
- **방어 원칙 4가지** — SRP·자료 범위·자료 사본·독립 스레드.
- **고수준 동시성 라이브러리** 사용 (직접 wait/notify 회피).
- **읽기-쓰기·생산자-소비자·식사하는 철학자** 패턴 인식.
- 동시성 코드 **테스트** 의 한계와 전략.

### 0.2 큰 그림

```
[ 필요성·난관 ]               [ 방어 원칙 ]                  [ 실행 모델 ]
 동시성이 필요한 이유           SRP                            생산자-소비자
 미신과 오해                   자료 범위 제한                  읽기-쓰기
                              자료 사본 사용                  식사하는 철학자
                              스레드 독립
```

> **비유 — 동시성은 "공유 도마"입니다.**
>
> 여러 요리사 (스레드) 가 한 도마 (공유 가변 상태) 에 동시 칼질하면 사고. 도마 사용 차례 (락) + 도마 사본 (불변·복사) + 도마 안 쓰기 (독립 스레드) 의 조합.

### 0.3 현업에서 왜 중요한가

- Spring MVC = 요청마다 다른 스레드, 빈은 싱글턴 → 빈의 가변 필드 = 공유 가변.
- *Effective Java* Item 78·79·80·82 와 같은 결.
- 동시성 사고는 **재현 어려움 + 운영 사고 단골**.

---

## 13.1 동시성이 필요한 이유

### 한 줄 정의

응답성·처리량·자원 활용. 단, **복잡도 폭증** 이 대가.

### 13.1.1 미신과 오해

- **"항상 성능 개선"** ❌ — 부하·하드웨어·태스크 성격에 따라 오히려 느려짐
- **"설계는 비슷"** ❌ — 단일 스레드와 완전히 다른 사고
- **"라이브러리 안 봐도"** ❌ — 동시성 라이브러리 학습 필수

---

## 13.2 난관

### 책의 단언

동시성은 **어렵다**. 자명해 보이는 코드도 멀티스레드에서 깨짐.

### 사례

```java
public class X {
    private int lastId = 0;
    public int getNextId() {
        return ++lastId;   // ❌ atomic 아님 — race
    }
}
```

→ 두 스레드가 동시에 호출 → 같은 ID 반환 가능.

---

## 13.3 동시성 방어 원칙

### 13.3.1 단일 책임 원칙 (SRP)

**동시성 코드 = 별도 클래스**. 비즈니스 로직과 섞지 마라.

```java
// ❌
public class OrderService {
    public void process(Order o) {
        synchronized (this) { ... }   // 동시성 + 비즈니스 섞임
    }
}

// ✅ — 동시성을 별도 클래스로
public class OrderQueue {
    private final BlockingQueue<Order> queue = ...;
    public void enqueue(Order o) { queue.put(o); }
    public Order dequeue() { return queue.take(); }
}

public class OrderService {
    private final OrderQueue queue;
    public void process(Order o) { queue.enqueue(o); }   // 단순
}
```

### 13.3.2 자료 범위를 제한하라

공유 가변 자료의 **접근 범위 최소화**. `synchronized` 영역도 작게.

### 13.3.3 자료 사본을 사용하라

원본 공유 대신 **불변 사본**. 동기화 비용 0.

### 13.3.4 스레드는 가능한 독립적으로

각 스레드가 **자기 자료** 만 다루도록 분리. 공유 영역 = 최소.

```java
// Servlet 모델 — 각 요청이 독립 데이터
public void doGet(HttpServletRequest req, HttpServletResponse res) {
    // req·res는 요청별 — 공유 X
    // 단, ServletContext의 공유 자원에는 동기화 필요
}
```

---

## 13.4 라이브러리를 이해하라

### 스레드 안전 컬렉션

- `ConcurrentHashMap` — `synchronized Map` 보다 빠름
- `CopyOnWriteArrayList` — 읽기 위주
- `BlockingQueue` — 생산자-소비자
- `Atomic*` — atomic 단일 변수 연산

### Java 5+ 동시성 유틸

- `Executor` / `ExecutorService` — 스레드 풀
- `Callable<T>` / `Future<T>` — 비동기 결과
- `CompletableFuture` (Java 8+) — 조합 가능

→ [[entity-effective-java]] Item 80·81 과 동일.

---

## 13.5 실행 모델을 이해하라

### 핵심 용어

| 용어 | 의미 |
|------|------|
| **임계 영역** | 한 번에 한 스레드만 들어갈 코드 |
| **데드락** | 두 스레드가 서로의 락 대기 → 영원 |
| **라이브락** | 데드락은 아니지만 진행 못 함 |
| **기아 (Starvation)** | 일부 스레드가 자원을 못 받음 |

### 13.5.1 생산자-소비자 (Producer-Consumer)

`BlockingQueue` 가 정석:
- Producer: `queue.put(item)` (가득 차면 대기)
- Consumer: `queue.take()` (비어 있으면 대기)

### 13.5.2 읽기-쓰기 (Readers-Writers)

여러 reader 동시 OK, writer 시 배타.

- `ReentrantReadWriteLock` — Java 표준

### 13.5.3 식사하는 철학자 (Dining Philosophers)

5명이 원형 식탁에서 포크를 공유 — 데드락 가능성 고전 문제.

해법: 락 획득 순서 통일·timeout·자원 한계.

---

## 13.6 동기화하는 메서드 사이의 의존성

### 한 줄 정의

여러 synchronized 메서드를 순차로 호출하는 호출자가 있으면 → **호출자 입장에서 atomic 보장 안 됨**.

### 해법 3가지

1. **클라이언트 기반 락** — 호출자가 외부에서 락
2. **서버 기반 락** — 서버가 합쳐진 메서드 제공
3. **Adapter** — 락을 끼워주는 어댑터

권장: **서버 기반** (캡슐화).

---

## 13.7 동기화하는 부분을 작게 만들어라

### 한 줄 정의

`synchronized` 영역은 **짧고 작게**. 길수록 경합·성능 손실.

```java
// ❌ 메서드 전체 synchronized
public synchronized void process(Order o) {
    validate(o);                  // 동기화 불필요
    Result r = compute(o);        // 동기화 불필요
    updateSharedState(r);         // ← 진짜 동기화 필요한 부분
    notifyListeners(r);           // 동기화 불필요 (외부 콜백 — 79번 함정)
}

// ✅ 작은 임계 영역
public void process(Order o) {
    validate(o);
    Result r = compute(o);
    synchronized (this) {
        updateSharedState(r);
    }
    notifyListeners(r);   // 락 밖에서
}
```

→ [[entity-effective-java]] Item 79 와 동일.

---

## 13.8 올바른 종료 코드는 구현하기 어렵다

### 한 줄 정의

스레드의 **정상 종료** (특히 graceful shutdown) 는 매우 어려움. 데드락·자원 누수 위험.

권장:
- `ExecutorService.shutdown()` + `awaitTermination`
- 인터럽트 처리 신중 (`InterruptedException` 재던지기·플래그 복원)
- 자원 정리는 try-with-resources

---

## 13.9 스레드 코드 테스트하기

### 한 줄 정의

동시성 테스트는 **재현이 어려움**. 그래도 가능한 시도들:

### 책의 권장 (요약)

- **말이 안 되는 실패는 스레드 문제로** 의심. "테스트가 가끔 실패" = flaky 가 아니라 **race**.
- **다중 스레드 코드 + 단일 스레드 코드 분리** — 단일 부터 통과시키기.
- 다양한 환경 (다른 OS, 다른 JVM) 에서 돌리기.
- **프로세서 수보다 많은 스레드** 돌리기 — context switch 강제.
- **자동화** — 실패 패턴 발견.

---

## 핵심 교훈

1. **동시성은 어렵다** — 자명해 보이는 코드도 깨진다.
2. **SRP 동시성에도** — 별도 클래스로 분리.
3. **자료 사본·독립 스레드·범위 제한** — 공유 최소화.
4. **고수준 라이브러리** 우선 — wait/notify 회피.
5. **임계 영역은 짧고 작게**.
6. **스레드 테스트는 재현 어려움** — 자동화 + 다양한 환경.

---

## 함정 / 주의

- 빈의 가변 필드 = 사실상 전역 — 거의 항상 사고.
- `synchronized` 안에서 외부 콜백·I/O = 데드락 위험 (Item 79).
- `Executors.newCachedThreadPool()` 무제한 생성 위험 — 명시적 `ThreadPoolExecutor` 권장.
- JPA `EntityManager` 는 스레드 안전 X — 트랜잭션·요청 스코프.

---

## 체크리스트

- [ ] Spring 빈 필드가 가변 + 공유 가능한가
- [ ] `synchronized` 영역에 I/O·콜백·블로킹이 있는가
- [ ] `new Thread()` 직접 호출이 비즈니스 코드에 있는가
- [ ] `HashMap`·`ArrayList` 를 멀티스레드 공유하는가 (`ConcurrentHashMap`·`CopyOnWriteArrayList` 검토)
- [ ] `SimpleDateFormat`·`Random` 공유 (`DateTimeFormatter`·`ThreadLocalRandom`)
- [ ] 스레드 풀 크기·큐·거부 정책이 명시적인가
- [ ] 테스트가 `Thread.sleep` 에 의존하는가 → `CountDownLatch`·`Awaitility`

---

## 퀴즈

**Q1. 동시성 SRP의 의미는?**

**A.** **동시성 코드 = 별도 클래스**. 비즈니스 로직과 섞으면 추론 어려움 + 테스트 어려움. 큐·풀·잠금 객체로 동시성만 책임지는 클래스 분리.

**Q2. "자료 사본" 이 동기화보다 자주 좋은 이유?**

**A.** 사본은 **공유가 아예 없음** → 동기화 비용 0, 데드락 없음, 추론 쉬움. 메모리 비용 증가는 보통 감수 가능. `Effective Java` Item 17 불변 권고와 직결.

**Q3. `synchronized` 메서드 전체보다 작은 임계 영역이 좋은 이유?**

**A.** 동기화 비용은 **락 보유 시간** 에 비례. 영역이 작을수록 (1) 다른 스레드 대기 짧음, (2) 데드락 확률 ↓. 본질적으로 공유 상태 변경만 임계 영역.

**Q4. `Executors.newCachedThreadPool()` 의 운영 위험?**

**A.** 큐가 `SynchronousQueue` + 최대 스레드 `Integer.MAX_VALUE` → 부하 폭발 시 스레드 무제한 생성 → OOM. 명시적 `ThreadPoolExecutor(코어, 맥스, 큐, 거부정책)` 권장.

**Q5. Spring MVC 의 빈에 가변 필드를 두면 안 되는 이유?**

**A.** Spring 빈은 기본 **싱글턴** + 요청마다 다른 스레드. 가변 필드 = 공유 가변 상태 = 거의 항상 race. 모든 가변 상태는 메서드 지역·요청 스코프·DB 로 옮기는 게 안전.

---

## 다음 장 예고 — 14장: 점진적인 개선

`Args` 라이브러리를 짤 때 Uncle Bob의 **실제 과정** 을 보여줌. 1차 초안 → 중단 → 점진 정련. "초안이 추한 건 정상이고 그 위에서 정련하는 게 본업" 이라는 살아있는 사례.
