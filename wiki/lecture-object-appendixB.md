---
title: "오브젝트 실전 강의 — 부록 B"
type: source
tags: [book, object, cho-young-ho, lecture]
sources: [object/오브젝트 실전 강의 교재 부록B.md]
created: 2026-06-21
updated: 2026-06-21
---

# 오브젝트 실전 강의 교재

## 부록 B — 타입 계층의 구현

> **원서**: 조영호 『오브젝트』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → 예시 → 핵심 교훈 → 함정 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 타입 계층을 표현하는 **여러 메커니즘** 비교 — 클래스·인터페이스·추상 클래스·결합·덕 타이핑·믹스인.
- 자바·Scala·Kotlin·JavaScript 의 각 메커니즘.
- **각 메커니즘의 트레이드오프** — 결합도·재사용·유연성.
- **Java Collection 의 표준 패턴** (List + AbstractList + ArrayList) 분석.

### 0.2 큰 그림 — 6 가지 메커니즘 비교

```
[ 단일 ]                          [ 결합 ]                      [ 동적 ]
 클래스 상속                       인터페이스 + 추상 클래스          덕 타이핑
 인터페이스                       (Java Collection 패턴)          (Ruby·Python)
 추상 클래스                                                     믹스인
                                                                (Scala trait·Kotlin)
```

> **비유 — "조직 구조"**
>
> 클래스 상속 = 가족 (혈연, 단일). 인터페이스 = 직무 자격증 (다중, 약). 추상 클래스 = 공통 매뉴얼 + 자식 책임 (강). 결합 = 매뉴얼 + 자격증 (균형). 덕 타이핑 = "할 줄 알면 OK" (정적 검사 X). 믹스인 = 기능을 가져다 붙임 (Scala trait).

### 0.3 현업에서 왜 중요한가

- *Effective Java* Item 20 (인터페이스 우선)·Item 22 (인터페이스는 타입만) 의 깊이.
- Java Collection 의 패턴 (List → AbstractList → ArrayList) 이 왜 그렇게 만들어졌는지.
- record·sealed (Java 17+) 가 추가된 새 메커니즘.

---

## 1. 클래스를 이용한 타입 계층

### 1.1 기본 구조

```java
public class Animal {
    public void eat() { ... }
    public void sleep() { ... }
}

public class Dog extends Animal {
    public void bark() { ... }
}

public class Cat extends Animal {
    public void meow() { ... }
}
```

### 1.2 장점

- **직관적** — is-a 관계가 코드로 표현.
- **코드 재사용** — 부모 메서드 자동 상속.
- **다형성** — `Animal a = new Dog()` 가능.

### 1.3 단점

- **단일 상속만** (자바·C#) — 다중 분류 표현 어려움.
- **LSP 위배 위험** — 자식이 부모 약속 깨뜨릴 수 있음.
- **취약한 기반 클래스** — 부모 변경이 자식 영향 (10장).

### 1.4 적합한 경우

- 도메인 관계가 명확히 is-a.
- 부모 변경이 거의 없음.
- 단일 분류로 충분.

→ 도메인 모델 상속은 거의 항상 의심. *EJ* Item 18.

---

## 2. 인터페이스를 이용한 타입 계층

### 2.1 기본 구조

```java
public interface Animal {
    void eat();
    void sleep();
}

public interface Flyable {
    void fly();
}

public class Dog implements Animal { ... }
public class Bird implements Animal, Flyable { ... }   // 다중 구현
```

### 2.2 장점

- **다중 구현** — 한 클래스가 여러 타입.
- **타입 호환만 — 코드 결합 X** — 구현 디테일 의존 없음.
- **LSP 친화** — 인터페이스는 약속만, 구현은 자식 자유.

### 2.3 단점

- **공통 코드 재사용 X** — 자식마다 똑같은 코드 반복.
- Java 8 이전엔 default method 없어 더 심각.

### 2.4 default method (Java 8+) 로 일부 해결

```java
public interface Animal {
    void eat();
    default void sleepEightHours() {
        System.out.println("Sleeping 8 hours");
    }
}
```

→ 인터페이스에 기본 구현 제공. 단, **필드는 못 가짐**.

→ *Effective Java* Item 20 권장: "인터페이스 우선".

### 2.5 적합한 경우

- 여러 분류·역할이 필요한 객체.
- 구현이 다양할 수 있는 경우.
- 도메인 모델·서비스·Repository 의 표준.

---

## 3. 추상 클래스를 이용한 타입 계층

### 3.1 기본 구조

```java
public abstract class Animal {
    public final void process() {   // 알고리즘 골격 (Template Method)
        eat();
        sleep();
    }
    protected abstract void eat();    // 자식 구현
    protected abstract void sleep();
}

public class Dog extends Animal {
    protected void eat() { ... }
    protected void sleep() { ... }
}
```

### 3.2 장점

- **공통 코드 + 자식 차이** — Template Method 정형.
- 알고리즘 골격 보장 (`final` 메서드).
- 자식은 변하는 부분만 책임.

### 3.3 단점

- **단일 상속** (자바).
- **자식이 부모 구현에 결합** — 취약한 기반 클래스 문제.

### 3.4 적합한 경우

- 알고리즘 골격이 안정적.
- 자식 차이가 명확하고 제한됨.
- Template Method 패턴 적용.

→ *EJ* Item 19: "상속을 고려해 설계·문서화, 그렇지 않으면 상속 금지".

---

## 4. 추상 클래스와 인터페이스 결합

### 4.1 Java Collection 의 표준 패턴

```java
public interface List<E> { ... }                      // 인터페이스 — 타입 호환

public abstract class AbstractList<E> implements List<E> {   // 추상 클래스 — 공통 코드
    @Override
    public boolean add(E e) {
        add(size(), e);   // 기본 구현 사용
        return true;
    }
    public abstract E get(int index);   // 자식 구현
    public abstract int size();
}

public class ArrayList<E> extends AbstractList<E> {   // 구체 — 차이만
    @Override public E get(int i) { return array[i]; }
    @Override public int size() { return size; }
}
```

### 4.2 장점

- **인터페이스의 유연성** (다중 구현·LSP 친화) + **추상 클래스의 코드 재사용**.
- 호출자는 `List<E>` 만 알면 됨 (구체 모름).
- 구현자는 `AbstractList<E>` 의 공통 코드 무료로 받음.

### 4.3 단점

- 클래스 수 증가 (인터페이스 + 추상 + 구체 = 3).
- 단순한 도메인엔 과한 구조.

### 4.4 적합한 경우

- 표준 라이브러리·프레임워크 설계.
- 다중 구현 + 공통 코드 둘 다 필요.

→ Spring `JdbcDaoSupport`, `WebMvcConfigurerAdapter` 같은 사례.

---

## 5. 덕 타이핑 (Duck Typing)

### 5.1 정의

> **"오리처럼 걷고 오리처럼 운다면 그것은 오리다"** — 동적 언어 (Ruby·Python·JavaScript).

### 5.2 예 — Python

```python
class Duck:
    def quack(self):
        print("Quack!")

class Person:
    def quack(self):
        print("I am quacking!")

def make_it_quack(thing):
    thing.quack()   # Duck 이든 Person 이든 quack() 메서드만 있으면 OK

make_it_quack(Duck())
make_it_quack(Person())
```

→ 인터페이스 명시 X, 런타임에 메서드 호출 시도.

### 5.3 자바는 정적 타입 — 덕 타이핑 직접 지원 X

자바는 컴파일 시점에 타입 확인. 인터페이스 명시 필수.

### 5.4 Scala 의 구조적 타이핑

```scala
def quack(duck: { def quack(): Unit }) { duck.quack() }
```

→ "quack() 메서드 있는 모든 타입" 매개변수 받음.

### 5.5 자바의 유사 패턴

- 리플렉션 — 런타임 메서드 호출 (성능·안전성 손해).
- `@FunctionalInterface` + 람다 — 단일 메서드만 일치하면 됨.

### 5.6 적합한 경우

- 동적 언어 (Ruby·Python·JavaScript).
- 자바에서는 거의 없음.

---

## 6. 믹스인 (Mixin)

### 6.1 정의

> **다른 클래스에 행동을 섞어 넣는 메커니즘**. 상속과 합성의 중간.

### 6.2 Scala trait

```scala
trait Logger {
  def log(msg: String): Unit = println(s"[$getClass] $msg")
}

trait Timer {
  def time[A](label: String)(block: => A): A = {
    val start = System.currentTimeMillis()
    val result = block
    println(s"$label took ${System.currentTimeMillis() - start}ms")
    result
  }
}

class OrderService extends Logger with Timer { ... }   // 다중 trait 믹스인
```

→ Scala trait 는 필드도 가능 — 진짜 믹스인.

### 6.3 Kotlin delegation

```kotlin
interface Engine { fun start() }
class GasEngine : Engine { override fun start() = println("Vroom") }

class Car(engine: Engine) : Engine by engine   // delegation
```

→ Car 가 Engine 인터페이스를 GasEngine 에 위임. 합성 + 인터페이스.

### 6.4 Java default method 의 한계

```java
public interface Loggable {
    default void log(String msg) {
        System.out.println(msg);
    }
    // 필드 X
}
```

→ Java default method 는 행동만 — 필드 없음. 진짜 믹스인 X.

### 6.5 적합한 경우

- Scala·Kotlin 활용.
- 자바에서는 default method 로 일부 표현, 필드 필요하면 합성.

---

## 7. 자바 17+ 의 새 메커니즘

### 7.1 record — 불변 ADT

```java
public record Money(int amount, String currency) {}
```

→ 불변 + equals + hashCode + toString 자동. ADT 의 정확한 구현.

### 7.2 sealed class — 제한된 상속

```java
public sealed interface Shape permits Circle, Rectangle, Triangle { }
public record Circle(double radius) implements Shape {}
public record Rectangle(double width, double height) implements Shape {}
public record Triangle(double a, double b, double c) implements Shape {}
```

→ Shape 의 자식은 정확히 3개 — 컴파일러가 보장. 패턴 매칭 + 다형성에 안전.

```java
double area(Shape s) {
    return switch (s) {
        case Circle c -> Math.PI * c.radius() * c.radius();
        case Rectangle r -> r.width() * r.height();
        case Triangle t -> { /* ... */ }
    };
    // default 불필요 — sealed 가 모든 경우 보장
}
```

→ ADT (sum type) 의 자바 표현. Scala·Kotlin 의 sealed 와 같은 메시지.

---

## 핵심 교훈

1. **타입 계층 표현은 여러 메커니즘** — 트레이드오프 이해.
2. **인터페이스 우선** (*Effective Java* Item 20).
3. **추상 클래스 = 공통 코드 + 자식 차이** — Template Method 정형.
4. **인터페이스 + 추상 클래스 결합** = Java Collection 의 표준 패턴.
5. **덕 타이핑** = 동적 언어, 자바는 인터페이스 명시.
6. **믹스인** = Scala trait·Kotlin delegation, Java default method 는 제한적.
7. **record + sealed** (Java 17+) = ADT 의 자바 표현.

---

## 함정 / 주의

- **인터페이스 도그마** — 단일 구현 인터페이스는 추측성 일반화.
- **추상 클래스 + 상속 = LSP 위배 위험** — Template Method 의 알고리즘 골격 변경 영향.
- **default method 남발** = 인터페이스가 abstract class 흉내. 두 종류 충돌 시 명시 해결.
- **자바에서 덕 타이핑 흉내** = 리플렉션 (안전성·성능 손해). 인터페이스가 답.

---

## 체크리스트

- [ ] 인터페이스 우선 — 추상 클래스는 공통 코드가 정말 있을 때
- [ ] 다중 분류 필요 시 인터페이스 다중 구현
- [ ] Java Collection 패턴 (인터페이스 + 추상 + 구체) 이 맞는 콘텍스트인가
- [ ] sealed 활용으로 ADT 표현 가능한가
- [ ] 단일 구현 인터페이스는 추측성 일반화 의심

---

## 퀴즈

1. **타입 계층 표현 6 메커니즘** 과 각각 한 줄 정의?
2. **Java Collection 의 List → AbstractList → ArrayList** 패턴이 왜 좋은가?
3. **default method** 가 추상 클래스를 완전히 대체 못 하는 이유?
4. **덕 타이핑** 이 자바에 어울리지 않는 이유?
5. **sealed class** 가 자바 17+ 에 도입된 의의는?

### 정답·해설

1. **클래스 상속** (단일), **인터페이스** (다중·약), **추상 클래스** (공통 + 자식), **결합** (Java Collection), **덕 타이핑** (동적 언어), **믹스인** (Scala trait). 각각 트레이드오프 다름.
2. **인터페이스의 유연성** (List 로 다중 구현 + 다형성) **+ 추상 클래스의 재사용** (AbstractList 의 공통 코드 무료) **+ 구체의 차이** (ArrayList 의 배열 구현). 세 층의 책임 분리.
3. **필드 못 가짐**. default method 는 행동만, 상태 (필드) 는 없음. 진짜 믹스인은 행동 + 상태 둘 다 — Scala trait 가 정형. Java 는 합성으로 보완.
4. **자바는 정적 타입** — 컴파일 시점에 메서드 존재 확인. 덕 타이핑은 런타임 호출 후 실패 — 자바 철학과 반대. 인터페이스 명시가 자바의 안전성 보장.
5. **ADT (sum type) 의 자바 표현**. Shape 의 자식이 정확히 N개 (Circle·Rectangle·Triangle) 임을 컴파일러가 보장 → switch 의 모든 경우 처리 가능 (default 불필요) → 패턴 매칭 안전. Scala·Kotlin 의 sealed 와 같은 메시지.

---

## 다음 — 부록 C: 동적인 협력, 정적인 코드

객체 협력의 동적 모델 vs 정적 코드의 차이. 도메인 모델·분석 모델·설계 모델·구현 모델의 일관성.
