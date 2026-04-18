---
title: JVM (Java Virtual Machine)
type: entity
tags: [java, jvm, 성능]
sources: [java-study-ch09-JVM과성능.md]
created: 2026-04-18
updated: 2026-04-18
---

# JVM (Java Virtual Machine)

## 정의

Java 바이트코드를 실행하는 가상 머신. Java의 "Write Once, Run Anywhere" 철학의 핵심이다.

## 구성 요소

- **클래스 로더**: `.class` 파일을 메모리에 적재
- **실행 엔진**: 바이트코드 → 네이티브 코드 변환 (JIT 컴파일러)
- **메모리 영역**: Heap, Stack, Method Area, PC Register

## 메모리 관리

- **Heap**: 객체 인스턴스가 생성되는 영역, GC 대상
- **Stack**: 메서드 호출 프레임, 지역 변수
- **GC**: Young → Old 세대별 수집, G1GC가 현재 기본

## 튜닝 포인트

- Heap 크기 설정 (`-Xms`, `-Xmx`)
- GC 알고리즘 선택
- 모니터링: VisualVM, JFR, GC 로그

## 관련 페이지

- [[src-java-study-2024-2025]] — JVM 기초 가이드 1~3
