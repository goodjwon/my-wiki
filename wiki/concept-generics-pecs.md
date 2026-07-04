---
title: "한정적 와일드카드 (PECS) — Producer Extends, Consumer Super"
type: concept
tags: [java, generics, wildcard, pecs, effective-java, api-design]
sources:
  - effective_java/이펙티브 자바 실전 강의 교재 5장.md
external:
  - https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collections.html
  - https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html
  - https://dev.java/learn/generics/wildcards/
created: 2026-07-04
updated: 2026-07-04
---

# 한정적 와일드카드 (PECS) — Producer Extends, Consumer Super

## 정의

PECS는 제네릭 메서드의 매개변수에 어느 방향의 와일드카드를 붙일지 정하는 공식입니다. 매개변수가 데이터를 **꺼내 주는 생산자(Producer)라면 `? extends T`**, 데이터를 **받아 담는 소비자(Consumer)라면 `? super T`** 를 씁니다. *Effective Java* 아이템 31의 핵심 권고이며, 컬렉션을 받는 API의 유연성이 이 한 줄에서 갈립니다.

> 청과물 도매상은 거래처를 두 종류로 나눠 관리합니다. 과일을 공급해 주는 납품 농가에서는 어떤 상자가 와도 좋습니다. 사과 상자든 후지사과 상자든, 결국 전부 "과일"로 받아서 진열하면 되기 때문입니다. 반대로 팔고 남은 과일을 실어 가는 수거업체 쪽은, 트럭 짐칸이 "과일 전용"일 필요가 없습니다. 과일도 싣고 다른 농산물도 싣는 더 넓은 짐칸이면 오히려 좋습니다.
>
> 제네릭 매개변수도 같은 구분을 따릅니다. 데이터를 공급받는 쪽(생산자)은 T의 하위 타입까지 전부 받도록 `? extends T`로 열어 두고, 데이터를 실어 보내는 쪽(소비자)은 T의 상위 타입 컨테이너까지 허용하도록 `? super T`로 열어 둡니다.

## 왜 필요한가 — 제네릭은 불공변

와일드카드가 없으면 어떤 문제가 생기는지부터 봅니다. 배열은 공변이라 `Integer[]`를 `Number[]` 자리에 넣을 수 있지만, 제네릭은 불공변이라 `List<Integer>`는 `List<Number>`의 하위 타입이 아닙니다(아이템 28, [[lecture-effective-java-ch5]] 참조). 그래서 아래 코드는 직관과 달리 컴파일되지 않습니다.

```java
Stack<Number> numberStack = new Stack<>();
Iterable<Integer> integers = List.of(1, 2, 3);
numberStack.pushAll(integers);
// ❌ 컴파일 오류 — pushAll(Iterable<Number>)에 Iterable<Integer>를 못 넘김
```

논리적으로는 Integer가 Number이므로 넣을 수 있어야 합니다. 이 간극을 사용 지점에서 메우는 장치가 한정적 와일드카드입니다. 선언 시점이 아니라 **메서드 시그니처에서 그때그때 변성(variance)을 열어 주는** 방식이라 use-site variance라고 부릅니다.

## 공변·반공변 — 방향이 다른 이유

`? extends`와 `? super`가 각각 어느 방향으로 안전한지는 읽기와 쓰기로 갈립니다.

| 표기 | 변성 | 안전한 방향 | 이유 |
|------|------|------------|------|
| `List<? extends Number>` | 공변(covariant) | **읽기만** | 원소는 Number의 어떤 하위 타입인지 모르지만, 꺼내면 반드시 Number입니다 |
| `List<? super Integer>` | 반공변(contravariant) | **쓰기만** | 컨테이너가 Integer 이상을 담는 통이므로, Integer를 넣는 것은 항상 안전합니다 |
| `List<Number>` | 불공변(invariant) | 읽기·쓰기 모두 | 정확한 타입이므로 제약이 없는 대신 유연성도 없습니다 |

읽기 쪽 장면을 그려 보면 이렇습니다. `List<? extends Number>`는 "Number 계열 무언가의 리스트"라서 실제로는 `List<Integer>`일 수도 `List<Double>`일 수도 있습니다. 꺼낸 원소를 Number로 받는 것은 항상 성립하지만, 거꾸로 무언가를 넣으려는 순간 컴파일러는 실제 리스트가 어느 쪽인지 모르므로 전부 거부합니다(`null`만 예외). 그래서 extends는 자연히 생산 전용이 됩니다.

쓰기 쪽은 반대입니다. `List<? super Integer>`는 `List<Integer>`, `List<Number>`, `List<Object>` 중 무엇이든 될 수 있고, 그 어느 쪽이라도 Integer를 담는 데는 문제가 없습니다. 대신 꺼낼 때는 어떤 상위 통인지 모르므로 `Object`로만 받을 수 있습니다. 그래서 super는 자연히 소비 전용이 됩니다.

## 표준 예제 — Stack의 pushAll / popAll

아이템 31의 대표 예제입니다. 스택에 원소를 채우는 `pushAll`은 src에서 꺼내 읽으므로 생산자, 스택을 비워 옮겨 담는 `popAll`은 dst에 넣으므로 소비자입니다.

```java
public class Stack<E> {
    // src는 원소를 '꺼내 주는' 생산자 → ? extends E
    public void pushAll(Iterable<? extends E> src) {
        for (E e : src) push(e);
    }

    // dst는 원소를 '받아 담는' 소비자 → ? super E
    public void popAll(Collection<? super E> dst) {
        while (!isEmpty()) dst.add(pop());
    }
}
```

이렇게 바꾸면 앞에서 실패했던 호출이 전부 통과합니다.

```java
Stack<Number> stack = new Stack<>();
stack.pushAll(List.of(1, 2, 3));            // Iterable<Integer> OK — extends 덕분
Collection<Object> objects = new ArrayList<>();
stack.popAll(objects);                       // Collection<Object> OK — super 덕분
```

## 상황별 선택표

시그니처를 설계할 때 매개변수의 역할만 판정하면 와일드카드가 자동으로 정해집니다.

| 매개변수 역할 | 선택 | 근거 |
|--------------|------|------|
| 생산자 — T를 꺼내 읽기만 함 | `? extends T` | 하위 타입 컬렉션까지 수용, 읽기는 항상 T로 안전 |
| 소비자 — T를 받아 담기만 함 | `? super T` | 상위 타입 컨테이너까지 수용, T 쓰기는 항상 안전 |
| 생산자 겸 소비자 — 읽고 씀 | 와일드카드 없이 정확한 `T` | 양방향이 필요하므로 타입을 고정해야 합니다 |
| 반환 타입 | 와일드카드 금지 | 클라이언트 코드까지 와일드카드가 번져 사용성이 나빠집니다 |
| `Comparable` / `Comparator` | 언제나 `Comparable<? super T>` | 비교자는 T를 인자로 받아 소비하는 쪽입니다 |

## JDK 실제 시그니처로 검증

PECS는 교과서 규칙이 아니라 JDK 표준 라이브러리가 그대로 따르는 설계입니다. 아래 시그니처는 Oracle Java 21 공식 API 문서에서 확인한 원문입니다.

| 메서드 | 시그니처 (Java 21 공식 문서) | PECS 해석 |
|--------|------------------------------|-----------|
| `Collections.copy` | `static <T> void copy(List<? super T> dest, List<? extends T> src)` | dest는 담는 소비자 → super, src는 꺼내는 생산자 → extends |
| `Collections.max` | `static <T> T max(Collection<? extends T> coll, Comparator<? super T> comp)` | coll은 생산자 → extends, 비교자는 소비자 → super |
| `Collections.addAll` | `static <T> boolean addAll(Collection<? super T> c, T... elements)` | c는 원소를 받아 담는 소비자 → super |
| `Stream.map` | `<R> Stream<R> map(Function<? super T, ? extends R> mapper)` | 함수 입력은 T를 소비 → super, 함수 출력은 R을 생산 → extends |
| `Stream.forEach` | `void forEach(Consumer<? super T> action)` | action은 T를 소비 → super |

`Stream.map`이 특히 좋은 교재입니다. `Function<? super T, ? extends R>` 한 시그니처 안에 PECS 양쪽이 다 들어 있습니다. 함수의 입력 자리는 스트림 원소 T를 받아 소비하므로 super, 함수의 출력 자리는 새 스트림에 넣을 R을 생산하므로 extends입니다. 덕분에 아래처럼 더 일반적인 함수를 그대로 재사용할 수 있습니다.

```java
Function<Object, Integer> hash = Object::hashCode;   // Object를 받는 더 일반적인 함수
Stream<Integer> hashes = Stream.of("a", "bb").map(hash);
// Function<? super String, ? extends Integer> 자리에 Function<Object, Integer>가 들어감
```

## 자주 나는 컴파일 오류 → 원인

와일드카드 관련 컴파일 오류는 메시지가 낯설어서 원인을 못 찾기 쉽습니다. 대표 4가지를 정리합니다.

| 오류 메시지 (요약) | 재현 코드 | 원인 | 해법 |
|--------------------|----------|------|------|
| `incompatible types: List<Integer> cannot be converted to List<Number>` | `void sum(List<Number> l)`에 `List<Integer>` 전달 | 제네릭 불공변 — 하위 타입 컬렉션은 별개 타입 | 매개변수를 `List<? extends Number>`로 |
| `no suitable method found for add(int)` / `capture of ? extends Number` | `List<? extends Number> l; l.add(1);` | extends는 실제 원소 타입 미상 → 쓰기 전면 금지(`null` 제외) | 넣어야 한다면 `? super` 또는 정확한 타입으로 |
| `incompatible types: Object cannot be converted to Integer` | `List<? super Integer> l; Integer i = l.get(0);` | super는 어느 상위 통인지 미상 → 읽으면 `Object`로만 나옴 | 읽어야 한다면 `? extends` 또는 정확한 타입으로 |
| 호출부마다 와일드카드 형변환·경고가 번짐 | 반환 타입을 `List<? extends T>`로 선언 | 반환 와일드카드는 클라이언트 코드로 전파됨 | 반환 타입은 와일드카드 없이 선언 |

표의 2·3행이 곧 PECS의 증명입니다. extends 쪽은 컴파일러가 쓰기를 막아 읽기 전용이 되고, super 쪽은 읽기가 `Object`로 뭉개져 쓰기 전용이 됩니다. 규칙을 외우지 않아도 컴파일러가 방향을 강제합니다.

## 같은 인사이트 패턴 — "제약을 타입으로 강제해 실수를 컴파일 타임으로 앞당김"

PECS의 본질은 "읽기 전용·쓰기 전용이라는 사용 방향을 주석이 아니라 타입 시스템에 새겨서, 위반을 컴파일 오류로 만드는 것"입니다. 위키의 다른 페이지에도 같은 구조의 인사이트가 누적되어 있습니다.

| 페이지 | 무엇을 타입·구조로 강제 | 막아 주는 사고 |
|--------|------------------------|---------------|
| (이 페이지) PECS | 매개변수의 데이터 흐름 방향 — extends는 읽기, super는 쓰기 | 잘못된 방향의 add/get을 컴파일 오류로 차단 |
| [[lecture-effective-java-ch4]] 아이템 17 불변 클래스 | 상태 변경 가능성 자체를 타입에서 제거 | 공유 객체가 몰래 바뀌는 동시성·별칭 버그 |
| [[lecture-effective-java-ch8]] 아이템 50 방어적 복사 | 가변 타입이 경계를 넘을 때 복사로 격리 | 외부 참조를 통한 내부 상태 훼손 |
| [[concept-jspecify-null-safety]] JSpecify | null 가능 여부를 타입 표기에 포함 | NPE를 런타임에서 컴파일 타임으로 |
| [[java-study-ch03]] 3.1 제네릭 기초 | 컬렉션 원소 타입을 선언에 라벨링 | `ClassCastException`을 런타임에서 컴파일 타임으로 |

→ 공통 원리는 하나입니다. 지켜야 할 규칙을 문서·리뷰·컨벤션에 맡기지 않고 **타입 시스템에 넣으면 컴파일러가 24시간 무료로 지켜 줍니다**. PECS는 그 원리를 "데이터 흐름의 방향"에 적용한 사례입니다.

## 빠른 진단 체크리스트

컬렉션·함수형 인터페이스를 받는 public 메서드를 설계할 때 순서대로 점검합니다.

- [ ] 이 매개변수에서 원소를 꺼내 읽기만 하는가 → `? extends T`
- [ ] 이 매개변수에 원소를 넣기만 하는가 → `? super T`
- [ ] 읽고 쓰기를 둘 다 하는가 → 와일드카드 없이 정확한 `T`
- [ ] 반환 타입에 와일드카드를 쓰지 않았는가
- [ ] `Comparator`/`Comparable` 매개변수에 `? super`를 적용했는가
- [ ] `List<Integer>`를 넘기는 호출부가 컴파일되는지(유연성) 실제로 확인했는가

## 원본 출처

- `raw/effective_java/이펙티브 자바 실전 강의 교재 5장.md` — 아이템 31 (위키 페이지: [[lecture-effective-java-ch5]])
- Oracle Java 21 API — [Collections](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collections.html) · [Stream](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html) (시그니처 원문 검증)
- [dev.java — Wildcards](https://dev.java/learn/generics/wildcards/) (공식 튜토리얼)

## 관련 페이지

- [[lecture-effective-java-ch5]] — 5장 제네릭 강의노트 (아이템 26~33 전체, 이 페이지의 원 소스)
- [[entity-effective-java]] — *Effective Java* 책 전체 지도 (⭐ 현업 최핵심 20 아이템에 Item 31 포함)
- [[java-study-ch03]] — 3.1 컬렉션 프레임워크와 제네릭 (제네릭 기초·와일드카드 입문)
- [[concept-jspecify-null-safety]] — 같은 패턴: null 제약을 타입으로 강제
- [[src-effective-java-lecture]] — 강의 교재 11장 인덱스
