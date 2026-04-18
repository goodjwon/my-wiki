# 10. 입출력과네트워크
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 10.0 입출력과 네트워크 개요

#### 개요

이 문서는 `입출력과 네트워크` 장의 안내 문서입니다. 이 장의 주제는 예외 처리, 파일 입출력, 네트워크 통신, JDBC처럼 서로 달라 보이지만, 실제로는 하나의 공통점을 가집니다. 모두 **외부 자원과 연결되는 코드**라는 점입니다.

이 단계부터는 단순히 문법을 아는 것만으로는 부족합니다. 파일은 언제든 없을 수 있고, 네트워크는 지연되거나 끊길 수 있고, 데이터베이스 연결은 실패할 수 있습니다. 그래서 이 장의 핵심은 API 이름을 많이 외우는 것이 아니라, **실패 가능한 자원을 안전하게 다루는 습관**을 익히는 데 있습니다.

#### 왜 이 장이 따로 필요한가

Java 문법과 객체지향, 컬렉션을 학습한 뒤에도 실제 프로그램이 바로 실무 코드처럼 느껴지지 않는 이유가 있습니다. 앞선 장들에서는 주로 메모리 안에서만 동작하는 예제를 다뤘다면, 이 장부터는 프로그램이 파일 시스템, 네트워크, 데이터베이스 같은 외부 세계와 만나기 시작하기 때문입니다.

#### 현재 저장소 기준으로 읽는 법

이 장은 소스 기준이 두 갈래입니다.

- `day_by_spring`: 실제 프로젝트에서 외부 자원을 Spring 추상화 위에서 다루는 기준
- `day-by-java`: 파일 처리, 소켓 통신, 순수 JDBC 같은 저수준 예제를 직접 보는 기준
즉 9장은 `day_by_spring`처럼 고수준 프레임워크 코드만 읽어서는 감이 안 잡히는 부분을 `day-by-java` 예제로 메우는 장입니다.

```plain text
예상 결과
파일, 네트워크, JDBC 문서를 읽을 때 "현재 Spring 프로젝트는 어디까지 추상화했는가"와
"자바 표준 API 수준에서는 실제로 무슨 일이 벌어지는가"를 함께 비교할 수 있다.
```

이때부터 코드의 난이도는 연산 자체보다 아래 질문에서 올라갑니다.

- 실패하면 어떻게 복구할 것인가
- 자원을 언제 열고 언제 닫을 것인가
- 예외를 어디서 감싸고 어디서 던질 것인가
- 데이터를 한 번에 다 읽을지, 스트리밍할지
- 네트워크와 DB 연결을 얼마나 신뢰할 수 있는가
즉, 이 장은 Java를 "언어"로 배우는 단계에서, **실행 환경과 외부 자원을 고려하는 프로그램**으로 확장하는 구간입니다.

#### 이 장의 중심 주제

##### 1. 예외

예외는 파일, 네트워크, DB에서 발생하는 실패를 코드로 드러내는 기본 구조입니다. 그래서 이 장에서는 가장 먼저 예외를 봅니다. 예외를 이해하지 못하면 이후의 모든 입출력 코드가 그저 `try-catch` 문법처럼만 보이게 됩니다.

##### 2. 파일 입출력

파일 처리는 가장 가까운 외부 자원입니다. 텍스트 파일, 바이너리 파일, 큰 파일을 다루는 방식이 각각 다르고, 읽기/쓰기 방식에 따라 메모리 사용과 성능이 달라집니다.

##### 3. 네트워크 통신

네트워크 코드는 파일보다 더 불안정합니다. 연결 실패, 지연, 타임아웃, 상대 서버 장애 같은 변수가 항상 존재합니다. 그래서 통신 코드는 정상 흐름보다 실패 흐름을 더 자주 의식해야 합니다.

##### 4. JDBC

JDBC는 Java 코드가 데이터베이스와 직접 연결되는 가장 기본적인 계층입니다. ORM을 쓰더라도 결국 커넥션, 쿼리 실행, 결과 매핑, 자원 해제라는 기본 구조를 이해하고 있는 편이 훨씬 강합니다.

#### 왜 예외를 맨 앞에 두는가

`Java 예외 종류 정리`와 `예외와 사용자 정의 예외`를 먼저 읽는 이유는 단순합니다. 그 뒤에 나오는 파일, 네트워크, JDBC는 모두 실패를 예외로 표현하기 때문입니다.

예를 들어 아래 문제는 전부 예외와 연결됩니다.

- 파일이 존재하지 않음
- 호스트 이름을 해석하지 못함
- 소켓 연결 거부
- SQL 제약조건 위반
- 잘못된 입력으로 인한 파싱 실패
그래서 이 장의 실제 학습 순서는 "파일 API부터"가 아니라, **실패를 읽는 눈을 먼저 만든 뒤 외부 자원으로 들어가는 순서**가 더 자연스럽습니다.

#### 권장 읽는 순서

1. `Java 예외 종류 정리`
1. `예외와 사용자 정의 예외`
1. `파일 읽기와 쓰기 기초`
1. `여러 형식의 파일 처리`
1. `네트워크 프로그래밍 기초`
1. `JDBC 기초`
이 순서는 난이도보다도 공통 모델을 기준으로 잡은 순서입니다. 먼저 실패를 이해하고, 그다음 파일, 네트워크, DB로 확장하는 방식입니다.

#### 문서별 역할

##### Java 예외 종류 정리

자주 만나는 예외를 범주별로 훑는 참조 문서입니다. 로그를 읽을 때 어떤 유형의 실패인지 빠르게 감을 잡게 해줍니다.

##### 예외와 사용자 정의 예외

예외를 어떻게 설계하고, 어디에서 감싸고, 언제 사용자 정의 예외를 도입할지 설명하는 문서입니다. 이 장의 사고방식을 잡는 핵심 문서입니다.

##### 파일 읽기와 쓰기 기초

`Reader/Writer`, `InputStream/OutputStream`, `Files`, `Buffered` 계열 API를 어떤 상황에서 써야 하는지 이해하는 출발점입니다.

##### 여러 형식의 파일 처리

CSV, JSON, 엑셀처럼 형식이 다른 파일을 같은 방식으로 다루면 왜 문제가 생기는지, 형식별 전략 차이를 설명합니다.

##### 네트워크 프로그래밍 기초

TCP, UDP, 소켓 통신을 예제로 연결합니다. 요청-응답 구조와 네트워크 오류를 함께 이해하게 해줍니다.

##### JDBC 기초

커넥션, SQL 실행, 결과 조회, 자원 해제라는 가장 기본적인 DB 접근 구조를 익히는 문서입니다.

#### 이 장에서 계속 반복되는 질문

이 장의 세부 문서를 읽을 때는 아래 질문을 계속 붙잡는 편이 좋습니다.

- 이 코드는 어떤 외부 자원에 의존하는가
- 실패 가능성은 어디에서 생기는가
- 예외를 지금 처리해야 하는가, 상위로 보내야 하는가
- 자원이 반드시 닫히는 구조인가
- 한 번에 메모리에 올리는 방식이 안전한가
이 질문이 있어야 예제 코드를 단순 실행 예제가 아니라, 구조 예제로 읽을 수 있습니다.

#### 실무 연결 포인트

- 파일 처리에서는 `try-with-resources`와 스트리밍 감각이 중요합니다.
- 네트워크 코드에서는 타임아웃과 연결 실패를 정상 시나리오처럼 다뤄야 합니다.
- JDBC에서는 커넥션과 statement, result set 해제를 실수 없이 구조화해야 합니다.
- 예외 설계는 사용자 메시지와 개발자용 원인 추적을 분리하는 방향으로 가야 합니다.
#### 공식 문서 기준으로 더 보면 좋은 자료

- [Exceptions Trail](https://docs.oracle.com/javase/tutorial/essential/exceptions/)
- [Basic I/O](https://docs.oracle.com/javase/tutorial/essential/io/)
- [Files API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/nio/file/Files.html)
- [Socket API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/net/Socket.html)
- [ServerSocket API](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/net/ServerSocket.html)
- [JDBC Basics](https://docs.oracle.com/javase/tutorial/jdbc/basics/index.html)
#### 정리

이 장은 Java가 외부 자원과 만나는 지점을 다룹니다. 그래서 파일, 네트워크, 데이터베이스를 각각 따로 배우는 것이 아니라, **실패 가능한 자원을 어떤 구조로 다룰 것인가**라는 공통 질문으로 묶어 읽는 편이 더 강합니다.

#### 한 줄 정리

`입출력과 네트워크` 장의 핵심은 API 개수가 아니라, **외부 자원을 실패까지 포함해 안전하게 다루는 기본기**를 익히는 것입니다.


---

## 10.1 Java 예외 종류 정리

#### 개요

이 문서는 Java에서 자주 만나는 예외를 범주별로 빠르게 정리한 참조 문서입니다. 핵심은 예외 이름을 외우는 것이 아니라, 어떤 계층에서 왜 발생하는지 연결해서 읽는 것입니다.

#### 왜 중요한가

파일, 네트워크, JDBC처럼 외부 자원과 연결되는 코드는 실패를 정상 흐름 밖으로 밀어내기 위해 예외를 사용합니다. 예외 계층을 이해하면 로그를 읽는 속도와 복구 지점 판단이 빨라집니다.

#### 1. 체크 예외와 언체크 예외

##### 체크 예외

컴파일 시점에 처리 여부를 강제하는 예외입니다.

- `IOException`
- `SQLException`
- `ClassNotFoundException`
주로 파일, 소켓, DB처럼 외부 자원 실패를 표현할 때 등장합니다.

##### 언체크 예외

런타임에 발생하며, 주로 잘못된 입력이나 상태 위반과 연결됩니다.

- `NullPointerException`
- `IllegalArgumentException`
- `NumberFormatException`
- `IndexOutOfBoundsException`
- `IllegalStateException`
주로 프로그래밍 실수, 검증 누락, 객체 상태 위반을 드러낼 때 등장합니다.

#### 2. 외부 자원 코드는 왜 체크 예외가 많은가

Java 21의 `try-with-resources`는 자원 해제를 자동화하고, 닫는 과정에서 추가 예외가 발생하면 이를 `suppressed exception`으로 보존합니다. 그래서 파일, 네트워크, JDBC 예제에서는 `finally`보다 `try-with-resources`가 기본입니다.

```java
try (BufferedReader reader = new BufferedReader(new FileReader("data.txt"))) {
    System.out.println(reader.readLine());
} catch (FileNotFoundException e) {
    System.err.println("파일이 없습니다.");
} catch (IOException e) {
    System.err.println("읽기 중 오류가 발생했습니다.");
}
```

```plain text
예상 결과
파일이 없으면 `FileNotFoundException`이 먼저 분기된다.
파일은 열렸지만 읽는 중 문제가 생기면 `IOException`으로 분기된다.
자원 해제는 자동으로 수행되고, 닫는 중 오류가 나면 원래 예외에 suppressed exception으로 붙는다.
```

#### 3. 자주 만나는 예외를 범주로 읽기

##### 파일과 입출력

- `FileNotFoundException`: 경로가 잘못되었거나 파일이 없음
- `EOFException`: 읽을 데이터가 예상보다 빨리 끝남
- `IOException`: 입출력 작업 전반의 일반 예외
##### 네트워크

- `UnknownHostException`: 호스트 이름 해석 실패
- `ConnectException`: 연결 거부 또는 서버 미기동
- `SocketException`: 소켓 통신 중 일반 오류
##### 데이터 변환과 상태

- `NumberFormatException`: 문자열을 숫자로 바꾸지 못함
- `ClassCastException`: 잘못된 타입 변환
- `IllegalArgumentException`: 잘못된 입력값
- `IllegalStateException`: 현재 상태에서 허용되지 않는 호출
##### 데이터베이스

- `SQLException`: JDBC 작업 전반의 기본 예외
- `SQLTimeoutException`: 쿼리 시간 초과
- `SQLIntegrityConstraintViolationException`: 제약 조건 위반
#### 4. 예외 이름보다 더 중요한 것

로그를 볼 때는 아래 순서로 읽는 편이 좋습니다.

1. 예외 타입
1. 메시지
1. 최초 발생 위치
1. 외부 자원과의 연결 지점
1. 원인 예외와 suppressed exception 존재 여부
#### 5. 현재 저장소에서 어떻게 읽히는가

`day_by_spring`에서는 외부 자원 실패 자체를 세세한 체크 예외로 위로 올리기보다, 서비스 계층에서 도메인 의미가 있는 런타임 예외로 바꾸는 경우가 많습니다. 반면 `day-by-java` 예제는 학습 목적상 `IOException`, `SQLException`, 사용자 정의 체크 예외를 그대로 드러내어 저수준 흐름을 보여줍니다.

즉 이 장에서는 다음처럼 읽으면 됩니다.

- `day-by-java`: 예외가 어디서 직접 발생하는지 보여주는 입문 예제
- `day_by_spring`: 예외 의미를 도메인과 API 응답으로 번역하는 실전 구조
#### 6. 빠른 판단 기준

- 파일, 네트워크, JDBC와 직접 맞닿아 있다: 체크 예외 또는 그 래핑 예외를 먼저 의심한다.
- 입력값이나 상태가 잘못되었다: `IllegalArgumentException`, `IllegalStateException`, 도메인 런타임 예외를 먼저 의심한다.
- 컨트롤러 응답이 실패했다: 예외 자체보다 전역 예외 처리기에서 어떤 HTTP 응답으로 번역했는지 함께 본다.
#### 정리

예외 분류의 목적은 암기가 아니라 진단 속도를 높이는 데 있습니다. 예외를 자원 실패, 입력 실패, 상태 실패, 도메인 실패로 나누어 보면 로그와 코드가 훨씬 빨리 읽힙니다.

#### 한 줄 정리

예외 정리의 핵심은 **예외 이름을 외우는 것이 아니라, 어떤 계층에서 왜 발생하는지 연결해서 이해하는 것**입니다.


---

## 10.3 파일 읽기와 쓰기 기초

#### 개요

이 문서는 Java에서 파일을 읽고 쓰는 가장 기본적인 흐름을 정리한 가이드입니다. 전통적인 IO와 NIO를 함께 보되, 초중급 Java 개발자가 실제로 자주 쓰는 형태에 집중합니다.

#### 왜 중요한가

파일 입출력은 문법보다 실패 가능성이 더 중요합니다. 경로, 권한, 인코딩, 자원 해제 문제가 자주 얽히기 때문에, 단순 예제라도 안전한 패턴으로 익혀두는 편이 좋습니다.

#### 1. 가장 먼저 기억할 것

- 외부 자원은 반드시 닫혀야 합니다.
- 인코딩을 명확히 하는 편이 안전합니다.
- 큰 파일은 한 번에 모두 읽기보다 스트림 방식이 유리합니다.
#### 현재 예제 소스와 먼저 연결하기

`day-by-java` 저장소에는 전통적인 IO와 NIO 예제가 함께 있습니다. 새 코드의 기본값은 `Path` + `Files` + `try-with-resources` 쪽으로 이해하는 편이 좋고, 레거시 코드를 읽을 때는 `BufferedReader`, `FileReader` 흐름을 같이 볼 수 있어야 합니다.

```java
try (BufferedReader br = new BufferedReader(new FileReader("output.txt"))) {
    String line;
    while ((line = br.readLine()) != null) {
        System.out.println(line);
    }
}
```

```java
Path filePath = Paths.get("output.txt");
Files.writeString(filePath, "\n추가 내용: NIO 를 사용한 파일 내용 추가", StandardOpenOption.APPEND);
```

```plain text
예상 결과
전통적인 IO 예제는 한 줄씩 읽는 패턴과 자원 해제를 보여준다.
NIO 예제는 같은 작업을 더 간결하게 표현하지만, `APPEND` 사용 시 파일 존재 여부를 먼저 고려해야 한다.
```

#### 2. 텍스트 파일 쓰기

```java
Path path = Paths.get("output.txt");
Files.writeString(path, "Hello Java\n", StandardCharsets.UTF_8);
```

##### 설명

- `Path`는 경로를 표현합니다.
- `Files.writeString`은 간단한 텍스트 파일 작성에 적합합니다.
- 인코딩은 가능하면 명시합니다.
#### 3. 텍스트 파일 읽기

```java
Path path = Paths.get("output.txt");
String content = Files.readString(path, StandardCharsets.UTF_8);
System.out.println(content);
```

작은 파일은 `readString`으로 충분하지만, 큰 파일은 라인 단위로 읽는 쪽이 낫습니다.

#### 4. 라인 단위 읽기

```java
try (Stream<String> lines = Files.lines(Paths.get("app.log"), StandardCharsets.UTF_8)) {
    lines.filter(line -> line.contains("ERROR"))
         .forEach(System.out::println);
}
```

로그 파일처럼 큰 텍스트 파일은 이 패턴이 더 실용적입니다.

#### 5. 내용 추가하기

```java
Files.writeString(
    Paths.get("output.txt"),
    "추가 내용\n",
    StandardCharsets.UTF_8,
    StandardOpenOption.CREATE,
    StandardOpenOption.APPEND
);
```

`APPEND`만 쓰면 파일이 없을 때 실패할 수 있으므로 `CREATE`를 함께 쓰는 편이 안전합니다.

#### 6. 바이너리 파일 다루기

```java
byte[] data = Files.readAllBytes(Paths.get("image.png"));
Files.write(Paths.get("copy.png"), data);
```

이미지나 압축 파일처럼 텍스트가 아닌 데이터는 바이트 배열 기반으로 다룹니다.

#### 7. 기존 IO와 NIO를 어떻게 고를까

예전 예제에서는 `FileInputStream`, `FileReader`, `BufferedReader` 같은 전통적인 IO 클래스가 많이 등장합니다. 이 흐름을 이해하는 것은 중요하지만, 새 코드의 기본값은 보통 `Path`, `Files`, `try-with-resources`를 중심으로 잡는 편이 더 낫습니다.

- 간단한 텍스트 파일 읽기/쓰기: `Files.readString`, `Files.writeString`
- 큰 파일 라인 처리: `Files.lines`
- 바이너리 파일 복사: `Files.readAllBytes`, `Files.copy`
- 레거시 API를 읽어야 할 때: `FileInputStream`, `FileReader`, `BufferedReader`
즉, IO를 버리는 것이 아니라 **레거시 코드를 읽을 줄 알되, 새 코드는 NIO 중심으로 작성하는 것**이 실무적인 기준입니다.

##### 보강: NIO의 Buffer와 Channel은 언제 떠올릴까

`Files` API만으로도 대부분의 파일 처리는 충분하지만, NIO를 더 깊게 이해하려면 `Buffer`와 `Channel`의 역할도 같이 알아두는 편이 좋습니다.

- `Buffer`는 읽고 쓸 데이터를 잠시 담아 두는 메모리 공간입니다.
- `Channel`은 파일이나 소켓 같은 외부 자원과 데이터를 주고받는 통로입니다.
- 작은 학습 예제에서는 `Files.readString`이 더 단순하지만, 큰 파일 복사나 네트워크 처리, Direct Buffer 같은 주제로 넘어가면 `ByteBuffer`, `FileChannel` 개념이 다시 등장합니다.
```java
try (FileChannel channel = FileChannel.open(Paths.get("data.bin"), StandardOpenOption.READ)) {
    ByteBuffer buffer = ByteBuffer.allocate(1024);

    while (channel.read(buffer) > 0) {
        buffer.flip();
        while (buffer.hasRemaining()) {
            System.out.print((char) buffer.get());
        }
        buffer.clear();
    }
}
```

핵심은 API를 많이 외우는 것이 아니라, **스트림 기반 IO보다 더 낮은 수준에서 버퍼를 직접 다루는 모델이 NIO**라는 점을 이해하는 데 있습니다.

#### 8. 파일 검색과 경로 작업

파일 처리는 읽기와 쓰기에서 끝나지 않습니다. 실제로는 파일을 찾고, 디렉토리를 만들고, 안전하게 삭제하는 작업도 자주 섞입니다.

```java
try (Stream<Path> paths = Files.walk(Paths.get("logs"))) {
    paths.filter(path -> path.getFileName().toString().endsWith(".log"))
         .forEach(System.out::println);
}
```

디렉토리 생성은 `Files.createDirectories`, 삭제는 `Files.deleteIfExists`처럼 NIO API를 쓰는 편이 예외 처리와 의도가 더 분명합니다.

#### 9. 대용량 파일은 어떻게 다를까

작은 파일 예제는 이해하기 쉽지만, 실무에서는 파일 전체를 메모리에 올리지 않고 **한 줄씩 읽으면서 통계를 누적하는 방식**이 더 중요합니다.

```java
record CsvStats(long count, int ageSum, double scoreSum, long highScoreCount) {}

Path path = Paths.get("sample_data.csv");
long count = 0;
int ageSum = 0;
double scoreSum = 0;
long highScoreCount = 0;

try (Stream<String> lines = Files.lines(path, StandardCharsets.UTF_8)) {
    for (String line : (Iterable<String>) lines.skip(1)::iterator) {
        String[] tokens = line.split(",");
        int age = Integer.parseInt(tokens[2]);
        double score = Double.parseDouble(tokens[3]);

        count++;
        ageSum += age;
        scoreSum += score;
        if (score >= 90.0) {
            highScoreCount++;
        }
    }
}
```

이 패턴의 핵심은 `readAllLines`로 전부 읽는 것이 아니라, **스트리밍 처리로 필요한 집계만 즉시 계산**하는 데 있습니다.

#### 10. 자주 반복되는 작업 패턴

파일 처리 예제를 많이 풀다 보면 결국 반복되는 작업은 몇 가지로 압축됩니다.

- 복사: `Files.copy`
- 병합: 여러 입력 파일을 순서대로 읽어 하나의 출력 파일에 쓰기
- 필터링: CSV나 로그에서 조건에 맞는 줄만 통과시키기
- 검색: 특정 디렉토리에서 파일명이나 확장자 기준으로 찾기
- 정리: 오래된 파일 삭제, 이름 변경, 다른 폴더로 이동
즉, API를 많이 외우는 것보다 `읽기 → 변환/필터링 → 쓰기` 흐름을 익히는 것이 더 중요합니다.

#### 11. 자주 하는 실수

- 상대 경로 기준이 어디인지 확인하지 않는 것
- 파일이 크다고 생각하지 않고 `readAllBytes`를 남용하는 것
- 인코딩을 생략해서 운영 환경에서 깨지는 것
- 스트림을 열고 닫지 않는 것
- `File` 기반 예제를 그대로 새 코드 기본값처럼 사용하는 것
- 대용량 파일 문제를 작은 파일 예제처럼 한 번에 읽는 방식으로 푸는 것
#### 실무 연결 포인트

- 로그 분석
- 설정 파일 로드
- CSV 내보내기
- 업로드 파일 저장
- 디렉토리 스캔과 파일 검색
- 임시 파일 생성과 정리
- 대용량 CSV/로그 통계 계산
- 여러 파일 병합과 이동 자동화
이 모두가 결국 파일 입출력 패턴을 안전하게 다루는 문제로 이어집니다.

#### 정리

파일 입출력의 핵심은 API를 많이 아는 것이 아니라, 어떤 상황에서 어떤 방식이 안전한지 구분하는 것입니다. 작은 파일, 큰 파일, 텍스트, 바이너리 파일을 나눠서 생각하면 구조가 훨씬 단순해집니다.

#### 한 줄 정리

파일 처리의 핵심은 **읽고 쓰는 코드보다, 자원 해제와 인코딩과 크기 조건을 먼저 생각하는 것**입니다.


---

## 10.4 여러 형식의 파일 처리

#### 개요

이 문서는 CSV, JSON, 엑셀, 로그 파일처럼 실제 업무에서 자주 마주치는 여러 형식의 파일을 어떻게 바라봐야 하는지 정리한 문서입니다. 각 형식의 기술적 차이보다, 어떤 상황에서 어떤 선택을 해야 하는지에 초점을 둡니다.

#### 왜 중요한가

실무에서는 파일을 단순히 읽고 쓰는 것보다, 형식에 맞는 처리 전략을 고르는 일이 더 자주 발생합니다. 같은 파일 처리라도 CSV와 JSON, 엑셀은 목적과 도구가 모두 다릅니다.

#### 1. CSV 파일

##### 언제 자주 쓰는가

- 대량 데이터 업로드와 다운로드
- 간단한 표 형식 교환
- 분석용 데이터 내보내기
##### 장점

- 구조가 단순합니다.
- 사람이 열어보기 쉽습니다.
- 엑셀과도 호환이 좋습니다.
##### 주의할 점

- 쉼표와 줄바꿈이 값 안에 들어갈 수 있습니다.
- 헤더 유무를 팀 안에서 합의해야 합니다.
#### 2. JSON 파일

##### 언제 자주 쓰는가

- 설정 파일
- API 응답 저장
- 구조화된 데이터 교환
##### 장점

- 계층 구조 표현이 쉽습니다.
- 객체 모델과 연결하기 좋습니다.
##### 주의할 점

- 필드 이름이 바뀌면 파싱 코드가 쉽게 깨집니다.
- 유연해 보이지만 스키마 관리는 여전히 중요합니다.
#### 3. 엑셀 파일

##### 언제 자주 쓰는가

- 보고서
- 운영 데이터 정리
- 다중 시트 기반 자료 공유
##### 장점

- 현업 사용자에게 익숙합니다.
- 셀 단위 편집과 서식이 가능합니다.
##### 주의할 점

- 자바 표준 라이브러리만으로는 충분하지 않고 보통 Apache POI 같은 라이브러리가 필요합니다.
- `Workbook`, `Sheet`, `Row`, `Cell` 같은 공통 인터페이스를 먼저 이해하고, `.xlsx`는 `XSSFWorkbook`, 대용량 쓰기는 `SXSSF`를 고려하는 편이 좋습니다.
- 실무에서는 경로 조회, 헤더 작성, 셀 타입 변환 같은 반복 코드를 `ExcelUtils` 같은 유틸로 묶어 두면 예제와 운영 코드를 분리하기 쉬워집니다.
- 셀 타입, 날짜 형식, 공백 처리에서 자주 실수합니다.
#### 4. 로그 파일

##### 언제 자주 쓰는가

- 장애 분석
- 사용자 행동 추적
- 배치 작업 기록
##### 핵심 포인트

로그 파일은 저장 그 자체보다 검색과 필터링이 중요합니다. 따라서 형식이 일정해야 하고, 시간 정보와 레벨이 함께 남아야 합니다.

#### 5. 객체 데이터를 여러 포맷으로 저장할 때

같은 `Person` 목록 같은 데이터를 저장하더라도 포맷에 따라 목적이 다릅니다.

- CSV: 단순 표 데이터 교환, 엑셀 호환이 중요할 때
- JSON: 시스템 간 교환, API 응답 저장, 계층 구조 표현이 필요할 때
- Properties: 소수의 설정 값 저장처럼 키-값 구조가 단순할 때
- ZIP: 데이터 자체보다 묶음과 전달이 중요할 때
- Java 직렬화(`ObjectOutputStream`): 학습용으로는 볼 수 있지만, 장기 저장 포맷의 기본값으로 삼기에는 주의가 필요할 때
핵심은 “무슨 데이터를 저장하느냐”보다 **누가 읽고, 얼마나 오래 유지하며, 어떤 도구로 다시 처리할지**를 먼저 보는 것입니다.

#### 6. Java 직렬화와 구조화 포맷을 어떻게 구분할까

초반 예제에서는 `Serializable`과 `ObjectOutputStream`으로 객체를 그대로 저장하는 실습을 자주 합니다. 이 방식은 Java 내부 구조를 빠르게 체험하는 데는 좋지만, 실무 기본값으로 두기에는 제약이 많습니다.

- 클래스 구조가 바뀌면 호환성이 깨지기 쉽습니다.
- 다른 언어나 도구에서 읽기 어렵습니다.
- 데이터가 사람이 읽기 좋은 형태가 아닙니다.
반대로 JSON, CSV, Properties는 사람이 읽거나 다른 시스템과 교환하기가 더 쉽습니다. 그래서 실무에서는 **직렬화 자체를 이해하되, 교환 포맷은 JSON/CSV 같은 구조화 포맷을 우선 검토**하는 편이 자연스럽습니다.

##### 보강: `serialVersionUID`와 `transient`는 왜 같이 보나

직렬화 예제를 볼 때는 `Serializable`만 외우기보다, 클래스 변경과 민감 정보 제외라는 두 문제를 같이 봐야 합니다.

```java
class Person implements Serializable {
    private static final long serialVersionUID = 1L;

    private String name;
    private transient String password;
}
```

- `serialVersionUID`는 클래스 구조가 바뀌었을 때 역직렬화 호환성을 통제하는 데 도움을 줍니다.
- `transient`는 비밀번호처럼 저장하면 안 되는 필드를 직렬화 대상에서 제외할 때 씁니다.
- 즉, Java 직렬화는 객체 저장 원리를 배우기에는 좋지만, **장기 보관 포맷의 기본값**으로 쓰기보다는 학습용 또는 제한된 내부 용도로 보는 편이 안전합니다.
#### 7. XML, YAML, HTML, Markdown은 어떻게 볼까

이 형식들도 파일 처리 예제에는 자주 나오지만, 핵심은 문자열을 손으로 파싱하는 데 있지 않습니다.

- XML: DOM, SAX, JAXB, Jackson XML 같은 도구를 통해 구조적으로 다뤄야 합니다.
- YAML: 설정 파일로는 유용하지만, 임의 문자열 파싱보다 전용 라이브러리 사용이 안전합니다.
- HTML: 파일 포맷이라기보다 문서 포맷에 가깝고, 읽을 때는 보통 Jsoup 같은 파서를 씁니다.
- Markdown: 사람이 읽는 문서를 만들 때는 좋지만 데이터 저장 포맷 기본값은 아닙니다.
즉, 이런 형식의 실습은 “문자열 다루기 연습”보다 **포맷마다 적합한 도구와 목적이 다르다**는 감각을 익히는 쪽으로 읽어야 합니다.

#### 8. 이미지와 압축 파일

이미지, ZIP, PDF는 텍스트 파일처럼 다룰 수 없습니다. 보통은 바이트 단위 처리, 메타데이터 관리, 변환 라이브러리 사용이 핵심입니다.

#### 예시 선택 기준

- 사람이 표로 수정해야 한다면 엑셀
- 시스템 간 구조화된 교환이라면 JSON
- 대량 행 데이터 교환이라면 CSV
- 소수의 설정 키-값이라면 Properties
- 묶어서 전달해야 한다면 ZIP
- 장애 추적이라면 로그 파일
#### 실무 연결 포인트

파일 형식을 고르는 일은 구현 세부사항이 아니라 인터페이스 설계에 가깝습니다. 어떤 사용자가 읽는지, 사람이 열어볼지, 시스템이 파싱할지 먼저 정하면 구현 선택이 훨씬 쉬워집니다.

#### 정리

여러 형식의 파일 처리는 API를 많이 아는 것보다 목적에 맞는 형식을 고르는 감각이 더 중요합니다. 파일 포맷은 곧 데이터 전달 방식이기 때문에, 읽는 사람과 사용하는 시스템을 함께 고려해야 합니다.

#### 한 줄 정리

여러 형식의 파일 처리의 핵심은 **파일을 어떻게 읽을지가 아니라, 왜 그 형식을 선택하는지 먼저 판단하는 것**입니다.


---

## 10.5 네트워크 프로그래밍 기초

#### 개요

이 문서는 Java에서 네트워크 통신 프로그램을 처음 구조적으로 이해하기 위한 가이드입니다. 네트워크 코드는 문법보다도 **연결이 언제 열리고 닫히는지, 읽기와 쓰기가 언제 멈출 수 있는지, 어떤 단위로 메시지를 구분할 것인지**가 더 중요합니다.

입문 단계에서는 TCP와 UDP 예제를 각각 한 번씩 따라 하는 것보다, `소켓 = 네트워크 통신의 끝점`, `스트림 = 데이터를 주고받는 방식`, `프로토콜 = 메시지를 해석하는 규칙`이라는 큰 구조를 먼저 잡는 편이 훨씬 도움이 됩니다.

#### 왜 네트워크 코드는 따로 공부해야 하는가

파일 처리도 외부 자원을 다루지만, 네트워크는 더 불안정합니다.

- 상대 서버가 꺼져 있을 수 있습니다.
- 연결이 거부될 수 있습니다.
- 응답이 늦어질 수 있습니다.
- 메시지가 한 번에 도착하지 않을 수 있습니다.
- 읽기 작업이 생각보다 오래 블로킹될 수 있습니다.
그래서 네트워크 코드는 정상 동작 예제보다, **실패와 지연이 기본이라는 전제**로 읽어야 합니다.

#### 1. 네트워크 통신의 최소 단위

입문 단계에서 꼭 구분해야 할 것은 세 가지입니다.

##### 1.1 IP 주소

통신 상대가 누구인지 식별하는 주소입니다.

##### 1.2 포트 번호

한 컴퓨터 안에서 어떤 서비스가 통신을 받는지 구분하는 번호입니다.

##### 1.3 소켓

프로그램이 실제로 네트워크 통신을 하기 위해 여는 끝점입니다. Java에서는 `Socket`, `ServerSocket`, `DatagramSocket` 같은 타입으로 표현됩니다.

즉, 네트워크 통신은 "어느 주소의 어느 포트에, 어떤 방식의 소켓으로 연결할 것인가"를 정하는 일에서 시작합니다.

#### 2. TCP와 UDP는 무엇이 다른가

##### 2.1 TCP

TCP는 연결 기반 통신입니다.

- 연결을 맺고 통신합니다.
- 데이터 순서를 보장합니다.
- 손실된 데이터를 재전송할 수 있습니다.
- 대신 연결과 상태를 관리해야 합니다.
Java 애플리케이션에서 요청-응답 구조를 이해하는 입문용 예제로는 TCP가 더 적합한 경우가 많습니다.

##### 2.2 UDP

UDP는 비연결 기반 통신입니다.

- 별도 연결 과정 없이 데이터그램을 보냅니다.
- 빠르지만 순서와 도착을 보장하지 않습니다.
- 메시지 단위가 더 분명합니다.
- 대신 손실과 순서 문제를 애플리케이션이 감당해야 할 수 있습니다.
입문 단계에서는 TCP로 흐름을 먼저 이해하고, UDP는 "왜 메시지 단위와 손실 가능성을 더 의식해야 하는가"를 비교하는 정도로 보는 편이 자연스럽습니다.

#### 3. 서버와 클라이언트는 역할이 다르다

TCP 기준으로 보면 서버와 클라이언트의 차이는 분명합니다.

- 서버: 포트를 열고 연결을 기다립니다.
- 클라이언트: 서버 주소와 포트로 접속을 시도합니다.
흐름은 아래처럼 이해하면 됩니다.

```plain text
ServerSocket 생성
    ↓
accept()로 연결 대기
    ↓
클라이언트가 Socket 연결 시도
    ↓
연결 성립
    ↓
입출력 스트림으로 데이터 송수신
```

여기서 중요한 점은 `accept()`도, `read()`도 **블로킹 호출**일 수 있다는 것입니다. 즉, 상대가 오지 않거나 데이터를 보내지 않으면 해당 지점에서 대기할 수 있습니다.

#### 4. 네트워크 통신은 결국 스트림을 다루는 일이다

TCP 소켓을 열고 나면 결국 입력 스트림과 출력 스트림을 다루게 됩니다.

```java
try (Socket socket = new Socket("127.0.0.1", 12345);
     BufferedReader reader = new BufferedReader(
         new InputStreamReader(socket.getInputStream()));
     PrintWriter writer = new PrintWriter(socket.getOutputStream(), true)) {

    writer.println("ping");
    String response = reader.readLine();
    System.out.println(response);
}
```

이 코드에서 핵심은 아래입니다.

- 연결은 `Socket`이 담당합니다.
- 읽기는 입력 스트림이 담당합니다.
- 쓰기는 출력 스트림이 담당합니다.
- `println`과 `readLine`을 같이 쓰려면 줄바꿈 규칙이 프로토콜 일부가 됩니다.
즉, 네트워크 코드는 단순히 소켓 API를 쓰는 것이 아니라, **메시지를 어떤 형식으로 경계 지을지**까지 함께 설계해야 합니다.

#### 5. 아주 작은 TCP 에코 서버 예제로 흐름 보기

`day-by-java` 저장소의 `SimpleTCPServer`, `SimpleTCPClient`는 입문용 네트워크 예제로 바로 연결하기 좋습니다.

##### 서버

```java
ServerSocket serverSocket = new ServerSocket(8888);
System.out.println("서버 시작. 클라이언트 대기 중...");

Socket clientSocket = serverSocket.accept();
System.out.println("클라이언트 연결됨: " + clientSocket.getInetAddress());

BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
```

##### 클라이언트

```java
Socket socket = new Socket("127.0.0.1", 8888);
System.out.println("서버에 연결됨");

BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

out.println("hello");
System.out.println("서버 응답: " + in.readLine());
```

```plain text
예상 결과
서버를 먼저 띄우면 "서버 시작. 클라이언트 대기 중..."가 출력된다.
클라이언트 연결 후 서버는 연결 IP와 메시지를 출력하고, 클라이언트는 "서버 응답: ..." 형태의 응답을 받는다.
이 예제는 `accept()`와 `readLine()`이 블로킹될 수 있다는 점까지 함께 보여준다.
```

이 예제는 단순하지만 네트워크 통신의 핵심이 다 들어 있습니다.

- 서버는 포트를 열고 대기한다.
- 클라이언트는 접속한다.
- 양쪽은 스트림으로 데이터를 주고받는다.
- 읽기와 쓰기 규칙이 맞아야 한다.
- 자원은 반드시 닫혀야 한다.
#### 6. 블로킹을 이해하지 못하면 통신 코드가 자주 멈춘다

네트워크 코드 초보 단계에서 가장 흔한 혼란은 "왜 프로그램이 멈춘 것처럼 보이는가"입니다. 실제로는 멈춘 것이 아니라 읽기나 연결 대기에서 블로킹 중인 경우가 많습니다.

대표적인 블로킹 지점:

- `serverSocket.accept()`
- `reader.readLine()`
- `socket.connect()`
그래서 네트워크 코드에서는 아래 질문을 항상 붙여야 합니다.

- 지금 이 호출은 상대가 없으면 얼마나 기다리는가
- 타임아웃을 둘 것인가
- 한 줄이 오기를 기다리는가, 바이트 단위로 읽는가
#### 7. 예외는 정상 흐름처럼 다뤄야 한다

네트워크 코드에서는 예외가 드문 일이 아닙니다. 오히려 설계의 일부입니다.

자주 보게 되는 예외는 아래와 같습니다.

- `UnknownHostException`: 호스트 이름을 찾지 못함
- `ConnectException`: 연결 거부
- `SocketTimeoutException`: 제한 시간 초과
- `SocketException`: 소켓 종료나 연결 문제
- `IOException`: 입출력 전반 문제
중요한 점은 네트워크 예외를 `e.printStackTrace()`로 끝내지 말고, **연결 실패인지, 읽기 실패인지, 상대 종료인지** 문맥을 나눠 해석하는 습관입니다.

#### 8. UDP는 "메시지 단위"를 더 분명히 본다

UDP에서는 `DatagramPacket` 단위로 송수신하기 때문에, TCP보다 메시지 경계가 더 분명합니다.

```java
byte[] buffer = new byte[1024];
DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
socket.receive(packet);
```

입문 단계에서 기억할 기준은 아래입니다.

- TCP는 스트림 기반이라 메시지 경계를 직접 정해야 한다.
- UDP는 데이터그램 단위라 한 번의 송신이 한 메시지처럼 보이기 쉽다.
- 대신 UDP는 도착과 순서를 보장하지 않는다.
즉, UDP는 빠르지만 애플리케이션이 더 많은 가정을 직접 다뤄야 합니다.

#### 9. 프로토콜이 없으면 통신은 금방 꼬인다

서버와 클라이언트가 연결되었다고 해서 통신이 완성된 것은 아닙니다. 서로 **어떤 형식으로 말할지** 정해야 합니다.

예를 들어 아래 항목이 모두 프로토콜 일부가 됩니다.

- 메시지를 줄바꿈으로 끝낼지
- JSON 한 덩어리를 보낼지
- 길이 정보를 먼저 보낼지
- 요청 하나에 응답 하나인지
- 종료 신호를 어떻게 표현할지
초보 단계에서는 `println`과 `readLine` 기반의 간단한 텍스트 프로토콜로 시작하는 편이 좋습니다. 핵심은 복잡한 포맷보다, **양쪽이 같은 규칙을 공유하는 것**입니다.


---

## 10.6 JDBC 기초

#### 개요

이 문서는 Java 코드가 관계형 데이터베이스와 직접 연결되는 가장 기본적인 구조인 JDBC를 이해하기 위한 입문 가이드입니다. 실무에서 JPA나 MyBatis를 쓰더라도, 결국 내부에서는 커넥션을 열고 SQL을 실행하고 결과를 읽고 자원을 닫는 흐름이 반복됩니다. JDBC는 그 가장 밑바닥 구조를 보여줍니다.

입문 단계에서 JDBC를 배우는 목적은 모든 SQL을 순수 JDBC로 작성하기 위함이 아닙니다. **DB 접근 코드가 어떤 생명주기를 가지는지**, 그리고 자원 해제와 예외 처리가 왜 중요한지 이해하는 데 있습니다.

#### 현재 저장소와 예제 저장소를 구분해서 읽기

현재 `day_by_spring` 저장소는 JDBC를 직접 노출하지 않고 Spring Data JPA와 트랜잭션 추상화 위에서 데이터 접근을 수행합니다. 반면 `day-by-java` 저장소에는 순수 JDBC 예제(`JDBCBasicExample`)가 있어서, 커넥션 획득부터 `PreparedStatement`, `ResultSet`, `finally` 정리까지 바닥 구조를 직접 볼 수 있습니다.

```java
Connection conn = DriverManager.getConnection(url, user, password);
PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM user");
ResultSet rs = pstmt.executeQuery();

while (rs.next()) {
    int id = rs.getInt("id");
    String name = rs.getString("name");
    String email = rs.getString("email");
    System.out.println(id + " : " + name + " : " + email);
}
```

```plain text
예상 결과
순수 JDBC 예제에서는 연결 성공, INSERT 완료, SELECT 결과 출력, 종료 순서가 코드에 그대로 드러난다.
현재 Spring 프로젝트는 이런 저수준 흐름을 직접 쓰지 않지만, 내부적으로는 같은 JDBC 생명주기 위에서 동작한다.
```

주의할 점도 있습니다. 예제 저장소의 JDBC 샘플은 학습용이라 자격 증명이 코드에 직접 들어 있고 `finally`로 자원을 닫습니다. 출판 기준에서는 실제 프로젝트 코드로 권장하기보다, **왜 ****`try-with-resources`****와 외부 설정 분리가 필요한지 보여주는 예제**로 읽는 편이 정확합니다.

#### 왜 JDBC를 먼저 알아야 하는가

ORM을 먼저 배우면 DB 접근이 너무 자동처럼 느껴질 수 있습니다. 하지만 실제로는 아래 질문을 이해해야 문제가 생겼을 때 원인을 잡을 수 있습니다.

- 커넥션은 언제 열리고 닫히는가
- SQL은 어떤 객체를 통해 실행되는가
- 조회 결과는 어떻게 읽히는가
- 실패하면 어떤 예외가 올라오는가
- 자원을 닫지 않으면 어떤 문제가 생기는가
즉, JDBC는 기술 자체보다 **DB 접근의 기본 생애주기**를 이해하게 해주는 문서입니다.

#### 1. JDBC가 하는 일

JDBC는 Java 애플리케이션이 데이터베이스와 통신할 수 있게 해 주는 표준 API입니다. 핵심은 특정 DB 제품에 상관없이 비슷한 방식으로 연결과 SQL 실행을 다룰 수 있게 해준다는 점입니다.

입문 단계에서는 아래 네 객체를 먼저 기억하면 충분합니다.

- `Connection`: DB 연결
- `PreparedStatement`: SQL 실행 준비와 파라미터 바인딩
- `ResultSet`: 조회 결과 읽기
- `SQLException`: DB 작업 실패 표현
#### 2. 가장 기본적인 흐름

JDBC의 기본 흐름은 아래처럼 이해하면 됩니다.

```plain text
드라이버 준비
    ↓
Connection 획득
    ↓
PreparedStatement 생성
    ↓
파라미터 바인딩
    ↓
SQL 실행
    ↓
ResultSet 읽기 또는 영향 row 수 확인
    ↓
자원 해제
```

여기서 핵심은 조회와 수정이 같은 것처럼 보여도, 결과를 다루는 방식이 다르다는 점입니다.

- `SELECT`는 `ResultSet`을 읽습니다.
- `INSERT`, `UPDATE`, `DELETE`는 변경된 행 수를 확인합니다.
#### 3. `Connection`은 네트워크 자원이다

`Connection`은 단순한 객체 생성이 아니라, 실제로 데이터베이스와 연결된 외부 자원입니다. 따라서 파일이나 소켓처럼 반드시 수명 관리를 해야 합니다.

```java
Connection connection = DriverManager.getConnection(url, username, password);
```

이 한 줄은 단순해 보이지만 실제로는 아래를 포함합니다.

- DB 서버 주소 확인
- 인증
- 세션 생성
- 네트워크 자원 점유
그래서 커넥션을 오래 붙잡거나 닫지 않으면 애플리케이션 전체가 느려지거나 고갈 문제를 일으킬 수 있습니다.

#### 4. `PreparedStatement`를 먼저 습관으로 잡아야 한다

초보 단계에서는 `Statement`로 바로 SQL 문자열을 붙여 쓰기 쉽습니다. 하지만 실무 감각으로는 `PreparedStatement`를 먼저 쓰는 습관이 더 중요합니다.

이유는 명확합니다.

- 파라미터 바인딩이 분명합니다.
- SQL 인젝션 위험을 줄일 수 있습니다.
- 같은 형태의 쿼리를 다루기 쉽습니다.
```java
String sql = "SELECT id, name, email FROM users WHERE email = ?";

try (Connection connection = DriverManager.getConnection(url, username, password);
     PreparedStatement statement = connection.prepareStatement(sql)) {

    statement.setString(1, "alice@example.com");

    try (ResultSet resultSet = statement.executeQuery()) {
        while (resultSet.next()) {
            System.out.println(resultSet.getLong("id"));
        }
    }
}
```

이 예제에서 중요한 것은 문법보다도 **SQL 구조와 파라미터를 분리해서 다룬다**는 점입니다.

#### 5. `ResultSet`은 한 줄씩 읽는 구조다

조회 결과는 보통 메모리에 완성된 리스트로 바로 오는 것이 아니라, `ResultSet`을 통해 한 행씩 읽는 구조입니다.

```java
while (resultSet.next()) {
    long id = resultSet.getLong("id");
    String name = resultSet.getString("name");
    String email = resultSet.getString("email");
}
```

입문 단계에서 기억해야 할 기준은 아래와 같습니다.

- `next()`가 다음 행으로 이동합니다.
- 컬럼은 이름이나 인덱스로 읽을 수 있습니다.
- 읽기 순서와 타입을 맞춰야 합니다.
- `ResultSet`도 닫아야 하는 자원입니다.
즉, JDBC 조회 코드는 단순히 "데이터를 가져온다"가 아니라, **결과 커서를 순회한다**고 이해하는 편이 더 정확합니다.

#### 6. 수정 쿼리는 결과셋이 아니라 영향 행 수를 본다

`INSERT`, `UPDATE`, `DELETE`는 보통 `executeUpdate()`를 사용합니다.

```java
String sql = "UPDATE users SET name = ? WHERE id = ?";

try (Connection connection = DriverManager.getConnection(url, username, password);
     PreparedStatement statement = connection.prepareStatement(sql)) {

    statement.setString(1, "Alice Kim");
    statement.setLong(2, 1L);

    int affectedRows = statement.executeUpdate();
    System.out.println("updated rows = " + affectedRows);
}
```

여기서 중요한 점은 SQL이 성공했는지 여부만 보지 말고, **실제로 몇 행이 바뀌었는지**도 확인해야 한다는 것입니다. 이 기준이 있어야 "실패는 아니지만 아무 것도 변경되지 않은 경우"를 구분할 수 있습니다.

#### 7. JDBC에서 가장 자주 하는 실수는 자원 해제다

JDBC 코드는 구조상 자주 길어지는데, 그 이유 중 하나가 자원 해제입니다.

닫아야 하는 대표 자원:

- `Connection`
- `PreparedStatement`
- `ResultSet`
그래서 modern Java에서는 `try-with-resources`가 사실상 기본입니다.

```java
try (Connection connection = DriverManager.getConnection(url, username, password);
     PreparedStatement statement = connection.prepareStatement(sql);
     ResultSet resultSet = statement.executeQuery()) {

    while (resultSet.next()) {
        System.out.println(resultSet.getString("name"));
    }
}
```

이 구조를 습관으로 잡아야 커넥션 누수, statement 누수 같은 문제를 줄일 수 있습니다.

#### 8. 예외는 DB 오류의 종류를 구분하는 단서다

JDBC에서는 기본적으로 `SQLException`을 많이 마주칩니다. 하지만 중요한 것은 예외 이름 자체보다, **무슨 단계에서 실패했는지**를 읽는 것입니다.

대표적인 실패 구간:

- 연결 실패
- 인증 실패
- SQL 문법 오류
- 제약조건 위반
- 타임아웃
예를 들어 아래 상황은 서로 대응이 달라집니다.

- DB 서버에 연결할 수 없음
- 테이블이 없음
- UNIQUE 제약조건 위반
- 커넥션은 열렸지만 쿼리 실행이 느림
즉, `SQLException` 하나로 뭉개지 말고 문맥을 같이 봐야 합니다.

#### 9. 트랜잭션을 모르면 JDBC 흐름이 반쪽짜리가 된다

입문 단계에서는 자동 커밋이 기본이라서 모든 쿼리가 즉시 반영되는 것처럼 보일 수 있습니다. 하지만 실제로는 여러 SQL이 하나의 작업 단위로 묶여야 할 때가 많습니다.

예를 들어 주문 생성과 재고 차감은 함께 성공하거나 함께 실패해야 합니다. 이때 트랜잭션이 필요합니다.

```java
connection.setAutoCommit(false);

try {
    // 주문 저장
    // 재고 차감
    connection.commit();
} catch (SQLException e) {
    connection.rollback();
    throw e;
}
```

이 예제를 지금 당장 깊게 파고들 필요는 없지만, JDBC가 단순 SQL 실행기를 넘어서 **트랜잭션 경계까지 다루는 구조**라는 점은 꼭 알아둘 필요가 있습니다.

#### 10. JPA와 MyBatis를 이해할 때도 JDBC가 바닥에 있다

JPA는 엔티티 중심으로 더 높은 추상화를 제공하고, MyBatis는 SQL 매핑을 더 편하게 해줍니다. 하지만 두 방식 모두 결국은 커넥션과 SQL 실행, 결과 매핑이라는 JDBC 구조 위에 서 있습니다.

그래서 JDBC를 알고 있으면 아래 상황에서 훨씬 강합니다.

- 커넥션 풀이 왜 필요한지 이해하기 쉽습니다.
- SQL 로그를 읽을 때 구조가 더 잘 보입니다.
- ORM이 생성한 쿼리의 비용을 더 현실적으로 볼 수 있습니다.
- 자원 누수와 트랜잭션 문제를 더 정확히 해석할 수 있습니다.
#### 자주 헷갈리는 지점

- `Connection`은 단순 객체가 아니라 외부 연결 자원입니다.
- 조회와 수정은 같은 실행처럼 보여도 결과를 읽는 방식이 다릅니다.
- `Statement`보다 `PreparedStatement`를 먼저 습관으로 잡는 편이 안전합니다.
- `ResultSet`도 닫아야 하는 자원입니다.
- ORM을 쓴다고 해서 JDBC 구조를 몰라도 되는 것은 아닙니다.

---

## 10.7 파일 처리 설계 실습

#### 개요

이 문서는 [여러 형식의 파일 처리](https://www.notion.so/1781e21f383680a49c7ddae902d280c8)를 읽은 뒤, 같은 데이터를 여러 포맷으로 저장하고 다시 읽어 오는 감각을 익히기 위한 워크북입니다.

텍스트, CSV, JSON처럼 자주 쓰는 형식부터 먼저 따라 하고, XML·YAML·ZIP은 비교 실습으로 보는 편이 좋습니다.

#### **Person 객체에 대한 파일 정보 처리하기 예제**

> 아래 파일은 유틸리티 클래스를 만들어 여러 형태로 처리 하는 연습을 해 봅니다. 한번에 다하지 말고 메소드 하나 하고 결과 보고 하는 식으로 진행 바랍니다.

---

**파일명 1: Person.java**

```java
import java.io.Serializable;

public class Person implements Serializable {
    private String name;
    private int age;

    // 직렬화를 위한 고정 버전 UID (선택사항)
    private static final long serialVersionUID = 1L;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    // 기본 생성자 (역직렬화 시 필요할 수 있음)
    public Person() {
    }

    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }

    // CSV 등에서 사용할 간단한 문자열 변환
    public String toDataString() {
        return name + "," + age;
    }

    // CSV에서 문자열 읽어와 Person 생성
    public static Person fromDataString(String data) {
        String[] tokens = data.split(",");
        String name = tokens[0];
        int age = Integer.parseInt(tokens[1]);
        return new Person(name, age);
    }
}

```

---

**파일명 2: FileIOHandler.java**

실제로는 필요한 라이브러리 추가 후 예외처리 등을 상세히 구현해야 함

```java

package com.example.ch4.files;

import java.io.*;
import java.util.*;
import java.util.zip.*;
import java.util.Properties;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
// XML 예시: Jackson, JAXB
// YAML 예시: SnakeYAML
// Excel 예시: Apache POI

public class FileIOHandler {

    // 1) 일반 텍스트 파일 쓰기
    public static void writeTextFile(String filename, List<Person> people) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            for (Person p : people) {
                bw.write(p.toDataString());
                bw.newLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 2) 일반 텍스트 파일 읽기
    public static List<Person> readTextFile(String filename) {
        List<Person> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                Person p = Person.fromDataString(line);
                list.add(p);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3) CSV 파일 쓰기 (텍스트와 유사하지만 확장자로 csv로 가정)
    public static void writeCSV(String filename, List<Person> people) {
        // 실제 CSV 처리 라이브러리 사용 가능 (opencsv 등)
        // 여기서는 단순히 ','로 구분해 쓰는 예시
        writeTextFile(filename, people);
    }

    // 4) CSV 파일 읽기
    public static List<Person> readCSV(String filename) {
        // 내용은 readTextFile과 동일, CSV 처리를 위해 별도 라이브러리 사용 가능
        return readTextFile(filename);
    }

    // 5) 이진 파일(직렬화) 쓰기
    public static void writeBinary(String filename, List<Person> people) {
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(filename))) {
            oos.writeObject(people);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 6) 이진 파일(직렬화) 읽기
    @SuppressWarnings("unchecked")
    public static List<Person> readBinary(String filename) {
        List<Person> list = new ArrayList<>();
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(filename))) {
            list = (List<Person>) ois.readObject();
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 7) JSON 파일 쓰기 (Gson 사용 예시)
    public static void writeJson(String filename, List<Person> people) {
        Gson gson = new Gson();
        String jsonStr = gson.toJson(people);
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            bw.write(jsonStr);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 8) JSON 파일 읽기 (Gson 사용 예시)
    public static List<Person> readJson(String filename) {
        Gson gson = new Gson();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return gson.fromJson(sb.toString(), new TypeToken<List<Person>>(){}.getType());
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 9) XML 파일 쓰기 (단순 예시, 실제는 JAXB나 JacksonXml 등 사용)
    public static void writeXml(String filename, List<Person> people) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            bw.write("<people>");
            for (Person p : people) {
                bw.write("<person>");
                bw.write("<name>" + p.getName() + "</name>");
                bw.write("<age>" + p.getAge() + "</age>");
                bw.write("</person>");
            }
            bw.write("</people>");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 10) XML 파일 읽기 (단순 파싱 예시)
    public static List<Person> readXml(String filename) {
        // 실제 XML 파서는 DOM, SAX, StAX, JAXB 등 사용 가능
        List<Person> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            String all = sb.toString();
            // <person> ~ </person> 블록을 찾아 파싱
            String[] personBlocks = all.split("</person>");
            for (String block : personBlocks) {
                if (block.contains("<person>")) {
                    // 이름 추출
                    String name = extractXmlValue(block, "name");
                    // 나이 추출
                    String ageStr = extractXmlValue(block, "age");
                    Person p = new Person(name, Integer.parseInt(ageStr));
                    list.add(p);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    // XML 태그값 추출 간단 유틸
    private static String extractXmlValue(String block, String tag) {
        // <tag> 와 </tag> 사이 문자열 추출
        int start = block.indexOf("<" + tag + ">") + tag.length() + 2;
        int end = block.indexOf("</" + tag + ">");
        return block.substring(start, end);
    }

    // 11) YAML 파일 쓰기 (단순 예시, 실제로는 SnakeYAML 등 사용)
    public static void writeYaml(String filename, List<Person> people) {
        // 실제 사용 시 SnakeYAML 라이브러리 필요
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            for (Person p : people) {
                bw.write("- name: " + p.getName());
                bw.newLine();
                bw.write("  age: " + p.getAge());
                bw.newLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 12) YAML 파일 읽기 (단순 예시)
    public static List<Person> readYaml(String filename) {
        // 실제 사용 시 SnakeYAML 라이브러리로 파싱
        List<Person> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String name = null;
            String age = null;
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.startsWith("- name:")) {
                    name = line.substring(line.indexOf(":") + 1).trim();
                } else if (line.startsWith("age:") || line.startsWith("  age:")) {
                    age = line.substring(line.indexOf(":") + 1).trim();
                    if (name != null && age != null) {
                        list.add(new Person(name, Integer.parseInt(age)));
                        name = null;
                        age = null;
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 13) Properties 파일 쓰기 (java.util.Properties 사용)
    public static void writeProperties(String filename, List<Person> people) {
        Properties props = new Properties();
        // 예시로 personX.name, personX.age 저장
        for (int i = 0; i < people.size(); i++) {
            Person p = people.get(i);
            props.setProperty("person" + i + ".name", p.getName());
            props.setProperty("person" + i + ".age", String.valueOf(p.getAge()));
        }
        try (FileOutputStream fos = new FileOutputStream(filename)) {
            props.store(fos, "Person Properties");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 14) Properties 파일 읽기
    public static List<Person> readProperties(String filename) {
        List<Person> list = new ArrayList<>();
        Properties props = new Properties();
        try (FileInputStream fis = new FileInputStream(filename)) {
            props.load(fis);
            // person0.name, person0.age, person1.name ...
            // 키 집합을 순회하며 person 인덱스 찾기
            int index = 0;
            while (true) {
                String name = props.getProperty("person" + index + ".name");
                String age = props.getProperty("person" + index + ".age");
                if (name == null || age == null) {
                    break;
                }
                list.add(new Person(name, Integer.parseInt(age)));
                index++;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 15) HTML 파일 쓰기 (간단하게 태그 작성)
    public static void writeHtml(String filename, List<Person> people) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            bw.write("<html><body>");
            bw.newLine();
            bw.write("<h1>Person List</h1>");
            bw.newLine();
            bw.write("<ul>");
            bw.newLine();
            for (Person p : people) {
                bw.write("<li>" + p.getName() + " (" + p.getAge() + ")</li>");
                bw.newLine();
            }
            bw.write("</ul>");
            bw.newLine();
            bw.write("</body></html>");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 16) HTML 파일 읽기 (아주 간단한 문자열 파싱 예시)
    public static List<Person> readHtml(String filename) {
        // 현실적으로 HTML 파싱은 Jsoup 등 라이브러리 사용
        // 여기서는 <li>... </li> 태그 기준으로 이름, 나이 추출
        List<Person> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            String all = sb.toString();
            String[] liTags = all.split("</li>");
            for (String li : liTags) {
                if (li.contains("<li>")) {
                    String content = li.substring(li.indexOf("<li>") + 4).trim();
                    // 예: "홍길동 (30)"
                    if (content.contains("(") && content.contains(")")) {
                        String name = content.substring(0, content.indexOf("(")).trim();
                        String ageStr = content.substring(content.indexOf("(") + 1, content.indexOf(")")).trim();
                        list.add(new Person(name, Integer.parseInt(ageStr)));
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 17) Markdown 파일 쓰기 (간단 예시)
    public static void writeMarkdown(String filename, List<Person> people) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            bw.write("# Person List");
            bw.newLine();
            for (Person p : people) {
                bw.write("- **" + p.getName() + "**, " + p.getAge() + "살");
                bw.newLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 18) Markdown 파일 읽기 (단순 예시)
    public static List<Person> readMarkdown(String filename) {
        // 예: "- **홍길동**, 30살"
        List<Person> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.startsWith("- **")) {
                    int startName = line.indexOf("**") + 2;
                    int endName = line.indexOf("**", startName);
                    String name = line.substring(startName, endName);
                    String rest = line.substring(endName + 2).trim();
                    // ", 30살" -> 나이 부분만 정수로 파싱
                    if (rest.startsWith(",")) {
                        rest = rest.substring(1).trim();
                        String ageStr = rest.replace("살", "").trim();
                        list.add(new Person(name, Integer.parseInt(ageStr)));
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 19) ZIP 압축 쓰기 (텍스트로 묶는 간단 예시)
    public static void writeZip(String filename, List<Person> people) {
        // ZIP 안에 "persons.txt" 라는 파일을 넣는 예시
        try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(filename))) {
            ZipEntry entry = new ZipEntry("persons.txt");
            zos.putNextEntry(entry);
            // person 정보를 문자열로 만들어 ZIP 내에 기록
            StringBuilder sb = new StringBuilder();
            for (Person p : people) {
                sb.append(p.toDataString()).append(System.lineSeparator());
            }
            byte[] data = sb.toString().getBytes();
            zos.write(data, 0, data.length);
            zos.closeEntry();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 20) ZIP 압축 읽기 (텍스트 파일 하나 있다고 가정)
    public static List<Person> readZip(String filename) {
        List<Person> list = new ArrayList<>();
        try (ZipInputStream zis = new ZipInputStream(new FileInputStream(filename))) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                if (entry.getName().equals("persons.txt")) {
                    BufferedReader br = new BufferedReader(new InputStreamReader(zis));
                    String line;
                    while ((line = br.readLine()) != null) {
                        Person p = Person.fromDataString(line);
                        list.add(p);
                    }
                    zis.closeEntry();
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }
}

```



---

**파일명 3: Main.java**

```java
package com.example.ch4.files;

import java.util.ArrayList;
import java.util.List;

public class FileIOHandlerMain {
    public static void main(String[] args) {
        // Person 리스트 준비
        List<Person> people = new ArrayList<>();
        people.add(new Person("홍길동", 30));
        people.add(new Person("김영희", 25));
        people.add(new Person("박철수", 35));

        // 1) 텍스트 파일 쓰기/읽기
        String textFile = "people.txt";
        FileIOHandler.writeTextFile(textFile, people);
        List<Person> textRead = FileIOHandler.readTextFile(textFile);
        System.out.println("[Text 파일 읽기 결과]");
        for (Person p : textRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 2) CSV 파일 쓰기/읽기
        String csvFile = "people.csv";
        FileIOHandler.writeCSV(csvFile, people);
        List<Person> csvRead = FileIOHandler.readCSV(csvFile);
        System.out.println("\n[CSV 파일 읽기 결과]");
        for (Person p : csvRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 3) 이진(직렬화) 파일 쓰기/읽기
        String binFile = "people.dat";
        FileIOHandler.writeBinary(binFile, people);
        List<Person> binRead = FileIOHandler.readBinary(binFile);
        System.out.println("\n[Binary 파일 읽기 결과]");
        for (Person p : binRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 4) JSON 파일 쓰기/읽기
        String jsonFile = "people.json";
        FileIOHandler.writeJson(jsonFile, people);
        List<Person> jsonRead = FileIOHandler.readJson(jsonFile);
        System.out.println("\n[JSON 파일 읽기 결과]");
        if (jsonRead != null) {
            for (Person p : jsonRead) {
                System.out.println(p.getName() + " / " + p.getAge());
            }
        }

        // 5) XML 파일 쓰기/읽기
        String xmlFile = "people.xml";
        FileIOHandler.writeXml(xmlFile, people);
        List<Person> xmlRead = FileIOHandler.readXml(xmlFile);
        System.out.println("\n[XML 파일 읽기 결과]");
        for (Person p : xmlRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 6) YAML 파일 쓰기/읽기
        String yamlFile = "people.yaml";
        FileIOHandler.writeYaml(yamlFile, people);
        List<Person> yamlRead = FileIOHandler.readYaml(yamlFile);
        System.out.println("\n[YAML 파일 읽기 결과]");
        for (Person p : yamlRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 7) Properties 파일 쓰기/읽기
        String propFile = "people.properties";
        FileIOHandler.writeProperties(propFile, people);
        List<Person> propRead = FileIOHandler.readProperties(propFile);
        System.out.println("\n[Properties 파일 읽기 결과]");
        for (Person p : propRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 8) HTML 파일 쓰기/읽기
        String htmlFile = "people.html";
        FileIOHandler.writeHtml(htmlFile, people);
        List<Person> htmlRead = FileIOHandler.readHtml(htmlFile);
        System.out.println("\n[HTML 파일 읽기 결과]");
        for (Person p : htmlRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 9) Markdown 파일 쓰기/읽기
        String mdFile = "people.md";
        FileIOHandler.writeMarkdown(mdFile, people);
        List<Person> mdRead = FileIOHandler.readMarkdown(mdFile);
        System.out.println("\n[Markdown 파일 읽기 결과]");
        for (Person p : mdRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }

        // 10) ZIP 파일 쓰기/읽기
        String zipFile = "people.zip";
        FileIOHandler.writeZip(zipFile, people);
        List<Person> zipRead = FileIOHandler.readZip(zipFile);
        System.out.println("\n[ZIP 파일(텍스트) 읽기 결과]");
        for (Person p : zipRead) {
            System.out.println(p.getName() + " / " + p.getAge());
        }
    }
}


```

---

**데이터**

- `Person` 객체 리스트
---

**출력 예시 (일부)**

```plain text

[Text 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[CSV 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[Binary 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[JSON 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[XML 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[YAML 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[Properties 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[HTML 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[Markdown 파일 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

[ZIP 파일(텍스트) 읽기 결과]
홍길동 / 30
김영희 / 25
박철수 / 35

Process finished with exit code 0

```

---




---

## 10.9-1 형식별 파일 처리 실전문제 풀이

#### 개요

이 문서는 `형식별 파일 처리 실전문제`의 풀이입니다. CSV, Excel, JSON을 같은 방식으로 읽지 않고, 형식마다 다른 도구와 책임 분리가 필요하다는 점을 코드로 확인하는 데 목적이 있습니다.

아래 코드는 단일 책임 원칙을 기준으로 각 작업의 책임을 독립적인 클래스로 나눠 구조화한 예시입니다.

---

##### CSV 파일 문제 풀이

1. 부서별 CSV 필터링과 정렬

```java
import java.io.*;
import java.util.*;

public class CsvProcessor {
    record Employee(int id, String name, int age, String department) {}

    public static void main(String[] args) throws IOException {
        List<Employee> employees = readCsv("data.csv");
        List<Employee> filtered = employees.stream()
                .filter(employee -> employee.department().equalsIgnoreCase("Engineering"))
                .sorted(Comparator.comparingInt(Employee::age))
                .toList();
        writeCsv("filtered_data.csv", filtered);
    }

    static List<Employee> readCsv(String filePath) throws IOException {
        List<Employee> result = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            boolean first = true;
            while ((line = br.readLine()) != null) {
                if (first) {
                    first = false;
                    continue;
                }
                String[] parts = line.split(",");
                if (parts.length == 4) {
                    result.add(new Employee(Integer.parseInt(parts[0]), parts[1], Integer.parseInt(parts[2]), parts[3]));
                }
            }
        }
        return result;
    }

    static void writeCsv(String filePath, List<Employee> employees) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath))) {
            bw.write("id,name,age,department");
            bw.newLine();
            for (Employee employee : employees) {
                bw.write(employee.id() + "," + employee.name() + "," + employee.age() + "," + employee.department());
                bw.newLine();
            }
        }
    }
}
```

해설

CSV 문제의 핵심은 포맷이 단순하다는 이유로 검증을 빼먹지 않는 것입니다. 헤더 처리, 컬럼 수 검증, 숫자 파싱 실패 대응까지 같이 봐야 실무 코드에 가까워집니다.

2. 대용량 CSV 집계

- 상세 풀이는 [파일처리 실전연습문제-1 풀이 1](https://www.notion.so/1861e21f38368096a641f5c0759bd3f8), [파일처리 실전연습문제-1 풀이 2](https://www.notion.so/1861e21f38368002874dc437b494f6b0)를 함께 보면 됩니다.
---

##### 엑셀 파일 문제 (1 ~ 10)

---

##### 1. **엑셀 데이터 합산**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.IOException;

public class ExcelSumProcessor {
    public static void main(String[] args) {
        SalesDataReader reader = new SalesDataReader();
        double totalSales = reader.calculateTotal("sales_data.xlsx");
        System.out.println("월별 매출 합계: " + totalSales);
    }
}

class SalesDataReader {
    public double calculateTotal(String filePath) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);
            double total = 0;

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                total += row.getCell(1).getNumericCellValue();
            }
            return total;
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 읽기 오류: " + e.getMessage());
        }
    }
}

```

---

##### 2. **특정 열의 데이터 필터링**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class EmployeeFilterProcessor {
    public static void main(String[] args) {
        EmployeeDataReader reader = new EmployeeDataReader();
        List<String> highSalaryEmployees = reader.filterBySalary("employee_data.xlsx", 50000000);
        System.out.println("연봉 5천만 원 이상 직원:");
        highSalaryEmployees.forEach(System.out::println);
    }
}

class EmployeeDataReader {
    public List<String> filterBySalary(String filePath, double minSalary) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);
            List<String> result = new ArrayList<>();

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                double salary = row.getCell(2).getNumericCellValue();
                if (salary >= minSalary) {
                    result.add(row.getCell(0).getStringCellValue());
                }
            }
            return result;
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 읽기 오류: " + e.getMessage());
        }
    }
}

```

---

##### 3. **엑셀 데이터 정렬**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class StudentScoreProcessor {
    public static void main(String[] args) {
        StudentScoreReader reader = new StudentScoreReader();
        List<Student> topStudents = reader.getTopStudents("students_scores.xlsx", 10);
        System.out.println("상위 10명 학생 점수:");
        topStudents.forEach(System.out::println);
    }
}

class Student {
    private final String name;
    private final String subject;
    private final int score;

    public Student(String name, String subject, int score) {
        this.name = name;
        this.subject = subject;
        this.score = score;
    }

    public int getScore() {
        return score;
    }

    @Override
    public String toString() {
        return "이름: " + name + ", 과목: " + subject + ", 점수: " + score;
    }
}

class StudentScoreReader {
    public List<Student> getTopStudents(String filePath, int topCount) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);
            List<Student> students = new ArrayList<>();

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                String name = row.getCell(0).getStringCellValue();
                String subject = row.getCell(1).getStringCellValue();
                int score = (int) row.getCell(2).getNumericCellValue();
                students.add(new Student(name, subject, score));
            }

            students.sort(Comparator.comparingInt(Student::getScore).reversed());
            return students.subList(0, Math.min(topCount, students.size()));
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 읽기 오류: " + e.getMessage());
        }
    }
}

```

---

##### 4. **특정 셀 값 변경**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class InventoryUpdater {
    public static void main(String[] args) {
        String filePath = "inventory.xlsx";
        String productName = "모니터";
        int newQuantity = 100;

        InventoryDataModifier modifier = new InventoryDataModifier();
        modifier.updateQuantity(filePath, productName, newQuantity);

        System.out.println(productName + " 수량이 " + newQuantity + "으로 변경됨.");
    }
}

class InventoryDataModifier {
    public void updateQuantity(String filePath, String productName, int newQuantity) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                if (row.getCell(0).getStringCellValue().equals(productName)) {
                    row.getCell(1).setCellValue(newQuantity);
                    break;
                }
            }

            try (FileOutputStream fos = new FileOutputStream(filePath)) {
                workbook.write(fos);
            }
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 수정 오류: " + e.getMessage());
        }
    }
}

```

---

##### 5. **엑셀 데이터 통합**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class ExcelDataMerger {
    public static void main(String[] args) {
        String file1 = "data1.xlsx";
        String file2 = "data2.xlsx";
        String outputFile = "merged_data.xlsx";

        ExcelMerger merger = new ExcelMerger();
        merger.mergeExcelFiles(file1, file2, outputFile);

        System.out.println("엑셀 데이터가 병합되어 " + outputFile + "에 저장됨.");
    }
}

class ExcelMerger {
    public void mergeExcelFiles(String file1, String file2, String outputFile) {
        try (FileInputStream fis1 = new FileInputStream(file1);
             FileInputStream fis2 = new FileInputStream(file2);
             Workbook workbook1 = new XSSFWorkbook(fis1);
             Workbook workbook2 = new XSSFWorkbook(fis2);
             Workbook outputWorkbook = new XSSFWorkbook()) {

            Sheet sheet1 = workbook1.getSheetAt(0);
            Sheet sheet2 = workbook2.getSheetAt(0);
            Sheet outputSheet = outputWorkbook.createSheet("Merged Data");

            int rowCount = 0;
            rowCount = copySheet(sheet1, outputSheet, rowCount);
            copySheet(sheet2, outputSheet, rowCount);

            try (FileOutputStream fos = new FileOutputStream(outputFile)) {
                outputWorkbook.write(fos);
            }
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 병합 오류: " + e.getMessage());
        }
    }

    private int copySheet(Sheet sourceSheet, Sheet targetSheet, int startRow) {
        for (int i = 0; i < sourceSheet.getPhysicalNumberOfRows(); i++) {
            Row sourceRow = sourceSheet.getRow(i);
            Row targetRow = targetSheet.createRow(startRow++);

            for (int j = 0; j < sourceRow.getPhysicalNumberOfCells(); j++) {
                Cell sourceCell = sourceRow.getCell(j);
                Cell targetCell = targetRow.createCell(j);

                switch (sourceCell.getCellType()) {
                    case STRING -> targetCell.setCellValue(sourceCell.getStringCellValue());
                    case NUMERIC -> targetCell.setCellValue(sourceCell.getNumericCellValue());
                    default -> targetCell.setCellValue(sourceCell.toString());
                }
            }
        }
        return startRow;
    }
}

```

---

##### 6. **조건에 맞는 셀 색상 변경**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class GradeHighlighter {
    public static void main(String[] args) {
        String filePath = "grades.xlsx";
        GradeCellModifier modifier = new GradeCellModifier();
        modifier.highlightLowScores(filePath, 50);
        System.out.println("점수 50점 미만 셀이 강조되었음.");
    }
}

class GradeCellModifier {
    public void highlightLowScores(String filePath, int threshold) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);
            CellStyle style = workbook.createCellStyle();
            style.setFillForegroundColor(IndexedColors.RED.getIndex());
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                Cell cell = row.getCell(2);
                if (cell.getCellType() == CellType.NUMERIC && cell.getNumericCellValue() < threshold) {
                    cell.setCellStyle(style);
                }
            }

            try (FileOutputStream fos = new FileOutputStream(filePath)) {
                workbook.write(fos);
            }
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 수정 오류: " + e.getMessage());
        }
    }
}

```

---

##### 7. **엑셀 데이터 시각화**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtils;
import org.jfree.chart.JFreeChart;
import org.jfree.data.category.DefaultCategoryDataset;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class SalesVisualizer {
    public static void main(String[] args) {
        String filePath = "monthly_sales.xlsx";
        String chartPath = "sales_chart.png";

        SalesChartGenerator generator = new SalesChartGenerator();
        generator.generateBarChart(filePath, chartPath);

        System.out.println("차트가 " + chartPath + "에 저장되었음.");
    }
}

class SalesChartGenerator {
    public void generateBarChart(String filePath, String outputPath) {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                String month = row.getCell(0).getStringCellValue();
                double sales = row.getCell(1).getNumericCellValue();
                dataset.addValue(sales, "Sales", month);
            }

            JFreeChart barChart = ChartFactory.createBarChart(
                    "Monthly Sales",
                    "Month",
                    "Sales",
                    dataset
            );

            ChartUtils.saveChartAsPNG(new File(outputPath), barChart, 800, 600);
        } catch (IOException e) {
            throw new RuntimeException("엑셀 읽기 또는 차트 생성 오류: " + e.getMessage());
        }
    }
}

```

---

##### 8. **빈 셀 채우기**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class SurveyDataCleaner {
    public static void main(String[] args) {
        String filePath = "survey_data.xlsx";

        SurveyCleaner cleaner = new SurveyCleaner();
        cleaner.fillEmptyCells(filePath, "N/A");

        System.out.println("빈 셀이 'N/A'로 채워졌음.");
    }
}

class SurveyCleaner {
    public void fillEmptyCells(String filePath, String filler) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                for (int j = 0; j < row.getPhysicalNumberOfCells(); j++) {
                    Cell cell = row.getCell(j);
                    if (cell == null || cell.getCellType() == CellType.BLANK) {
                        row.createCell(j).setCellValue(filler);
                    }
                }
            }

            try (FileOutputStream fos = new FileOutputStream(filePath)) {
                workbook.write(fos);
            }
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 수정 오류: " + e.getMessage());
        }
    }
}



import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class SurveyDataReplacer {
    public static void main(String[] args) {
        String filePath = "survey_data.xlsx";

        SurveyReplacer replacer = new SurveyReplacer();
        replacer.replaceText(filePath, "없음", "n/a");

        System.out.println("'없음'이 'n/a'로 대체됨.");
    }
}

class SurveyReplacer {
    public void replaceText(String filePath, String target, String replacement) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                for (int j = 0; j < row.getPhysicalNumberOfCells(); j++) {
                    Cell cell = row.getCell(j);
                    if (cell != null && cell.getCellType() == CellType.STRING) {
                        if (cell.getStringCellValue().equals(target)) {
                            cell.setCellValue(replacement);
                        }
                    }
                }
            }

            try (FileOutputStream fos = new FileOutputStream(filePath)) {
                workbook.write(fos);
            }
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 처리 오류: " + e.getMessage());
        }
    }
}

```

---

##### 9. **다중 시트 데이터 처리**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class MultiSheetMerger {
    public static void main(String[] args) {
        String filePath = "multi_sheet.xlsx";
        String outputPath = "merged_sheets.xlsx";

        MultiSheetProcessor processor = new MultiSheetProcessor();
        processor.mergeSheets(filePath, outputPath);

        System.out.println("다중 시트 데이터가 병합되어 " + outputPath + "에 저장됨.");
    }
}

class MultiSheetProcessor {
    public void mergeSheets(String inputFilePath, String outputFilePath) {
        try (FileInputStream fis = new FileInputStream(inputFilePath);
             Workbook inputWorkbook = new XSSFWorkbook(fis);
             Workbook outputWorkbook = new XSSFWorkbook()) {

            Sheet outputSheet = outputWorkbook.createSheet("Merged Data");
            int rowCount = 0;

            for (int i = 0; i < inputWorkbook.getNumberOfSheets(); i++) {
                Sheet inputSheet = inputWorkbook.getSheetAt(i);
                rowCount = copySheet(inputSheet, outputSheet, rowCount);
            }

            try (FileOutputStream fos = new FileOutputStream(outputFilePath)) {
                outputWorkbook.write(fos);
            }
        } catch (IOException e) {
            throw new RuntimeException("엑셀 병합 오류: " + e.getMessage());
        }
    }

    private int copySheet(Sheet sourceSheet, Sheet targetSheet, int startRow) {
        for (int i = 0; i < sourceSheet.getPhysicalNumberOfRows(); i++) {
            Row sourceRow = sourceSheet.getRow(i);
            Row targetRow = targetSheet.createRow(startRow++);

            for (int j = 0; j < sourceRow.getPhysicalNumberOfCells(); j++) {
                Cell sourceCell = sourceRow.getCell(j);
                Cell targetCell = targetRow.createCell(j);

                switch (sourceCell.getCellType()) {
                    case STRING -> targetCell.setCellValue(sourceCell.getStringCellValue());
                    case NUMERIC -> targetCell.setCellValue(sourceCell.getNumericCellValue());
                    default -> targetCell.setCellValue(sourceCell.toString());
                }
            }
        }
        return startRow;
    }
}

```

---

##### 10. **엑셀 데이터 통계 분석**

```java
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.IOException;

public class TestScoresAnalyzer {
    public static void main(String[] args) {
        String filePath = "test_scores.xlsx";

        TestScoreProcessor processor = new TestScoreProcessor();
        processor.analyzeScores(filePath);
    }
}

class TestScoreProcessor {
    public void analyzeScores(String filePath) {
        try (FileInputStream fis = new FileInputStream(filePath);
             Workbook workbook = new XSSFWorkbook(fis)) {

            Sheet sheet = workbook.getSheetAt(0);
            double total = 0;
            double max = Double.MIN_VALUE;
            double min = Double.MAX_VALUE;
            int count = 0;

            for (int i = 1; i < sheet.getPhysicalNumberOfRows(); i++) {
                Row row = sheet.getRow(i);
                double score = row.getCell(2).getNumericCellValue();
                total += score;
                max = Math.max(max, score);
                min = Math.min(min, score);
                count++;
            }

            double average = total / count;
            System.out.println("평균 점수: " + average);
            System.out.println("최대 점수: " + max);
            System.out.println("최소 점수: " + min);
        } catch (IOException e) {
            throw new RuntimeException("엑셀 파일 읽기 오류: " + e.getMessage());
        }
    }
}

```

---

##### JSON 파일 문제 (1 ~ 10)

---

##### 1. **JSON 데이터 키 검색**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class ProductKeySearcher {
    public static void main(String[] args) {
        String filePath = "products.json";

        ProductReader reader = new ProductReader();
        reader.printKeyValues(filePath, "price");
    }
}

class ProductReader {
    public void printKeyValues(String filePath, String key) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Product> products = mapper.readValue(new File(filePath), new TypeReference<>() {});

            System.out.println(key + " 값 목록:");
            products.forEach(product -> {
                if (key.equals("price")) {
                    System.out.println(product.getPrice());
                } else {
                    System.out.println("키가 유효하지 않음.");
                }
            });
        } catch (IOException e) {
            throw new RuntimeException("JSON 읽기 오류: " + e.getMessage());
        }
    }
}

class Product {
    private int id;
    private String name;
    private double price;

    public double getPrice() {
        return price;
    }
}

```

---

##### 2. **특정 값 추출**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class UserFilter {
    public static void main(String[] args) {
        String filePath = "users.json";

        UserReader reader = new UserReader();
        reader.filterByAge(filePath, 30);
    }
}

class UserReader {
    public void filterByAge(String filePath, int minAge) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<User> users = mapper.readValue(new File(filePath), new TypeReference<>() {});

            System.out.println("나이 " + minAge + " 이상 사용자의 이메일:");
            users.stream()
                    .filter(user -> user.getAge() >= minAge)
                    .map(User::getEmail)
                    .forEach(System.out::println);
        } catch (IOException e) {
            throw new RuntimeException("JSON 읽기 오류: " + e.getMessage());
        }
    }
}

class User {
    private String name;
    private int age;
    private String email;

    public int getAge() {
        return age;
    }

    public String getEmail() {
        return email;
    }
}

```

---

##### 3. **JSON 데이터 합산**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class SalesSumCalculator {
    public static void main(String[] args) {
        String filePath = "sales.json";

        SalesDataReader reader = new SalesDataReader();
        double totalSales = reader.calculateTotalSales(filePath);

        System.out.println("총 매출액: " + totalSales);
    }
}

class SalesDataReader {
    public double calculateTotalSales(String filePath) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            SalesData salesData = mapper.readValue(new File(filePath), SalesData.class);

            return salesData.getMonthlySales().stream()
                    .mapToDouble(MonthlySale::getSales)
                    .sum();
        } catch (IOException e) {
            throw new RuntimeException("JSON 읽기 오류: " + e.getMessage());
        }
    }
}

class SalesData {
    private List<MonthlySale> monthlySales;

    public List<MonthlySale> getMonthlySales() {
        return monthlySales;
    }
}

class MonthlySale {
    private String month;
    private double sales;

    public double getSales() {
        return sales;
    }
}

```

---

##### 4. **중첩 JSON 데이터 탐색**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class DepartmentEmployeeFinder {
    public static void main(String[] args) {
        String filePath = "organization.json";

        OrganizationReader reader = new OrganizationReader();
        reader.findEmployeesByDepartment(filePath, "개발팀");
    }
}

class OrganizationReader {
    public void findEmployeesByDepartment(String filePath, String departmentName) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            Organization organization = mapper.readValue(new File(filePath), Organization.class);

            organization.getDepartments().stream()
                    .filter(department -> department.getName().equals(departmentName))
                    .flatMap(department -> department.getEmployees().stream())
                    .map(Employee::getName)
                    .forEach(System.out::println);
        } catch (IOException e) {
            throw new RuntimeException("JSON 읽기 오류: " + e.getMessage());
        }
    }
}

class Organization {
    private List<Department> departments;

    public List<Department> getDepartments() {
        return departments;
    }
}

class Department {
    private String name;
    private List<Employee> employees;

    public String getName() {
        return name;
    }

    public List<Employee> getEmployees() {
        return employees;
    }
}

class Employee {
    private String name;

    public String getName() {
        return name;
    }
}

```

---

##### 5. **JSON 데이터 수정**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class InventoryPriceUpdater {
    public static void main(String[] args) {
        String filePath = "inventory.json";

        InventoryModifier modifier = new InventoryModifier();
        modifier.updatePrice(filePath, "모니터", 150000);

        System.out.println("가격 수정 완료.");
    }
}

class InventoryModifier {
    public void updatePrice(String filePath, String productName, double newPrice) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Product> inventory = mapper.readValue(new File(filePath), new TypeReference<>() {});

            inventory.stream()
                    .filter(product -> product.getProduct().equals(productName))
                    .forEach(product -> product.setPrice(newPrice));

            mapper.writeValue(new File(filePath), inventory);
        } catch (IOException e) {
            throw new RuntimeException("JSON 수정 오류: " + e.getMessage());
        }
    }
}

class Product {
    private String product;
    private int quantity;
    private double price;

    public String getProduct() {
        return product;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}

```

---

##### 6. **JSON 데이터 병합**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class JsonMerger {
    public static void main(String[] args) {
        String file1 = "data1.json";
        String file2 = "data2.json";
        String outputFile = "merged_data.json";

        JsonDataMerger merger = new JsonDataMerger();
        merger.mergeJsonFiles(file1, file2, outputFile);

        System.out.println("JSON 파일 병합 완료: " + outputFile);
    }
}

class JsonDataMerger {
    public void mergeJsonFiles(String file1, String file2, String outputFile) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Object> data1 = mapper.readValue(new File(file1), new TypeReference<>() {});
            List<Object> data2 = mapper.readValue(new File(file2), new TypeReference<>() {});

            List<Object> mergedData = new ArrayList<>(data1);
            mergedData.addAll(data2);

            mapper.writeValue(new File(outputFile), mergedData);
        } catch (IOException e) {
            throw new RuntimeException("JSON 병합 오류: " + e.getMessage());
        }
    }
}

```

---

##### 7. **JSON 데이터 정렬**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class MovieSorter {
    public static void main(String[] args) {
        String filePath = "movies.json";

        MovieSorterProcessor processor = new MovieSorterProcessor();
        List<Movie> sortedMovies = processor.sortMoviesByRating(filePath);

        System.out.println("평점 정렬된 영화:");
        sortedMovies.forEach(System.out::println);
    }
}

class MovieSorterProcessor {
    public List<Movie> sortMoviesByRating(String filePath) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Movie> movies = mapper.readValue(new File(filePath), new TypeReference<>() {});

            return movies.stream()
                    .sorted((m1, m2) -> Double.compare(m2.getRating(), m1.getRating()))
                    .collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException("JSON 읽기 오류: " + e.getMessage());
        }
    }
}

class Movie {
    private String title;
    private double rating;

    public String getTitle() {
        return title;
    }

    public double getRating() {
        return rating;
    }

    @Override
    public String toString() {
        return "영화 제목: " + title + ", 평점: " + rating;
    }
}

```

---

##### 8. **JSON 데이터 시각화**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtils;
import org.jfree.chart.JFreeChart;
import org.jfree.data.category.DefaultCategoryDataset;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class PopulationVisualizer {
    public static void main(String[] args) {
        String filePath = "population.json";
        String chartPath = "population_chart.png";

        PopulationChartGenerator generator = new PopulationChartGenerator();
        generator.generateBarChart(filePath, chartPath);

        System.out.println("인구 차트가 " + chartPath + "에 저장됨.");
    }
}

class PopulationChartGenerator {
    public void generateBarChart(String filePath, String chartPath) {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();

        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Country> countries = mapper.readValue(new File(filePath), new TypeReference<>() {});

            for (Country country : countries) {
                dataset.addValue(country.getPopulation(), "Population", country.getCountry());
            }

            JFreeChart barChart = ChartFactory.createBarChart(
                    "Country Population",
                    "Country",
                    "Population",
                    dataset
            );

            ChartUtils.saveChartAsPNG(new File(chartPath), barChart, 800, 600);
        } catch (IOException e) {
            throw new RuntimeException("JSON 읽기 또는 차트 생성 오류: " + e.getMessage());
        }
    }
}

class Country {
    private String country;
    private int population;

    public String getCountry() {
        return country;
    }

    public int getPopulation() {
        return population;
    }
}

```

---

##### 9. **특정 조건의 데이터 삭제**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class CustomerDataCleaner {
    public static void main(String[] args) {
        String filePath = "customers.json";
        String outputFilePath = "filtered_customers.json";

        CustomerFilter filter = new CustomerFilter();
        filter.removeUnderageCustomers(filePath, outputFilePath, 18);

        System.out.println("18세 미만 고객 제거 완료. 결과는 " + outputFilePath + "에 저장됨.");
    }
}

class CustomerFilter {
    public void removeUnderageCustomers(String filePath, String outputFilePath, int minAge) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Customer> customers = mapper.readValue(new File(filePath), new TypeReference<>() {});

            List<Customer> filteredCustomers = customers.stream()
                    .filter(customer -> customer.getAge() >= minAge)
                    .collect(Collectors.toList());

            mapper.writeValue(new File(outputFilePath), filteredCustomers);
        } catch (IOException e) {
            throw new RuntimeException("JSON 처리 오류: " + e.getMessage());
        }
    }
}

class Customer {
    private String name;
    private int age;
    private String address;

    public int getAge() {
        return age;
    }

    @Override
    public String toString() {
        return "이름: " + name + ", 나이: " + age + ", 주소: " + address;
    }
}

```

---

##### 10. **JSON 데이터에서 중복 제거**

```java
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class OrderDeduplicator {
    public static void main(String[] args) {
        String filePath = "orders.json";
        String outputFilePath = "deduplicated_orders.json";

        OrderFilter filter = new OrderFilter();
        filter.removeDuplicateOrders(filePath, outputFilePath);

        System.out.println("중복된 주문 제거 완료. 결과는 " + outputFilePath + "에 저장됨.");
    }
}

class OrderFilter {
    public void removeDuplicateOrders(String filePath, String outputFilePath) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Order> orders = mapper.readValue(new File(filePath), new TypeReference<>() {});

            Set<String> uniqueOrderIds = new HashSet<>();
            List<Order> deduplicatedOrders = orders.stream()
                    .filter(order -> uniqueOrderIds.add(order.getOrderId()))
                    .collect(Collectors.toList());

            mapper.writeValue(new File(outputFilePath), deduplicatedOrders);
        } catch (IOException e) {
            throw new RuntimeException("JSON 처리 오류: " + e.getMessage());
        }
    }
}

class Order {
    private String orderId;
    private String product;
    private int quantity;

    public String getOrderId() {
        return orderId;
    }

    @Override
    public String toString() {
        return "주문 ID: " + orderId + ", 제품: " + product + ", 수량: " + quantity;
    }
}

```

---

##### 주요 원칙 적용 설명

1. **단일 책임 원칙 (SRP)**:
1. **확장성**:
1. **재사용성**:





---

## 10.2 예외와 사용자 정의 예외

#### 개요

이 문서는 Java에서 예외를 어떻게 처리하고, 언제 사용자 정의 예외를 만들어야 하는지 정리한 문서입니다.

#### 왜 중요한가

예외 처리는 프로그램이 죽지 않게 만드는 기술이 아니라, 실패의 의미를 설계하는 작업에 가깝습니다.

#### 1. 기본 예외 처리 구조

```java
try {
    int value = Integer.parseInt("ABC");
} catch (NumberFormatException e) {
    System.err.println("숫자 변환에 실패했습니다: " + e.getMessage());
} finally {
    System.out.println("정리 작업 실행");
}
```

#### 3. 사용자 정의 예외가 필요한 시점

- 비즈니스 규칙 위반을 명확히 표현하고 싶을 때
- 호출하는 쪽에서 예외 종류에 따라 분기해야 할 때
- 컨트롤러에서 일관된 에러 코드를 내려야 할 때

#### 한 줄 정리

사용자 정의 예외의 핵심은 **새 예외를 많이 만드는 것이 아니라, 실패의 의미를 더 정확하게 표현하는 것**입니다.

---

## 10.8 파일 처리 실전문제 1

#### 개요

이 문서는 파일 읽기와 쓰기 기초를 읽은 뒤 이어서 푸는 실전문제입니다. 핵심은 파일을 전부 메모리에 올리지 않고, 한 줄씩 읽으면서 통계를 누적하는 방식으로 사고를 바꾸는 데 있습니다.

문제: CSV 파일을 읽고 평균 나이, 평균 점수, 90점 이상 사용자 수, 특정 문자로 시작하는 사용자 수, 최연소/최고령 사용자를 구합니다.

---

## 10.8-1 파일 처리 실전문제 1 풀이 1

#### 개요

이 풀이는 한 클래스 안에서 빠르게 통계를 계산하는 직진형 해설입니다. 처음 문제를 풀 때는 이 방식이 이해하기 쉽고, 두 번째 풀이와 비교하면 구조화의 필요성이 더 잘 보입니다.

```java
public class LargeFileProcessing {
    private static void processFile(String fileName) {
        try (InputStream is = LargeFileProcessing.class.getClassLoader().getResourceAsStream(fileName);
             BufferedReader br = new BufferedReader(new InputStreamReader(is))) {
            br.readLine(); // 헤더 스킵
            analyzeData(br);
        } catch (IOException e) {
            System.err.println("파일 처리 중 오류 발생: " + e.getMessage());
        }
    }
}
```

---


## 10.8-2 파일 처리 실전문제 1 풀이 2

#### 개요

이 풀이는 CSV 읽기, 통계 집계, 결과 표현을 역할별로 나눈 구조화된 해설입니다. 도메인 모델(User), 리포지토리(CsvUserRepository), 분석 서비스(UserAnalyticsService)로 분리하여 같은 문제를 더 확장 가능한 구조로 풀어봅니다.

---

## 10.9 형식별 파일 처리 실전문제

#### 개요

이 문서는 `여러 형식의 파일 처리` 다음에 푸는 형식별 파일 처리 실전문제 모음입니다. CSV, Excel, JSON은 모두 파일이지만 읽는 방식과 도구와 실수 포인트가 다르므로, 형식별로 따로 연습하는 편이 좋습니다.

#### CSV 파일 관련 연습문제
1. `부서별 CSV 필터링과 정렬`
2. `CSV 헤더와 유효성 검사`
3. `대용량 CSV 집계`

#### 엑셀 파일 관련 연습문제
1. `엑셀 데이터 합산`
2. `특정 열의 데이터 필터링`
3. `엑셀 데이터 정렬`
4. `특정 셀 값 변경`
5. `엑셀 데이터 통합`
6. `조건에 맞는 셀 색상 변경`
7. `엑셀 데이터 시각화`
8. `빈 셀 채우기`
9. `다중 시트 데이터 처리`
10. `엑셀 데이터 통계 분석`

#### JSON 파일 관련 연습문제
1. `JSON 데이터 키 검색`
2. `특정 값 추출`
3. `JSON 데이터 합산`
4. `중첩 JSON 데이터 탐색`
5. `JSON 데이터 수정`
6. `JSON 데이터 병합`
7. `JSON 데이터 정렬`
8. `JSON 데이터 시각화`
9. `특정 조건의 데이터 삭제`
10. `JSON 데이터에서 중복 제거`

---

