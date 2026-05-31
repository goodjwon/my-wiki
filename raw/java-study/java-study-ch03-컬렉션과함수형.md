# 3. 컬렉션과함수형
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 3.0 컬렉션과 함수형 개요

#### 개요

이 문서는 책의 `컬렉션과 함수형` 챕터를 안내하는 문서입니다. Java를 어느 정도 읽을 수 있게 된 시점부터는 문법 암기보다, **데이터를 어떤 구조에 담고 어떤 방식으로 흘려보낼지**를 이해하는 것이 더 중요해집니다.

#### 왜 중요한가

컬렉션과 함수형 프로그래밍은 서로 다른 주제처럼 보이지만, 실제 Java 코드에서는 함께 등장합니다. 컬렉션이 데이터를 담는 방식이라면, 람다와 스트림은 그 데이터를 읽고 변환하고 집계하는 방식입니다.

```java
List<String> names = List.of("kim", "lee", "park");
List<String> result = names.stream()
    .filter(name -> name.startsWith("k"))
    .map(String::toUpperCase)
    .toList();

System.out.println(result);
```

즉, 이 장은 `무엇을 담을 것인가`와 `그 데이터를 어떻게 흘려보낼 것인가`를 한꺼번에 배우는 장입니다.

#### 이 챕터에서 다루는 범위

- 컬렉션 프레임워크의 기본 구조
- 제네릭이 타입 안전성을 어떻게 높이는지
- 자료구조를 실제 요구사항에 연결하는 선택 시나리오
- 람다식과 함수형 인터페이스의 역할
- 스트림 파이프라인을 읽는 방법
- 실무 코드에서 자주 만나는 선택 기준과 주의점

#### 읽는 순서

1. `컬렉션 프레임워크와 제네릭`
1. `컬렉션 자료구조 활용 사례`
1. `컬렉션 선택 시나리오`
1. `람다와 스트림`

#### 정리

이 챕터의 목적은 API를 많이 외우는 것이 아닙니다. 데이터 구조와 처리 흐름을 읽는 눈을 갖추면, 이후의 Querydsl, 테스트, 서버 코드도 훨씬 빠르게 이해할 수 있습니다.

#### 한 줄 정리

`컬렉션과 함수형` 챕터의 핵심은 **데이터를 담는 방식과 처리하는 방식을 함께 이해하는 것**입니다.

---

## 3.1 컬렉션 프레임워크와 제네릭

#### 개요

이 문서는 Java에서 컬렉션 프레임워크와 제네릭을 함께 이해하기 위한 가이드입니다. 컬렉션은 데이터를 다루는 기본 도구이고, 제네릭은 그 도구를 **타입 안전하게** 쓰기 위한 장치입니다.

#### 왜 중요한가

컬렉션만 배우면 자료구조 이름을 외우는 데 그치기 쉽고, 제네릭만 배우면 문법 퍼즐처럼 느껴지기 쉽습니다. 하지만 둘을 같이 보면 `왜 List<String> 같은 선언이 필요한지`, `왜 잘못된 타입이 컴파일 단계에서 걸러지는지`가 자연스럽게 연결됩니다.

#### 1. 컬렉션 프레임워크를 어떻게 볼 것인가

Java 컬렉션 프레임워크는 데이터를 담는 공통 인터페이스와 구현 클래스를 제공합니다. 실무에서는 구현체 이름보다 먼저, 아래 질문을 보는 편이 더 낫습니다.

- 순서가 중요한가
- 중복을 허용하는가
- 키와 값으로 조회해야 하는가
- 앞뒤 삽입과 삭제가 잦은가
#### 2. 가장 자주 만나는 컬렉션 인터페이스

##### List

순서를 유지하고, 같은 값을 여러 번 담을 수 있습니다. 읽기와 인덱스 접근이 중요하면 가장 먼저 떠올리는 인터페이스입니다.

```java
List<String> fruits = new ArrayList<>();
fruits.add("Apple");
fruits.add("Banana");
fruits.add("Cherry");

for (String fruit : fruits) {
    System.out.println(fruit);
}
```

##### Set

중복을 허용하지 않습니다. 값의 존재 여부와 유일성이 더 중요할 때 자연스럽습니다.

```java
Set<Integer> numbers = new HashSet<>();
numbers.add(1);
numbers.add(2);
numbers.add(2);
numbers.add(3);

System.out.println(numbers);
```

##### Queue와 Deque

처리 순서가 중요할 때 사용합니다. 작업 대기열, 메시지 처리, BFS 같은 흐름에서 자주 만납니다.

```java
Queue<String> queue = new LinkedList<>();
queue.add("First");
queue.add("Second");
queue.add("Third");

System.out.println(queue.poll());
System.out.println(queue.poll());
```

##### Map

키로 값을 찾는 구조입니다. 조회 성격이 강한 코드를 읽을 때 가장 자주 보게 됩니다.

```java
Map<Integer, String> userMap = new HashMap<>();
userMap.put(1, "Kim");
userMap.put(2, "Lee");
userMap.put(3, "Park");

System.out.println(userMap.get(1));
for (Map.Entry<Integer, String> entry : userMap.entrySet()) {
    System.out.println(entry.getKey() + " : " + entry.getValue());
}
```

#### 3. 구현체는 언제 고를까

대부분의 초중급 실무 코드에서는 아래 정도만 먼저 익혀도 충분합니다.

- `ArrayList`: 순차 데이터와 읽기 중심 작업
- `HashSet`: 중복 제거와 포함 여부 확인
- `HashMap`: 키 기반 조회
- `ArrayDeque`: 스택과 큐를 모두 자연스럽게 처리
핵심은 “무조건 빠른 자료구조”를 찾는 것이 아니라, **현재 코드의 접근 패턴과 수정 패턴에 맞는지**를 보는 것입니다.

##### ArrayList와 LinkedList를 어떻게 구분할까

학습 단계에서는 `LinkedList`가 삽입과 삭제에 유리하다고 배우지만, 실무의 기본값은 대개 `ArrayList`입니다. 이유는 실제 서비스 코드에서 중간 노드 조작보다 순차 조회와 반복이 더 흔하고, CPU 캐시 친화성까지 고려하면 `ArrayList`가 더 예측 가능하기 때문입니다. `LinkedList`는 큐처럼 앞뒤 삽입과 삭제가 매우 분명한 구조에서만 선택해도 충분합니다.

##### Vector는 왜 거의 쓰지 않을까

`Vector`는 내부 메서드가 기본 동기화된 레거시 리스트 구현체입니다. 멀티스레드 환경이라고 해서 곧바로 `Vector`를 선택하는 것은 아닙니다. 새 코드에서는 보통 `ArrayList`를 기본값으로 두고, 정말 동시성 제어가 필요하면 별도의 동시성 컬렉션이나 상위 설계를 먼저 검토합니다.

##### Stack보다 ArrayDeque를 먼저 떠올리자

Java에서는 후입선출 구조가 필요해도 `Stack`보다 `ArrayDeque`를 우선 떠올리는 편이 낫습니다. `Stack`은 `Vector`를 상속한 레거시 타입이고, `ArrayDeque`가 스택과 큐 양쪽 모두에서 더 자연스럽고 일관된 API를 제공합니다.

#### 4. 제네릭이 필요한 이유

제네릭은 컬렉션 안에 어떤 타입이 들어가는지 컴파일 단계에서 분명하게 드러냅니다.

```java
List<String> names = new ArrayList<>();
names.add("Kim");
```

이 선언의 장점은 두 가지입니다.

- 컬렉션의 의도가 코드에 바로 드러납니다.
- 잘못된 타입 삽입이 런타임이 아니라 컴파일 단계에서 막힙니다.
제네릭은 컬렉션에만 쓰는 문법이 아니라, 같은 구조를 여러 타입에 안전하게 재사용하는 도구이기도 합니다. `day-by-java`의 단순 예제를 보면 감이 더 빠르게 잡힙니다.

```java
class Box<T> {
    private T value;

    public void setValue(T value) {
        this.value = value;
    }

    public T getValue() {
        return value;
    }
}

Box<String> stringBox = new Box<>();
stringBox.setValue("Hello, Generics!");
System.out.println(stringBox.getValue());

Box<Integer> intBox = new Box<>();
intBox.setValue(1234);
System.out.println(intBox.getValue());
```

```plain text
예상 결과
Hello, Generics!
1234
```

여기서 중요한 점은 `Box` 구조는 같지만, `String`과 `Integer`를 각각 다른 타입 안전성 아래에서 다룬다는 것입니다. 즉, 제네릭은 문법 장식이 아니라 **재사용성과 타입 안정성을 같이 잡는 장치**입니다.

#### 5. 제네릭을 읽는 기본 규칙

##### 타입 파라미터

`List<String>`에서 `String`은 이 컬렉션이 어떤 타입을 담는지 설명합니다.

##### 메서드 제네릭

제네릭은 클래스뿐 아니라 메서드에도 붙을 수 있습니다. 이때 중요한 것은 **반복을 줄이기 위한 문법 장식**이 아니라, 같은 로직을 여러 타입에 안전하게 적용하는 구조라는 점입니다.

```java
public static <T> void printAll(List<T> items) {
    for (T item : items) {
        System.out.println(item);
    }
}
```

##### 와일드카드

`?`, `? extends`, `? super`는 처음부터 깊게 파고들기보다, 읽기 전용인지 쓰기 중심인지 구분하는 정도로 먼저 이해하면 충분합니다.

```java
public static void printNumbers(List<? extends Number> numbers) {
    for (Number number : numbers) {
        System.out.println(number);
    }
}
```

#### 6. 실무에서 자주 하는 실수

- `List`, `Map` 인터페이스가 아니라 구현체 타입으로 필드를 고정하는 것
- 제네릭을 생략한 raw type을 사용하는 것
- 자료구조의 역할보다 익숙한 구현체만 반복해서 쓰는 것
- `LinkedList`를 막연히 “삽입이 빠르다”는 이유만으로 기본값처럼 쓰는 것
#### 실무 연결 포인트

컬렉션과 제네릭 감각이 약하면 DTO 리스트 처리, 요청/응답 매핑, Querydsl 결과 가공, 테스트 데이터 준비가 모두 불안정해집니다. 반대로 이 감각이 잡히면 프레임워크를 바꿔도 코드 읽는 속도가 빨라집니다.

#### 공식 문서 참고

- [Java Collections Framework](https://docs.oracle.com/en/java/javase/21/core/java-collections-framework.html)
- [The Collection Interface](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Collection.html)
- [dev.java](http://dev.java/)[ Generics](https://dev.java/learn/generics/)
#### 정리

컬렉션 프레임워크는 데이터를 어떤 구조로 다룰지에 대한 기준이고, 제네릭은 그 구조를 타입 안전하게 유지하는 장치입니다. 이 둘을 함께 이해해야 Java 코드가 비로소 구조적으로 보이기 시작합니다.

#### 한 줄 정리

컬렉션과 제네릭의 핵심은 **데이터 구조 선택과 타입 안전성을 동시에 설계하는 것**입니다.


---

## 3.2 컬렉션 자료구조 활용 사례

#### 개요

이 문서는 Java에서 자주 사용하는 컬렉션과 자료구조를 실제 상황에 어떻게 연결해서 이해하면 좋은지 설명하는 문서입니다. `ArrayList`, `LinkedList`, `HashSet`, `HashMap`, `Vector`, `Stack`, `ArrayDeque`를 단순 정의로만 외우기보다, 어떤 상황에서 어떤 선택이 자연스러운지를 중심으로 정리합니다.

#### 왜 중요한가

자료구조는 알고리즘 문제에서만 중요한 것이 아니라, 서비스 코드의 성능과 가독성에도 직접 영향을 줍니다. 같은 데이터를 다루더라도 어떤 구조를 선택하느냐에 따라 코드가 훨씬 단순해지거나 복잡해질 수 있습니다.

#### 1. ArrayList

##### 언제 적합한가

- 순서가 중요한 데이터가 필요할 때
- 중간 삽입과 삭제보다 조회가 많을 때
- 인덱스로 빠르게 접근해야 할 때
##### 예시

상품 목록, 사용자 목록, 게시글 목록 같은 읽기 중심 데이터에 잘 맞습니다.

```java
ArrayList<String> list = new ArrayList<>();
list.add("사과");
list.add("바나나");
list.add("체리");

System.out.println("ArrayList: " + list);
System.out.println(list.get(1));
```

```plain text
예상 결과
ArrayList: [사과, 바나나, 체리]
바나나
```

#### 2. LinkedList

##### 언제 적합한가

- 앞뒤 삽입과 삭제가 자주 일어날 때
- 순차적으로 데이터를 처리할 때
##### 예시

작업 대기열, 최근 방문 기록, 순차 처리 목록처럼 중간 조정이 잦은 경우에 생각해볼 수 있습니다.

```java
LinkedList<String> tasks = new LinkedList<>();
tasks.add("Task 1");
tasks.addFirst("Urgent Task");
tasks.addLast("Task 2");

System.out.println(tasks);
```

##### 실무 메모

`LinkedList`는 자료구조 교과서에서는 자주 등장하지만, 애플리케이션 코드의 기본 리스트로 바로 선택할 필요는 없습니다. 대부분의 목록 처리에서는 `ArrayList`가 더 단순하고 예측 가능하며, `LinkedList`는 앞뒤 삽입과 삭제가 명확한 경우에만 선택해도 충분합니다.

#### 3. HashSet

##### 언제 적합한가

- 중복 없는 값 집합이 필요할 때
- 포함 여부를 빠르게 확인하고 싶을 때
##### 예시

이메일 중복 체크, 태그 중복 제거, 방문 사용자 집계 같은 경우에 잘 맞습니다.

```java
Set<String> tags = new HashSet<>();
tags.add("java");
tags.add("spring");
tags.add("java");

System.out.println(tags.contains("spring"));
System.out.println(tags);
```

#### 4. HashMap

##### 언제 적합한가

- 키로 값을 빠르게 조회해야 할 때
- ID 기반 조회가 많을 때
##### 예시

회원 ID로 회원 정보를 찾거나, 설정 값을 키-값으로 관리할 때 자주 사용합니다.

```java
Map<Long, String> users = new HashMap<>();
users.put(1L, "Kim");
users.put(2L, "Lee");
users.put(3L, "Park");

System.out.println(users.get(2L));
```

#### 5. Vector

##### 언제 적합한가

지금은 새 코드에서 직접 사용할 일은 많지 않습니다. 과거 동기화 컬렉션을 이해하거나 레거시 코드를 읽을 때 의미가 있습니다.

##### 핵심 포인트

- 기본적으로 동기화됩니다.
- 단일 스레드 환경에서는 보통 `ArrayList`가 더 적합합니다.
- 새 코드에서 동시성 문제가 있다면 `Vector`보다 상위 설계나 동시성 컬렉션을 먼저 검토하는 편이 낫습니다.
#### 6. Stack

##### 언제 적합한가

후입선출 구조가 필요할 때입니다. 다만 현대 Java에서는 `Stack`보다 `ArrayDeque`를 더 자주 권장합니다.

##### 예시

뒤로 가기, 실행 취소, 괄호 검사 같은 문제에서 자주 떠올릴 수 있습니다.

```java
Stack<String> history = new Stack<>();
history.push("Home");
history.push("Product");
history.push("Order");

System.out.println(history.pop());
```

##### 실무 메모

`Stack`은 레거시 타입이라서 새 코드의 기본 선택지로 두기에는 아쉽습니다. 같은 후입선출 구조가 필요하면 `ArrayDeque`가 더 가볍고 API도 일관됩니다.

#### 7. ArrayDeque

##### 언제 적합한가

- 스택처럼 쓰고 싶을 때
- 큐처럼 쓰고 싶을 때
- 앞뒤 삽입과 삭제가 모두 필요할 때
##### 예시

메시지 처리, 작업 큐, 괄호 검사 같은 상황에서 매우 실용적입니다.

```java
Deque<String> deque = new ArrayDeque<>();
deque.addLast("Message 1");
deque.addLast("Message 2");

System.out.println(deque.pollFirst());
System.out.println(deque.pollFirst());
```

```plain text
예상 결과
Message 1
Message 2
```

##### 실무 메모

`ArrayDeque`는 `Stack`과 `LinkedList`의 자리를 상당 부분 대체할 수 있는 실용적인 기본값입니다. 새 코드에서는 스택과 큐 문제를 만나면 `ArrayDeque`부터 검토하는 편이 더 일관됩니다.

#### 8. 선택 기준 요약

- 조회 중심: `ArrayList`
- 앞뒤 조작 중심: `LinkedList` 또는 `ArrayDeque`
- 중복 제거: `HashSet`
- 키 기반 조회: `HashMap`
- 스택/큐 대체: `ArrayDeque`
- 레거시 동기화 컬렉션 이해: `Vector`, `Stack`
#### 실무 연결 포인트

실무에서는 자료구조를 아주 많이 바꾸기보다, 처음 선택을 너무 무겁게 하지 않는 것이 중요합니다. 대부분의 경우 `ArrayList`, `HashMap`, `ArrayDeque`만 잘 이해해도 기본적인 선택은 충분히 할 수 있습니다.

#### 정리

자료구조 학습의 핵심은 이름을 외우는 것이 아니라, 데이터가 어떻게 들어오고 나가는지를 상상하는 것입니다. 그 흐름을 기준으로 보면 어떤 구조를 써야 할지가 훨씬 자연스럽게 보입니다.

#### 한 줄 정리

자료구조 선택의 핵심은 **이론적 정의보다 데이터의 흐름과 조작 패턴을 먼저 보는 것**입니다.


---

## 3.3 컬렉션 선택 시나리오

#### 개요

이 문서는 컬렉션과 자료구조를 실제 요구사항에 연결해 보는 시나리오형 가이드입니다. `ArrayList`, `LinkedList`, `ArrayDeque`, `PriorityQueue`, `ConcurrentHashMap` 같은 도구를 이름으로 고르는 것이 아니라, **조회 패턴, 삽입/삭제 위치, 동시성 요구, 우선순위 처리**를 기준으로 선택하는 감각을 만드는 것이 목적입니다.

#### 왜 필요한가

기초 문서를 읽고 나면 `List`, `Set`, `Map`의 정의는 알게 되지만, 실제 문제 앞에서는 다시 막히기 쉽습니다. 이 문서는 “이 상황이라면 무엇을 고를까”를 반복해 보면서 컬렉션 선택 기준을 손에 익히도록 돕습니다.

#### 1. 상품 목록 관리: ArrayList

상품 목록은 순서를 유지하면서 반복 조회하는 일이 많고, 인덱스 접근도 자주 일어납니다. 이런 상황에서는 `ArrayList`가 가장 자연스럽습니다.

```java
public class ProductCatalog {
    private final List<Product> products = new ArrayList<>();

    public void add(Product product) {
        products.add(product);
    }

    public Product find(int index) {
        return products.get(index);
    }

    public void remove(int index) {
        products.remove(index);
    }
}
```

핵심은 “삽입/삭제가 아주 많지 않다면 기본 리스트는 먼저 `ArrayList`를 검토한다”는 점입니다.

#### 2. 진료 대기열: LinkedList보다 Queue 관점으로 보기

앞에서 꺼내고 뒤에 넣는 흐름이라면 자료구조 이름보다 **큐**라는 관점이 먼저 떠올라야 합니다. 구현은 `LinkedList`보다 `ArrayDeque`가 더 단순한 기본값인 경우가 많습니다.

```java
Deque<String> waitingQueue = new ArrayDeque<>();
waitingQueue.addLast("홍길동");
waitingQueue.addLast("이순신");
waitingQueue.addFirst("응급환자");

System.out.println(waitingQueue.pollFirst());
System.out.println(waitingQueue.pollFirst());
```

```plain text
예상 결과
응급환자
홍길동
```

교과서에서는 `LinkedList`가 자주 나오지만, 새 코드에서는 `Queue`나 `Deque` 인터페이스 관점으로 먼저 설계하는 편이 더 낫습니다.

#### 3. 브라우저 뒤로가기와 실행 취소: ArrayDeque

뒤로가기와 Undo는 가장 최근 작업을 먼저 꺼내는 후입선출 구조입니다. 이때 레거시 `Stack`보다 `ArrayDeque`를 스택처럼 쓰는 편이 더 자연스럽습니다.

```java
Deque<String> history = new ArrayDeque<>();
history.push("/home");
history.push("/books");
history.push("/orders");

System.out.println(history.pop());
System.out.println(history.peek());
```

```plain text
예상 결과
/orders
/books
```

#### 4. 실시간 메시지 처리: Queue와 Deque

메시지를 먼저 넣은 순서대로 처리해야 한다면 FIFO가 중요합니다. 이런 경우도 `ArrayDeque`를 큐처럼 사용하는 선택이 실용적입니다.

```java
Deque<String> messages = new ArrayDeque<>();
messages.addLast("message-1");
messages.addLast("message-2");

System.out.println(messages.pollFirst());
System.out.println(messages.pollFirst());
```

##### 보강: 생산자-소비자에서는 `BlockingQueue`

단순한 큐 예제를 넘어서 멀티스레드에서 생산자와 소비자가 데이터를 주고받는 상황이라면 `Queue`보다 `BlockingQueue`를 먼저 떠올리는 편이 좋습니다.

```java
BlockingQueue<String> jobs = new ArrayBlockingQueue<>(10);
Runnable producer = () -> {
    try {
        jobs.put("report.csv");
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    }
};
Runnable consumer = () -> {
    try {
        String job = jobs.take();
        System.out.println("처리: " + job);
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    }
};
```

핵심은 자료구조 이름보다, **경쟁하는 스레드가 있고 대기와 재개가 필요한가**를 먼저 보는 것입니다. 그 순간부터는 `LinkedList`나 `ArrayDeque`보다 `BlockingQueue` 같은 동시성 도구가 더 적합합니다.

#### 5. 우선순위 주문 처리: PriorityQueue

모든 요청을 입력 순서대로 처리하지 않고, VIP나 긴급 작업을 먼저 처리해야 한다면 `PriorityQueue`를 고려합니다.

```java
record Order(String name, int priority) {}

PriorityQueue<Order> orders = new PriorityQueue<>(Comparator.comparing(Order::priority).reversed());
orders.add(new Order("일반 주문", 1));
orders.add(new Order("VIP 주문", 10));

System.out.println(orders.poll().name());
System.out.println(orders.poll().name());
```

```plain text
예상 결과
VIP 주문
일반 주문
```

이 구조의 핵심은 “먼저 들어온 것”이 아니라 “먼저 처리할 가치가 큰 것”을 우선한다는 점입니다.

#### 6. 설정 값 공유: ConcurrentHashMap

여러 스레드가 동시에 읽고 쓰는 설정 저장소라면 `HashMap`만으로는 부족합니다. 이때는 `ConcurrentHashMap` 같은 동시성 컬렉션을 고려해야 합니다.

```java
ConcurrentHashMap<String, String> settings = new ConcurrentHashMap<>();
settings.put("theme", "dark");
settings.put("locale", "ko-KR");

System.out.println(settings.get("theme"));
```

중요한 점은 `Vector`처럼 오래된 synchronized 컬렉션을 먼저 떠올리기보다, 요구사항에 맞는 동시성 컬렉션을 찾는 습관입니다.

#### 7. 트리 구조 표현: 컬렉션을 조합해서 만든다

폴더 구조나 카테고리 계층처럼 트리 구조를 다룰 때는 Java 기본 컬렉션을 조합해 직접 표현할 수 있습니다. 보통 각 노드가 자식 목록을 `List`로 가지는 방식이 단순합니다.

```java
class FileNode {
    private final String name;
    private final List<FileNode> children = new ArrayList<>();

    FileNode(String name) {
        this.name = name;
    }

    void addChild(FileNode child) {
        children.add(child);
    }
}
```

즉, 컬렉션 학습은 개별 구현체를 외우는 데서 끝나는 것이 아니라, 더 큰 구조를 어떻게 조합할지까지 이어져야 합니다.

#### 선택 기준 요약

- 목록 조회 중심: `ArrayList`
- 앞뒤 삽입/삭제와 큐/스택 흐름: `ArrayDeque`
- 우선순위 처리: `PriorityQueue`
- 동시성 키-값 저장소: `ConcurrentHashMap`
- 계층 구조 표현: `List`를 포함한 사용자 정의 노드 구조
#### 정리

컬렉션 선택의 핵심은 구현체 이름을 많이 아는 것이 아니라, **데이터가 들어오고 나가고 경쟁하는 방식**을 먼저 보는 것입니다. 시나리오를 기준으로 반복해서 선택해 보면, 자료구조가 외워야 할 목록이 아니라 설계 도구로 보이기 시작합니다.

#### 한 줄 정리

컬렉션은 이름으로 고르는 것이 아니라, **문제의 흐름과 제약을 보고 선택하는 도구**입니다.


---

## 3.4 람다와 스트림

#### 개요

이 문서는 람다식, 함수형 인터페이스, 스트림을 한 흐름으로 이해하기 위한 가이드입니다. Java의 함수형 스타일은 문법을 줄이는 기술이 아니라, **동작을 값처럼 전달하고 컬렉션 처리를 선언적으로 표현하는 방식**에 가깝습니다.

#### 왜 중요한가

실무의 Java 코드에서는 정렬, 필터링, 변환, 집계가 반복됩니다. 이때 람다와 스트림을 이해하면 `for` 문을 기계적으로 줄이는 수준을 넘어, 데이터 처리 의도를 더 선명하게 드러낼 수 있습니다.

#### 1. 람다식은 무엇을 바꾸었는가

람다식은 익명 클래스가 하던 역할을 더 짧고 명확하게 표현할 수 있게 해줍니다. 하지만 핵심은 짧아진 문장이 아니라, **동작을 값처럼 다룰 수 있게 되었다는 점**입니다.

`day-by-java` 예제 중 가장 단순한 형태는 아래와 같습니다.

```java
Runnable runnable = () -> System.out.println("Hello, Lambda!");
System.out.println("Hello, Lambda!");
runnable.run();
runnable.run();
```

```plain text
예상 결과
Hello, Lambda!
Hello, Lambda!
Hello, Lambda!
```

첫 줄은 일반 출력이고, 뒤의 두 줄은 같은 동작을 `Runnable` 변수에 담아 다시 실행한 결과입니다. 이 예제에서 봐야 할 것은 문법이 아니라, **출력 동작 자체가 변수처럼 다뤄진다**는 점입니다.

#### 2. 함수형 인터페이스를 먼저 이해할 것

람다는 아무 곳에나 붙지 않습니다. 추상 메서드가 하나인 함수형 인터페이스와 함께 사용됩니다.

- `Consumer<T>`: 값을 받아서 소비
- `Supplier<T>`: 값을 공급
- `Function<T, R>`: 값을 변환
- `Predicate<T>`: 조건 판별
초반에는 이름을 외우기보다, 입력과 출력이 어떤 형태인지 먼저 보는 편이 좋습니다.

예를 들어 `Function<String, Integer>`는 문자열을 받아 정수로 바꾸는 함수형 인터페이스입니다.

```java
Function<String, Integer> lengthFunction = s -> s.length();
System.out.println(lengthFunction.apply("Hello"));
```

```plain text
예상 결과
5
```

이 코드는 문자열 자체를 저장하는 것이 아니라, **문자열을 받아 길이로 바꾸는 규칙**을 변수로 들고 있다는 점이 핵심입니다.

#### 3. 스트림은 컬렉션을 대체하지 않는다

스트림은 데이터를 저장하는 구조가 아니라, **데이터를 처리하는 파이프라인**입니다.

```java
List<String> result = names.stream()
    .filter(name -> name.startsWith("K"))
    .map(String::toUpperCase)
    .toList();
```

위 코드는 세 단계를 보여줍니다.

- 원본 데이터를 스트림으로 열고
- 조건으로 걸러내고
- 다른 형태로 변환한 뒤
- 최종 결과로 수집합니다.
#### 4. 중간 연산과 최종 연산

스트림을 읽을 때는 중간 연산과 최종 연산을 나눠 보는 것이 중요합니다.

- 중간 연산: `filter`, `map`, `sorted`
- 최종 연산: `forEach`, `collect`, `toList`, `reduce`, `count`
최종 연산이 호출되기 전까지는 실제 계산이 바로 끝나지 않는다는 점이 핵심입니다.

#### 5. 언제 읽기 좋아지고, 언제 오히려 나빠지는가

스트림은 아래 상황에서 특히 읽기 좋습니다.

- 조건 필터링이 분명할 때
- 변환 단계가 2~3개 정도로 명확할 때
- 집계 목적이 뚜렷할 때
반대로 아래 상황에서는 오히려 나빠질 수 있습니다.

- 상태를 바꾸는 부작용이 많을 때
- 예외 처리가 복잡하게 섞일 때
- 스트림 한 줄에 비즈니스 규칙이 과도하게 몰릴 때
#### 6. 병렬 스트림은 신중하게 볼 것

병렬 스트림은 “더 빠른 기본값”이 아닙니다. 작업 특성, 데이터 크기, 부작용 여부를 함께 봐야 합니다. 초중급 단계에서는 먼저 **순차 스트림을 명확하게 읽는 능력**을 갖추는 편이 더 중요합니다.

#### 7. 실무 연결 포인트

람다와 스트림은 컬렉션 처리뿐 아니라 정렬 기준, 테스트 데이터 생성, Querydsl 결과 후처리, Spring 코드의 콜백 구조를 읽을 때도 자주 등장합니다. 결국 문법이 아니라, 동작 전달과 파이프라인 사고에 익숙해지는 것이 핵심입니다.

#### 공식 문서 참고

- [Lambda Expressions](https://dev.java/learn/lambdas/)
- [Stream Package Summary](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/package-summary.html)
- [Stream Interface](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/stream/Stream.html)
#### 정리

람다와 스트림은 Java를 다른 언어처럼 바꾸는 기능이 아닙니다. 기존 객체지향 코드를 보완해, 반복되는 데이터 처리 로직을 더 선언적으로 표현하게 해주는 도구입니다.

#### 한 줄 정리

람다와 스트림의 핵심은 **동작 전달과 데이터 처리 파이프라인을 읽기 좋은 형태로 만드는 것**입니다.


---

## 3.7 알고리즘 기초: 시간복잡도와 탐색/정렬

### 알고리즘 기초: 시간복잡도와 탐색/정렬

#### 개요

이 문서는 자료구조를 배운 다음, 알고리즘을 어떤 관점으로 읽어야 하는지 잡아 주는 입문 가이드입니다. 핵심은 어려운 알고리즘을 많이 외우는 것이 아니라, **입력 크기와 데이터 구조에 따라 어떤 선택이 자연스러운지** 판단하는 기준을 만드는 데 있습니다.

#### 왜 중요한가

초중급 Java 학습에서 알고리즘은 코딩 테스트 전용 과목처럼 보이기 쉽습니다. 하지만 실제 서비스 코드에서도 검색, 집계, 정렬, 중복 제거, 우선순위 처리 같은 문제는 계속 나타납니다. 그래서 알고리즘 학습은 문제 풀이 기술보다 **자료구조 선택과 성능 감각**을 기르는 쪽으로 읽는 편이 더 오래 갑니다.

#### 1. 시간복잡도는 무엇을 보나

시간복잡도는 입력 크기 `n`이 커질 때 연산량이 어떻게 증가하는지 표현하는 기준입니다.

- `O(1)`: 크기와 무관하게 거의 일정한 작업
- `O(log n)`: 범위를 절반씩 줄이는 탐색
- `O(n)`: 처음부터 끝까지 한 번 훑는 작업
- `O(n log n)`: 효율적인 정렬 계열
- `O(n^2)`: 이중 반복문이 주가 되는 비교 작업
```java
int first = numbers[0];           // O(1)
for (int n : numbers) { }         // O(n)
Arrays.sort(numbers);             // 보통 O(n log n)
```

핵심은 복잡도를 수학 문제처럼 외우는 것이 아니라, **이 코드가 입력이 커질수록 어디서 느려질지** 감을 잡는 것입니다.

#### 2. 선형 검색, 이진 검색, 해시 탐색

같은 검색 문제라도 데이터 상태에 따라 선택이 달라집니다.

##### 선형 검색

정렬되지 않은 목록을 한 번 훑어야 하면 가장 단순합니다.

```java
int[] data = {5, 3, 8, 4, 2};
int target = 4;
int index = -1;
for (int i = 0; i < data.length; i++) {
    System.out.println("인덱스 " + i + "에서 검사: 값 " + data[i]);
    if (data[i] == target) {
        index = i;
        break;
    }
}
System.out.println("결과 인덱스: " + index);
```

```plain text
예상 결과
인덱스 0에서 검사: 값 5
인덱스 1에서 검사: 값 3
인덱스 2에서 검사: 값 8
인덱스 3에서 검사: 값 4
결과 인덱스: 3
```

- 장점: 준비 작업이 없습니다.
- 비용: `O(n)`
##### 이진 검색

데이터가 이미 정렬되어 있다면 범위를 절반씩 줄여 빠르게 찾을 수 있습니다.

```java
int[] data = {2, 3, 5, 7, 11, 13, 17};
int target = 11;
int left = 0;
int right = data.length - 1;
int result = -1;
while (left <= right) {
    int mid = left + (right - left) / 2;
    System.out.println("중간 인덱스: " + mid + ", 값: " + data[mid]);
    if (data[mid] == target) {
        result = mid;
        break;
    }
    if (data[mid] < target) {
        left = mid + 1;
    } else {
        right = mid - 1;
    }
}
System.out.println("결과 인덱스: " + result);
```

```plain text
예상 결과
중간 인덱스: 3, 값: 7
중간 인덱스: 5, 값: 13
중간 인덱스: 4, 값: 11
결과 인덱스: 4
```

- 장점: `O(log n)`
- 전제: 정렬되어 있어야 합니다.
##### 해시 탐색

같은 데이터를 여러 번 찾을 거라면 해시 기반 조회가 더 낫습니다.

```java
Map<Integer, String> users = new HashMap<>();
users.put(1, "Kim");
users.put(2, "Lee");

System.out.println(users.get(2));
```

- 평균 조회: `O(1)`
- 전제: 키로 바로 접근할 수 있어야 합니다.
즉, 검색의 핵심은 “무조건 빠른 알고리즘”이 아니라, **정렬 여부와 반복 조회 여부**를 먼저 보는 것입니다.

#### 3. 정렬은 언제 직접 구현하고 언제 라이브러리를 쓰나

학습 단계에서는 버블, 선택, 삽입, 퀵, 병합 정렬을 보면서 비교와 분할정복 감각을 익히는 것이 중요합니다. 하지만 실무에서는 직접 구현보다 표준 라이브러리의 정렬을 기본값으로 두는 편이 안전합니다.

```java
int[] numbers = {5, 1, 4, 2, 8};
Arrays.sort(numbers);
System.out.println(Arrays.toString(numbers));
```

정렬 계열을 볼 때는 다음 정도만 먼저 잡아 두면 충분합니다.

- 버블/선택/삽입 정렬: 구조 이해용, 대체로 `O(n^2)`
- 퀵/병합 정렬: 더 효율적인 정렬 사고 훈련, 보통 `O(n log n)`
- 실무 기본값: `Arrays.sort`, `Collections.sort`, `Comparator`
#### 4. 복잡도보다 더 중요한 선택 기준

같은 `O(n)`이라도 어떤 자료구조를 쓰느냐에 따라 체감 성능과 코드 구조가 달라집니다.

```java
Set<Integer> lookup = new HashSet<>(List.of(1, 3, 5, 7));
System.out.println(lookup.contains(5));
```

두 배열의 공통 원소를 찾을 때 이중 반복문으로 비교하면 `O(n * m)`이 되지만, 한쪽을 `HashSet`으로 바꾸면 `O(n + m)`에 가까워집니다. 그래서 알고리즘 학습은 결국 자료구조 학습과 같이 가야 합니다.

#### 5. 트리와 그래프는 왜 다시 나오나

알고리즘을 배우다 보면 배열과 리스트를 넘어 트리와 그래프가 등장합니다. 이 둘은 낯설어 보이지만, 결국 **데이터 관계를 어떻게 표현할 것인가**의 문제입니다.

- 트리: 부모-자식으로 내려가는 계층 구조
- 그래프: 순환과 복잡한 연결이 가능한 일반 연결 구조
```java
class TreeNode {
    int value;
    TreeNode left;
    TreeNode right;

    TreeNode(int value) {
        this.value = value;
    }
}
```

트리는 파일 시스템, 댓글 계층, 카테고리 구조 같은 곳에서 자주 보이고, 그래프는 지도, 추천, 소셜 관계 같은 연결 문제에서 다시 나타납니다.

#### 6. 재귀는 왜 트리와 잘 붙나

재귀는 함수가 자기 자신을 다시 호출하는 방식입니다. 트리처럼 하위 구조가 같은 모양으로 반복될 때 특히 자연스럽습니다.

```java
void preOrder(TreeNode node) {
    if (node == null) {
        return;
    }
    System.out.println(node.value);
    preOrder(node.left);
    preOrder(node.right);
}
```

핵심은 두 가지입니다.

- `base case`: 언제 멈출지
- `recursive case`: 어떤 더 작은 문제로 내려갈지
재귀는 코드가 짧아지기 쉽지만, 호출 깊이가 너무 깊어지면 스택을 많이 사용합니다. 그래서 JVM 문서에서 `StackOverflowError`가 다시 연결됩니다.

#### 7. 동적 프로그래밍은 무엇을 줄이나

재귀 문제를 풀다 보면 같은 하위 문제를 여러 번 계산하는 경우가 많습니다. 동적 프로그래밍은 이 중복 계산을 줄이는 방법입니다.

```java
int fib(int n) {
    int[] dp = new int[n + 1];
    dp[0] = 0;
    if (n > 0) dp[1] = 1;

    for (int i = 2; i <= n; i++) {
        dp[i] = dp[i - 1] + dp[i - 2];
    }
    return dp[n];
}

System.out.println(fib(10));
```

```plain text
예상 결과
55
```

입문 단계에서는 고난도 DP 문제를 많이 푸는 것보다, **재귀가 왜 느려지는지, 저장하면 무엇이 빨라지는지**를 이해하는 정도가 더 중요합니다.

#### 8. BFS와 DFS는 탐색의 다른 얼굴이다

검색 알고리즘 문서를 보다 보면 선형 검색, 이진 검색뿐 아니라 그래프 탐색인 BFS와 DFS도 같이 등장합니다. 이 둘은 “배열에서 값 찾기”와는 결이 다르지만, **탐색 순서를 설계한다**는 점에서 연결됩니다.

- DFS: 한 방향으로 깊게 들어갑니다.
- BFS: 가까운 노드부터 넓게 확장합니다.
```java
Queue<Integer> queue = new LinkedList<>();
queue.add(start);
while (!queue.isEmpty()) {
    int node = queue.poll();
    // 인접 노드 방문
}
```

여기서 중요한 것은 BFS가 `Queue`, DFS가 재귀나 `Stack`과 잘 연결된다는 점입니다. 그래서 자료구조와 알고리즘은 분리해서 보기보다 함께 읽는 편이 좋습니다.

#### 9. 실전에서는 어떻게 판단하나

- 한 번만 훑으면 되는가: 선형 탐색
- 이미 정렬되어 있는가: 이진 탐색
- 반복 조회가 많은가: 해시 기반 조회
- 결과 순서가 중요한가: 정렬 필요
- 최단 거리나 레벨 탐색인가: BFS
- 모든 경로를 깊게 내려가야 하는가: DFS
#### 정리

알고리즘 입문의 핵심은 복잡한 문제를 많이 푸는 것이 아니라, **데이터 상태와 요구사항을 보고 자료구조와 탐색/정렬/재귀 전략을 고르는 것**입니다. 시간복잡도는 그 판단을 돕는 기준이고, 트리와 그래프는 그 전략이 더 복잡한 구조로 확장된 모습입니다.

#### 한 줄 정리

알고리즘 학습의 핵심은 **빅 오를 외우는 것**보다, **어떤 데이터에 어떤 탐색·정렬·재귀·자료구조가 맞는지 판단하는 것**입니다.


---

## 3.8 알고리즘 기초 실전문제

#### 개요

이 문서는 `알고리즘 기초: 시간복잡도와 탐색/정렬`을 읽은 뒤 이어서 풀어보는 기초 알고리즘 실전문제 모음입니다. Java 문법과 자료구조를 실제 문제 풀이 감각으로 연결하기 위한 문서입니다. 난도는 낮지만, 배열 순회, 정렬, 집계, 빈도 계산, 조건 분기 같은 기본기를 점검하기에 적절한 문제들로 구성했습니다.

#### 문제 0. 대량 배열에서 여러 타깃 찾기

크기 1,000,000의 배열에서 여러 목표 값이 몇 번째 인덱스에 있는지 찾아야 한다고 가정해 봅시다.

- 한 번만 찾는다면 선형 검색으로도 충분한가
- 배열이 정렬되어 있다면 이진 검색으로 무엇이 달라지는가
- 같은 배열을 계속 조회한다면 `HashMap<Integer, List<Integer>>` 같은 인덱스를 미리 만드는 편이 나은가
핵심은 정답 하나보다, **입력 상태와 반복 조회 여부에 따라 탐색 전략이 바뀐다는 점을 설명하는 것**입니다.

#### 어떻게 활용하면 좋은가

- 먼저 손으로 입출력을 정리한 뒤 코드를 작성합니다.
- 시간 복잡도와 자료구조 선택 이유를 함께 설명해봅니다.
- 정답이 나온 뒤에는 변수명과 메서드 분리까지 다시 점검합니다.
#### 문제 구성

##### 1. 순회와 조건 분기

- 재고 부족 상품 찾기
- 레벨업 가능한 사용자 찾기
- 사용 가능한 스킬 찾기
##### 2. 집계와 계산

- 드랍 확률 계산
- 장바구니 총액 계산
- 구매 빈도 분석
##### 3. 정렬과 우선순위

- 추천 상품 정렬
- 리더보드 상위 N명 찾기
##### 4. 자료구조 활용

- `HashSet`으로 중복 문자 찾기
- `HashMap`으로 빈도 계산하기
#### 예시 문제

##### 문제 1. 재고가 부족한 상품 찾기

```java
int[][] inventory = {
    {101, 5},
    {102, 12},
    {103, 8}
};
```

- 상품 ID와 재고 수량이 주어집니다.
- 재고가 10개 미만인 상품의 ID를 반환합니다.
- 출력 예시는 `101, 103`입니다.
##### 문제 2. 추천 상품 정렬

```java
int[][] recommendations = {
    {101, 85},
    {102, 95},
    {103, 70}
};
```

- 두 번째 값인 선호도 점수를 기준으로 내림차순 정렬합니다.
- 정렬 기준이 하나인지, 동점일 때 추가 규칙이 필요한지도 함께 생각해봅니다.
#### 문제 목록

##### 1. 재고 관리 시스템

- 재고 수량이 기준보다 작은 상품만 추려냅니다.
##### 2. 유저 레벨업 조건 확인

- 경험치가 기준 이상인 사용자만 반환합니다.
##### 3. 할인 코드 유효성 검증

- 문자열에 중복 문자가 있는지 검사합니다.
##### 4. 아이템 드랍 확률 계산

- 비율 계산과 포맷팅을 연습합니다.
##### 5. 장바구니 최종 가격 계산

- 합계 계산 후 할인율을 적용합니다.
##### 6. 리더보드 업데이트

- 점수 기준 정렬과 상위 N개 추출을 다룹니다.
##### 7. 구매 빈도 분석

- 가장 많이 등장한 값을 찾습니다.
##### 8. 캐릭터 스킬 쿨타임 체크

- 문자열 데이터를 수치로 바꿔 조건 필터링합니다.
##### 9. 추천 상품 정렬

- 2차원 배열 정렬 문제를 다룹니다.
#### 풀이 전 체크 포인트

- 입력과 출력 형식을 먼저 분명히 적었는가
- 배열, 리스트, 맵, 셋 중 어떤 자료구조가 적절한지 판단했는가
- 반복문과 조건문을 최소한으로 유지했는가
- 메서드 이름이 문제 의도를 드러내는가
#### 정리

기초 알고리즘 문제는 고난도 문제 풀이보다, 실무 코드에서도 자주 쓰는 작은 연산들을 안정적으로 다루는 능력을 길러줍니다. 특히 초중급 개발자에게는 복잡한 알고리즘보다 입력 구조를 읽고 적절한 자료구조를 고르는 감각이 더 중요합니다.

#### 한 줄 정리

기초 알고리즘 문제는 어려운 공식을 익히는 과정이 아니라, 데이터를 다루는 기본 동작을 정확하게 익히는 과정입니다.


---

## 3.8-1 알고리즘 기초 실전문제 풀이

#### 개요

이 문서는 `Java 알고리즘 기초 문제`의 해설서입니다. 정답 코드만 확인하는 데서 그치지 않고, 왜 그 자료구조와 반복 구조를 선택했는지까지 함께 설명하는 것을 목표로 합니다.

#### 풀이를 읽는 방법

- 먼저 문제를 직접 푼 뒤 결과를 비교합니다.
- 정답 여부보다 입력 처리, 자료구조 선택, 반복문의 구조를 점검합니다.
- 더 간결한 메서드 분리나 변수명 개선이 가능한지도 함께 봅니다.
#### 해설 구성

##### 1. 순회와 조건 분기 문제

- 재고 관리 시스템
- 유저 레벨업 조건 확인
- 캐릭터 스킬 쿨타임 체크
##### 2. 집계와 계산 문제

- 할인 코드 유효성 검증
- 아이템 드랍 확률 계산
- 장바구니 최종 가격 계산
##### 3. 정렬과 우선순위 문제

- 리더보드 업데이트
- 추천 상품 정렬
##### 4. 빈도 계산 문제

- 구매 빈도 분석
#### 문제 1. 재고 관리 시스템

```java
public static List<Integer> findLowStockItems(int[][] inventory, int threshold) {
    List<Integer> lowStock = new ArrayList<>();
    for (int[] item : inventory) {
        if (item[1] < threshold) {
            lowStock.add(item[0]);
        }
    }
    return lowStock;
}
```

##### 해설

이 문제는 2차원 배열을 순회하면서 두 번째 값인 재고 수량만 조건으로 검사하면 됩니다. 복잡한 자료구조가 필요하지 않으며, 입력 형식을 정확히 읽는지가 핵심입니다.

#### 문제 2. 유저 레벨업 조건 확인

```java
public static List<Integer> findLevelUpUsers(int[][] userStats, int threshold) {
    List<Integer> eligibleUsers = new ArrayList<>();
    for (int[] user : userStats) {
        if (user[1] >= threshold) {
            eligibleUsers.add(user[0]);
        }
    }
    return eligibleUsers;
}
```

##### 해설

문제 1과 같은 순회 구조이지만, 비교 연산만 반대로 바뀝니다. 이런 문제에서 중요한 점은 조건문을 정확히 읽고 공통 구조를 재사용하는 감각입니다.

#### 문제 3. 할인 코드 유효성 검증

```java
public static boolean isUniqueCode(String code) {
    HashSet<Character> seen = new HashSet<>();
    for (char c : code.toCharArray()) {
        if (!seen.add(c)) {
            return false;
        }
    }
    return true;
}
```

##### 해설

중복 검사는 `HashSet`이 가장 자연스럽습니다. 이미 본 문자가 다시 나오면 `add()`가 `false`를 반환하므로, 바로 중복 여부를 판단할 수 있습니다.

#### 문제 4. 아이템 드랍 확률 계산

```java
public static double calculateDropRate(int kills, int drops) {
    return (double) drops / kills * 100;
}
```

##### 해설

정수 나눗셈을 피하기 위해 형변환을 먼저 적용해야 합니다. 출력 형식까지 문제에 포함되어 있다면 `printf` 사용 여부도 함께 확인해야 합니다.

#### 문제 5. 장바구니 최종 가격 계산

```java
public static double calculateFinalPrice(double[][] cart, double discountRate) {
    double total = 0;
    for (double[] item : cart) {
        total += item[0] * item[1];
    }
    return total * (1 - discountRate / 100);
}
```

##### 해설

합계를 먼저 계산한 뒤 할인율을 적용하는 순서가 중요합니다. 문제를 작게 쪼개면 `합계 계산`과 `할인 적용`이라는 두 단계로 나눌 수 있습니다.

#### 문제 6. 리더보드 업데이트

```java
Arrays.sort(scores, (a, b) -> b[1] - a[1]);
```

##### 해설

이 문제의 핵심은 정렬 기준을 두 번째 값으로 두는 것입니다. 이후 상위 `N`개만 출력하면 되므로, 정렬 후 앞부분만 순회하면 충분합니다.

#### 문제 7. 구매 빈도 분석

```java
public static int findMostPurchased(int[] purchases) {
    HashMap<Integer, Integer> frequency = new HashMap<>();
    for (int id : purchases) {
        frequency.put(id, frequency.getOrDefault(id, 0) + 1);
    }

    int maxCount = 0;
    int mostPurchased = Integer.MAX_VALUE;

    for (int id : frequency.keySet()) {
        if (frequency.get(id) > maxCount ||
            (frequency.get(id) == maxCount && id < mostPurchased)) {
            maxCount = frequency.get(id);
            mostPurchased = id;
        }
    }
    return mostPurchased;
}
```

##### 해설

빈도 계산은 `HashMap`이 적절합니다. 동률일 때 더 작은 ID를 선택한다는 추가 조건이 있기 때문에, 단순 최빈값보다 비교 조건을 한 번 더 넣어야 합니다.

#### 문제 8. 캐릭터 스킬 쿨타임 체크

```java
public static List<String> findAvailableSkills(String[][] skills) {
    List<String> available = new ArrayList<>();
    for (String[] skill : skills) {
        if (Integer.parseInt(skill[1]) <= 0) {
            available.add(skill[0]);
        }
    }
    return available;
}
```

##### 해설

문자열을 숫자로 변환해 조건 비교하는 문제입니다. 입력 타입을 먼저 확인하고, 필요한 순간에만 변환하는 습관이 중요합니다.

#### 문제 9. 추천 상품 정렬

```java
public static void sortRecommendations(int[][] recommendations) {
    Arrays.sort(recommendations, (a, b) -> b[1] - a[1]);
}
```

##### 해설

리더보드 문제와 거의 같은 구조입니다. 문제를 여러 개 풀다 보면 정렬 기준과 출력 방식만 바뀌는 문제를 빠르게 인식하게 됩니다.

#### 체크 포인트

- 입력 형식을 정확히 읽었는가
- 배열, 리스트, 맵, 셋 중 적절한 자료구조를 골랐는가
- 정렬 기준과 동점 처리 규칙을 놓치지 않았는가
- 메서드 이름이 문제 의도를 설명하는가
#### 정리

기초 알고리즘 문제의 해설은 정답을 복사하기 위한 문서가 아니라, 단순한 문제를 어떻게 구조적으로 읽어야 하는지 보여주는 문서입니다. 같은 난도의 문제라도 입력 형식과 조건을 정확히 읽는 습관이 쌓이면 이후 복잡한 문제를 다룰 때도 훨씬 안정적입니다.

#### 한 줄 정리

알고리즘 기초 문제 풀이의 핵심은 정답 코드보다, 문제를 작은 규칙으로 분해해 읽는 습관을 익히는 데 있습니다.


---

## 3.9 함수형 인터페이스와 스트림 연습 문제

### 개요

이 문서는 `람다와 스트림` 본문을 읽은 뒤 직접 손으로 풀어보는 **실전문제**입니다. 책 본문에서 다룬 개념을 다시 문제로 확인하고, 스트림과 함수형 인터페이스를 실제 코드 판단으로 연결하는 데 목적이 있습니다.

#### 어떻게 활용하면 좋은가

- 먼저 [람다와 스트림](https://www.notion.so/31d1e21f383681069038fd7d832e06b9)을 읽습니다.
- 정답 코드를 바로 보지 말고, 입력과 출력, 타입 시그니처를 먼저 손으로 적어봅니다.
- 한 문제를 풀 때마다 `입력`, `출력`, `부작용`, `반환 타입`을 같이 점검합니다.
- 가능하면 `for` 문 풀이와 스트림 풀이를 둘 다 작성해봅니다.
#### 이 문서의 목표

- 함수형 인터페이스의 입력과 출력 형태를 구분한다.
- 스트림 파이프라인의 중간 연산과 최종 연산을 구분한다.
- `람다를 짧게 쓰는 것`과 `읽기 좋게 쓰는 것`이 다르다는 점을 이해한다.
- `Optional`, `Comparator`, `groupingBy`, `flatMap` 같은 실전 도구를 한 번씩 직접 써 본다.
#### 1. 함수형 인터페이스 기본

##### 문제 1. `Runnable`을 람다식으로 바꾸기

아래 익명 클래스를 람다식으로 바꿔 보세요.

```java
Runnable task = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello, Lambda!");
    }
};
```

##### 문제 2. `Consumer<String>` 만들기

문자열 하나를 받아 그대로 출력하는 `Consumer<String>`를 작성하세요.

기대 출력:

```plain text
Hello, Consumer!
```

##### 문제 3. `Supplier<String>` 만들기

입력 없이 `"Hello, Supplier!"`를 반환하는 `Supplier<String>`를 작성하세요.

##### 문제 4. `Function<String, Integer>` 만들기

문자열을 받아 길이를 반환하는 `Function<String, Integer>`를 작성하세요.

입력 예시:

```plain text
Hello
```

기대 출력:

```plain text
5
```

##### 문제 5. `Predicate<String>` 만들기

문자열 길이가 5보다 큰지 판별하는 `Predicate<String>`를 작성하세요.

#### 2. 조합과 변환

##### 문제 6. `Function.andThen()` 사용하기

문자열을 대문자로 바꾼 뒤 길이를 구하는 함수를 작성하세요.

입력 예시:

```plain text
Hello, Function!
```

##### 문제 7. `Consumer.andThen()` 사용하기

이름을 출력하고, 이어서 그 이름의 길이를 출력하는 `Consumer<String>` 조합을 작성하세요.

입력 예시:

```plain text
Alice
Bob
Charlie
```

기대 출력 예시:

```plain text
Name: Alice
Length: 5
Name: Bob
Length: 3
Name: Charlie
Length: 7
```

##### 문제 8. 제네릭 메서드와 `Function` 결합하기

아래 시그니처를 만족하는 `process` 메서드를 작성하고, `Integer`를 받아 `String`으로 바꾸는 예제를 만들어 보세요.

```java
public static <T, R> R process(T value, Function<T, R> function)
```

#### 3. 스트림 기본

##### 문제 9. `filter`

문자열 리스트에서 `"b"`만 출력하세요.

입력 예시:

```java
List<String> list = Arrays.asList("a", "b", "c");
```

##### 문제 10. `map`

문자열 리스트를 모두 대문자로 바꿔 출력하세요.

##### 문제 11. `collect`

대문자로 바꾼 결과를 다시 `List<String>`으로 수집하세요.

##### 문제 12. 메서드 참조

`forEach(System.out::println)` 형태로 리스트를 출력하세요.

#### 4. 스트림 중급

##### 문제 13. `flatMap`

중첩된 `List<List<String>>`를 하나의 `List<String>`으로 평탄화하세요.

입력 예시:

```java
List<List<String>> list = Arrays.asList(
    Arrays.asList("a", "b"),
    Arrays.asList("c", "d")
);
```

기대 결과:

```plain text
[a, b, c, d]
```

##### 문제 14. `reduce`

정수 리스트의 합계를 `reduce`로 계산하세요.

입력 예시:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4);
```

기대 출력:

```plain text
10
```

##### 문제 15. `groupingBy`

직원 목록을 부서별로 그룹화하고, 각 부서의 이름 목록만 남기세요.

##### 문제 16. `Comparator`와 람다

문자열 리스트를 오름차순으로 정렬하세요.

#### 5. Optional과 예외

##### 문제 17. `Optional.ifPresent`

값이 있을 때만 출력하는 코드를 작성하세요.

##### 문제 18. `orElseThrow`

값이 없을 때 `IllegalArgumentException`을 던지도록 작성하세요.

핵심 질문:

- `null` 체크와 비교했을 때 무엇이 더 분명해졌는가
- 예외를 던지는 시점을 코드에서 바로 읽을 수 있는가
#### 6. 실전 감각 문제

##### 문제 19. `peek`를 어디까지 허용할 것인가

아래 코드를 보고, 왜 `peek`는 디버깅 용도에 가깝다고 하는지 설명해 보세요.

```java
List<String> result = Arrays.asList("apple", "banana", "avocado").stream()
    .filter(s -> s.startsWith("a"))
    .peek(s -> System.out.println("[중간출력] " + s))
    .map(String::toUpperCase)
    .toList();
```

##### 문제 20. 병렬 스트림을 기본값으로 쓰지 않는 이유 설명하기

아래 질문에 문장으로 답해 보세요.

- 병렬 스트림이 항상 더 빠르지 않은 이유는 무엇인가
- 부작용이 있는 코드와 병렬 스트림을 섞으면 왜 위험한가
- 초중급 단계에서 먼저 익혀야 할 것은 병렬화인가, 순차 파이프라인 읽기인가
#### 7. 리팩터링 문제

##### 문제 21. `for` 문을 스트림으로 바꾸기

아래 코드를 스트림으로 바꿔 보세요.

```java
List<String> result = new ArrayList<>();
for (String name : names) {
    if (name.startsWith("K")) {
        result.add(name.toUpperCase());
    }
}
```

바꾼 뒤 아래도 같이 답해 보세요.

- 정말 더 읽기 좋아졌는가
- 예외 처리나 로깅이 추가되면 여전히 스트림이 적합한가
#### 풀이 전 체크 포인트

- 함수형 인터페이스의 입력과 출력 타입을 먼저 적었는가
- 스트림의 최종 결과 타입을 먼저 예상했는가
- `map`과 `forEach`를 혼동하지 않았는가

---
