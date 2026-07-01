---
title: "Java 스터디 — 안내"
type: source
tags: [java, study, ch00]
sources: [java-study/java-study-ch00-안내.md]
created: 2026-04-18
updated: 2026-06-30
---

> 📘 [[src-java-study-2024-2025]] 원본 교재 본문. 학습 흐름은 [[guide-java-learning-path]] 참조.

# 안내

## 🎯 이 장에서 배우는 것

- 이 교재를 어떤 순서로 읽고 어떻게 활용하는지
- 학습 로드맵과 문서 포맷 약속

**단계**: 1단계 — Java Core · **다음 장**: [[java-study-ch01]]

> **따라 하는 법**: 위에서 아래로 읽으며 코드를 직접 쳐본다. 먼저 [[guide-java-learning-path]]에서 5개 트랙 지도를 보고, 본인 수준에 맞는 트랙부터 시작한다.

---

## 0.0 읽는 순서와 문서 포맷

**🎯 목표**: 이 교재의 읽는 순서와 문서 포맷 약속을 이해한다.

#### 개요

이 문서는 `day_by_spring` 프로젝트를 기준으로 Spring Boot 프로파일을 어떻게 나누고 실행하는지 정리한 가이드입니다. 이 저장소는 추상적인 `local/dev/test/prod` 예시를 설명하는 문서가 아니라, **실제 `application-*.yml` 파일 구조와 실행 명령을 기준으로 읽어야 하는 문서**입니다.

#### 왜 중요한가

Spring Boot는 활성 프로파일에 따라 `application-{profile}.yml`을 함께 읽습니다. 따라서 같은 코드라도 어떤 프로파일로 실행하느냐에 따라 데이터베이스, 로그 레벨, DDL 전략, SQL 출력 방식이 달라질 수 있습니다. 프로파일을 코드와 분리해서 외운다면 실행은 되더라도 왜 그렇게 동작하는지 이해하기 어렵습니다.

#### 1. 이 프로젝트의 실제 프로파일 구조

현재 저장소의 기준 파일은 아래와 같습니다.

```text
src/main/resources/application.yml
src/main/resources/application-h2.yml
src/main/resources/application-dev-my.yml
src/main/resources/application-dev-pg.yml
src/main/resources/application-prod.yml
src/test/resources/application.yml
src/test/resources/application-dev-pg.yml
```

기본 활성 프로파일은 `application.yml`에서 `h2`로 지정되어 있습니다.

```yaml
spring:
  profiles:
    active: h2
```

즉, 별도 옵션 없이 실행하면 먼저 H2 환경으로 기동됩니다.

#### 2. 프로파일별 역할

##### h2

- 기본 로컬 실행 프로파일입니다.
- `application-h2.yml`이 함께 로드됩니다.
- `jdbc:h2:mem:localdb`를 사용합니다.
- `ddl-auto: create-drop`으로 빠르게 실습하기 좋습니다.
- H2 콘솔(`/h2-console`)이 활성화되어 있습니다.
##### dev-my

- 로컬 MySQL 기반 개발 프로파일입니다.
- `application-dev-my.yml`이 함께 로드됩니다.
- 기본값은 `jdbc:mysql://localhost:3306/daybyspring`입니다.
- `DEV_MY_DB_URL`, `DEV_MY_DB_USERNAME`, `DEV_MY_DB_PASSWORD` 환경변수로 덮어쓸 수 있습니다.
- 현재 설정은 `ddl-auto: create-drop`입니다.
##### dev-pg

- 로컬 PostgreSQL 기반 개발 프로파일입니다.
- `application-dev-pg.yml`이 함께 로드됩니다.
- 기본값은 `jdbc:postgresql://localhost:5432/daybyspring`입니다.
- `DEV_PG_DB_URL`, `DEV_PG_DB_USERNAME`, `DEV_PG_DB_PASSWORD` 환경변수로 덮어쓸 수 있습니다.
- 현재 설정은 `ddl-auto: update`입니다.
##### prod

- 운영 환경 프로파일입니다.
- `application-prod.yml`이 함께 로드됩니다.
- PostgreSQL 기반으로 동작하며 DB 정보는 환경변수에서 주입받습니다.
- `ddl-auto: validate`로 스키마를 검증만 하고 자동 변경하지 않습니다.
- SQL 로그는 줄이고 운영 옵션을 우선합니다.
#### 3. 왜 `local/dev/test/prod` 일반론으로 설명하면 안 되는가

이 저장소는 이름이 곧 프로파일 의미가 되는 구조가 아닙니다. 실제로는 아래처럼 역할이 분리되어 있습니다.

- `h2`: 가장 가벼운 기본 로컬 실행
- `dev-my`: MySQL 개발 환경
- `dev-pg`: PostgreSQL 개발 환경
- `prod`: 운영 환경
즉, 이 프로젝트를 설명할 때 `local`이라는 이름을 기본값처럼 쓰면 실제 설정 파일과 바로 어긋납니다. 책 문서도 저장소 기반 설명을 할 때는 반드시 이 이름을 그대로 따라가야 합니다.

#### 4. 실행 방법

##### 기본 실행

```bash
./mvnw spring-boot:run
```

기본 활성 프로파일이 `h2`이므로 별도 옵션이 없으면 H2 환경으로 실행됩니다.

```text
예상 결과
The following 1 profile is active: "h2"
H2 console available at '/h2-console'. Database available at 'jdbc:h2:mem:localdb'
Started SpringApplication in 3.x seconds
Tomcat started on port 8080
```

##### h2 명시 실행

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=h2
```

```text
예상 결과
The following 1 profile is active: "h2"
H2 console available at '/h2-console'. Database available at 'jdbc:h2:mem:localdb'
Started SpringApplication in 3.x seconds
```

##### dev-my 실행

```bash
set -a; source .env; set +a
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev-my
```

```text
예상 결과
The following 1 profile is active: "dev-my"
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Started SpringApplication in 4.x seconds
```

MySQL 접속 정보가 잘못되거나 서버가 없으면 `HikariPool ... Unable to acquire JDBC Connection` 오류가 발생합니다.

##### dev-pg 실행

```bash
set -a; source .env; set +a
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev-pg
```

```text
예상 결과
The following 1 profile is active: "dev-pg"
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Started SpringApplication in 4.x seconds
```

##### JAR 실행

```bash
java -jar -Dspring.profiles.active=h2 target/spring-0.0.1-SNAPSHOT.jar
java -jar -Dspring.profiles.active=dev-my target/spring-0.0.1-SNAPSHOT.jar
java -jar -Dspring.profiles.active=dev-pg target/spring-0.0.1-SNAPSHOT.jar
java -jar -Dspring.profiles.active=prod target/spring-0.0.1-SNAPSHOT.jar
```

```text
예상 결과
The following 1 profile is active: "<지정한 프로파일>"
기동 로그에서 활성 프로파일 이름과 Hikari 연결 풀 시작 여부를 확인합니다.
```

#### 5. 테스트와 프로파일을 같이 볼 때의 기준

이 저장소는 `src/test/resources/application.yml`과 `src/test/resources/application-dev-pg.yml`을 사용합니다.

- `src/test/resources/application.yml`: `spring.test.database.replace=none`
- `src/test/resources/application-dev-pg.yml`: `ddl-auto: create-drop`
즉, 이 프로젝트의 테스트 설명을 할 때는 막연히 `test` 프로파일을 가정하기보다, **테스트 리소스 파일이 어떤 프로파일을 보조하는지** 같이 봐야 합니다.

#### 6. DDL 전략을 읽는 기준

현재 저장소 기준으로 보면 다음처럼 이해하는 편이 정확합니다.

- `h2`: 빠른 실습용이므로 `create-drop`
- `dev-my`: 로컬 MySQL 실험용으로 `create-drop`
- `dev-pg`: 개발 DB를 유지하며 검증하기 위해 `update`
- `prod`: 운영 안정성을 위해 `validate`
여기서 중요한 점은 `create-drop`, `update`, `validate`를 추상적으로 외우는 것이 아니라, **어떤 환경에서 어떤 위험을 감수하는지와 함께 읽는 것**입니다.

#### 7. 프로파일 문서를 읽을 때 먼저 확인할 항목

- 현재 활성 프로파일이 무엇인가
- 실제로 어떤 `application-{profile}.yml`이 로드되는가
- DB URL이 어느 데이터베이스를 가리키는가
- 민감 정보가 파일 고정값인지 환경변수 주입인지
- DDL 전략이 현재 환경 목적과 맞는가
- SQL 로그 수준이 디버깅용인지 운영용인지
#### 8. 자주 하는 실수

- 저장소에는 없는 `local` 프로파일이 있다고 가정하는 것
- `dev-my`와 `dev-pg`를 같은 개발 환경으로만 뭉뚱그려 설명하는 것
- 운영 환경인데 `update` 같은 자동 변경 전략을 허용하는 것
- 테스트 설명에서 실제 `src/test/resources` 구성을 보지 않는 것
- 환경변수 주입 값을 문서에서 고정값처럼 오해하는 것
#### 공식 문서 기준으로 같이 보면 좋은 주제

- Spring Boot Externalized Configuration
- Spring Boot Profiles
- Spring Boot Testing
공식 문서는 프로파일별 설정 파일이 활성 프로파일에 따라 함께 로드된다는 구조와, 실행 시 프로파일을 바꾸는 방식을 기준으로 읽으면 됩니다.

#### 정리

프로파일 설정의 핵심은 이름을 외우는 데 있지 않습니다. **현재 저장소가 어떤 프로파일 파일을 가지고 있고, 그 프로파일이 DB·로그·DDL 전략을 어떻게 바꾸는지**를 정확히 읽는 데 있습니다. 이 프로젝트에서는 `h2`, `dev-my`, `dev-pg`, `prod`가 실제 기준선입니다.

#### 한 줄 정리

이 저장소의 프로파일 가이드는 일반론이 아니라, **`h2`를 기본으로 하고 `dev-my`, `dev-pg`, `prod`로 확장되는 실제 설정 구조**를 기준으로 이해해야 합니다.
