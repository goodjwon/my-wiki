---
title: 자바 직렬화의 보안 위험 — 역직렬화 RCE와 방어 패턴
type: concept
tags: [java, security, serialization, deserialization, effective-java, rce, jep290]
sources: []
created: 2026-07-04
updated: 2026-07-04
---

# 자바 직렬화의 보안 위험 — 역직렬화 RCE와 방어 패턴

## 개요

자바 직렬화(`ObjectOutputStream`/`ObjectInputStream`)는 객체를 바이트 스트림으로 저장·전송하는 언어 기본 기능입니다. 편리해 보이지만, **신뢰할 수 없는 바이트 스트림을 역직렬화하는 순간 공격자가 서버에서 임의 코드를 실행(RCE, Remote Code Execution)할 수 있는** 자바 역사상 최악급 공격면이 열립니다. 이 페이지는 *Effective Java* 12장([[lecture-effective-java-ch12]])의 Item 85·88·90을 방어 관점에서 정리하고, 2015년 Apache Commons Collections 사건을 개념 수준으로 다룹니다.

이 문서는 **방어 목적 교육 자료**입니다. 공격 재현 코드(payload)는 싣지 않으며, 위험이 왜 생기는지의 원리와 그것을 막는 코드 패턴에 초점을 둡니다.

> **비유 — 역직렬화는 "봉투를 열자마자 실행되는 우편물"입니다.**
>
> 보통의 데이터 파싱은 편지를 읽고 내용을 해석하는 일입니다. 반면 자바 역직렬화는 봉투에 적힌 지시대로 받는 쪽이 곧바로 객체를 조립하고, 그 과정에서 봉투가 지정한 클래스의 `readObject`가 자동으로 돌아갑니다. 그래서 봉투 안에 악성 클래스 조합이 들어 있으면, 내용을 검토하기도 전에 그 지시가 실행됩니다.

## Item 85 — 자바 직렬화의 대안을 찾으라

### readObject는 "보이지 않는 생성자"입니다

일반 객체는 생성자를 통해서만 만들어지고, 생성자 안의 검증 로직이 불변식을 지킵니다. 그런데 역직렬화는 이 생성자를 **우회**합니다. `readObject`가 사실상 또 하나의 public 생성자 역할을 하지만, 개발자 눈에 잘 보이지 않고 아무 검증 없이 필드를 스트림 값으로 채웁니다. 더 위험한 점은, 역직렬화가 스트림에 적힌 **임의 클래스**의 `readObject`를 연쇄로 호출한다는 것입니다. 클래스패스에 어떤 라이브러리가 있느냐에 따라, 개발자가 의도한 적 없는 코드 경로가 실행될 수 있습니다.

### 위험 3가지

| 위험 | 설명 |
|------|------|
| **보안 (가장 큼)** | 신뢰할 수 없는 스트림 역직렬화가 RCE로 이어짐. 공격자가 만든 바이트 스트림 하나로 서버 장악 가능 |
| **역호환** | 클래스 구조가 조금만 바뀌어도 깨짐. `serialVersionUID` 관리 부담이 영구적 |
| **성능·크기** | 바이너리인데도 메타데이터가 과다해 JSON보다 큰 경우가 흔함 |

### 핵심 원칙

**신뢰할 수 없는 출처의 바이트 스트림은 절대 역직렬화하지 않습니다.** 새 시스템이라면 자바 직렬화 자체를 쓰지 않고 JSON·Protocol Buffers 같은 크로스 플랫폼 데이터 형식으로 우회하는 것이 근본 해법입니다. 어쩔 수 없이 써야 한다면 뒤의 `ObjectInputFilter`(JEP 290)와 Item 90 프록시 패턴으로 겹겹이 방어합니다.

## Apache Commons Collections gadget chain 사건 (2015)

### 무슨 일이 있었나

2015년 1월 AppSecCali 컨퍼런스에서 Gabriel Lawrence와 Chris Frohoff가 "Marshalling Pickles — how deserializing objects will ruin your day" 발표로 문제를 공론화했습니다. 핵심은 **자바 직렬화를 받아들이는 애플리케이션이면, 클래스패스에 있는 평범한 라이브러리 조합만으로 RCE가 가능하다**는 것이었습니다. 같은 해 11월 FoxGlove Security의 후속 분석으로 파급력이 폭발했고, IBM WebSphere·Oracle WebLogic·Red Hat JBoss·Jenkins 등 수많은 엔터프라이즈 제품이 영향을 받았습니다.

### gadget chain이란 (개념 수준)

"가젯 체인(gadget chain)"은 각각은 무해해 보이는 클래스들의 메서드를, 역직렬화가 부르는 순서를 이용해 사슬처럼 엮어 결국 임의 명령 실행에 도달시키는 기법입니다. Commons Collections 사례의 개념 흐름은 다음과 같습니다.

| 단계 | 무엇이 일어나는가 |
|------|------------------|
| 진입점 | JDK 내부 클래스의 `readObject`가 역직렬화된 맵의 조회 메서드를 호출 |
| 연결 고리 | 조회를 가로채도록 구성된 Commons Collections의 지연 맵·변환기(Transformer) 조합이 발동 |
| 최종 도달 | 리플렉션 기반 변환기가 런타임 명령 실행 API를 호출 → 임의 코드 실행 |

중요한 것은, 공격자가 새 취약 코드를 심는 게 아니라 **이미 클래스패스에 존재하는 정상 라이브러리의 조합**을 악용한다는 점입니다. 그래서 "우리 코드에는 취약점이 없다"는 판단이 통하지 않습니다. 이 원리를 무기화한 도구가 Frohoff의 `ysoserial`이며, 여기서는 원리만 언급하고 재현은 다루지 않습니다.

### CVE와 패치 흐름

| 항목 | 내용 |
|------|------|
| **CVE-2015-4852** | Oracle WebLogic 등에서의 역직렬화 RCE로 널리 알려진 번호 |
| **CVE-2015-7501** | Red Hat JBoss 계열의 `InvokerTransformer` 역직렬화 코드 실행 |
| 취약 버전 | commons-collections 3.0 ~ 3.2.1, commons-collections4 4.0 |
| **패치** | 3.2.2 릴리스(COLLECTIONS-580) — functor 패키지의 위험 클래스(`InvokerTransformer` 등) 직렬화 지원을 **기본 비활성화** |
| 플랫폼 대응 | 이후 JDK가 JEP 290 직렬화 필터를 도입(아래) |

### 교훈

라이브러리 하나를 패치한다고 역직렬화 문제가 끝나지 않습니다. 다른 라이브러리에서 새 가젯 체인이 계속 발견되기 때문입니다. 그래서 대응의 축은 "취약 클래스 제거"가 아니라 **"신뢰할 수 없는 입력을 역직렬화하지 않는다"**는 아키텍처 원칙으로 이동했습니다. 이는 Item 85가 말하는 바와 정확히 같습니다.

## Item 88 — readObject는 방어적으로 작성하라

어쩔 수 없이 `Serializable`을 구현했다면, `readObject`를 **생성자와 같은 수준으로** 방어해야 합니다. 잘못된 바이트 스트림이 들어와도 불변식이 깨지지 않도록 가변 컴포넌트는 방어적으로 복사하고, 불변식을 검증합니다.

```java
public final class Period implements Serializable {
    private Date start;
    private Date end;

    public Period(Date start, Date end) {
        this.start = new Date(start.getTime());   // 방어적 복사
        this.end = new Date(end.getTime());
        if (this.start.after(this.end)) {
            throw new IllegalArgumentException(start + " > " + end);
        }
    }

    private void readObject(ObjectInputStream s)
            throws IOException, ClassNotFoundException {
        s.defaultReadObject();

        // 1) 가변 컴포넌트 방어적 복사 — 원본 참조가 외부에 노출됐을 수 있음
        start = new Date(start.getTime());
        end = new Date(end.getTime());

        // 2) 불변식 검증 — 위반이면 InvalidObjectException
        if (start.after(end)) {
            throw new InvalidObjectException(start + " > " + end);
        }
    }
}
```

규칙은 네 가지입니다. private 가변 컴포넌트는 방어적으로 복사하고, 불변식을 검증해 위반 시 `InvalidObjectException`을 던지며, 재정의 가능한 메서드는 호출하지 않고, 외부로 반환하는 메서드 역시 방어적으로 복사합니다.

## Item 90 — 직렬화 프록시 패턴

가장 안전한 방어는 `readObject`를 잘 짜는 것을 넘어, **원본 객체가 직접 역직렬화되지 못하게 막고 대리인(프록시)을 통하는 것**입니다. 프록시의 `readResolve`가 정상 생성자를 호출하므로 검증·복사가 자동으로 걸립니다.

```java
public final class Period implements Serializable {
    private final Date start;
    private final Date end;

    public Period(Date start, Date end) {
        this.start = new Date(start.getTime());
        this.end = new Date(end.getTime());
        if (this.start.after(this.end)) {
            throw new IllegalArgumentException();
        }
    }

    // 1) 직렬화 시 원본 대신 프록시를 내보냄
    private Object writeReplace() {
        return new SerializationProxy(this);
    }

    // 2) 원본의 직접 역직렬화를 무력화 — 공격 스트림 차단
    private void readObject(ObjectInputStream s) throws InvalidObjectException {
        throw new InvalidObjectException("Proxy required");
    }

    // 3) 정적 내부 클래스 프록시
    private static class SerializationProxy implements Serializable {
        private static final long serialVersionUID = 1L;
        private final Date start;
        private final Date end;

        SerializationProxy(Period p) {
            this.start = p.start;
            this.end = p.end;
        }

        // 역직렬화 시 정상 생성자를 거쳐 원본 생성 → 검증·복사 자동
        private Object readResolve() {
            return new Period(start, end);
        }
    }
}
```

원본의 `readObject`가 예외를 던지므로, 공격자가 원본을 직접 겨냥한 스트림은 조립 단계에서 거부됩니다. 정상 경로는 오직 프록시를 거쳐 생성자로 흐르므로 불변식이 항상 보장됩니다. 다만 클라이언트가 상속할 수 있는 클래스에는 적용할 수 없고, 객체를 두 번 거치는 약간의 성능 비용이 있습니다.

## 대안 — 형식과 필터

가장 좋은 방어는 자바 직렬화를 안 쓰는 것입니다. 다음은 실무 대안과, 그래도 써야 할 때의 안전장치입니다.

| 대안 | 장점 | 유의점 |
|------|------|--------|
| **JSON (Jackson)** | 표준·가독성·크로스 플랫폼, Spring 기본 | 다형성 역직렬화(`@class`/default typing)는 같은 RCE 위험 — 켜지 말 것 |
| **Protocol Buffers** | 작고 빠름, 스키마 진화 지원 | 별도 IDL·코드 생성 필요 |
| **MessagePack** | JSON 호환 + 바이너리 | 도구 생태계가 상대적으로 작음 |
| **`ObjectInputFilter` (JEP 290)** | 자바 직렬화를 유지하면서 허용 클래스 화이트리스트 | 필터를 좁게 유지해야 실효, 블랙리스트는 우회당하기 쉬움 |

### JEP 290 — 역직렬화 데이터 필터링

JEP 290("Filter Incoming Serialization Data")은 Java 9에 도입되고 8u121·7u131·6u141로 백포트된 플랫폼 차원의 방어입니다. `ObjectInputFilter`를 스트림에 붙이면, JVM이 **각 클래스를 인스턴스화하기 전에** 필터를 호출해 허용·거부를 판정합니다. 화이트리스트 방식으로 우리 도메인 클래스만 통과시키는 것이 권장 패턴입니다.

```java
ObjectInputStream ois = new ObjectInputStream(in);

// 허용 목록(화이트리스트) — 우리 패키지만 통과, 그 외 전부 거부
ObjectInputFilter filter = ObjectInputFilter.Config.createFilter(
        "com.example.dto.*;java.base/*;!*");
ois.setObjectInputFilter(filter);

Object obj = ois.readObject();   // 허용되지 않은 클래스는 여기서 거부됨
```

패턴 문자열에서 `!*`는 "그 외 모든 클래스 거부"를 뜻하므로, 앞에 명시한 패키지만 통과합니다. 블랙리스트로 위험 클래스를 하나씩 막는 방식은 새 가젯이 계속 나와 우회당하기 쉬우므로, **허용 목록**을 기본으로 삼습니다.

## 같은 인사이트 패턴 — "기본 제공 기능의 암묵적 신뢰가 사고로"

자바 직렬화 RCE의 본질은 "언어가 기본으로 주는 기능이니 안전하겠지"라는 암묵적 신뢰가 만든 사고입니다. 위키의 "기본값과 가정의 함정" 패턴과 같은 뿌리를 공유합니다.

| 페이지 | 암묵적으로 신뢰한 기본값·기능 | 그 결과 |
|--------|------------------------------|---------|
| **이 페이지** | `ObjectInputStream`이 데이터를 "그냥 읽어 줄" 것이라는 신뢰 | 임의 클래스 코드 실행(RCE) |
| [[concept-transactional-rollback-policy]] | `@Transactional`이 모든 예외를 롤백한다는 가정 | 체크 예외에서 커밋되어 데이터 오염 |
| [[concept-api-backward-compatibility]] | 클라이언트 JSON 파서가 관용적일 것이라는 가정 | 필드 추가만으로 앱 전체 오류 |
| [[concept-cronjob-concurrency-trap]] | K8s CronJob `concurrencyPolicy` 기본값 | 잡 중복 실행 |
| [[concept-db-connection-pool]] | 커넥션 수명 기본 무한 가정 | 죽은 커넥션 반환 |
| [[concept-varchar-length-prefix]] | 관습적 `VARCHAR(255)` | 잠재적 잘림·마이그레이션 비용 |

공통 원리는 이렇습니다. **프레임워크·언어가 제공하는 기본 동작을 "안전하고 무해하다"고 검증 없이 신뢰하면, 그 기본 동작이 곧 공격면·사고면이 됩니다.** 역직렬화는 그중에서도 결과가 RCE라 파급이 가장 큽니다.

## 빠른 진단 체크리스트

- [ ] 우리 코드에 `ObjectInputStream`/`readObject` 사용처가 있는가
- [ ] 그 입력이 외부(네트워크·업로드·큐 등) 신뢰할 수 없는 출처에서 오는가
- [ ] Redis·Hazelcast 캐시나 톰캣 세션이 JDK 직렬화를 쓰고 있지 않은가
- [ ] 자바 직렬화를 JSON/Protobuf로 대체할 수 있는가 (Item 85)
- [ ] 불가피하다면 `ObjectInputFilter`(JEP 290) 화이트리스트가 걸려 있는가
- [ ] commons-collections 등 라이브러리가 알려진 취약 버전(3.2.1 이하)이 아닌가
- [ ] `Serializable` 값 객체에 방어적 `readObject`(Item 88) 또는 프록시 패턴(Item 90)이 적용됐는가
- [ ] Jackson의 default typing / 다형성 역직렬화를 무분별하게 켜 두지 않았는가

## 원본 출처

- [[lecture-effective-java-ch12]] — *Effective Java* 12장 강의 교재 (Item 85·88·90 원문 발췌)
- [OpenJDK — JEP 290: Filter Incoming Serialization Data](https://openjdk.org/jeps/290)
- [Apache Commons Collections 3.2.2 릴리스 노트](https://commons.apache.org/proper/commons-collections/release_3_2_2.html)
- [COLLECTIONS-580 — Arbitrary remote code execution with InvokerTransformer (ASF Jira)](https://issues.apache.org/jira/browse/collections-580)
- [Red Hat — CVE-2015-7501](https://access.redhat.com/security/cve/cve-2015-7501)
- [Apache Commons statement to widespread Java object de-serialisation vulnerability (ASF Blog)](https://news.apache.org/foundation/entry/apache_commons_statement_to_widespread)
- [Oracle — Serialization Filtering (Java Core 문서)](https://docs.oracle.com/en/java/javase/11/core/serialization-filtering1.html)

## 관련 페이지

- [[lecture-effective-java-ch12]] — 12장 직렬화 전체 (Item 85~90)
- [[entity-effective-java]] — *Effective Java* 엔티티 (Item 85·88·90 매핑 출처)
- [[concept-transactional-rollback-policy]] / [[concept-api-backward-compatibility]] / [[concept-cronjob-concurrency-trap]] — "기본값과 가정의 함정" 같은 패턴
- [[concept-db-connection-pool]] — try-with-resources·기본 수명 가정 (Item 9 사례)
- [[concept-varchar-length-prefix]] — 관습적 기본값의 함정
