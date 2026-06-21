---
title: Java 도서 실습 환경 가이드
type: guide
tags: [java, book, lecture, study, lab, beginner]
sources: [object/, effective_java/, refactoring/, clean-code/, tdd/]
created: 2026-06-21
updated: 2026-06-21
---

# Java 도서 실습 환경 가이드

## 목적

오브젝트·Effective Java·리팩터링·Clean Code·TDD 강의 교재를 **읽고 끝내지 않고 직접 손으로 확인**하기 위한 공통 실습 환경이다. 각 장은 책이 달라도 같은 루틴으로 진행한다.

```
[읽기] 문제 상황 파악
  ↓
[빨강] 테스트 또는 실행 예로 현재 문제 확인
  ↓
[초록] 가장 작은 수정
  ↓
[정련] 이름·책임·중복·의존성 정리
  ↓
[기록] 체크리스트와 퀴즈로 인사이트 고정
```

## 기본 도구

| 도구 | 용도 | 확인 명령 |
|------|------|-----------|
| Java 17+ | 오브젝트·Effective Java·Clean Code·TDD 1부 실습 | `java -version` |
| Maven 또는 Gradle | JUnit 5 테스트 실행 | `./mvnw test` 또는 `./gradlew test` |
| JUnit 5 | TDD·리팩터링 안전망 | 테스트 실패/성공 확인 |
| AssertJ | 읽기 쉬운 단언 | `assertThat(...)` |
| Python 3 | TDD 2부 xUnit 예제 | `python3 --version` |
| Node.js 20+ | 리팩터링 1장 JavaScript 예제 | `node --version` |

## 최소 Maven 프로젝트

```text
book-lab/
├── pom.xml
└── src/test/java/study/BookLabTest.java
```

`pom.xml` 예시. 이미 팀 표준 BOM이나 Spring Boot 프로젝트가 있으면 그 버전을 우선한다.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>study</groupId>
  <artifactId>book-lab</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <maven.compiler.release>17</maven.compiler.release>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>5.11.4</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.assertj</groupId>
      <artifactId>assertj-core</artifactId>
      <version>3.27.3</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.5.2</version>
      </plugin>
    </plugins>
  </build>
</project>
```

첫 확인:

```bash
./mvnw test
```

Maven Wrapper가 없다면 `mvn test`로 시작해도 된다.

## 도서별 실습 방식

| 책 | 주 실습 방식 | 확인할 것 |
|----|--------------|-----------|
| [[src-object-lecture]] | 한 객체가 남의 내부를 만지는 코드를 책임 이동으로 바꿈 | getter 호출이 메시지 전송으로 바뀌는가 |
| [[src-effective-java-lecture]] | 각 Item을 작은 테스트/클래스로 확인 | API 선택의 장단점을 설명할 수 있는가 |
| [[src-refactoring-lecture]] | 기존 테스트를 안전망으로 두고 작은 단계로 구조 변경 | 매 단계 테스트가 초록인가 |
| [[src-clean-code-lecture]] | 이름·함수·주석·클래스 단위로 Before/After 작성 | 읽는 사람이 의도를 바로 아는가 |
| [[src-tdd-lecture]] | 실패 테스트를 먼저 쓰고 최소 구현 후 정련 | 빨강을 본 뒤 초록으로 갔는가 |

## 장별 셀프 체크

- [ ] 이 장의 “문제 코드”를 직접 타이핑했다.
- [ ] 실패하는 테스트나 불편한 실행 결과를 먼저 확인했다.
- [ ] 한 번에 하나의 변경만 했다.
- [ ] 변경 후 테스트 또는 실행 결과를 확인했다.
- [ ] 왜 이 설계가 나아졌는지 한 문장으로 적었다.
- [ ] 현업 코드에서 같은 냄새가 나는 예를 하나 찾았다.

## 막힐 때

| 증상 | 대응 |
|------|------|
| 코드가 컴파일되지 않음 | 테스트 목표가 너무 큰지 확인하고, 클래스 껍데기부터 만든다 |
| 테스트가 왜 실패하는지 모르겠음 | 실패 메시지를 먼저 읽고, 기대값/실제값을 한 줄로 적는다 |
| 리팩터링 중 깨짐 | 직전 초록 상태로 돌아가 변경 단위를 반으로 줄인다 |
| 원칙은 알겠는데 적용이 안 됨 | 해당 장의 체크리스트를 자기 코드 한 파일에만 적용한다 |

## 관련 페이지

- [[src-object-lecture]]
- [[src-effective-java-lecture]]
- [[src-refactoring-lecture]]
- [[src-clean-code-lecture]]
- [[src-tdd-lecture]]
