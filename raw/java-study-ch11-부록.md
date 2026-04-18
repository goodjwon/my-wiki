# 11. 부록
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 11.10 미니프로젝트 과제 정리

#### 개요

이 문서는 본문에서 배운 요구사항 분석, DB 설계, 객체 모델링을 프로젝트 단위로 묶어 보는 부록 실습 안내문입니다. 아래 항목은 단순 기능 목록이 아니라, 실제로 기능 명세서, 테이블 설계, API 설계, 테스트 시나리오로 확장할 수 있는 미니프로젝트 재료로 사용합니다.

#### 이 문서를 언제 보는가

- 본문 개념을 읽었지만 실제로 어떻게 묶어 프로젝트로 전개할지 막힐 때
- 요구사항, 테이블, 클래스, API를 한 번에 연결하는 연습이 필요할 때
- 작은 토이프로젝트를 어떤 기준으로 시작해야 할지 기준점이 필요할 때
#### 연결된 프로젝트

- [11.25 [PJ]블로그 작성하기 미니프로젝트]([11.25 [PJ]블로그 작성하기 미니프로젝트](https://www.notion.so/1d91e21f383680799346c4b7046a7bb5))
- [11.19 [PJ]온라인 게임 토이 프로젝트]([11.19 [PJ]온라인 게임 토이 프로젝트](https://www.notion.so/16c1e21f383680039e78de2f000def78))
- [11.26 [PJ]메모 앱 토이프로젝트]([11.26 [PJ]메모 앱 토이프로젝트](https://www.notion.so/13f1e21f38368054a177d693f0a95306))
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
```plain text
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
```plain text
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

## 11.18 GitHub 작업 순서 가이드

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

```plain text
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

```plain text
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

## 11.23 [PJ]Java/JSP(Model 1) 기반 블로그 개발 실습 가이드

#### 개요

이 문서는 JSP Model 1 방식으로 블로그를 만드는 과정을 정리한 레거시 실습 가이드입니다.

현재 책 본문에서는 직접 다루지 않지만, `JSP 기본 개념 예제`와 `블로그 작성하기 미니프로젝트`를 더 구체적인 코드 수준에서 연결해 보고 싶을 때 참고 자료로 사용할 수 있습니다.

### **Java/JSP(Model 1) 기반 블로그 개발 실습 가이드**

#### **1. 실습 프로세스 개요**

1. **환경 설정**
1. **프로젝트 생성**
1. **데이터베이스 설계 및 구축**
1. **모델(Model) 구현 (Java)**
1. **뷰(View) 및 로직 처리 구현 (JSP)**
1. **테스트 및 디버깅**
1. **배포 (선택 사항)**
#### **2. 프로젝트 구조 예시 (Maven 기준)**

```plain text
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

#### **3. 핵심 기술 및 개념**

- **JSP:** HTML 내 Java 코드 삽입 (스크립틀릿, 표현식, 선언부)
- **JDBC:** Java DB 연결 API
- **DAO/DTO:** DB 로직 분리 및 데이터 전달 객체
- **HttpSession:** 사용자 로그인 상태 관리
- **쿠키:** 자동 로그인 기능 (Remember Me)
- **JSP 액션 태그:** `<jsp:useBean>`, `<jsp:setProperty>`, `<jsp:getProperty>`
- **JSTL & EL:** 코드 가독성 향상 (권장)
#### **4. 데이터베이스 스키마 예시 (MySQL)**

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

#### **5. 핵심 Java 클래스 구현**

##### **User DTO (****`dto/User.java`****)**

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

##### **UserSession DTO (****`dto/UserSession.java`****)**

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

##### **PasswordUtil (****`util/PasswordUtil.java`****)**

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

##### **SessionUtil (****`util/SessionUtil.java`****)**

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

##### **UserDAO 확장 (****`dao/UserDAO.java`****)**

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

#### **6. JSP 구현 예시**

##### **로그인 폼 (****`user/login_form.jsp`****)**

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

##### **로그인 처리 (****`user/login_action.jsp`****)**

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

##### **로그아웃 처리 (****`user/logout_action.jsp`****)**

```java
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.myblog.util.SessionUtil" %>

<%-- --- 로그아웃 처리 --- --%>
<%
    SessionUtil.logout(request, response);
    response.sendRedirect("login_form.jsp?logout=success");
%>

### **공통 헤더 (로그인 상태 표시) (`common/header.jsp`)**

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
### **인증 체크 공통 로직 (****`common/auth_check.jsp`****)**
```

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.myblog.util.SessionUtil" %>

<%--

--%>

<%

%>

```javascript
### **관리자 권한 체크 (****`common/admin_check.jsp`****)**
```

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.myblog.util.SessionUtil" %>

<%--

--%>

<%

%>

##### **회원가입 처리 (****`user/signup_action.jsp`****)**

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

##### **프로필 페이지 (****`user/profile.jsp`****)**

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

##### **게시글 작성 폼 (로그인 필요) (****`post/form.jsp`****)**

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

##### **게시글 상세보기 (수정/삭제 권한 체크) (****`post/view.jsp`****)**

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

#### **7. 세션 관리 고급 기능**

##### **SessionDAO (****`dao/SessionDAO.java`****)**

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

#### **8. build.gradle (JSP Model 1 용)**

```plain text
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

#### **9. web.xml (JSP Model 1 용)**

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

#### **10. 필요 산출물 정리 (JSP Model 1 + 인증)**

##### **Java 소스 코드:**

- **DTO:** `User.java`, `Post.java`, `Category.java`, `Comment.java`, `UserSession.java`
- **DAO:** `UserDAO.java`, `PostDAO.java`, `CategoryDAO.java`, `CommentDAO.java`, `SessionDAO.java`
- **Util:** `PasswordUtil.java`, `SessionUtil.java`, `DBConnection.java`
##### **JSP 파일:**

- **공통:** `header.jsp`, `footer.jsp`, `auth_check.jsp`, `admin_check.jsp`
- **사용자:** `login_form.jsp`, `login_action.jsp`, `logout_action.jsp`, `signup_form.jsp`, `signup_action.jsp`, `profile.jsp`, `profile_action.jsp`
- **게시글:** `list.jsp`, `view.jsp`, `form.jsp`, `post_action.jsp`, `delete_action.jsp`
- **댓글:** `comment_action.jsp`
- **관리자:** `userList.jsp`, `category.jsp`, `category_action.jsp`
##### **정적 파일:**

- **CSS:** `style.css`
- **JavaScript:** `main.js` (선택사항)
- **이미지:** 업로드된 이미지 파일들
##### **설정 파일:**

- `build.gradle` 또는 `pom.xml`
- `web.xml`
##### **DB 스크립트:**

- 테이블 생성 SQL

---

## 11.25 [PJ]블로그 작성하기 미니프로젝트

#### 개요

이 문서는 게시판, 인증, 댓글, 카테고리, 관리자 기능을 한 번에 묶어 보는 미니프로젝트 초안입니다.

`JDBC + JSP -> 서블릿 MVC -> Spring`으로 단계적으로 확장하는 연습용 과제로 두고, 기능 요구사항을 정제하고 DB 모델링으로 연결하는 연습에 사용합니다.

##### 사용자 이용 시나리오

**신규 사용자 가입 및 이용**

**기존 사용자의 블로그 활동**

**프로필 관리**

##### 게시글 이용 시나리오

**글 작성과 수정**

**글 검색과 조회**

**카테고리별 탐색**

##### 관리자 시나리오

**사용자 관리**

**카테고리 관리**

**게시글 관리**

##### 댓글 이용 시나리오

**댓글 작성 및 소통**

**댓글 관리**



누가 무엇을 어떻게

사용자

게시글

관리자

댓글

#### 기능 명세서 (숙제)

1. 사용자 관리
1. 게시글 관리
1. 댓글 관리
1. 관리자 기능
#### DB 모델링





#### 객체 모델링





#### 주요 SQL 쿼리 (숙제)





#### 개발 단계

##### 1단계: JDBC + JSP 구현 (목록, 쓰기, 상세읽기, 수정하기, 삭제하기, 로그인)

- JDBC를 이용한 데이터베이스 연결 및 쿼리 실행
- JSP를 이용한 뷰 구현
- 각 기능별 JSP 페이지 구현
##### 2단계: MVC 패턴 + 서블릿 구현 (목록, 쓰기, 상세읽기, 수정하기, 삭제하기, 로그인)

- 1단계 코드를 MVC 패턴으로 리팩토링
- 모델(DAO, DTO), 뷰(JSP), 컨트롤러(서블릿) 분리
- Front Controller 패턴 적용
- 서비스 계층 추가
##### 3단계: Spring 프레임워크 적용

- 2단계 코드를 Spring 프레임워크로 리팩토링
- Spring IoC 컨테이너 활용
- Spring MVC 적용
- Spring JDBC 또는 JPA 적용—
- Spring Security 적용 (인증/인가)




#### 사용자 관련 요구사항

<!-- table -->
#### 게시글 관련 요구사항

<!-- table -->
#### 관리자 관련 요구사항

<!-- table -->
#### 댓글 관련 요구사항

<!-- table -->
#### 종합 분석

1. **누락된 요구사항**:
1. **불일치 요소**:
1. **추가 고려사항**:


### 기능 명세 비교 분석

#### 1. 사용자 관리 기능 비교

<!-- table -->
#### 2. 게시글 관리 기능 비교

<!-- table -->
#### 3. 댓글 관리 기능 비교

<!-- table -->
#### 4. 관리자 기능 비교

<!-- table -->
#### 종합 분석

1. **세부 사항의 차이점**:
1. **누락된 항목**:
1. **추가 고려사항**:
1. **통합 필요 사항**:

---

## 11.1 기초 리소스에 대한 이해

이 문서는 책 본문 밖에서 찾아보는 참고 리소스를 한곳에 묶어 둔 안내 페이지입니다. 막히는 지점이 생길 때만 필요한 문서를 골라 보는 방식으로 사용합니다.

포함 자료: 컴퓨팅 구조, 네트워크 구조, 개발자 기본 지식, 기술면접 예상질문, Java 면접 질문, Git 기초, 스레드와 동기화, 포트폴리오 예제, GitHub 작업 순서, JSP 기본 개념, DBMS 개요, 트랜잭션 개요 등.

---

## 11.2 컴퓨팅 구조

CPU, 메모리, 캐시, 저장장치, 운영체제의 기본 구조를 빠르게 다시 잡기 위한 참고 문서. JVM과 성능 문서를 읽다가 하드웨어 기초가 흔들릴 때 사용합니다.

---

## 11.3 네트워크 구조

네트워크 계층, TCP/UDP, HTTP, DNS, TLS 같은 핵심 개념을 빠르게 다시 잡기 위한 참고 문서. 서버, 인증, 통신 문서를 읽다가 네트워크 기초가 흔들릴 때 사용합니다.

---

## 11.4 개발자 기본 지식

운영체제, 네트워크, 데이터베이스, 자료구조처럼 개발자가 오래 가져가야 할 CS 주제를 한 번에 훑는 참고 가이드. 유지본 문서 지도를 통해 각 주제의 상세 문서로 연결됩니다.

---

## 11.9 오프라인 게임 파일 처리 시스템 과제

파일 처리 실습을 하나의 과제 흐름으로 묶어 둔 유지본. 파일 생성, 로그 기록, 백업, JSON 리소스 로딩을 게임 도메인으로 연습합니다. 핵심은 게임 로직보다 **파일 I/O 흐름을 끝까지 구현하는 것**입니다.

---

## 11.11 DBMS와 RDBMS 개요

DBMS, RDBMS, NoSQL 같은 용어가 헷갈릴 때 빠르게 다시 보기 위한 참고 문서. RDBMS는 테이블과 관계, SQL 중심의 DBMS이며, Java 서비스가 가장 자주 만나는 저장소입니다.

---

## 11.12 트랜잭션과 시스템 카탈로그 개요

트랜잭션, ACID, COMMIT, ROLLBACK, 시스템 카탈로그 같은 용어가 헷갈릴 때 다시 보는 참고 문서. 트랜잭션은 변경의 안전장치이고, 시스템 카탈로그는 데이터베이스 구조를 설명하는 내부 설명서입니다.

---

## 11.13 기술면접 예상질문

CS 전반을 면접형 질문과 짧은 답변으로 점검하는 참고 문서. 프로세스/스레드 차이, TCP/UDP, HTTP 스테이트리스, 인덱스, 정규화, 캐시, 교착 상태, 시스템 콜, 트랜잭션, 로드 밸런싱 등 10개 핵심 질문을 다룹니다.

---

