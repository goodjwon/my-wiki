---
title: "Java 스터디 — 부록"
type: source
tags: [java, study, notion, ch11]
sources: [java-study/java-study-ch11-부록.md]
created: 2026-04-18
updated: 2026-06-30
---

> 📘 [[src-java-study-2024-2025]] 원본 교재의 11장 본문. 학습 흐름은 [[guide-java-learning-path]] 참조.

# 부록

## 🎯 이 장에서 배우는 것

- 컴퓨팅·네트워크·스레드 등 기초 토대 보강
- 면접 질문·Git·포트폴리오 등 실무 준비
- [PJ] 종합 토이프로젝트로 전체 통합

**단계**: 3단계 — 고급·품질 · **앞 장**: [[java-study-ch09]] · **학습 경로**: [[guide-java-learning-path]]

> **따라 하는 법**: 위에서 아래로 읽으며 코드를 직접 쳐본다. 약한 곳을 골라 보강하고, 11.19·11.22·11.25 등 토이프로젝트 하나를 README까지 완성한다.

---

원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 11.1 기초 리소스에 대한 이해

**🎯 목표**: 개발에 필요한 기초 리소스가 무엇인지 파악한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 책 본문 밖에서 찾아보는 참고 리소스를 한곳에 묶어 둔 안내 페이지입니다.
본문 흐름을 끊지 않기 위해 부록으로 분리했고, 막히는 지점이 생길 때만 필요한 문서를 골라 보는 방식으로 사용합니다.

### 포함된 자료
- 11.2 컴퓨팅 구조 (→ 11.2)
- 11.3 네트워크 구조 (→ 11.3)
- 11.4 개발자 기본 지식 (→ 11.4)
- 11.13 기술면접 예상질문 (→ 11.13)
- 11.14 Java 면접 질문 (→ 11.14)
- 11.16 스레드와 동기화 기초 (→ 11.16)
- 11.15 Git 기초 (→ 11.15)
- 11.18 GitHub 작업 순서 가이드 (→ 11.18)
- 11.21 JSP 기본 개념 (→ 11.21)
- 11.11 DBMS와 RDBMS 개요 (→ 11.11)
- 11.12 트랜잭션과 시스템 카탈로그 개요 (→ 11.12)
- 11.17 포트폴리오 예제 (→ 11.17)
- 11.21 Swagger 설정 가이드

### 언제 무엇을 보면 되는가
- JVM, 메모리, CPU가 막히면 `11.2 컴퓨팅 구조`를 봅니다.
- 소켓, HTTP, DNS, TLS가 막히면 `11.3 네트워크 구조`를 봅니다.
- 스레드, synchronized, interrupt, BlockingQueue 흐름이 헷갈리면 `11.16 스레드와 동기화 기초`를 봅니다.
- CS 전반을 한 문서에서 훑고 싶으면 `11.4 개발자 기본 지식`을 봅니다.
- 면접형 질문으로 빠르게 점검하려면 `11.13 기술면접 예상질문`과 `11.14 Java 면접 질문`을 봅니다.
- Git 사용이 막히면 `11.15 Git 기초`를 봅니다.
- 이슈, 브랜치, 커밋, 라벨, Projects 흐름이 헷갈리면 `11.18 GitHub 작업 순서 가이드`를 봅니다.
- JSP와 서버 렌더링의 옛 구조를 비교하고 싶으면 `11.21 JSP 기본 개념`을 봅니다.
- DBMS, RDBMS, NoSQL 구분이 헷갈리면 `11.11 DBMS와 RDBMS 개요`를 봅니다.
- 트랜잭션, ACID, 시스템 카탈로그가 헷갈리면 `11.12 트랜잭션과 시스템 카탈로그 개요`를 봅니다.
- 학습 결과물의 배치 예시가 필요하면 `11.17 포트폴리오 예제`를 봅니다.

### 편집 원칙
- 이 묶음은 책 본문에 직접 포함하지 않습니다.
- 본문에 이미 정리된 주제는 여기서 반복 설명하지 않고 유지본으로 연결합니다.
- 계층은 하위 페이지가 아니라 데이터베이스 속성과 `상위 문서`로 유지합니다.
```text
예상 결과
독자는 막히는 주제가 생겼을 때 필요한 참고 문서로만 빠르게 이동할 수 있다.
본문 원고와 참고 리소스가 섞이지 않아 읽는 흐름이 무너지지 않는다.
```

### 한 줄 정리
이 묶음은 책 전체를 받쳐 주는 참고 리소스 허브입니다.

## 11.2 컴퓨팅 구조

**🎯 목표**: 컴퓨팅 구조(CPU·메모리·저장장치)의 기본을 이해한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 CPU, 메모리, 캐시, 저장장치, 운영체제의 기본 구조를 빠르게 다시 잡기 위한 참고 문서입니다.
JVM과 성능 문서를 읽다가 하드웨어와 운영체제 기초가 흔들릴 때만 골라 보는 방식으로 사용합니다.

### 핵심 주제

#### 1. CPU와 명령 실행
- 명령어는 가져오기, 해석, 실행 흐름으로 처리됩니다.
- 레지스터와 캐시는 CPU가 자주 쓰는 데이터를 빠르게 다루기 위한 장치입니다.

#### 2. 메모리와 저장장치
- RAM은 실행 중인 데이터를 잠시 두는 공간이고, SSD/HDD는 오래 저장하는 공간입니다.
- 성능 문제를 볼 때는 CPU, 메모리, 디스크 중 어디가 병목인지 구분해야 합니다.

#### 3. 프로세스와 운영체제
- 운영체제는 프로세스, 스레드, 메모리, 파일, 입출력을 관리합니다.
- 시스템 콜은 사용자 프로그램이 운영체제 기능을 요청하는 통로입니다.

#### 4. 캐시와 지역성
- 캐시는 자주 접근하는 데이터를 더 가까운 곳에 두어 속도를 높입니다.
- 시간 지역성과 공간 지역성이 핵심입니다.

### 유지본 연결
- JVM 관점으로 이어서 읽기: JVM 기초 가이드 1: 개념과 구성 원리 (→ 9.0)
- 메모리 문제로 이어서 읽기: JVM 기초 가이드 2: 메모리 관리 (→ 9.1)
- 튜닝 관점으로 이어서 읽기: JVM 기초 가이드 3: 튜닝과 실전 활용 (→ 9.2)

### 체크 포인트
- CPU와 메모리의 역할을 분리해서 설명할 수 있는가
- 캐시가 왜 빠른지 참조 지역성으로 설명할 수 있는가
- 프로세스와 스레드의 차이를 운영체제 관점에서 설명할 수 있는가

### 한 줄 정리
이 문서는 JVM과 성능 문서를 이해하기 위한 컴퓨팅 기초 복습 노트입니다.

## 11.3 네트워크 구조

**🎯 목표**: 네트워크 구조의 기본을 이해한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 네트워크 계층, TCP/UDP, HTTP, DNS, TLS 같은 핵심 개념을 빠르게 다시 잡기 위한 참고 문서입니다.
서버, 인증, 통신 문서를 읽다가 네트워크 기초가 흔들릴 때만 필요한 부분을 찾아보는 용도로 사용합니다.

### 핵심 주제

#### 1. 계층 구조
- 네트워크는 링크 계층, IP 계층, 전송 계층, 응용 계층으로 나누어 생각하면 이해가 쉬워집니다.
- 각 계층은 바로 아래 계층의 기능 위에서 동작합니다.

#### 2. IP와 포트
- IP는 어느 호스트로 갈지 결정하고, 포트는 그 호스트 안의 어느 프로세스로 갈지 구분합니다.
- 개발자가 보는 오류의 상당수는 주소, 포트, 방화벽, DNS 중 하나에서 시작됩니다.

#### 3. TCP와 UDP
- TCP는 연결, 순서 보장, 재전송을 제공하고, UDP는 연결 없이 빠르게 전달합니다.
- 신뢰성이 중요한 API 통신은 대체로 TCP 위의 HTTP를 사용합니다.

#### 4. HTTP와 HTTPS
- HTTP는 요청-응답 프로토콜이고, HTTPS는 TLS를 더해 전송 구간을 보호한 형태입니다.
- 상태 코드는 서버가 요청 결과를 어떻게 처리했는지 알려 주는 계약입니다.

### 유지본 연결
- 소켓 프로그래밍: 네트워크 프로그래밍 기초 (→ 10.5)
- 서버와 실행 환경: Tomcat 실행과 설정 (→ 7.0)
- 인증 흐름: Spring Security 인증 흐름 (→ 7.1)
- 토큰 기반 인증: 토큰 기반 인증 (→ 7.3)

### 체크 포인트
- IP와 포트의 역할을 구분할 수 있는가
- TCP와 UDP를 실제 사례로 설명할 수 있는가
- HTTP와 HTTPS의 차이를 보안 관점에서 설명할 수 있는가
- DNS가 왜 필요한지 설명할 수 있는가

### 한 줄 정리
이 문서는 서버와 인증 파트를 떠받치는 네트워크 기초 복습 노트입니다.

## 11.4 개발자 기본 지식

**🎯 목표**: 개발자가 갖춰야 할 기본 지식을 점검한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 운영체제, 네트워크, 데이터베이스, 자료구조처럼 개발자가 오래 가져가야 할 CS 주제를 한 번에 훑는 참고 가이드입니다.
다만 본문 유지본이 이미 따로 있으므로, 이 문서는 긴 강의노트를 반복하지 않고 읽기 지도를 제공하는 역할로 압축합니다.

### 어디까지 다루는가
- 컴퓨터 구조와 메모리
- 운영체제와 프로세스, 스레드
- 네트워크와 HTTP
- 데이터베이스와 인덱스, 정규화
- 자료구조와 알고리즘의 기본 관점

### 유지본 문서 지도
- 컴퓨터 구조와 메모리: 11.2 컴퓨팅 구조 (→ 11.2), 9.0 JVM 기초 가이드 1: 개념과 구성 원리 (→ 9.0), 9.1 JVM 기초 가이드 2: 메모리 관리 (→ 9.1)
- 네트워크: 11.3 네트워크 구조 (→ 11.3), 10.5 네트워크 프로그래밍 기초 (→ 10.5)
- 데이터베이스: 6.0 데이터베이스 설계 (→ 6.0), 10.6 JDBC 기초 (→ 10.6), 6.3 쿼리 최적화 (→ 6.3)
- 자료구조와 컬렉션: 3.2 컬렉션 프레임워크와 제네릭 (→ 3.1), 3.1 컬렉션 자료구조 활용 사례 (→ 3.2)

### 빠른 점검 질문
- CPU와 메모리의 역할을 구분해서 설명할 수 있는가
- 프로세스와 스레드의 차이를 말할 수 있는가
- TCP와 UDP의 차이를 말할 수 있는가
- 인덱스를 왜 설계의 일부로 봐야 하는지 설명할 수 있는가
- 정규화와 역정규화의 기준을 말할 수 있는가

### 사용 원칙
- 처음부터 끝까지 정독하기보다 막힌 개념을 다시 잡는 용도로 사용합니다.
- 자세한 설명은 각 유지본 문서에서 확인합니다.
- 면접형 복습이 필요하면 기술면접 예상질문 (→ 11.13)으로 이어갑니다.

### 한 줄 정리
이 문서는 CS 전반의 원고 저장소가 아니라, 핵심 주제를 다시 연결해 주는 참고 지도입니다.

## 11.9 오프라인 게임 파일 처리 시스템 과제

**🎯 목표**: 오프라인 게임 파일 처리 과제로 입출력을 종합한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 파일 처리 실습을 하나의 과제 흐름으로 묶어 둔 유지본입니다. 중복되던 `파일처리 오프라인 게임 토이 프로젝트` 초안은 이 문서로 통합했고, 서버 동기화가 섞인 확장 버전은 온라인 게임 토이 프로젝트 (→ 11.19)로 분리했습니다.

### 이 문서를 언제 보는가
- 파일 생성, 읽기, 로그 기록, 백업 같은 I/O 흐름을 한 프로젝트에서 연습하고 싶을 때
- 네트워크 없이도 끝까지 구현할 수 있는 실습이 필요할 때
- 파일 처리와 도메인 상태 갱신을 함께 묶어 보고 싶을 때

### 이 과제의 목표
이 과제의 핵심은 게임 자체가 아니라 파일 처리 패턴을 익히는 것입니다. 즉 아래 흐름을 끊김 없이 구현하는 것이 목표입니다.
- 상태 파일 생성 또는 로드
- 활동 로그 기록
- 종료 시 저장과 백업
- JSON 리소스 읽기
```text
예상 결과
독자는 이 문서를 통해 파일 생성, 로그 적재, 백업, JSON 로드가 각각 따로 노는 기능이 아니라 하나의 실행 흐름으로 연결된다는 점을 보게 된다.
온라인 동기화나 서버 설계 없이도 파일 처리만으로 충분한 실습 과제를 만들 수 있다는 기준도 잡을 수 있다.
```

### 권장 진행 순서

#### 1. 플레이어 데이터 파일 생성 및 로드
- `player_data.txt` 존재 여부 확인
- 파일이 없으면 초기 데이터 생성
- 파일이 있으면 유저 상태 출력

#### 2. 활동 로그 파일 생성 및 기록
- `game_log.txt` 생성
- 던전 진입, 전투 결과, 종료 시점 로그 기록
- 시간 정보 포함

#### 3. 로그 파일 백업
- `backup/` 디렉터리 생성
- 종료 시 `game_log.txt`를 날짜 기반 이름으로 이동

#### 4. 맵 데이터 JSON 로드
- 클래스패스에서 `map_data.json` 읽기
- JSON을 Java 객체로 파싱
- 맵, 몬스터, 보스 정보를 메모리에 적재

#### 5. 게임 흐름 연결
- 던전 진입
- 전투 결과 반영
- 저장 및 종료

### 우선순위를 읽는 법
- 높음: 파일 입출력 핵심 흐름이므로 먼저 구현
- 중간: 백업, 종료 처리처럼 흐름 완성도를 높이는 단계
- 낮음: 유지보수 자동화나 데이터 확장 단계

### 구현 후 확인해야 할 산출물
- `player_data.txt`가 생성되는가
- `game_log.txt`에 시간 포함 로그가 남는가
- 종료 후 `backup/`에 백업 파일이 생기는가
- JSON 리소스를 읽어 맵/몬스터 정보를 출력할 수 있는가
```text
예상 결과
처음 실행하면 기본 플레이어 파일이 생성된다.
플레이 도중에는 활동 로그가 누적된다.
종료 후에는 백업 파일이 생성되고, 다음 실행에서 기존 상태를 다시 읽을 수 있어야 한다.
```

### 온라인 버전과의 경계
- 이 문서는 파일 처리 중심의 오프라인 실습입니다.
- 서버 동기화, 다중 사용자, 충돌 해결은 다루지 않습니다.
- 그 확장 버전은 온라인 게임 토이 프로젝트 (→ 11.19)에서 따로 봅니다.

### 정리
이 과제는 게임 장르를 빌려 왔지만, 실제 학습 축은 파일 I/O와 리소스 로딩입니다. 작은 도메인을 빌려 파일 생성, 로그 기록, 백업, JSON 파싱을 끝까지 이어 보는 것이 핵심입니다.

### 한 줄 정리
오프라인 게임 파일 처리 과제의 핵심은 **게임 로직보다 파일 생성, 기록, 백업, 리소스 로딩 흐름을 끝까지 구현하는 것**입니다.

## 11.10 미니프로젝트 과제 정리

**🎯 목표**: 미니프로젝트 과제 구성을 파악한다.

#### 개요

이 문서는 본문에서 배운 요구사항 분석, DB 설계, 객체 모델링을 프로젝트 단위로 묶어 보는 부록 실습 안내문입니다. 아래 항목은 단순 기능 목록이 아니라, 실제로 기능 명세서, 테이블 설계, API 설계, 테스트 시나리오로 확장할 수 있는 미니프로젝트 재료로 사용합니다.

#### 이 문서를 언제 보는가

- 본문 개념을 읽었지만 실제로 어떻게 묶어 프로젝트로 전개할지 막힐 때
- 요구사항, 테이블, 클래스, API를 한 번에 연결하는 연습이 필요할 때
- 작은 토이프로젝트를 어떤 기준으로 시작해야 할지 기준점이 필요할 때
#### 연결된 프로젝트

- 11.25 [PJ]블로그 작성하기 미니프로젝트 (→ 11.25)
- 11.19 [PJ]온라인 게임 토이 프로젝트 (→ 11.19)
- 11.26 [PJ]메모 앱 토이프로젝트 (→ 11.26)
#### 프로젝트를 고를 때 먼저 볼 기준

- 콘솔 입출력 위주로 시작하고 싶다: 메모 앱
- 사용자, 게시글, 댓글처럼 CRUD 도메인을 연습하고 싶다: 블로그
- 상태, 이벤트, 규칙이 많은 구조를 연습하고 싶다: 게임형 프로젝트
#### 예시 과제 축

##### 1. 사용자 관리

- 회원가입, 로그인, 로그아웃 기능
- 프로필 수정 기능
- 관리자의 사용자 관리 기능
##### 2. 게시글 관리

- 게시글 작성, 수정, 삭제 기능
- 게시글 목록 조회, 상세 조회 기능
- 카테고리별 게시글 조회 기능
- 게시글 검색 기능
##### 3. 댓글 관리

- 댓글 작성, 수정, 삭제 기능
- 게시글별 댓글 목록 조회 기능
##### 4. 카테고리 관리

- 카테고리 생성, 수정, 삭제 기능
- 카테고리 목록 조회 기능
#### 기능 명세를 만들 때의 최소 형식

기능을 바로 코드로 옮기지 말고 아래 네 줄부터 먼저 정리합니다.

- 누가 사용하는가
- 입력은 무엇인가
- 성공 결과는 무엇인가
- 실패 조건은 무엇인가
예를 들면 회원가입은 아래처럼 적을 수 있습니다.

- 사용자: 신규 방문자
- 입력: 이메일, 비밀번호, 이름, 닉네임
- 성공 결과: 회원 생성 완료
- 실패 조건: 이메일 중복, 형식 오류
```text
예상 결과
문서화 단계에서 기능 하나마다 입력, 성공 결과, 실패 조건이 구분된다.
이 구분이 되어 있어야 이후 DB 컬럼, DTO, 검증 규칙, 테스트 케이스로 자연스럽게 이어진다.
```

#### DB 모델링 초안

##### Users

- `user_id` (PK)
- `email`
- `password`
- `name`
- `nickname`
- `role`
- `created_at`
- `updated_at`
##### Categories

- `category_id` (PK)
- `name`
- `created_at`
- `updated_at`
##### Posts

- `post_id` (PK)
- `title`
- `content`
- `user_id` (FK)
- `category_id` (FK)
- `view_count`
- `created_at`
- `updated_at`
##### Comments

- `comment_id` (PK)
- `content`
- `post_id` (FK)
- `user_id` (FK)
- `created_at`
- `updated_at`
#### 객체 모델링으로 옮길 때 볼 포인트

- 테이블 컬럼을 그대로 필드로 복사하는 데서 끝내지 않습니다.
- 객체가 직접 책임질 동작을 같이 적습니다.
- 연관 관계가 많아질수록 조회 전략과 수정 책임을 분리합니다.
예를 들어 `Post`는 단순히 `title`, `content`를 갖는 데이터 묶음이 아니라, 수정 권한 확인, 조회수 증가, 댓글 연결 같은 동작 후보를 품고 있습니다.

#### 주요 SQL 또는 API로 확장하는 방법

- `회원가입` -> `INSERT INTO users ...`
- `게시글 목록` -> `SELECT ... FROM posts JOIN users ...`
- `게시글 검색` -> 제목/내용 기준 `LIKE` 또는 전문 검색 전략
- `댓글 작성` -> `INSERT INTO comments ...`
```text
예상 결과
기능 명세, 테이블, 객체, SQL이 각각 따로 노는 것이 아니라 같은 요구사항을 다른 층위에서 표현한 문서로 정리된다.
독자는 프로젝트를 시작할 때 무엇부터 써야 하는지 순서를 잡을 수 있다.
```

#### 권장 진행 순서

1. 프로젝트 하나를 고릅니다.
1. 핵심 사용자 시나리오 3개만 먼저 적습니다.
1. 기능 명세를 입력/성공/실패 기준으로 나눕니다.
1. 테이블 초안을 만듭니다.
1. 핵심 엔티티와 책임을 적습니다.
1. 가장 짧은 API 또는 콘솔 기능 하나를 구현합니다.
1. 테스트 시나리오를 붙입니다.
#### 정리

이 문서는 완성 답안을 주는 부록이 아니라, 본문에서 배운 개념을 실제 프로젝트 재료로 변환하는 출발점입니다. 핵심은 기능 목록을 늘리는 것이 아니라, 요구사항과 데이터 구조와 코드 책임을 한 줄기로 묶는 것입니다.

#### 한 줄 정리

미니프로젝트의 핵심은 **기능 목록을 많이 적는 것이 아니라, 요구사항과 DB와 객체와 테스트를 같은 흐름으로 연결하는 것**입니다.


---

## 11.11 DBMS와 RDBMS 개요

**🎯 목표**: DBMS와 RDBMS의 개념을 이해한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 책 본문을 읽다가 `DBMS`, `RDBMS`, `NoSQL` 같은 용어가 헷갈릴 때 빠르게 다시 보기 위한 참고 문서입니다. 본문 중심 설명은 데이터베이스 설계 (→ 6.0)에 두고, 이 문서는 개념 구분만 간결하게 정리합니다.

### DBMS란 무엇인가
DBMS(Database Management System)는 애플리케이션과 데이터 저장소 사이에서 데이터를 정의하고, 읽고, 바꾸고, 보호하는 소프트웨어입니다.
핵심 역할은 세 가지로 보면 됩니다.
- 구조를 정의한다.
- 데이터를 읽고 바꾼다.
- 무결성, 권한, 동시성, 복구를 관리한다.
즉, Java 애플리케이션이 직접 파일을 만지는 대신 DBMS를 통해 데이터를 다룬다고 이해하면 됩니다.

### RDBMS는 무엇이 다른가
RDBMS는 데이터를 테이블과 관계로 다루는 DBMS입니다.
- 행과 열 구조를 사용한다.
- PK, FK, UNIQUE, CHECK 같은 제약조건을 둘 수 있다.
- JOIN으로 여러 테이블을 함께 조회한다.
- SQL이 기본 언어다.
실무에서 Java 서비스가 가장 자주 만나는 저장소는 여전히 RDBMS입니다. PostgreSQL, MySQL, Oracle, SQL Server가 대표적입니다.

### NoSQL은 언제 같이 언급되는가
NoSQL은 관계보다 확장성, 문서 구조, 키-값 접근, 그래프 탐색 같은 방식에 초점을 둔 저장소 묶음입니다.
- 관계형 설계보다 유연한 스키마가 필요할 때
- 매우 큰 트래픽과 분산 저장이 중요할 때
- 문서 단위 저장이 자연스러운 도메인일 때
다만 초중급 Java 개발자가 먼저 단단히 잡아야 하는 축은 보통 RDBMS입니다.

### Java 개발자 관점에서 왜 알아야 하나
- JDBC는 결국 DBMS와 연결하는 표준 인터페이스입니다.
- JPA와 Querydsl도 내부적으로는 RDBMS와 SQL 위에서 동작합니다.
- 트랜잭션, 잠금, 제약조건, 인덱스는 DBMS 관점 없이 이해하기 어렵습니다.
그래서 DBMS는 별도 시험용 용어가 아니라, 데이터 접근 계층의 바닥 개념입니다.

### 최소 구분 기준
- DBMS: 데이터베이스를 관리하는 소프트웨어 전체
- RDBMS: 테이블과 관계, SQL 중심의 DBMS
- NoSQL: 비관계형 저장소 계열

### 함께 보면 좋은 문서
- 데이터베이스 설계 (→ 6.0)
- SQL 기본기: DDL, DML, JOIN, 집계 (→ 6.2)
- JDBC 기초 (→ 10.6)

### 한 줄 정리
DBMS는 데이터를 관리하는 운영체제에 가깝고, RDBMS는 그중에서 Java 서비스가 가장 자주 만나는 테이블 기반 저장소입니다.

## 11.12 트랜잭션과 시스템 카탈로그 개요

**🎯 목표**: 트랜잭션과 시스템 카탈로그의 개념을 이해한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 데이터베이스를 공부하다가 `트랜잭션`, `ACID`, `COMMIT`, `ROLLBACK`, `시스템 카탈로그` 같은 용어가 헷갈릴 때 다시 보는 참고 문서입니다. 책 본문에서 데이터 접근과 SQL을 읽을 때 필요한 최소 개념만 간결하게 정리합니다.

### 트랜잭션이란 무엇인가
트랜잭션은 데이터베이스에서 하나의 논리적 작업 단위를 뜻합니다. 예를 들어 주문 생성은 보통 아래 동작이 함께 성공하거나 함께 실패해야 합니다.
- 주문 생성
- 주문 항목 저장
- 재고 차감
- 결제 상태 반영
이 묶음을 중간까지만 반영하면 데이터가 깨질 수 있습니다. 그래서 DB는 트랜잭션 경계를 두고 `COMMIT` 또는 `ROLLBACK`으로 결과를 확정합니다.

### ACID는 왜 중요한가
트랜잭션은 보통 네 가지 성질로 설명합니다.
- Atomicity: 전부 성공하거나 전부 실패해야 한다.
- Consistency: 제약조건을 깨지 않는 상태를 유지해야 한다.
- Isolation: 동시에 실행되는 작업끼리 서로를 함부로 오염시키지 않아야 한다.
- Durability: 커밋된 결과는 장애가 나도 보존되어야 한다.
Java 서비스에서 `@Transactional`을 쓰는 이유도 결국 이 성질을 코드 레벨에서 다루기 위해서입니다.

### COMMIT과 ROLLBACK
- `COMMIT`: 트랜잭션 결과를 확정한다.
- `ROLLBACK`: 트랜잭션 중간 변경을 취소한다.
즉, 변경 SQL은 한 줄만 보지 말고 어떤 트랜잭션 안에서 실행되는지 같이 봐야 합니다.

### 시스템 카탈로그는 무엇인가
시스템 카탈로그는 데이터베이스가 자기 자신의 구조 정보를 저장하는 메타데이터 저장소입니다.
여기에는 보통 아래 정보가 들어 있습니다.
- 테이블
- 컬럼
- 인덱스
- 제약조건
- 사용자와 권한
- 뷰와 기타 객체 정보
즉, DBMS가 "이 테이블이 존재하는가", "이 컬럼 타입은 무엇인가", "이 인덱스가 있는가"를 아는 근거가 시스템 카탈로그입니다.

### Java 개발자에게 왜 필요한가
- 트랜잭션을 모르면 서비스 계층의 저장 로직을 안전하게 설계하기 어렵습니다.
- 시스템 카탈로그를 이해하면 마이그레이션, 스키마 조회, ORM 동작 방식을 더 잘 읽을 수 있습니다.
- 장애나 배포 이슈가 생겼을 때도 결국 트랜잭션과 메타데이터 관점이 필요합니다.

### 함께 보면 좋은 문서
- DBMS와 RDBMS 개요 (→ 11.11)
- 데이터베이스 설계 (→ 6.0)
- SQL 기본기: DDL, DML, JOIN, 집계 (→ 6.2)
- JDBC 기초 (→ 10.6)

### 한 줄 정리
트랜잭션은 변경의 안전장치이고, 시스템 카탈로그는 데이터베이스 구조를 설명하는 내부 설명서입니다.

## 11.13 기술면접 예상질문

**🎯 목표**: 기술 면접 예상 질문을 내 말로 설명한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 CS 전반을 면접형 질문과 짧은 답변으로 점검하는 참고 문서입니다.
길게 다시 읽고 싶을 때는 개발자 기본 지식 (→ 11.4)을, 빠르게 확인할 때는 이 문서를 사용합니다.

### 질문과 짧은 답변

#### 1. 프로세스와 스레드의 차이는 무엇인가
프로세스는 독립된 메모리 공간을 가진 실행 단위이고, 스레드는 같은 프로세스 안에서 자원을 공유하며 실행되는 작업 단위입니다.

#### 2. TCP와 UDP의 차이는 무엇인가
TCP는 연결, 순서 보장, 재전송을 제공하는 신뢰성 중심 프로토콜이고, UDP는 연결 없이 빠르게 보내는 속도 중심 프로토콜입니다.

#### 3. HTTP가 스테이트리스라는 말은 무엇인가
각 요청이 독립적으로 처리되고, 서버가 이전 요청의 상태를 기본적으로 기억하지 않는다는 뜻입니다.

#### 4. 인덱스는 왜 성능을 높이는가
조건 검색과 정렬에 필요한 탐색 범위를 줄여 디스크 접근 비용을 낮추기 때문입니다.

#### 5. 정규화는 왜 필요한가
중복 데이터를 줄이고 갱신 이상을 막아 데이터 무결성을 높이기 위해 필요합니다.

#### 6. 캐시가 빠른 이유는 무엇인가
CPU에 더 가까운 빠른 저장소에 자주 쓰는 데이터를 올려 두기 때문입니다. 핵심 원리는 참조 지역성입니다.

#### 7. 교착 상태가 발생하는 대표 조건은 무엇인가
상호 배제, 점유와 대기, 비선점, 환형 대기가 함께 성립할 때 발생할 수 있습니다.

#### 8. 시스템 콜은 왜 필요한가
사용자 프로그램이 파일, 네트워크, 프로세스 같은 운영체제 자원에 안전하게 접근하려면 커널 기능을 호출해야 하기 때문입니다.

#### 9. 트랜잭션의 핵심은 무엇인가
여러 작업을 하나의 논리 단위로 묶고, 모두 성공하거나 모두 실패하게 만들어 데이터 일관성을 지키는 것입니다.

#### 10. 로드 밸런싱은 왜 쓰는가
트래픽을 여러 서버에 분산해 가용성과 처리량을 높이고 특정 서버 과부하를 막기 위해 사용합니다.

### 연결 문서
- 컴퓨터 구조: 컴퓨팅 구조 (→ 11.2)
- 네트워크: 네트워크 구조 (→ 11.3)
- 데이터베이스: 데이터베이스 설계 (→ 6.0)

### 한 줄 정리
이 문서는 CS 전반을 면접 답변 길이로 빠르게 점검하는 체크리스트입니다.

## 11.14 Java 면접 질문

**🎯 목표**: Java 면접 질문을 개념과 연결해 답한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 Java 언어, 객체지향, SOLID, 예외, 메모리 같은 주제를 면접형 질문으로 빠르게 점검하는 참고 문서입니다.
긴 설명이 필요하면 본문 유지본으로 돌아가고, 여기서는 짧고 정확하게 답하는 연습에 집중합니다.

### 질문과 짧은 답변

#### 1. Java의 장점은 무엇인가
JVM 위에서 동작해 운영체제 의존성이 낮고, 라이브러리 생태계가 넓으며, 메모리 관리와 예외 처리 같은 언어 차원의 기본기가 잘 갖춰져 있습니다.

#### 2. 클래스와 객체의 차이는 무엇인가
클래스는 상태와 행동을 정의한 설계도이고, 객체는 그 설계도로부터 생성된 실행 시점의 실체입니다.

#### 3. 캡슐화가 왜 중요한가
객체 내부 상태를 직접 노출하지 않고 책임 있는 메서드로만 다루게 만들어 변경 영향을 줄이고 불변식을 지키기 쉽기 때문입니다.

#### 4. 상속보다 합성을 우선하라는 말은 무슨 뜻인가
코드 재사용을 위해 무리하게 계층을 만들기보다, 필요한 기능을 가진 객체를 조합해 결합도를 낮추라는 뜻입니다.

#### 5. 다형성은 실무에서 어떻게 쓰이는가
같은 인터페이스를 통해 서로 다른 구현을 교체 가능하게 만들어 분기문을 줄이고 확장에 열려 있는 구조를 만들 때 사용합니다.

#### 6. 추상 클래스와 인터페이스는 어떻게 다르게 보아야 하는가
추상 클래스는 공통 상태와 기본 동작을 함께 묶을 때, 인터페이스는 역할과 계약을 분리할 때 더 적합합니다.

#### 7. checked exception과 unchecked exception의 차이는 무엇인가
checked exception은 컴파일 시 처리 여부를 강제하고, unchecked exception은 주로 프로그래밍 오류나 잘못된 상태를 나타냅니다.

#### 8. equals와 hashCode를 함께 재정의해야 하는 이유는 무엇인가
해시 기반 컬렉션에서 같은 객체로 취급되려면 동등성 판단과 해시 계산 규칙이 일치해야 하기 때문입니다.

#### 9. String은 왜 불변인가
공유와 캐싱이 쉬워지고, 해시값 안정성과 보안성이 높아지며, 멀티스레드 환경에서 다루기 쉬워지기 때문입니다.

#### 10. JVM 메모리를 설명할 때 최소 무엇을 말해야 하는가
스택, 힙, 메서드 영역 계열 개념과 객체 생성, 참조, 가비지 컬렉션의 관계를 함께 설명해야 합니다.

### 연결 문서
- 객체지향: 객체지향 프로그래밍 (→ 2.3)
- 설계 원칙: 객체지향 원칙별 샘플 코드 (→ 2.4)
- 예외: 예외와 사용자 정의 예외 (→ 10.2)
- JVM: JVM 기초 가이드 1: 개념과 구성 원리 (→ 9.0)

### 한 줄 정리
이 문서는 Java와 객체지향을 짧고 정확하게 답하는 연습용 질문집입니다.

## 11.15 Git 기초

**🎯 목표**: Git 기초(add·commit·branch)를 익힌다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 Git을 처음 쓰는 학습자를 위한 기초 실습 가이드입니다. 책 본문이 아니라 부록 참고 자료이며, 로컬 저장소 생성, 첫 커밋, 원격 저장소 연결, SSH 설정까지 한 번에 따라 해보는 데 목적이 있습니다.

### 이 문서를 언제 보는가
- Java 문법보다 협업 도구가 먼저 막힐 때
- 토이프로젝트 결과물을 GitHub에 올리고 싶을 때
- 브랜치 전략보다 먼저 `init`, `add`, `commit`, `push` 흐름이 필요할 때

### 목표
- 로컬 저장소를 만들고 변경 사항을 커밋할 수 있습니다.
- GitHub 원격 저장소를 연결하고 `main` 브랜치로 푸시할 수 있습니다.
- 장기적으로는 비밀번호 대신 SSH 인증을 기본으로 사용합니다.

### 가장 짧은 실습 흐름

#### 1. 저장소 초기화
```bash
git init
```
```text
예상 결과
현재 디렉터리에 `.git` 디렉터리가 생성된다.
`Initialized empty Git repository ...` 형태의 안내 메시지가 출력된다.
```

#### 2. 파일 추가와 첫 커밋
```bash
echo "# My First Git Project" > README.md
git add README.md
git commit -m "feat: initial commit"
```
```text
예상 결과
`git add` 후 `git status`를 보면 `README.md`가 staged 상태로 보인다.
`git commit` 후에는 첫 커밋 해시와 커밋 메시지가 출력된다.
```

#### 3. 기본 브랜치 이름 정리
```bash
git branch -M main
```
```text
예상 결과
현재 브랜치 이름이 `main`으로 바뀐다.
이미 `main`이면 눈에 띄는 변화 없이 유지된다.
```

#### 4. 원격 저장소 연결
```bash
git remote add origin https://github.com/your_username/my-first-git-project.git
```
```text
예상 결과
`git remote -v`를 실행하면 `origin`이 등록된 것을 확인할 수 있다.
같은 이름의 원격이 이미 있으면 중복 등록 오류가 난다.
```

#### 5. 첫 푸시
```bash
git push -u origin main
```
```text
예상 결과
원격 저장소에 첫 커밋이 업로드된다.
이후에는 `git push`만으로 같은 브랜치에 푸시할 수 있다.
인증이 되지 않으면 HTTPS 토큰 또는 SSH 설정을 먼저 확인해야 한다.
```

### 인증 방식

#### HTTPS
- GitHub 계정 비밀번호로는 푸시할 수 없습니다.
- HTTPS를 쓸 경우 Personal Access Token을 사용합니다.

#### SSH
- 학습과 실무 모두 SSH를 기본값으로 두는 편이 안정적입니다.
- 공개 키를 GitHub에 등록한 뒤 SSH 주소로 원격 저장소를 연결합니다.
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-add ~/.ssh/id_ed25519
```
```bash
git remote set-url origin git@github.com:your_username/my-first-git-project.git
```
```text
예상 결과
`ssh -T git@github.com`이 정상 동작하면 이후 푸시에서 브라우저 인증 없이 연결된다.
원격 주소를 다시 보면 `https://` 대신 `git@github.com:` 형태로 바뀐다.
```

### 꼭 알아둘 명령
- 상태 확인: `git status`
- 변경 이력 확인: `git log --oneline`
- 원격 저장소 확인: `git remote -v`
- 현재 브랜치 확인: `git branch`

### 이 문서를 본 뒤 바로 할 일
1. 토이프로젝트 디렉터리 하나를 정해 `git init`을 직접 해 봅니다.
1. `README.md`를 만들고 첫 커밋까지 완료합니다.
1. GitHub 원격 저장소를 연결하고 `push`까지 끝냅니다.

### 정리
이 문서는 Git 전체를 설명하는 문서가 아니라, 토이프로젝트 결과물을 안전하게 버전 관리하고 GitHub에 올리는 최소 흐름을 빠르게 익히기 위한 부록입니다.

### 한 줄 정리
이 문서는 로컬 작업을 GitHub 원격 저장소에 안전하게 올리는 최소 Git 실습 가이드입니다.

### ✏️ 직접 해보기

새 저장소에서 브랜치를 파고 커밋한 뒤 main에 병합해 보라.

## 11.16 스레드와 동기화 기초

**🎯 목표**: 스레드와 동기화의 기초를 이해한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 Java에서 스레드와 동시성을 처음 구조적으로 이해하려는 독자를 위한 참고 가이드입니다. 책 본문에서 파일, 네트워크, 서버를 배우다 보면 `Thread`, `synchronized`, `interrupt`, `BlockingQueue` 같은 개념이 자꾸 다시 등장하므로, 그때 돌아와 빠르게 정리해 보는 용도로 두었습니다.

### 1. 프로세스와 스레드
- 프로세스는 실행 중인 프로그램 단위입니다.
- 스레드는 그 안에서 실제 코드를 실행하는 흐름입니다.
- 하나의 프로세스 안에서도 여러 스레드가 동시에 작업할 수 있습니다.
핵심은 “작업을 나누면 빨라진다”보다, **대기 시간이 긴 작업을 분리해 응답성을 지키는 것**에 더 가깝습니다.

### 2. 스레드 시작은 어떻게 볼까
`Thread`를 직접 만드는 예제는 원리를 배우기에는 좋지만, 실무 코드에서는 보통 `Runnable`, `Callable`, `ExecutorService` 같은 상위 도구를 더 많이 봅니다.
```java
ExecutorService executor = Executors.newFixedThreadPool(2);
executor.submit(() -> System.out.println("작업 1"));
executor.submit(() -> System.out.println("작업 2"));
executor.shutdown();
```
즉, 입문 단계에서는 `new Thread(...).start()`를 이해하되, 실제 운영 코드는 실행 정책을 분리하는 쪽으로 발전한다고 보면 됩니다.

### 3. 공유 상태가 생기면 왜 어려워질까
여러 스레드가 같은 값을 동시에 바꾸면 순서가 꼬일 수 있습니다.
```java
class Counter {
    private int value = 0;

    public synchronized void increment() {
        value++;
    }

    public int getValue() {
        return value;
    }
}
```
이때 중요한 것은 문법보다, **여러 작업이 같은 상태를 공유하는 순간부터 동시성 문제가 시작된다**는 감각입니다.

### 4. `synchronized`, `wait/notify`, `BlockingQueue`
초기 학습에서는 `synchronized`, `wait`, `notify`를 많이 배우지만, 실제 생산자-소비자 패턴에서는 `BlockingQueue`가 더 직접적일 때가 많습니다.
```java
BlockingQueue<String> queue = new ArrayBlockingQueue<>(10);

queue.put("job-1");
String job = queue.take();
```
- `synchronized`: 임계 구역 보호
- `wait/notify`: 저수준 대기/깨움 제어
- `BlockingQueue`: 대기열 기반 작업 분리에 더 실용적
핵심은 저수준 API를 외우는 것이 아니라, **직접 잠금 제어가 필요한지, 아니면 더 높은 수준의 동시성 도구가 있는지** 먼저 보는 것입니다.

### 5. `interrupt`는 종료 신호에 가깝다
스레드를 강제로 멈춘다고 생각하기 쉽지만, `interrupt`는 보통 “멈출 준비를 해라”에 가까운 신호입니다.
```java
try {
    Thread.sleep(1000);
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
}
```
인터럽트를 받았을 때 신호를 삼키지 않고 다시 설정하는 패턴은 자주 등장합니다.

### 6. JVM과의 연결
스레드를 배우면 JVM 문서와도 연결됩니다.
- 각 스레드는 자기만의 스택 프레임을 가집니다.
- 스레드가 너무 많으면 메모리와 스케줄링 비용이 함께 늘어납니다.
- 장애 분석에서는 `jcmd <pid> Thread.print` 같은 도구로 스레드 상태를 확인합니다.
즉, 동시성은 언어 문법만의 주제가 아니라 JVM 메모리, 스케줄링, 운영 관찰까지 이어집니다.

### 7. 언제 다시 이 문서를 보면 좋은가
- `synchronized`와 `volatile` 차이가 흐릴 때
- `wait/notify`와 `BlockingQueue`를 언제 써야 할지 막힐 때
- 인터럽트와 종료 처리 규칙이 헷갈릴 때
- JVM 메모리 문서를 읽다가 `Thread Stack`이 다시 궁금해질 때

### 한 줄 정리
스레드 학습의 핵심은 **코드를 여러 개 돌리는 법**보다, **공유 상태와 대기, 종료 신호를 어떻게 다룰지 이해하는 것**입니다.

### ✏️ 직접 해보기

두 스레드가 공유 변수를 증가시킬 때 동기화 유무에 따른 결과 차이를 확인하라.

## 11.17 포트폴리오 예제

**🎯 목표**: 포트폴리오 예제로 결과물 정리 방법을 익힌다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 학습 결과물을 어떤 구조로 정리하면 읽기 쉬운 포트폴리오가 되는지 감을 잡기 위한 참고 문서입니다.
책 본문이나 필수 워크북은 아니며, 결과물을 정리할 때 기준선을 맞추는 용도로만 사용합니다.

### 좋은 포트폴리오의 최소 구성

#### 1. 프로젝트 개요
- 무엇을 만들었는지
- 어떤 문제를 해결했는지
- 누구를 위한 결과물인지

#### 2. 기술 선택 이유
- 왜 Spring Boot를 썼는지
- 왜 JPA, Querydsl, JWT 같은 기술을 선택했는지
- 대안과 비교했을 때 어떤 장단점이 있었는지

#### 3. 핵심 구현 포인트
- 도메인 모델링
- 인증과 인가
- 쿼리 설계와 성능 개선
- 테스트 전략

#### 4. 문제 해결 기록
- 실제로 부딪힌 오류
- 원인 분석
- 어떤 기준으로 수정했는지

#### 5. 결과와 회고
- 무엇이 좋아졌는지
- 다음에 다시 하면 바꿀 점은 무엇인지

### 편집 원칙
- 화면 캡처만 모아 두지 않습니다.
- 코드 일부보다 설계 의도와 판단 기준을 더 분명히 씁니다.
- README, API 문서, 테스트 근거가 서로 연결되게 정리합니다.

### 연결 문서
- 미니프로젝트 정리: 11.10 미니프로젝트 과제 정리 (→ 11.10)
- 실습 예시: [11.25 [PJ]블로그 작성하기 미니프로젝트](‣), [11.19 [PJ]온라인 게임 토이 프로젝트](‣)

### 한 줄 정리
포트폴리오는 결과 화면 모음이 아니라, 문제 정의와 설계 판단을 설명하는 문서여야 합니다.

## 11.18 GitHub 작업 순서 가이드

**🎯 목표**: GitHub 협업 작업 순서(브랜치·PR)를 익힌다.

#### 개요

이 문서는 **초중급 Java 개발자**가 GitHub 기반으로 개인 프로젝트나 소규모 팀 프로젝트를 운영할 때 필요한 최소 작업 흐름을 정리한 가이드입니다. 목표는 도구를 많이 쓰는 것이 아니라, 작업 단위를 예측 가능하게 만드는 것입니다.

#### 왜 중요한가

코드는 잘 작성해도 작업 기록이 남지 않으면 협업과 회고가 어려워집니다. 특히 Spring 프로젝트처럼 기능, 테스트, 리팩터링이 함께 움직이는 저장소에서는 이슈, 브랜치, 커밋 흐름이 일정해야 변경 이력을 읽기 쉬워집니다.

#### 대상 독자

- 혼자 프로젝트를 진행하지만 기록을 남기고 싶은 개발자
- 이슈, 브랜치, 커밋 흐름을 한 번 정리하고 싶은 개발자
- GitHub Projects까지는 아니어도 기본 운영 체계를 잡고 싶은 개발자
#### 전체 흐름

1. 라벨을 정리합니다.
1. 마일스톤을 생성합니다.
1. 이슈 템플릿을 준비합니다.
1. 작업 이슈를 등록합니다.
1. 브랜치를 분기하고 작업합니다.
1. 커밋과 푸시로 작업 단위를 남깁니다.
#### 1. 라벨 정리

처음부터 라벨을 많이 만들 필요는 없습니다. 라벨은 작업을 보기 좋게 만드는 도구이지, 관리 부담을 늘리는 도구가 아니어야 합니다.

##### 추천 라벨

- `feature`
- `bug`
- `docs`
- `refactor`
- `priority-high`
- `priority-medium`
- `priority-low`
- `status-todo`
- `status-in-progress`
- `status-done`
#### 2. 마일스톤 생성

마일스톤은 큰 묶음의 목표를 표현하는 용도로만 씁니다. 스프린트, 버전, 기능 묶음을 식별하는 데 충분하면 됩니다.

```text
제목: 회원 관리 시스템 v1.0
설명: 회원 CRUD 기능 완성
마감일: 2주 후
```

#### 3. 이슈 템플릿 준비

기능 개발용 템플릿 하나만 잘 만들어도 반복 작업이 훨씬 쉬워집니다.

```markdown
## 기능 개요
- 기능명:
- 우선순위:
- 예상 작업 시간:

## 요구사항
- [ ]

## 구현 내용
- 엔드포인트:
- 요청/응답:
- 수정 대상 파일:

## 완료 조건
- [ ] 기능 구현 완료
- [ ] 테스트 코드 작성
- [ ] API 동작 확인
```

#### 4. 작업 이슈 등록

```text
제목: [FEATURE] 회원 단건 조회 API 구현
라벨: feature, priority-high, status-todo
마일스톤: 회원 관리 시스템 v1.0
```

이슈에는 구현 목적, 요구사항, 테스트 포인트가 드러나면 충분합니다. 너무 긴 설계 문서를 붙이기보다, 작업 단위를 명확히 보이게 하는 편이 낫습니다.

#### 5. 브랜치 분기

```bash
git checkout -b feature/member-find-one
```

브랜치 이름은 작업 내용을 바로 알 수 있게 짓는 편이 좋습니다. 브랜치명만 보고도 어떤 변경인지 유추할 수 있어야 이후 관리가 쉬워집니다.

#### 6. 커밋과 푸시

```bash
git add .
git commit -m "feat: 회원 단건 조회 API 구현"
git push origin feature/member-find-one
```

커밋 메시지는 작업 단위를 설명해야 하고, 푸시는 너무 큰 덩어리가 되지 않게 나누는 편이 좋습니다.

#### 7. 라벨은 최소한으로 시작한다

라벨은 복잡한 분류 체계를 만드는 도구가 아니라, 작업 맥락을 빠르게 읽게 만드는 도구입니다. 처음에는 아래 정도면 충분합니다.

- `feature`
- `bug`
- `docs`
- `refactor`
- `priority-high`
- `priority-low`
- `in-progress`
핵심은 라벨 종류를 많이 만드는 것이 아니라, **팀이 실제로 계속 쓸 수 있는 개수로 제한하는 것**입니다.

#### 8. GitHub Projects는 상태를 시각화하는 보조 도구다

이슈와 브랜치만으로도 작업은 진행할 수 있지만, 작업량이 많아지면 보드가 있으면 상태를 훨씬 빨리 읽을 수 있습니다.

- 개인 프로젝트: `Task list`나 `Feature planning`
- 소규모 팀 프로젝트: `Team planning`
필드도 과하게 늘리지 않는 편이 좋습니다.

- 상태
- 우선순위
- 담당자
- 마일스톤 또는 이터레이션
즉 GitHub Projects의 목표는 정교한 PM이 아니라, **작업 상태를 한눈에 보이게 하는 것**입니다.

#### 자주 하는 실수

- 이슈 없이 바로 코딩부터 시작하는 것
- 브랜치 이름을 임의로 지어 작업 맥락이 사라지는 것
- 커밋 메시지를 너무 짧게 써서 변경 의도가 보이지 않는 것
- 라벨 체계를 과하게 크게 시작하는 것
#### 정리

좋은 GitHub 작업 흐름은 도구가 많은 상태가 아니라, 작업 단위가 분명한 상태를 의미합니다. 라벨, 이슈, 브랜치, 커밋만 안정적으로 굴러가도 프로젝트 가독성은 크게 좋아집니다.

#### 한 줄 정리

GitHub 작업 관리는 복잡한 보드보다 **이슈, 브랜치, 커밋 흐름을 일정하게 유지하는 것**이 먼저입니다.


---

## 11.19 [PJ]온라인 게임 토이 프로젝트

**🎯 목표**: 온라인 게임 토이 프로젝트로 종합 실습한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 파일 저장, 네트워크 통신, 서버 동기화, 게임 상태 모델링을 한꺼번에 엮어 보는 토이 프로젝트 초안입니다. 현재는 `초반` 상태이므로 완성된 정답본이 아니라, 시나리오를 시스템 경계와 데이터 흐름으로 바꾸는 연습 재료로 보는 편이 맞습니다.

### 이 문서를 언제 보는가
- 파일 저장, 네트워크, 상태 동기화를 한 프로젝트 안에서 같이 연습하고 싶을 때
- 단순 CRUD보다 한 단계 복잡한 시스템 경계를 다뤄 보고 싶을 때
- 클라이언트, 서버, 공통 데이터가 어떻게 분리되는지 감을 잡고 싶을 때

### 먼저 볼 핵심 경계
이 프로젝트는 기능을 바로 구현하기보다, 아래 세 축을 분리해서 읽는 것이 중요합니다.
- 사용자: 로그인, 캐릭터 선택, 던전 진입, 종료
- 클라이언트: 로컬 파일 저장, 게임 상태 관리, 서버 동기화 요청
- 서버: 계정/상태 저장, 로그 수집, 동기화 처리
```text
예상 결과
독자는 이 문서를 읽고 '게임 기능 목록'보다 먼저 시스템 경계를 구분하게 된다.
즉 무엇이 로컬 책임이고, 무엇이 서버 책임이며, 어떤 데이터가 공통 자원인지 먼저 정리하게 된다.
```

### 최소 시나리오

#### 1. 사용자 관점
- 게임 실행 후 로그인
- 캐릭터 선택 또는 생성
- 던전 진입 후 전투와 보상 획득
- 종료 시 상태 저장

#### 2. 클라이언트 관점
- 실행 시 로컬 데이터 로드
- 필요 시 서버에 데이터 요청
- 활동 로그를 로컬 파일에 기록
- 일정 간격 또는 종료 시 서버와 동기화

#### 3. 서버 관점
- 계정과 캐릭터 상태 조회
- 클라이언트가 보낸 데이터 반영
- 활동 로그 저장 또는 분석 시스템 전달
- 백업 및 무결성 점검

### 권장 구현 순서
1. 오프라인 단일 사용자 버전부터 만든다.
1. `player_data.txt` 또는 JSON 파일로 상태 저장을 붙인다.
1. 전투 로그를 파일로 남긴다.
1. 서버 없이도 동작하는 최소 게임 루프를 만든다.
1. 그 뒤에 소켓 또는 HTTP 기반 동기화를 붙인다.
이 순서를 지키지 않으면 네트워크 문제와 게임 로직 문제가 한꺼번에 섞여 디버깅이 어려워집니다.

### 공통 기초 데이터 예시
서버나 클라이언트가 공통으로 사용하는 `몬스터`, `맵`, `아이템` 같은 정적 데이터는 JSON으로 분리하는 편이 좋습니다.
```text
src/main/resources/game_data.json
```
```json
{
  "maps": [
    {
      "mapId": "dungeon1",
      "name": "Dungeon: Slime Cave",
      "monsters": ["slime", "slime_king"],
      "recommendedLevel": 1
    }
  ],
  "monsters": [
    {
      "monsterId": "slime",
      "name": "Slime",
      "hp": 20,
      "attack": 3,
      "expReward": 10
    },
    {
      "monsterId": "slime_king",
      "name": "King Slime",
      "hp": 100,
      "attack": 8,
      "expReward": 50
    }
  ],
  "items": [
    {
      "itemId": "small_potion",
      "name": "Small Healing Potion",
      "effect": "hp+20"
    }
  ]
}
```
```text
예상 결과
게임 코드는 맵/몬스터 상수를 직접 하드코딩하지 않고 공통 데이터 파일에서 읽어 올 수 있다.
새 던전이나 몬스터를 추가할 때 코드 전체를 뜯지 않고 데이터 파일부터 수정하는 구조를 연습하게 된다.
```

### 확장 포인트
- 오프라인 모드와 재연결 동기화
- 실시간 전투 상태 동기화
- 충돌 해결 규칙
- 활동 로그 기반 리포트 생성

### 편집 원칙
- 이 문서는 완성 답안이 아니라 시스템 분리 연습용 초안입니다.
- 본문에는 여기의 전체 시나리오를 그대로 넣지 않고, 파일 처리/네트워크/동기화 설명에 필요한 일부만 발췌합니다.
- 실제 구현에 들어갈 때는 오프라인 버전과 온라인 버전을 반드시 나누어 단계적으로 진행합니다.

### 한 줄 정리
온라인 게임 토이프로젝트의 핵심은 **게임 기능을 많이 적는 것이 아니라, 로컬 상태와 서버 상태와 공통 데이터를 분리해 보는 것**입니다.

## 11.20 [PJ]레거시 실습과 연재형 원고

**🎯 목표**: 레거시 실습으로 점진적 개선을 연습한다.

<!-- 2026-06-29 라이브 Notion에서 수집 (4월 ingest 이후 추가분) -->

### 개요
이 문서는 현재 책의 메인 목차에는 넣지 않지만, 학습 자료로서 보존 가치가 있는 레거시 실습 문서와 연재형 초안을 묶어 두는 안내 페이지입니다. 핵심 원칙은 단순합니다. 본문과 직접 연결되는 내용은 본문 문서로 흡수하고, 형식이 거칠거나 연재체 구조가 강한 문서는 이 묶음 아래에서 참고 자료로만 유지합니다.

### 이 문서를 언제 보는가
- 본문에 넣기에는 거칠지만 버리기 아까운 자료가 있을 때
- 기존 연재형 글에서 개념만 뽑아 다시 쓰고 싶을 때
- 특정 프로젝트 문서가 일반 개념 문서로 승격될 수 있는지 판단하고 싶을 때

### 이 묶음에 포함되는 문서
- [11.23 [PJ]Java/JSP(Model 1) 기반 블로그 개발 실습 가이드](‣)
- [11.22 [PJ]도서 주문 및 대여 시스템 시나리오](‣)
- 11.24 Loan API 리팩터링 요약
- [11.25 [PJ]블로그 작성하기 미니프로젝트](‣)
- [11.19 [PJ]온라인 게임 토이 프로젝트](‣)

### 편집 원칙
- 책 본문과 중복되는 설명은 `통합됨` 문서로 접고 대표 문서 링크만 남깁니다.
- 프로젝트형 실습 자료는 `미니프로젝트`, `JSP`, `시나리오`, `운영 메모`처럼 목적이 드러나는 묶음 아래에 둡니다.
- Loan, 로그, 모니터링처럼 특정 프로젝트 맥락이 강한 문서는 일반 개념 문서로 승격하지 않고 프로젝트 참고 자료로만 유지합니다.
- 연재형 초안은 본문으로 쓰지 않고, 필요한 개념만 메인 원고로 다시 서술합니다.
- 외부 하위 데이터베이스는 이 페이지에서 위치만 안내하고, 메인 목차에는 직접 포함하지 않습니다.
```text
예상 결과
독자는 이 허브를 보고 '본문 후보', '부록 유지본', '프로젝트 전용 기록'을 구분할 수 있다.
편집자는 무엇을 삭제할지보다 무엇을 재서술 대상으로 남길지 판단하기 쉬워진다.
```

### 사용 방법
- JSP, 서블릿, Model 1 구조를 복습할 때는 `11.23 [PJ]Java/JSP(Model 1) 기반 블로그 개발 실습 가이드`를 봅니다.
- 도메인 시나리오를 프로젝트 단위로 확장하고 싶을 때는 `11.22 [PJ]도서 주문 및 대여 시스템 시나리오`를 봅니다.
- Loan API 구조 변경과 리팩터링 의도를 빠르게 확인할 때는 `11.24 Loan API 리팩터링 요약`을 봅니다.
- 요구사항 분석부터 DB 모델링까지 한 번에 묶어 보고 싶을 때는 `11.25 [PJ]블로그 작성하기 미니프로젝트`와 `11.19 [PJ]온라인 게임 토이 프로젝트`를 봅니다.

### 참고 위치 메모
- `11.22-1 Loan 시스템 화면/API 실습 가이드`와 `Loan 서비스 주요 조회 쿼리`는 책 원고 DB의 메인 목차가 아니라 프로젝트 하위 데이터베이스 안에 유지합니다.
- 로그와 모니터링 관련 연재형 글도 프로젝트 운영 기록으로 보고, 책 본문에는 일반화된 개념만 남깁니다.

### 정리
이 묶음은 본문 밖에 남겨 두는 자료들의 폐기장이 아니라, 다시 쓰기 전의 원재료 창고입니다. 부록의 목적은 자료를 무조건 살리는 것이 아니라, 본문으로 올릴 재료와 프로젝트 전용 기록을 명확히 분리하는 데 있습니다.

### 한 줄 정리
이 묶음은 본문 밖 자료를 버리지 않고, 다시 쓰기 전의 원재료로 관리하기 위한 레거시 허브입니다.


## 11.21 JSP 기본 개념

**🎯 목표**: JSP 기본 개념을 이해한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 JSP의 가장 기본적인 문법과 실행 흐름을 빠르게 훑어보기 위한 예제 모음입니다. 최신 Spring Boot 중심 개발 흐름에서는 JSP를 직접 사용할 일이 줄었지만, 서버 사이드 렌더링과 서블릿 기반 웹 구조를 이해하는 데에는 여전히 참고 가치가 있습니다.

### 어떻게 활용하면 좋은가
- JSP를 처음 볼 때 문법 요소를 한 번에 정리하는 용도로 읽습니다.
- 스크립틀릿, 내장 객체, 폼 처리 방식이 어떤 한계를 가지는지도 함께 봅니다.
- 현대적인 Spring MVC + 템플릿 엔진 구조와 비교하며 읽으면 더 도움이 됩니다.

### 예제 구성

#### 1. 기본 JSP 페이지
- 선언부, 스크립틀릿, 표현식을 함께 보여주는 예제

#### 2. 폼 처리 예제
- 입력 페이지와 처리 페이지를 나눠 요청 흐름을 확인하는 예제

#### 3. 내장 객체 예제
- `request`, `response`, `session`, `application`, `out` 사용 예제

#### 4. JavaBean 사용 예제
- `<jsp:useBean>`, `<jsp:setProperty>`, `<jsp:getProperty>` 흐름 확인

### 예제 1. 기본 JSP 페이지
```
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JSP 기본 예제</title>
</head>
<body>
    <h1>Hello JSP World!</h1>

    <%! 
        private String getMessage() {
            return "JSP에서 메소드를 통해 생성된 메시지입니다.";
        }
    %>

    <%
        String greeting = "JSP의 세계에 오신 것을 환영합니다!";
    %>

    <p><%= greeting %></p>
    <p><%= getMessage() %></p>
</body>
</html>
```

#### 해설
이 예제는 JSP가 HTML 안에 Java 코드를 직접 끼워 넣는 방식으로 동작한다는 점을 보여줍니다. 선언부, 스크립틀릿, 표현식이 각각 어떤 역할을 하는지 구분하는 것이 핵심입니다.

### 예제 2. 폼 처리 예제
```
<form action="processForm.jsp" method="post">
    <input type="text" name="name" required>
    <input type="email" name="email" required>
    <input type="submit" value="제출">
</form>
```

#### 해설
입력 페이지와 결과 페이지를 분리해 요청이 서버로 전달되는 흐름을 이해하는 예제입니다. `request.getParameter()`가 어떻게 동작하는지 확인하기 좋습니다.

### 예제 3. JSP 내장 객체
```
<p>서버 이름: <%= request.getServerName() %></p>
<p>세션 ID: <%= session.getId() %></p>
<p>서버 정보: <%= application.getServerInfo() %></p>
```

#### 해설
JSP는 별도 선언 없이 여러 내장 객체를 제공합니다. 다만 이런 접근은 뷰와 로직이 강하게 결합되기 쉬워, 현재는 컨트롤러와 템플릿 역할을 분리하는 방식이 더 일반적입니다.

### 예제 4. JavaBean 사용
```
<jsp:useBean id="user" class="com.example.beans.User" scope="session" />
<jsp:setProperty name="user" property="name" param="name" />
<jsp:getProperty name="user" property="name" />
```

#### 해설
JSP는 JavaBean과 결합해 폼 데이터를 객체에 바인딩하는 기본 방식을 제공합니다. 현재 기준으로 보면 단순한 데이터 바인딩의 초기 형태를 이해하는 정도로 보는 것이 적절합니다.

### 실행 방법
- Tomcat을 실행합니다.
- 브라우저에서 예제 JSP 파일 경로로 직접 접속합니다.
- 폼 예제는 입력 페이지와 결과 페이지를 함께 확인합니다.

### 체크 포인트
- 선언부, 스크립틀릿, 표현식의 차이를 이해했는가
- 내장 객체가 무엇을 의미하는지 구분할 수 있는가
- JSP가 왜 로직과 화면을 쉽게 섞게 되는지 이해했는가
- 현재 기준에서 JSP보다 템플릿 엔진이나 API + 프론트엔드 분리가 왜 선호되는지 설명할 수 있는가

### 정리
JSP 예제는 지금 실무의 주류 기술을 배우는 문서라기보다, Java 웹 개발이 어떤 방식으로 발전해왔는지 이해하는 참고 자료에 가깝습니다. 서블릿, 요청-응답 흐름, 서버 렌더링의 기초를 이해하는 데는 여전히 의미가 있습니다.

### 한 줄 정리
JSP 예제의 핵심은 최신 기술을 익히는 것보다, Java 웹 개발의 기본 요청 처리 흐름을 이해하는 데 있습니다.

## 11.22 [PJ]도서 주문 및 대여 시스템 시나리오

**🎯 목표**: 도서 주문·대여 시스템 시나리오로 도메인을 설계한다.

<!-- 2026-06-29 라이브 Notion에서 수집 (4월 ingest 이후 추가분) -->

### 개요
이 문서는 도서 주문 및 대여 시스템을 예시 도메인으로 삼아 요구사항, 연재형 원고, 실험용 데이터베이스를 묶어 둔 부록 허브입니다. 책 본문으로 바로 편입하지 않고, 실습 확장이나 후속 연재 원고를 정리할 때만 참고합니다.

### 이 페이지의 역할
- 예시 도메인 시나리오를 한 번에 조망하는 허브
- 하위 요구사항 페이지와 실험용 데이터베이스의 진입점
- 본문으로 흡수되기 전의 연재형 원고 보관소

### 이 문서를 언제 보는가
- 회원, 주문, 결제, 대여처럼 여러 도메인이 한 시스템 안에서 어떻게 엮이는지 보고 싶을 때
- 작은 예제보다 한 단계 큰 요구사항 묶음을 설계 연습에 쓰고 싶을 때
- 본문에서 배운 JPA, Security, 테스트, API 설계를 실제 도메인 시나리오에 투영해 보고 싶을 때

### 핵심 시나리오
- 회원 가입, 회원 조회와 수정
- 도서 구매, 주문 처리, 배송 상태 변경
- 도서 대여, 반납, 연체 관리
- 통계, 재고, 관리자 기능
```text
예상 결과
독자는 이 허브에서 세부 요구사항, API 명세, 테스트 시나리오, 리팩터링 메모를 한 번에 찾아갈 수 있다.
하지만 본문에서는 여기의 세부 명세를 그대로 복제하지 않고, 정제된 개념과 대표 예시만 가져간다.
```

### 세부 요구사항 페이지
[1] 회원관리 기능 ⇒ 1 회원가입
[1] 회원관리 기능 ⇒ 2.회원조회 및 관리

### 연결된 실험 데이터베이스

### 편집 원칙
- 책 본문과 겹치는 개념은 이곳에서 반복 설명하지 않습니다.
- 세부 명세는 하위 페이지나 하위 데이터베이스에서만 유지합니다.
- 메인 원고에는 여기서 정제한 개념과 예시만 다시 서술합니다.
- 허브 문서는 방향을 잡는 역할만 하고, 상세 설명은 하위 자료에 남깁니다.

### 여기서 뽑아갈 수 있는 산출물
- 요구사항 체크리스트
- API 초안과 테스트 시나리오
- 리팩터링 후보 목록
- 도메인 흐름 설명에 쓸 대표 사례

### 정리
이 문서는 본문 원고 그 자체가 아니라, 여러 실험 자료를 한데 모아 두는 도메인 실험장 허브입니다. 부록의 역할은 모든 내용을 다 설명하는 것이 아니라, 필요한 상세 자료로 빠르게 이동하게 만드는 데 있습니다.

### 한 줄 정리
이 문서는 도메인 실험장 전체를 묶어 두고, 본문에 넣을 재료만 골라 가져가기 위한 부록 허브입니다.


## 11.23 [PJ]Java/JSP(Model 1) 기반 블로그 개발 실습 가이드

**🎯 목표**: Java/JSP(Model 1) 블로그 개발을 실습한다.

#### 개요

이 문서는 JSP Model 1 방식으로 블로그를 만드는 과정을 정리한 레거시 실습 가이드입니다.

현재 책 본문에서는 직접 다루지 않지만, `JSP 기본 개념 예제`와 `블로그 작성하기 미니프로젝트`를 더 구체적인 코드 수준에서 연결해 보고 싶을 때 참고 자료로 사용할 수 있습니다.

### Java/JSP(Model 1) 기반 블로그 개발 실습 가이드

#### 1. 실습 프로세스 개요

1. **환경 설정**
1. **프로젝트 생성**
1. **데이터베이스 설계 및 구축**
1. **모델(Model) 구현 (Java)**
1. **뷰(View) 및 로직 처리 구현 (JSP)**
1. **테스트 및 디버깅**
1. **배포 (선택 사항)**
#### 2. 프로젝트 구조 예시 (Maven 기준)

```text
my-blog/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/myblog/
│   │   │       ├── dao/
│   │   │       │   ├── UserDAO.java
│   │   │       │   ├── PostDAO.java
│   │   │       │   ├── CategoryDAO.java
│   │   │       │   └── SessionDAO.java (선택)
│   │   │       ├── dto/
│   │   │       │   ├── User.java
│   │   │       │   ├── Post.java
│   │   │       │   ├── Category.java
│   │   │       │   └── UserSession.java
│   │   │       ├── util/
│   │   │       │   ├── PasswordUtil.java
│   │   │       │   ├── DBConnection.java
│   │   │       │   └── SessionUtil.java
│   │   │       └── service/ (선택사항)
│   │   │           ├── AuthService.java
│   │   │           └── SessionService.java
│   │   ├── resources/
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── lib/
│   │       │   └── web.xml
│   │       ├── css/
│   │       ├── js/
│   │       ├── images/
│   │       ├── user/
│   │       │   ├── login_form.jsp => 로그인 입력폼
│   │       │   ├── login_action.jsp => 로그인 처리
│   │       │   ├── logout_action.jsp => 로그아웃 처리
│   │       │   ├── signup_form.jsp => 회원가입 폼
│   │       │   ├── signup_action.jsp => 회원가입 처리
│   │       │   ├── profile.jsp => 프로필 조회 (로그인 필요)
│   │       │   └── profile_action.jsp => 프로필 수정
│   │       ├── post/
│   │       │   ├── list.jsp
│   │       │   ├── view.jsp
│   │       │   ├── form.jsp (로그인 필요)
│   │       │   ├── post_action.jsp
│   │       │   └── delete_action.jsp (로그인 + 권한 체크)
│   │       ├── comment/
│   │       │   └── comment_action.jsp (로그인 필요)
│   │       ├── admin/
│   │       │   ├── userList.jsp (관리자 전용)
│   │       │   ├── category.jsp
│   │       │   └── category_action.jsp
│   │       ├── common/
│   │       │   ├── header.jsp => 공통 헤더 (로그인 상태 표시)
│   │       │   ├── footer.jsp
│   │       │   └── auth_check.jsp => 인증 체크 공통 로직
│   │       └── index.jsp
│   └── test/
│       └── java/
└── build.gradle

```

#### 3. 핵심 기술 및 개념

- **JSP:** HTML 내 Java 코드 삽입 (스크립틀릿, 표현식, 선언부)
- **JDBC:** Java DB 연결 API
- **DAO/DTO:** DB 로직 분리 및 데이터 전달 객체
- **HttpSession:** 사용자 로그인 상태 관리
- **쿠키:** 자동 로그인 기능 (Remember Me)
- **JSP 액션 태그:** `<jsp:useBean>`, `<jsp:setProperty>`, `<jsp:getProperty>`
- **JSTL & EL:** 코드 가독성 향상 (권장)
#### 4. 데이터베이스 스키마 예시 (MySQL)

```sql
create database mini_blog;
use mini_blog;

-- 사용자 테이블
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- 해싱된 비밀번호 저장
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL, -- 마지막 로그인 시간
    is_active BOOLEAN DEFAULT TRUE, -- 계정 정지 여부
    role ENUM('USER', 'ADMIN') DEFAULT 'USER' -- 사용자 권한
);

-- 로그인 세션 테이블 (자동 로그인용)
CREATE TABLE user_sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    ip_address VARCHAR(45), -- IPv6 지원
    user_agent TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_sessions_user_id (user_id),
    INDEX idx_user_sessions_expires (expires_at)
);

-- 카테고리 테이블
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 게시글 테이블
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image_path VARCHAR(255), -- 이미지 파일 경로
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    view_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 댓글 테이블
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id INT, -- 대댓글 기능 (NULL이면 일반 댓글)
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_reported BOOLEAN DEFAULT FALSE, -- 신고 여부
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- 기본 데이터 삽입
INSERT INTO categories (name) VALUES ('일반'), ('기술'), ('일상');
INSERT INTO users (email, password, name, nickname, role)
VALUES ('admin@blog.com', '$2a$10$...', '관리자', 'admin', 'ADMIN');

```

#### 5. 핵심 Java 클래스 구현

##### User DTO (`dto/User.java`)

```java
package com.myblog.dto;

import java.time.LocalDateTime;

public class User {
    private int userId;
    private String email;
    private String password;
    private String name;
    private String nickname;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime lastLoginAt;
    private boolean isActive;
    private String role; // USER, ADMIN

    // 기본 생성자
    public User() {}

    // 로그인용 생성자
    public User(String email, String password) {
        this.email = email;
        this.password = password;
    }

    // Getter/Setter 메소드들...
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    // 편의 메소드
    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }
}

```

##### UserSession DTO (`dto/UserSession.java`)

```java
package com.myblog.dto;

import java.time.LocalDateTime;

public class UserSession {
    private String sessionId;
    private int userId;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private boolean isActive;
    private String ipAddress;
    private String userAgent;

    // 생성자
    public UserSession() {}

    public UserSession(String sessionId, int userId, LocalDateTime expiresAt) {
        this.sessionId = sessionId;
        this.userId = userId;
        this.expiresAt = expiresAt;
        this.isActive = true;
        this.createdAt = LocalDateTime.now();
    }

    // Getter/Setter 메소드들...
    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    // 만료 체크
    public boolean isExpired() {
        return expiresAt.isBefore(LocalDateTime.now());
    }
}

```

##### PasswordUtil (`util/PasswordUtil.java`)

```java
package com.myblog.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    // 비밀번호 해싱 (SHA-256 + Salt)
    public static String hashPassword(String password) {
        try {
            // Salt 생성
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);

            // 비밀번호 + Salt 해싱
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));

            // Salt + Hash를 Base64로 인코딩하여 저장
            byte[] saltAndHash = new byte[salt.length + hashedPassword.length];
            System.arraycopy(salt, 0, saltAndHash, 0, salt.length);
            System.arraycopy(hashedPassword, 0, saltAndHash, salt.length, hashedPassword.length);

            return Base64.getEncoder().encodeToString(saltAndHash);

        } catch (Exception e) {
            throw new RuntimeException("비밀번호 해싱 중 오류가 발생했습니다.", e);
        }
    }

    // 비밀번호 검증
    public static boolean verifyPassword(String password, String storedHash) {
        try {
            byte[] saltAndHash = Base64.getDecoder().decode(storedHash);

            // Salt 추출 (첫 16바이트)
            byte[] salt = new byte[16];
            System.arraycopy(saltAndHash, 0, salt, 0, 16);

            // 입력된 비밀번호를 같은 방식으로 해싱
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));

            // 저장된 해시와 비교
            for (int i = 0; i < hashedPassword.length; i++) {
                if (saltAndHash[16 + i] != hashedPassword[i]) {
                    return false;
                }
            }
            return true;

        } catch (Exception e) {
            return false;
        }
    }
}

```

##### SessionUtil (`util/SessionUtil.java`)

```java
package com.myblog.util;

import com.myblog.dto.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import java.security.SecureRandom;
import java.util.Base64;

public class SessionUtil {

    public static final String LOGIN_USER_KEY = "loginUser";
    public static final String REMEMBER_ME_COOKIE = "rememberMe";
    public static final int REMEMBER_ME_DAYS = 30;

    // 로그인 처리
    public static void login(HttpServletRequest request, User user, boolean rememberMe) {
        HttpSession session = request.getSession();
        session.setAttribute(LOGIN_USER_KEY, user);
        session.setMaxInactiveInterval(30 * 60); // 30분

        if (rememberMe) {
            // Remember Me 쿠키 설정
            String rememberToken = generateRememberToken();
            Cookie cookie = new Cookie(REMEMBER_ME_COOKIE, rememberToken);
            cookie.setMaxAge(REMEMBER_ME_DAYS * 24 * 60 * 60); // 30일
            cookie.setPath("/");
            cookie.setHttpOnly(true);

            // TODO: DB에 remember token 저장 (UserSessionDAO 사용)
        }
    }

    // 로그아웃 처리
    public static void logout(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Remember Me 쿠키 삭제
        Cookie cookie = new Cookie(REMEMBER_ME_COOKIE, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
    }

    // 로그인 상태 확인
    public static boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(LOGIN_USER_KEY) != null;
    }

    // 로그인 사용자 정보 조회
    public static User getLoginUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(LOGIN_USER_KEY);
        }
        return null;
    }

    // 관리자 권한 확인
    public static boolean isAdmin(HttpServletRequest request) {
        User user = getLoginUser(request);
        return user != null && user.isAdmin();
    }

    // Remember Token 생성
    private static String generateRememberToken() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[64];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().encodeToString(bytes);
    }

    // 클라이언트 IP 주소 추출
    public static String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }

        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }

        return request.getRemoteAddr();
    }
}

```

##### UserDAO 확장 (`dao/UserDAO.java`)

```java
package com.myblog.dao;

import com.myblog.dto.User;
import com.myblog.util.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;

public class UserDAO {

    // 로그인 인증
    public User authenticate(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND is_active = true";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                User user = mapResultSetToUser(rs);
                // 비밀번호 검증은 Service 레이어에서 수행
                return user;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // 마지막 로그인 시간 업데이트
    public boolean updateLastLoginTime(int userId) {
        String sql = "UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 이메일로 사용자 조회
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // 사용자 추가 (회원가입)
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (email, password, name, nickname) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getEmail());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getName());
            pstmt.setString(4, user.getNickname());

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ResultSet을 User 객체로 매핑
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setName(rs.getString("name"));
        user.setNickname(rs.getString("nickname"));
        user.setActive(rs.getBoolean("is_active"));
        user.setRole(rs.getString("role"));

        // Timestamp를 LocalDateTime으로 변환
        Timestamp lastLogin = rs.getTimestamp("last_login_at");
        if (lastLogin != null) {
            user.setLastLoginAt(lastLogin.toLocalDateTime());
        }

        return user;
    }
}

```

#### 6. JSP 구현 예시

##### 로그인 폼 (`user/login_form.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>로그인 - 마이 블로그</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <h2>로그인</h2>

        <%-- 에러 메시지 표시 --%>
        <c:if test="${param.error eq 'invalid'}">
            <div class="error">이메일 또는 비밀번호가 올바르지 않습니다.</div>
        </c:if>
        <c:if test="${param.error eq 'inactive'}">
            <div class="error">비활성화된 계정입니다. 관리자에게 문의하세요.</div>
        </c:if>
        <c:if test="${param.signup eq 'success'}">
            <div class="success">회원가입이 완료되었습니다. 로그인해주세요.</div>
        </c:if>
        <c:if test="${param.logout eq 'success'}">
            <div class="success">로그아웃되었습니다.</div>
        </c:if>

        <form action="login_action.jsp" method="post">
            <div class="form-group">
                <label for="email">이메일:</label>
                <input type="email" id="email" name="email" required
                       value="${param.email}" placeholder="example@email.com">
            </div>

            <div class="form-group">
                <label for="password">비밀번호:</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-group">
                <label>
                    <input type="checkbox" name="rememberMe" value="true">
                    로그인 상태 유지 (30일)
                </label>
            </div>

            <button type="submit">로그인</button>
        </form>

        <p>
            <a href="signup_form.jsp">회원가입</a> |
            <a href="../post/list.jsp">게시글 목록으로</a>
        </p>
    </div>
</body>
</html>

```

##### 로그인 처리 (`user/login_action.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.myblog.dto.User" %>
<%@ page import="com.myblog.dao.UserDAO" %>
<%@ page import="com.myblog.util.PasswordUtil" %>
<%@ page import="com.myblog.util.SessionUtil" %>

<%-- --- 로그인 처리 로직 --- --%>
<%
    request.setCharacterEncoding("UTF-8");

    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String rememberMeParam = request.getParameter("rememberMe");
    boolean rememberMe = "true".equals(rememberMeParam);

    // 입력값 검증
    if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
        response.sendRedirect("login_form.jsp?error=missing_fields");
        return;
    }

    UserDAO userDAO = new UserDAO();
    String redirectUrl = "login_form.jsp";
    String errorParam = "";

    try {
        // 사용자 인증
        User user = userDAO.authenticate(email, password);

        if (user != null) {
            // 비밀번호 검증
            if (PasswordUtil.verifyPassword(password, user.getPassword())) {
                if (user.isActive()) {
                    // 로그인 성공
                    SessionUtil.login(request, user, rememberMe);
                    userDAO.updateLastLoginTime(user.getUserId());

                    // 원래 요청했던 페이지로 리다이렉트 (있다면)
                    String returnUrl = request.getParameter("returnUrl");
                    if (returnUrl != null && !returnUrl.isEmpty()) {
                        redirectUrl = returnUrl;
                    } else {
                        redirectUrl = "../post/list.jsp";
                    }
                } else {
                    // 비활성화된 계정
                    errorParam = "?error=inactive";
                }
            } else {
                // 비밀번호 불일치
                errorParam = "?error=invalid&email=" + java.net.URLEncoder.encode(email, "UTF-8");
            }
        } else {
            // 사용자 없음
            errorParam = "?error=invalid&email=" + java.net.URLEncoder.encode(email, "UTF-8");
        }

    } catch (Exception e) {
        e.printStackTrace();
        errorParam = "?error=system";
    }

    response.sendRedirect(redirectUrl + errorParam);
%>

```

##### 로그아웃 처리 (`user/logout_action.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.myblog.util.SessionUtil" %>

<%-- --- 로그아웃 처리 --- --%>
<%
    SessionUtil.logout(request, response);
    response.sendRedirect("login_form.jsp?logout=success");
%>

### 공통 헤더 (로그인 상태 표시) (`common/header.jsp`)

```

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.myblog.util.SessionUtil" %>

<%@ page import="com.myblog.dto.User" %>

<%@ taglib uri="[http://java.sun.com/jsp/jstl/core](http://java.sun.com/jsp/jstl/core)" prefix="c" %>

<%-- 로그인 상태 확인 --%>

<%

%>

<header class="site-header">

</header>

```javascript
### 인증 체크 공통 로직 (`common/auth_check.jsp`)
```

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.myblog.util.SessionUtil" %>

<%--

--%>

<%

%>

```javascript
### 관리자 권한 체크 (`common/admin_check.jsp`)
```

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.myblog.util.SessionUtil" %>

<%--

--%>

<%

%>

##### 회원가입 처리 (`user/signup_action.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.myblog.dto.User" %>
<%@ page import="com.myblog.dao.UserDAO" %>
<%@ page import="com.myblog.util.PasswordUtil" %>

<%-- --- 회원가입 처리 로직 --- --%>
<%
    request.setCharacterEncoding("UTF-8");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    String name = request.getParameter("name");
    String nickname = request.getParameter("nickname");

    // 입력값 검증
    if (email == null || password == null || name == null || nickname == null ||
        email.isEmpty() || password.isEmpty() || name.isEmpty() || nickname.isEmpty()) {
        response.sendRedirect("signup_form.jsp?error=missing_fields");
        return;
    }

    // 비밀번호 확인 검증
    if (!password.equals(confirmPassword)) {
        response.sendRedirect("signup_form.jsp?error=password_mismatch&email=" +
                            java.net.URLEncoder.encode(email, "UTF-8") +
                            "&name=" + java.net.URLEncoder.encode(name, "UTF-8") +
                            "&nickname=" + java.net.URLEncoder.encode(nickname, "UTF-8"));
        return;
    }

    // 비밀번호 강도 검증 (최소 8자, 영문+숫자 조합)
    if (password.length() < 8 || !password.matches(".*[a-zA-Z].*") || !password.matches(".*[0-9].*")) {
        response.sendRedirect("signup_form.jsp?error=weak_password&email=" +
                            java.net.URLEncoder.encode(email, "UTF-8") +
                            "&name=" + java.net.URLEncoder.encode(name, "UTF-8") +
                            "&nickname=" + java.net.URLEncoder.encode(nickname, "UTF-8"));
        return;
    }

    User user = new User();
    user.setEmail(email.trim());
    user.setPassword(PasswordUtil.hashPassword(password));
    user.setName(name.trim());
    user.setNickname(nickname.trim());

    UserDAO userDAO = new UserDAO();
    boolean success = false;
    String redirectUrl = "signup_form.jsp";
    String messageParam = "";

    try {
        // 중복 이메일 체크
        User existingUser = userDAO.getUserByEmail(email);
        if (existingUser != null) {
            messageParam = "?error=duplicate_email&name=" +
                          java.net.URLEncoder.encode(name, "UTF-8") +
                          "&nickname=" + java.net.URLEncoder.encode(nickname, "UTF-8");
        } else {
            success = userDAO.addUser(user);
            if (success) {
                redirectUrl = "login_form.jsp";
                messageParam = "?signup=success";
            } else {
                messageParam = "?error=db_error";
            }
        }
    } catch (Exception e) {
         e.printStackTrace();
         messageParam = "?error=system";
    }

    response.sendRedirect(redirectUrl + messageParam);
%>

```

##### 프로필 페이지 (`user/profile.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../common/auth_check.jsp" %>
<%@ page import="com.myblog.util.SessionUtil" %>
<%@ page import="com.myblog.dto.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    User loginUser = SessionUtil.getLoginUser(request);
    request.setAttribute("user", loginUser);
%>

<!DOCTYPE html>
<html>
<head>
    <title>프로필 - 마이 블로그</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="container">
        <h2>내 프로필</h2>

        <%-- 성공/에러 메시지 --%>
        <c:if test="${param.update eq 'success'}">
            <div class="success">프로필이 수정되었습니다.</div>
        </c:if>
        <c:if test="${param.error eq 'nickname_duplicate'}">
            <div class="error">이미 사용 중인 닉네임입니다.</div>
        </c:if>

        <form action="profile_action.jsp" method="post">
            <div class="form-group">
                <label>이메일 (변경불가):</label>
                <input type="text" value="${user.email}" readonly>
            </div>

            <div class="form-group">
                <label for="name">이름:</label>
                <input type="text" id="name" name="name" value="${user.name}" required>
            </div>

            <div class="form-group">
                <label for="nickname">닉네임:</label>
                <input type="text" id="nickname" name="nickname" value="${user.nickname}" required>
            </div>

            <div class="form-group">
                <label for="newPassword">새 비밀번호 (변경시에만 입력):</label>
                <input type="password" id="newPassword" name="newPassword"
                       placeholder="8자 이상, 영문+숫자 조합">
            </div>

            <div class="form-group">
                <label for="confirmPassword">비밀번호 확인:</label>
                <input type="password" id="confirmPassword" name="confirmPassword">
            </div>

            <div class="form-group">
                <label for="currentPassword">현재 비밀번호 (필수):</label>
                <input type="password" id="currentPassword" name="currentPassword" required>
            </div>

            <button type="submit">프로필 수정</button>
        </form>

        <div class="profile-info">
            <h3>계정 정보</h3>
            <p>가입일: <fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd HH:mm"/></p>
            <p>마지막 로그인:
                <c:choose>
                    <c:when test="${user.lastLoginAt != null}">
                        <fmt:formatDate value="${user.lastLoginAt}" pattern="yyyy-MM-dd HH:mm"/>
                    </c:when>
                    <c:otherwise>정보 없음</c:otherwise>
                </c:choose>
            </p>
            <p>권한: ${user.role}</p>
        </div>
    </div>
</body>
</html>

```

##### 게시글 작성 폼 (로그인 필요) (`post/form.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../common/auth_check.jsp" %>
<%@ page import="com.myblog.dao.CategoryDAO" %>
<%@ page import="com.myblog.dto.Category" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- 카테고리 목록 조회 --%>
<%
    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categoryList = null;
    try {
        categoryList = categoryDAO.getAllCategories();
    } catch (Exception e) {
        e.printStackTrace();
    }
    request.setAttribute("categoryList", categoryList);
%>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 작성 - 마이 블로그</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="container">
        <h2>새 게시글 작성</h2>

        <form action="post_action.jsp" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="create">

            <div class="form-group">
                <label for="categoryId">카테고리:</label>
                <select id="categoryId" name="categoryId" required>
                    <option value="">카테고리 선택</option>
                    <c:forEach var="category" items="${categoryList}">
                        <option value="${category.categoryId}">${category.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label for="title">제목:</label>
                <input type="text" id="title" name="title" required maxlength="255">
            </div>

            <div class="form-group">
                <label for="content">내용:</label>
                <textarea id="content" name="content" rows="15" required></textarea>
            </div>

            <div class="form-group">
                <label for="imageFile">이미지 첨부 (선택사항):</label>
                <input type="file" id="imageFile" name="imageFile" accept="image/*">
            </div>

            <div class="form-actions">
                <button type="submit">게시글 작성</button>
                <a href="list.jsp" class="btn-cancel">취소</a>
            </div>
        </form>
    </div>
</body>
</html>

```

##### 게시글 상세보기 (수정/삭제 권한 체크) (`post/view.jsp`)

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.myblog.dao.PostDAO" %>
<%@ page import="com.myblog.dao.CommentDAO" %>
<%@ page import="com.myblog.dto.Post" %>
<%@ page import="com.myblog.dto.Comment" %>
<%@ page import="com.myblog.util.SessionUtil" %>
<%@ page import="com.myblog.dto.User" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- 게시글 조회 및 조회수 증가 --%>
<%
    String postIdStr = request.getParameter("postId");
    int postId = 0;
    try {
        postId = Integer.parseInt(postIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("list.jsp?error=invalid_post");
        return;
    }

    PostDAO postDAO = new PostDAO();
    CommentDAO commentDAO = new CommentDAO();
    Post post = null;
    List<Comment> commentList = null;

    try {
        post = postDAO.getPostById(postId);
        if (post == null) {
            response.sendRedirect("list.jsp?error=post_not_found");
            return;
        }

        // 조회수 증가
        postDAO.increaseViewCount(postId);

        // 댓글 목록 조회
        commentList = commentDAO.getCommentsByPostId(postId);

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("list.jsp?error=system");
        return;
    }

    // 현재 로그인 사용자 정보
    User loginUser = SessionUtil.getLoginUser(request);
    boolean canEdit = false;
    boolean canDelete = false;

    if (loginUser != null) {
        // 작성자이거나 관리자인 경우 수정/삭제 가능
        canEdit = (loginUser.getUserId() == post.getUserId()) || loginUser.isAdmin();
        canDelete = canEdit;
    }

    request.setAttribute("post", post);
    request.setAttribute("commentList", commentList);
    request.setAttribute("canEdit", canEdit);
    request.setAttribute("canDelete", canDelete);
    request.setAttribute("loginUser", loginUser);
%>

<!DOCTYPE html>
<html>
<head>
    <title>${post.title} - 마이 블로그</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="container">
        <article class="post-detail">
            <header class="post-header">
                <h1>${post.title}</h1>
                <div class="post-meta">
                    <span>작성자: ${post.nickname}</span>
                    <span>카테고리: ${post.categoryName}</span>
                    <span>작성일: <fmt:formatDate value="${post.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
                    <span>조회수: ${post.viewCount}</span>
                </div>

                <%-- 수정/삭제 버튼 (권한 있는 경우만) --%>
                <c:if test="${canEdit || canDelete}">
                    <div class="post-actions">
                        <c:if test="${canEdit}">
                            <a href="form.jsp?action=edit&postId=${post.postId}" class="btn-edit">수정</a>
                        </c:if>
                        <c:if test="${canDelete}">
                            <a href="delete_action.jsp?postId=${post.postId}"
                               onclick="return confirm('정말 삭제하시겠습니까?')" class="btn-delete">삭제</a>
                        </c:if>
                    </div>
                </c:if>
            </header>

            <div class="post-content">
                <c:if test="${not empty post.imagePath}">
                    <img src="${pageContext.request.contextPath}/images/${post.imagePath}"
                         alt="게시글 이미지" class="post-image">
                </c:if>

                <div class="content-text">
                    ${post.content}
                </div>
            </div>
        </article>

        <%-- 댓글 섹션 --%>
        <section class="comments-section">
            <h3>댓글 (${commentList.size()}개)</h3>

            <%-- 댓글 작성 폼 (로그인된 경우만) --%>
            <c:if test="${isLoggedIn}">
                <form action="../comment/comment_action.jsp" method="post" class="comment-form">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="postId" value="${post.postId}">
                    <textarea name="content" placeholder="댓글을 입력하세요..." required></textarea>
                    <button type="submit">댓글 작성</button>
                </form>
            </c:if>

            <%-- 댓글 목록 --%>
            <div class="comments-list">
                <c:choose>
                    <c:when test="${not empty commentList}">
                        <c:forEach var="comment" items="${commentList}">
                            <div class="comment">
                                <div class="comment-header">
                                    <strong>${comment.nickname}</strong>
                                    <span class="comment-date">
                                        <fmt:formatDate value="${comment.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </span>

                                    <%-- 댓글 삭제 버튼 (작성자나 관리자만) --%>
                                    <c:if test="${loginUser != null && (loginUser.userId == comment.userId || loginUser.admin)}">
                                        <a href="../comment/comment_action.jsp?action=delete&commentId=${comment.commentId}&postId=${post.postId}"
                                           onclick="return confirm('댓글을 삭제하시겠습니까?')" class="btn-delete-comment">삭제</a>
                                    </c:if>
                                </div>
                                <div class="comment-content">
                                    ${comment.content}
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p class="no-comments">첫 번째 댓글을 작성해보세요!</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <div class="post-navigation">
            <a href="list.jsp">목록으로 돌아가기</a>
        </div>
    </div>
</body>
</html>

```

#### 7. 세션 관리 고급 기능

##### SessionDAO (`dao/SessionDAO.java`)

```java
package com.myblog.dao;

import com.myblog.dto.UserSession;
import com.myblog.util.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class SessionDAO {

    // Remember Me 세션 저장
    public boolean saveRememberMeSession(UserSession session) {
        String sql = "INSERT INTO user_sessions (session_id, user_id, expires_at, ip_address, user_agent) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, session.getSessionId());
            pstmt.setInt(2, session.getUserId());
            pstmt.setTimestamp(3, Timestamp.valueOf(session.getExpiresAt()));
            pstmt.setString(4, session.getIpAddress());
            pstmt.setString(5, session.getUserAgent());

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Remember Me 세션 조회 및 검증
    public UserSession getValidRememberMeSession(String sessionId) {
        String sql = "SELECT * FROM user_sessions WHERE session_id = ? AND is_active = true AND expires_at > CURRENT_TIMESTAMP";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, sessionId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToSession(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // 만료된 세션 정리
    public int cleanupExpiredSessions() {
        String sql = "DELETE FROM user_sessions WHERE expires_at < CURRENT_TIMESTAMP";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            return pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // 사용자의 모든 세션 무효화 (로그아웃)
    public boolean invalidateUserSessions(int userId) {
        String sql = "UPDATE user_sessions SET is_active = false WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private UserSession mapResultSetToSession(ResultSet rs) throws SQLException {
        UserSession session = new UserSession();
        session.setSessionId(rs.getString("session_id"));
        session.setUserId(rs.getInt("user_id"));
        session.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        session.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
        session.setActive(rs.getBoolean("is_active"));
        session.setIpAddress(rs.getString("ip_address"));
        session.setUserAgent(rs.getString("user_agent"));
        return session;
    }
}

```

#### 8. build.gradle (JSP Model 1 용)

```text
plugins {
    id 'java'
    id 'war'
}

group 'kr.goo.mini.blog'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

ext {
    junitVersion = '5.11.0'
    lombokVersion = '1.18.30'
    jstlVersion = '2.0.0'
    mysqlConnectorVersion = '8.4.0'
}

sourceCompatibility = '17'
targetCompatibility = '17'

tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
}

dependencies {
    compileOnly('jakarta.servlet:jakarta.servlet-api:6.1.0')
    compileOnly "org.projectlombok:lombok:${lombokVersion}"
    implementation "com.mysql:mysql-connector-j:${mysqlConnectorVersion}"
    implementation("jakarta.servlet.jsp.jstl:jakarta.servlet.jsp.jstl-api:${jstlVersion}")
    implementation("org.glassfish.web:jakarta.servlet.jsp.jstl:${jstlVersion}")
    annotationProcessor "org.projectlombok:lombok:${lombokVersion}"

    testImplementation("org.junit.jupiter:junit-jupiter-api:${junitVersion}")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:${junitVersion}")
}

test {
    useJUnitPlatform()
}

```

#### 9. web.xml (JSP Model 1 용)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_5_0.xsd"
         version="5.0">

    <display-name>My Blog Application (JSP Model 1)</display-name>

    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
        <welcome-file>post/list.jsp</welcome-file>
    </welcome-file-list>

    <!-- 문자 인코딩 필터 -->
    <filter>
        <filter-name>CharacterEncodingFilter</filter-name>
        <filter-class>org.apache.catalina.filters.SetCharacterEncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
        <init-param>
            <param-name>ignore</param-name>
            <param-value>false</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>CharacterEncodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <!-- 세션 설정 -->
    <session-config>
        <session-timeout>30</session-timeout> <!-- 30분 -->
        <cookie-config>
            <http-only>true</http-only>
            <secure>false</secure> <!-- HTTPS 환경에서는 true로 설정 -->
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
    </session-config>

    <!-- 에러 페이지 설정 -->
    <error-page>
        <error-code>404</error-code>
        <location>/error/404.jsp</location>
    </error-page>

    <error-page>
        <error-code>500</error-code>
        <location>/error/500.jsp</location>
    </error-page>

</web-app>

```

#### 10. 필요 산출물 정리 (JSP Model 1 + 인증)

##### Java 소스 코드:

- **DTO:** `User.java`, `Post.java`, `Category.java`, `Comment.java`, `UserSession.java`
- **DAO:** `UserDAO.java`, `PostDAO.java`, `CategoryDAO.java`, `CommentDAO.java`, `SessionDAO.java`
- **Util:** `PasswordUtil.java`, `SessionUtil.java`, `DBConnection.java`
##### JSP 파일:

- **공통:** `header.jsp`, `footer.jsp`, `auth_check.jsp`, `admin_check.jsp`
- **사용자:** `login_form.jsp`, `login_action.jsp`, `logout_action.jsp`, `signup_form.jsp`, `signup_action.jsp`, `profile.jsp`, `profile_action.jsp`
- **게시글:** `list.jsp`, `view.jsp`, `form.jsp`, `post_action.jsp`, `delete_action.jsp`
- **댓글:** `comment_action.jsp`
- **관리자:** `userList.jsp`, `category.jsp`, `category_action.jsp`
##### 정적 파일:

- **CSS:** `style.css`
- **JavaScript:** `main.js` (선택사항)
- **이미지:** 업로드된 이미지 파일들
##### 설정 파일:

- `build.gradle` 또는 `pom.xml`
- `web.xml`
##### DB 스크립트:

- 테이블 생성 SQL

---

## 11.25 [PJ]블로그 작성하기 미니프로젝트

**🎯 목표**: 블로그 작성 미니프로젝트로 CRUD를 구현한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 게시판, 인증, 댓글, 카테고리, 관리자 기능을 한 번에 묶어 보는 미니프로젝트 초안입니다.
`JDBC + JSP -> 서블릿 MVC -> Spring`으로 단계적으로 확장하는 연습용 과제로 두고, 기능 요구사항을 정제하고 DB 모델링으로 연결하는 연습에 사용합니다.

#### 사용자 이용 시나리오
**신규 사용자 가입 및 이용**
인터넷을 검색하다 발견한 블로그 사이트에 방문한 미나는 글을 남기고 싶어 회원가입을 합니다. 이메일, 비밀번호와 함께 이름과 닉네임을 입력하여 가입을 완료했습니다. 이제 자신만의 글을 작성하고 다른 사람들의 글에 댓글을 달 수 있게 되었습니다.
**기존 사용자의 블로그 활동**
회원인 준호는 오늘도 로그인 후 자신이 관심 있는 IT 카테고리의 글들을 둘러봅니다. 마음에 드는 글을 발견하고 댓글을 남깁니다. 그리고 자신이 알게 된 새로운 기술에 대한 정보를 공유하기 위해 새 글을 작성합니다. 글을 쓴 후, 오탈자를 발견하고 수정합니다.
**프로필 관리**
소영은 블로그에서 활동한 지 6개월이 되었습니다. 닉네임이 마음에 들지 않아 마이페이지에서 프로필을 수정하려고 합니다. 자신의 정보를 확인하고 닉네임을 변경한 후 저장합니다.

#### 게시글 이용 시나리오
**글 작성과 수정**
요리에 관심이 많은 민재는 오늘 만든 특별한 요리 레시피를 공유하고 싶어합니다. '요리' 카테고리를 선택하고 '바삭한 치킨 윙 만들기'라는 제목으로 글을 작성합니다. 사진도 함께 첨부하고 상세한 조리 과정을 설명합니다. 나중에 빠진 재료를 발견하고 글을 수정합니다.
**글 검색과 조회**
치킨 요리를 만들어보고 싶은 지연은 블로그에서 '치킨'을 검색합니다. 여러 검색 결과 중 민재의 '바삭한 치킨 윙 만들기' 글을 발견하고 클릭하여 상세 내용을 읽습니다. 유용한 정보에 감사 댓글을 남깁니다.
**카테고리별 탐색**
영화 리뷰에 관심 있는 동현은 '영화' 카테고리를 클릭하여 최근에 올라온 영화 리뷰들을 모아서 봅니다. 관심 있는 영화 리뷰를 발견하면 클릭하여 자세히 읽습니다.

#### 관리자 시나리오
**사용자 관리**
블로그 관리자인 세진은 정기적으로 회원 목록을 확인합니다. 악성 댓글을 자주 다는 사용자가 신고되어 해당 사용자의 활동을 검토한 후, 규정을 위반한 내용이 확인되어 해당 계정을 정지시킵니다.
**카테고리 관리**
관리자 세진은 사용자들의 요청을 반영하여 새로운 카테고리 '여행'을 추가합니다. 또한 이용률이 낮은 '일상' 카테고리의 이름을 '라이프스타일'로 변경하기로 결정하고 수정합니다.
**게시글 관리**
신고된 게시글에 대해 세진은 내용을 검토합니다. 커뮤니티 가이드라인을 위반한 글을 발견하고 해당 게시글을 삭제 처리합니다. 작성자에게 가이드라인을 안내하는 메시지를 보냅니다.

#### 댓글 이용 시나리오
**댓글 작성 및 소통**
유익한 글을 읽은 현우는 작성자에게 감사의 마음을 전하고 추가 질문을 하기 위해 댓글을 남깁니다. 작성자가 답변을 달면 알림을 받고 다시 방문하여 대화를 이어나갑니다.
**댓글 관리**
자신의 글에 달린 댓글 중 부적절한 내용을 발견한 수진은 해당 댓글을 신고합니다. 또한 자신이 실수로 작성한 댓글을 수정하거나 필요 없는 댓글은 직접 삭제합니다.

### 요구사항 시나리오 정제 (숙제)

누가 무엇을 어떻게
사용자
- [ ] 회원가입이 가능하다
- [ ] 로그인이 가능하다
- [ ] 로그아웃이 가능하다
- [ ] 게시글을 작성, 수정, 삭제할 수 있다
- [ ] 댓글을 작성, 수정, 삭제할 수 있다
- [ ] 부적절한 내용을 발견할 시 신고할 수 있다

게시글
- [ ] 각 게시글에는 여러 카테고리를 생성할 수 있다
- [ ] 블로그 내에서 게시글을 검색할 수 있다
- [ ] 각 게시글에는 댓글을 작성할 수 있다
- [ ] 게시글들은 카테고리 별로 분류되어 있다
관리자
- [ ] 회원 목록 확인이 가능하다
- [ ] 회원 관리가 가능하다. 정지 등
- [ ] 카테고리를 추가, 수정, 삭제할 수 있다
- [ ] 신고 받은 게시글이 있을 때 작성자에게 안내 메시지 발송된다
댓글
- [ ] 댓글에 답변이 달릴 시 댓글 작성자에게 알림을 보낸다

### 기능 명세서 (숙제)
1. 사용자 관리
1-1 회원가입
           이메일 형식 확인       중복 확인 불필요
           닉네임 입력                중복 확인 필요		조건 : 10자 이하
           이름 입력	                중복 확인 불필요
           비밀번호 입력	        조건 : 8자 이상/특수기호, 영문, 숫자 포함
1-2 로그인/로그아웃
           로그인	                       이메일 + 비밀번호 형식
           로그아웃		       별도 페이지 불필요
1-3 프로필 관리
           마이페이지                변경 즉시 반영		이메일, 이름, 닉네임, 비밀번호 변경 가능
1-4 사용자 알림
           댓글	                      쓴 댓글에 답글이 달릴 시 알림 전송
1. 게시글 관리
2-1 작성
          게시글 작성               카테고리 선택, 제목, 본문 작성
          이미지 첨부               PUG, JPEG, GIF
2-2 수정/삭제
          게시글수정/삭제      본인이 작성한 글에 한정     수정 시 기존 내용 불러오기
2-3 검색
          게시글 검색               키워드 기반 검색                  제목, 본문 기준
          카테고리                    해당 카테고리 클릭시 게시글 목록 불러오기        최신순으로 정렬
2-4 상세보기
          게시글                        제목, 작성자, 작성일, 본문, 이미지 표시
          댓글                            댓글 목록 표시
1. 댓글 관리
3-1 작성
          댓글 작성                   게시글 하단에 작성               즉시 반영/새로고침 후 반영
3-2 수정/삭제
          댓글 수정/삭제         본인이 작성한 댓글에 한정   수정 시 기존 내용 불러오기
3-3 신고
          댓글 신고                   부적절한 댓글 신고 기능       사유 선택 후 세부 사유 작성 가능/조건 : 100자 이내
3-4 알림
          댓글 알림                   답변 시 작성자에게 알림 전송
1. 관리자 기능
4-1 사용자 관리
          사용자 목록               전체 사용자 목록
          신고 목록                   신고된 사용자 이력 확인
          사용자 관리               계정 정지 / 경고 알림 전송
4-2 카테고리 관리
          카테고리                    카테고리 추가/수정/삭제      카테고리 이름 변경 가능
4-3 게시글 관리
          신고 게시글               신고된 게시글 목록 열람       해당 게시글 삭제 가능
          경고 알림                   작성자에게 알림 전송
4-4 댓글 관리
          신고 댓글                  신고된 댓글 목록 열람            해당 댓글 삭제 가능
          경고 알림                  작성자에게 알림 전송/해당 작성자 제재 가능

### DB 모델링

### 객체 모델링

### 주요 SQL 쿼리 (숙제)

### 개발 단계

#### 1단계: JDBC + JSP 구현 (목록, 쓰기, 상세읽기, 수정하기, 삭제하기, 로그인)
- JDBC를 이용한 데이터베이스 연결 및 쿼리 실행
- JSP를 이용한 뷰 구현
- 각 기능별 JSP 페이지 구현
  - 로그인/회원가입 페이지
  - 게시글 목록/상세/작성/수정 페이지
  - 댓글 기능
  - 관리자 페이지

#### 2단계: MVC 패턴 + 서블릿 구현 (목록, 쓰기, 상세읽기, 수정하기, 삭제하기, 로그인)
- 1단계 코드를 MVC 패턴으로 리팩토링
- 모델(DAO, DTO), 뷰(JSP), 컨트롤러(서블릿) 분리
  - 서블릿을 이용한 컨트롤러 구현+++——
- Front Controller 패턴 적용
- 서비스 계층 추가

#### 3단계: Spring 프레임워크 적용

## 11.26 [PJ]메모 앱 토이프로젝트

**🎯 목표**: 메모 앱 토이 프로젝트로 객체지향을 적용한다.

<!-- 2026-06-29 라이브 Notion 최신본으로 갱신 -->

### 개요
이 문서는 콘솔 기반 CRUD를 가장 작은 프로젝트로 묶어 보는 부록 실습입니다. 복잡한 프레임워크보다 객체 설계, 컬렉션 관리, 파일 저장 또는 메모리 저장 구조를 먼저 잡는 연습용으로 보는 편이 좋습니다.

### 이 문서를 언제 보는가
- 클래스를 배웠지만 작은 프로그램을 끝까지 만들어 본 적이 없을 때
- 컬렉션, 파일 저장, 예외 처리, 테스트를 한 번에 엮는 연습이 필요할 때
- Spring으로 바로 가기 전에 순수 Java로 기능 흐름을 끝까지 경험하고 싶을 때

### 사용자 시나리오
주인공은 갑자기 떠오른 아이디어를 적고, 나중에 검색하고, 필요하면 수정하고, 더 이상 필요 없으면 삭제하고 싶어 합니다. 이 프로젝트는 그 최소 흐름을 콘솔 프로그램으로 구현하는 연습입니다.
핵심 흐름은 네 가지입니다.
1. 메모를 작성한다.
1. 목록을 조회한다.
1. 키워드로 검색한다.
1. 내용을 수정하거나 삭제한다.

### 먼저 정할 것
1. 중심 클래스를 찾는다.
1. 중심 클래스의 속성을 정의한다.
1. 생성 조건을 정의한다.
1. 기능을 정의한다.
1. 데이터 저장 방식을 정한다.
1. 기능별 반환값과 예외 상황을 정한다.
1. 구현한다.
1. 테스트한다.

### 권장 최소 설계

#### `Memo`
- `id`
- `title`
- `content`
- `createdAt`
- `modifiedAt`

#### `MemoApp` 또는 `MemoService`
- `addMemo`
- `listMemos`
- `searchMemo`
- `editMemo`
- `deleteMemo`
처음에는 `List<Memo>` 기반 메모리 저장으로 시작하고, 익숙해지면 파일 저장으로 확장합니다.

### 구현하면서 볼 포인트
- 메모 생성 시 ID는 어떻게 부여할 것인가
- 수정 시 `modifiedAt`을 어떻게 갱신할 것인가
- 검색 기준은 제목만 볼 것인가, 내용까지 볼 것인가
- 삭제 후 목록과 검색 결과가 일관되게 바뀌는가
- 빈 제목, 잘못된 ID 입력 같은 실패를 어떻게 처리할 것인가

### 예상 실행 흐름
```text
예상 결과
사용자는 메뉴에서 번호를 골라 메모를 추가, 조회, 검색, 수정, 삭제할 수 있다.
메모를 추가하면 목록에서 바로 확인할 수 있어야 한다.
검색 키워드를 입력하면 관련 메모만 출력되어야 한다.
수정 후에는 `modifiedAt`이 갱신되고, 삭제 후에는 목록에서 사라져야 한다.
```

### 콘솔 예시
```text
=== Memo Application ===
1. Add Memo
2. List Memos
3. Search Memo
4. Edit Memo
5. Delete Memo
6. Exit
Choose an option: 1
Enter title: title
Enter content: content
Memo added successfully!

=== Memo Application ===
1. Add Memo
2. List Memos
3. Search Memo
4. Edit Memo
5. Delete Memo
6. Exit
Choose an option: 2
ID: 1
Title: title
Content: content
Created: 2024-11-23 07:30:18
Modified: 2024-11-23 07:30:18
```
```text
예상 결과
첫 메모를 추가한 뒤 목록 조회를 하면 저장된 메모가 즉시 보인다.
수정 기능을 구현했다면 `Modified` 시간이 변경되어야 하고, 삭제 기능을 구현했다면 다시 조회했을 때 항목이 사라져야 한다.
```

### 함께 보면 좋은 문서
- 토이프로젝트 메모 앱 만들기 풀이 (→ 11.26-1)
- 미니프로젝트 과제 정리 (→ 11.10)
- **힌트 (어려울 때만 보세요)**

### 정리
이 프로젝트의 목적은 거대한 기능을 만드는 것이 아니라, 작은 요구사항을 클래스, 컬렉션, 예외 처리, 테스트로 끝까지 밀어 보는 데 있습니다. Spring 없이도 프로그램 구조를 세울 수 있어야 이후 프레임워크 학습이 훨씬 가벼워집니다.

### 한 줄 정리
메모 앱 토이프로젝트의 핵심은 **작은 CRUD를 끝까지 구현하면서 객체, 컬렉션, 예외, 저장 전략을 한 번에 묶어 보는 것**입니다.

## 11.26-1 [PJ]메모 앱 토이프로젝트 풀이

**🎯 목표**: 메모 앱 풀이를 확인한다.

<!-- 2026-06-29 라이브 Notion에서 수집 (4월 ingest 이후 추가분) -->

### 개요
이 문서는 메모 앱 토이프로젝트 (→ 11.26)의 예시 풀이입니다.
가장 단순한 콘솔 CRUD 구조를 먼저 완성한 뒤, 이후에는 파일 저장, 검색 조건 분리, 테스트 가능 구조로 확장하는 출발점으로 보면 됩니다.
```java
package com.example.ch4.toy;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class MemoApp {

    // 메모 클래스 정의
    static class Memo {
        private static int idCounter = 1;
        private int id;
        private String title;
        private String content;
        private String createdDate;
        private String modifiedDate;

        public Memo(String title, String content) {
            this.id = idCounter++;
            this.title = title;
            this.content = content;
            this.createdDate = getCurrentDateTime();
            this.modifiedDate = getCurrentDateTime();
        }

        public void updateContent(String title, String content) {
            this.title = title;
            this.content = content;
            this.modifiedDate = getCurrentDateTime();
        }

        @Override
        public String toString() {
            return "ID: " + id + "\nTitle: " + title + "\nContent: " + content +
                    "\nCreated: " + createdDate + "\nModified: " + modifiedDate + "\n";
        }

        private static String getCurrentDateTime() {
            return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        }

        public int getId() {
            return id;
        }

        public String getTitle() {
            return title;
        }
    }

    // 메모 리스트
    private static List<Memo> memoList = new ArrayList<>();

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while (true) {
            System.out.println("=== Memo Application ===");
            System.out.println("1. Add Memo");
            System.out.println("2. List Memos");
            System.out.println("3. Search Memo");
            System.out.println("4. Edit Memo");
            System.out.println("5. Delete Memo");
            System.out.println("6. Exit");
            System.out.print("Choose an option: ");
            int choice = scanner.nextInt();
            scanner.nextLine(); // Consume newline

            switch (choice) {
                case 1:
                    addMemo(scanner);
                    break;
                case 2:
                    listMemos();
                    break;
                case 3:
                    searchMemo(scanner);
                    break;
                case 4:
                    editMemo(scanner);
                    break;
                case 5:
                    deleteMemo(scanner);
                    break;
                case 6:
                    System.out.println("Exiting the application. Goodbye!");
                    return;
                default:
                    System.out.println("Invalid option. Please try again.");
            }
        }
    }

    private static void addMemo(Scanner scanner) {
        System.out.print("Enter title: ");
        String title = scanner.nextLine();
        System.out.print("Enter content: ");
        String content = scanner.nextLine();
        Memo memo = new Memo(title, content);
        memoList.add(memo);
        System.out.println("Memo added successfully!");
    }

    private static void listMemos() {
        if (memoList.isEmpty()) {
            System.out.println("No memos found.");
            return;
        }
        for (Memo memo : memoList) {
            System.out.println(memo);
        }
    }

    private static void searchMemo(Scanner scanner) {
        System.out.print("Enter keyword to search: ");
        String keyword = scanner.nextLine();
        boolean found = false;
        for (Memo memo : memoList) {
            if (memo.getTitle().contains(keyword)) {
                System.out.println(memo);
                found = true;
            }
        }
        if (!found) {
            System.out.println("No memos matched your search.");
        }
    }

    private static void editMemo(Scanner scanner) {
        System.out.print("Enter the ID of the memo to edit: ");
        int id = scanner.nextInt();
        scanner.nextLine(); // Consume newline
        for (Memo memo : memoList) {
            if (memo.getId() == id) {
                System.out.print("Enter new title: ");
                String newTitle = scanner.nextLine();
                System.out.print("Enter new content: ");
                String newContent = scanner.nextLine();
                memo.updateContent(newTitle, newContent);
                System.out.println("Memo updated successfully!");
                return;
            }
        }
        System.out.println("Memo with the given ID not found.");
    }

    private static void deleteMemo(Scanner scanner) {
        System.out.print("Enter the ID of the memo to delete: ");
        int id = scanner.nextInt();
        scanner.nextLine(); // Consume newline
        for (Memo memo : memoList) {
            if (memo.getId() == id) {
                memoList.remove(memo);
                System.out.println("Memo deleted successfully!");
                return;
            }
        }
        System.out.println("Memo with the given ID not found.");
    }
}

```


## 11.90 JVM 워크북: 연습 문제와 프로젝트

**🎯 목표**: JVM 워크북 문제로 9장 내용을 굳힌다.

<!-- 2026-06-29 라이브 Notion에서 수집 (4월 ingest 이후 추가분) -->

### 목차
1. 핵심 연습문제 (20문제)
1. 간단한 메모리 모니터 프로젝트
1. 실전 시나리오 (5문제)

---

### 1. 핵심 연습문제

#### JVM 기본 (1-5)
**1. JVM의 주요 역할 3가지는?**
**정답:** 바이트코드 실행, 자동 메모리 관리, 플랫폼 독립성 제공

---
**2. .java 파일과 .class 파일의 차이는?**
**정답:**
- .java: 사람이 작성한 소스 코드
- .class: 컴파일된 바이트코드

---
**3. 다음 출력 순서는?**
```java
class A {
    static { System.out.println("A 로드"); }
}

public class Main {
    public static void main(String[] args) {
        System.out.println("1");
        A a = new A();
        System.out.println("2");
    }
}

```
**정답:** `1` → `A 로드` → `2`

---
**4. JVM, JRE, JDK의 차이는?**
**정답:**
- JVM: 실행 환경
- JRE: JVM + 라이브러리
- JDK: JRE + 개발 도구

---
**5. 클래스는 언제 로드되나요?**
**정답:** 처음 사용될 때 (new, static 접근 시)

---

#### 메모리 구조 (6-12)
**6. 다음 변수들의 메모리 위치는?**
```java
public class Test {
    static int a = 10;      // ?
    int b = 20;             // ?

    public void method() {
        int c = 30;         // ?
        String s = new String("Hi");  // ?
    }
}

```
**정답:**
- `a`: Method Area
- `b`: Heap (객체 안)
- `c`: Stack
- `s` 변수: Stack, "Hi" 객체: Heap

---
**7. 힙과 스택의 차이는?**
**정답:**
- 힙: 객체 저장, 크고 느림, GC가 정리
- 스택: 지역변수 저장, 작고 빠름, 자동 정리

---
**8. 다음 중 힙에 저장되는 것은?**
```java
a) int age = 25;
b) String name = new String("Kim");
c) int[] arr = new int[10];

```
**정답:** b, c (객체와 배열)

---
**9. StackOverflowError는 왜 발생하나요?**
**정답:** 무한 재귀 호출로 스택 메모리가 가득 찰 때

---
**10. String Pool 위치는? (Java 7+)**
**정답:** Heap 영역

---
**11. 다음 코드의 출력은?**
```java
String s1 = "Hello";
String s2 = "Hello";
String s3 = new String("Hello");

System.out.println(s1 == s2);
System.out.println(s1 == s3);

```
**정답:** `true`, `false`

---
**12. 메소드 종료 시 지역 변수는?**
**정답:** 자동으로 삭제됨

---

#### 가비지 컬렉션 (13-20)
**13. 가비지 컬렉션이란?**
**정답:** 안 쓰는 객체를 자동으로 메모리에서 제거하는 기능

---
**14. 어떤 객체가 가비지가 되나요?**
**정답:** 아무도 참조하지 않는 객체

---
**15. 다음 코드에서 가비지가 되는 시점은?**
```java
String str1 = new String("A");
str1 = new String("B");  // ?

```
**정답:** `new String("B")` 할당 시 "A" 객체가 가비지

---
**16. Young 영역과 Old 영역의 차이는?**
**정답:**
- Young: 새 객체, 자주 GC (빠름)
- Old: 오래된 객체, 가끔 GC (느림)

---
**17. 다음 코드의 문제점은?**
```java
public class Cache {
    private static List<String> data = new ArrayList<>();

    public static void add(String item) {
        data.add(item);
    }
}

```
**정답:** 메모리 누수 (데이터가 계속 쌓임, 제거 안됨)

---
**18. try-with-resources의 장점은?**
**정답:** 리소스를 자동으로 닫아줌 (메모리 누수 방지)

---
**19. 다음 코드를 개선하세요.**
```java
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i;
}

```
**정답:**
```java
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);
}
String result = sb.toString();

```

---
**20. System.gc()를 호출하면?**
**정답:** GC를 "요청"만 할 뿐 강제 실행은 안 됨

---

### 2. 메모리 모니터 프로젝트

#### 간단한 메모리 모니터
```java
import java.util.*;

public class MemoryMonitor {

    public static void printMemory() {
        Runtime rt = Runtime.getRuntime();
        long total = rt.totalMemory() / 1024 / 1024;
        long free = rt.freeMemory() / 1024 / 1024;
        long used = total - free;

        System.out.println("=== 메모리 상태 ===");
        System.out.println("전체: " + total + " MB");
        System.out.println("사용: " + used + " MB");
        System.out.println("여유: " + free + " MB");
        System.out.printf("사용률: %.1f%%\n",
            (double)used/total * 100);
    }

    public static void loadTest() {
        List<String> list = new ArrayList<>();

        System.out.println("\n10만 개 객체 생성 중...");
        for (int i = 0; i < 100000; i++) {
            list.add("데이터" + i);
        }

        printMemory();

        System.out.println("\n객체 제거 중...");
        list.clear();
        list = null;
        System.gc();

        try { Thread.sleep(1000); }
        catch (InterruptedException e) {}

        printMemory();
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        while (true) {
            System.out.println("\n1.메모리 확인  2.부하테스트  3.종료");
            System.out.print("선택: ");
            int choice = sc.nextInt();

            if (choice == 1) printMemory();
            else if (choice == 2) loadTest();
            else if (choice == 3) break;
        }

        sc.close();
    }
}

```

#### 실행 방법
```bash
javac MemoryMonitor.java
java -Xmx256m MemoryMonitor

```

---

### 3. 실전 시나리오

#### 시나리오 1: 메모리 누수
**문제:**
```java
public class UserSession {
    private static Map<String, User> sessions = new HashMap<>();

    public static void login(String id, User user) {
        sessions.put(id, user);
    }
    // 로그아웃 없음!
}

```
