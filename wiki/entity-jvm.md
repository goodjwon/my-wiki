---
title: JVM (Java Virtual Machine)
type: entity
tags: [java, jvm, gc, jit, memory, performance]
sources: [java-study/java-study-ch10-JVM과성능.md]
external:
  - https://docs.oracle.com/en/java/javase/21/vm/java-virtual-machine-technology-overview.html
  - https://docs.oracle.com/en/java/javase/21/gctuning/
created: 2026-04-18
updated: 2026-06-07
---

# JVM (Java Virtual Machine)

## 정의

Java 바이트코드(`.class`)를 실행하는 가상 머신. "Write Once, Run Anywhere"의 핵심. 같은 바이트코드를 Windows/Linux/macOS 어디서나 실행 가능하게 만든다.

JVM은 **명세(JVM Specification)** 이며, 실제 구현체는 여러 가지:

| 구현체 | 제공자 | 특징 |
|--------|--------|------|
| **HotSpot** | Oracle (OpenJDK) | 가장 보편적. JIT + GC 최강 |
| GraalVM | Oracle | Native Image(AOT) 가능, polyglot |
| OpenJ9 | Eclipse | 메모리 효율, 빠른 기동 |
| Zing | Azul | 저지연 GC 특화 |
| Amazon Corretto | AWS | OpenJDK 기반, LTS 무료 |

## 실행 흐름

```
.java  --[javac]-->  .class (바이트코드)
                          ↓
                   [클래스 로더] — 메모리 로드
                          ↓
                   [바이트코드 검증]
                          ↓
                   [실행 엔진]
                     · 인터프리터 (느림)
                     · JIT 컴파일러 (핫스팟 감지 → 네이티브 변환)
                          ↓
                       OS / CPU
```

## 메모리 영역

| 영역 | 무엇이 들어가나 | GC 대상 |
|------|---------------|---------|
| **Heap** | `new`로 만든 모든 객체 (Young + Old) | ✅ |
| **Stack** | 메서드 호출 프레임, 지역 변수, 참조 | ❌ (자동 해제) |
| **Metaspace** | 클래스 메타데이터, 메서드 코드 | △ |
| **PC Register** | 다음 명령 위치 | ❌ |
| **Native Method Stack** | JNI 네이티브 호출 | ❌ |

> **Java 8 이전의 PermGen → Metaspace로 교체**. 기본적으로 OS 메모리만큼 자동 확장 가능 (이전엔 OOM의 흔한 원인).

### Heap 세부 구조

```
Young Generation
 ├ Eden        — 새로 만든 객체가 여기로
 └ Survivor    — S0, S1 (Minor GC 살아남은 객체 왕복)
Old Generation (Tenured) — Survivor 왕복 후 Promotion
```

## GC (Garbage Collection)

### 세대별 GC 전제

> "대부분의 객체는 금방 죽는다(Weak Generational Hypothesis)."

→ **Young**(짧은 수명) 자주 작게 수집 / **Old**(긴 수명) 가끔 크게 수집.

### Young → Old 흐름

```
1. new Object()       → Eden 할당
2. Eden 가득          → Minor GC 발생
3. 살아남음           → Survivor (S0 또는 S1)으로 이동
4. Survivor 왕복      → MaxTenuringThreshold(기본 15) 도달
5. Old로 승격(Promotion)
6. Old 가득           → Major GC (또는 Full GC) 발생
```

### 주요 GC 알고리즘

| GC | 출시 | 특징 | 적합 |
|----|------|------|------|
| Serial | Java 1.0 | 단일 스레드, 작은 힙 | 컨테이너 작은 메모리 |
| Parallel | Java 5 | 멀티 스레드, 처리량 중심 | 배치 작업 |
| CMS | Java 5 | 동시 마킹 (Java 14에 제거) | (deprecated) |
| **G1** | Java 7 → Java 9 **기본** | Region 기반, 예측 가능한 정지 시간 | **대부분의 워크로드** |
| **ZGC** | Java 11+ | **저지연** (대부분의 정지 < 1ms) | 큰 힙 + 저지연 |
| **Shenandoah** | Java 12+ | 저지연, Red Hat | ZGC 대안 |

### GC 알고리즘 선택

```bash
java -XX:+UseG1GC ...           # G1 (Java 9+ 기본)
java -XX:+UseZGC ...            # ZGC (Java 15+ production)
java -XX:+UseShenandoahGC ...   # Shenandoah
java -XX:+UseParallelGC ...     # Parallel (throughput)
```

## JIT (Just-In-Time) 컴파일러

처음에는 **인터프리터**가 바이트코드를 한 줄씩 해석. 자주 호출되는 메서드(Hot Spot)를 감지하면 **JIT이 네이티브 코드로 컴파일** → 이후엔 빠른 네이티브로 실행.

HotSpot JVM의 2단계 JIT:

| 단계 | 이름 | 특징 |
|------|------|------|
| C1 | Client Compiler | 빠른 컴파일, 적당한 최적화 |
| C2 | Server Compiler | 느린 컴파일, 깊은 최적화 |

Java 7+ 기본 = **Tiered Compilation** (C1로 빠르게 시작 → 핫 메서드는 C2로 재컴파일).

대안: **AOT (Ahead-of-Time)** — GraalVM Native Image는 빌드 시 모든 코드를 네이티브로 컴파일. 기동 시간 매우 짧음(서버리스 친화), 단 리플렉션·동적 코드는 제약.

## 튜닝 핵심 옵션

```bash
# 힙 크기
-Xms512m              # 초기 힙 크기
-Xmx2g                # 최대 힙 크기
-XX:NewRatio=2        # Old/Young 비율 (기본 2 = Old가 2배)

# GC 로그 (운영 필수)
-Xlog:gc*:file=gc.log:time,uptime,level,tags:filecount=5,filesize=10m

# OOM 시 힙 덤프
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/var/log/myapp/

# Container-aware (Java 10+)
-XX:+UseContainerSupport            # 컨테이너 메모리 인식 (기본 켜져 있음)
-XX:MaxRAMPercentage=75.0           # 컨테이너 메모리의 75%를 힙으로
```

### Spring Boot 운영 권장

```bash
java -XX:+UseG1GC \
     -XX:MaxRAMPercentage=75.0 \
     -Xlog:gc*:file=/var/log/gc.log:time:filecount=5,filesize=10m \
     -XX:+HeapDumpOnOutOfMemoryError \
     -XX:HeapDumpPath=/var/log/heapdumps/ \
     -jar app.jar
```

## 모니터링 도구

| 도구 | 용도 |
|------|------|
| **VisualVM** | 무료 GUI, 힙·스레드·CPU 프로파일링 |
| **JFR** (Flight Recorder) | 운영 가능한 저오버헤드 프로파일러 (Java 11+ 무료) |
| **JConsole** | JMX 기반 모니터링 |
| **Eclipse MAT** | 힙 덤프 분석 (OOM 원인 추적) |
| **async-profiler** | flame graph, low overhead |
| **jstack** | 스레드 덤프 (`jstack <pid>`) |
| **jmap** | 힙 덤프 생성 (`jmap -dump:format=b,file=heap.hprof <pid>`) |
| **jstat** | GC 통계 (`jstat -gc <pid> 1s`) |

### Spring Boot Actuator

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health, metrics, prometheus, heapdump, threaddump
```

→ `/actuator/heapdump` 호출 시 `.hprof` 다운로드, Eclipse MAT으로 분석.

## 자주 마주치는 OOM 종류

| Error 메시지 | 원인 | 대처 |
|--------------|------|------|
| `Java heap space` | Heap 부족 (메모리 누수 또는 진짜 부족) | 힙 덤프 분석, `-Xmx` 증가 |
| `GC overhead limit exceeded` | GC가 98% 시간 차지하는데 2% 회수 | 힙 증가 또는 누수 수정 |
| `Metaspace` | 클래스 메타데이터 부족 | `-XX:MaxMetaspaceSize` 증가, 클래스 누수 의심 |
| `Direct buffer memory` | `ByteBuffer.allocateDirect` 누적 | NIO 사용 코드 점검 |
| `unable to create new native thread` | 스레드 수 한계 | 스레드 풀 점검, 컨테이너 ulimit |

## 같은 인사이트 패턴

| 영역 | 함정 | 해결 |
|------|------|------|
| **이 페이지: GC** | 디폴트 ParallelGC (Java 8 이하)는 정지 시간 김 | G1 또는 ZGC |
| **이 페이지: 컨테이너 메모리** | JVM이 호스트 메모리로 오인 | `+UseContainerSupport`(기본) + `MaxRAMPercentage` |
| [[concept-db-connection-pool]] | 풀 좀비 커넥션 | `maxLifetime` 타이머 |
| [[concept-keepalive-timeout-race]] | TCP 타임아웃 불일치 | 명시적 설정 |

## 원본 출처

- raw: `raw/java-study/java-study-ch10-JVM과성능.md`
- 공식: [Oracle — Java Virtual Machine Technology Overview](https://docs.oracle.com/en/java/javase/21/vm/java-virtual-machine-technology-overview.html)
- 공식: [HotSpot Garbage Collection Tuning Guide](https://docs.oracle.com/en/java/javase/21/gctuning/)

## 관련 페이지

- [[src-java-study-2024-2025]] — Ch09 JVM과 성능 (교재 원본)
- [[concept-spring-core]] — Spring Bean 싱글톤은 JVM 메모리 위에서 동작
- [[entity-spring-boot]] — Spring Boot 내장 서버도 JVM 위
- [[concept-oop]] — 객체 생성·GC는 OOP 설계와 직결
- [[concept-db-connection-pool]] — 같은 "자원 풀링" 메커니즘
