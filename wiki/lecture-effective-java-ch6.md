---
title: "Effective Java 실전 강의 — 6장"
type: source
tags: [book, effective-java, bloch, lecture]
sources: [effective_java/이펙티브 자바 실전 강의 교재 6 장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 이펙티브 자바 실전 강의 교재

## 6장 — 열거 타입과 애너테이션

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 설명 → 비유 → 현업 예제 → 따라하기(실습) → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- `int`/`String` 상수 대신 **`enum`**으로 도메인 상수를 타입 안전하게 모델링한다.
- `EnumSet`/`EnumMap`으로 enum 기반 자료구조를 효율·안전하게 다룬다.
- **애너테이션**의 동작 원리를 이해하고, 명명 패턴 대신 애너테이션으로 메타데이터를 표현한다.

### 0.2 큰 그림 — "정해진 것"과 "표시하는 것"

```
[ 정해진 값(enum) ]                         [ 표시(애너테이션) ]
 34 int 상수 → enum ⭐                        39 명명 패턴 → 애너테이션 ⭐
 35 ordinal → 인스턴스 필드                   40 @Override 일관 사용
 36 비트필드 → EnumSet                        41 타입이면 마커 인터페이스
 37 ordinal 인덱싱 → EnumMap
 38 확장 enum → 인터페이스
```

> **비유 — enum은 "정식 메뉴판", 애너테이션은 "스티커"입니다.**
> 
> - enum: 손님이 아무 숫자(`int 0,1,2`)나 외치지 못하게, **정해진 메뉴**(`DRAFT, ACTIVE, CLOSED`)만 주문하게 합니다. 잘못된 주문은 **컴파일 시점**에 막힙니다.
> - 애너테이션: 코드에 "이건 테스트야"(`@Test`), "이건 빈이야"(`@Component`) 같은 **스티커**를 붙여, 도구·프레임워크가 그 스티커를 읽고 동작하게 합니다.

### 0.3 현업에서 왜 중요한가

- 계약상태·결제수단·권한·코드값 등 도메인 상수는 enum으로 모델링해야 안전합니다(잘못된 값 차단 + 동작 캡슐화).
- 여러분이 매일 쓰는 `@Component`, `@Transactional`, `@Test`는 전부 **아이템 39(애너테이션)**의 산물입니다.

---

## 아이템 34. int 상수 대신 열거 타입을 사용하라 ⭐핵심

### 한 줄 요약

관련 상수의 집합은 `int`/`String`이 아니라 **`enum`**으로. 타입 안전 + 의미 + 동작을 한 몸에 담아라.

### 비유 — "메뉴판 주문 vs 아무 숫자나 외치기"

`int 상수`는 손님이 "3번!"이라고 외치는데, 메뉴에 3번이 없어도 주방은 그냥 받습니다(타입 안전 X). enum은 정해진 메뉴만 주문 가능하고, 각 메뉴에 **레시피(메서드)**까지 붙일 수 있습니다.

### 문제: int enum 패턴 (안티패턴)

```java
// ❌ 타입 안전성 없음: APPLE_FUJI와 ORANGE_NAVEL을 더해도 컴파일러가 안 막음
public static final int APPLE_FUJI  = 0;
public static final int ORANGE_NAVEL = 0;   // 값이 같아 구분도 안 됨
```

- 컴파일러가 "사과 자리에 오렌지"를 못 막는다.
- 출력하면 의미 없는 숫자(0)만 보인다(디버깅 곤란).
- 상수가 바뀌면 클라이언트를 **재컴파일**해야 한다.

### 해법: 기본 enum

```java
public enum Apple  { FUJI, PIPPIN, GRANNY_SMITH }
public enum Orange { NAVEL, TEMPLE, BLOOD }
```

- Apple 자리에 Orange를 넣으면 **컴파일 에러**.
- 이름을 그대로 출력(`toString` 기본 제공), `values()`로 순회 가능.

### 한 단계 위: 데이터와 메서드를 가진 enum

```java
public enum Planet {
    EARTH(5.975e24, 6.378e6),
    MARS (6.419e23, 3.393e6);

    private final double mass;
    private final double radius;
    Planet(double mass, double radius) { this.mass = mass; this.radius = radius; }

    public double surfaceGravity() {
        return 6.67300E-11 * mass / (radius * radius);
    }
}
```

### 최상위: 상수별 메서드 구현 (전략 enum)

연산처럼 **상수마다 동작이 다른** 경우, switch 대신 상수별로 동작을 구현합니다.

```java
public enum Operation {
    PLUS("+")  { public double apply(double x, double y) { return x + y; } },
    MINUS("-") { public double apply(double x, double y) { return x - y; } },
    TIMES("*") { public double apply(double x, double y) { return x * y; } };

    private final String symbol;
    Operation(String symbol) { this.symbol = symbol; }
    public abstract double apply(double x, double y);   // 각 상수가 구현
}
```

### 현업 예제 — 도메인 상태 모델링 ⭐

계약상태를 enum으로 두고, **상태 전이 규칙까지 캡슐화**하면 잘못된 전이를 원천 차단할 수 있습니다.

```java
public enum ContractStatus {
    DRAFT, ACTIVE, SUSPENDED, CLOSED;

    private static final Map<ContractStatus, Set<ContractStatus>> ALLOWED = Map.of(
        DRAFT,     Set.of(ACTIVE),
        ACTIVE,    Set.of(SUSPENDED, CLOSED),
        SUSPENDED, Set.of(ACTIVE, CLOSED),
        CLOSED,    Set.of()
    );

    public boolean canTransitionTo(ContractStatus next) {
        return ALLOWED.getOrDefault(this, Set.of()).contains(next);
    }
}
```

이제 "DRAFT → CLOSED"처럼 금지된 전이를 도메인이 스스로 막습니다(불변식 보호).

> **JPA 메모**: 엔티티에 enum을 저장할 때는 `@Enumerated(EnumType.STRING)`을 쓰세요. 기본값인 `ORDINAL`은 **순서(0,1,2)를 DB에 저장**하므로, 나중에 상수 순서를 바꾸면 기존 데이터가 깨집니다(아이템 35와 직결).

### 따라하기 (실습 34-A)

1. int 상수로 결제수단을 만들고, 엉뚱한 값(99)을 넣어도 컴파일이 통과하는 것을 확인한다.
2. `enum PaymentMethod`로 바꿔 타입 안전을 확보한다.
3. `ContractStatus.canTransitionTo`를 구현하고, 금지된 전이가 false를 반환하는지 테스트한다.

### 체크리스트

- [ ] 관련 상수 묶음을 `int`/`String`으로 관리하고 있지 않은가? → enum
- [ ] enum 상수마다 동작이 다른가? → 상수별 메서드 구현
- [ ] JPA 저장 시 `@Enumerated(STRING)`을 썼는가?

### 퀴즈

<details><summary>Q. int enum 패턴이 enum보다 위험한 결정적 이유는?</summary>

**타입 안전성이 없습니다.** 컴파일러가 "사과 상수 자리에 오렌지 상수"를 막지 못해, 의미상 잘못된 값이 그대로 통과합니다. enum은 이를 컴파일 시점에 차단합니다.

</details>

---

## 아이템 35. ordinal 메서드 대신 인스턴스 필드를 사용하라

### 한 줄 요약

enum의 `ordinal()`(선언 순서)에 **의미를 부여하지 마라.** 순서가 바뀌면 깨진다. 값이 필요하면 **인스턴스 필드**에 담아라.

### 비유 — "줄 선 순번에 월급 매기기"

줄 선 순서(ordinal)로 월급을 정하면, 누군가 줄 순서만 바꿔도 월급이 엉망이 됩니다. 월급은 명찰(필드)에 적어야 합니다.

### 문제 → 해법

```java
// ❌ ordinal에 의존: 상수 순서를 바꾸거나 중간 삽입하면 값이 어긋남
public enum Ensemble {
    SOLO, DUET, TRIO;
    public int numberOfMusicians() { return ordinal() + 1; }
}

// ✅ 인스턴스 필드로 명시
public enum Ensemble {
    SOLO(1), DUET(2), TRIO(3), QUARTET(4);
    private final int n;
    Ensemble(int n) { this.n = n; }
    public int numberOfMusicians() { return n; }
}
```

### 현업 메모

`ordinal()`은 `EnumSet`/`EnumMap` 같은 자바 표준 구현이 내부적으로 쓰라고 있는 것이지, **애플리케이션 코드가 쓰라는 게 아닙니다.** DB에 enum을 ordinal로 저장하는 것도 같은 이유로 위험합니다.

### 퀴즈

<details><summary>Q. enum을 DB에 ordinal로 저장하면 어떤 사고가 나는가?</summary>

나중에 enum 상수의 **순서를 바꾸거나 중간에 추가**하면, DB에 저장된 숫자가 다른 상수를 가리키게 되어 **데이터 의미가 통째로 어긋납니다.**

</details>

---

## 아이템 36. 비트 필드 대신 EnumSet을 사용하라

### 한 줄 요약

플래그를 OR로 합치는 **비트 필드** 대신, 타입 안전하고 읽기 쉬운 **`EnumSet`**을 써라.

### 비유 — "체크박스 묶음"

권한을 `1|4|8`처럼 비트로 합치면 사람이 못 읽습니다. `EnumSet.of(READ, WRITE)`는 체크박스를 표시하듯 직관적입니다(내부적으로는 비트벡터라 성능도 좋음).

### 문제 → 해법

```java
// ❌ 비트 필드: 의미 불명, 타입 안전성 없음
public static final int STYLE_BOLD      = 1 << 0;
public static final int STYLE_ITALIC    = 1 << 1;
text.applyStyles(STYLE_BOLD | STYLE_ITALIC);   // 1|2 = 3 ... 뭐였더라?

// ✅ EnumSet: 타입 안전 + 가독성 + 내부적으로 비트벡터(빠름)
public enum Style { BOLD, ITALIC, UNDERLINE }
text.applyStyles(EnumSet.of(Style.BOLD, Style.ITALIC));
```

### 현업 예제 — 권한 집합

```java
public enum Permission { READ, WRITE, DELETE, ADMIN }

EnumSet<Permission> editor = EnumSet.of(Permission.READ, Permission.WRITE);
if (editor.contains(Permission.DELETE)) { /* ... */ }   // 의도가 명확
```

### 퀴즈

<details><summary>Q. EnumSet이 비트 필드의 장점(성능)도 가져가는 이유는?</summary>

내부적으로 **비트 벡터로 구현**되어 있어, 가독성·타입 안전을 얻으면서도 비트 연산 수준의 성능을 유지합니다.

</details>

---

## 아이템 37. ordinal 인덱싱 대신 EnumMap을 사용하라

### 한 줄 요약

enum을 키로 한 배열을 `ordinal()`로 인덱싱하지 마라. **`EnumMap`**을 써라.

### 비유 — "이름표 달린 서랍"

번호(ordinal)로 서랍을 찾으면 순서가 바뀔 때 엉뚱한 서랍을 엽니다. `EnumMap`은 **enum 이름표**가 붙은 서랍이라 안전하고, 내부적으로 배열만큼 빠릅니다.

### 문제 → 해법

```java
// ❌ ordinal로 배열 인덱싱: 비검사 형변환 + 순서 의존 + 범위 오류 위험
Set<Plant>[] plantsByLifeCycle = new Set[LifeCycle.values().length];

// ✅ EnumMap: 타입 안전 + 가독성
Map<LifeCycle, Set<Plant>> byCycle = new EnumMap<>(LifeCycle.class);
for (Plant p : garden) {
    byCycle.computeIfAbsent(p.lifeCycle, k -> new HashSet<>()).add(p);
}
```

스트림으로는 `groupingBy(p -> p.lifeCycle, () -> new EnumMap<>(...), toSet())`로도 만듭니다.

### 퀴즈

<details><summary>Q. EnumMap이 "ordinal 인덱싱 배열"의 성능을 거의 그대로 가져가는 이유는?</summary>

내부적으로 **배열로 구현**되어 있어, 배열 인덱싱과 비슷한 성능을 내면서도 타입 안전과 가독성을 제공합니다.

</details>

---

## 아이템 38. 확장할 수 있는 열거 타입이 필요하면 인터페이스를 사용하라

### 한 줄 요약

enum은 상속할 수 없다. 확장이 필요하면 **인터페이스를 구현하는 enum**으로 풀어라.

### 비유 — "공통 규격을 따르는 별개의 enum들"

enum끼리는 가문을 잇지(상속) 못하지만, 같은 **자격증(인터페이스)**을 가질 수는 있습니다. 그러면 서로 다른 enum을 같은 타입으로 다룰 수 있습니다.

### 예제

```java
public interface Operation { double apply(double x, double y); }

public enum BasicOperation implements Operation {
    PLUS  { public double apply(double x, double y) { return x + y; } },
    MINUS { public double apply(double x, double y) { return x - y; } };
}
// 다른 모듈에서 확장
public enum ExtendedOperation implements Operation {
    EXP { public double apply(double x, double y) { return Math.pow(x, y); } };
}
```

`Operation` 타입으로 받으면 두 enum을 모두 쓸 수 있습니다.

### 퀴즈

<details><summary>Q. enum을 직접 상속(extends)할 수 없는 이유는?</summary>

모든 enum은 암묵적으로 `java.lang.Enum`을 상속하고 있어, 추가 상속이 불가능합니다. 그래서 확장은 **공통 인터페이스 구현**으로 풉니다.

</details>

---

## 아이템 39. 명명 패턴보다 애너테이션을 사용하라 ⭐핵심

### 한 줄 요약

"이름이 test로 시작하면 테스트" 같은 **명명 패턴**을 버리고, **애너테이션**으로 메타데이터를 명시하라. (JUnit·Spring의 기반)

### 비유 — "약속한 이름 규칙 vs 명시적 스티커"

- 명명 패턴: "메서드 이름을 test로 시작하기로 약속하자" → 오타(`tset`)면 조용히 무시됨, 강제력 없음.
- 애너테이션: 메서드에 `@Test` **스티커**를 직접 붙임 → 도구가 스티커를 정확히 인식, 매개변수도 전달 가능.

### 직접 만들어 보는 @Test (원리 이해)

```java
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)   // 런타임에 리플렉션으로 읽을 수 있게
@Target(ElementType.METHOD)           // 메서드에만 부착 가능
public @interface Test { }
```

이 스티커를 리플렉션으로 읽어 실행하는 "미니 테스트 러너":

```java
public static void main(String[] args) throws Exception {
    Class<?> testClass = Class.forName(args[0]);
    for (Method m : testClass.getDeclaredMethods()) {
        if (m.isAnnotationPresent(Test.class)) {   // 스티커가 붙은 메서드만
            try {
                m.invoke(null);
                System.out.println(m.getName() + " 통과");
            } catch (Exception e) {
                System.out.println(m.getName() + " 실패: " + e.getCause());
            }
        }
    }
}
```

**이게 바로 JUnit과 Spring이 동작하는 원리입니다.** 애너테이션을 붙이고, 프레임워크가 리플렉션으로 읽어 처리합니다.

### 매개변수를 받는 애너테이션

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTest {
    Class<? extends Throwable> value();   // 기대 예외를 인자로
}

@ExceptionTest(ArithmeticException.class)
public static void divideByZero() { int x = 1 / 0; }
```

### 현업 예제 — 우리가 매일 쓰는 애너테이션

- Spring: `@Component`, `@Service`, `@Transactional`, `@RequestMapping`
- JPA: `@Entity`, `@Id`, `@Column`
- 검증: `@NotNull`, `@Valid` 이들은 전부 "스티커 + 그것을 읽는 프로세서/프레임워크" 구조입니다. 직접 도메인용 애너테이션(`@MaskLog`, `@AuditTrail` 등)을 만들 수도 있습니다.

### 따라하기 (실습 39-A)

1. 위 `@Test` 애너테이션과 미니 러너를 직접 구현해, 애너테이션 붙은 메서드만 실행되는 것을 확인한다.
2. `@ExceptionTest`로 "기대한 예외가 나면 통과"하는 러너로 확장한다.
3. (심화) `@Retention(SOURCE)`로 바꾸면 왜 리플렉션으로 못 읽는지 관찰한다.

### 체크리스트

- [ ] "이름 규칙"에 동작을 의존하고 있지 않은가? → 애너테이션
- [ ] 런타임에 읽어야 하면 `@Retention(RUNTIME)`인가?
- [ ] 부착 위치를 `@Target`으로 제한했는가?

### 퀴즈

<details><summary>Q. <code>@Retention(SOURCE)</code> 애너테이션을 리플렉션으로 읽을 수 없는 이유는?</summary>

`SOURCE`는 컴파일 단계까지만 존재하고 **클래스 파일/런타임에는 남지 않기** 때문입니다. 런타임 리플렉션으로 읽으려면 `RUNTIME`이어야 합니다.

</details>

---

## 아이템 40. @Override 애너테이션을 일관되게 사용하라

### 한 줄 요약

상위 타입의 메서드를 재정의할 때는 **항상 `@Override`**를 붙여라. 오타·시그니처 실수를 컴파일러가 잡아준다.

### 비유 — "부모 것을 덮어쓴다는 도장"

"이건 부모 메서드를 덮어쓰는 겁니다"라고 도장을 찍어두면, 실수로 시그니처가 어긋나(덮어쓰기 실패) 별개 메서드가 되는 사고를 컴파일러가 막아줍니다.

### 예제

```java
// ❌ @Override 없음 + equals 시그니처 실수 → 재정의가 아니라 다중정의(오버로드)
public boolean equals(Bigram b) { ... }   // Object가 아니라 Bigram을 받음 → 의도와 다름

// ✅ @Override가 있으면 컴파일 에러로 즉시 발각
@Override public boolean equals(Object o) { ... }
```

아이템 10(equals)에서 본 함정이 바로 이것입니다. `@Override`만 붙였어도 컴파일 단계에서 잡혔습니다.

### 체크리스트

- [ ] 재정의 메서드마다 `@Override`를 붙였는가?
- [ ] IDE의 "missing @Override" 검사를 켰는가?

### 퀴즈

<details><summary>Q. @Override가 잡아주는 대표적 실수는?</summary>

재정의 의도였으나 **시그니처가 달라(예: Object 대신 구체 타입) 다중정의**가 되어버리는 실수를, 컴파일 에러로 즉시 발견하게 해줍니다.

</details>

---

## 아이템 41. 정의하려는 것이 타입이라면 마커 인터페이스를 사용하라

### 한 줄 요약

"이 클래스는 어떤 속성을 가진다"를 **타입으로** 표시하려면, 마커 애너테이션보다 **마커 인터페이스**가 낫다(컴파일 타임 검사 가능).

### 비유 — "자격증(타입) vs 스티커(메타데이터)"

마커 인터페이스(`Serializable`)는 "이 타입은 직렬화 가능"이라는 **자격증**이라, 그 타입을 요구하는 자리에 컴파일러가 강제할 수 있습니다. 마커 애너테이션은 단순 **표시(스티커)**라 타입 검사에 쓰기 어렵습니다.

### 핵심

- 마커 인터페이스: 메서드 없는 인터페이스(`Serializable`, `Cloneable`). **컴파일 타임에 타입으로 검사** 가능.
- 마커 애너테이션: `@FunctionalInterface` 등. 클래스·메서드 외 요소에도 붙일 수 있어 더 유연하지만, 타입 보장은 약함.
- "타입을 정의"하는 거면 인터페이스, "임의의 프로그램 요소에 메타데이터"면 애너테이션.

### 퀴즈

<details><summary>Q. 마커 인터페이스가 마커 애너테이션보다 나은 결정적 한 가지는?</summary>

**컴파일 타임 타입 검사**가 가능합니다. 그 타입을 요구하는 매개변수/필드 자리에서 컴파일러가 강제할 수 있습니다.

</details>

---

## 6장 종합 정리

### 한눈에 보는 결정 가이드

|상황|선택|
|---|---|
|관련 상수 묶음|**enum(34)**, 상수별 동작은 메서드로|
|enum의 부가 값|ordinal 금지 → **인스턴스 필드(35)**|
|플래그 집합|비트필드 금지 → **EnumSet(36)**|
|enum 키 매핑|ordinal 인덱싱 금지 → **EnumMap(37)**|
|enum 확장|**인터페이스 구현(38)**|
|메타데이터 표현|명명 패턴 금지 → **애너테이션(39)**|
|재정의|**항상 @Override(40)**|
|타입 표시|**마커 인터페이스(41)**|

### 종합 체크리스트 (코드 리뷰용)

- [ ] 도메인 상수를 enum으로 모델링했는가 (JPA는 `@Enumerated(STRING)`)
- [ ] `ordinal()`을 애플리케이션 로직/저장에 쓰고 있지 않은가
- [ ] 플래그/매핑에 EnumSet/EnumMap을 썼는가
- [ ] 메타데이터를 이름 규칙이 아니라 애너테이션으로 표현했는가
- [ ] 모든 재정의에 `@Override`가 붙어 있는가

### 종합 퀴즈

<details><summary>Q1. enum과 애너테이션을 한 문장으로 대비하면?</summary>

enum은 "**값을 정해진 집합으로 제한**"하는 도구, 애너테이션은 "**코드에 메타데이터를 붙여 도구가 읽게**"하는 도구다.

</details> <details><summary>Q2. <code>@Transactional</code>이 6장의 어떤 아이템을 구현한 것인가?</summary>

아이템 39, **애너테이션**(메타데이터를 붙이고 Spring이 리플렉션/프록시로 읽어 처리).

</details> <details><summary>Q3. 계약상태를 enum으로 만들 때 얻는 가장 큰 도메인적 이점은?</summary>

잘못된 값 차단에 더해, **상태 전이 규칙 같은 불변식을 enum 안에 캡슐화**해 도메인이 스스로 무결성을 지키게 할 수 있다.

</details>

---

## 다음 장 예고 — 7장: 람다와 스트림

익명 클래스 대신 람다, 메서드 참조, 표준 함수형 인터페이스, 그리고 **스트림을 언제 쓰고 언제 피할지**를 다룹니다. 현업에서 가장 자주 쓰이지만 가독성·성능 면에서 오남용도 잦은 장입니다.

> 이어서 만들까요? (7장으로 진행 / 8장 메서드로 점프 / 지금까지 만든 장들을 통합 교재로 묶기)