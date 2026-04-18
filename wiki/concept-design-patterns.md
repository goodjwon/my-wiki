---
title: 디자인 패턴 (Java 스터디)
type: concept
tags: [java, design-pattern, oop, spring]
sources: [java-study-ch04-객체지향설계와패턴.md]
created: 2026-04-18
updated: 2026-04-18
---

# 디자인 패턴

## 개요

Java 스터디에서 다루는 8가지 디자인 패턴. 모든 패턴을 Before/After 코드로 비교하고 Spring 실무 연결점을 명시한다.

## 패턴 요약

| 패턴 | 핵심 | Spring 연결 |
|------|------|------------|
| **전략 (Strategy)** | 행위를 캡슐화하여 교체 가능하게 | DI, 결제/알림 처리기 |
| **템플릿 메서드** | 흐름은 고정, 세부만 교체 | `JdbcTemplate`, 배치 처리 |
| **팩토리 메서드** | 생성 책임을 분리 | Bean 생성, 파서 선택 |
| **싱글톤** | 인스턴스를 하나만 유지 | `@Component` 기본 스코프 |
| **옵저버** | 상태 변화를 느슨하게 전파 | `@EventListener`, 이벤트 발행 |
| **프록시** | 대리 객체로 공통 관심사 분리 | `@Transactional`, AOP |
| **어댑터** | 호환되지 않는 인터페이스 연결 | `HandlerAdapter`, API 래퍼 |
| **파사드** | 복잡한 서브시스템에 단순 진입점 | 서비스 조합, 외부 연계 흐름 |

## 공통 교훈

- 단순한 분기까지 패턴으로 만들면 **과한 설계**
- 패턴을 아는 것보다 **무엇을 분리할지 판단**하는 것이 더 중요
- Spring을 쓸 때 이미 많은 패턴이 프레임워크 안에 녹아 있음

## 관련 페이지

- [[concept-oop]] — 패턴의 기반이 되는 객체지향 원칙
- [[concept-spring-core]] — 패턴이 실무에서 적용되는 Spring 구조
