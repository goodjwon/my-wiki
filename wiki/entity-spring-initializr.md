---
title: Spring Initializr
type: entity
tags: [Java, Spring, 도구, 스캐폴딩]
sources: [spring/Spring Boot.md]
external: [https://start.spring.io, https://github.com/spring-io/initializr]
created: 2026-04-18
updated: 2026-05-31
---

# Spring Initializr

[[entity-spring-boot|Spring Boot]] 프로젝트를 빠르게 부트스트랩하는 웹 도구 + REST API + 확장 가능한 프레임워크. 의존성·빌드 도구·언어·버전을 선택하면 즉시 실행 가능한 프로젝트 스캐폴딩(ZIP)을 생성한다.

- **공식**: https://start.spring.io
- **소스**: https://github.com/spring-io/initializr (Apache 2.0)

## 생성 시 선택 옵션

| 항목 | 선택지 |
|------|--------|
| **Project** | Gradle (Groovy/Kotlin DSL) / Maven |
| **Language** | Java / Kotlin / Groovy |
| **Spring Boot version** | 안정/마일스톤/스냅샷 중 선택 |
| **Project Metadata** | Group, Artifact, Name, Description, Package name |
| **Packaging** | Jar / War |
| **Java version** | 17, 21, 24 등 |
| **Dependencies** | Spring Boot 스타터 검색·추가 (web, data-jpa, security, actuator 등 수백 개) |

## 생성되는 산출물

- 빌드 스크립트 (`build.gradle` / `pom.xml`) — 의존성과 플러그인 설정 완료
- 메인 애플리케이션 클래스 (`@SpringBootApplication`)
- 기본 테스트 클래스
- `.gitignore`
- 선택한 언어·패키지 구조에 맞는 디렉터리 트리

## 사용 경로

| 경로 | 명령/방법 |
|------|----------|
| **Web UI** | https://start.spring.io 접속 → 옵션 선택 → "Generate" |
| **Spring Boot CLI** | `spring init --dependencies=web,data-jpa demo` |
| **cURL / HTTPie** | `curl https://start.spring.io/starter.zip -d dependencies=web -o demo.zip` |
| **IDE 플러그인** | IntelliJ IDEA, VS Code (Spring Boot Extension Pack), NetBeans, STS |

## 셀프 호스팅·확장

Initializr는 **Spring Boot 기반 라이브러리**(`initializr-web` 모듈)로 제공되어 조직 내부에 자체 인스턴스로 배포 가능. 사내 BOM/사내 스타터를 카탈로그에 등록하면 팀 표준 프로젝트 생성기로 사용할 수 있다. 공식 `start.spring.io`도 이 라이브러리의 한 인스턴스에 불과.

확장 지점:
- **메타데이터**: 사용 가능한 의존성 카탈로그, Java/Boot 버전, 패키징, 컨벤션 정의
- **훅 포인트**: 생성 직전·직후 후처리 (커스텀 파일 추가, 환경별 설정 등)
- **REST 엔드포인트**: `/starter.zip`, `/metadata/client` 등

## 원본 출처

- raw: `raw/spring/Spring Boot.md` (공식 소개 페이지 클리핑)
- 외부: [start.spring.io](https://start.spring.io), [github.com/spring-io/initializr](https://github.com/spring-io/initializr)

## 관련

- [[entity-spring-boot]] — Initializr가 생성하는 프로젝트의 기반 프레임워크
- [[entity-spring-framework]] — Spring Boot의 기반 코어
- [[src-spring-boot]] — Spring Boot 공식 소개 페이지 요약
- [[concept-spring-core]] — IoC, DI, Bean — Initializr가 깔아주는 프로젝트의 핵심 패턴
