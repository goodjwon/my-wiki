---
title: "Clean Code 실전 강의 — 8장"
type: source
tags: [book, clean-code, uncle-bob, lecture]
sources: [clean-code/클린 코드 실전 강의 교재 8장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 클린 코드 실전 강의 교재

## 8장 — 경계

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 외부 라이브러리·API 와 우리 코드 사이의 **경계** 를 어떻게 설계할지.
- **학습 테스트** — 외부 라이브러리를 익히는 가장 빠른 길.
- **존재하지 않는 코드** (다른 팀·외부 API) 를 가정해 만드는 패턴.

### 0.2 큰 그림

```
[ 외부 코드 사용 ]              [ 격리·학습 ]                  [ 미래 대비 ]
 8.1 외부 코드 사용 (Map 사례)   8.2 경계 살피고 익히기           8.4 아직 없는 코드 사용
                                  8.3 학습 테스트는 공짜 이상      8.5 깨끗한 경계
```

> **비유 — 경계는 "국경"입니다.**
>
> 우리 코드와 외부 라이브러리는 다른 나라. 국경에 **세관(Adapter)** 을 두어 격리해야 외부 변경이 우리 안까지 흔들지 않음.

### 0.3 현업에서 왜 중요한가

- Spring 프로젝트는 거의 모두 외부 라이브러리 의존 (Jackson·Hibernate·log4j·Redis 클라이언트…).
- 외부 API 변경 한 번에 우리 코드 전체가 흔들리는 사고 단골.
- 경계 설계 = 향후 **교체·테스트·검증** 자유의 기반.

---

## 8.1 외부 코드 사용하기

### 한 줄 정의

외부 인터페이스(Java의 `Map` 같은) 가 **너무 많은 기능** 을 노출하면, 우리 코드가 그 모든 기능에 결합됨.

### Before / After — `Map<String, Sensor>` 의 함정

```java
// Before — Map 그대로 노출
Map<String, Sensor> sensors = new HashMap<>();
Sensor s = sensors.get(id);   // 캐스팅 필요 (제네릭 없는 옛 API의 경우)
sensors.clear();              // 호출자가 임의로 비울 수 있음

// After — 캡슐화
public class Sensors {
    private final Map<String, Sensor> sensors = new HashMap<>();
    public Sensor getById(String id) {
        return sensors.get(id);
    }
    // clear() / putAll() 같은 위험한 메서드 노출 X
}

Sensors s = new Sensors();
Sensor sensor = s.getById("a1");
```

### 핵심

- Map 같은 **광범위한 외부 인터페이스** 를 그대로 노출하지 마라.
- **필요한 메서드만** 우리 클래스가 노출 → 외부 인터페이스 변경이 우리 코드에 미치는 영향 최소화.

---

## 8.2 경계 살피고 익히기

### 한 줄 정의

새 라이브러리를 프로덕션 코드에 곧장 쓰지 마라. **학습 테스트** 부터.

### 학습 테스트란

- 라이브러리의 **공개 API를 테스트로 학습**
- 라이브러리가 어떻게 동작하는지 **우리 코드가 가정하는 방식대로** 검증

### 예시 — log4j 학습

```java
@Test
void 콘솔에_INFO_레벨_메시지를_출력한다() {
    Logger logger = Logger.getLogger("MyLogger");
    logger.setLevel(Level.INFO);
    // log4j 설정·동작이 우리가 기대한 대로인지 검증
    logger.info("Hello");
    // 검증: 콘솔 또는 캡처된 appender에서 "Hello" 발견
}
```

---

## 8.3 학습 테스트는 공짜 이상이다

### 한 줄 정의

학습 테스트의 보너스: **라이브러리 새 버전이 우리 가정을 깨면 즉시 발견**.

### 효과

| | 학습 테스트 없음 | 학습 테스트 있음 |
|---|---|---|
| 라이브러리 동작 학습 | 문서·시행착오 | 테스트로 직접 |
| 버전 업그레이드 | 운영에서 사고 | CI에서 빨강 즉시 |
| 비호환 변경 발견 | 소비자가 보고 | 우리가 먼저 |
| 시간 비용 | "시간 없어" | 같음 — 어차피 학습 필요 |

→ 학습 시간 자체가 곧 회귀 테스트.

---

## 8.4 아직 존재하지 않는 코드를 사용하기

### 한 줄 정의

다른 팀·외부 API가 **아직 없을 때**, 인터페이스를 **우리가 원하는 모양으로 먼저 정의** 하고 가짜 구현으로 작업.

### 패턴 — Adapter

```
[ 우리 코드 ] → [ 우리가 정의한 인터페이스 ] → [ 가짜/실제 구현 ]
                                                  ↑ 외부 API 나오면 Adapter로
```

### 예시

```java
// 우리가 원하는 모양
public interface PaymentGateway {
    PaymentResult charge(Money amount, Card card);
}

// 외부 API 아직 없음 → 가짜
public class FakePaymentGateway implements PaymentGateway { ... }

// 우리 코드는 PaymentGateway 인터페이스에 의존 → 진행 가능

// 나중에 외부 API 나오면 Adapter
public class StripeGateway implements PaymentGateway {
    private final StripeClient client;
    public PaymentResult charge(Money amount, Card card) {
        // StripeClient API → 우리 인터페이스 변환
    }
}
```

### 효과

- **개발 차단 X** — 외부 API 대기 없이 진행
- **테스트 가능** — 가짜 구현으로 단위 테스트
- **교체 자유** — Stripe → Toss → PayPal 갈아타기 쉬움

---

## 8.5 깨끗한 경계

### 핵심 정리

- 외부 인터페이스를 **우리 인터페이스로 감싸기** (Adapter)
- 외부 클래스를 **우리 코드에서 직접 사용 최소화**
- 외부 클래스를 **반환하지 마라** — 호출자에게 외부 의존 전파

### Spring 현업

```java
// ❌ — 외부 라이브러리 클래스를 우리 인터페이스에 직접 노출
public interface NotificationService {
    void send(SlackMessage msg);   // Slack 라이브러리 의존이 전파
}

// ✅ — 우리 도메인 객체
public interface NotificationService {
    void send(Notification notif);   // 우리가 정의한 record
}

// 구현체 안에서만 Slack 변환
public class SlackNotificationService implements NotificationService {
    public void send(Notification notif) {
        SlackMessage msg = toSlackMessage(notif);
        slackClient.send(msg);
    }
}
```

---

## 핵심 교훈

1. **외부 인터페이스 = 광범위함**. 그대로 노출하면 결합도 폭증.
2. **학습 테스트** = 라이브러리 학습 + 회귀 테스트 — 일거양득.
3. **존재하지 않는 코드** 를 미리 인터페이스로 정의해 진행 (Adapter).
4. **외부 클래스를 우리 API에서 노출하지 마라** — 의존이 전파됨.
5. 경계는 **테스트·교체·검증의 자유** 의 기반.

---

## 함정 / 주의

- 모든 외부 라이브러리를 wrapping은 과함. **자주 변하거나 광범위한 것만**.
- `String`, `Integer` 같은 표준 타입은 wrapping 안 함 — 그건 언어의 일부.
- Adapter도 과하면 추가 복잡도 → 외부 API 가 정말 우리 인터페이스에 맞을 때만.

---

## 체크리스트 (코드 리뷰용)

- [ ] 외부 라이브러리 클래스를 도메인 인터페이스에 노출하고 있는가
- [ ] 새 라이브러리 도입 시 학습 테스트를 작성했는가
- [ ] 외부 의존이 우리 코드의 깊은 곳까지 침투했는가
- [ ] 외부 API 교체 시 변경 범위가 한 Adapter 안에 한정되는가
- [ ] 미완성 외부 API에 대해 인터페이스 + 가짜 구현으로 진행 가능한가

---

## 퀴즈

**Q1. Map 같은 광범위한 외부 인터페이스를 그대로 노출하면 안 되는 이유?**

**A.** Map의 모든 메서드(`clear`/`putAll`/`remove`) 에 우리 코드가 결합됨. 우리는 일부만 쓰는데 호출자는 다 쓸 수 있어 객체 불변식 위험. **필요한 메서드만 노출하는 작은 클래스로 감싸라**.

**Q2. 학습 테스트가 "공짜 이상" 인 이유?**

**A.** 라이브러리 학습 시간은 어차피 필요 → 그 시간이 곧 **회귀 테스트** 가 됨. 새 버전에서 동작이 바뀌면 CI에서 즉시 빨강. 운영 사고 전 발견.

**Q3. "아직 존재하지 않는 코드" 를 인터페이스로 먼저 정의하는 패턴 이름?**

**A.** **Adapter 패턴**. 우리가 원하는 인터페이스를 먼저 그리고, 가짜 구현으로 진행. 외부 API 나오면 그 구현체가 어댑터 역할. 진행 차단 X, 테스트 자유.

**Q4. 외부 라이브러리 클래스를 우리 API의 반환 타입으로 쓰면 위험한 이유?**

**A.** **의존 전파**. 호출자가 그 외부 클래스를 받아 쓰면 호출자도 그 라이브러리에 의존. 라이브러리 교체 시 호출자도 같이 수정 — 폭증.

**Q5. 모든 외부 라이브러리를 wrapping하는 게 과한 이유?**

**A.** Wrapping에도 비용 (코드·간접 호출·이해). **자주 변하거나 광범위한 인터페이스만** wrapping이 가성비 있음. `String`·`Integer` 같은 언어 표준은 wrapping 불필요.

---

## 다음 장 예고 — 9장: 단위 테스트

**TDD 3법칙**, **F.I.R.S.T.**, **테스트 당 assert 하나**. 테스트 코드도 프로덕션 코드만큼 깨끗해야 한다는 메시지. 4장(리팩터링) 의 "자가 테스트가 모든 리팩터링의 전제" 와 짝.
