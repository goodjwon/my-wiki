# 2. Java문법과객체
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 2.0 기본 문법: 변수, 자료형, 연산자

#### 개요

이 문서는 Java를 처음 다시 정리할 때 가장 먼저 확인해야 하는 기본 문법을 다룹니다. 변수, 자료형, 연산자는 너무 기초처럼 보이지만, 이후 객체지향과 컬렉션, 예외 처리 문서를 읽을 때 계속 기반이 되는 내용입니다.

#### 왜 중요한가

기초 문법은 단순 암기 영역이 아니라, 코드가 실제로 메모리에 어떻게 저장되고 어떤 결과를 만들어내는지 이해하는 출발점입니다. 여기서 흔들리면 이후 클래스, 객체, 컬렉션 문서도 추상적으로 느껴지기 쉽습니다.

#### 1. 변수란 무엇인가

변수는 값을 저장하기 위한 이름 있는 공간입니다.

```java
int age = 20;
String name = "Kim";
System.out.println(name + " : " + age);
```

```plain text
예상 결과
Kim : 20
```

##### 핵심 포인트

- 변수는 타입과 이름을 함께 가집니다.
- 같은 변수에는 같은 타입의 값만 저장할 수 있습니다.
- 읽기 좋은 변수 이름이 코드 이해 속도를 크게 좌우합니다.
#### 2. 기본 자료형

Java의 기본 자료형은 값을 직접 저장합니다.

- `byte`, `short`, `int`, `long`: 정수
- `float`, `double`: 실수
- `char`: 문자
- `boolean`: 참/거짓
```java
int count = 10;
double price = 19.99;
char grade = 'A';
boolean active = true;
```

#### 3. 참조 자료형

문자열, 배열, 객체는 참조 자료형입니다.

```java
String title = "Java";
int[] numbers = {1, 2, 3};
```

기본 자료형과 달리 실제 값 자체보다, 값을 가리키는 참조 개념을 함께 이해해야 합니다.

#### 4. 형 변환

##### 자동 형 변환

작은 범위의 값을 큰 범위로 옮길 때는 자동으로 변환됩니다.

```java
int num = 10;
double result = num;
```

##### 강제 형 변환

큰 범위의 값을 작은 범위로 옮길 때는 명시적으로 변환해야 합니다.

```java
double value = 3.14;
int result = (int) value;
```

이 경우 소수점 아래 값은 잘립니다.

#### 5. 산술 연산자

- `+`, `-`, `*`, `/`, `%`
```java
int a = 10;
int b = 3;
System.out.println(a + b);
System.out.println(a / b);
System.out.println(a % b);
```

```plain text
예상 결과
13
3
1
```

정수 나눗셈은 결과도 정수라는 점을 자주 실수합니다.

#### 6. 비교 연산자와 논리 연산자

- 비교 연산자: `==`, `!=`, `>`, `<`, `>=`, `<=`
- 논리 연산자: `&&`, `||`, `!`
```java
int age = 20;
boolean adult = age >= 19;
boolean weekend = true;
boolean canRest = adult && weekend;
```

#### 7. 증감 연산자와 대입 연산자

```java
int count = 0;
count++;
count += 5;
```

이 문법은 짧지만, 반복문과 조건문에서 자주 사용되므로 손에 익혀두는 편이 좋습니다.

#### 8. 문자열과 연산

문자열은 `+` 연산으로 이어 붙일 수 있습니다.

```java
String name = "Park";
int age = 20;
System.out.println(name + " is " + age + " years old.");
```

다만 반복문 안에서 문자열을 많이 붙일 때는 나중에 `StringBuilder`를 고려해야 합니다.

#### 자주 하는 실수

- `==`와 `equals()`를 구분하지 않는 것
- 정수 나눗셈 결과를 실수처럼 기대하는 것
- 형 변환 시 데이터 손실을 무시하는 것
- 변수 이름을 너무 짧거나 모호하게 쓰는 것
#### 실무 연결 포인트

기초 문법은 이후 DTO 필드 타입, 엔티티 속성, 조건 분기, API 응답 처리, 컬렉션 순회까지 모든 곳에 이어집니다. 즉 이 문서는 가장 단순하지만, 가장 넓게 연결되는 문서입니다.

#### 정리

변수, 자료형, 연산자는 Java 문법의 출발점입니다. 어렵지 않지만, 이 개념을 정확히 이해하면 이후 문서들을 훨씬 빠르고 안정적으로 읽을 수 있습니다.

#### 한 줄 정리

기본 문법의 핵심은 **문법 자체보다 값의 타입과 계산 결과가 어떻게 결정되는지 정확히 이해하는 것**입니다.


---

## 2.2 메서드와 배열, 문자열

#### 개요

이 문서는 제어문 다음 단계에서 반드시 정리해야 하는 `메서드`, `배열`, `문자열`을 한 흐름으로 묶은 가이드입니다. 이 세 가지는 문법 항목처럼 보이지만, 실제로는 **코드를 나누고, 여러 값을 다루고, 텍스트를 안전하게 처리하는 기본 도구**입니다.

#### 왜 여기서 배우는가

변수와 제어문만으로도 작은 코드는 만들 수 있습니다. 하지만 로직이 길어지고 입력이 늘어나면 같은 코드를 반복하게 됩니다. 이때 메서드는 로직을 나누고, 배열은 여러 값을 같은 규칙으로 다루게 해주며, 문자열은 사용자 입력과 파일, HTTP 요청처럼 실무에서 자주 만나는 텍스트 데이터를 처리하게 해줍니다.

#### 1. 메서드는 로직에 이름을 붙이는 단위다

메서드는 특정 작업을 하나의 이름 아래로 묶습니다. 좋은 메서드는 길지 않고, 하나의 책임이 분명합니다.

```java
public int sum(int left, int right) {
    return left + right;
}
```

메서드를 읽을 때는 세 가지를 먼저 봐야 합니다.

- 입력이 무엇인지
- 결과가 무엇인지
- 부수 효과가 있는지
메서드가 많아지는 것이 중요한 것이 아니라, **읽는 사람이 의도를 빠르게 이해할 수 있는 단위로 분리되는 것**이 중요합니다.

#### 2. 매개변수와 반환값을 분명히 구분해야 한다

매개변수는 메서드가 외부에서 받는 값이고, 반환값은 메서드가 계산해서 돌려주는 값입니다.

```java
public boolean isAdult(int age) {
    return age >= 20;
}
```

초보 단계에서 흔한 실수는 메서드가 계산도 하고 출력도 하고 상태도 바꾸는 식으로 여러 책임을 동시에 갖는 것입니다. 먼저는 입력과 출력이 분명한 메서드를 만드는 습관이 더 중요합니다.

#### 3. Java는 인자를 값으로 전달한다

Java에서는 기본형이든 참조값이든 **항상 값이 전달**됩니다. 객체를 넘기면 객체 자체가 복사되는 것이 아니라, 그 객체를 가리키는 참조값이 복사됩니다.

이 차이를 이해해야 메서드 안에서 값을 바꿨을 때 무엇이 바뀌고 무엇이 안 바뀌는지 설명할 수 있습니다.

#### 4. 배열은 같은 타입의 값을 순서대로 다루는 가장 기본 구조다

배열은 길이가 고정된 자료구조입니다.

```java
int[] scores = {90, 80, 100};
for (int i = 0; i < scores.length; i++) {
    System.out.println(scores[i]);
}
```

배열에서 꼭 기억할 기준은 아래와 같습니다.

- 인덱스는 0부터 시작합니다.
- 길이는 생성 시점에 정해집니다.
- 범위를 벗어나면 `ArrayIndexOutOfBoundsException`이 발생합니다.
배열은 컬렉션 프레임워크를 배우기 전 단계에서, 반복 처리와 인덱스 기반 접근을 익히는 데 가장 좋은 출발점입니다.

#### 5. 배열 변수와 배열 객체를 구분해야 한다

```java
int[] numbers = new int[3];
```

여기서 `numbers`는 참조 변수이고, 실제 배열 객체는 힙 메모리에 생성됩니다. 그래서 배열을 다른 변수에 대입하면 값이 복사되는 것이 아니라 같은 배열을 가리키게 됩니다.

```java
int[] source = {1, 2, 3};
int[] target = source;
target[0] = 99;

System.out.println(source[0]);
System.out.println(target[0]);
```

```plain text
예상 결과
99
99
```

이 경우 `source[0]`도 99가 됩니다. 같은 배열을 보고 있기 때문입니다.

#### 6. 문자열은 배열이 아니라 불변 객체다

문자열은 문자 묶음처럼 보이지만 Java에서는 `String` 객체입니다. 그리고 한 번 만들어진 문자열은 바뀌지 않습니다.

```java
String name = "java";
String upper = name.toUpperCase();

System.out.println(name);  // java
System.out.println(upper); // JAVA
```

문자열 메서드는 원본을 바꾸기보다 새 문자열을 돌려주는 경우가 많습니다. 이 특성을 알아야 디버깅할 때 혼란이 줄어듭니다.

#### 7. 문자열 비교는 `==`가 아니라 `equals`를 우선한다

`==`는 두 참조가 같은 객체를 가리키는지 비교하고, `equals`는 문자열 내용이 같은지 비교합니다.

```java
String a = new String("spring");
String b = new String("spring");

System.out.println(a == b);
System.out.println(a.equals(b));
```

```plain text
예상 결과
false
true
```

실무에서 문자열 비교 실수는 인증, 권한, 상태값 분기 같은 곳에서 바로 버그로 이어집니다.

#### 8. 문자열을 많이 이어 붙이면 `StringBuilder`를 고려한다

반복문 안에서 문자열을 계속 더하면 불필요한 객체가 많이 생길 수 있습니다.

```java
StringBuilder builder = new StringBuilder();
for (int i = 0; i < 3; i++) {
    builder.append(i);
}
String result = builder.toString();
```

초반에는 성능 최적화보다 개념 이해가 우선이지만, 문자열이 불변이라는 사실과 `StringBuilder`가 왜 필요한지는 여기서 잡아 두는 편이 좋습니다.

#### 9. 세 개념은 함께 써야 감이 잡힌다

예를 들어 학생 점수 목록이 배열로 들어오면, 평균 계산 로직은 메서드로 분리하고, 이름이나 상태 메시지는 문자열로 다루게 됩니다.

즉, 메서드는 구조를 만들고, 배열은 데이터를 담고, 문자열은 사용자와 시스템이 주고받는 텍스트를 표현합니다.

#### 자주 하는 실수

- 메서드 이름은 있는데 실제 책임이 너무 많은 경우
- 배열 길이를 확인하지 않고 인덱스에 접근하는 경우
- 배열 복사와 참조 공유를 구분하지 못하는 경우
- 문자열 비교에 `==`를 사용하는 경우
- 반복 문자열 결합을 무조건 `+`로만 처리하는 경우
#### 공식 문서 기준으로 더 보면 좋은 자료

- [Defining Methods](https://docs.oracle.com/javase/tutorial/java/javaOO/methods.html)
- [Arrays](https://docs.oracle.com/javase/tutorial/java/nutsandbolts/arrays.html)
- [Strings](https://docs.oracle.com/javase/tutorial/java/data/strings.html)
- [String API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/String.html)
#### 정리

메서드, 배열, 문자열은 각각 따로 외우는 문법 목록이 아닙니다. 이 셋은 작은 프로그램을 읽기 쉬운 구조로 바꾸고, 여러 데이터를 다루고, 텍스트 입력을 처리하게 만드는 가장 기본적인 도구입니다.

#### 한 줄 정리

좋은 Java 입문은 `변수와 제어문` 다음에 `메서드`, `배열`, `문자열`을 한 묶음으로 이해하는 데서부터 안정됩니다.


---

## 2.4 객체지향 원칙별 샘플 코드

#### 이 문서를 읽는 기준

객체지향 원칙은 정의를 외우는 순간보다, **같은 메시지를 보내도 객체 타입에 따라 다른 동작이 나온다**는 장면을 직접 볼 때 훨씬 빨리 잡힙니다. 아래 예시는 `day-by-java`의 게임 예제 흐름을 단순화한 것으로, 다형성과 오버라이딩을 가장 짧게 보여줍니다.

```java
public class Enemy {
    public String name;

    public Enemy(String name) {
        this.name = name;
    }

    public void attack() {
        System.out.println(name + "이 무기로 공격합니다!");
    }
}

class Goblin extends Enemy {
    public Goblin(String name) {
        super(name);
    }

    @Override
    public void attack() {
        System.out.println(name + "이 단검으로 찌릅니다!");
    }
}

class Troll extends Enemy {
    public Troll(String name) {
        super(name);
    }

    @Override
    public void attack() {
        System.out.println(name + "이 몽둥이로 내리칩니다!");
    }
}

class Main {
    public static void main(String[] args) {
        Enemy goblin = new Goblin("고블린");
        Enemy troll = new Troll("트롤");
        goblin.attack();
        troll.attack();
    }
}
```

```plain text
예상 결과
고블린이 단검으로 찌릅니다!
트롤이 몽둥이로 내리칩니다!
```

이 장면에서 중요한 점은 변수 타입이 둘 다 `Enemy`인데도 실제 동작은 하위 클래스 구현이 실행된다는 것입니다. 즉, 객체지향 원칙은 문법 이름보다 **책임 분리와 메시지 위임**으로 읽는 편이 더 정확합니다.

#### 1. 캡슐화(Encapsulation)

##### 예제 1: Private 필드와 Public 메서드 사용

```java
public class Person {
    // Private 필드
    private String name;
    private int age;

    // Public getter와 setter 메서드
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name; // 'this'는 인스턴스 변수를 가리킵니다.
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        if(age >= 0) { // 나이의 유효성 검사
            this.age = age;
        }
    }
}

```

**설명:** 

`Person` 클래스는 `name`과 `age` 필드를 `private`으로 선언하여 외부에서 직접 접근하지 못하게 합니다. 

대신 `public` 메서드인 `getName()`, `setName()`, `getAge()`, `setAge()`를 통해서만 접근 가능합니다.

##### 예제 2: 은행 계좌 클래스

```java
public class BankAccount {
    private double balance;

    // 생성자
    public BankAccount(double initialBalance) {
        balance = initialBalance;
    }

    // 입금 메서드
    public void deposit(double amount) {
        if(amount > 0) {
            balance += amount;
        }
    }

    // 출금 메서드
    public void withdraw(double amount) {
        if(amount > 0 && amount <= balance) {
            balance -= amount;
        }
    }

    // 잔액 조회 메서드 (읽기 전용)
    public double getBalance() {
        return balance;
    }
}

```

**설명:** 

`BankAccount` 클래스는 `balance` 필드를 `private`으로 선언하고, 입출금을 위한 메서드를 제공합니다. 이를 통해 데이터의 무결성을 유지하고, 직접적인 접근을 방지합니다.

#### 2. 상속(Inheritance)

##### 예제 1: 동물과 개 클래스

```java
// 부모 클래스
public class Animal {
    public void eat() {
        System.out.println("동물이 먹습니다.");
    }
}

// 자식 클래스
public class Dog extends Animal {
    public void bark() {
        System.out.println("개가 짖습니다.");
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Dog dog = new Dog();
        dog.eat();  // 부모 클래스로부터 상속된 메서드
        dog.bark(); // 자식 클래스에서 정의한 메서드
    }
}

```

**설명:** 

`Dog` 클래스는 `Animal` 클래스를 상속받아 `eat()` 메서드를 사용할 수 있으며, 자신만의 `bark()` 메서드를 추가로 제공합니다.

##### 예제 2: 차량과 자동차 클래스

```java
// 부모 클래스
public class Vehicle {
    protected String brand = "현대";

    public void honk() {
        System.out.println("빵빵!");
    }
}

// 자식 클래스
public class Car extends Vehicle {
    private String modelName = "소나타";

    public static void main(String[] args) {
        Car myCar = new Car();
        myCar.honk(); // 부모 클래스로부터 상속된 메서드
        System.out.println(myCar.brand + " " + myCar.modelName);
    }
}

```

**설명:** 

`Car` 클래스는 `Vehicle` 클래스를 상속받아 `brand` 필드와 `honk()` 메서드를 사용할 수 있습니다.

##### 예제 3: 직원과 매니저 클래스

```java
public class Employee {
    public void work() {
        System.out.println("직원이 일합니다.");
    }
}

public class Manager extends Employee {
    @Override
    public void work() {
        System.out.println("매니저가 일하고 있습니다.");
    }

    public void manage() {
        System.out.println("매니저가 관리하고 있습니다.");
    }
}

public class Main {
    public static void main(String[] args) {
        Employee emp = new Employee();
        emp.work(); // 출력: 직원이 일합니다.

        Manager mgr = new Manager();
        mgr.work(); // 출력: 매니저가 일하고 있습니다.
        mgr.manage(); // 출력: 매니저가 관리하고 있습니다.
    }
}

```

**설명:** 

`Manager` 클래스는 `Employee` 클래스를 상속받아 `work()` 메서드를 재정의하고, 추가로 `manage()` 메서드를 제공합니다.

#### 3. 다형성(Polymorphism)

##### 예제 1: 메서드 오버로딩 (Overloading)

```java
public class Calculator {
    // 두 개의 정수 합
    public int add(int a, int b) {
        return a + b;
    }

    // 세 개의 정수 합
    public int add(int a, int b, int c) {
        return a + b + c;
    }

    // 두 개의 실수 합
    public double add(double a, double b) {
        return a + b;
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Calculator calc = new Calculator();
        System.out.println(calc.add(2, 3)); // 출력: 5
        System.out.println(calc.add(2, 3, 4)); // 출력: 9
        System.out.println(calc.add(2.5, 3.5)); // 출력: 6.0
    }
}

```

**설명:** 

`Calculator` 클래스는 같은 이름의 `add` 메서드를 여러 개 정의하여, 입력 매개변수에 따라 다른 동작을 수행합니다.

##### 예제 2: 메서드 오버라이딩 (Overriding)과 다형성

```java
public class Animal {
    public void makeSound() {
        System.out.println("동물이 소리를 냅니다.");
    }
}

public class Cat extends Animal {
    @Override
    public void makeSound() {
        System.out.println("고양이가 야옹합니다.");
    }
}

public class Dog extends Animal {
    @Override
    public void makeSound() {
        System.out.println("개가 멍멍합니다.");
    }
}

public class Main {
    public static void main(String[] args) {
        Animal myAnimal = new Animal();
        Animal myCat = new Cat();
        Animal myDog = new Dog();

        myAnimal.makeSound(); // 출력: 동물이 소리를 냅니다.
        myCat.makeSound();    // 출력: 고양이가 야옹합니다.
        myDog.makeSound();    // 출력: 개가 멍멍합니다.
    }
}

```

**설명:**

##### 예제 3: 인터페이스와 다형성

```java
public interface Shape {
    public double getArea();
}

public class Circle implements Shape {
    private double radius;

    public Circle(double radius) {
        this.radius = radius;
    }

    @Override
    public double getArea() {
        return Math.PI * radius * radius;
    }
}

public class Rectangle implements Shape {
    private double width, height;

    public Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public double getArea() {
        return width * height;
    }
}

public class Main {
    public static void main(String[] args) {
        Shape s1 = new Circle(5);
        Shape s2 = new Rectangle(4, 6);

        System.out.println("원의 면적: " + s1.getArea());
        System.out.println("사각형의 면적: " + s2.getArea());
    }
}

```

**설명:** 

`Shape` 인터페이스를 구현한 `Circle`과 `Rectangle` 클래스는 `getArea()` 메서드를 각각 다르게 구현합니다. 이를 통해 인터페이스 타입의 변수로 다양한 객체를 다룰 수 있습니다.

#### 4. 추상화(Abstraction)

##### 예제 1: 추상 클래스 사용

```java
public abstract class Animal {
    public abstract void makeSound();

    public void sleep() {
        System.out.println("동물이 잠을 잡니다.");
    }
}

public class Dog extends Animal {
    @Override
    public void makeSound() {
        System.out.println("개가 멍멍합니다.");
    }
}

public class Main {
    public static void main(String[] args) {
        Animal dog = new Dog();
        dog.makeSound(); // 출력: 개가 멍멍합니다.
        dog.sleep();     // 출력: 동물이 잠을 잡니다.
    }
}

```

**설명:** 

`Animal` 추상 클래스는 `makeSound()` 추상 메서드를 선언하여 하위 클래스에서 구현하도록 합니다. `Dog` 클래스는 이를 구현하여 구체적인 동작을 정의합니다.

##### 예제 2: 인터페이스 사용

```java
public interface RemoteControl {
    void turnOn();
    void turnOff();
}

public class Television implements RemoteControl {
    @Override
    public void turnOn() {
        System.out.println("TV를 켭니다.");
    }

    @Override
    public void turnOff() {
        System.out.println("TV를 끕니다.");
    }
}

public class Main {
    public static void main(String[] args) {
        RemoteControl tv = new Television();
        tv.turnOn();  // 출력: TV를 켭니다.
        tv.turnOff(); // 출력: TV를 끕니다.
    }
}

```

**설명:** 

`RemoteControl` 인터페이스는 전자 기기의 공통 동작을 정의하고, `Television` 클래스는 이를 구현하여 구체적인 동작을 제공합니다.

##### 예제 3: 추상 클래스를 이용한 템플릿 메서드 패턴

```java
public abstract class Game {
    abstract void initialize();
    abstract void startPlay();
    abstract void endPlay();

    // 템플릿 메서드
    public final void play() {
        initialize();
        startPlay();
        endPlay();
    }
}

public class Football extends Game {
    @Override
    void initialize() {
        System.out.println("축구 게임 초기화!");
    }

    @Override
    void startPlay() {
        System.out.println("축구 게임 시작!");
    }

    @Override
    void endPlay() {
        System.out.println("축구 게임 종료!");
    }
}

public class Main {
    public static void main(String[] args) {
        Game game = new Football();
        game.play();
        /*
        출력:
        축구 게임 초기화!
        축구 게임 시작!
        축구 게임 종료!
        */
    }
}

```

**설명:** 

`Game` 추상 클래스는 게임 진행의 템플릿을 정의하고, 구체적인 구현은 하위 클래스인 `Football`에서 제공합니다.




---

## 2.5 추상 클래스 활용 예제

#### 이 문서를 읽는 기준

추상 클래스는 "new로 바로 만들 수 없는 클래스"라는 정의만 외우면 오래 남지 않습니다. 더 중요한 것은 **공통 흐름은 부모가 잡고, 달라지는 부분만 자식이 채운다**는 구조를 보는 것입니다.

`day-by-java`의 템플릿 메서드 예제를 단순화하면 아래처럼 읽을 수 있습니다.

```java
public abstract class AbstractDataProcessor {
    public final void process() {
        System.out.println("--- " + getClass().getSimpleName() + " 실행 ---");
        String data = selectData();
        String processedData = transformData(data);
        saveData(processedData);
    }

    private String selectData() {
        System.out.println("[공통] 데이터베이스에서 데이터를 조회합니다.");
        return "id,name,role";
    }

    private void saveData(String data) {
        System.out.println("[공통] 변환된 데이터를 파일에 씁니다: " + data);
        System.out.println("[저장] " + getFileName() + " 파일이 성공적으로 생성되었습니다.");
    }

    protected abstract String transformData(String data);
    protected abstract String getFileName();
}

public class CsvDataProcessor extends AbstractDataProcessor {
    @Override
    protected String transformData(String data) {
        System.out.println("[CSV] 데이터를 쉼표(,)로 구분된 형식으로 변환합니다.");
        return data.replace(",", ", ");
    }

    @Override
    protected String getFileName() {
        return "data.csv";
    }
}
```

```plain text
예상 결과
--- CsvDataProcessor 실행 ---
[공통] 데이터베이스에서 데이터를 조회합니다.
[CSV] 데이터를 쉼표(,)로 구분된 형식으로 변환합니다.
[공통] 변환된 데이터를 파일에 씁니다: id, name, role
[저장] data.csv 파일이 성공적으로 생성되었습니다.
```

이 예제에서 핵심은 `process()` 전체 순서는 부모 클래스가 고정하고, 실제 변환 규칙과 파일명만 자식 클래스가 결정한다는 점입니다. 즉, 추상 클래스는 단순 상속 문법이 아니라 **공통 뼈대를 재사용하면서도 확장 지점을 열어 두는 도구**입니다.

#### 예제 1: 직원 관리 시스템

##### 추상 클래스와 구체 클래스

```java
// 추상 클래스
public abstract class Employee {
    protected String name;
    protected int id;

    public Employee(String name, int id) {
        this.name = name;
        this.id = id;
    }

    // 추상 메서드
    public abstract double calculateSalary();

    // 일반 메서드
    public void displayInfo() {
        System.out.println("이름: " + name);
        System.out.println("ID: " + id);
    }
}

// 정규직 직원 클래스
public class FullTimeEmployee extends Employee {
    private double annualSalary;

    public FullTimeEmployee(String name, int id, double annualSalary) {
        super(name, id);
        this.annualSalary = annualSalary;
    }

    @Override
    public double calculateSalary() {
        return annualSalary / 12; // 월급 계산
    }
}

// 계약직 직원 클래스
public class ContractEmployee extends Employee {
    private double hourlyRate;
    private int hoursWorked;

    public ContractEmployee(String name, int id, double hourlyRate, int hoursWorked) {
        super(name, id);
        this.hourlyRate = hourlyRate;
        this.hoursWorked = hoursWorked;
    }

    @Override
    public double calculateSalary() {
        return hourlyRate * hoursWorked; // 급여 계산
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Employee emp1 = new FullTimeEmployee("홍길동", 101, 60000000);
        Employee emp2 = new ContractEmployee("김영희", 102, 20000, 160);

        emp1.displayInfo();
        System.out.println("월급: " + emp1.calculateSalary() + "원\\n");

        emp2.displayInfo();
        System.out.println("급여: " + emp2.calculateSalary() + "원");
    }
}

```

**설명:** 

`Employee` 추상 클래스는 공통 필드와 메서드를 가지며, `calculateSalary()` 추상 메서드를 통해 직원 유형에 따라 급여 계산 방법을 다르게 구현.

---

#### 예제 2: 그래픽 요소의 계층 구조

##### 추상 클래스와 다형성의 결합

```java
// 추상 클래스
public abstract class Graphic {
    // 추상 메서드
    public abstract void draw();

    // 공통 메서드
    public void move(int x, int y) {
        System.out.println("좌표 (" + x + ", " + y + ")로 이동합니다.");
    }
}

// 구체적인 그래픽 요소 클래스
public class Circle extends Graphic {
    private int radius;

    public Circle(int radius) {
        this.radius = radius;
    }

    @Override
    public void draw() {
        System.out.println("반지름이 " + radius + "인 원을 그립니다.");
    }
}

public class Rectangle extends Graphic {
    private int width, height;

    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public void draw() {
        System.out.println("가로 " + width + ", 세로 " + height + "인 사각형을 그립니다.");
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Graphic circle = new Circle(5);
        Graphic rectangle = new Rectangle(4, 6);

        circle.draw();
        circle.move(10, 20);

        rectangle.draw();
        rectangle.move(30, 40);
    }
}

```

**설명:** 

`Graphic` 추상 클래스는 그래픽 요소의 공통 동작을 정의하며, `Circle`과 `Rectangle` 클래스는 이를 상속받아 구체적인 `draw()` 메서드를 구현.

---

#### 예제 3: 템플릿 메서드 패턴의 응용

##### 데이터 처리 과정의 추상화

```java
public abstract class DataProcessor {
    // 템플릿 메서드
    public final void process() {
        readData();
        processData();
        saveData();
    }

    // 공통 구현 메서드
    public void readData() {
        System.out.println("데이터를 읽습니다.");
    }

    // 하위 클래스에서 구현할 추상 메서드
    public abstract void processData();

    // 공통 구현 메서드
    public void saveData() {
        System.out.println("데이터를 저장합니다.");
    }
}

// CSV 데이터 처리 클래스
public class CSVDataProcessor extends DataProcessor {
    @Override
    public void processData() {
        System.out.println("CSV 데이터를 처리합니다.");
    }
}

// XML 데이터 처리 클래스
public class XMLDataProcessor extends DataProcessor {
    @Override
    public void processData() {
        System.out.println("XML 데이터를 처리합니다.");
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        DataProcessor csvProcessor = new CSVDataProcessor();
        csvProcessor.process();
        /*
        출력:
        데이터를 읽습니다.
        CSV 데이터를 처리합니다.
        데이터를 저장합니다.
        */

        DataProcessor xmlProcessor = new XMLDataProcessor();
        xmlProcessor.process();
        /*
        출력:
        데이터를 읽습니다.
        XML 데이터를 처리합니다.
        데이터를 저장합니다.
        */
    }
}

```

**설명:** 

`DataProcessor` 추상 클래스는 데이터 처리 흐름을 정의하는 템플릿 메서드 `process()`를 제공. 세부적인 데이터 처리 부분은 하위 클래스에서 구현.

---

#### 예제 4: 게임 캐릭터의 능력 정의

##### 추상 클래스와 인터페이스의 조합

```java
// 추상 클래스
public abstract class Character {
    protected String name;

    public Character(String name) {
        this.name = name;
    }

    // 추상 메서드
    public abstract void attack();

    // 공통 메서드
    public void move() {
        System.out.println(name + "이(가) 이동합니다.");
    }
}

// 인터페이스
public interface Magic {
    void castSpell();
}

// 전사 클래스
public class Warrior extends Character {
    public Warrior(String name) {
        super(name);
    }

    @Override
    public void attack() {
        System.out.println(name + "이(가) 검으로 공격합니다.");
    }
}

// 마법사 클래스
public class Wizard extends Character implements Magic {
    public Wizard(String name) {
        super(name);
    }

    @Override
    public void attack() {
        System.out.println(name + "이(가) 지팡이로 공격합니다.");
    }

    @Override
    public void castSpell() {
        System.out.println(name + "이(가) 마법을 시전합니다.");
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Character warrior = new Warrior("아서");
        warrior.move();
        warrior.attack();

        Wizard wizard = new Wizard("메르린");
        wizard.move();
        wizard.attack();
        wizard.castSpell();
    }
}

```

**설명:** `Character` 추상 클래스는 게임 캐릭터의 기본 동작을 정의하고, `Magic` 인터페이스는 마법사만의 능력을 정의. `Warrior`와 `Wizard` 클래스는 각각 이를 구현하여 캐릭터의 특성을 나타냄.

---

#### 예제 5: 가전 제품의 전원 관리

##### 추상 클래스의 기본 구현 제공

```java
public abstract class Appliance {
    protected boolean isOn = false;

    // 전원 켜기
    public void turnOn() {
        isOn = true;
        System.out.println(getClass().getSimpleName() + " 전원이 켜졌습니다.");
    }

    // 전원 끄기
    public void turnOff() {
        isOn = false;
        System.out.println(getClass().getSimpleName() + " 전원이 꺼졌습니다.");
    }

    // 추상 메서드: 기능 수행
    public abstract void performFunction();
}

// 냉장고 클래스
public class Refrigerator extends Appliance {
    @Override
    public void performFunction() {
        if(isOn) {
            System.out.println("냉장고가 냉각을 시작합니다.");
        } else {
            System.out.println("냉장고 전원이 꺼져 있습니다.");
        }
    }
}

// 세탁기 클래스
public class WashingMachine extends Appliance {
    @Override
    public void performFunction() {
        if(isOn) {
            System.out.println("세탁기가 세탁을 시작합니다.");
        } else {
            System.out.println("세탁기 전원이 꺼져 있습니다.");
        }
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Appliance fridge = new Refrigerator();
        fridge.turnOn();
        fridge.performFunction();

        Appliance washer = new WashingMachine();
        washer.performFunction();
        washer.turnOn();
        washer.performFunction();
    }
}

```

**설명:** `Appliance` 추상 클래스는 가전 제품의 공통 동작(전원 관리)을 구현하고, 구체적인 기능은 추상 메서드 `performFunction()`을 통해 하위 클래스에서 정의.

---

#### 예제 6: 온라인 주문 처리 시스템

##### 추상 클래스의 부분 구현 활용

```java
public abstract class OrderProcessor {
    // 주문 처리 전체 흐름
    public void processOrder() {
        selectItem();
        makePayment();
        if(isGift()) {
            wrapGift();
        }
        shipItem();
    }

    // 공통 구현 메서드
    public void selectItem() {
        System.out.println("상품을 선택했습니다.");
    }

    // 추상 메서드
    public abstract void makePayment();

    // 후크 메서드 (필요에 따라 오버라이드)
    public boolean isGift() {
        return false;
    }

    // 공통 구현 메서드
    public void wrapGift() {
        System.out.println("선물 포장을 합니다.");
    }

    // 공통 구현 메서드
    public void shipItem() {
        System.out.println("상품을 배송합니다.");
    }
}

// 신용카드 결제 클래스
public class CreditCardOrder extends OrderProcessor {
    @Override
    public void makePayment() {
        System.out.println("신용카드로 결제합니다.");
    }
}

// 페이팔 결제 클래스
public class PayPalOrder extends OrderProcessor {
    @Override
    public void makePayment() {
        System.out.println("PayPal로 결제합니다.");
    }

    @Override
    public boolean isGift() {
        return true;
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        OrderProcessor order1 = new CreditCardOrder();
        order1.processOrder();
        /*
        출력:
        상품을 선택했습니다.
        신용카드로 결제합니다.
        상품을 배송합니다.
        */

        OrderProcessor order2 = new PayPalOrder();
        order2.processOrder();
        /*
        출력:
        상품을 선택했습니다.
        PayPal로 결제합니다.
        선물 포장을 합니다.
        상품을 배송합니다.
        */
    }
}

```

**설명:** `OrderProcessor` 추상 클래스는 주문 처리의 전체 흐름을 정의하며, 결제 방법과 선물 포장 여부는 하위 클래스에서 결정.

---

#### 예제 7: 교육 과정 관리

##### 추상 클래스에서 공통 동작과 추상화된 동작 정의

```java
public abstract class Course {
    public void takeCourse() {
        enroll();
        attendLectures();
        submitAssignments();
        takeExams();
        getCertificate();
    }

    // 공통 구현 메서드
    public void enroll() {
        System.out.println("과정에 등록했습니다.");
    }

    public void attendLectures() {
        System.out.println("강의를 듣습니다.");
    }

    public void submitAssignments() {
        System.out.println("과제를 제출합니다.");
    }

    // 추상 메서드
    public abstract void takeExams();

    // 공통 구현 메서드
    public void getCertificate() {
        System.out.println("수료증을 받습니다.");
    }
}

// 온라인 과정 클래스
public class OnlineCourse extends Course {
    @Override
    public void takeExams() {
        System.out.println("온라인 시험을 봅니다.");
    }
}

// 오프라인 과정 클래스
public class OfflineCourse extends Course {
    @Override
    public void takeExams() {
        System.out.println("오프라인 시험을 봅니다.");
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Course onlineCourse = new OnlineCourse();
        onlineCourse.takeCourse();
        /*
        출력:
        과정에 등록했습니다.
        강의를 듣습니다.
        과제를 제출합니다.
        온라인 시험을 봅니다.
        수료증을 받습니다.
        */

        Course offlineCourse = new OfflineCourse();
        offlineCourse.takeCourse();
        /*
        출력:
        과정에 등록했습니다.
        강의를 듣습니다.
        과제를 제출합니다.
        오프라인 시험을 봅니다.
        수료증을 받습니다.
        */
    }
}

```

**설명:** `Course` 추상 클래스는 교육 과정의 일반적인 흐름을 정의하고, 시험 방식은 추상 메서드로 선언하여 하위 클래스에서 구체화.

---

#### 예제 8: 파일 시스템 구성

##### 추상 클래스와 재귀적 구조 표현

```java
public abstract class FileSystemComponent {
    protected String name;

    public FileSystemComponent(String name) {
        this.name = name;
    }

    // 추상 메서드
    public abstract void display(String indent);
}

// 파일 클래스
public class File extends FileSystemComponent {
    public File(String name) {
        super(name);
    }

    @Override
    public void display(String indent) {
        System.out.println(indent + "파일: " + name);
    }
}

// 디렉토리 클래스
import java.util.ArrayList;
import java.util.List;

public class Directory extends FileSystemComponent {
    private List<FileSystemComponent> components = new ArrayList<>();

    public Directory(String name) {
        super(name);
    }

    public void addComponent(FileSystemComponent component) {
        components.add(component);
    }

    @Override
    public void display(String indent) {
        System.out.println(indent + "디렉토리: " + name);
        for(FileSystemComponent component : components) {
            component.display(indent + "    ");
        }
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Directory root = new Directory("루트");
        File file1 = new File("파일1.txt");
        File file2 = new File("파일2.txt");

        Directory subDir = new Directory("서브디렉토리");
        File file3 = new File("파일3.txt");

        root.addComponent(file1);
        root.addComponent(file2);
        root.addComponent(subDir);

        subDir.addComponent(file3);

        root.display("");
        /*
        출력:
        디렉토리: 루트
            파일: 파일1.txt
            파일: 파일2.txt
            디렉토리: 서브디렉토리
                파일: 파일3.txt
        */
    }
}

```

**설명:** `FileSystemComponent` 추상 클래스는 파일과 디렉토리의 공통 동작을 정의하며, 재귀적인 구조를 표현하기 위해 디렉토리 내에 구성 요소를 추가.

---

#### 예제 9: 메시지 전송 시스템

##### 추상 클래스의 계층 구조 확장

```java
public abstract class MessageSender {
    protected String sender;
    protected String receiver;

    public MessageSender(String sender, String receiver) {
        this.sender = sender;
        this.receiver = receiver;
    }

    // 추상 메서드
    public abstract void sendMessage(String message);
}

// 이메일 전송 클래스
public class EmailSender extends MessageSender {
    public EmailSender(String sender, String receiver) {
        super(sender, receiver);
    }

    @Override
    public void sendMessage(String message) {
        System.out.println("이메일 전송");
        System.out.println("보낸 사람: " + sender);
        System.out.println("받는 사람: " + receiver);
        System.out.println("메시지: " + message);
    }
}

// SMS 전송 클래스
public class SMSSender extends MessageSender {
    public SMSSender(String sender, String receiver) {
        super(sender, receiver);
    }

    @Override
    public void sendMessage(String message) {
        System.out.println("SMS 전송");
        System.out.println("보낸 사람: " + sender);
        System.out.println("받는 사람: " + receiver);
        System.out.println("메시지: " + message);
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        MessageSender email = new EmailSender("admin@example.com", "user@example.com");
        email.sendMessage("안녕하세요, 이메일입니다.");

        MessageSender sms = new SMSSender("010-1234-5678", "010-8765-4321");
        sms.sendMessage("안녕하세요, SMS입니다.");
    }
}

```

**설명:** `MessageSender` 추상 클래스는 메시지 전송의 공통 인터페이스를 정의하고, `EmailSender`와 `SMSSender` 클래스는 각각 이메일과 SMS 전송 방법을 구현.

---

#### 예제 10: 추상 클래스의 다중 수준 상속

##### 추상 클래스의 계층적 설계

```java
// 최상위 추상 클래스
public abstract class Vehicle {
    public abstract void move();
}

// 중간 추상 클래스
public abstract class AirVehicle extends Vehicle {
    public abstract void fly();
}

// 구체 클래스
public class Airplane extends AirVehicle {
    @Override
    public void move() {
        System.out.println("비행기가 활주로를 이동합니다.");
    }

    @Override
    public void fly() {
        System.out.println("비행기가 하늘을 납니다.");
    }
}

// 사용 예시
public class Main {
    public static void main(String[] args) {
        Airplane airplane = new Airplane();
        airplane.move();
        airplane.fly();
    }
}

```

**설명:** `Vehicle` 추상 클래스를 상속한 `AirVehicle` 추상 클래스는 추가적인 추상 메서드를 정의하며, `Airplane` 클래스는 이를 모두 구현.

---

#### 결론

추상 클래스는 공통된 동작과 인터페이스를 정의하면서도, 하위 클래스에서의 구체적인 구현을 **강제함으로써 **코드의 유연성과 재사용성 향상시킴. 




---

## 2.1 제어문: 조건문, 반복문

#### 개요

이 문서는 Java에서 조건문과 반복문을 어떻게 읽고 써야 하는지 정리한 기초 가이드입니다. 제어문은 단순히 문법 블록을 외우는 주제가 아니라, **프로그램의 흐름을 어떤 기준으로 분기하고 반복할지 결정하는 도구**입니다.

#### 1. 조건문은 분기 기준을 코드로 표현하는 방법이다

`if`, `if-else`, `if-else if-else`의 핵심은 **더 구체적이거나 더 우선순위가 높은 조건을 먼저 배치해야 한다**는 점입니다.

#### 2. `switch`는 값 중심 분기에 적합하다

고정된 값 비교는 `switch`가 더 읽기 쉽습니다.

#### 3. 반복문은 같은 작업을 여러 번 수행하는 구조다

반복문의 핵심은 "몇 번 도는가"보다, **언제 시작하고 언제 멈추는가**를 분명히 하는 것입니다.

#### 한 줄 정리

제어문의 핵심은 **문법을 외우는 것이 아니라, 프로그램 흐름이 왜 그렇게 갈라지고 반복되는지 설명할 수 있는 것**입니다.

---

## 2.3 객체지향 프로그래밍

#### 개요

이 문서는 Java에서 객체지향 프로그래밍을 어떻게 이해해야 하는지 정리한 핵심 이론 문서입니다. 객체지향은 문법 항목 하나가 아니라, **상태와 행위를 함께 묶고 책임을 나누는 사고 방식**에 가깝습니다.

#### 주요 내용

1. 클래스와 객체를 먼저 정확히 구분할 것
2. 객체지향의 출발점은 데이터가 아니라 책임이다
3. 캡슐화는 getter/setter 자동 생성과 다르다 — **잘못된 상태 변경을 막는 것**이 목적
4. 상속보다 먼저 합성을 의식할 것
5. 다형성은 같은 메시지에 다른 응답을 만드는 구조다
6. 추상화와 인터페이스는 변경 가능성을 다루는 도구다
7. 생성자는 객체의 시작 상태를 보장해야 한다

#### 한 줄 정리

객체지향의 핵심은 **데이터를 객체에 넣는 것이 아니라, 책임을 객체에 배치하는 것**입니다.

---

## 2.9 객체지향 실전문제

#### 개요

이 문서는 `객체지향 프로그래밍` 장을 읽은 뒤 바로 이어서 푸는 실전문제입니다. 클래스와 객체, 생성자, 캡슐화, 상속, 다형성, 추상화, 인터페이스, 예외 처리까지 Java 학습의 기초 주제를 다시 확인하는 데 목적이 있습니다.

#### 문제 구성

1. 객체 모델링과 OOP 개념 정리
2. 클래스와 객체
3. 생성자
4. 캡슐화
5. 상속과 다형성
6. 추상화와 인터페이스
7. 예외 처리

#### 한 줄 정리

객체지향 기초 문제의 목적은 정답 코드 작성보다, 객체가 어떤 책임을 가져야 하는지 판단하는 눈을 기르는 데 있습니다.

---

