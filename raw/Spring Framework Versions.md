---
title: "Spring Framework Versions"
source: "https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-7.0-Release-Notes"
author:
published:
created: 2026-04-18
description: "Spring Framework. Contribute to spring-projects/spring-framework development by creating an account on GitHub."
tags:
  - "clippings"
---
## Upgrading From Spring Framework 6.2

### Baseline Upgrades

Spring Framework 7.0 retains a JDK 17 baseline while at the same time recommending JDK 25 as the latest LTS release. It also introduces a Jakarta EE 11 baseline and embraces Kotlin 2.2 as well as GraalVM 25.

Specifically, this new generation raises its minimum requirements for the following:

- Servlet 6.1 (Tomcat 11.0, Jetty 12.1)
- JPA 3.2 (Hibernate ORM 7.1/7.2)
- Bean Validation 3.1 (Hibernate Validator 9.0/9.1)
- GraalVM 25 with the [new "exact reachability metadata" format](https://www.graalvm.org/latest/reference-manual/native-image/metadata/)
- Netty 4.2 (see [#34996](https://github.com/spring-projects/spring-framework/pull/34996))
- Kotlin 2.2 (see [#33629](https://github.com/spring-projects/spring-framework/issues/33629))
- JUnit 6

### Removed APIs

#### Spring JCL has been removed

The `spring-jcl` module has been removed in favor of [Apache Commons Logging](https://github.com/apache/commons-logging) 1.3.0. This change should be transparent for most applications, as `spring-jcl` was a transitive dependency and the logging API calls should not change. See [#32459](https://github.com/spring-projects/spring-framework/issues/32459) for more details.

#### Removed support for javax.annotation and javax.inject annotations

Annotations in the `javax.annotation` and `javax.inject` packages are no longer supported. This includes annotations such as `@javax.annotation.Resource`,`@javax.annotation.PostConstruct`, `@javax.inject.Inject`, etc. If your application still uses annotations from those packages, you will need to migrate to their equivalents in the `jakarta.annotation` and `jakarta.inject` packages.

#### Deprecated path mapping options removed

Several path mapping options have been marked for removal since 6.0. They are now removed completely. This includes:

- `suffixPatternMatch` / `registeredSuffixPatternMatch` for annotated controller methods
- `trailingSlashMatch` for extensions of `AbstractHandlerMapping`
- `favorPathExtension` / `ignoreUnknownPathExtensions` and underlying `PathExtensionContentNegotiationStrategy` and `ServletPathExtensionContentNegotiationStrategy` for content negotiation, configurable through `ContentNegotiationManagerFactoryBean` and in the MVC Java config
- `matchOptionalTrailingSeparator` in `PathPatternParser`

#### Undertow support removed

The Undertow project currently does not support Servlet 6.1, which is a baseline requirement for this Spring Framework generation. As a result, we have dropped Undertow-specific classes for WebSocket support and low-level HTTP support for WebFlux applications.

Since Spring MVC applications can be deployed on any Servlet 6.1 compliant server, Undertow users will be able to leverage our standard Servlet support once a version of Undertow has been released which is compatible with Servlet 6.1.

#### Other removals

Many other APIs and features were removed as part of [#33809](https://github.com/spring-projects/spring-framework/issues/33809), including:

- `ListenableFuture` in favor of `CompletableFuture`
- WebJars support with `org.webjars:webjars-locator-core` in favor of `org.webjars:webjars-locator-lite`
- OkHttp3 support
- `Theme` support

The `RequestContext#jstPresent` protected static field has been renamed to `JSTL_PRESENT` as part of [#35525](https://github.com/spring-projects/spring-framework/issues/35525).

The `HttpComponentsClientHttpRequestFactory#setConnectTimeout` methods have been removed as part of [#35748](https://github.com/spring-projects/spring-framework/issues/35748).

`JdbcOperations.queryForObject(sql: String, args: Array<out Any>)` and `JdbcOperations.queryForList(sql: String, args: Array<out Any>)` Kotlin extensions have been replaced by variants using a vararg parameter instead of the array one, to align with the Java API as part of [#35846](https://github.com/spring-projects/spring-framework/issues/35846).

### Breaking Changes

#### HttpHeaders changes

The `HttpHeaders` API has been revisited in 7.0. This class no longer extends the `MultiValueMap` contract. Underlying servers treat headers more like a collection of pairs, and many map-like operations do not behave or perform well, because headers are case-insensitive in the first place. We therefore removed several methods as a result and introduced fallbacks as immediately `@Deprecated`, like `HttpHeaders#asMultiValueMap`. Please consider other methods as much as possible. See [#33913](https://github.com/spring-projects/spring-framework/issues/33913) for more details.

#### SpringExtension extension context scope

The `SpringExtension`, which integrates the Spring TestContext Framework into JUnit Jupiter, now uses a test-method scoped `ExtensionContext` (see [#35697](https://github.com/spring-projects/spring-framework/issues/35697)). Although this change allows for consistent dependency injection semantics within `@Nested` test class hierarchies, it may constitute a breaking change for custom `TestExecutionListener` implementations.

If you discover that Spring-related integration tests in `@Nested` test class hierarchies start to fail after an upgrade to Spring Framework 7.0, you may need to annotate the top-level class in such hierarchies with `@SpringExtensionConfig(useTestClassScopedExtensionContext = true)`. As an alternative, as of Spring Framework 7.0.7, you may change the global default for this behavior by setting the `spring.test.extension.context.scope` property to `test_class` via a JVM system property, the `SpringProperties` mechanism, or a JUnit Platform configuration parameter. See the [@SpringExtensionConfig](https://docs.spring.io/spring-framework/reference/7.0-SNAPSHOT/testing/annotations/integration-junit-jupiter.html#integration-testing-annotations-springextensionconfig) documentation for details.

If you have developed a custom `TestExecutionListener` that overrides `prepareTestInstance(TestContext)` and that listener no longer works correctly with Spring Framework 7.0, you might need to modify the listener's implementation to look up the *current* test class via `testContext.getTestInstance().getClass()` instead of `testContext.getTestClass()`. See the updated [Javadoc](https://docs.spring.io/spring-framework/docs/7.0.0/javadoc-api/org/springframework/test/context/TestExecutionListener.html#prepareTestInstance\(org.springframework.test.context.TestContext\)) for details.

### Deprecations

- `RestTemplate` was previously declared as "feature complete". As of Spring Framework 7.0, we have deprecated this type in our reference documentation, and we will mark it as officially `@Deprecated` in Spring Framework 7.1. See ["the state of HTTP clients" blog post](https://spring.io/blog/2025/09/30/the-state-of-http-clients-in-spring) for more details.
- The `<mvc:*` XML configuration namespace for Spring MVC is now deprecated in favor of the Java configuration variant. There are no plans yet for removing it completely, but XML configuration will not be updated to follow the Java configuration model. Other namespaces (like `<bean>`) are NOT deprecated.
- The Kotlin team has shared their intention to remove JSR 223 support in a future Kotlin 2.x release. As a result, the templating support for Kotlin scripts in Spring has been deprecated.
- JUnit 4 support in the Spring TestContext Framework is now deprecated in favor of the [SpringExtension](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/support-classes.html#testcontext-junit-jupiter-extension) for [JUnit Jupiter](https://junit.org/junit5/docs/current/user-guide/#writing-tests). Deprecated classes include the `SpringRunner`, `SpringClassRule`, `SpringMethodRule`, `AbstractJUnit4SpringContextTests`, `AbstractTransactionalJUnit4SpringContextTests`, and related support classes.
- Jackson 2.x support has been deprecated in favor of Jackson 3.x (see [#33798](https://github.com/spring-projects/spring-framework/issues/33798)).
- The use of `PathMatcher` in Spring MVC is now deprecated (see [#34018](https://github.com/spring-projects/spring-framework/issues/34018)).
- The `HandlerMappingIntrospector` SPI (for alignment of Spring Security and Spring MVC path matching) is deprecated (see [#34019](https://github.com/spring-projects/spring-framework/issues/34019) and [spring-security/16886](https://github.com/spring-projects/spring-security/issues/16886)).
- We [updated our HttpStatus class](https://github.com/spring-projects/spring-framework/issues/32870) to better align with the latest RFC9110. This mostly materializes with new HTTP statuses and a few deprecations with immediate replacements.
- The `org.springframework.web.servlet.view.document` and `org.springframework.web.servlet.view.feed` and all their types have been deprecated. The `*View` classes for XLS, RSS and PDF support will be removed in a future version. Instead, such types should be shipped independently from Spring Framework in libraries: this will provide broader and more flexible support. As an alternative, applications can use such libraries directly and perform the rendering phase in web handlers.
- The `<lang:*` XML configuration namespace is now deprecated, see [#35719](https://github.com/spring-projects/spring-framework/issues/35719) for more details.
- The BeanShell scripting support is now deprecated since it is not actively maintained anymore.

### Null Safety

Spring nullness annotations with JSR 305 semantics are deprecated in favor of [JSpecify annotations](https://jspecify.dev/docs/user-guide/). The Spring Framework codebase has been migrated to Specify and now specifies the nullness of array/vararg elements and generic types. You can find more details in [this dedicated section of the reference documentation](https://docs.spring.io/spring-framework/reference/7.0.0/core/null-safety.html) and in the blog post [Null-safe applications with Spring Boot 4](https://spring.io/blog/2025/11/12/null-safe-applications-with-spring-boot-4).

Spring Framework Kotlin APIs nullability may have changed, requiring code changes in Kotlin projects consuming them due to:

- Spring Framework Java API nullability differences
- Differences between JSR 305 and JSpecify interpretation by Kotlin
- Kotlin extensions nullability refinements to align more closely with Java (for example in `JdbcOperations` [#35846](https://github.com/spring-projects/spring-framework/issues/35846) or `RestOperations` [#35852](https://github.com/spring-projects/spring-framework/issues/35852) ones)

Java developers may need refinements when migrating from previous versions due to `MethodParameter#isOptional` behaving slightly differently due to the removal of JSR 305 dedicated support, as the pragmatic check on any `@Nullable` annotations at parameter level now only check the local annotations, not the inherited ones.

### Servlet 6.1 and WebSocket 2.2

Spring Framework 7.0 adopted Jakarta Servlet 6.1 and WebSocket 2.2 as new baselines for web applications. In practice, this means that applications should be deployed on recent Servlet containers like Tomcat 11+ and Jetty 12.1+.

We also took this opportunity to update our HTTP mock support with `MockHttpServletRequest` / `MockHttpServletResponse`, better aligning with the behavior described in the Servlet API. This is especially relevant when using `null` names and values in HTTP headers.

### JPA 3.2 and Hibernate ORM 7.1/7.2

JPA 3.2 introduces a new arrangement for dependency injection: An `EntityManagerFactory` as well as its shared `EntityManager` reference can be generally injected via `@Inject` / `@Autowired` now, including qualifier support for selecting a specific persistence unit. In a typical Spring setup, such a default or qualified `EntityManager` reference is provided by `LocalContainerEntityManagerFactoryBean` itself; there is no need for a separate `SharedEntityManagerBean` definition anymore.

Spring Framework 7.0 also embraces Hibernate ORM 7.1/7.2 as a JPA provider, with the native Hibernate support formerly living in `org.springframework.orm.hibernate5` having migrated to the `orm.jpa.hibernate` package. Note that only the capabilities that make sense in addition to JPA itself are being continued: `LocalSessionFactoryBean/Builder`, `HibernateTransactionManager`, `SpringBeanContainer`, `SpringSessionContext`. This serves as an alternative to standard JPA bootstrapping and is also able to support `SessionFactory#getCurrentSession()` based data access code.

### Persistence unit management for JPA 3.2/4.0

For a warning-free experience with JPA 3.2 and forward compatibility with JPA 4.0, Spring's `MutablePersistenceUnitInfo` is decoupled from the standard `PersistenceUnitInfo` interface itself now. `MutablePersistenceUnitInfo` was originally designed as the argument type for `PersistenceUnitPostProcessor` and now exclusively serves that purpose; it cannot be assigned to `jakarta.persistence.spi.PersistenceUnitInfo` since it does not implement that interface directly anymore.

For any custom bootstrapping purposes, use the newly public `SpringPersistenceUnitInfo` class instead, adapting it to `jakarta.persistence.spi.PersistenceUnitInfo` through `SpringPersistenceUnitInfo#asStandardPersistenceUnitInfo()` - which automatically adapts to the JPA 3.2/4.0 API as encountered at runtime. We aim to provide early support for JPA 4.0 providers in Spring Framework 7.1, without any changes to your Spring configuration.

### JMS destination handling

Along with the introduction of `JmsClient` (see below), we changed the default `DestinationResolver` to the new `SimpleDestinationResolver` which caches `Session` -resolved `Queue` and `Topic` instances. This also applies to `JmsTemplate` and listener containers by default now. If you need to enforce fresh resolution on every call (even if this should not be necessary with common JMS brokers), please explicitly configure `DynamicDestinationResolver` instead.

### Jackson 3.x support

As of [#33798](https://github.com/spring-projects/spring-framework/issues/33798), we default to supporting Jackson 3.x in our entire stack, falling back to Jackson 2.x. Support for the Jackson 2.x generation has been deprecated in Spring Framework, and our current plan is to disable its auto-detection in 7.1 and remove its support entirely in 7.2.

Jackson 3.x uses a new `tools.jackson` package, which differs from the traditional `com.fasterxml.jackson` package. Classes from the "jackson-annotation" artifact (such as `@JsonView` and `@JsonTypeInfo`) remain in the `com.fasterxml.jackson` package for easier upgrading.

There is no Jackson 3.x equivalent for `Jackson2ObjectMapperBuilder`. We now recommend using Jackson's `JsonMapper.builder()`, `CBORMapper.builder()`, and others as replacements.

The blog post [Introducing Jackson 3 support in Spring](https://spring.io/blog/2025/10/07/introducing-jackson-3-support-in-spring) provides more details on the changes, the migration path and the impact portfolio wide.

### kotlinx.serialization support

Over the years, the combined usage of Kotlin Serialization alongside another general purpose JSON library (typically Jackson) has triggered the creation of a lot of bug reports in Spring Framework. In order to prevent those side effects, [#35761](https://github.com/spring-projects/spring-framework/issues/35761) changes the default behavior of Kotlin Serialization converters/codecs to perform an additional check invoking [`KotlinDetector#hasSerializableAnnotation`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/KotlinDetector.html#hasSerializableAnnotation\(org.springframework.core.ResolvableType\)) to decide if the related type should be processed or not. New constructors allowing to specify a custom predicate are also introduced.

### Google Gson support in WebFlux

We added new codecs for JSON (de)serialization in WebFlux, namely `GsonEncoder` and `GsonDecoder`. Because the `Gson` library itself does not support decoding JSON in a non-blocking fashion, the `GsonDecoder` does not support decoding to `Flux<*>` types. The encoder does support NDJSON for streaming when serializing to JSON.

### GraalVM Native Applications

Spring Framework 7.0 switches to the unified reachability metadata format, being adopted by the GraalVM community. Applications contributing `RuntimeHints` should apply the following changes.

The resource hints syntax has changed from a `java.util.regex.Pattern` format to a ["glob pattern" format](https://www.graalvm.org/jdk23/reference-manual/native-image/metadata/#resource-metadata-in-json). In practice, applications might need to change their resource hint registrations if they were using wildcards. Previously, `"/files/*.ext"` matched both `"/files/a.ext"` and `"/files/folder/b.txt"`. The new behavior matches only the former. To match both, you will need to use `"/files/**/*.ext"` instead. Registration of "excludes" has been removed completely.

Registering a reflection hint for a type now implies methods, constructors, and fields introspection. As a result, `ExecutableMode.INTROSPECT` and all `MemberCategory` values except `MemberCategory.INVOKE_*` have been deprecated. They have no replacement, as registering a type hint is enough.

In practice, it is enough to replace this:

```
hints.reflection().registerType(MyType.class, MemberCategory.DECLARED_FIELDS);
```

With this:

```
hints.reflection().registerType(MyType.class);
```

As for `MemberCategory.PUBLIC_FIELDS` and `MemberCategory.DECLARED_FIELDS`, those constants were replaced by `INVOKE_PUBLIC_FIELDS` and `INVOKE_DECLARED_FIELDS` to make their original intent clearer and to align with the rest of the API. Note, if you were using those values for reflection only, you can safely remove those hints in favor of a simple type hint.

More details on the related changes can be found in [#33847](https://github.com/spring-projects/spring-framework/issues/33847).

### CORS Pre-Flight requests behavior change

As of [#31839](https://github.com/spring-projects/spring-framework/issues/31839), CORS Pre-Flight requests are not rejected anymore when the CORS configuration is empty.

### WebClient behavior changes for Reactor client

As of [#34850](https://github.com/spring-projects/spring-framework/pull/34850), the Reactor client (when used with `WebClient`) will automatically opt-in for the system properties for proxy configuration, `https.proxyHost` and `https.proxyPort`.

## New and Noteworthy

### Null Safety

The Spring Framework codebase is annotated with [JSpecify](https://jspecify.dev/docs/start-here/) annotations to declare the nullness of APIs, fields, and related type usage. JSpecify provides significant enhancements compared to the previous JSR 305 based arrangement, such as properly defined specifications, a canonical dependency with no split-package issue, better tooling, better Kotlin integration, and the capability to specify nullness for generic types, arrays, and vararg elements. Using JSpecify annotations is also recommended for Spring-based applications. For more on this, [check out the revisited "Null Safety" section of our reference documentation](https://docs.spring.io/spring-framework/reference/7.0.0/core/null-safety.html).

### Class-File API usage for Java 24+ apps

Spring Framework reads class bytecode to collect metadata about the application code. Historically we have used a reduced ASM fork for this purpose, through the `MetadataReaderFactory` and `MetadataReader` types in the `org.springframework.core.type.classreading` package. Although Spring applications typically have no direct exposure to this API, this is especially useful when parsing `@Configuration` classes or looking for annotations on application code.

Java 24 introduced a new [Class-File API with JEP 484](https://openjdk.org/jeps/484) for reading and writing classes as Java bytecode. Spring Framework 7.0 adopts this feature for Java 24+ applications with a new `ClassFileMetadataReader` implementation in `spring-core`. This should be completely transparent for applications.

### Programmatic Bean Registration

Applications should never attempt to register several beans within a single `@Bean` method in a `@Configuration` class. Similarly, `@Bean` methods should declare the most concrete type as their return type. Those requirements often get in the way of more flexible bean registrations when more logic is required, or when multiple registration is needed.

This major version introduces a new programmatic bean registration mechanism with the `BeanRegistrar` contract that will help with such use cases. See the new ["Programmatic Bean Registration" section in the reference documentation](https://docs.spring.io/spring-framework/reference/7.0.0/core/beans/java/programmatic-bean-registration.html).

### Optional support with null-safe and Elvis operators in SpEL expressions

The `java.util.Optional` type is now better supported in SpEL expressions. Not only can you now call [null-safe operations on `Optional` types](https://docs.spring.io/spring-framework/reference/core/expressions/language-ref/operator-safe-navigation.html#expressions-operator-safe-navigation-optional) with transparent unwrapping, but you can also use [the Elvis operator](https://docs.spring.io/spring-framework/reference/core/expressions/language-ref/operator-elvis.html) to automatically unwrap an `Optional`.

### Consistent proxy type defaulting and consistent opting out for specific beans

As of 7.0, global proxy type defaulting to CGLIB - like in Spring Boot - is consistently applied to all proxy processors (including `@Async` and co). For custom purposes, a bean of type `ProxyConfig` can be declared under the name `AutoProxyUtils.DEFAULT_PROXY_CONFIG_BEAN_NAME`, containing default proxy settings for the current application context.

Opting out is possible for individual beans through the new `@Proxyable` annotation, for example through `@Proxyable(INTERFACES)` in case of a CGLIB target-class default or also through `@Proxyable(TARGET_CLASS)` in case of the regular default (JDK dynamic proxy with interfaces), declared at the level of a `@Bean` method or a scanned `@Component` class. As a bonus, bean-specific proxy interfaces can be suggested through `@Proxyable(interfaces=MyService.class)` which also overrides any context-wide default proxy type.

### Resilience features: RetryTemplate, @Retryable, @ConcurrencyLimit

The Spring team has been working on the [Spring Retry project](https://github.com/spring-projects/spring-retry) for a very long time, and we decided that it was time to trim unnecessary features, revisit some of its APIs, and merge the resulting work into the `spring-core` module of Spring Framework. This new foundational retry support is located in the `org.springframework.core.retry` package, which includes `RetryTemplate`, `RetryPolicy`, and supporting classes.

Aligned with `core.retry`, there is also `@Retryable` annotation support in the `spring-context` module, accompanied by a `@ConcurrencyLimit` annotation based on Spring's concurrency throttling support. Both of those can be conveniently enabled through `@EnableResilientMethods` on a `@Configuration` class. Check out the new [resilience chapter](https://docs.spring.io/spring/reference/core/resilience.html) in the reference documentation as well as the related [blog post](https://spring.io/blog/2025/09/09/core-spring-resilience-features).

Note that `@Retryable` (including its customization through annotation attributes) automatically adapts to reactive methods with a reactive return type, decorating the pipeline with Reactor’s retry capabilities. Regular imperative methods will be invoked via a `RetryTemplate` with a corresponding `RetryPolicy`.

### Embracing JPA 3.2 and Hibernate StatelessSession

`LocalEntityManagerFactoryBean` accepts a JPA 3.2 `PersistenceConfiguration` object now, for richer standalone bootstrapping without `persistence.xml`. `LocalContainerEntityManagerFactoryBean` accepts `PersistenceConfiguration` as well, merging it into its default persistence unit. This specifically supports the `HibernatePersistenceConfiguration` subclass as well, detecting Hibernate ORM 7.1's scanning configuration options.

`LocalSessionFactoryBean` exposes transactional `Session` and `StatelessSession` proxy references for dependency injection, along the lines of the JPA 3.2 arrangement for `EntityManager` injection with `@Inject` / `@Autowired`. We recommend using Hibernate ORM 7.2 (rather than 7.1) for `StatelessSession` support since we can derive a transactional `StatelessSession` from the current transactional `Session` there.

### Introducing JmsClient and revisiting JdbcClient

After `JdbcClient` and `RestClient` in 6.1, Spring Framework 7.0 introduces a `JmsClient` now: with common send and receive operations against a JMS destination, dealing with Spring's common `Message` or with payload values, throwing `MessagingException` in alignment with the `spring-messaging` module. This is effectively an alternative to `JmsMessagingTemplate`, also delegating to Spring's `JmsTemplate` for performing actual operations.

`JmsClient` provides reusable operation handles which can be configured with custom QoS settings. With a similar design, `JdbcClient` conveniently provides statement-level settings such as fetch size, max rows, and query timeout now.

### API Versioning

Spring MVC and WebFlux now provide first class support for API versioning. On the server side, you can map requests to controller methods and route requests to functional endpoints by taking into account the API version of the request. You can configure how the API version is resolved, parsed, and validated, mark versions as deprecated in order to notify clients, and more. On the client side, there is support for setting the API version on requests in `RestClient`, `WebClient`, and also with HTTP interface clients. On the testing side, there is support in `WebTestClient` as well as in MockMvc.

For more details see the reference docs for [Spring MVC](https://docs.spring.io/spring-framework/reference/web/webmvc-versioning.html) and [WebFlux](https://docs.spring.io/spring-framework/reference/web/webflux-versioning.html), and the blog post [API Versioning in Spring](https://spring.io/blog/2025/09/16/api-versioning-in-spring).

### HTTP Interface Client configuration

There is now dedicated support for HTTP interface client configuration that can significantly simplify the required configuration especially when you work with many HTTP interfaces and target hosts. This is done through `@ImportHttpServices` declarations that let applications focus on identifying HTTP Services by group, and customizing the client for each group, while the framework transparently creates a registry of client proxies, and declares each proxy as a bean. For example:

```
@Configuration(proxyBeanMethods = false)
@ImportHttpServices(group = "weather", types = {FreeWeather.class, CommercialWeather.class})
@ImportHttpServices(group = "user", types = {UserServiceInternal.class, UserServiceOfficial.class})
static class HttpServicesConfiguration extends AbstractHttpServiceRegistrar {

    @Bean
    public RestClientHttpServiceGroupConfigurer groupConfigurer() {
        return groups -> groups.filterByName("weather", "user")
            .forEachClient((group, builder) -> builder.defaultHeader("User-Agent", "My-Application"));
    }

}
```

For more details, see the [reference documentation](https://docs.spring.io/spring-framework/reference/integration/rest-clients.html#rest-http-service-client-group-config), and the blog post [HTTP Service Client Enhancements](https://spring.io/blog/2025/09/23/http-service-client-enhancements).

### HTTP Interface Client support for InputStream and OutputStream

It is now possible to provide an `OutputStream` for the request body through an `StreamingHttpOutputMessage.Body` method parameter, and also to consume the response through an `InputStream` or `ResponseEntity<InputStream>` return value.

### PathPattern matching improved

As of Spring Framework 7.0, the legacy `AntPathMatcher` variant for matching HTTP request mappings is being deprecated. We started this migration back in 5.0, introducing the `PathPattern` option, then making it the default.

Community members reached out and shared that there was one last missing feature that was preventing their upgrade: the ability to match many path segments at the beginning of the path (think, `"/**/pages/index.html"`). This is now supported, and we described more thoroughly [the allowed patterns in the reference documentation](https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-controller/ann-requestmapping.html#mvc-ann-requestmapping-uri-templates).

### Easier message converters configuration with HttpMessageConverters

Similar to the codecs configuration on the reactive side with `WebClient` and WebFlux server applications, we have introduced the new `HttpMessageConverters` class for an easier and centralized experience when it comes to classpath detection of HTTP message converters and their global setup.

In practice, you will encounter them on new configuration methods. For example, [`WebMvcConfigurer#configureMessageConverters`](https://docs.spring.io/spring-framework/docs/7.0.0/javadoc-api/org/springframework/web/servlet/config/annotation/WebMvcConfigurer.html#configureMessageConverters\(org.springframework.http.converter.HttpMessageConverters.ServerBuilder\)) will let you configure a custom JSON converter like this:

```
@Configuration
public class WebConfiguration implements WebMvcConfigurer {

    @Override
    public void configureMessageConverters(HttpMessageConverters.ServerBuilder builder) {
        JsonMapper jsonMapper = JsonMapper.builder()
                .findAndAddModules()
                .enable(SerializationFeature.INDENT_OUTPUT)
                .defaultDateFormat(new SimpleDateFormat("yyyy-MM-dd"))
                .build();
        builder.jsonMessageConverter(new JacksonJsonHttpMessageConverter(jsonMapper));
    }
}
```

Similar methods exist for `RestClient` and RestTemplate.

### Pausing of Test Application Contexts

As of Spring Framework 7.0, an application context stored in the test context cache may be *paused* when it is no longer actively in use and automatically *restarted* the next time it is needed. This ensures that background processes within the context are not actively running while the context is not used by tests.

Prior to Spring Framework 7.0.3, unused application contexts for tests were always paused immediately. Beginning with Spring Framework 7.0.3, application contexts are only paused if the next context retrieved from the context cache is a different context. That is the default pause behavior; however, you can revert to always pausing unused contexts by setting the `spring.test.context.cache.pause` property to `always`. Similarly, you can completely disable the pausing feature by setting the `spring.test.context.cache.pause` property to `never`. This property can be set via a JVM system property or the `SpringProperties` mechanism.

For more details, see the [reference documentation](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/ctx-management/context-pausing.html).

### Improved Dependency Injection in @Nested Test Class Hierarchies

The `SpringExtension` for JUnit Jupiter now supports dependency injection into test class constructors and fields in `@⁠Nested` test class hierarchies using the same `ApplicationContext` that is used to perform dependency injection into lifecycle and test methods such `@⁠BeforeEach`, `@⁠AfterEach`, `@⁠Test`, etc. (see [#35697](https://github.com/spring-projects/spring-framework/issues/35697)). This provides a more consistent programming model for `@Nested` tests. However, if you encounter issues after upgrading to Spring Framework 7.0, see [SpringExtension extension context scope](#springextension-extension-context-scope) for details on potentially breaking changes.

### Bean Overrides for non-singleton Beans

Bean Overrides such as `@MockitoBean`, `@MockitoSpyBean` and `@TestBean` can now be applied to non-singleton beans such as `prototype` or custom scoped beans.

### RestTestClient

This is a popular enhancement request coming from the community: providing a non-reactive variant for `WebTestClient`. Developers like the way `WebTestClient` can test live servers and mock setups, with a fluent API and nice assertions.

This is now done with the new `RestTestClient`; you can bind it to a live server, an MVC `@Controller` or the application context. See the new [`RestTestClient` documentation section](https://docs.spring.io/spring-framework/reference/testing/resttestclient.html#page-title) for more.

### Context Propagation for Kotlin Coroutines

Kotlin developers shared that while context propagation for traces worked well for blocking and reactive applications, this information was not available during the execution of a Kotlin Coroutine. This new release introduces [automatic context propagation](https://docs.spring.io/spring-framework/reference/languages/kotlin/coroutines.html#coroutines.propagation) for Coroutines via the [`PropagationContextElement`](https://docs.spring.io/spring-framework/reference/languages/kotlin/coroutines.html#coroutines.propagation) operator.