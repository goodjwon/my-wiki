---
title: 표준 함수형 인터페이스 (java.util.function)
type: concept
tags: [java, functional-interface, lambda, effective-java, spring, item-44]
sources: [effective_java/이펙티브 자바 실전 강의 교재 7장.md]
created: 2026-07-04
updated: 2026-07-04
---

# 표준 함수형 인터페이스 — java.util.function

## 정의

함수형 인터페이스는 추상 메서드가 정확히 1개인 인터페이스로, 람다와 메서드 참조를 담는 그릇입니다. Java 8이 `java.util.function` 패키지에 **43개의 표준 함수형 인터페이스**를 제공하며(Java 17 공식 API 문서 기준으로도 43개 동일), *Effective Java* Item 44의 결론은 한 문장입니다 — **필요한 용도에 맞는 게 있다면 직접 만들지 말고 표준 함수형 인터페이스를 사용하라**. 43개를 다 외울 필요는 없고, 기본형 6개만 외우면 나머지는 이름 규칙으로 유도할 수 있습니다.

> **비유 — 표준 공구 규격**
>
> 정비소에 새 볼트가 들어올 때마다 전용 렌치를 깎아 만드는 정비사는 없습니다. 볼트는 이미 규격대로 만들어져 있고, 벽에 걸린 표준 렌치 세트에서 맞는 치수를 꺼내 쓰면 됩니다. 직접 깎은 렌치는 그 정비소 안에서만 통하지만, 표준 렌치는 어느 정비소에 가져가도 같은 볼트에 맞습니다. `java.util.function`이 바로 이 표준 렌치 세트이고, 직접 정의한 `MyConverter` 같은 인터페이스는 남들이 쓸 수 없는 수제 렌치입니다.

## 기본형 6개 — 반드시 암기

6개 기본형의 시그니처와 용도입니다. 나머지 37개는 전부 이 6개의 변형입니다.

| 인터페이스 | 추상 메서드 | 의미 | 대표 사용처 |
|-----------|------------|------|-------------|
| `Function<T,R>` | `R apply(T t)` | 1입력 → 1출력 (타입 변환) | `Stream.map`, `Optional.map` |
| `Predicate<T>` | `boolean test(T t)` | 1입력 → 참/거짓 | `Stream.filter`, `Collection.removeIf` |
| `Consumer<T>` | `void accept(T t)` | 1입력 → 소비 (반환 없음) | `Stream.forEach`, `Iterable.forEach` |
| `Supplier<T>` | `T get()` | 입력 없음 → 1출력 (지연 생성) | `Optional.orElseGet`, `Stream.generate` |
| `UnaryOperator<T>` | `T apply(T t)` | 같은 타입 1입력 → 1출력 | `List.replaceAll`, `String::trim` |
| `BinaryOperator<T>` | `T apply(T a, T b)` | 같은 타입 2입력 → 1출력 | `Stream.reduce`, `Map.merge` |

`UnaryOperator<T>`는 `Function<T,T>`를, `BinaryOperator<T>`는 `BiFunction<T,T,T>`를 상속한 특수형입니다. "입력과 출력 타입이 같다"는 의도를 이름으로 드러낼 때 씁니다.

43개 전체의 구성은 다음과 같이 유도됩니다.

| 그룹 | 개수 | 예시 |
|------|------|------|
| 기본형 | 6 | 위 표 |
| 기본 타입(int/long/double) 특화 — 기본형 × 3 | 18 | `IntPredicate`, `LongBinaryOperator`, `DoubleConsumer` |
| `Function`의 기본 타입 반환 변형 | 9 | `IntToLongFunction`, `ToIntFunction<T>` |
| 인수 2개 `Bi` 변형 | 9 | `BiFunction<T,U,R>`, `BiPredicate<T,U>`, `ObjIntConsumer<T>` |
| `BooleanSupplier` | 1 | boolean 반환 Supplier |

## 기본형 특화와 박싱 비용

`Function<Integer, Integer>`처럼 제네릭에 래퍼 타입을 넣으면 호출마다 박싱·언박싱이 일어납니다. 같은 계산을 기본형 특화로 바꾸면 이 비용이 사라집니다.

**박싱 비교**: 아래 두 줄은 같은 일을 하지만 메모리 동작이 다릅니다.

```java
Function<Integer, Integer> boxed = x -> x * 2;   // 호출마다 Integer 박싱/언박싱
IntUnaryOperator primitive = x -> x * 2;         // int 그대로 — 박싱 없음
```

대량 반복이 도는 핫패스(스트림 백만 건 처리, 배치 계산)에서는 차이가 누적되므로 `IntStream`/`IntPredicate`/`ToIntFunction` 계열을 우선합니다. 반대로 호출 빈도가 낮은 일반 비즈니스 로직에서는 가독성을 해치면서까지 특화형을 고집할 이유가 없습니다.

## Item 44 원칙 — 직접 만들지 말고 표준을 써라

**안티패턴**: 표준에 이미 있는 시그니처를 새 이름으로 다시 만드는 경우입니다.

```java
// ❌ Function<T, R>과 시그니처가 완전히 같음
@FunctionalInterface
interface MyConverter<T, R> {
    R convert(T value);
}
```

직접 만든 인터페이스는 표준 API(`Stream.map` 등)와 호환되지 않고, 읽는 사람이 새 어휘를 학습해야 하며, `andThen`/`compose` 같은 디폴트 메서드도 없습니다.

### 직접 만들어도 되는 예외 3조건

`Comparator<T>`는 구조상 `ToIntBiFunction<T,T>`와 같지만 별도 인터페이스로 살아남았습니다. 그 이유가 곧 예외 조건입니다. 다음 중 하나 이상을 만족하면 전용 함수형 인터페이스가 정당합니다.

1. **이름 자체가 용도를 훌륭하게 설명** — `Comparator`라는 이름이 "두 값을 비교한다"는 계약을 즉시 전달합니다.
2. **반드시 따라야 하는 규약이 있음** — `compare`는 반사성·대칭성·추이성 규약을 집니다. 표준 인터페이스에는 이런 규약을 실을 자리가 없습니다.
3. **유용한 디폴트 메서드를 제공** — `reversed()`, `thenComparing()` 같은 조합 메서드가 인터페이스의 가치를 키웁니다.

여기에 실무 조건 하나를 더하면, **검사 예외를 던져야 할 때**도 전용 인터페이스가 필요합니다(`Function.apply`는 검사 예외를 던질 수 없음). Spring의 `TransactionCallback<T>`이 좋은 예로, 구조는 `Function<TransactionStatus, T>`와 같지만 "트랜잭션 경계 안에서 실행된다"는 규약을 이름에 실었습니다.

전용 인터페이스를 만들기로 했다면 `@FunctionalInterface`를 항상 붙입니다. 누군가 추상 메서드를 추가하는 실수를 컴파일 오류로 막아 주고, 람다용 인터페이스라는 설계 의도를 문서화합니다.

## Spring 활용 — 표준 인터페이스가 곧 API가 되는 자리

Spring 생태계는 표준 함수형 인터페이스를 설정·라우팅·함수 노출의 1급 시민으로 씁니다. 실무에서 자주 만나는 세 자리를 예제로 정리합니다.

### 1. 함수형 엔드포인트 — RouterFunction (WebMvc.fn / WebFlux.fn)

`@Controller` 애너테이션 대신 람다·메서드 참조로 라우팅을 선언하는 방식입니다. 핸들러 자리는 `HandlerFunction<ServerResponse>`(`ServerRequest → ServerResponse` 모양의 전용 함수형 인터페이스)이며, 메서드 참조가 그대로 들어갑니다.

```java
@Configuration
public class OrderRoutes {

    @Bean
    public RouterFunction<ServerResponse> orderRouter(OrderHandler handler) {
        return RouterFunctions.route()
                .GET("/orders/{id}", handler::findById)   // HandlerFunction 자리에 메서드 참조
                .POST("/orders", handler::create)
                .build();
    }
}
```

### 2. Spring Cloud Function — Function/Supplier/Consumer 빈이 곧 함수

`Function`·`Supplier`·`Consumer` 타입 빈을 등록하면 FunctionCatalog에 자동 수집되고, `spring-cloud-function-web`을 쓰면 빈 이름이 그대로 HTTP 엔드포인트가 됩니다(공식 레퍼런스에서 확인한 동작). 같은 빈이 AWS Lambda·Spring Cloud Stream 어댑터로도 재사용됩니다.

```java
@SpringBootApplication
public class FunctionApp {

    @Bean
    public Function<String, String> uppercase() {   // POST /uppercase
        return String::toUpperCase;
    }

    @Bean
    public Supplier<List<String>> words() {         // GET /words
        return () -> List.of("java", "spring");
    }
}
```

### 3. Supplier 지연 평가 — 빈 등록과 orElseGet

`Supplier`의 본질은 "값이 필요해질 때까지 생성을 미룬다"입니다. Spring 5+의 프로그래매틱 빈 등록과 `Optional.orElseGet`이 대표 사용처입니다.

```java
// 리플렉션 없이 Supplier로 빈 등록 — 생성 시점이 컨테이너에 위임됨
context.registerBean(OrderService.class,
        () -> new OrderService(context.getBean(OrderRepository.class)));

// orElse는 값이 있어도 기본값을 항상 만들고, orElseGet은 없을 때만 만듦
Order fallback = repository.findById(id)
        .orElseGet(Order::empty);   // Supplier — 필요할 때만 생성
```

## 같은 인사이트 패턴 — 표준 어휘를 재사용하면 학습·합의 비용이 준다

Item 44의 본질은 성능이 아니라 **어휘의 경제학**입니다. 모두가 아는 이름을 재사용하면 학습 비용과 합의 비용이 동시에 줄어든다는 인사이트가 위키의 여러 페이지에 반복됩니다.

| 위키 페이지 | 표준 어휘 | 재사용이 줄이는 비용 |
|-------------|-----------|---------------------|
| (이 페이지) Item 44 | `java.util.function` 43개 인터페이스 | 새 인터페이스 학습 비용 + 표준 API 비호환 비용 |
| [[guide-code-authoring-and-review]] | "G19", "Item 18" 같은 PR 리뷰 코드 | 리뷰 코멘트마다 근거를 다시 설명하는 합의 비용 |
| [[concept-design-patterns]] | 패턴 이름 = 팀 공용어 (Strategy, Facade) | 설계 의도를 문장으로 풀어 전달하는 소통 비용 |
| [[entity-effective-java]] | 6원칙 중 "표준을 우선" (Item 44·59·72) | 바퀴 재발명 비용 (라이브러리·표준 예외 동일 원리) |

공통 원리는 하나입니다 — **이름이 이미 공유되어 있으면 이름만 말해도 계약 전체가 전달됩니다**. 반대로 사설 어휘를 만들 때는 Comparator 3조건처럼 "이름이 새 정보를 실어 나르는가"를 증명해야 합니다.

## 빠른 진단 체크리스트

- [ ] 새 함수형 인터페이스를 만들기 전에 `java.util.function` 43개를 확인했는가?
- [ ] 만들기로 했다면 Comparator 3조건(이름 가치·규약·디폴트 메서드) 중 하나 이상을 만족하는가?
- [ ] 전용 인터페이스에 `@FunctionalInterface`를 붙였는가?
- [ ] 핫패스에서 `Function<Integer, ...>` 같은 래퍼 제네릭을 쓰고 있지 않은가? (→ `IntUnaryOperator` 등 특화형)
- [ ] `orElse(비싼생성())`을 쓰고 있지 않은가? (→ `orElseGet(Supplier)`)
- [ ] 람다가 3줄을 넘으면 메서드로 추출해 메서드 참조로 바꿨는가? ([[lecture-effective-java-ch7]] Item 42·43)

## 원본 출처

- raw: `raw/effective_java/이펙티브 자바 실전 강의 교재 7장.md` — Item 44 절 (위키 정리본: [[lecture-effective-java-ch7]])
- 검증: [java.util.function 패키지 공식 API 문서 (Java 17)](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/function/package-summary.html) — 인터페이스 43개·기본형 6개 확인
- 검증: [Spring Cloud Function — Programming Model](https://docs.spring.io/spring-cloud-function/reference/spring-cloud-function/programming-model.html) — Function/Supplier/Consumer 빈의 FunctionCatalog 등록·노출 확인

## 관련 페이지

- [[lecture-effective-java-ch7]] — 7장 전체 (Item 42~48) — 람다·메서드 참조·스트림 맥락
- [[entity-effective-java]] — 책 전체 지도, "표준을 우선" 6원칙
- [[java-study-ch03]] — 3.4 람다와 스트림 (함수형 인터페이스 입문 눈높이)
- [[guide-code-authoring-and-review]] — PR 리뷰 표준 어휘 (같은 인사이트 패턴)
- [[concept-naming-conventions]] — 이름 자체가 문서·계약이라는 관점 (같은 패턴)
- [[concept-design-patterns]] — 패턴 이름 = 팀 공용어 (같은 인사이트 패턴)
- [[concept-spring-core]] — Spring 빈·DI (registerBean·`@Bean` 팩토리의 배경)
