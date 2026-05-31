# Spring Framework Web MVC Reference
원본: https://docs.spring.io/spring-framework/reference/web.html
Spring Framework 7.0.7 공식 문서 중 Web MVC 핵심 내용.

---

## Annotated Controllers 기본

```java
@Controller
public class HelloController {
    @GetMapping("/hello")
    public String handle(Model model) {
        model.addAttribute("message", "Hello World!");
        return "index";
    }
}
```

### 핵심 어노테이션

| 어노테이션 | 용도 |
|-----------|------|
| `@Controller` | 뷰 반환 컨트롤러 |
| `@RestController` | `@Controller` + `@ResponseBody` |
| `@RequestMapping` | URL 매핑 (메서드/클래스) |
| `@GetMapping` / `@PostMapping` | HTTP 메서드별 축약 |
| `@PathVariable` | URL 경로 변수 |
| `@RequestParam` | 쿼리 파라미터 |
| `@RequestBody` | HTTP 바디 → 객체 변환 |
| `@ResponseBody` | 객체 → HTTP 바디 |
| `@Valid` | Bean Validation 적용 |

---

## @RequestBody + Validation

```java
@PostMapping("/accounts")
public void handle(@Valid @RequestBody Account account, Errors errors) {
    // validation 실패 시 errors에 바인딩
    // Errors 파라미터 없으면 MethodArgumentNotValidException → 400
}
```

- `@RequestBody`는 `HttpMessageConverter`로 역직렬화
- 폼 데이터는 `@RequestParam` 사용 (RequestBody 아님)

---

## ResponseEntity

```java
@GetMapping("/something")
public ResponseEntity<String> handle() {
    String body = "...";
    return ResponseEntity.ok()
        .eTag(etag)
        .body(body);
}

// 상태 코드 + 헤더 + 바디 커스터마이징
return ResponseEntity.status(HttpStatus.CREATED)
    .header("X-Custom", "value")
    .body(resource);

// 404
return ResponseEntity.notFound().build();
```

- `@ResponseBody`와 달리 상태코드/헤더 제어 가능
- `ResponseEntity<Resource>`로 파일 다운로드 구현

---

## @ExceptionHandler + @ControllerAdvice

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusiness(BusinessException ex) {
        return ResponseEntity.badRequest()
            .body(new ErrorResponse(ex.getErrorCode(), ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDATION_ERROR", ex.getMessage()));
    }
}
```

- `@ControllerAdvice`: 전역 예외 처리
- `@RestControllerAdvice`: `@ControllerAdvice` + `@ResponseBody`

---

## @RequestMapping 상세

### HTTP Method 축약 어노테이션
- `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping`

### URI 패턴

| 패턴 | 설명 | 예시 |
|------|------|------|
| `/users/{id}` | 경로 변수 | `@PathVariable Long id` |
| `/files/{*path}` | catch-all 변수 | 하위 경로 전체 캡처 |
| `{name:[a-z]+}` | 정규식 변수 | 영문 소문자만 |
| `?` | 단일 문자 | `/t?st` → `/test` |
| `*` | 세그먼트 내 0+ 문자 | `/resources/*.png` |
| `**` | 0+ 경로 세그먼트 | `/resources/**` |

### 기본 예제

```java
@RestController
@RequestMapping("/persons")
class PersonController {

    @GetMapping("/{id}")
    public Person getPerson(@PathVariable Long id) { ... }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void add(@RequestBody Person person) { ... }
}
```

### Content-Type 제한

```java
@PostMapping(path = "/pets", consumes = "application/json")
public void addPet(@RequestBody Pet pet) { ... }

@GetMapping(path = "/pets/{petId}", produces = "application/json")
public Pet getPet(@PathVariable String petId) { ... }
```

### 파라미터/헤더 조건

```java
@GetMapping(path = "/pets", params = "type=dog")
public List<Pet> findDogs() { ... }

@GetMapping(path = "/pets", headers = "X-API-Version=2")
public List<Pet> findPetsV2() { ... }
```

### API 버전 관리 (Spring 7)

```java
@GetMapping(version = "1.1")
public Account getAccountV1_1() { }

@GetMapping(version = "1.2+")  // 1.2 이상
public Account getAccountV1_2Plus() { }
```

---

## Jackson JSON 처리

### @JsonView — 필드 선택적 직렬화

```java
public class User {
    public interface Summary {};
    public interface Detail extends Summary {};

    @JsonView(Summary.class)
    private String username;

    @JsonView(Detail.class)
    private String password;
}

@GetMapping("/user")
@JsonView(User.Summary.class)
public User getUser() { return new User("eric", "secret"); }
// 결과: {"username": "eric"} (password 제외)
```

### MappingJacksonValue — 프로그래밍 방식

```java
@GetMapping("/user")
public MappingJacksonValue getUser() {
    MappingJacksonValue value = new MappingJacksonValue(user);
    value.setSerializationView(User.Summary.class);
    return value;
}
```

---
