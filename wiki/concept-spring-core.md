---
title: Spring 핵심 개념 (IoC, DI, Bean, MVC)
type: concept
tags: [spring, ioc, di, bean, mvc]
sources: [java-study-ch05-Spring과프로젝트실행.md]
created: 2026-04-18
updated: 2026-04-18
---

# Spring 핵심 개념

## IoC vs DI

- **IoC**: 객체 생성과 연결의 제어권을 코드 바깥(컨테이너)으로 넘기는 관점
- **DI**: IoC를 실현하는 대표적 방법 — 생성자/메서드로 의존성 주입

생성자 주입이 기본값인 이유: 의존성이 드러나고, `final`로 불변성 유지가 쉽고, 테스트에서 직접 객체를 만들기 쉽다.

## Bean과 컨테이너

`@Component`, `@Service`, `@Repository`, `@Controller`로 등록한 객체는 Spring 컨테이너가 관리하는 Bean이다.

- 기본 스코프는 **싱글톤**
- Bean 안에 가변 상태를 들고 있으면 동시성 문제 발생 가능
- 직접 싱글톤 구현보다 **Bean 생명주기 이해**가 더 중요

## MVC 구조

`DispatcherServlet` → Controller(HTTP) → Service(유스케이스) → Repository(데이터) → DTO(형태 분리)

## AOP와 프록시

`@Transactional`, `@Async`, 보안은 모두 프록시 기반 AOP. 핵심은 **메서드 호출 앞뒤에 부가 동작이 끼어든다**는 모델을 이해하는 것.

## 관련 페이지

- [[entity-spring-boot]] — Spring Boot 프레임워크
- [[entity-spring-framework]] — Spring Framework
- [[concept-design-patterns]] — Spring에서 활용되는 패턴들
- [[src-spring-guide]] — 실무 가이드 (디렉터리 구조, 도메인, 예외, 서비스, API, 테스트)
- [[src-java-study-2024-2025]] — Java 스터디 교재 Ch5~Ch8
