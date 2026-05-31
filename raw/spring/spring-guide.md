# Spring Guide (cheese10yun)
원본: https://github.com/cheese10yun/spring-guide

Spring Boot 기반의 실무 가이드 모음. 디렉터리 구조, 도메인 설계, 예외 처리, 서비스 레이어, API 호출, 테스트 전략을 다룬다.

---

## README

[![CircleCI](https://circleci.com/gh/cheese10yun/spring-guide.svg?style=svg)](https://circleci.com/gh/cheese10yun/spring-guide)
[![Coverage Status](https://coveralls.io/repos/github/cheese10yun/spring-guide/badge.svg?branch=master)](https://coveralls.io/github/cheese10yun/spring-guide?branch=master)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fcheese10yun%2Fspring-guide&count_bg=%2379C83D&title_bg=%23555555&icon=github.svg&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

# Spring Guide

# 소개
Spring Boot 기반 Rest API를 개발할 때 유지 보수하기 좋은 코드를 만들기 위해서 평소 생각했던 가이드를 연하고 있습니다. 테스트 코드, 예외처리, 올바른 서비스의 크기, 프로젝트 구조 등에 대해서 주로 다룰 예정입니다. Start, Watching 버튼을 누르시면 구독 신청받으실 수 있습니다. 저의 경험이 여러분에게 조금이라도 도움이 되기를 기원합니다.


# 프로젝트 실행 방법
```bash
$ git clone git@github.com:cheese10yun/spring-guide.git
$ cd spring-guide
$ docker-compose up -d
$ ./mvnw clean package
$ java -jar -Dspring.profiles.active=local api-service/target/api-service-0.0.1-SNAPSHOT.jar
```

# 목차
1. [Test 전략 가이드](https://github.com/cheese10yun/spring-guide/blob/master/docs/test-guide.md)
2. [Exception 전략 가이드](https://github.com/cheese10yun/spring-guide/blob/master/docs/exception-guide.md)
3. [Domain 객체 가이드](https://github.com/cheese10yun/spring-guide/blob/master/docs/domain-guide.md)
4. [외부 API 가이드](https://github.com/cheese10yun/spring-guide/blob/master/docs/api-call-guide.md)
5. [Service 적절한 크기 가이드](https://github.com/cheese10yun/spring-guide/blob/master/docs/service-guide.md)
6. [Directory 가이드](https://github.com/cheese10yun/spring-guide/blob/master/docs/directory-guide.md)








---

## directory-guide

# Directory Guide 

패키지 구성은 크게 레이어 계층형, 도메인형 이렇게 2 가지 유형이 있다고 생각합니다. 각 유형별로 간단하게 설명하고 제 개인적인 Best Practices를 설명하겠습니다.

## 계층형 
```
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── example
    │   │           └── demo
    │   │               ├── DemoApplication.java
    │   │               ├── config
    │   │               ├── controller
    │   │               ├── dao
    │   │               ├── domain
    │   │               ├── exception
    │   │               └── service
    │   └── resources
    │       └── application.properties
```

계층형 구조는 각 계층을 대표하는 디렉터리를 기준으로 코드들이 구성됩니다. 계층형 구조의 장점은 해당 프로젝트에 이해가 상대적으로 낮아도 전체적인 구조를 빠르게 파악할 수 있는 장점이 있습니다. 단점으로는 디렉터리에 클래스들이 너무 많이 모이게 되는 점입니다.

## 도메인형
```
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── example
    │   │           └── demo
    │   │               ├── DemoApplication.java
    │   │               ├── coupon
    │   │               │   ├── controller
    │   │               │   ├── domain
    │   │               │   ├── exception
    │   │               │   ├── repository
    │   │               │   └── service
    │   │               ├── member
    │   │               │   ├── controller
    │   │               │   ├── domain
    │   │               │   ├── exception
    │   │               │   ├── repository
    │   │               │   └── service
    │   │               └── order
    │   │                   ├── controller
    │   │                   ├── domain
    │   │                   ├── exception
    │   │                   ├── repository
    │   │                   └── service
    │   └── resources
    │       └── application.properties

```
도메인 디렉터리 기준으로 코드를 구성합니다. 도메인형의 장점은 관련된 코드들이 응집해 있는 장점이 있습니다. 단점으로는 프로젝트에 대한 이해도가 낮을 경우 전체적인 구조를 파악하기 어려운 점이 있습니다.


## 개인적인 Best Practices
**저는 도메인형이 더 좋은 구조라고 생각합니다.** 이전부터 도메인형을 선호했었지만 이러한 디렉터리 구조는 어느 정도 취향 차이라고 생각해 왔었습니다. **하지만 최근 들어 취향 차이를 넘어 도메인형 디렉터리 구조가 더 효과적**이라고 확신이 들어 이 주제로 포스팅을 해야겠다는 생각을 했습니다.

### 너무 많은 클래스
계층형 같은 경우 Controller, Service 등에 너무 많은 클래스들이 밀집하게 됩니다. 많게는 30 ~ 40의 클래스들이 xxxxController, xxxxService 같은 패턴으로 길게 나열되어 프로젝트 전체적인 구조는 상단 디렉터리 몇 개로 빠르게 파악할 수 있지만 그 이후로는 파악하기가 더 힘들어지게 됩니다.

### 관련 코드의 응집
관련된 코드들이 응집해 있으면 자연스럽게 연관돼 있는 자연스럽게 코드 스타일, 변수, 클래스 이름 등을 참고하게 되고 비슷한 코드 스타일과 패턴으로 개발할 수 있게 될 환경이 자연스럽게 마련된다고 생각합니다.

계층형 구조일 경우 수신자에 대한 클래스명을 Receiver로 지정했다면, 너무 많은 클래스들로 Receiver에 대한 클래스가 자연스럽게 인식하지 않게 되고 Recipient 같은 클래스 명이나 네이밍을 사용하게 됩니다. 반변 도메인형은 관련된 코드들이 응집해있기 때문에 자연스럽게 기존 코드를 닮아갈 수 있다고 생각합니다. 

또 해당 디렉터리가 컨텍스트를 제공해줍니다. order라는 디렉터리에 Receiver 클래스가 있는 경우 주문을 배송받는 수취인이라는 컨텍스트를 제공해줄 수 있습니다. (물론 OrderReceiver라고 더 구체적으로 명명하는 게 더 좋은 네이밍이라고 생각합니다.)


### 최근 기술 동향
도메인 주도 개발, ORM, 객체지향 프로그래밍 등에서 도메인형 구조가 더 적합하다고 생각합니다. 도메인 주도 개발에서 Root Aggregate 같은 표현은 계층형보다 도메인형으로 표현했을 경우 훨씬 더 직관적이며 해당 도메인을 이해하는 것에도 효율적입니다.


## 도메인형 디렉토리 구조
도메인 계층으로 디렉터리 구조를 몇몇 프로젝트에서 진행해 보았지만 그때마다 더 좋은 구조를 찾게 되기 조금 더 발전시키는 가정이다 보니 아직은 아주 명확한 근거를 기반으로 하지는 못하고 있습니다. 약간 코에 걸면 코걸이 느낌이 있습니다.

### 전체적인 구조

```
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── spring
    │   │           └── guide
    │   │               ├── ApiApp.java
    │   │               ├── SampleApi.java
    │   │               ├── domain
    │   │               │   ├── coupon
    │   │               │   │   ├── api
    │   │               │   │   ├── application
    │   │               │   │   ├── dao
    │   │               │   │   ├── domain
    │   │               │   │   ├── dto
    │   │               │   │   └── exception
    │   │               │   ├── member
    │   │               │   │   ├── api
    │   │               │   │   ├── application
    │   │               │   │   ├── dao
    │   │               │   │   ├── domain
    │   │               │   │   ├── dto
    │   │               │   │   └── exception
    │   │               │   └── model
    │   │               │       ├── Address.java
    │   │               │       ├── Email.java
    │   │               │       └── Name.java
    │   │               ├── global
    │   │               │   ├── common
    │   │               │   │   ├── request
    │   │               │   │   └── response
    │   │               │   ├── config
    │   │               │   │   ├── SwaggerConfig.java
    │   │               │   │   ├── properties
    │   │               │   │   ├── resttemplate
    │   │               │   │   └── security
    │   │               │   ├── error
    │   │               │   │   ├── ErrorResponse.java
    │   │               │   │   ├── GlobalExceptionHandler.java
    │   │               │   │   └── exception
    │   │               │   └── util
    │   │               └── infra
    │   │                   ├── email
    │   │                   └── sms
    │   │                       ├── AmazonSmsClient.java
    │   │                       ├── SmsClient.java
    │   │                       └── dto
    │   └── resources
    │       ├── application-dev.yml
    │       ├── application-local.yml
    │       ├── application-prod.yml
    │       └── application.yml

```

전체적인 구조는 도메인을 담당하는 디렉터리 domain, 전체적인 설정을 관리하는 global, 외부 인프라스트럭처를 관리하는 infra를 기준으로 설명을 드리겠습니다.

### Domain

```
├── domain
│   ├── member
│   │   ├── api
│   │   │   └── MemberApi.java
│   │   ├── application
│   │   │   ├── MemberProfileService.java
│   │   │   ├── MemberSearchService.java
│   │   │   ├── MemberSignUpRestService.java
│   │   │   └── MemberSignUpService.java
│   │   ├── dao
│   │   │   ├── MemberFindDao.java
│   │   │   ├── MemberPredicateExecutor.java
│   │   │   ├── MemberRepository.java
│   │   │   ├── MemberSupportRepository.java
│   │   │   └── MemberSupportRepositoryImpl.java
│   │   ├── domain
│   │   │   ├── Member.java
│   │   │   └── ReferralCode.java
│   │   ├── dto
│   │   │   ├── MemberExistenceType.java
│   │   │   ├── MemberProfileUpdate.java
│   │   │   ├── MemberResponse.java
│   │   │   └── SignUpRequest.java
│   │   └── exception
│   │       ├── EmailDuplicateException.java
│   │       ├── EmailNotFoundException.java
│   │       └── MemberNotFoundException.java
│   └── model
│       ├── Address.java
│       ├── Email.java
│       └── Name.java

```
`model` 디렉터리는 Domain Entity 객체들이 공통적으로 사용할 객체들로 구성됩니다. 대표적으로 `Embeddable` 객체, `Enum` 객체 등이 있습니다.

`member` 디렉터리는 간단한 것들부터 설명하겠습니다.

* api : 컨트롤러 클래스들이 존재합니다. 외부 rest api로 프로젝트를 구성하는 경우가 많으니 api라고 지칭했습니다. Controller 같은 경우에는 ModelAndView를 리턴하는 느낌이 있어서 명시적으로 api라고 하는 게 더 직관적인 거 같습니다.
* domain : 도메인 엔티티에 대한 클래스로 구성됩니다. 특정 도메인에만 속하는 `Embeddable`, `Enum` 같은 클래스도 구성됩니다.
* dto : 주로 Request, Response 객체들로 구성됩니다.
* exception : 해당 도메인이 발생시키는 Exception으로 구성됩니다.


#### application
application 디렉터리는 도메인 객체와 외부 영역을 연결해주는 파사드와 같은 역할을 주로 담당하는 클래스로 구성됩니다. 대표적으로 데이터베이스 트랜잭션을 처리를 진행합니다. service 계층과 유사합니다. 디렉터리 이름을 service로 하지 않은 이유는 service로 했을 경우 xxxxService로 클래스 네임을 해야 한다는 강박관념이 생기기 때문에 application이라고 명명했습니다.


#### dao
repository 와 비슷합니다. repository로 하지 않은 이유는 조회 전용 구현체들이 작성 많이 작성되는데 이러한 객체들은 DAO라는 표현이 더 직관적이라고 판단했습니다. [Querydsl를 이용해서 Repository 확장하기(1), (2)](https://github.com/cheese10yun/spring-jpa-best-practices)처럼 Reopsitory를 DAO처럼 확장하기 때문에 dao 디렉터리 명이 더 직관적이라고 생각합니다.

### global

```
├── global
│   ├── common
│   │   ├── request
│   │   └── response
│   │       └── Existence.java
│   ├── config
│   │   ├── SwaggerConfig.java
│   │   ├── properties
│   │   ├── resttemplate
│   │   │   ├── RestTemplateClientHttpRequestInterceptor.java
│   │   │   ├── RestTemplateConfig.java
│   │   │   └── RestTemplateErrorHandler.java
│   │   └── security
│   ├── error
│   │   ├── ErrorResponse.java
│   │   ├── GlobalExceptionHandler.java
│   │   └── exception
│   │       ├── BusinessException.java
│   │       ├── EntityNotFoundException.java
│   │       ├── ErrorCode.java
│   │       └── InvalidValueException.java
│   └── util
```

global은 프로젝트 전방위적으로 사용되는 객체들로 구성됩니다. global로 지정한 이유는 common, util, config 등 프로젝트 전체에서 사용되는 클래스들이 global이라는 디렉터리에 모여 있는 것이 좋다고 생각했습니다.

* common : 공통으로 사용되는 Value 객체들로 구성됩니다. 페이징 처리를 위한 Request, 공통된 응답을 주는 Response 객체들이 있습니다. 
* config : 스프링 각종 설정들로 구성됩니다. 
* error : 예외 핸들링을 담당하는 클래스로 구성됩니다. [Exception Guide](https://github.com/cheese10yun/spring-guide/blob/master/docs/exception-guide.md)에서 설명했던 코드들이 있습니다.
* util : 유틸성 클래스들이 위치합니다.

그 밖에도 global 하게 설정하는 것들을 global 디렉터리에 위치 시키면 될 거 같습니다.

### infra

```
└── infra
    ├── email
    └── sms
        ├── AmazonSmsClient.java
        ├── KtSmsClient.java
        ├── SmsClient.java
        └── dto
            └── SmsRequest.java
```
infra 디렉터리는 인프라스트럭처 관련된 코드들로 구성됩니다. 인프라스트럭처는 대표적으로 이메일 알림, SMS 알림 등 외부 서비스에 대한 코드들이 존재합니다. 그렇기 때문에 domain, global에 속하지 않습니다. global로 볼 수는 있지만 이 계층도 잘 관리해야 하는 대상이기에 별도의 디렉터리 했습니다.

인프라스트럭처는 대체성을 강하게 갔습니다. SMS 메시지를 보내는 클라이언트를 국내 사용자에게는 KT SMS, 해외 사용자에게는 Amazon SMS 클라이언트를 이용해서 보낼 수 있습니다. 

만약 국내 서비스만 취급한다고 하더라도 언제 다른 플랫폼으로 변경될지 모르니 이런 인프라스트럭처는 기계적으로 인터페이스를 두고 개발하는 것이 좋습니다. 이런 측면에서 infra 디렉터리로 분리 시켜 관련 코드들을 모았습니다.

## 결론
도메인형 기준으로 디렉터리를 구성하디보니 도메인 디렉터리에 속하지 않은 config, util, error, common, infra 등을 어느 디렉터리에 위치시켜야 할지 고민을 했었고 global, infra로 분리해서 도메인에 속하지 않은 코드들을 위치 시켰습니다. 그러기 때문에 도메인형이라는 큰 틀에서는 어느 정도 자유롭게 구성을 하는 것이 좋습니다.

특히 DDD의 Root Aggregate 기준으로 디렉터리들이 위치하는 경우 디렉터리 위치만으로도 개발자에게 많은 컨텍스트를 전달해줄 수 있다고 생각합니다.

---

## domain-guide

# Domain Guide

도메인 객체는 우리가 해결하고자 하는 핵심 비즈니스 로직이 반영되는 곳입니다. 특히 도메인 객체에서 자기 자신의 책임을 충분히 다하지 않으면 그 로직들은 자연스럽게 Service 영역 및 외부 영역에서 해당 책임 넘겨받아 구현하게 됩니다. 본인의 책임을 다하는 도메인 객체를 만들고 다른 레이어와 어떻게 메시지를 주고받는지 포스팅을 진행하겠습니다.

## 목차

- [Domain Guide](#domain-guide)
  - [목차](#%EB%AA%A9%EC%B0%A8)
  - [Member 클래스](#member-%ED%81%B4%EB%9E%98%EC%8A%A4)
  - [Lombok 잘쓰기](#lombok-%EC%9E%98%EC%93%B0%EA%B8%B0)
  - [실무에서 Lombok 사용법 요약](#%EC%8B%A4%EB%AC%B4%EC%97%90%EC%84%9C-lombok-%EC%82%AC%EC%9A%A9%EB%B2%95-%EC%9A%94%EC%95%BD)
  - [JPA 어노테이션](#jpa-%EC%96%B4%EB%85%B8%ED%85%8C%EC%9D%B4%EC%85%98)
  - [Embedded 적극 활용하기](#embedded-%EC%A0%81%EA%B7%B9-%ED%99%9C%EC%9A%A9%ED%95%98%EA%B8%B0)
  - [Rich Obejct](#rich-obejct)


## Member 클래스
```java
@Entity
@Table(name = "member")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
@EqualsAndHashCode(of = {"id"})
@ToString(of = {"email", "name"})
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", updatable = false)
    private Long id;

    @Embedded
    @AttributeOverride(name = "value", column = @Column(name = "email", nullable = false, unique = true, updatable = false, length = 50))
    private Email email;

    @Embedded
    @AttributeOverride(name = "value", column = @Column(name = "referral_code", nullable = false, unique = true, updatable = false, length = 50))
    private ReferralCode referralCode;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "first", column = @Column(name = "first_name", nullable = false)),
            @AttributeOverride(name = "middle", column = @Column(name = "middle_name")),
            @AttributeOverride(name = "last", column = @Column(name = "last_name", nullable = false))
    })
    private Name name;

    @CreationTimestamp
    @Column(name = "create_at", nullable = false, updatable = false)
    private LocalDateTime createAt;

    @UpdateTimestamp
    @Column(name = "update_at", nullable = false)
    private LocalDateTime updateAt;

    @Builder
    public Member(Email email, ReferralCode referralCode, Name name) {
        this.email = email;
        this.referralCode = referralCode;
        this.name = name;
    }

    public void updateProfile(final Name name) {
        this.name = name;
    }
}
```

## Lombok 잘쓰기 
> [실무에서 Lombok 사용법](https://github.com/cheese10yun/blog-sample/tree/master/lombok)에 자세한 설명이 있습니다.

## 실무에서 Lombok 사용법 요약
* `@NoArgsConstructor(access = AccessLevel.PROTECTED)` JPA에서는 프록시 객체가 필요하므로 기본 생성자 하나가 반드시 있어야 합니다. 이때 접근지시자는 `protected`면 됩니다. (낮은 접근지시자를 사용)
* `@Data`는 사용하지 말자, 너무 많은 것들을 해준다.
* `@Setter`는 사용하지 말자, 객체는 변경 포인트를 남발하지 말자.
* `@ToString` 무한 참조가 생길 수 있다. 조심하자. (개인적으로 `@ToString(of = {""})` 권장)
* 클래스 상단의 `@Builder` X, 생성자 위에 `@Builder` OK


Lombok이 자동으로 해주는 것들을 남용하다 보면 코드의 안전성이 낮아집니다. 특히 도메인 엔티티는 모든 레이어에서 사용되는 객체이니 특별히 신경을 더 많이 써야 합니다. **이 부분은 모든 객체에 해당되는 부분입니다.**

## JPA 어노테이션

* `@Table(name = "member")` : 테이블 네임은 반드시 명시합니다. 명시하지 않으면 기본적으로 클래스 네임을 참조하기 때문에 클래스 네임 변경 시 영향을 받게 됩니다.
* `@Column` : 컬럼 네임도 클래스 네임과 마찬가지로 반드시 지정합니다.
* `nullable`, `unique`, `updatable` 등의 기능을 적극 활용합니다. 이메일일 경우 `nullable`, `unique` 같은 속성을 반드시 추가합니다.
* `@CreationTimestamp`, `@UpdateTimestamp` 어노테이션을 이용하여 생성, 수정 시간을 쉽게 설정할 수 있습니다.

## Embedded 적극 활용하기
`Embedded` 어노테이션을 이용하여 도메인 객체의 책임을 나눌 수 있습니다. **앞서 언급했지만, 객체가 자기 자신의 책임을 다하지 않으면 그 책임은 자연스럽게 다른 객체에게 넘어가게 됩니다.**

`Name`, `Address` 객체들이 대표적인 `Embedded` 대상이 되는 객체들입니다. `Member` 객체에서 `Embedded`으로 해당 객체를 가지고 있지 않았다면 다음과 같이 작성됩니다.

```java
class Member {
    @NotEmpty @Column(name = "first_name", length = 50)
    private String firstName;

    @Column(name = "middle_name", length = 50)
    private String middleName;

    @NotEmpty @Column(name = "last_name", length = 50)
    private String lastName;

    @NotEmpty @Column(name = "county")
    private String county;

    @NotEmpty
    @Column(name = "state")
    private String state;

    @NotEmpty
    @Column(name = "city")
    private String city;

    @NotEmpty
    @Column(name = "zip_code")
    private String zipCode;
}
```

전체 이름, 전체 주소를 가져오기 위해서는 Member 객체에서 기능을 구현해야 합니다. 즉 Member의 책임이 늘어나는 것입니다. 그뿐만이 아닙니다. `Name`, `Address`는 많은 도메인 객체에서 사용되는 객체이므로 중복 코드의 증가됩니다. 아래 코드는 `Embedded`을 활용한 코드입니다.

```java
public class Name {
    @NotEmpty @Column(name = "first_name", length = 50)
    private String first;

    @Column(name = "middle_name", length = 50)
    private String middle;

    @NotEmpty @Column(name = "last_name", length = 50)
    private String last;
}

public class Address {
    @NotEmpty @Column(name = "county")
    private String county;

    @NotEmpty @Column(name = "state")
    private String state;

    @NotEmpty @Column(name = "city")
    private String city;

    @NotEmpty @Column(name = "zip_code")
    private String zipCode;
}

public class Member {
    @Embedded private Name name;
    @Embedded private Address address;
}
```
`Name`, `Address` 객체에서 본인의 책임을 충분히 해주고 있다면 `Member` 객체도 그 부분에 대해서는 책임이 줄어들게 됩니다. 

만약 주문이라는 객체가 있다면 `Name`, `Address` 객체를 그대로 사용하면 됩니다. `Embedded`의 장점을 정리하면 아래와 같습니다.

1. 데이터 응집력 증가
2. 중복 코드 방지
3. 책임의 분산
4. 테스트 코드 작성의 용이함

## Rich Obejct
저는 이 부분이 객체지향에서 가장 기본적이며 핵심적인 것이라고 생각합니다. JPA도 객체지향 프로그래밍을 돕는(패러다임 불일치를 해결해서) 도구라고 생각합니다.

**객체지향에서 중요한 것들이 많겠지만 그중에 하나가 객체 본인의 책임을 다하는 것입니다. 여러번 반복해서 언급하지만, 객체가 자기 자신의 책임을 다하지 않으면 그 책임은 다른 객체에게 넘어가게 됩니다.**

도메인 객체들에 기본적인 getter, setter 외에는 메서드를 작성하지 않는 경우가 있습니다. 이렇게 되면 객체 본인의 책임을 다하지 않으니 이런 책임들이 다른 객체에서 이루어지게 됩니다.

다음은 쿠폰 도메인 객체 코드입니다.

```java
public class Coupon {

    @Embedded
    private CouponCode code;

    @Column(name = "used", nullable = false)
    private boolean used;

    @Column(name = "discount", nullable = false)
    private double discount;

    @Column(name = "expiration_date", nullable = false, updatable = false)
    private LocalDate expirationDate;

    public boolean isExpiration() {
        return LocalDate.now().isAfter(expirationDate);
    }

    public void use() {
        verifyExpiration();
        verifyUsed();
        this.used = true;
    }

    private void verifyUsed() {
        if (used) throw new CouponAlreadyUseException();
    }

    private void verifyExpiration() {
        if (LocalDate.now().isAfter(getExpirationDate())) throw new CouponExpireException();
    }
}

```

쿠폰에 만료 여부, 쿠폰이 사용 가능 여부, 쿠폰의 사용 등의 메서드는 어느 객체에서 제공해야 할까요? 당연히도 쿠폰 객체 자신입니다.


> 출처 : 객체지향의 사실과 오해 (정말 정말 추천드리고 싶은 도서입니다.)
> 
> 객체는 충분히 '협력적'이어야 한다. 객체는 다른 객체의 요청에 충실히 귀 기울이고 다른 객체에게 적극적으로 도움을 요청할 정도로 열린 마음을 지녀야 한다. 객체는 다른 객체의 명령에 복종하는 것이 아니라 요청에 응답할 뿐이다. 어떤 방식으로 응답할지는 객체 스스로 판단하고 결장한다. 심지어 요청에 응할지 여부도 객체 스스로 결정할 수 있다.


단순하게 getter, settet 메서드만 제공한다면 이는 협력적인 관계가 아닙니다. 그저 복종하는 관계에 지나지 않습니다. 또 요청에 응답할지 자체도 객체 스스로가 결절할 수 있게 객체의 자율성을 보장해야 합니다. `use()` 메서드 요청이 오더라도 쿠폰 객체는 해당 요청이 알맞지 않다고 판단하면 그 요청을 무시하고 예외를 발생시킵니다. 이렇듯 객체의 자율성이 있어야 합니다.


setter를 사용하게 되면 해당 객체는 복종하는(수동적인) 관계를 갖게 됩니다.(순수하게 값을 바인딩 하는 코드만 있는 setter를 의미) `setUse(true)` 메서드는 그저 used 필드를 true 변경하는 외부 객체에 복종하는 메서드 그입니다. 쿠폰 객체 스스로가 자율성을 갖고 해당 메시지에 응답을 할지의 여부도 판단해야 외부 객체와 능동적인 관계를 갖게 됩니다.

또한 복종하는 관계에서는 쿠폰 사용 로직을 만들기 위해서 내가 객체의 세부적인 사항을 다 알고 있어야 합니다. 쿠폰 만료일, 만료 여부, 기타 등등 수많은 세부사항을 다 알고 검사를 하고 나서 비로소 `use()` 메서드를 호출하게 됩니다. 이것은 **본인의 책임을 다하고 있지 않아 외부 객체에게 해당 책임이 넘어가는 경우입니다.**

지금까지 설명드린 대부분의 경우는 도메인 객체에 국한 되지 않습니다. 모든 객체에 적용되는 설명입니다. 도메인 객체는 모든 레이어에서 사용하는 아주 중요한 객체이므로 여기서부터 올바른 책임을 제공해 주고 있지 않으면 모든 곳에서 힘들어지기 때문에 도메인 객체 가이드에 작성했습니다.


---

## exception-guide

# Exception Guide
스프링은 예외처리를 위해 다양하고 막강한 어노테이션을 제공하고 있습니다. 일관성 있는 코드 스타일을 유지하면서 Exception을 처리하는 방법에 대해서 소개하겠습니다.

# 목차
- [Exception Guide](#exception-guide)
- [목차](#%EB%AA%A9%EC%B0%A8)
- [통일된 Error Response 객체](#%ED%86%B5%EC%9D%BC%EB%90%9C-error-response-%EA%B0%9D%EC%B2%B4)
  - [Error Response JSON](#error-reponse-json)
  - [Error Response 객체](#error-reponse-%EA%B0%9D%EC%B2%B4)
- [@ControllerAdvice로 모든 예외를 핸들링](#controlleradvice-%EB%AA%A8%EB%93%A0-%EC%98%88%EC%99%B8%EB%A5%BC-%ED%97%A8%EB%93%A4%EB%A7%81)
- [Error Code 정의](#error-code-%EC%A0%95%EC%9D%98)
- [Business Exception 처리](#business-exception-%EC%B2%98%EB%A6%AC)
  - [비즈니스 예외를 위한 최상위 BusinessException 클래스](#%EB%B9%84%EC%A7%80%EB%8B%88%EC%8A%A4-%EC%98%88%EC%99%B8%EB%A5%BC-%EC%9C%84%ED%95%9C-%EC%B5%9C%EC%83%81%EC%9C%84-businessexception-%ED%81%B4%EB%9E%98%EC%8A%A4)
  - [Coupon Code](#coupon-code)
- [컨트롤러 예외 처리](#%EC%BB%A8%ED%8A%B8%EB%A1%A4%EB%9F%AC-%EC%98%88%EC%99%B8-%EC%B2%98%EB%A6%AC)
  - [Controller](#controller)
- [Try Catch 전략](#try-catch-%EC%A0%84%EB%9E%B5)

# 통일된 Error Response 객체

Error Response 객체는 항상 동일한 Error Response를 가져야 합니다. 그렇지 않으면 클라이언트에서 예외 처리를 항상 동일한 로직으로 처리하기 어렵습니다. Error Response 객체를 유연하게 처리하기 위해서 간혹 `Map<Key, Value>` 형식으로 처리하는데 이는 좋지 않다고 생각합니다. 우선 Map 이라는 친구는 런타임시에 정확한 형태를 갖추기 때문에 객체를 처리하는 개발자들도 정확히 무슨 키에 무슨 데이터가 있는지 확인하기 어렵습니다.

```java
@ExceptionHandler(MethodArgumentNotValidException.class)
protected ResponseEntity<ErrorResponse> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
    log.error("handleMethodArgumentNotValidException", e);
    final ErrorResponse response = ErrorResponse.of(ErrorCode.INVALID_INPUT_VALUE, e.getBindingResult());
    return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
}
```
위 예제 코드처럼 리턴 타입이 `ResponseEntity<ErrorResponse>` 으로 무슨 데이터가 어떻게 있는지 명확하게 추론하기 쉽도록 구성하는 게 바람직합니다.

## Error Response JSON
```json
{
  "message": " Invalid Input Value",
  "status": 400,
  // "errors":[], 비어있을 경우 null 이 아닌 빈 배열을 응답한다.
  "errors": [
    {
      "field": "name.last",
      "value": "",
      "reason": "must not be empty"
    },
    {
      "field": "name.first",
      "value": "",
      "reason": "must not be empty"
    }
  ],
  "code": "C001"
}
```
ErrorResponse 객체의 JSON 입니다.
* message : 에러에 대한 message를 작성합니다.
* status : http status code를 작성합니다. header 정보에도 포함된 정보이니 굳이 추가하지 않아도 됩니다.
* errors : 요청 값에 대한 `field`, `value`, `reason` 작성합니다. 일반적으로 `@Valid` 어노테이션으로 `JSR 303: Bean Validation`에 대한 검증을 진행 합니다.
  * 만약 errors에 바인인된 결과가 없을 경우 null이 아니라 빈 배열 `[]`을 응답해줍니다. null 객체는 절대 리턴하지 않습니다. null이 의미하는 것이 애매합니다.
* code : 에러에 할당되는 유니크한 코드값입니다.


## Error Response 객체

```java
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ErrorResponse {

    private String message;
    private int status;
    private List<FieldError> errors;
    private String code;
    ...

    @Getter
    @NoArgsConstructor(access = AccessLevel.PROTECTED)
    public static class FieldError {
        private String field;
        private String value;
        private String reason;
        ...
    }
}
```
ErrorResponse 객체 입니다. POJO 객체로 관리하면 `errorResponse.getXXX();` 이렇게 명확하게 객체에 있는 값을 가져올 수 있습니다. 그 밖에 특정 Exception에 대해서 ErrorResponse 객체를 어떻게 만들 것인가에 대한 책임을 명확하게 갖는 구조로 설계할 수 있습니다. 세부적인 것은 코드를 확인해주세요.

# @ControllerAdvice로 모든 예외를 핸들링

`@ControllerAdvice` 어노테이션으로 모든 예외를 한 곳에서 처리할 수 있습니다. 해당 코드의 세부적인 것은 중요하지 않으며 가장 기본적이며 필수적으로 처리하는 코드입니다. 코드에 대한 이해보다 아래의 설명을 참고하는 게 좋습니다.

```java
@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    /**
     *  javax.validation.Valid or @Validated 으로 binding error 발생시 발생한다.
     *  HttpMessageConverter 에서 등록한 HttpMessageConverter binding 못할경우 발생
     *  주로 @RequestBody, @RequestPart 어노테이션에서 발생
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    protected ResponseEntity<ErrorResponse> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        log.error("handleMethodArgumentNotValidException", e);
        final ErrorResponse response = ErrorResponse.of(ErrorCode.INVALID_INPUT_VALUE, e.getBindingResult());
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * @ModelAttribut 으로 binding error 발생시 BindException 발생한다.
     * ref https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-modelattrib-method-args
     */
    @ExceptionHandler(BindException.class)
    protected ResponseEntity<ErrorResponse> handleBindException(BindException e) {
        log.error("handleBindException", e);
        final ErrorResponse response = ErrorResponse.of(ErrorCode.INVALID_INPUT_VALUE, e.getBindingResult());
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * enum type 일치하지 않아 binding 못할 경우 발생
     * 주로 @RequestParam enum으로 binding 못했을 경우 발생
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    protected ResponseEntity<ErrorResponse> handleMethodArgumentTypeMismatchException(MethodArgumentTypeMismatchException e) {
        log.error("handleMethodArgumentTypeMismatchException", e);
        final ErrorResponse response = ErrorResponse.of(e);
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * 지원하지 않은 HTTP method 호출 할 경우 발생
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    protected ResponseEntity<ErrorResponse> handleHttpRequestMethodNotSupportedException(HttpRequestMethodNotSupportedException e) {
        log.error("handleHttpRequestMethodNotSupportedException", e);
        final ErrorResponse response = ErrorResponse.of(ErrorCode.METHOD_NOT_ALLOWED);
        return new ResponseEntity<>(response, HttpStatus.METHOD_NOT_ALLOWED);
    }

    /**
     * Authentication 객체가 필요한 권한을 보유하지 않은 경우 발생합니다.
     */
    @ExceptionHandler(AccessDeniedException.class)
    protected ResponseEntity<ErrorResponse> handleAccessDeniedException(AccessDeniedException e) {
        log.error("handleAccessDeniedException", e);
        final ErrorResponse response = ErrorResponse.of(ErrorCode.HANDLE_ACCESS_DENIED);
        return new ResponseEntity<>(response, HttpStatus.valueOf(ErrorCode.HANDLE_ACCESS_DENIED.getStatus()));
    }

    @ExceptionHandler(BusinessException.class)
    protected ResponseEntity<ErrorResponse> handleBusinessException(final BusinessException e) {
        log.error("handleEntityNotFoundException", e);
        final ErrorCode errorCode = e.getErrorCode();
        final ErrorResponse response = ErrorResponse.of(errorCode);
        return new ResponseEntity<>(response, HttpStatus.valueOf(errorCode.getStatus()));
    }


    @ExceptionHandler(Exception.class)
    protected ResponseEntity<ErrorResponse> handleException(Exception e) {
        log.error("handleEntityNotFoundException", e);
        final ErrorResponse response = ErrorResponse.of(ErrorCode.INTERNAL_SERVER_ERROR);
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```

* handleMethodArgumentNotValidException
  * avax.validation.Valid or @Validated 으로 binding error 발생 시 발생한다. )
  * HttpMessageConverter 에서 등록한 HttpMessageConverter binding 못할 경우 발생. 주로 @RequestBody, @RequestPart 어노테이션에서 발생함.
* handleBindException
  * @ModelAttribut 으로 binding error 발생시 BindException 발생한다.
* MethodArgumentTypeMismatchException
  * enum type 일치하지 않아 binding 못할 경우 발생
  * 주로 @RequestParam enum으로 binding 못했을 경우 발생
* handleHttpRequestMethodNotSupportedException :
  * 지원하지 않은 HTTP method 호출 할 경우 발생
* handleAccessDeniedException
  * Authentication 객체가 필요한 권한을 보유하지 않은 경우 발생합니다.
  * Security에서 던지는 예외
* handleException
  * 그 밖에 발생하는 모든 예외 처리, Null Point Exception, 등등
  * 개발자가 직접 핸들링해서 다른 예외로 던지지 않으면 모두 이곳으로 모인다.
* handleBusinessException
  * 비즈니스 요규사항에 따른 Exception
  * 아래에서 자세한 설명 진행

추가로 스프링 및 라이브러리 등 자체적으로 발생하는 예외는 `@ExceptionHandler` 으로 추가해서 적절한 Error Response를 만들고 **비지니스 요구사항에 예외일 경우 `BusinessException` 으로 통일성 있게 처리하는 것을 목표로 한다. 추가로 늘어날 수는 있겠지만 그 개수를 최소한으로 하는 노력이 필요합니다.**


# Error Code 정의
```java
public enum ErrorCode {

    // Common
    INVALID_INPUT_VALUE(400, "C001", " Invalid Input Value"),
    METHOD_NOT_ALLOWED(405, "C002", " Invalid Input Value"),
    ....
    HANDLE_ACCESS_DENIED(403, "C006", "Access is Denied"),

    // Member
    EMAIL_DUPLICATION(400, "M001", "Email is Duplication"),
    LOGIN_INPUT_INVALID(400, "M002", "Login input is invalid"),

    ;
    private final String code;
    private final String message;
    private int status;

    ErrorCode(final int status, final String code, final String message) {
        this.status = status;
        this.message = message;
        this.code = code;
    }
}
```
에러 코드는 enum 타입으로 한 곳에서 관리합니다.

에러 코드가 전체적으로 흩어져있을 경우 코드, 메시지의 중복을 방지하기 어렵고 전체적으로 관리하는 것이 매우 어렵습니다. `C001` 같은 코드도 동일하게 enum으로 관리 하는 것도 좋습니다. 에러 메시지는 Common과 각 도메인별로 관리하는 것이 효율적일 거 같습니다.

# Business Exception 처리
여기서 말하는 Business Exception은 요구사항에 맞지 않을 경우 발생시키는 Exception을 말합니다. 만약 쿠폰을 사용 하려고 하는데 이미 사용한 쿠폰인 경우에는 더 이상 정상적인 흐름을 이어갈수가 없게 됩니다. 이런 경우에는 적절한 Exception을 발생시키고 로직을 종료 시켜야합니다.

더 쉽게 정리하면 요구사항에 맞게 개발자가 직접 Exception을 발생시키는 것들이 Business Exception 이라고 할수 있습니다.

유지 보수하기 좋은 코드를 만들기 위해서는 Exception을 발생시켜야 합니다. 쿠폰을 입력해서 상품을 주문했을 경우 상품 계산 로직에서 이미 사용해 버린 쿠폰이면 로직을 이어나가기는 어렵습니다.

단순히 어려운 것이 아니라 해당 계산 로직의 책임이 증가하게 됩니다. 계산 로직은 특정 공식에 의해서 제품의 가격을 계산하는 것이 책임이지 쿠폰이 이미 사용 해 경우, 쿠폰이 만료되었을 경우, 제품이 매진 됐을 경우 등등의 책임을 갖게 되는 순간 유지 보수하기 어려운 코드가 됩니다. 객체의 적절한 책임을 주기 위해서라도 본인이 처리 못 하는 상황일 경우 적절한 Exception을 발생시켜야 합니다.

> 클린 코드 : 오류 코드 보다 예외를 사용하라 리팩토링

```java
public class DeviceController {
    ...
    public void sendShutDown() {
        DeviceHandle handle = getHandle(DEV1);
        // 디바이스 상태를 점검한다.
        if (handle != DeviceHandle.INVALID) {
            // 레코드 필드에 디바이스 상태를 저장한다.
            retrieveDeviceRecord(handle);
            // 디바이스가 일시정지 상태가 아니라면 종료한다.
            if (record.getStatus() != DEVICE_SUSPENDED) {
                pauseDevice(handle);
                clearDeviceWorkQueue(handle);
                closeDevice(handle);
            } else {
                logger.log("Device suspended. Unable to shut down");
            }
        } else {
            logger.log("Invalid handle for: " + DEV1.toString());
        }
    }
    ...
}
```
`if ... else`의 반복으로 인해서 sendShutDown 핵심 비지니스 코드의 이해하기가 어렵습니다.

```java
public class DeviceController {
    ...
    public void sendShutDown() {
        try {
            tryToShutDown();
        } catch (DeviceShutDownError e) {
            logger.log(e);
        }
    }

    private void tryToShutDown() throws DeviceShutDownError {
        DeviceHandle handle = getHandle(DEV1);
        DeviceRecord record = retrieveDeviceRecord(handle);
        pauseDevice(handle);
        clearDeviceWorkQueue(handle);
        closeDevice(handle);
    }

    private DeviceHandle getHandle(DeviceID id) {
        ...
        throw new DeviceShutDownError("Invalid handle for: " + id.toString());
        ...
    }
    ...
}
```
객체 본인의 책임 외적인 것들은 DeviceShutDownError 예외를 발생시키고 있습니다. 코드의 가독성과 책임이 분명하게 드러나고 있습니다.

## 비지니스 예외를 위한 최상위 BusinessException 클래스

![](/docs/imgs/BusinessException-final.png)

최상위 BusinessException을 상속 받는 InvalidValueException, EntityNotFoundException 등이 있습니다.

* InvalidValueException : 유효하지 않은 값일 경우 예외를 던지는 Excetion
  * 쿠폰 만료, 이미 사용한 쿠폰 등의 이유로 더이상 진행이 못할경우
* EntityNotFoundException : 각 엔티티들을 못찾았을 경우
  * `findById`, `findByCode` 메서드에서 조회가 안되었을 경우

최상위 BusinessException을 기준으로 예외를 발생시키면 통일감 있는 예외 처리를 가질 수 있습니다. 비니지스 로직을 수행하는 코드 흐름에서 로직의 흐름을 진행할 수 없는 상태인 경우에는 적절한 BusinessException 중에 하나를 예외를 발생 시키거나 직접 정의하게 됩니다.

```java
@ExceptionHandler(BusinessException.class)
protected ResponseEntity<ErrorResponse> handleBusinessException(final BusinessException e) {
    log.error("handleEntityNotFoundException", e);
    final ErrorCode errorCode = e.getErrorCode();
    final ErrorResponse response = ErrorResponse.of(errorCode);
    return new ResponseEntity<>(response, HttpStatus.valueOf(errorCode.getStatus()));
}
```
이렇게 발생하는 모든 예외는 `handleBusinessException` 에서 동일하게 핸들링 됩니다. 예외 발생시 알람을 받는 등의 추가적인 행위도 손쉽게 가능합니다. 또 BusinessException 클래스의 하위 클래스 중에서 특정 예외에 대해서 다른 알람을 받는 등의 더 디테일한 핸들링도 가능해집니다.


## Coupon Code

```java
public class Coupon {

    ...

    public void use() {
        verifyExpiration();
        verifyUsed();
        this.used = true;
    }

    private void verifyUsed() {
        if (used) throw new CouponAlreadyUseException();
    }

    private void verifyExpiration() {
        if (LocalDate.now().isAfter(getExpirationDate())) throw new CouponExpireException();
    }
}
```
쿠폰의 `use` 메서드입니다. 만료일과 사용 여부를 확인하고 예외가 발생하면 적절한 Exception을 발생시킵니다.

# 컨트롤러 예외 처리

컨틀롤러에서 모든 요청에 대한 값 검증을 진행하고 이상이 없을 시에 서비스 레이어를 호출해야 합니다. 위에서도 언급했듯이 잘못된 값이 있으면 서비스 레이어에서 정상적인 작업을 진행하기 어렵습니다. **무엇보다 컨틀롤러의 책임을 다하고 있지 않으면 그 책임은 자연스럽게 다른 레이어로 전해지게 되며 이렇게 넘겨받은 책임을 처리하는데 큰 비용과 유지보수 하기 어려워질 수밖에 없습니다.**

컨트롤러의 중요한 책임 중의 하나는 요청에 대한 값 검증이 있습니다. 스프링은 JSR 303 기반 어노테이션으로 값 검증을 쉽고 일관성 있게 처리할 수 있도록 도와줍니다. 모든 예외는 `@ControllerAdvice` 선언된 객체에서 핸들링 됩니다. 컨트롤러로 본인이 직접 예외까지 처리하지 않고 예외가 발생하면 그냥 던져버리는 패턴으로 일관성 있게 개발할 수 있습니다.


## Controller
```java
@RestController
@RequestMapping("/members")
public class MemberApi {

    private final MemberSignUpService memberSignUpService;

    @PostMapping
    public MemberResponse create(@RequestBody @Valid final SignUpRequest dto) {
        final Member member = memberSignUpService.doSignUp(dto);
        return new MemberResponse(member);
    }
}
```
```java
public class SignUpRequest {
    @Valid private Email email;
    @Valid private Name name;
}

public class Name {
    @NotEmpty private String first;
    private String middle;
    @NotEmpty private String last;
}

public class Email {
    @javax.validation.constraints.Email
    private String value;
}
```

회원 가입 Reuqest Body 중에서 유효하지 않은 값이 있을 때 `@Valid` 어노테이션으로 예외를 발생시킬 수 있습니다. 이 예외는 `@ControllerAdvice`에서 적절하게 처리됩니다. `@NotEmpty`, `@Email` 외에도 다양한 어노테이션들이 제공됩니다.

# Try Catch 전략
기본적으로 예외가 발생하면 로직의 흐름을 끊고 종료 시켜야 합니다. 물론 예외도 있지만, 최대한 예외를 발생시켜 종료하는 것을 지향해야 한다고 생각합니다.

```java
try {
    // 비즈니스 로직 수행...
}catch (Exception e){
    e.printStackTrace();
}
```
위 같은 코드는 지양해야 하는 패턴입니다. 최소한의 양심으로 `e.printStackTrace();` 로그라도 출력했지만 이미 예외가 발생했음에도 불구하고 다음 로직을 실행합니다. 이런 식의 `try catch`를 최대한 지양해야 합니다.

하지만 Checked Exception 같은 경우에는 예외를 반드시 감싸야 하므로 이러한 경우에는 `try catch`를 사용해야 합니다.

```java
try {
    // 비즈니스 로직 수행...
}catch (Exception e){
    e.printStackTrace();
    throw new XXX비즈니스로직예외(e);
}
```
`try catch`를 사용해야 하는 경우라면 더 구체적인 예외로 Exception을 발생시키는 것이 좋습니다. 간단하게 정리하면

1. `try catch`를 최대한 지양해라
2. `try catch`로 에러를 먹고 주는 코드는 지양해라(이런 코드가 있다면 로그라도 추가해주세요...)
3. `try catch`를 사용하게 된다면 더 구체적인 Exception을 발생시키는 것이 좋다.


---

## service-guide

# Service Guide

## 서비스 레이어란 ?

![](https://image.slidesharecdn.com/random-151127092631-lva1-app6892/95/-60-638.jpg?cb=1448755823)
> 이미지 출저 [애플리케이션 아키텍처와 객체지향](https://www.slideshare.net/baejjae93/ss-55571345)

우리는 Member라는 객체로 회원가입(객체 생성), 프로필 수정(객체 수정) 모든 행위가 가능하지만 그것을 영속화 시켜야 하기 때문에 별도의 레이어가 필요하고 이것을 서비스 레이어라고 합니다. 서비스 레이어에서는 대표적으로 데이터베이스에 대한 트랜잭션을 관리합니다. 

서비스 영역은 도메인의 핵심 비즈니스 코드를 담당하는 영역이 아니라 인프라스트럭처(데이터베이스) 영역과 도메인 영역을 연결해주는 매개체 역할이라고 생각합니다.

**다시 한번 강조하지만 Member 객체에 대한 제어는 Member 스스로 제어해야 합니다.**



## 서비스의 적절한 책임의 크기 부여하기

책임이란 것은 외부 객체의 요청에 대한 응답이라고 생각합니다. **이러한 책임들이 모여 역할이 되고 역할은 대체 가능성을 의미합니다.** 그렇기 때문에 대체가 가능할 정도의 적절한 크기를 가져야 합니다. 이 부분은 아래의 예제로 천천히 설명드리겠습니다.

### 행위 기반으로 네이밍 하기

서비스의 책임의 크기를 잘 부여하는 방법 중에 가장 쉬운 방법이라고 생각합니다. 행위 기반으로 서비스를 만드는 것입니다.

`MemberService`라는 네이밍은 많이 사용하지만 정말 좋지 않은 패턴이라고 생각합니다. 우선 해당 클래스의 책임이 분명하지 않아서 모든 로직들이 `MemberService`으로 모이게 될 것입니다. 그 결과 외부 객체에서는 `MemberSerivce` 객체를 의존하게 됩니다. findById 메서드 하나를 사용하고 싶어도 `MemberSerivce`를 주입받아야 합니다. `MemberSerivce` 구현도 본인이 모든 구현을 하려고 하니 메서드의 라인 수도 방대해집니다. 테스트 코드 작성하기도 더욱 어렵게 만들어집니다.

Member에 대한 조회 전용 서비스 객체인 `MemberFindService`으로 네이밍을 하면 자연스럽게 객체의 책임이 부여됩니다. **객체를 행위 기반으로 바라보고 행위 기반으로 네이밍을 주어 자연스럽게 책임을 부여하는 것이 좋습니다.**

### 역할은 대체 가능성을 의미

> 책임이란 것은 외부 객체의 요청에 대한 응답이라고 생각합니다. **이러한 책임들이 모여 역할이 되고 역할은 대체 가능성을 의미합니다.** 

위에서 언급한 말을 매우 과격하게 표현하면 아래와 같습니다.

> 메서드(책임)란 것은 외부 객체의 호출에 대한 응답이고, 이러한 메서드(책임)들이 모여 클래스(역할)가되고 클래스(역할)는 인터페이스(대체 가능성)을 의미합니다.



[Service, ServiceImpl 구조에 대한 고찰](https://github.com/cheese10yun/blog-sample/tree/master/service)에 대해서 포스팅 한 내용을 다시 한번 설명드리겠습니다. 


#### 책임의 크기가 적절해야하는 이유

```java
public interface MemberService {

    Member findById(MemberId id);

    Member findByEmail(Email email);

    void changePassword(PasswordDto.ChangeRequest dto);

    Member updateName(MemberId id, Name name);
}
```
위 같은 Service, ServiceImpl 구조는 스프링 예제에서 많이 사용되는 예제입니다. 위 객체의 책임은 크게 member 조회, 수정입니다. 이 책임이 모여 클래스가 됩니다.(여기서는 MemberServiceImpl) 이 클래스(역할)는 대체 가능성을 의미합니다. **그런데 저 인터페이스가 대체가 될까요?**


findById, findByEmail, changePassword, updateName의 세부 구현이 모두 다른 구현제가 있을까요? 일반적으로는 저 모든 메서드를 세부 구현이 다르게 대체하는 구현체는 2개 이상 갖기 힘듭니다. 이렇듯 객체의 책임이 너무 많으면 대체성을 갖지 못하고 SOLID 또 한 준수할 수가 없습니다.

책임에 대한 자세한 내용은 [Service, ServiceImpl 구조에 대한 고찰](https://github.com/cheese10yun/blog-sample/tree/master/service), [단일 책임의 원칙: Single Responsibility Principle](https://github.com/cheese10yun/spring-SOLID/blob/master/docs/SRP.md)
를 참조해주세요

물론 1개의 세부 구현체만 갖더라도 인프라스트럭처 영역 같은 경우에는 인터페이스로 바라보는 것이 좋습니다. 그 외에도 다양한 이유로 인터페이스로 바라보게 하는 것이 클래래스 간의 강결합을 줄일 수 있는 효과가 있습니다. 제가 말하고 싶은 것은 그렇게 인터페이스로 두더라도 **올바른 책임의 크기에 의해서(대체 가능한 범위) 인터페이스를 나눠야 한다는 것입니다.**


### 서비스의 적절한 크기는 대체 가능성을 염두 하는 것

우선 행위 기반으로 서비스의 네이밍을 하면 자연스럽게 해당 행위에 대해서 책임이 할당됩니다. 이렇게 행위 기반으로 책임을 할당하면 자연스럽게 대체 가능성을 갖게 될 수 있습니다.

물론 이것만으로 올바르게 객체지향 설계를 할 수 있는 것은 아니지만 최소한의 객체지향 프로그래밍을 할 수 있는 작은 시발점이 될 수 있다고 생각합니다.

## SignUp Sample Code


```java
@Embeddable
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class ReferralCode {

    @Column(name = "referral_code", length = 50)
    private String value;

    private ReferralCode(String value) {
        this.value = value;
    }

    public static ReferralCode of(final String value) {
        return new ReferralCode(value);
    }

    public static ReferralCode generateCode() {
        return new ReferralCode(RandomString.make(10));
    }
}

@Service
@Transactional
@RequiredArgsConstructor
public class MemberSignUpService { // (1)

    private final MemberRepository memberRepository;

    public Member doSignUp(final SignUpRequest dto) {

        if (memberRepository.existsByEmail(dto.getEmail())) { //(2)
            throw new EmailDuplicateException(dto.getEmail());
        }

        final ReferralCode referralCode = generateUniqueReferralCode();
        return memberRepository.save(dto.toEntity(referralCode));
    }

    private ReferralCode generateUniqueReferralCode() { //(3)
        ReferralCode referralCode;
        do {
            referralCode = ReferralCode.generateCode(); //(4)
        } while (memberRepository.existsByReferralCode(referralCode)); // (5)

        return referralCode;
    }

}
```
1. MemberSignUpService 네이밍을 통해서 행위 기반의 책임을 부여
2. Email의 존재 여부는 데이터베이스에 있음으로 존재 여부는 memberRepository를 사용
3. 유니크한 referralCode를 생성을 위한 메서드
4. **ReferralCode에 대한 생성은 ReferralCode 객체가 관리**
5. 해당 코드가 존재하는지는 데이터베이스에 있음으로 존재 여부는 memberRepository를 사용


ReferralCode에 대한 생성 비즈니스 로직은 ReferralCode 객체가 스스로 제어하고 있습니다. 이것이 데이터베이스에 중복 여부 검사를 서비스 레이어에서 진행합니다.


---

## api-call-guide

# API Call Guide

이번 주제는 외부 API 호출 가이드를 진행하겠습니다. 본 포스팅에서는 RestTemplate 기반으로 설명하고 있지만 RestTemplate에 대한 사용법이 초점은 아닙니다. Request, Response에 대한 로킹, Interceptors를 통한 추가 작업, errorHandler을 통한 각 Vendor마다 예외 처리 전략을 살펴보겠습니다.

## Vendor 마다 다르게 Bean 등록

```java
@Bean
public RestTemplate localTestTemplate() {
return restTemplateBuilder.rootUri("http://localhost:8899")
    .additionalInterceptors(new RestTemplateClientHttpRequestInterceptor())
    .errorHandler(new RestTemplateErrorHandler())
    .setConnectTimeout(Duration.ofMinutes(3))
    .build();
}


@Bean
public RestTemplate xxxPaymentTemplate() {
return restTemplateBuilder.rootUri("http://xxxx")
    .additionalInterceptors(new RestTemplateClientHttpRequestInterceptor())
    .errorHandler(new RestTemplateErrorHandler())
    .setConnectTimeout(Duration.ofMinutes(3))
    .build();
}
```

우선 RestTemplate를 외부 API 특성에 맞는 Bean을 생성합니다. 여기서 중요한 점은 각 API Vendor사 별로 각각 Bean으로 관리하는 것입니다. 

Vendor사 별로 다르게 Bean을 적용하는 이유
* connection timeout 설정이 각기 다릅니다.
* 로깅을 각기 다르게 설정 할 수 있습니다.
* 예외 처리가 각기 다릅니다.
* API에 대한 권한 인증이 각기 다릅니다.

## Logging

restTemplateBuilder의 `additionalInterceptors()` 메서드를 이용하면 로킹을 쉽게 구현할 수 있고 특정 Vendor의 Bean에는 더 구체적인 로킹, 그 이외의 작업을 Interceptors을 편리하게 등록할 수 있습니다.

### Code

```java
@Slf4j
public class RestTemplateClientHttpRequestInterceptor implements ClientHttpRequestInterceptor {

  @NonNull
  @Override
  public ClientHttpResponse intercept(@NonNull final HttpRequest request,
      @NonNull final byte[] body, final @NonNull ClientHttpRequestExecution execution)
      throws IOException {
    final ClientHttpResponse response = execution.execute(request, body);

    loggingResponse(response);
    loggingRequest(request, body);
    return execution.execute(request, body);
  }
}
```
Request, Response의 Logging을 저장하는 Interceptor 코드입니다. 결제와 같은 중요한 API 호출은 모든 요청과 응답을 모두 로킹 하는 것이 바람직합니다. 

상대적으로 덜 중요한 API 호출 같은 경우에는 Interceptor 등록하지 않아도 됩니다. 이처럼 Vendor 사마다 Bean으로 지정해서 관리하는 것이 효율적입니다.

### API Call

```java
public class SampleApi {
  
  private final RestTemplate localTestTemplate;
  
  @PostMapping("/local-sign-up")
  public Member test(@RequestBody @Valid final SignUpRequest dto){
    final ResponseEntity<Member> responseEntity = localTestTemplate
        .postForEntity("/members", dto, Member.class);

    final Member member = responseEntity.getBody();
    return member;
  }
}
```
위에서 등록한 localTestTemplate Bean으로 회원 가입 API을 호출해보겠습니다.
![](imgs/api-req-res.png)


Interceptor를 통해서 요청했던 Request 정보와 응답받은 Response 정보가 모두 정상적으로 로그 되는 것을 확인할 수 있습니다.

## 예외 처리

외부 API는 Vendor마다 각기 다르기 때문에 통일성 있게 예외 처리를 진행하기 어렵습니다. 아래는 처리하기 애매한 한 Response입니다.

```json
{
  "success": false,
  "result": {
      ....
  }
}
```
Resttemplate는 우선 Http Status Code로 1차적으로 API 이상 유무를 검사하게 됩니다. 2xxx 이 외의 코드가 넘어오게 되면 Resttemplate 예외를 발생시킵니다. 

그런데 문제는 2xx http status code를 응답받고 위 JSON 같이 success에 false를 주는 API들입니다. 그렇다면 API 호출마다 아래와 같은 코드로 확인해야 합니다.

```java

  public Member test(@RequestBody @Valid final SignUpRequest dto){
    final ResponseEntity<Member> responseEntity = localTestTemplate
        .postForEntity("/members", dto, Member.class);

    if(responseEntity.getBody().isSuccess(){
      // 성공...
    }else{
      // 실패...
    }
    ...
  }
```

모든 API 호출 시에 위와 같은 if else 코드가 있다고 생각하면 끔찍합니다. 이처럼 Vendor마다 다른 예외 처리를 Interceptor처럼 등록해서 Vendor에 알맞은 errorHandler를 지정할 수 있습니다.


### Code
```java
public class RestTemplateErrorHandler implements ResponseErrorHandler {

  @Override
  public boolean hasError(@NonNull final ClientHttpResponse response) throws IOException {
    final HttpStatus statusCode = response.getStatusCode();
//    response.getBody() 넘겨 받은 body 값으로 적절한 예외 상태 확인 이후 boolean return
    return !statusCode.is2xxSuccessful();
  }

  @Override
  public void handleError(@NonNull final ClientHttpResponse response) throws IOException {
//    hasError에서 true를 return하면 해당 메서드 실행.
//    상황에 알맞는 Error handling 로직 작성....
  }
```
Bean을 등록할 때 ResponseErrorHandler 객체를 추가할 수 있습니다. Response 객체에 `"success": false`를 `hasError()` 메서드에서 확인하고, false가 return 되면 `handleError()`에서 추가적인 에러 핸들링 작업을 이어 나갈 수 있습니다. 이렇게 ResponseErrorHandler 등록을 하면 위처럼 반본 적인 if else 문을 작성하지 않아도 됩니다.

![](imgs/api-error.png)

위 그림은 에러 발생 시 로킹을 남기는 ResponseErrorHandler를 등록 이후 출력된 그림입니다.

개인적인 의견이지만 2xx 관련된 Reponse에 `success` 같은 키값을 내려주지 않는 것이 좋다고 생각합니다. 2xx status code를 응답 해놓고 다시 `success` false를 주는 것이 논리적으로 이해하기 어렵습니다. 특히 boolean 타입이 아닌 문자열로 내려주는 경우 무슨 문자열이 성공이며, 실패인지 알기가 더 어렵습니다.


## 마무리
본 예제에서는 RestTemplate를 기반으로 설명드리긴 했지만 각 Vendor마다 다르고 그것은 추상화하기 어렵기 때문에 별도의 Bean으로 등록하고 특정 Vendor에 특화된 로킹 예외 처리 등 다양한 후속 처리를 하는 것이 바람직하다고 생각합니다.

---

## test-guide

# Test Guide

스프링은 다양한 테스트 전략을 제공하고 있습니다. 대표적으로 Slice Test 라는 것으로 특정 레이어에 대해서 Bean을 최소한으로 등록시켜 테스트 하고자 하는 부분에 최대한 단위 테스트를 지원합니다. 다양하게 지원해주는 만큼 테스트 코드를 통일성 있게 관리하는 것이 중요합니다. 더 안전하고 통일성 있게 테스트를 진행하는 방법에 대해서 제 나름의 노하우를 정리해보았습니다.

# 목차

- [Test Guide](#test-guide)
- [목차](#%EB%AA%A9%EC%B0%A8)
- [테스트 전략](#%ED%85%8C%EC%8A%A4%ED%8A%B8-%EC%A0%84%EB%9E%B5)
- [통합테스트](#%ED%86%B5%ED%95%A9%ED%85%8C%EC%8A%A4%ED%8A%B8)
  - [장점](#%EC%9E%A5%EC%A0%90)
  - [단점](#%EB%8B%A8%EC%A0%90)
  - [Code](#code)
    - [IntegrationTest](#integrationtest)
    - [Test Code](#test-code)
- [서비스 테스트](#%EC%84%9C%EB%B9%84%EC%8A%A4-%ED%85%8C%EC%8A%A4%ED%8A%B8)
  - [장점](#%EC%9E%A5%EC%A0%90-1)
  - [단점](#%EB%8B%A8%EC%A0%90-1)
  - [Code](#code-1)
    - [MockTest](#mocktest)
    - [Test Code](#test-code-1)
- [Mock API 테스트](#mock-api-%ED%85%8C%EC%8A%A4%ED%8A%B8)
  - [장점](#%EC%9E%A5%EC%A0%90-2)
  - [단점](#%EB%8B%A8%EC%A0%90-2)
  - [Code](#code-2)
- [Repository Test](#repository-test)
  - [장점](#%EC%9E%A5%EC%A0%90-3)
  - [단점](#%EB%8B%A8%EC%A0%90-3)
  - [Code](#code-3)
    - [RepositoryTest](#repositorytest)
    - [Test Code](#test-code-2)
- [POJO 테스트](#pojo-%ED%85%8C%EC%8A%A4%ED%8A%B8)
  - [설명](#%EC%84%A4%EB%AA%85)
  - [장점](#%EC%9E%A5%EC%A0%90-4)
  - [단점](#%EB%8B%A8%EC%A0%90-4)
  - [Code](#code-4)
    - [Embeddable](#embeddable)
    - [Test Code](#test-code-3)
- [마무리](#%EB%A7%88%EB%AC%B4%EB%A6%AC)



# 테스트 전략

| 어노테이션           | 설명                  | 부모 클래스          | Bean         |
| --------------- | ------------------- | --------------- | ------------ |
| @SpringBootTest | 통합 테스트, 전체          | IntegrationTest | Bean 전체      |
| @WebMvcTest     | 단위 테스트, Mvc 테스트     | MockApiTest     | MVC 관련된 Bean |
| @DataJpaTest    | 단위 테스트, Jpa 테스트     | RepositoryTest  | JPA 관련 Bean  |
| None            | 단위 테스트, Service 테스트 | MockTest        | None         |
| None            | POJO, 도메인 테스트       | None            | None         |

# 통합테스트

## 장점
* 모든 Bean을 올리고 테스트를 진행하기 때문에 쉽게 테스트 진행 가능
* 모든 Bean을 올리고 테스트를 진행하기 때문에 운영환경과 가장 유사하게 테스트 가능
* API를 테스트할 경우 요청부터 응답까지 전체적인 테스트 진행 가능

## 단점
* 모든 Bean을 올리고 테스트를 진행하기 때문에 테스트 시간이 오래 걸림
* 테스트의 단위가 크기 때문에 테스트 실패시 디버깅이 어려움
* 외부 API 콜같은 Rollback 처리가 안되는 테스트 진행을 하기 어려움

## Code

### IntegrationTest
```java
@RunWith(SpringRunner.class)
@SpringBootTest(classes = ApiApp.class)
@AutoConfigureMockMvc
@ActiveProfiles(TestProfile.TEST)
@Transactional
@Ignore
public class IntegrationTest {
    @Autowired protected MockMvc mvc;
    @Autowired protected ObjectMapper objectMapper;
    ...
}
```
* 통합 테스트의 Base 클래스입니다. Base 클래스를 통해서 테스트 전략을 통일성 있게 가져갈 수 있습니다.
* 통합 테스트는 주로 컨트롤러 테스트를 주로 하며 요청부터 응답까지의 전체 플로우를 테스트합니다.
* `@ActiveProfiles(TestProfile.TEST)` 설정으로 테스트에 profile을 지정합니다. 환경별로 properties 파일을 관리하듯이 test도 반드시 별도의 properties 파일로 관리하는 것이 바람직합니다.
* 인터페이스나 enum 클래스를 통해서 profile을 관리합니다. 오타 실수를 줄일 수 있으며 전체적인 프로필이 몇 개 있는지 한 번에 확인할 수 있습니다.
* `@Transactional` 트랜잭션 어노테이션을 추가하면 테스트코드의 데이터베이스 정보가 자동으로 Rollback 됩니다. 베이스 클래스에 이 속성을 추가 해야지 실수 없이 진행할 수 있습니다.
* `@Transactional`을 추가하면 자연스럽게 데이터베이스 상태 의존적인 테스트를 자연스럽게 하지 않을 수 있게 됩니다.
* 통합 테스트 시 필요한 기능들을 `protected`로 제공해줄 수 있습니다. API 테스트를 주로 하게 되니 ObjectMapper 등을 제공해줄 수 있습니다. 유틸성 메서드들도 `protected`로 제공해주면 중복 코드 및 테스트 코드의 편의성이 높아집니다.
* 실제로 동작할 필요가 없으니 `@Ignore` 어노테이션을 추가합니다.

### Test Code
```java
public class MemberApiTest extends IntegrationTest {

    @Autowired
    private MemberSetup memberSetup;

    @Test
    public void 회원가입_성공() throws Exception {
        //given
        final Member member = MemberBuilder.build();
        final Email email = member.getEmail();
        final Name name = member.getName();
        final SignUpRequest dto = SignUpRequestBuilder.build(email, name);

        //when
        final ResultActions resultActions = requestSignUp(dto);

        //then
        resultActions
                .andExpect(status().isOk())
                .andExpect(jsonPath("email.value").value(email.getValue()))
                .andExpect(jsonPath("email.host").value(email.getHost()))
                .andExpect(jsonPath("email.id").value(email.getId()))
                .andExpect(jsonPath("name.first").value(name.getFirst()))
                .andExpect(jsonPath("name.middle").value(name.getMiddle()))
                .andExpect(jsonPath("name.last").value(name.getLast()))
                .andExpect(jsonPath("name.fullName").value(name.getFullName()))
        ;
    }

    @Test
    public void 회원조회() throws Exception {
        //given
        final Member member = memberSetup.save();

        //when
        final ResultActions resultActions = requestGetMember(member.getId());

        //then
        resultActions
                .andExpect(status().isOk())
                .andExpect(jsonPath("email.value").value(member.getEmail().getValue()))
                .andExpect(jsonPath("email.host").value(member.getEmail().getHost())
                .andExpect(jsonPath("email.id").value(member.getEmail().getId()))
                .andExpect(jsonPath("name.first").value(member.getName().getFirst()))
                .andExpect(jsonPath("name.middle").value(member.getName().getMiddle()))
                .andExpect(jsonPath("name.last").value(member.getName().getLast()))
                .andExpect(jsonPath("name.fullName").value(member.getName().getFullName()))
        ;
    }

    private ResultActions requestSignUp(SignUpRequest dto) throws Exception {
        return mvc.perform(post("/members")
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(objectMapper.writeValueAsString(dto)))
                .andDo(print());
    }
    ...
}
```
* `IntegrationTest` 클래스를 상속받습니다. 이 상속을 통해서 MemberApiTest에서 테스트를 위한 어노테이션이 생략되며 어떤 통합 테스트라도 항상 통일성을 가질 수 있습니다.
* `given`, `when`, `then` 키워드로 테스트 흐름을 알려줍니다. 다른 사람의 테스트 코드의 가독성이 높아지기 때문에 해당 키워드로 적절하게 표시하는 것을 권장합니다.
* 요청에 대한 메서드를 `requestSignUp(...)`으로 분리해서 재사용성을 높입니다. 해당 메서드로 valdate 실패하는 케이스도 작성합니다 `andDo(print())` 메서드를 추가해서 해당 요청에 대한 출력을 확인합니다. 디버깅에 매우 유용합니다.
* 모든 response에 대한 `andExpect`를 작성합니다. 간혹 `.andExpect(content().string(containsString("")))` 이런 테스트를 진행하는데 특정 문자열이 들어 있는지 없는지 확인하는 것보다 모
  * **response에 하나라도 빠지거나 변경되면 API 변경이 이루어진 것이고 그 변경에 맞게 테스트 코드도 변경되어야 합니다.**
* `회원 조회` 테스트 같은 경우 `memberSetup.save();` 메서드로 테스트전에 데이터베이스에 insert 합니다. 
  * 데이터베이스에 미리 있는 값을 검증하는 것은 데이터베이스 상태에 의존한 코드가 되며 누군가가 회원 정보를 변경하게 되면 테스트 코드가 실패하게 됩니다.
  * 테스트 전에 데이터를 insert하지 않는다면 테스트 코드 구동 전에 `.sql` 으로 미리 데이터베이스를 준비시킵니다 ApplicationRunner를 이용해서 데이터베이스를 준비시키 방법도 있습니다.
  * **중요한 것은 데이터베이스 상태에 너무 의존적인 테스트는 향후 로직의 문제가 없더라도 테스트가 실패하는 상황이 자주 만나게 됩니다.**

# 서비스 테스트

## 장점
* 진행하고자 하는 테스트에만 집중할 수 있습니다.
* 테스트 진행시 중요 관점이 아닌 것들은 Mocking 처리해서 외부 의존성들을 줄일 수 있습니다.
  * 예를 들어 주문 할인 로직이 제대로 동작하는지에 대한 테스트만 진행하지 이게 실제로 데이터베이스에 insert되는지는 해당 테스트의 관심사가 아닙니다.
* 테스트 속도가 빠릅니다.

## 단점
* 의존성 있는 객체를 Mocking 하기 때문에 문제가 완결된 테스트는 아닙니다.
* Mocking 하기가 귀찮습니다.
* Mocking 라이브러리에 대한 학습 비용이 발생합니다.

## Code

### MockTest
```java
@RunWith(MockitoJUnitRunner.class)
@ActiveProfiles(TestProfile.TEST)
@Ignore
public class MockTest {

}
```
* 주로 Service 영역을 테스트 합니다. 
* `MockitoJUnitRunner`을 통해서 Mock 테스트를 진행합니다.

### Test Code
```java
public class MemberSignUpServiceTest extends MockTest {

    @InjectMocks
    private MemberSignUpService memberSignUpService;

    @Mock
    private MemberRepository memberRepository;
    private Member member;

    @Before
    public void setUp() throws Exception {
        member = MemberBuilder.build();
    }

    @Test
    public void 회원가입_성공() {
        //given
        final Email email = member.getEmail();
        final Name name = member.getName();
        final SignUpRequest dto = SignUpRequestBuilder.build(email, name);

        given(memberRepository.existsByEmail(any())).willReturn(false);
        given(memberRepository.save(any())).willReturn(member);

        //when
        final Member signUpMember = memberSignUpService.doSignUp(dto);

        //then
        assertThat(signUpMember).isNotNull();
        assertThat(signUpMember.getEmail().getValue()).isEqualTo(member.getEmail().getValue());
        assertThat(signUpMember.getName().getFullName()).isEqualTo(member.getName().getFullName());
    }

    @Test(expected = EmailDuplicateException.class)
    public void 회원가입_이메일중복_경우() {
        //given
        final Email email = member.getEmail();
        final Name name = member.getName();
        final SignUpRequest dto = SignUpRequestBuilder.build(email, name);

        given(memberRepository.existsByEmail(any())).willReturn(true);

        //when
        memberSignUpService.doSignUp(dto);
    }
}
```
* `MockTest` 객체를 상속받아 테스트의 일관성을 갖습니다.
* `회원가입_성공` 테스트는 오직 회원 가입에대한 단위 테스트만 진행합니다.
  * `existsByEmail`을 모킹해서 해당 이메일이 중복되지 않았다는 가정을 합니다.
  * `then` 에서는 회원 객체가 해당 비지니스 요구사항에 맞게 생성됬는지를 검사합니다.
  * 실제 데이터베이스에 Insert 됐는지 여부는 해당 테스트의 관심사가 아닙니다.
* `회원가입_이메일중복_경우` 테스트는 회원가입시 이메일이 중복됬는지 여부를 확인합니다.
  * `existsByEmail`을 모킹해서 이메일이 중복됬다는 가정을 합니다.
  * `expected`으로 이메일이 중복되었을 경우 `EmailDuplicateException` 예외가 발생하는지 확인합니다.
  * 해당 이메일이 데이터베이스에 실제로 있어서 예외가 발생하는지는 관심사가 아닙니다. 작성한 코드가 제대로 동작 여부만이 해당 테스트의 관심사 입니다.
* 오직 테스트의 관심사만 테스트를 진행하기 때문에 예외 발생시 디버깅 작업도 명확해집니다.
* 외부 의존도가 낮기 때문에 테스트 하고자하는 부분만 명확하게 테스트가 가능합니다.
  * 이것은 단점이기도 합니다. 해당 테스트만 진행하지 외부 의존을 갖는 코드까지 테스트하지 않으니 실제 환경에서 제대로 동작하지 않을 가능성이 있습니다. 외부 의존에 대한 테스트는 통합 테스트에서 진행합니다.


# Mock API 테스트

## 장점
* Mock 테스트와 장점은 거의 같습니다.
* `WebApplication` 관련된 Bean들만 등록하기 때문에 통합 테스트보다 빠르게 테스트할 수 있습니다.
* 통합 테스트를 진행하기 어려운 테스트를 진행합니다.
  * 외부 API 같은 Rollback 처리가 힘들거나 불가능한 테스트를 주로 사용합니다.
  * 예를 들어 외부 결제 모듈 API를 콜하면 안 되는 케이스에서 주로 사용 할 수 있습니다.
  * 이런 문제는 통합 테스트에서 해당 객체를 Mock 객체로 변경해서 테스트를 변경해서 테스트할 수도 있습니다.

## 단점
* Mock 테스트와 단점은 거의 같습니다.
* 요청부터 응답까지 모든 테스트를 Mock기반으로 테스트하기 때문에 실제 환경에서는 제대로 동작하지 않을 가능성이 매우 큽니다.

## Code
```java
@WebMvcTest(MemberApi.class)
public class MemberMockApiTest extends MockApiTest {
    @MockBean private MemberSignUpService memberSignUpService;
    @MockBean private MemberHelperService memberHelperService;
    ...

    @Test
    public void 회원가입_유효하지않은_입력값() throws Exception {
        //given
        final Email email = Email.of("asdasd@d"); // 이메일 형식이 유효하지 않음
        final Name name = Name.builder().build();
        final SignUpRequest dto = SignUpRequestBuilder.build(email, name);
        final Member member = MemberBuilder.build();

        given(memberSignUpService.doSignUp(any())).willReturn(member);

        //when
        final ResultActions resultActions = requestSignUp(dto);

        //then
        resultActions
                .andExpect(status().isBadRequest())
        ;

    }
```
* `@WebMvcTest(MemberApi.class)` 어노테이션을 통해서 하고자 하는 `MemberApi`의 테스트를 진행합니다.
* `@MockBean` 으로 객체를 주입받아 Mocking 작업을 진행합니다.
* 테스트의 관심사는 오직 Request와 그에 따른 Response 입니다. 

# Repository Test

## 장점
* `Repository` 관련된 Bean들만 등록하기 때문에 통합 테스트에 비해서 빠릅니다.
* `Repository`에 대한 관심사만 갖기 때문에 테스트 범위가 작습니다.

## 단점
* 테스트 범위가 작기 때문에 실제 환경과 차이가 발생합니다. 

## Code

### RepositoryTest
```java
@RunWith(SpringRunner.class)
@DataJpaTest
@ActiveProfiles(TestProfile.TEST)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Ignore
public class RepositoryTest {
}
```
* `@DataJpaTest` 어노테이션을 통해서 `Repository`에 대한 Bean만 등록합니다.
* `@DataJpaTest`는 기본적으로 메모리 데이터베이스에 대한 테스트를 진행합니다. `@AutoConfigureTestDatabase` 어노테이션을 통해서 profile에 등록된 데이터베이스 정보로 대체할 수 있습니다.
* `JpaRepository`에서 기본적으로 기본적으로 재공해주는 `findById`, `findByAll`, `deleteById`등은 테스트를 하지 않습니다.
  * 기본적으로 `save()` null 제약 조건 등의 테스트는 진행해도 좋다고 생각합니다.
  * 주로 커스텀하게 작성한 쿼리 메서드, `@Query`으로 작성된 JPQL등의 커스텀하게 추가된 메서드를 테스트합니다.

### Test Code
```java
public class MemberRepositoryTest extends RepositoryTest {

    @Autowired
    private MemberRepository memberRepository;

    private Member saveMember;
    private Email email;

    @Before
    public void setUp() throws Exception {
        final String value = "cheese10yun@gmail.com";
        email = EmailBuilder.build(value);
        final Name name = NameBuilder.build();
        saveMember = memberRepository.save(MemberBuilder.build(email, name));
    }

    ...
    @Test
    public void existsByEmail_존재하는경우_true() {
        final boolean existsByEmail = memberRepository.existsByEmail(email);
        assertThat(existsByEmail).isTrue();
    }

    @Test
    public void existsByEmail_존재하지않은_경우_false() {
        final boolean existsByEmail = memberRepository.existsByEmail(Email.of("ehdgoanfrhkqortntksdls@asd.com"));
        assertThat(existsByEmail).isFalse();
    }
}
```
* `setUp()` 메서드를 통해서 Member를 데이터베이스에 insert 합니다.
  * `setUp()` 메서드는 메번 테스트 코드가 실행되기전에 실행됩니다. 즉 테스트 코드를 실행할 때마다 insert -> rollback이 자동으로 이루어집니다.
* 추가 작성한 쿼리메서드 `existsByEmail`을 테스트 진행합니다. 
  * 실제로 작성된 쿼리가 어떻게 출력되는지 `show-sql` 옵션을 통해서 확인 합니다. ORM은 SQL을 직접 작성하지 않으니 실제 쿼리가 어떻게 출력되는지 확인하는 습관을 반드시 가져야합니다.

# POJO 테스트

## 설명
각 엔티티(Embeddable, Entity, 일반 POJO, 모든 객체) 객체들의 기능이 풍부해야 합니다. 객체 본인의 책임을 충분히 다하지 않고 있으면 다른 영역으로 그 객체의 책임이 넘어 가게됩니다. 예를 들어 `Name` 객체가 `getFullName()` 메서드를 제공해주지 않는다면 `getFullName()` 메서드를 만족시키는 메서드들이 다른 계층에서 구현하게 되고 어느 계층에서 어떻게 사용되고 있는지 모르기 때문에 누군가는 중복코드를 만들게 됩니다.

객체지향에서 본인의 책임(기능)은 본인 스스로가 제공해야 합니다. 특히 엔티티 객체들은 가장 핵심 객체이고 이 객체를 사용하는 계층들이 다양하게 분포되기 때문에 반드시 테스트 코드를 작성해야합니다.

## 장점
* POJO 객체이므로 테스트하기 편합니다. 외부에서 주입 받을 의존성도 없고 Mocking할 대상도 없습니다.
* 엔티티 객체는 사용하는 계층이 많으므로 테스트의 효율성이 높습니다.

## 단점
* 단점은 없다고 생각합니다. POJO를 테스트 하므로 테스트 속도 및 난도가 낮지만 높은 안전성을 갖게 됩니다.

## Code

### Embeddable
```java
@Embeddable
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@ToString(of = {"first", "middle", "last"})
public class Name {

    @NotEmpty
    @Column(name = "first_name", length = 50)
    private String first;

    @Column(name = "middle_name", length = 50)
    private String middle;

    @NotEmpty
    @Column(name = "last_name", length = 50)
    private String last;

    @Builder
    public Name(final String first, final String middle, final String last) {
        this.first = first;
        this.middle = StringUtils.isEmpty(middle) ? null : middle;
        this.last = last;
    }

    public String getFullName() {
        if (this.middle == null) {
            return String.format("%s %s", this.first, this.last);
        }
        return String.format("%s %s %s", this.first, this.middle, this.last);
    }
}
```
* `Name` 객체는 `Member` 객체에서 사용하고 있습니다. 이처럼 Name 이라는 객체를 `Embeddable`으로 별도로 가지고 있으면 데이터의 응집력 재사용성이 높아집니다.
  * 예를 들어 주문 시 주문자 정보를 받아야 된다면 `Order` 라는 객체에도 동일하게 `Name` 객체를 사용하면 재사용성이 높아집니다.
* `Embeddable` 객체에서도 다른 객체와 마찬가지로 `Name` 관련된 기능을 충분히 제공해야 합니다. `getFullName()` 메서드 처럼 `first`, `last`, `middle`의 이름을 적절하게 조합해서 제공해줍니다.

### Test Code
```java
public class NameTest {

    @Test
    public void getFullName_isFullName_ReturnFullName() {
        final Name name = Name.builder()
                .first("first")
                .middle("middle")
                .last("last")
                .build();
        final String fullName = name.getFullName();
        assertThat(fullName, is("first middle last"));
    }

    @Test
    public void getFullName_WithoutMiddle_ReturnMiddleNameIsNull() {
        final Name name = Name.builder()
                .first("first")
                .middle("")
                .last("last")
                .build();
        final String fullName = name.getFullName();
        assertThat(fullName, is("first last"));
        assertThat(name.getMiddle(), is(nullValue()));
    }

    @Test
    public void getFullName_MiddleNameIsNull_ReturnMiddleNameIsNull() {
        final Name name = Name.builder()
                .first("first")
                .middle("")
                .last("last")
                .build();
        final String fullName = name.getFullName();
        assertThat(fullName, is("first last"));
        assertThat(name.getMiddle(), is(nullValue()));
    }

}
```
* `entity`, `Embeddable` 객체 등의 객체들도 반드시 테스트 코드를 작성해야합니다.
* middle값이 비어있을 경우 null로 잘 들어가는지, `getFullName()` 메서드가 잘 동작하는지 테스트합니다.

# 마무리
각자의 프로젝트 환경이 다르기 때문에 어느 한 방법이 Best Practice라고 말하는 게 어렵습니다. 그래도 테스트 코드의 중요성은 이미 많은 개발자가 공감하고 있는 만큼 보다 효율적인 테스트 코드 환경을 구축하려는 노력이 많이 선행되어야 한다고 생각합니다.


---

