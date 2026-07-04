---
title: "Java 스터디 — Spring과 프로젝트 실행"
type: source
tags: [java, study, ch06]
sources: [java-study/java-study-ch06-Spring과프로젝트실행.md]
created: 2026-04-18
updated: 2026-07-04
---

# Spring과 프로젝트 실행

## 🎯 이 장에서 배우는 것

- IoC·DI·Bean·MVC로 객체 조립을 컨테이너에 위임
- 실습 환경·Maven·프로파일 구성
- 스프링 부트 프로젝트를 직접 띄우기

**단계**: 2단계 — Spring & 웹 백엔드 · **앞 장**: [[java-study-ch05]] · **다음 장**: [[java-study-ch07]]

> **따라 하는 법**: 위에서 아래로 읽으며 코드를 직접 쳐본다. 환경 세팅을 그대로 따라 하고, 빈 주입을 직접 코드로 확인한다. 깊이: [[concept-spring-core]].

> **실습 프로젝트**: 이 챕터의 실습은 **6.1에서 start.spring.io로 만드는 `demo` 프로젝트**에서 진행합니다. ch07~08·10의 Spring 실습도 같은 `demo`를 이어서 씁니다. 본문에 가끔 나오는 실무 프로젝트 이야기는 필자의 실무 저장소 참고 사례일 뿐, 실습에 필요하지 않습니다.

---

## 6.0 Spring 핵심 개념: IoC, DI, Bean, MVC

**🎯 목표**: IoC·DI·Bean·MVC로 객체 조립을 컨테이너에 맡기는 개념을 잡는다.

### 개요
이 문서는 Java와 객체지향 기초를 마친 독자가 Spring 프로젝트로 넘어가기 전에 잡아야 할 공통 개념을 정리한 본문 가이드입니다. 뒤 장에서 환경 구성, 데이터 접근, 보안, 테스트를 각각 다루기 전에, 여기서 IoC, DI, Bean, MVC, 프록시 같은 핵심 축을 먼저 연결합니다.

### 1. IoC와 DI는 무엇이 다른가
`IoC`는 객체 생성과 연결의 제어권을 코드 바깥으로 넘기는 관점이고, `DI`는 그 제어를 실제 코드에서 구현하는 대표적인 방법입니다. (참고 코드 — 생성자 주입 형태를 보여주는 개념 예시입니다. 클래스 위 `@Service`는 아래 3에서 다루는 Bean 등록 표기입니다.)
```java
@Service
public class OrderService {
    private final PaymentClient paymentClient;

    public OrderService(PaymentClient paymentClient) {
        this.paymentClient = paymentClient;
    }
}
```
핵심은 `new PaymentClient()`를 직접 호출하지 않고, 외부에서 준비된 객체를 받는다는 점입니다.

- IoC: 누가 객체를 만들고 연결할 것인가
- DI: 그 객체를 생성자나 메서드로 주입하는 방식

### 2. 왜 생성자 주입을 기본값으로 두나
Spring에서는 필드 주입도 가능하지만, 기본값은 생성자 주입이 더 낫습니다.

- 의존성이 드러납니다.
- `final`로 불변성을 유지하기 쉽습니다.
- 테스트에서 직접 객체를 만들기 쉽습니다.
즉 Spring을 배우는 핵심은 어노테이션을 많이 외우는 것이 아니라, **객체 그래프를 명시적으로 설계하는 감각**을 익히는 데 있습니다.

### 3. Bean과 컨테이너는 어떻게 보나
`@Component`, `@Service`, `@Repository`, `@Controller`로 등록된 객체는 보통 Spring 컨테이너가 관리하는 `Bean`입니다. (참고 코드 — Bean 등록을 보여주는 개념 예시입니다.)
```java
@Service
public class BookService {
}
```
여기서 중요한 점은 다음입니다.

- 대부분 기본 스코프는 싱글톤입니다.
- 그래서 Bean 안에 가변 상태를 오래 들고 있으면 동시성 문제가 생길 수 있습니다.
- 직접 싱글톤 패턴을 구현하는 것보다, Spring의 Bean 생명주기를 이해하는 편이 더 중요합니다.

### 4. MVC는 무엇을 나누는가
Spring MVC는 `DispatcherServlet`을 중심으로 요청을 받고, 컨트롤러에 연결하고, 응답을 조립합니다.

- Controller: HTTP 계약
- Service: 유스케이스 조율
- Repository: 데이터 접근
- DTO: 요청/응답 형태 분리
즉 MVC를 본다는 것은 화면 기술을 보는 것이 아니라, **웹 요청을 어디서 끊어 책임을 나누는지** 보는 것입니다.

### 5. AOP와 프록시는 왜 자꾸 같이 나오나
트랜잭션, 로깅, 보안은 비즈니스 메서드마다 반복되기 쉽습니다. Spring은 프록시 기반 AOP로 이런 공통 관심사를 분리합니다. (참고 코드 — 메서드에 트랜잭션 처리를 입히는 `@Transactional` 개념 예시입니다.)
```java
@Transactional
public void placeOrder(CreateOrderRequest request) {
    // 핵심 비즈니스 로직
}
```
여기서 중요한 것은 `@Transactional`을 외우는 것이 아니라, **실제 메서드 호출 앞뒤에 부가 동작이 끼어들 수 있다**는 프록시 모델을 이해하는 것입니다.

### 6. Spring을 어떤 순서로 읽는 게 좋은가
이 저장소 기준으로는 아래 흐름이 자연스럽습니다. 각 항목은 대부분 이 원고 뒤 절의 제목입니다 — 환경 구성은 바로 다음 6.1, Tomcat과 Security는 ch08, 테스트 전략은 ch09에서 만나므로, 여기서는 읽기 순서만 눈에 담아 두면 됩니다.

- `Spring 실습 환경 구성 가이드`: 실행 준비
- `Local Docker Deployment Guide`: Docker 기반 로컬 실행이 필요할 때 보는 보조 문서
- `Tomcat 실행과 설정`: 요청이 어디서 시작되는가
- `Spring Security 인증 흐름`: 필터 체인과 인증
- `Spring Security 용어 정리`: 용어 정리
- `Spring Boot 테스트 전략`: 테스트 계층 구분
- `Swagger 설정 가이드`: API 문서화
즉 Spring 전체를 한 장에서 끝내려 하기보다, **실제 관심사마다 필요한 조각을 읽는 구조**가 더 낫습니다.

### 7. 자주 헷갈리는 연결점
- IoC와 DIP는 다릅니다. DIP는 추상화 의존 원칙이고, IoC는 생성 제어의 위치 문제입니다.
- Bean 싱글톤과 디자인 패턴 싱글톤은 같은 단어를 쓰지만 관심사가 다릅니다.
- MVC와 REST는 같은 개념이 아닙니다. MVC는 구조, REST는 HTTP 설계 관점입니다.
- AOP를 이해하면 `@Transactional`, 보안 프록시, 로깅 설계가 함께 보이기 시작합니다.

### 한 줄 정리
Spring 핵심 개념의 핵심은 **어노테이션 이름**보다, **객체 생성과 요청 흐름과 공통 관심사를 어떻게 분리하는지 이해하는 것**입니다.

### ✏️ Spring 핵심 개념 직접 해보기

두 클래스를 생성자 주입으로 연결한 빈을 만들어 컨테이너가 주입하는지 확인하라.

!!! example "실습 순서"

    1. **파일 생성** — `demo` 프로젝트에 `src/main/java/com/example/demo/ch06/di/MessageProvider.java`와 `src/main/java/com/example/demo/ch06/di/MessageClient.java`를 만듭니다. 아직 `demo` 프로젝트가 없으면 6.1을 먼저 진행합니다.
    2. **뼈대 입력** — 아래 뼈대 두 개를 그대로 입력합니다.

        **파일**: `src/main/java/com/example/demo/ch06/di/MessageProvider.java`

        ```java
        package com.example.demo.ch06.di;

        import org.springframework.stereotype.Component;

        @Component
        public class MessageProvider {
            // 1) getMessage() — "DI가 연결한 메시지" 문자열을 반환하는 메서드 추가
        }
        ```

        **파일**: `src/main/java/com/example/demo/ch06/di/MessageClient.java`

        ```java
        package com.example.demo.ch06.di;

        import org.springframework.stereotype.Component;

        @Component
        public class MessageClient {

            private final MessageProvider messageProvider;

            public MessageClient(MessageProvider messageProvider) {
                this.messageProvider = messageProvider;
                System.out.println("MessageClient 생성 — 주입 확인");
                // 2) messageProvider.getMessage() 결과를 출력해 주입된 빈이 동작하는지 확인
            }
        }
        ```

    3. **하나씩 구현** — 주석의 과제를 한 항목씩 구현합니다.
    4. **실행·확인** — `./mvnw spring-boot:run` — 시작 로그에 "MessageClient 생성 — 주입 확인"이 찍히는지 확인합니다. — 추가할 때마다 다시 실행해 출력을 확인합니다.


## 6.1 Spring 실습 환경 구성 가이드

**🎯 목표**: 스프링 실습 환경을 구성해 첫 애플리케이션을 띄운다.

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
- Maven Wrapper가 포함된 Spring Boot 프로젝트 — 아래 3에서 start.spring.io로 직접 만듭니다
##### 권장 기준

- 현재 실습 저장소 기준은 **Java 21**입니다.
- 일반적인 Spring Boot 예제는 Java 17에서도 많이 동작하지만, 저장소 기준 버전과 다르면 작은 설정 차이로 시간을 낭비할 수 있습니다.
- 가능하면 실습 저장소의 기준 버전에 맞추는 편이 좋습니다.
#### 1. JDK를 먼저 맞추는 이유

Spring 실습에서 가장 먼저 확인해야 할 것은 IDE가 아니라 **JDK 버전**입니다. 컴파일러와 런타임 버전이 다르면 애플리케이션이 실행되지 않거나, Lombok(getter·생성자 같은 반복 코드를 어노테이션으로 자동 생성해 주는 라이브러리)과 같은 도구가 이상하게 동작할 수 있습니다.

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

Spring Initializr(start.spring.io — 스프링 부트 프로젝트 뼈대를 만들어 주는 공식 생성 도구)로 프로젝트를 만드는 것은 어렵지 않습니다. 하지만 더 중요한 것은 **왜 그 의존성을 넣는지 이해하는 것**입니다. 의존성을 무작정 많이 넣으면 초반 학습 범위가 불필요하게 넓어집니다.

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
- `Spring Data JPA`: 엔티티, 리포지토리, 트랜잭션 개념을 함께 익힐 수 있습니다. (JPA 자체는 ch07에서 자세히 다룹니다)
- `Validation`: 요청 검증을 일찍 경험할 수 있습니다.
- `H2 Database`: 별도 설치 없이 메모리에서 도는 경량 DB라 로컬에서 빠르게 실습하기 좋습니다.
- `Spring Boot Starter Test`: 테스트 습관을 초반부터 잡을 수 있습니다.

##### 실제로 프로젝트 만들기 (start.spring.io)

권장 의존성 그대로 프로젝트를 생성합니다. 여기서 만드는 `demo`가 이후 Spring 챕터(ch07~08·10)까지 이어 쓰는 기준 프로젝트입니다. 명령으로 한 번 만들어 보면 구조가 눈에 들어옵니다.

```bash
# start.spring.io에 요청해 zip으로 받아 푼다 (한 줄)
curl https://start.spring.io/starter.zip -d type=maven-project -d language=java -d javaVersion=21 -d groupId=com.example -d artifactId=demo -d dependencies=web,data-jpa,validation,h2,lombok -o demo.zip
unzip demo.zip -d demo
cd demo
```

> **Windows**: PowerShell의 `curl`은 별칭이라 위 문법이 안 먹습니다. **`curl.exe`**로 명시하거나, 브라우저에서 [start.spring.io](https://start.spring.io) → 의존성 선택 → **Generate**로 zip을 받아 풉니다. (IDE 대안: IntelliJ *File › New › Project › Spring Boot*)

생성된 프로젝트에는 래퍼(`mvnw`·`mvnw.cmd`)가 포함되어 있어, Maven을 따로 설치하지 않아도 `./mvnw`로 빌드·실행할 수 있습니다.

#### 4. 프로젝트 구조는 어디까지 먼저 이해하면 되는가

초반에는 모든 패키지와 설정을 한 번에 이해하려고 하지 않는 편이 좋습니다. 먼저 아래 네 가지 위치만 익혀도 실습을 시작하는 데 충분합니다.

```text
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

프로젝트를 바로 실행하기 전에, 어떤 프로파일과 어떤 데이터베이스를 바라보는지 먼저 확인해야 합니다. 추상적인 `local/dev` 설명보다, **실제 `application-*` 파일과 활성 프로파일 이름**을 기준으로 읽는 편이 정확합니다.

##### demo 프로젝트에서 먼저 볼 파일

- `src/main/resources/application.properties` — 갓 만든 `demo`에는 설정 파일이 이것 하나뿐이고, 내용은 비어 있습니다.
- 6.3에서 이 파일을 `application.yml`로 바꾸고, `application-h2.yml` 같은 프로파일별 파일을 직접 만들어 확장합니다.

> **참고 — 실제 프로젝트에서는**: 필자의 실무 저장소처럼 `application-h2.yml`·`application-dev-my.yml`·`application-dev-pg.yml`·`application-prod.yml`을 두고 환경마다 골라 실행하는 구조가 일반적입니다. 6.3에서 같은 구조를 `demo`에 그대로 만들어 봅니다.

##### 우선 확인할 항목

- 서버 포트
- 기본 활성 프로파일이 무엇인지 (설정이 없으면 `default`)
- 현재 실행이 어느 프로파일 환경인지 — 6.3에서 `h2`, `dev-my`, `dev-pg`, `prod`를 만든 뒤부터 의미가 생깁니다
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
./mvnw spring-boot:run        # Windows: mvnw.cmd spring-boot:run
```

- 이 명령은 **포그라운드로 서버를 붙잡습니다** — 종료는 `Ctrl+C`. curl 등 다른 명령은 새 터미널에서 실행합니다.
- 갓 만든 `demo`는 프로파일 설정이 없으므로 `default` 프로파일로 뜨고, 클래스패스의 H2 의존성 덕분에 인메모리 H2가 자동 구성됩니다.
- 로그에 `Tomcat started on port 8080` / `Started ...Application in N seconds`가 출력되면 정상입니다. 새 터미널에서 아래 명령으로 확인합니다.

```bash
# 새 터미널에서 — 아직 매핑한 API가 없으면 Whitelabel Error Page(404)가 떠도 정상(서버는 떠 있다는 뜻)
curl -i http://localhost:8080/
```

6.3에서 프로파일 파일을 만들고 나면, 아래처럼 프로파일을 명시해서 실행할 수 있습니다.

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
- 가장 단순한 요청(위 `curl -i http://localhost:8080/`)으로 기본 응답을 확인할 수 있는지

##### 기동 로그로 성공 확인하기

정상 기동하면 콘솔에 Spring 배너(ASCII 아트 로고)가 먼저 찍히고, 마지막에 `Started DemoApplication ...` 줄이 나옵니다. 이 마지막 줄이 기동 완료 신호입니다. 배너의 버전과 초 단위 숫자는 생성 시점·PC 성능에 따라 다릅니다.

```text
예상 결과
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::               (v3.5.5)

Tomcat started on port 8080 (http) with context path '/'
Started DemoApplication in 3.x seconds (process running for 4.x)
```

> **참고 — 실무 프로젝트라면**: springdoc 같은 API 문서화 의존성이 있는 저장소에서는 기동 확인 후 `http://localhost:8080/swagger-ui.html`로 접속해 Swagger UI(API 문서 화면)가 열리는지도 함께 봅니다. 우리 `demo`에는 그 의존성이 없으므로 위 `curl` 확인이면 충분합니다.

#### 7. 테스트 실행은 왜 바로 해봐야 하는가

애플리케이션이 실행되더라도 테스트가 실패한다면 개발 환경이 완전히 준비된 것은 아닙니다. 테스트는 실행 환경과 빌드 환경이 함께 맞는지를 확인하는 가장 좋은 기준입니다. `demo`에는 start.spring.io가 만들어 준 테스트가 이미 하나 들어 있어(`src/test/java`의 `DemoApplicationTests` — 스프링 설정 전체를 실제로 로드해 보는 `contextLoads` 테스트), 코드를 따로 쓰지 않아도 바로 돌려볼 수 있습니다.

##### 실행 명령

```bash
./mvnw test        # Windows: mvnw.cmd test
```

```text
예상 결과
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

##### 여기서 확인할 것

- 테스트가 JDK 버전 문제 없이 실행되는지
- Maven 의존성이 정상적으로 내려받아졌는지
- 스프링 컨텍스트가 온전히 뜨는지 — 6.3에서 프로파일 파일을 만든 뒤에는 이 테스트가 그 설정이 깨지지 않았는지도 함께 걸러 줍니다

#### 8. 초중급 개발자가 자주 막히는 지점

경험상 첫 실행 실패의 대부분은 아래 다섯 가지 중 하나입니다. 증상별 확인 방법을 표로 정리합니다.

| 막히는 지점 | 확인·해결 |
|------------|----------|
| 터미널의 JDK와 IDE의 JDK가 다름 | `java -version`(터미널)과 IDE의 Project SDK(위 2)를 비교해 하나로 맞춥니다 |
| Lombok annotation processing 비활성화 | IntelliJ *Settings › Build › Compiler › Annotation Processors*에서 활성화합니다 (위 2의 확인 설정) |
| 8080 포트가 이미 사용 중 | 앞서 띄워 둔 서버를 `Ctrl+C`로 내리거나, `lsof -i :8080`(Windows: `netstat -ano \| findstr 8080`)으로 점유 프로세스를 찾아 종료합니다 |
| 설정 파일의 DB 설정이 현재 환경과 안 맞음 | 갓 만든 `demo`는 H2 자동 구성이라 해당 없음 — 6.3에서 프로파일 파일을 만든 뒤부터 생기는 문제이므로, 그때는 6.3의 "자주 나는 에러 → 원인" 표를 봅니다 |
| Maven import가 끝나기 전에 실행 시도 | IDE 우측 하단 진행 표시(의존성 내려받기·인덱싱)가 끝날 때까지 기다린 뒤 실행합니다 |

#### 자주 하는 실수

- JDK 버전 확인 없이 예제 코드를 바로 실행하는 것
- IDE 오류를 무시한 채 애플리케이션 재실행만 반복하는 것
- 실행만 되면 환경이 끝났다고 생각하고 테스트를 건너뛰는 것
- 로컬 환경과 프로젝트 기준 버전이 다른데 그냥 진행하는 것

#### 환경 준비 체크리스트

아래 다섯 항목이 모두 통과하면 이 절의 목표는 달성입니다.

- [ ] JDK 21이 설치되어 있고 `java -version`으로 확인했다
- [ ] IDE Project SDK가 올바르게 설정되어 있다
- [ ] Lombok과 Maven import가 정상 동작한다
- [ ] `./mvnw spring-boot:run`이 실행된다
- [ ] `./mvnw test`가 통과한다

---

### ✏️ Spring 실습 환경 구성 가이드 직접 해보기

Spring Initializr로 프로젝트를 만들어 내장 톰캣으로 실행해 보라.

!!! example "실습 순서"

    1. **프로젝트 생성** — 위 6.1 절차대로 start.spring.io에서 `demo` 프로젝트를 만들어 내려받고 압축을 풉니다.
    2. **실행** — `demo` 프로젝트 루트에서 `./mvnw spring-boot:run`
    3. **확인** — 시작 로그에서 Tomcat이 8080 포트로 뜨는지 확인합니다.

#### 정리

환경 설정은 화려한 작업이 아니지만, 이후 학습 속도와 문제 해결 난도를 크게 좌우합니다. 초반에는 기능을 많이 넣는 것보다 문제가 생겼을 때 어디를 확인해야 하는지 아는 환경을 만드는 것이 더 중요합니다.

#### 한 줄 정리

Spring 학습 초반에는 코드를 많이 쓰는 것보다, JDK·IDE·빌드·실행·테스트가 한 번에 이어지는 로컬 환경을 먼저 안정화하는 것이 우선입니다.

## 6.2 Maven 환경 구성과 프로젝트 전환

**🎯 목표**: Maven으로 의존성·빌드를 관리한다.

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

```text
예상 결과
- Apache Maven 버전이 표시됩니다.
- Java version 항목이 함께 표시됩니다.
- Maven home 또는 실행 경로가 표시됩니다.
```

정상이라면 Maven 버전, Java 버전, 실행 경로가 함께 출력됩니다.

#### 이번 원고에서 Maven을 읽는 기준

이 원고는 Maven을 하나의 프로젝트에만 묶어서 설명하지 않습니다.

##### Wrapper 방식 — 6.1에서 만든 `demo`

- start.spring.io가 넣어 준 Maven Wrapper(`./mvnw`)를 사용합니다.
- 팀 단위로 Maven 버전을 통일하고 싶을 때 더 적합합니다.
##### 시스템 Maven 방식 — 아래 archetype으로 만드는 `myapp`

- Wrapper 없이 `pom.xml` 중심의 예제 프로젝트입니다.
- 따라서 시스템에 설치된 `mvn` 명령으로 실행하는 전통적인 Maven 흐름을 보기 좋습니다.
즉, **실습 프로젝트(`demo`)는 Wrapper 중심**, **기본 Maven 구조 이해용(`myapp`)은 시스템 Maven**으로 구분해서 보면 자연스럽습니다.

> **참고 — 실제 프로젝트에서는**: 필자의 저장소도 같은 구분입니다. Spring 서비스 저장소는 Wrapper를 커밋해 두어 팀원 모두 같은 Maven 버전으로 빌드하고, 순수 Java 예제 저장소는 시스템 `mvn`으로 실행합니다.

#### Maven 프로젝트 구조 이해하기

Maven은 아래 구조를 기본으로 사용합니다.

```text
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

가장 단순한 예시는 archetype(Maven이 제공하는 프로젝트 템플릿) 기반 생성입니다.

```bash
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=myapp \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
```

> **Windows**: 줄 끝 `\`(줄바꿈 잇기)는 bash 전용입니다. cmd에서는 `^`, PowerShell에서는 백틱(`` ` ``)을 쓰거나, **한 줄로 붙여서** 실행합니다.

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

##### 의존성 추가 예시

라이브러리는 `pom.xml`의 `<dependencies>`에 좌표를 적으면 자동으로 받아집니다. 예를 들어 `commons-lang3`을 추가하려면 `</properties>` 다음에 아래처럼 작성합니다.

```xml
<dependencies>
  <dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
    <version>3.14.0</version>
  </dependency>
</dependencies>
```

반영됐는지는 다음 명령으로 확인합니다. (`myapp`처럼 Wrapper가 없으면 `mvn`, 6.1의 `demo`처럼 Wrapper가 있으면 `./mvnw`)

```bash
mvn dependency:tree | grep commons-lang3    # Windows: mvn dependency:tree | findstr commons-lang3
```

#### 자주 쓰는 Maven 명령

##### Wrapper가 있는 프로젝트 (6.1의 `demo`)

```bash
./mvnw clean compile
./mvnw test
./mvnw clean package
```

```text
예상 결과
- `compile`: `target/classes` 아래에 컴파일 결과가 생성됩니다.
- `test`: 테스트 리포트와 함께 성공/실패 여부가 출력됩니다.
- `package`: `target/` 아래에 실행 가능한 JAR이 생성됩니다.
```

##### 시스템 Maven을 쓰는 프로젝트 (archetype으로 만든 `myapp`)

```bash
mvn clean compile
mvn test
mvn package
```

```text
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

### ✏️ Maven 환경 구성과 프로젝트 전환 직접 해보기

`pom.xml`에 의존성을 하나 추가하고 빌드해 적용되는지 확인하라.

!!! example "실습 순서"

    1. **파일 열기** — `demo` 프로젝트의 `pom.xml`을 엽니다.
    2. **수정** — `<dependencies>` 안에 의존성(예: `spring-boot-starter-validation`)을 추가합니다.
    3. **재실행** — `./mvnw clean compile` — 새 라이브러리가 내려받아지는지 로그에서 확인합니다.

#### 정리

Maven은 단순한 라이브러리 다운로드 도구가 아니라, Java 프로젝트의 구조와 실행 방식을 표준화하는 핵심 도구입니다. 학습 단계에서 Maven 구조를 익혀두면 Spring Boot 프로젝트를 다룰 때도 훨씬 수월해집니다.

#### 한 줄 정리

Maven 도입의 핵심은 빌드 명령 하나가 아니라, 프로젝트 구조와 협업 방식을 표준화하는 데 있습니다.

---

## 6.3 프로파일 설정 가이드

**🎯 목표**: 프로파일로 dev/prod 환경을 분리한다.

### 개요
이 절은 6.1에서 만든 `demo` 프로젝트에 프로파일 구조를 **직접 만들어 실행**하는 실습 가이드입니다. 추상적인 `local/dev/test/prod` 예시를 외우는 대신, `application-*.yml` 파일을 하나씩 만들고 실행 명령으로 프로파일이 바뀌는 것을 눈으로 확인합니다. 프로파일 이름과 구조는 필자의 실무 프로젝트에서 쓰는 것을 그대로 가져왔습니다.

### 왜 중요한가
Spring Boot는 활성 프로파일에 따라 `application-{profile}.yml`을 함께 읽습니다. 따라서 같은 코드라도 어떤 프로파일로 실행하느냐에 따라 데이터베이스, 로그 레벨, DDL 전략, SQL 출력 방식이 달라질 수 있습니다. 프로파일을 코드와 분리해서 외운다면 실행은 되더라도 왜 그렇게 동작하는지 이해하기 어렵습니다.

### 1. demo에 만들 프로파일 구조
이 절을 마치면 `demo`의 리소스 구성이 아래처럼 됩니다.
```text
src/main/resources/application.yml          # 기본 활성 프로파일 지정
src/main/resources/application-h2.yml       # 로컬 H2 (기본)
src/main/resources/application-dev-my.yml   # 로컬 MySQL
src/main/resources/application-dev-pg.yml   # 로컬 PostgreSQL
src/main/resources/application-prod.yml     # 운영 (환경변수 주입)
```
먼저 갓 만든 `demo`에 있는 빈 `application.properties`를 **삭제**하고, 아래 다섯 파일을 만듭니다.

**파일**: src/main/resources/application.yml
```yaml
spring:
  profiles:
    active: h2
```
기본 활성 프로파일을 `h2`로 지정했으므로, 별도 옵션 없이 실행하면 먼저 H2 환경으로 기동됩니다.

**파일**: src/main/resources/application-h2.yml
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:localdb
    driver-class-name: org.h2.Driver
    username: sa
    password: ""
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  h2:
    console:
      enabled: true
```

**파일**: src/main/resources/application-dev-my.yml
```yaml
spring:
  datasource:
    url: ${DEV_MY_DB_URL:jdbc:mysql://localhost:3306/demo}
    username: ${DEV_MY_DB_USERNAME:root}
    password: ${DEV_MY_DB_PASSWORD:changeme}
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
```

**파일**: src/main/resources/application-dev-pg.yml
```yaml
spring:
  datasource:
    url: ${DEV_PG_DB_URL:jdbc:postgresql://localhost:5432/demo}
    username: ${DEV_PG_DB_USERNAME:postgres}
    password: ${DEV_PG_DB_PASSWORD:changeme}
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
```

**파일**: src/main/resources/application-prod.yml
```yaml
spring:
  datasource:
    url: ${PROD_DB_URL}
    username: ${PROD_DB_USERNAME}
    password: ${PROD_DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
```

`${환경변수:기본값}` 문법은 환경변수가 있으면 그 값을, 없으면 콜론 뒤 기본값을 씁니다. `prod`만 기본값이 없는데, 운영 접속 정보는 파일에 절대 적지 않기 위해서입니다.

마지막으로 MySQL·PostgreSQL 드라이버를 `pom.xml`의 `<dependencies>`에 추가합니다. (6.1의 의존성에는 H2만 있습니다)

```xml
<dependency>
  <groupId>com.mysql</groupId>
  <artifactId>mysql-connector-j</artifactId>
  <scope>runtime</scope>
</dependency>
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <scope>runtime</scope>
</dependency>
```

### 2. 프로파일별 역할

#### h2
- 기본 로컬 실행 프로파일입니다.
- `application-h2.yml`이 함께 로드됩니다.
- `jdbc:h2:mem:localdb`를 사용합니다.
- `ddl-auto: create-drop`으로 빠르게 실습하기 좋습니다.
- H2 콘솔(`/h2-console`)이 활성화되어 있습니다.

#### dev-my
- 로컬 MySQL 기반 개발 프로파일입니다.
- `application-dev-my.yml`이 함께 로드됩니다.
- 기본값은 `jdbc:mysql://localhost:3306/demo`입니다.
- `DEV_MY_DB_URL`, `DEV_MY_DB_USERNAME`, `DEV_MY_DB_PASSWORD` 환경변수로 덮어쓸 수 있습니다.
- 설정은 `ddl-auto: create-drop`입니다.

#### dev-pg
- 로컬 PostgreSQL 기반 개발 프로파일입니다.
- `application-dev-pg.yml`이 함께 로드됩니다.
- 기본값은 `jdbc:postgresql://localhost:5432/demo`입니다.
- `DEV_PG_DB_URL`, `DEV_PG_DB_USERNAME`, `DEV_PG_DB_PASSWORD` 환경변수로 덮어쓸 수 있습니다.
- 설정은 `ddl-auto: update`입니다.

#### prod
- 운영 환경 프로파일입니다.
- `application-prod.yml`이 함께 로드됩니다.
- PostgreSQL 기반으로 동작하며 DB 정보는 환경변수에서 주입받습니다.
- `ddl-auto: validate`로 스키마를 검증만 하고 자동 변경하지 않습니다.
- SQL 로그는 줄이고 운영 옵션을 우선합니다.

### 3. 왜 `local/dev/test/prod` 일반론으로 외우면 안 되는가
프로파일 이름은 예약어가 아니라 팀이 정하는 규약입니다. 위에서 만든 구조는 아래처럼 역할이 분리됩니다.

- `h2`: 가장 가벼운 기본 로컬 실행
- `dev-my`: MySQL 개발 환경
- `dev-pg`: PostgreSQL 개발 환경
- `prod`: 운영 환경
즉, "당연히 `local` 프로파일이 있겠지"라고 가정하고 실행하면 실제 설정 파일과 바로 어긋납니다. 어떤 프로젝트를 받든 **저장소에 실제로 있는 `application-*.yml` 이름**부터 확인해야 합니다.

### 4. 실행 방법

#### 기본 실행
```bash
./mvnw spring-boot:run
```
기본 활성 프로파일이 `h2`이므로 별도 옵션이 없으면 H2 환경으로 실행됩니다.
```text
예상 결과
The following 1 profile is active: "h2"
H2 console available at '/h2-console'. Database available at 'jdbc:h2:mem:localdb'
Started DemoApplication in 3.x seconds
Tomcat started on port 8080
```

#### h2 명시 실행
```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2
```
```text
예상 결과
The following 1 profile is active: "h2"
H2 console available at '/h2-console'. Database available at 'jdbc:h2:mem:localdb'
Started DemoApplication in 3.x seconds
```

#### dev-my 실행

`dev-my`는 로컬 MySQL이 떠 있어야 합니다. 없다면 Docker로 하나 띄웁니다.

```bash
docker run -d --name demo-mysql -e MYSQL_ROOT_PASSWORD=changeme -e MYSQL_DATABASE=demo -p 3306:3306 mysql:8
```

접속 정보는 환경변수로 주입합니다. 이때 쓰는 `.env`는 접속 정보 같은 값을 `KEY=값` 줄로 모아 두는 관례적인 파일로, 비밀번호를 설정 파일에 적어 커밋하는 대신 셸 환경변수로 불러 쓰기 위한 것입니다. 먼저 `demo` 프로젝트 루트에 `.env`를 만듭니다.

**파일**: .env
```text
DEV_MY_DB_URL=jdbc:mysql://localhost:3306/demo
DEV_MY_DB_USERNAME=root
DEV_MY_DB_PASSWORD=changeme
```

그다음 `.env`를 셸에 불러들여 실행합니다.

```bash
# Mac / Linux
set -a; source .env; set +a
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev-my
```

> **Windows**: `source`는 bash 전용입니다. PowerShell에서는 값을 직접 주입하거나(`$env:DEV_MY_DB_URL="..."`) IDE 실행 구성의 환경변수에 넣고 `mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev-my`로 실행합니다. (전제: 로컬 MySQL이 떠 있고 `demo` DB가 있어야 합니다.)
```text
예상 결과
The following 1 profile is active: "dev-my"
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Started DemoApplication in 4.x seconds
```
로그의 `HikariPool`은 Spring Boot가 기본으로 쓰는 DB 커넥션 풀 이름으로, `Start completed`가 보이면 실제 DB 연결에 성공했다는 뜻입니다. MySQL 접속 정보가 잘못되거나 서버가 없으면 `HikariPool ... Unable to acquire JDBC Connection` 오류가 발생합니다.

#### dev-pg 실행

로컬 PostgreSQL이 없다면 역시 Docker로 띄우고, `.env`에 접속 정보를 추가합니다.

```bash
docker run -d --name demo-pg -e POSTGRES_PASSWORD=changeme -e POSTGRES_DB=demo -p 5432:5432 postgres:16
```

**파일**: .env (아래 3줄 추가)
```text
DEV_PG_DB_URL=jdbc:postgresql://localhost:5432/demo
DEV_PG_DB_USERNAME=postgres
DEV_PG_DB_PASSWORD=changeme
```

dev-my 때와 같은 방식으로 `.env`를 셸에 다시 불러들여 실행합니다.

```bash
set -a; source .env; set +a
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev-pg
```
```text
예상 결과
The following 1 profile is active: "dev-pg"
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Started DemoApplication in 4.x seconds
```

#### JAR 실행
먼저 `./mvnw clean package`로 JAR을 만든 뒤, 프로파일을 골라 실행합니다.
```bash
./mvnw clean package
java -jar -Dspring.profiles.active=h2 target/demo-0.0.1-SNAPSHOT.jar
java -jar -Dspring.profiles.active=dev-my target/demo-0.0.1-SNAPSHOT.jar
java -jar -Dspring.profiles.active=dev-pg target/demo-0.0.1-SNAPSHOT.jar
java -jar -Dspring.profiles.active=prod target/demo-0.0.1-SNAPSHOT.jar
```
`prod`는 `PROD_DB_URL`·`PROD_DB_USERNAME`·`PROD_DB_PASSWORD` 환경변수를 모두 넣어야 기동됩니다. 기본값이 없으므로 빠지면 즉시 실패하는데, 이것이 의도된 안전장치입니다.
```text
예상 결과
The following 1 profile is active: "<지정한 프로파일>"
기동 로그에서 활성 프로파일 이름과 Hikari 연결 풀 시작 여부를 확인합니다.
```

### 5. 테스트와 프로파일을 같이 볼 때의 기준
테스트는 `src/test/resources`의 설정을 우선 읽습니다. `demo`에는 아직 테스트 전용 설정 파일이 없으므로, 기본 생성된 테스트(`contextLoads`)는 메인 설정을 그대로 물려받아 활성 프로파일 `h2`로 돕니다.

> **참고 — 실제 프로젝트에서는**: 필자의 실무 저장소는 `src/test/resources/application.yml`(`spring.test.database.replace=none`)과 `src/test/resources/application-dev-pg.yml`(`ddl-auto: create-drop`)을 따로 둔다. 테스트를 설명할 때는 막연히 `test` 프로파일을 가정하기보다, **테스트 리소스 파일이 어떤 프로파일을 보조하는지** 같이 봐야 한다.

### 6. DDL 전략을 읽는 기준
위에서 만든 구조 기준으로 보면 다음처럼 이해하는 편이 정확합니다.

- `h2`: 빠른 실습용이므로 `create-drop`
- `dev-my`: 로컬 MySQL 실험용으로 `create-drop`
- `dev-pg`: 개발 DB를 유지하며 검증하기 위해 `update`
- `prod`: 운영 안정성을 위해 `validate`
여기서 중요한 점은 `create-drop`, `update`, `validate`를 추상적으로 외우는 것이 아니라, **어떤 환경에서 어떤 위험을 감수하는지와 함께 읽는 것**입니다.

### 7. 프로파일 문서를 읽을 때 먼저 확인할 항목
- 현재 활성 프로파일이 무엇인가
- 실제로 어떤 `application-{profile}.yml`이 로드되는가
- DB URL이 어느 데이터베이스를 가리키는가
- 민감 정보가 파일 고정값인지 환경변수 주입인지
- DDL 전략이 현재 환경 목적과 맞는가
- SQL 로그 수준이 디버깅용인지 운영용인지

### 8. 자주 하는 실수
- 저장소에는 없는 `local` 프로파일이 있다고 가정하는 것
- `dev-my`와 `dev-pg`를 같은 개발 환경으로만 뭉뚱그려 설명하는 것
- 운영 환경인데 `update` 같은 자동 변경 전략을 허용하는 것
- 테스트 설명에서 실제 `src/test/resources` 구성을 보지 않는 것
- 환경변수 주입 값을 문서에서 고정값처럼 오해하는 것

### 자주 나는 에러 → 원인

| 증상 | 원인 확인 |
|------|----------|
| 기동 로그가 `The following 1 profile is active: "h2"`가 아니라 `No active profile set` | `application.yml`에 `spring.profiles.active: h2`가 빠졌거나, 갓 만들 때의 `application.properties`를 지우지 않아 설정이 갈라진 상태 |
| 기동 실패 + `mapping values are not allowed here` 류 YAML 파싱 오류 | yml 들여쓰기 오류 — 탭 금지·공백 2칸, `url:`처럼 키와 값 사이에는 공백 한 칸 |
| `http://localhost:8080/h2-console`이 404 | `spring.h2.console.enabled: true` 누락 또는 `h2`가 아닌 프로파일로 실행 중. 접속 화면의 JDBC URL은 `jdbc:h2:mem:localdb`, 사용자는 `sa` |
| `Unable to acquire JDBC Connection` 또는 `Cannot load driver class` | 전자는 로컬 MySQL·PostgreSQL 미기동(`docker ps`로 컨테이너 확인)·접속 정보 불일치, 후자는 `pom.xml`에 드라이버 의존성 누락(1번의 마지막 단계) |

### 공식 문서 기준으로 같이 보면 좋은 주제
- Spring Boot Externalized Configuration
- Spring Boot Profiles
- Spring Boot Testing
공식 문서는 프로파일별 설정 파일이 활성 프로파일에 따라 함께 로드된다는 구조와, 실행 시 프로파일을 바꾸는 방식을 기준으로 읽으면 됩니다.

### ✏️ 프로파일 설정 가이드 직접 해보기

프로파일마다 `server.port`를 다르게 지정해(`h2`는 8080, `dev-pg`는 8081) 실행 로그에서 포트가 프로파일에 따라 바뀌는지 확인하라.

!!! example "실습 순서"

    1. **파일 열기** — `demo` 프로젝트의 위 `application-h2.yml`·`application-dev-pg.yml`(6.3)을 엽니다.
    2. **수정** — `application-h2.yml`에 `server.port: 8080`, `application-dev-pg.yml`에 `server.port: 8081`을 추가합니다.
    3. **재실행** — `./mvnw spring-boot:run -Dspring-boot.run.profiles=h2` 와 `-Dspring-boot.run.profiles=dev-pg`로 바꿔가며 실행해, 시작 로그의 포트가 프로파일에 따라 바뀌는지 확인합니다.

### 정리
프로파일 설정의 핵심은 이름을 외우는 데 있지 않습니다. **내 프로젝트가 어떤 프로파일 파일을 가지고 있고, 그 프로파일이 DB·로그·DDL 전략을 어떻게 바꾸는지**를 정확히 읽는 데 있습니다. 이 절에서 `demo`에 만든 `h2`, `dev-my`, `dev-pg`, `prod`가 그 기준선입니다.

### 한 줄 정리
`demo`의 프로파일 구조는 일반론이 아니라, **`h2`를 기본으로 하고 `dev-my`, `dev-pg`, `prod`로 확장되는 실제 설정 구조**를 기준으로 이해해야 합니다.
