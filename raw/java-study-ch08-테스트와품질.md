# 8. 테스트와품질
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 8.1 Spring Boot 테스트 전략

#### 개요

이 문서는 Spring Boot 프로젝트에서 테스트를 어떤 레벨로 나누고, 어떤 도구를 선택해야 하는지 정리한 가이드입니다. 핵심은 테스트를 많이 쓰는 것이 아니라, **가장 적절한 범위로 검증하는 것**입니다.

#### 왜 중요한가

Spring Boot는 웹, 데이터, 보안, 설정이 함께 묶인 프레임워크라서 테스트도 한 가지 방식으로 해결되지 않습니다. 모든 테스트를 무겁게 만들면 느리고, 모든 테스트를 가볍게 만들면 실제 동작을 놓치게 됩니다.

#### 1. 기본 출발점

Spring Boot는 `spring-boot-starter-test`를 통해 테스트에 필요한 기본 구성을 제공합니다. 초중급 단계에서는 먼저 이 스타터가 어떤 테스트 도구를 묶어 주는지 이해하는 것이 좋습니다.

#### 2. 테스트를 나누는 기본 기준

##### 단위 테스트

Spring 컨테이너 없이, 클래스 하나나 협력 객체 몇 개만 검증합니다. 가장 빠르고, 실패 원인을 좁히기 쉽습니다.

##### 슬라이스 테스트

웹 계층이나 JPA 계층처럼 특정 레이어만 잘라서 검증합니다. 단위 테스트보다 실제 프레임워크와 더 가깝고, 전체 통합 테스트보다 가볍습니다.

##### 통합 테스트

여러 레이어를 함께 붙여 실제 동작을 확인합니다. 설정, 트랜잭션, 직렬화, 보안 필터 같은 경계 지점을 검증할 때 필요합니다.

#### 3. Spring Boot에서 자주 쓰는 테스트 애노테이션

##### `@WebMvcTest`

컨트롤러, JSON 직렬화, 요청/응답 매핑 같은 웹 계층 검증에 적합합니다. 서비스와 리포지토리까지 전부 띄우는 대신, 웹 레이어에 집중합니다.

##### `@DataJpaTest`

리포지토리와 JPA 매핑, 쿼리 동작을 검증할 때 적합합니다. 영속성 계층만 빠르게 확인하고 싶을 때 유용합니다.

##### `@SpringBootTest`

애플리케이션 전체를 실제와 가깝게 띄웁니다. 가장 강력하지만 가장 무겁기 때문에, 꼭 필요한 경계 검증에 집중해서 써야 합니다.

#### 4. 실무에서 추천하는 기본 조합

- 도메인 로직과 서비스 규칙: 단위 테스트
- 컨트롤러 요청/응답 검증: `@WebMvcTest`
- JPA 매핑과 조회 검증: `@DataJpaTest`
- 설정, 보안, 전체 흐름 검증: `@SpringBootTest`
이 조합이 중요한 이유는, 테스트 실패 원인을 빨리 좁히면서도 실제 동작 검증을 놓치지 않기 때문입니다.

#### 현재 저장소에서 실제로 쓰는 조합

현재 `day_by_spring` 저장소는 추상적인 권장 조합이 아니라 아래 패턴을 실제로 사용합니다.

- 서비스 단위 테스트: `@ExtendWith(MockitoExtension.class)` + 목 객체 (`AuthServiceImplTest`, `LoanServiceImplTest`)
- 컨트롤러 슬라이스 테스트: `@WebMvcTest` + `@MockitoBean` + `MockMvc` (`LoanControllerTest`, `BookControllerTest`)
- JPA 슬라이스 테스트: `@DataJpaTest` + `TestEntityManager` (`LoanRepositoryTest`, `BookRepositoryTest`)
- 통합 테스트: `@SpringBootTest` (`OrderServiceIntegrationTest`, `AopLoggingIntegrationTest`)
```java
@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {
    @Mock private AuthenticationManager authenticationManager;
    @Mock private JwtTokenProvider jwtTokenProvider;
    @InjectMocks private AuthServiceImpl authService;
}
```

```java
@WebMvcTest(LoanController.class)
@AutoConfigureMockMvc(addFilters = false)
class LoanControllerTest {
    @MockitoBean private LoanService loanService;
    @Autowired private MockMvc mockMvc;
}
```

```java
@DataJpaTest
class LoanRepositoryTest {
    @Autowired private TestEntityManager entityManager;
    @Autowired private LoanRepository loanRepository;
}
```

```plain text
예상 결과
서비스 테스트는 빠르게 유스케이스 오케스트레이션을 검증한다.
컨트롤러 테스트는 보안 필터를 끈 상태에서 HTTP 계약을 검증한다.
리포지토리 테스트는 실제 JPA 매핑과 쿼리 동작을 확인한다.
```

#### 5. 수동 검증은 왜 여전히 필요한가

자동화 테스트가 있더라도 `curl`, Swagger, Postman 같은 수동 검증은 여전히 의미가 있습니다. 특히 인증 헤더, 실제 JSON 바디, 운영과 유사한 요청 흐름은 수동 점검이 빠를 때가 많습니다. 다만 수동 검증은 회귀 방지를 대신하지 못하므로, 자동화 테스트와 역할을 분리해야 합니다.

#### 6. 자주 하는 실수

- 모든 테스트를 `@SpringBootTest`로만 작성하는 것
- 컨트롤러 테스트에서 서비스 내부 로직까지 다 검증하려는 것
- 테스트 데이터 준비가 너무 복잡해져 본론이 흐려지는 것
- 성공 케이스만 작성하고 실패 케이스를 빼는 것
#### 공식 문서 참고

- [Spring Boot Testing Reference](https://docs.spring.io/spring-boot/reference/testing/index.html)
- [Spring Framework Testing](https://docs.spring.io/spring-framework/reference/testing.html)
- [Spring Boot Test Auto-configuration Annotations](https://docs.spring.io/spring-boot/reference/test-auto-configuration/index.html)
#### 정리

테스트 전략은 기술 선택 문제가 아니라 경계 설정 문제입니다. 무엇을 어디까지 검증할지 먼저 정하면, 애노테이션과 도구 선택은 그 다음에 자연스럽게 따라옵니다.

#### 한 줄 정리

Spring Boot 테스트의 핵심은 **가장 작은 비용으로 가장 큰 회귀 위험을 줄이는 검증 레벨을 고르는 것**입니다.


---

## 8.3 API 수동 검증: curl 활용

### 개요

이 문서는 `curl`을 사용해 HTTP API를 직접 검증하는 방법을 정리한 가이드입니다. 자동화 테스트가 있어도, 실제 요청과 응답을 눈으로 확인해야 하는 순간은 계속 존재합니다. 핵심은 수동 검증을 많이 하는 것이 아니라, **어떤 문제를 ****`curl`****로 빨리 확인하고 어떤 문제를 자동화 테스트로 남길지 구분하는 것**입니다.

#### 왜 중요한가

테스트 코드는 회귀 방지에 강하지만, 실제 HTTP 요청을 한 번에 점검하는 데는 `curl`이 더 빠를 때가 많습니다. 특히 아래 상황에서는 수동 검증이 유용합니다.

- 인증 헤더를 포함한 실제 요청을 바로 보내 보고 싶을 때
- JSON 바디와 상태 코드를 빠르게 확인하고 싶을 때
- 로컬 프로파일, 포트, 프록시, CORS 이전 단계 문제를 확인할 때
- Swagger UI 없이도 재현 가능한 요청 스크립트를 남기고 싶을 때
#### 이 문서의 역할

이 문서는 자동화 테스트를 대체하지 않습니다. 책 기준에서 `curl`은 아래 역할에 가깝습니다.

- API 설계가 실제 요청/응답으로 어떻게 보이는지 확인한다.
- 인증, 직렬화, 상태 코드 같은 경계 지점을 빠르게 점검한다.
- 버그 재현 절차를 텍스트로 남긴다.
반대로 아래는 자동화 테스트가 더 적합합니다.

- 반복 실행이 필요한 회귀 검증
- 비즈니스 규칙 검증
- 레이어별 실패 원인 추적
#### 1. 수동 검증 전에 먼저 확인할 것

좋은 `curl` 테스트는 명령보다 **사전 조건**이 먼저 분명해야 합니다.

- 애플리케이션이 어떤 프로파일로 실행 중인가
- 서버 주소와 포트는 무엇인가
- 필요한 인증 토큰이 준비되었는가
- 테스트용 데이터가 이미 있는가, 아니면 먼저 만들어야 하는가
- 성공 기준이 응답 바디인지, 상태 코드인지, 둘 다인지
이 기준이 없으면 `curl` 명령이 많아져도 문서 품질은 올라가지 않습니다.

#### 2. 가장 먼저 보는 것은 상태 코드입니다

초중급 단계에서 가장 흔한 실수는 JSON 바디만 보고 성공 여부를 판단하는 것입니다. 하지만 API 검증의 첫 줄은 상태 코드입니다.

- `200 OK`: 조회나 수정이 정상 처리되었는가
- `201 Created`: 생성 요청이 새 리소스를 만들었는가
- `400 Bad Request`: 잘못된 요청 형식을 제대로 거부하는가
- `401 Unauthorized`: 인증 없는 요청을 막는가
- `403 Forbidden`: 권한 없는 사용자를 막는가
- `404 Not Found`: 없는 리소스 접근을 적절히 처리하는가
#### 3. 기본 `curl` 패턴

##### GET 요청

```bash
curl -i http://localhost:8080/api/books/1
```

##### JSON 바디를 포함한 POST 요청

```bash
curl -i -X POST http://localhost:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Effective Java",
    "author": "Joshua Bloch"
  }'
```

##### 인증 헤더 포함 요청

```bash
curl -i http://localhost:8080/api/client/loans \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

```plain text
예상 결과
유효한 사용자 또는 관리자 토큰이면 현재 로그인 사용자의 대출 목록이 반환된다.
이 프로젝트에서는 `@AuthenticationPrincipal CustomUserDetails`를 통해 토큰에서 복원된 `memberId`를 사용한다.
```

##### PATCH 요청

```bash
curl -i -X PATCH http://localhost:8080/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Effective Java 3rd"
  }'
```

##### DELETE 요청

```bash
curl -i -X DELETE http://localhost:8080/api/books/1
```

여기서 중요한 것은 명령어 자체보다, **각 요청이 어떤 HTTP 의미를 가지는지 알고 보내는 것**입니다.

#### 4. 추천 검증 순서

책 기준에서 가장 실수 적은 순서는 아래와 같습니다.

1. 서버 기동과 포트 확인
1. 공개 조회 API로 기본 연결 확인
1. `/api/auth/login`으로 토큰 발급 확인
1. 보호된 사용자 API 검증
1. 보호된 관리자 API 검증
1. 잘못된 입력으로 `400` 확인
1. 인증 실패와 권한 부족 흐름 확인
1. 없는 ID로 요청해서 `404` 확인
이 순서가 좋은 이유는, 환경 문제와 도메인 문제를 섞지 않게 해 주기 때문입니다.

현재 저장소 기준으로는 아래 순서가 특히 자연스럽습니다.

```plain text
GET /api/books/{id}
  → POST /api/auth/login
  → GET /api/client/loans
  → PUT /api/admin/members/{id}/promote
```

관리자 토큰과 일반 사용자 토큰을 나눠 보면 `hasRole("ADMIN")` 규칙 검증까지 한 번에 이어집니다.

#### 5. 인증 API는 헤더와 실패 케이스를 같이 봅니다

인증이 들어가는 API는 성공 요청만 보면 부족합니다. 최소한 아래 세 가지는 같이 확인하는 편이 좋습니다.

- 토큰이 있을 때 정상 동작하는가
- 토큰이 없을 때 요청이 차단되는가
- 권한이 부족할 때 `403 Forbidden`이 나는가
즉, 인증 API 검증은 “요청이 된다”가 아니라 **경계가 올바르게 막히는지**까지 포함해야 합니다.

현재 저장소는 `AuthenticationEntryPoint`와 `AccessDeniedHandler`를 별도로 커스터마이징하지 않았습니다. 따라서 보호된 API에서 토큰이 없을 때의 정확한 실패 응답은 실제 실행 환경에서 확인하는 편이 안전합니다. 반면 **인증된 USER 토큰으로 `/api/admin/**`를 호출했을 때 권한 부족으로 차단되는 흐름은 반드시 확인해야 합니다.

```bash
curl -i -X PUT "http://localhost:8080/api/admin/members/1/promote" \
  -H "Authorization: Bearer USER_ACCESS_TOKEN"
```

```plain text
예상 결과
관리자 권한이 없는 사용자 토큰이면 `403 Forbidden`으로 차단된다.
현재 보안 설정의 `requestMatchers("/api/admin/**").hasRole("ADMIN")` 규칙이 실제로 동작하는지 확인하는 가장 짧은 검증이다.
```

#### 6. 예제 프로젝트에 적용하는 방법

도서 대여 같은 예제 프로젝트에서는 아래 흐름으로 검증 문서를 만들면 좋습니다.

- 회원가입 또는 기존 테스트 계정 확인
- 로그인 후 JWT 토큰 발급
- 공개 API와 보호된 API를 구분해 호출
- 대출 생성
- 내 대출 조회
- 반납 또는 상태 변경
- 권한 부족 요청으로 `403` 확인
- 삭제 후 `404` 확인
핵심은 특정 도메인이 아니라, **사전 데이터 생성 → 정상 흐름 → 오류 흐름** 순서가 보이는 것입니다.

로그인 실패도 별도 검증 가치가 있습니다.

```bash
curl -i -X POST "http://localhost:8080/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "hong@test.com",
    "password": "wrong-password"
  }'
```

```plain text
예상 결과
인증 실패 시 토큰은 발급되지 않는다.
현재 저장소는 `GlobalExceptionHandler`에서 `AuthenticationException`을 받아 `401 Unauthorized`와 `AUTHENTICATION_FAILED` 형태의 응답으로 정리한다.
```

#### 7. `curl` 문서를 남길 때 좋은 형식

좋은 수동 검증 문서는 아래 네 가지를 함께 남깁니다.

- 사전 조건
- 요청 명령
- 기대 상태 코드
- 기대 결과 요약
예를 들면 아래처럼 적는 편이 좋습니다.

```plain text
목적: 없는 리소스 조회 시 404 확인
사전 조건: ID 9999는 존재하지 않음
요청: GET /api/books/9999
기대 결과: 404 Not Found
```

이 정도만 있어도 나중에 버그 재현 문서로 바로 재사용할 수 있습니다.

#### 자주 하는 실수

- 서버를 띄우지 않고 요청부터 보내는 것
- 인증 API인데 토큰 없이 성공만 기대하는 것
- 사전 데이터 생성 없이 수정/삭제부터 시도하는 것
- 상태 코드를 보지 않고 응답 바디만 확인하는 것
- 수동 검증 절차를 남기지 않아 같은 버그를 다시 재현하지 못하는 것
#### 공식 문서

- [everything curl](https://everything.curl.dev/)

---

## 8.0 테스트와 품질

#### 개요

이 문서는 책의 `테스트와 품질` 챕터를 안내하는 문서입니다. 테스트는 기능이 다 만들어진 뒤 붙이는 보너스 작업이 아니라, **변경을 두려워하지 않게 만드는 구조적 장치**입니다.

#### 왜 중요한가

Java와 Spring 실무에서는 기능 구현보다 유지보수가 더 오래 지속됩니다. 이때 테스트가 없으면 리팩터링, 버그 수정, 의존성 교체가 모두 위험한 작업이 됩니다.

#### 이 챕터에서 다루는 범위

- Spring Boot 테스트 도구 구성
- 테스트 피라미드와 레이어별 테스트 선택
- 단위 테스트와 슬라이스 테스트의 역할
- 작은 예제를 통해 보는 테스트 가능한 구조
- `curl`을 활용한 API 수동 검증과 자동화 테스트의 경계

#### 한 줄 정리

`테스트와 품질` 챕터의 핵심은 **변경 비용을 줄이는 검증 구조를 만드는 것**입니다.

---

## 8.2 계산기 테스트 기초

#### 개요

이 문서는 작은 계산기 예제를 통해 **테스트 가능한 코드가 어떤 구조를 요구하는지** 설명하는 실습 문서입니다. 핵심은 계산기를 만드는 것이 아니라, 테스트가 가능하도록 책임을 분리하는 과정을 이해하는 데 있습니다.

#### 왜 중요한가

테스트는 완성된 코드에 붙이는 마지막 장식이 아닙니다. 테스트를 쓰려는 순간, 입력 파싱과 계산 규칙, 예외 처리, 출력 책임을 분리해야 한다는 사실이 드러납니다.

#### 2. 첫 단계는 계산 규칙을 메서드로 분리하는 것이다

```java
public class Calculator {
    public int calculate(int left, String operator, int right) {
        return switch (operator) {
            case "+" -> left + right;
            case "-" -> left - right;
            case "*" -> left * right;
            case "/" -> {
                if (right == 0) {
                    throw new IllegalArgumentException("0으로 나눌 수 없습니다.");
                }
                yield left / right;
            }
            default -> throw new IllegalArgumentException("지원하지 않는 연산자입니다.");
        };
    }
}
```

#### 4. JUnit 5 테스트 예제

```java
class CalculatorTest {
    private final Calculator calculator = new Calculator();

    @Test
    @DisplayName("덧셈을 계산한다")
    void addsNumbers() {
        assertEquals(8, calculator.calculate(5, "+", 3));
    }

    @Test
    @DisplayName("0으로 나누면 예외가 발생한다")
    void rejectsDivisionByZero() {
        assertThrows(IllegalArgumentException.class,
            () -> calculator.calculate(5, "/", 0));
    }
}
```

#### 한 줄 정리

테스트 가능한 코드의 핵심은 **테스트 기술보다 먼저, 책임이 나뉜 구조를 만드는 것**입니다.

---

