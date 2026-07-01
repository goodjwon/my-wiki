---
title: "Java 스터디 — 환경과 실행"
type: source
tags: [java, study, ch01]
sources: [java-study/java-study-ch01-환경과실행.md]
created: 2026-04-18
updated: 2026-06-30
---

> 📘 [[src-java-study-2024-2025]] 원본 교재 본문. 학습 흐름은 [[guide-java-learning-path]] 참조.

# 환경과 실행

## 🎯 이 장에서 배우는 것

- JDK·JRE·JVM의 차이와 개발 환경(IDE·계정) 세팅
- "한 번 작성, 어디서나 실행"이 가능한 이유
- 첫 프로그램 실행 → **빌드 도구(Maven·Gradle)로 첫 프로젝트 생성·빌드·실행**

**단계**: 1단계 — Java Core · **앞 장**: [[java-study-ch00]] · **다음 장**: [[java-study-ch02]]

> **따라 하는 법**: 위에서 아래로 읽으며 코드를 직접 쳐본다. 설치 → Hello World → **1.2에서 Maven/Gradle로 진짜 프로젝트를 만들어 빌드·실행**까지 커맨드로 한 바퀴 돌린다.

---

## 1.0 개발 환경과 계정 준비

**🎯 목표**: JDK 설치·IDE·계정까지 개발 환경을 끝까지 세팅한다.

### 개요
이 문서는 **초중급 Java 개발자**가 스터디나 프로젝트를 시작하기 전에 필요한 개발 환경과 계정을 한 번에 준비할 수 있도록 정리한 가이드입니다. 설치 링크만 모으는 것이 아니라, 무엇을 왜 먼저 준비해야 하는지를 중심으로 설명합니다.

### 왜 먼저 준비해야 하는가
학습 초반에는 문법보다 환경 차이로 더 자주 막힙니다. GitHub, JDK, IDE, 협업 도구가 미리 준비되어 있으면 이후 실습 문서와 프로젝트 셋업을 훨씬 부드럽게 따라갈 수 있습니다.

### 대상 독자
- Java와 Spring 학습을 시작하는 초중급 개발자
- 스터디 또는 팀 프로젝트에 처음 참여하는 개발자
- 개발 도구와 계정을 한 번에 정리하고 싶은 개발자

### 이번 원고에서 실제로 참고하는 저장소
이 책 원고는 아래 두 저장소를 함께 참고합니다.

#### `day_by_spring`
- Spring Boot 3.5.x, Java 21 기준의 현재 프로젝트 저장소입니다.
- 설정, 실행, 보안, 테스트, 데이터 접근처럼 **프로젝트형 설명**의 기준선입니다.

#### `day-by-java`
- Java 기초와 장별 예제 중심 저장소입니다.
- Java 문법, 객체, 함수형, 예외, 파일 처리, 네트워크, 패턴처럼 **작게 실행해 볼 수 있는 예시 코드**를 보강할 때 유용합니다.

#### 독자가 먼저 맞춰야 할 기준
- 현재 프로젝트 기준 문서를 따라가려면 Java 21 환경이 가장 안전합니다.
- 예제 저장소의 일부 코드는 Java 17 기준으로 작성되었지만, 문서를 읽는 기준선은 우선 Java 21로 맞추는 편이 흐름이 덜 흔들립니다.

### 1. GitHub
- GitHub 계정을 생성합니다.
- 학생이라면 Education Pack 신청 여부를 확인합니다.
- 로컬 PC에 Git을 설치합니다.
[GitHub](https://github.com/)

### 2. Notion
- 스터디 자료를 읽고 협업 문서를 정리하기 위해 Notion 계정을 준비합니다.
- 학생 요금제나 교육용 플랜이 필요한지 확인합니다.

### 3. Java
- JDK 21 또는 학습 기준 버전을 설치합니다.
- `JAVA_HOME`과 PATH를 함께 점검합니다.
- Windows라면 환경 변수 설정을 반드시 확인합니다.
[OpenJDK Downloads](https://www.openlogic.com/openjdk-downloads?field_java_parent_version_target_id=807&field_operating_system_target_id=436&field_architecture_target_id=391&field_java_package_target_id=396)

### 4. IDE

#### IntelliJ IDEA
- JetBrains Toolbox App으로 설치하면 버전 관리가 편합니다.
- 초중급 Java 개발자 기준으로는 IntelliJ IDEA Community만으로도 학습을 진행할 수 있습니다.
[JetBrains](https://www.jetbrains.com/ko-kr/)

#### VS Code
- 가벼운 편집기 용도로 유용합니다.
- 필요한 확장은 최소한으로 설치하는 편이 좋습니다.
- 예: Live Server, Live Share
[VS Code](https://code.visualstudio.com/)

### 5. 협업 도구
- Slack: 공지, 질문, 빠른 커뮤니케이션
- Google Meet: 원격 회의
- Google 원격 데스크톱: 원격 지원이 필요할 때 사용

### 6. Docker
- 컨테이너 기반 실습이나 로컬 개발 환경 통일이 필요하다면 Docker Desktop을 준비합니다.
[Docker Desktop](https://www.docker.com/products/docker-desktop/)

### 7. MySQL
- 로컬 DB 실습이 필요하면 MySQL을 설치합니다.
- 초반에는 H2로 시작해도 되지만, DB 차이를 경험하려면 MySQL 설치가 도움이 됩니다.
[MySQL Installer](https://dev.mysql.com/downloads/installer/)

### 8. 짝코딩과 협업 준비
- GitHub 저장소 초대 여부를 확인합니다.
- JetBrains 또는 VS Code 기반 짝코딩 도구를 확인합니다.
- 협업 전에는 같은 JDK와 Git 버전을 사용하는지 먼저 맞춥니다.

### 자주 하는 실수
- 계정만 만들고 실제 로그인과 접근 권한 확인을 하지 않는 것
- JDK 설치 후 환경 변수 설정을 확인하지 않는 것
- IDE와 Git 설치를 미루다가 실습 중간에 막히는 것
- 협업 도구를 나중에 맞추려다 초기 세팅을 반복하는 것

### ✏️ 직접 해보기

JDK를 설치하고 IDE에서 새 프로젝트를 만들어 `main` 메서드를 실행해 보라.

### 정리
개발 환경과 계정 준비는 단순한 사전 작업이 아니라, 이후 학습과 협업 흐름을 결정하는 기반입니다. 한 번만 정리해두면 다음 문서들을 훨씬 적은 마찰로 따라갈 수 있습니다.

### 한 줄 정리
학습 시작 전에는 **계정, JDK, IDE, 협업 도구를 먼저 맞춰서 실습 흐름이 끊기지 않게 만드는 것**이 중요합니다.

## 1.1 Java 소개와 개발 환경

**🎯 목표**: Java가 JVM 위에서 도는 원리와 "한 번 작성, 어디서나 실행"의 의미를 이해한다.

#### 개요

이 문서는 Java가 어떤 언어인지 간단히 소개하고, 학습을 시작하기 위한 최소 개발 환경을 정리한 문서입니다. 초중급 Java 개발자가 실습에 바로 들어가기 전에 꼭 맞춰야 할 기준만 담았습니다.

#### 왜 중요한가

Java는 문법만 익힌다고 끝나는 언어가 아닙니다. JDK, IDE, 실행 방식까지 함께 이해해야 예제 코드가 왜 그렇게 동작하는지 자연스럽게 연결됩니다.

#### 1. Java란 무엇인가

Java는 객체지향 프로그래밍 언어이며, JVM 위에서 실행된다는 점이 큰 특징입니다.

##### Java의 핵심 특징

- 플랫폼 독립성
- 객체지향 구조
- 풍부한 표준 라이브러리
- 멀티스레드 지원

즉, 운영체제가 달라도 JVM만 맞으면 같은 프로그램을 실행할 수 있습니다.

#### 2. JDK와 JRE의 차이

##### JDK

개발자가 코드를 작성하고 컴파일하고 실행하기 위한 도구 모음입니다.

##### JRE

작성된 프로그램을 실행하기 위한 환경입니다.

학습과 개발을 위해서는 JRE가 아니라 JDK를 설치해야 합니다.

#### 3. JDK 설치

현재 학습 흐름에서는 JDK 21 기준으로 맞추는 편이 가장 안정적입니다.

##### 확인 방법

```bash
java -version
javac -version
```

두 명령이 모두 정상 출력되어야 개발 환경이 제대로 준비된 것입니다.

#### 4. IDE 선택

##### IntelliJ IDEA

Java와 Spring 학습에 가장 무난한 선택입니다.

##### VS Code

가볍게 편집하거나 간단한 실습을 할 때 유용합니다.

핵심은 도구를 많이 설치하는 것이 아니라, 하나의 IDE로 컴파일과 실행을 안정적으로 반복할 수 있게 만드는 것입니다.

#### 5. 첫 Java 프로그램

가장 단순한 출발점은 콘솔에 한 줄을 출력하는 프로그램입니다. 예제 소스 다발인 `day-by-java`에도 같은 목적의 최소 실행 예제가 있습니다.

```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello world!");
    }
}
```

##### 여기서 먼저 볼 것

- 클래스 이름과 파일 이름이 같아야 합니다.
- `main` 메서드는 프로그램의 시작점입니다.
- `System.out.println`은 콘솔 출력입니다.
- 중요한 것은 문장을 외우는 것이 아니라, **작성 -> 컴파일 -> 실행 -> 출력 확인** 흐름을 직접 한 번 닫아보는 것입니다.

#### 6. 실행 흐름 이해하기

1. `.java` 파일 작성
1. `javac`로 컴파일
1. `.class` 파일 생성
1. `java` 명령으로 JVM에서 실행

이 흐름을 이해하면 IDE가 내부에서 해주는 일도 더 잘 보입니다.

#### 자주 하는 실수

- JRE만 설치하고 JDK를 설치하지 않는 것
- `JAVA_HOME` 또는 PATH 확인을 생략하는 것
- 클래스 이름과 파일 이름을 다르게 두는 것
- IDE에서만 실행하고 실제 명령행 실행은 확인하지 않는 것

### ✏️ 직접 해보기

Hello World를 `javac`로 컴파일하고 `java`로 실행한 뒤, 생성된 `.class` 파일을 확인하라.

#### 정리

Java 학습 초반에는 언어 소개보다 실행 가능한 환경을 먼저 만드는 것이 중요합니다. `java -version`, `javac -version`, Hello World 실행까지 확인되면 다음 단계 문서를 안정적으로 따라갈 수 있습니다.

#### 한 줄 정리

Java 입문의 핵심은 **언어 특징을 아는 것보다, JDK 설치와 첫 실행 흐름을 직접 확인하는 것**입니다.

## 1.2 첫 프로젝트 만들기 (Maven·Gradle)

**🎯 목표**: 단일 파일 실행에서 벗어나, **빌드 도구로 표준 구조의 프로젝트를 생성·빌드·실행**하고 git으로 버전관리를 시작한다.

#### 개요

`javac Main.java` 한 줄은 파일 하나짜리다. 하지만 실제 프로젝트는 **여러 소스·테스트·외부 라이브러리**를 다뤄야 하고, 그걸 사람이 손으로 관리할 수 없다. 그래서 **빌드 도구**(Maven 또는 Gradle)가 표준 구조·의존성·빌드·실행을 대신 관리한다. 이 스터디는 Spring 단계에서 **Maven**을 쓰지만, 현업에서 **Gradle**도 널리 쓰이므로 둘 다 익혀 둔다.

> IDE(IntelliJ)의 *New Project*로도 같은 프로젝트를 만들 수 있다. 하지만 **구조를 이해하려면 먼저 커맨드로 한 번** 만들어 보는 편이 낫다. 아래는 CLI 기준이다.

> **Mac·Linux ↔ Windows** — 커맨드는 대부분 공통이고, 세 가지만 다르다:
>
> | | Mac · Linux | Windows |
> |---|---|---|
> | 래퍼 실행 | `./gradlew` · `./mvnw` | `gradlew` · `mvnw` (PowerShell은 `.\gradlew`) |
> | 여러 줄 명령 | 줄 끝 `\` 로 이어쓰기 | `\` 안 됨 → **한 줄로** 붙여 실행 (PowerShell은 백틱 `` ` ``) |
> | 파일 만들기 | `cat > 파일 << 'EOF'` 가능 | 안 됨 → **편집기/IDE로** 파일 생성 |
>
> 아래 예시는 한 줄 명령으로 적어 두 OS에서 모두 동작한다. (`mvn`·`java`·`git`·`mkdir`·`cd`는 양쪽 공통)

#### 1. 왜 빌드 도구인가

| 손으로 하면 | 빌드 도구가 해주는 것 |
|------------|---------------------|
| 라이브러리 jar를 직접 내려받아 classpath에 추가 | 좌표(`group:artifact:version`) 한 줄로 자동 다운로드 |
| `javac` 여러 파일 일일이 컴파일 | 표준 명령 하나로 컴파일·테스트·패키징 |
| 프로젝트마다 구조가 제각각 | `src/main/java`·`src/test/java` 표준 구조 |

#### 2. 프로젝트 생성

**Maven** — quickstart 아키타입으로 생성 (한 줄):

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=hello-java -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
cd hello-java
```

**Gradle** — `gradle init` 로 생성 (프롬프트가 뜨면 기본값 Enter):

```bash
mkdir hello-java
cd hello-java
gradle init --type java-application --dsl groovy --test-framework junit-jupiter --package com.example --project-name hello-java
```

#### 3. 표준 프로젝트 구조

두 도구 모두 아래 표준 레이아웃을 만든다 (빌드 파일만 다름):

```text
hello-java/
├── pom.xml            ← Maven 설정      (Gradle은 build.gradle)
├── src/
│   ├── main/java/com/example/App.java   ← 실제 코드
│   └── test/java/com/example/AppTest.java ← 테스트
└── (gradlew / mvnw)   ← 래퍼 스크립트 (버전 고정용)
```

- `src/main/java` = 프로덕션 코드, `src/test/java` = 테스트 코드. 이 분리가 표준이다.
- 패키지 `com.example` = 폴더 경로와 일치해야 한다 (2장에서 자세히).

#### 4. 빌드 → 실행 사이클

**Maven**:

```bash
mvn compile                                   # 컴파일 → target/classes
mvn test                                      # 테스트 실행
mvn package                                   # 실행 가능 jar → target/*.jar
java -cp target/classes com.example.App       # 직접 실행
```

**Gradle**:

```bash
./gradlew build          # 컴파일 + 테스트 + jar 한 번에
./gradlew run            # 실행 (application 플러그인)
```

> 처음엔 `run`/`java -cp`로 콘솔에 "Hello" 한 줄이 찍히는 것만 확인하면 된다. 중요한 건 **"소스 → 빌드 → 실행" 사이클을 도구로 한 바퀴 돌려보는 것**.

#### 5. 의존성 추가 (예: Guava)

외부 라이브러리는 빌드 파일에 좌표 한 줄만 적으면 자동으로 받아진다.

**Maven** — `pom.xml` 의 `<dependencies>` 안:

```xml
<dependency>
  <groupId>com.google.guava</groupId>
  <artifactId>guava</artifactId>
  <version>33.0.0-jre</version>
</dependency>
```

**Gradle** — `build.gradle` 의 `dependencies` 안:

```groovy
implementation 'com.google.guava:guava:33.0.0-jre'
```

#### 6. git 버전관리 시작

빌드 산출물은 커밋하지 않는다. 먼저 저장소를 초기화하고:

```bash
git init
```

**편집기/IDE로** 프로젝트 루트에 `.gitignore` 파일을 만들어 아래 내용을 넣는다 (gitignore 주석은 줄 전체 `#`만 인식하므로 값 옆에 쓰지 않는다):

```text
# 빌드 산출물 (커밋 안 함)
target/
build/
.gradle/
*.class

# IDE
.idea/
```

그다음 첫 커밋:

```bash
git add .
git commit -m "chore: 첫 Java 프로젝트 셋업"
```

#### 자주 하는 실수

- `target/`·`build/`(빌드 산출물)를 git에 커밋하는 것 → `.gitignore` 필수
- 패키지 폴더 경로와 `package` 선언을 다르게 두는 것
- IDE에서만 실행해 보고 `mvn`/`gradlew` 커맨드 빌드는 안 돌려 보는 것
- 의존성을 손으로 jar 받아 넣는 것 (빌드 파일에 좌표로 선언해야 함)

### ✏️ 직접 해보기

Maven **또는** Gradle 중 하나로 `hello-java` 프로젝트를 만들고, `App.java`가 콘솔에 문장을 출력하도록 고친 뒤 **빌드→실행**을 커맨드로 한 바퀴 돌려라. 그다음 `.gitignore`를 만들고 첫 커밋까지 남겨라.

#### 정리

첫 프로젝트의 핵심은 언어가 아니라 **"빌드 도구가 잡아 주는 표준 구조 위에서 소스를 빌드·실행하는 흐름"**이다. Maven·Gradle 어느 쪽이든 `생성 → 구조 확인 → 빌드 → 실행 → 의존성 → git` 한 바퀴를 돌려 보면, 이후 Spring 프로젝트(6장)도 같은 골격의 확장임을 알게 된다.

#### 한 줄 정리

단일 파일 실행을 넘어 **빌드 도구로 프로젝트를 만들고 빌드·실행 사이클을 손에 익히는 것**이 진짜 프로젝트의 출발점이다.

---

## [참고 1] Java와 OS의 관계 및 C/C++과의 비교

### 1. Java와 운영체제(OS)의 관계
Java는 운영체제와 독립적인 플랫폼 독립성을 제공함으로써 다양한 환경에서 실행 가능.

#### 1.1 Java의 플랫폼 독립성
- **JVM(Java Virtual Machine)**: Java 프로그램은 JVM에서 실행되며, JVM은 각 운영체제에 맞게 구현되어 있음.
- **바이트코드**: Java 컴파일러는 소스 코드를 바이트코드(.class 파일)로 컴파일하고, JVM은 바이트코드를 해석하여 실행.
- **Write Once, Run Anywhere**: 한 번 작성한 코드를 다양한 운영체제에서 실행할 수 있다는 의미.

#### 1.2 운영체제와의 상호 작용
- Java는 운영체제의 세부 사항을 추상화하여 개발자가 직접 운영체제에 종속적인 코드를 작성하지 않도록 함.
- **JNI(Java Native Interface)**: 필요한 경우 C나 C++로 작성된 네이티브 코드를 호출하여 운영체제의 특정 기능 활용 가능.

### 2. Java와 C/C++의 비교
Java와 C/C++은 모두 프로그래밍 언어지만, 여러 면에서 차이점이 존재함.

#### 2.1 언어의 특징 비교

#### 2.2 메모리 관리 차이
- **Java**
  - 자동 가비지 컬렉션으로 메모리 누수 위험 감소.
  - 개발자는 메모리 해제에 신경 쓸 필요가 없음.
- **C/C++**
  - 동적 메모리 할당 시 `malloc`, `free` 등을 사용하여 직접 관리.
  - 메모리 누수 및 잘못된 메모리 접근의 위험이 있음.

#### 2.3 실행 환경 차이
- **Java**
  - JVM 위에서 바이트코드를 해석하여 실행.
  - JVM의 최적화(JIT 컴파일러 등)로 성능 향상 가능.
- **C/C++**
  - 컴파일 시 기계어로 변환되어 운영체제에서 직접 실행.
  - 하드웨어 자원을 직접 제어 가능하여 고성능 프로그램 개발에 유리.

#### 2.4 사용 분야
- **Java**
  - 웹 애플리케이션, 안드로이드 앱, 기업용 소프트웨어 등.
  - 플랫폼 독립성과 풍부한 라이브러리로 다양한 분야에서 사용.
- **C/C++**
  - 시스템 프로그래밍, 게임 개발, 임베디드 시스템 등.
  - 하드웨어와 밀접한 고성능 프로그램 개발에 적합.

#### 2.5 코드 예시 비교

#### Java 코드 예시
```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, Java!");
    }
}

```

#### C 코드 예시
```c
#include <stdio.h>

int main() {
    printf("Hello, C!\\n");
    return 0;
}

```

#### C++ 코드 예시
```cpp
#include <iostream>

int main() {
    std::cout << "Hello, C++!" << std::endl;
    return 0;
}

```

### 3. 결론
- Java는 플랫폼 독립성과 자동 메모리 관리 등의 장점을 가지며, 운영체제에 종속되지 않는 응용 프로그램 개발에 유리.
- C/C++은 하드웨어 자원에 대한 직접적인 접근과 높은 성능을 제공하여 시스템 프로그래밍 등에 적합.
- 개발 목적과 요구 사항에 따라 적합한 프로그래밍 언어를 선택하는 것이 중요.

---
