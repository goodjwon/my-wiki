---
title: "[2024-2025] Java 스터디 자료"
type: source
tags: [java, spring, study, notion]
sources: [java-study-ch00-안내.md, java-study-ch01-환경과실행.md, java-study-ch02-Java문법과객체.md, java-study-ch03-컬렉션과함수형.md, java-study-ch04-객체지향설계와패턴.md, java-study-ch05-Spring과프로젝트실행.md, java-study-ch06-데이터접근과SQL.md, java-study-ch07-서버와인증.md, java-study-ch08-테스트와품질.md, java-study-ch09-JVM과성능.md, java-study-ch10-입출력과네트워크.md, java-study-ch11-부록.md]
created: 2026-04-18
updated: 2026-04-18
---

# [2024-2025] Java 스터디 자료

## 개요

Notion 데이터베이스 기반의 Java 학습 교재로, 초중급 개발자를 대상으로 Java 기초부터 Spring Boot 실무까지 체계적으로 구성되어 있다. 총 91개 문서(12개 챕터)로 이루어져 있으며, 이론·가이드·실습·문제·풀이가 균형 있게 배치되어 있다.

## 챕터 구성

| 챕터 | 주제 | 핵심 내용 |
|------|------|----------|
| 0. 안내 | 읽는 순서·문서 포맷 | 학습 로드맵, Notion 뷰 운영 가이드 |
| 1. 환경과 실행 | [[concept-java-dev-environment]] | JDK/JRE 구분, IDE 선택, Hello World |
| 2. Java 문법과 객체 | [[concept-oop]] | 변수·연산자, 제어문, 메서드·배열, 객체지향 4원칙 |
| 3. 컬렉션과 함수형 | [[concept-collections-functional]] | 컬렉션 프레임워크, 제네릭, 람다, 스트림, 알고리즘 기초 |
| 4. 객체지향 설계와 패턴 | [[concept-design-patterns]] | 전략·템플릿·팩토리·싱글톤·옵저버·프록시·어댑터·파사드 |
| 5. Spring과 프로젝트 실행 | [[concept-spring-core]] | IoC, DI, Bean, MVC, 프로파일, Maven |
| 6. 데이터 접근과 SQL | [[entity-querydsl]] | DB 설계, SQL 기본기, Querydsl, 쿼리 최적화 |
| 7. 서버와 인증 | [[concept-spring-security]] | Tomcat, Spring Security, 토큰 기반 인증 |
| 8. 테스트와 품질 | [[concept-testing-strategy]] | 테스트 피라미드, JUnit 5, curl 검증 |
| 9. JVM과 성능 | [[entity-jvm]] | JVM 구조, 메모리 관리, GC 튜닝 |
| 10. 입출력과 네트워크 | 예외·파일·네트워크 | 예외 처리, 파일 I/O, JDBC, 네트워크 프로그래밍 |
| 11. 부록 | 면접·Git·프로젝트 | 컴퓨팅/네트워크 기초, 면접 질문, 미니프로젝트 |

## 교육 방법론 특징

- **Before/After 구조**: 디자인 패턴 문서마다 패턴 적용 전후 코드를 비교하여 직관적 이해 유도
- **실무 연결 포인트**: 각 문서 끝에 Spring 실무에서 해당 개념이 어떻게 쓰이는지 명시
- **한 줄 정리**: 모든 문서가 핵심을 한 문장으로 압축
- **`day_by_spring` 저장소 연동**: 실제 프로젝트 코드와 교재를 연결하여 학습

## 핵심 메시지

> "문법을 외우는 것이 아니라, 왜 그렇게 동작하는지 설명할 수 있어야 한다."

이 교재는 Java 문법 나열이 아닌, **책임 분리·구조 설계·실무 판단력**을 키우는 데 초점을 맞추고 있다.

## 관련 위키 페이지

- [[entity-spring-boot]] — 교재에서 다루는 주요 프레임워크
- [[entity-spring-framework]] — Spring 핵심 개념의 기반
- [[concept-oop]] — 객체지향 프로그래밍 핵심
- [[concept-design-patterns]] — 디자인 패턴 8가지
- [[concept-spring-core]] — IoC, DI, Bean, MVC
