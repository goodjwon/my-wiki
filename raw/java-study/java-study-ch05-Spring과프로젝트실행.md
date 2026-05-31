# 5. Spring과프로젝트실행
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 5.1 Spring 실습 환경 구성 가이드

#### 개요

이 문서는 **초중급 Java 개발자**가 Spring 실습을 시작하기 전에 로컬 개발 환경을 안정적으로 맞추기 위한 가이드입니다. 단순 설치 목록을 나열하는 것이 아니라, 왜 이 순서로 준비해야 하는지와 어디서 가장 자주 막히는지를 함께 설명합니다.

#### 왜 먼저 읽어야 하는가

Spring 학습 초반에는 문법보다 **실행 가능한 환경을 먼저 확보하는 것**이 더 중요합니다. 환경이 흔들리면 예제 코드가 틀린 것인지, 내 설정이 잘못된 것인지 구분하기 어려워집니다. 이 문서는 그런 혼란을 줄이기 위한 출발점입니다.

#### 대상 독자

- Java 문법과 IDE 사용 경험은 있지만 Spring 프로젝트 실행은 아직 익숙하지 않은 개발자
- 강의나 책의 예제를 따라 하다가 JDK, 빌드 도구, IDE 설정 문제로 자주 막히는 개발자
- 실습 전에 개발 환경을 한 번 정리하고 싶었던 초중급 Java 개발자
#### 준비물과 권장 기준

##### 필수 준비물

- JDK 21
- IntelliJ IDEA 또는 VS Code
- Git
- Maven Wrapper가 포함된 Spring Boot 프로젝트
##### 권장 기준

- 현재 실습 저장소 기준은 **Java 21**입니다.
- 일반적인 Spring Boot 예제는 Java 17에서도 많이 동작하지만, 저장소 기준 버전과 다르면 작은 설정 차이로 시간을 낭비할 수 있습니다.
- 가능하면 실습 저장소의 기준 버전에 맞추는 편이 좋습니다.
#### 1. JDK를 먼저 맞추는 이유

Spring 실습에서 가장 먼저 확인해야 할 것은 IDE가 아니라 **JDK 버전**입니다. 컴파일러와 런타임 버전이 다르면 애플리케이션이 실행되지 않거나, Lombok과 같은 도구가 이상하게 동작할 수 있습니다.

##### 확인 명령

```bash
java -version
javac -version
```

##### 체크 포인트

- `java`와 `javac`가 같은 버전을 가리키는지 확인합니다.
- IDE 내부 JDK와 터미널 JDK가 서로 다른 경우가 많으므로 둘 다 점검합니다.
- macOS, Windows, Linux 모두 `JAVA_HOME`과 PATH가 일관되게 잡혀 있는지 확인합니다.
#### 2. IDE는 왜 IntelliJ IDEA를 우선 추천하는가

VS Code로도 실습은 가능하지만, 초중급 개발자에게는 **프로젝트 구조를 눈으로 파악하기 쉬운 도구**가 더 유리합니다. Spring Boot 학습 초반에는 빠른 편집보다 구조 이해가 더 중요하므로 IntelliJ IDEA가 보통 더 적합합니다.

##### 추천 플러그인

- Lombok
- Spring Boot
- Spring Data
##### IDE에서 확인할 설정

- Project SDK가 JDK 21로 지정되어 있는지 확인합니다.
- Annotation Processing이 활성화되어 있는지 확인합니다.
- Maven 프로젝트가 정상적으로 import 되었는지 확인합니다.
#### 3. 프로젝트 생성보다 먼저 알아야 할 것

Spring Initializr로 프로젝트를 만드는 것은 어렵지 않습니다. 하지만 더 중요한 것은 **왜 그 의존성을 넣는지 이해하는 것**입니다. 의존성을 무작정 많이 넣으면 초반 학습 범위가 불필요하게 넓어집니다.

##### 권장 기본 설정

- Project: Maven
- Language: Java
- Packaging: Jar
- Java: 21
##### 초반 학습용 권장 의존성

- Spring Web
- Spring Data JPA
- Validation
- H2 Database
- Lombok
- Spring Boot Starter Test
##### 왜 이 조합이 적절한가

- `Spring Web`: HTTP 요청과 컨트롤러 흐름을 이해하기 좋습니다.
- `Spring Data JPA`: 엔티티, 리포지토리, 트랜잭션 개념을 함께 익힐 수 있습니다.
- `Validation`: 요청 검증을 일찍 경험할 수 있습니다.
- `H2 Database`: 로컬에서 빠르게 실습하기 좋습니다.
- `Spring Boot Starter Test`: 테스트 습관을 초반부터 잡을 수 있습니다.
#### 4. 프로젝트 구조는 어디까지 먼저 이해하면 되는가

초반에는 모든 패키지와 설정을 한 번에 이해하려고 하지 않는 편이 좋습니다. 먼저 아래 네 가지 위치만 익혀도 실습을 시작하는 데 충분합니다.

```plain text
src/main/java
src/main/resources
src/test/java
pom.xml
```

##### 의미

- `src/main/java`: 애플리케이션 코드가 들어갑니다.
- `src/main/resources`: 설정 파일과 리소스가 들어갑니다.
- `src/test/java`: 테스트 코드가 들어갑니다.
- `pom.xml`: 의존성과 빌드 설정이 들어갑니다.
##### 초반에 특히 눈여겨볼 것

- `application.yml` 또는 `application.properties`
- 메인 애플리케이션 클래스
- 가장 단순한 Controller 또는 Test 코드
#### 5. 실행 전에 반드시 확인할 설정

프로젝트를 바로 실행하기 전에, 어떤 프로파일과 어떤 데이터베이스를 바라보는지 먼저 확인해야 합니다. 이 저장소는 추상적인 `local/dev` 설명보다, **실제 ****`application-*.yml`**** 파일과 활성 프로파일 이름**을 기준으로 읽는 편이 정확합니다.

##### 이 저장소에서 먼저 볼 파일

- `src/main/resources/application.yml`
- `src/main/resources/application-h2.yml`
- `src/main/resources/application-dev-my.yml`
- `src/main/resources/application-dev-pg.yml`
- `src/main/resources/application-prod.yml`
##### 우선 확인할 항목

- 서버 포트
- 기본 활성 프로파일이 무엇인지
- 현재 실행이 `h2`, `dev-my`, `dev-pg`, `prod` 중 어느 환경인지
- 데이터베이스 URL과 계정 정보가 파일 고정값인지 환경변수 주입인지
- JPA SQL 로그와 DDL 전략이 어떤 값으로 설정되어 있는지
##### 왜 중요한가

- 포트 충돌은 가장 흔한 실행 실패 원인입니다.
- 프로파일이 다르면 같은 코드도 완전히 다르게 동작합니다.
- 데이터베이스 설정을 모르면 오류 메시지를 읽어도 원인을 찾기 어렵습니다.
- `create-drop`, `update`, `validate` 같은 전략은 환경 목적과 함께 읽어야 의미가 맞습니다.
#### 6. 첫 실행은 어떻게 해야 하는가

첫 실행의 목표는 기능 확인이 아니라 **애플리케이션이 정상적으로 뜨는지 확인하는 것**입니다. 처음부터 API 호출과 DB 저장까지 다 보려고 하면 문제 범위가 너무 넓어집니다.

##### 실행 명령

```bash
./mvnw spring-boot:run
```

이 저장소는 기본 활성 프로파일이 `h2`이므로, 위 명령은 별도 옵션이 없으면 H2 환경으로 실행됩니다.

필요하면 아래처럼 프로파일을 명시해서 실행할 수 있습니다.

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev-my
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev-pg
```

##### 첫 실행에서 볼 것

- 애플리케이션이 예외 없이 기동되는지
- 내장 서버가 지정한 포트에서 뜨는지
- DB 연결 오류가 없는지
- 현재 프로파일에 맞는 설정이 실제로 반영되는지
- Swagger나 가장 단순한 엔드포인트로 기본 응답을 확인할 수 있는지

---

## 5.2 Maven 환경 구성과 프로젝트 전환

#### 개요

이 문서는 Java 학습 환경을 `javac` 중심의 수동 실행에서 `Maven` 기반 프로젝트 구조로 전환할 때 필요한 흐름을 정리한 가이드입니다. 초중급 Java 개발자에게는 빌드 도구를 이해하는 시점이 중요합니다. Maven을 도입하면 의존성 관리, 표준 디렉터리 구조, 테스트 실행, 패키징 과정을 한 번에 통일할 수 있습니다.

#### 왜 중요한가

- 프로젝트 구조가 팀 단위로 일관됩니다.
- 라이브러리 버전을 직접 관리하지 않아도 됩니다.
- 테스트와 빌드 명령을 반복 가능한 형태로 고정할 수 있습니다.
- 이후 Spring Boot, JUnit, Querydsl 같은 도구를 붙이기 쉬워집니다.
#### 대상 독자

- Java 프로젝트를 IDE에서만 실행해본 개발자
- `pom.xml`이 무엇을 하는지 아직 감이 약한 개발자
- 기존 수동 구조를 Maven 표준 구조로 옮기고 싶은 개발자
#### 준비물

- JDK 설치 및 `JAVA_HOME` 설정
- 터미널 또는 명령 프롬프트 사용 가능 환경
- IntelliJ IDEA 또는 VS Code
#### Maven 설치와 확인

##### 설치

- 공식 사이트에서 바이너리를 내려받아 압축을 해제합니다.
- Windows는 `MAVEN_HOME`, macOS 또는 Linux는 셸 환경 변수에 Maven 경로를 설정합니다.
- `PATH`에 Maven의 `bin` 경로를 추가합니다.
##### 확인

```bash
mvn -version
```

```plain text
예상 결과
- Apache Maven 버전이 표시됩니다.
- Java version 항목이 함께 표시됩니다.
- Maven home 또는 실행 경로가 표시됩니다.
```

정상이라면 Maven 버전, Java 버전, 실행 경로가 함께 출력됩니다.

#### 이번 원고에서 Maven을 읽는 기준

이 원고는 Maven을 하나의 프로젝트에만 묶어서 설명하지 않습니다.

##### `day_by_spring`

- Maven Wrapper(`./mvnw`)를 사용합니다.
- 팀 단위로 Maven 버전을 통일하고 싶을 때 더 적합합니다.
##### `day-by-java`

- 현재는 Wrapper 없이 `pom.xml` 중심의 예제 프로젝트입니다.
- 따라서 시스템에 설치된 `mvn` 명령으로 실행하는 전통적인 Maven 흐름을 보기 좋습니다.
즉, 책에서는 **실무형 저장소는 Wrapper 중심**, **예제형 저장소는 기본 Maven 구조 이해용**으로 구분해서 설명하는 편이 자연스럽습니다.

#### Maven 프로젝트 구조 이해하기

Maven은 아래 구조를 기본으로 사용합니다.

```plain text
project-root
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   └── resources
    └── test
        ├── java
        └── resources
```

이 구조를 이해하면 소스 코드, 설정 파일, 테스트 코드의 위치가 자연스럽게 정리됩니다.

#### 새 프로젝트를 Maven으로 시작하기

가장 단순한 예시는 archetype 기반 생성입니다.

```bash
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=myapp \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
```

이 방식은 학습용으로 유용하지만, 실무에서는 Spring Initializr나 팀 템플릿을 더 자주 사용합니다.

#### 기존 프로젝트를 Maven 구조로 옮기기

##### 1. 디렉터리부터 정리하기

- 기존 `src` 아래 Java 파일은 `src/main/java`로 이동합니다.
- 설정 파일은 `src/main/resources`로 이동합니다.
- 테스트 코드는 `src/test/java`로 분리합니다.
##### 2. `pom.xml` 작성하기

`pom.xml`은 이 프로젝트의 빌드 규칙과 의존성을 설명하는 문서입니다.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>myapp</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
</project>
```

지금 저장소 기준으로는 Java 21과 Maven Wrapper를 쓰는 방식이 더 자연스럽습니다.

#### 자주 쓰는 Maven 명령

##### Wrapper가 있는 프로젝트 (`day_by_spring`)

```bash
./mvnw clean compile
./mvnw test
./mvnw clean package
```

```plain text
예상 결과
- `compile`: `target/classes` 아래에 컴파일 결과가 생성됩니다.
- `test`: 테스트 리포트와 함께 성공/실패 여부가 출력됩니다.
- `package`: `target/` 아래에 실행 가능한 JAR이 생성됩니다.
```

##### 시스템 Maven을 쓰는 프로젝트 (`day-by-java`)

```bash
mvn clean compile
mvn test
mvn package
```

```plain text
예상 결과
- `compile`: 소스 코드가 컴파일되고 문법 오류가 있으면 여기서 실패합니다.
- `test`: 테스트가 있으면 실행되고, 없으면 빌드 흐름만 계속 진행됩니다.
- `package`: JAR 산출물이 생성됩니다.
```

- `compile`: 컴파일만 수행합니다.
- `test`: 테스트를 실행합니다.
- `package`: JAR 또는 WAR 같은 산출물을 만듭니다.
#### 기존 방식과 무엇이 달라지는가

##### Before

- 클래스 경로를 직접 잡아야 했습니다.
- 라이브러리를 수동으로 추가했습니다.
- 프로젝트 구조가 사람마다 달랐습니다.
##### After

- 표준 디렉터리 구조를 따릅니다.
- 의존성과 플러그인을 `pom.xml`에서 관리합니다.
- 빌드와 테스트가 명령 한 줄로 재현됩니다.
#### 자주 하는 실수

- `JAVA_HOME`은 맞는데 `PATH`에 Maven이 빠져 있는 경우
- `src/main/resources` 대신 Java 코드 옆에 설정 파일을 두는 경우
- Java 버전과 `pom.xml`의 컴파일 버전이 다른 경우
- `mvn`만 믿고 Wrapper(`./mvnw`)를 쓰지 않아 팀 환경이 갈리는 경우
#### 정리

Maven은 단순한 라이브러리 다운로드 도구가 아니라, Java 프로젝트의 구조와 실행 방식을 표준화하는 핵심 도구입니다. 학습 단계에서 Maven 구조를 익혀두면 Spring Boot 프로젝트를 다룰 때도 훨씬 수월해집니다.

#### 한 줄 정리

Maven 도입의 핵심은 빌드 명령 하나가 아니라, 프로젝트 구조와 협업 방식을 표준화하는 데 있습니다.


---

## 5.0 Spring 핵심 개념: IoC, DI, Bean, MVC

#### 개요

이 문서는 Java와 객체지향 기초를 마친 독자가 Spring 프로젝트로 넘어가기 전에 잡아야 할 공통 개념을 정리한 본문 가이드입니다.

#### 1. IoC와 DI는 무엇이 다른가

`IoC`는 객체 생성과 연결의 제어권을 코드 바깥으로 넘기는 관점이고, `DI`는 그 제어를 실제 코드에서 구현하는 대표적인 방법입니다.

```java
@Service
public class OrderService {
    private final PaymentClient paymentClient;

    public OrderService(PaymentClient paymentClient) {
        this.paymentClient = paymentClient;
    }
}
```

- IoC: 누가 객체를 만들고 연결할 것인가
- DI: 그 객체를 생성자나 메서드로 주입하는 방식

#### 2. 왜 생성자 주입을 기본값으로 두나

- 의존성이 드러납니다.
- `final`로 불변성을 유지하기 쉽습니다.
- 테스트에서 직접 객체를 만들기 쉽습니다.

Spring을 배우는 핵심은 어노테이션을 많이 외우는 것이 아니라, **객체 그래프를 명시적으로 설계하는 감각**을 익히는 데 있습니다.

#### 3. Bean과 컨테이너는 어떻게 보나

`@Component`, `@Service`, `@Repository`, `@Controller`로 등록된 객체는 보통 Spring 컨테이너가 관리하는 `Bean`입니다.

- 대부분 기본 스코프는 싱글톤입니다.
- 그래서 Bean 안에 가변 상태를 오래 들고 있으면 동시성 문제가 생길 수 있습니다.
- 직접 싱글톤 패턴을 구현하는 것보다, Spring의 Bean 생명주기를 이해하는 편이 더 중요합니다.

#### 4. MVC는 무엇을 나누는가

Spring MVC는 `DispatcherServlet`을 중심으로 요청을 받고, 컨트롤러에 연결하고, 응답을 조립합니다.

- Controller: HTTP 계약
- Service: 유스케이스 조율
- Repository: 데이터 접근
- DTO: 요청/응답 형태 분리

MVC를 본다는 것은 화면 기술을 보는 것이 아니라, **웹 요청을 어디서 끊어 책임을 나누는지** 보는 것입니다.

#### 5. AOP와 프록시는 왜 자꾸 같이 나오나

트랜잭션, 로깅, 보안은 비즈니스 메서드마다 반복되기 쉽습니다. Spring은 프록시 기반 AOP로 이런 공통 관심사를 분리합니다.

여기서 중요한 것은 `@Transactional`을 외우는 것이 아니라, **실제 메서드 호출 앞뒤에 부가 동작이 끼어들 수 있다**는 프록시 모델을 이해하는 것입니다.

#### 한 줄 정리

Spring 핵심 개념의 핵심은 **어노테이션 이름**보다, **객체 생성과 요청 흐름과 공통 관심사를 어떻게 분리하는지 이해하는 것**입니다.

---

