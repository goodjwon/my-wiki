# Spring Framework Testing Reference
원본: https://docs.spring.io/spring-framework/reference/testing.html
Spring Framework 7.0.7 공식 문서 중 Testing 핵심 내용.

---

## 핵심 테스트 어노테이션

### Context & Configuration

| 어노테이션 | 용도 |
|-----------|------|
| `@ContextConfiguration` | 테스트 애플리케이션 컨텍스트 설정 |
| `@WebAppConfiguration` | WebApplicationContext 로드 |
| `@ActiveProfiles` | 특정 프로파일 활성화 |
| `@TestPropertySource` | 테스트용 프로퍼티 제공 |
| `@DynamicPropertySource` | 런타임 동적 프로퍼티 (Testcontainers 등) |

### Bean & Mock

| 어노테이션 | 용도 |
|-----------|------|
| `@MockitoBean` | Mockito Mock 등록 |
| `@MockitoSpyBean` | Mockito Spy 등록 |
| `@TestBean` | 테스트용 Bean 등록 |

### Transaction

| 어노테이션 | 용도 |
|-----------|------|
| `@Commit` | 테스트 후 트랜잭션 커밋 |
| `@Rollback` | 테스트 후 트랜잭션 롤백 (기본값) |
| `@BeforeTransaction` | 트랜잭션 시작 전 실행 |
| `@AfterTransaction` | 트랜잭션 종료 후 실행 |
| `@Sql` | SQL 스크립트 실행 |

---

## 단위 테스트 지원

### Mock 객체

```java
// 서블릿 Mock
MockHttpServletRequest request = new MockHttpServletRequest("GET", "/users");
request.setParameter("id", "123");
MockHttpServletResponse response = new MockHttpServletResponse();

// 환경 Mock
MockEnvironment env = new MockEnvironment();
env.setProperty("app.name", "MyApp");
```

### ReflectionTestUtils

```java
// private 필드 설정
ReflectionTestUtils.setField(targetObject, "privateField", value);

// private 메서드 호출
ReflectionTestUtils.invokeMethod(targetObject, "privateMethod", args);
```

### 주요 용도
- ORM private 필드 테스트 (JPA, Hibernate)
- `@Autowired` 주입 없이 필드 설정
- `@PostConstruct` 라이프사이클 콜백 테스트

---

## MockMvc 테스트

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void getUser() throws Exception {
        given(userService.findById(1L)).willReturn(new User("Kim"));

        mockMvc.perform(get("/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Kim"));
    }

    @Test
    void createUser() throws Exception {
        mockMvc.perform(post("/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{"name": "Lee"}"))
            .andExpect(status().isCreated());
    }
}
```

---

## 테스트 계층 가이드

| 테스트 유형 | 도구 | 범위 | 속도 |
|-----------|------|------|------|
| 단위 테스트 | JUnit + Mockito | 클래스 단위 | 가장 빠름 |
| 슬라이스 테스트 | `@WebMvcTest`, `@DataJpaTest` | 레이어 단위 | 빠름 |
| 통합 테스트 | `@SpringBootTest` | 전체 컨텍스트 | 느림 |
| E2E 테스트 | `WebTestClient`, `TestRestTemplate` | API 전체 | 가장 느림 |

### 권장 전략
- **테스트 피라미드**: 단위 > 슬라이스 > 통합 > E2E
- 모든 테스트를 `@SpringBootTest`로 하지 말 것
- 도메인 로직은 단위테스트, 웹 계층은 `@WebMvcTest`, DB는 `@DataJpaTest`

---
