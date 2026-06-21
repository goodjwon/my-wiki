---
title: "Effective Java 실전 강의 — 3장"
type: source
tags: [book, effective-java, bloch, lecture]
sources: [effective_java/이펙티브 자바 실전 강의 교재 3장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 이펙티브 자바 실전 강의 교재

## 3장 — 모든 객체의 공통 메서드

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 설명 → 비유 → 현업 예제 → 따라하기(실습) → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x, JPA(Hibernate)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- `Object`가 물려주는 `equals`, `hashCode`, `toString`, `clone`, `Comparable`을 **언제 재정의해야 하는지** 판단한다.
- **잘못 재정의했을 때 터지는 실제 버그**(HashMap에서 객체를 못 찾음, JPA 엔티티 중복, 로그에 비밀번호 노출)를 예방한다.
- "값을 표현하는 객체(값 객체)"와 "정체성을 가진 객체(엔티티)"를 구분해 재정의 전략을 다르게 가져간다.

### 0.2 큰 그림 — `Object`의 메서드는 "계약서"다

`Object`의 메서드들은 그냥 오버라이드 가능한 메서드가 아니라, **일반 규약(general contract)**이라는 계약이 걸려 있습니다.

```
[ 같음을 정의 ]                 [ 표현/정렬 ]               [ 복제 ]
 아이템 10  equals 규약          아이템 12  toString          아이템 13  clone (가급적 회피)
 아이템 11  hashCode 동반        아이템 14  Comparable        → 복사 생성자/팩터리 권장
```

> **비유 — `equals`/`hashCode`는 "주민등록 시스템"입니다.**
> 
> - `equals`: 두 사람이 **같은 사람인지** 판단하는 기준(주민번호).
> - `hashCode`: 그 사람을 **어느 서랍에 보관할지** 정하는 분류번호.
> - **같은 사람(equals=true)인데 서랍 번호(hashCode)가 다르면**, 사서는 영영 못 찾습니다. 그래서 둘은 항상 **세트**로 다닙니다(아이템 11).

### 0.3 현업에서 왜 중요한가

- JPA 엔티티에 Lombok `@Data`를 무심코 붙였다가 **무한 루프 / Set 중복 / 프록시 비교 오류**로 운영 사고가 납니다.
- `toString`에 모든 필드를 노출했다가 **비밀번호·주민번호가 로그에 찍히는** 개인정보 사고가 납니다(ISMS-P 위반 소지).
- 정렬·중복 제거가 `equals`/`Comparable` 구현에 따라 **조용히 틀린 결과**를 냅니다.

---

## 아이템 10. equals는 일반 규약을 지켜 재정의하라

### 한 줄 요약

`equals`는 **논리적 동치**가 필요할 때만 재정의하라. 재정의한다면 **5가지 규약**을 반드시 지켜라.

### 비유 — "같은 사람인가?"

- **참조 동등성(`==`)**: "이 몸과 저 몸이 물리적으로 같은가?" (같은 메모리 주소)
- **논리적 동치(`equals`)**: "주민번호가 같으니 같은 사람인가?" (값이 같은가)

`Integer`, `String`, 그리고 우리가 만드는 **값 객체(money, 좌표, 전화번호)**는 보통 논리적 동치가 필요합니다.

### 재정의하지 말아야 할 때

- 각 인스턴스가 **본질적으로 고유**할 때(예: 동작 주체인 `Thread`).
- 논리적 동치를 **검사할 일이 없을** 때.
- 상위 클래스의 `equals`가 **하위에도 들어맞을** 때.

### equals의 5가지 규약 (계약서)

|규약|의미|비유|
|---|---|---|
|반사성|`x.equals(x)`는 항상 true|나는 나와 같다|
|대칭성|`x.equals(y)`면 `y.equals(x)`|A가 B의 친구면 B도 A의 친구|
|추이성|`x=y`, `y=z`면 `x=z`|A=B, B=C면 A=C|
|일관성|값이 안 변하면 결과도 안 변함|같은 질문엔 같은 답|
|null-아님|`x.equals(null)`은 false|존재하는 사람 ≠ 없는 사람|

### 가장 흔한 함정: 상속에서 대칭성·추이성 깨짐

`Point`를 상속한 `ColorPoint`에서 색까지 비교하려 하면 **대칭성**(point.equals(colorPoint)와 반대 결과)이 깨집니다. **결론: 구체 클래스를 확장하면서 equals 규약을 지키는 방법은 사실상 없다.** → **상속 대신 컴포지션**(아이템 18).

```java
public class ColorPoint {
    private final Point point;   // 상속이 아니라 포함
    private final Color color;
    // equals는 point와 color를 함께 비교 (규약 안전)
}
```

### 올바른 equals 작성 순서 (정형 패턴)

```java
@Override
public boolean equals(Object o) {
    if (this == o) return true;                 // 1) 자기 자신: 성능 최적화
    if (!(o instanceof PhoneNumber pn)) return false;  // 2) 타입 확인 + 형변환(패턴 매칭)
    return pn.areaCode == areaCode              // 3) 핵심 필드 비교
        && pn.prefix == prefix
        && pn.lineNum == lineNum;
}
```

### 현업 예제 — 값 객체로서의 `Money`, `PhoneNumber`

공공 계약 도메인에서 `금액(Money)`, `사업자번호`, `계약식별자` 같은 값 객체는 **값이 같으면 같은 것**으로 취급해야 합니다. equals를 제대로 재정의해야 비교·중복 제거가 의도대로 동작합니다.

> **JPA 주의(아이템 11과 함께 봐야 함)**: 엔티티는 "값"이 아니라 "정체성(ID)"을 가집니다. 엔티티 equals는 무심코 모든 필드로 비교하면 안 되고, **비즈니스 키 또는 ID 기반**으로 신중히 설계해야 합니다(아래 11번에서 상세).

### 따라하기 (실습 10-A)

1. `Point`에 equals를 구현한다.
2. `ColorPoint`를 **상속으로** 만들어 대칭성이 깨지는 것을 테스트로 재현한다.
3. **컴포지션**으로 바꿔 규약을 지킨다.

### 체크리스트

- [ ] 이 객체는 "값"인가 "정체성"인가? (값일 때만 보통 equals 재정의)
- [ ] `Object` 타입을 매개변수로 받았는가? (`equals(MyType o)`로 잘못 쓰면 오버라이드가 아니라 오버로드)
- [ ] `@Override`를 붙였는가? (시그니처 실수 방지, 아이템 40)

### 퀴즈

**Q. `public boolean equals(PhoneNumber pn)`로 작성하면 무엇이 잘못되는가?**

**A.** `Object`를 받지 않으므로 **재정의(override)가 아니라 다중정의(overload)**가 됩니다. `Object` 참조로 호출하면 `Object.equals`(참조 비교)가 불려서 의도와 다르게 동작합니다. `@Override`를 붙였다면 컴파일 에러로 잡혔을 것입니다.

---

## 아이템 11. equals를 재정의하려거든 hashCode도 재정의하라 ⭐현업 사고 단골

### 한 줄 요약

`equals`를 재정의했으면 `hashCode`도 **반드시** 재정의하라. 안 그러면 `HashMap`/`HashSet`에서 객체를 잃어버린다.

### 비유 — "도서관 분류번호"

같은 책(equals=true)은 **같은 서가(hashCode)**에 꽂혀 있어야 사서가 찾습니다. 제목은 같은데 분류번호가 제각각이면, 사서는 그 책이 없다고 합니다.

### 규약

- equals가 **같다고 판단한 두 객체는 hashCode도 같아야** 한다.
- (역은 성립 안 함: hashCode가 같다고 equals가 같진 않음 — 해시 충돌은 정상.)

### 깨졌을 때의 실제 증상

```java
Map<PhoneNumber, String> m = new HashMap<>();
m.put(new PhoneNumber(707, 867, 5309), "제니");

// equals만 재정의하고 hashCode를 안 했다면 → null 반환!
m.get(new PhoneNumber(707, 867, 5309));   // 기대: "제니", 실제: null
```

"분명히 넣었는데 못 찾는다"는 버그의 대표 원인입니다.

### 올바른 hashCode 작성

```java
// 간단 버전: 성능이 크게 중요치 않으면
@Override public int hashCode() {
    return Objects.hash(areaCode, prefix, lineNum);
}

// 성능 핫패스: 직접 31배수 누적 (캐싱도 가능)
@Override public int hashCode() {
    int result = Integer.hashCode(areaCode);
    result = 31 * result + Integer.hashCode(prefix);
    result = 31 * result + Integer.hashCode(lineNum);
    return result;
}
```

> 왜 31인가? 홀수·소수라 곱셈 시 정보 손실이 적고, `31*i == (i<<5)-i`로 JVM이 최적화하기 좋아서입니다.

### 현업 예제 — JPA 엔티티의 equals/hashCode 함정 ⭐⭐

이 부분이 현업에서 가장 사고가 잦습니다.

**문제 1: Lombok `@Data`/`@EqualsAndHashCode`를 엔티티에 그대로 사용**

- 모든 필드를 비교 → 연관관계 필드까지 건드려 **지연 로딩 강제 + 무한 루프** 위험.
- 영속화 전(id=null)과 후(id 발급)의 hashCode가 **달라져** Set에서 객체가 사라짐.

**문제 2: id만으로 비교하되 id가 영속화 시점에 생성되는 경우**

- 컬렉션에 넣은 뒤 id가 채워지면 hashCode가 변함 → `HashSet`에서 미아 발생.

**현업 권장 패턴(둘 중 하나):**

```java
// (A) 변하지 않는 '비즈니스 키'가 있으면 그것으로
@Entity
public class Member {
    @Id @GeneratedValue private Long id;
    @Column(unique = true, updatable = false)
    private String memberNo;   // 발급 후 불변인 자연키

    @Override public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Member m)) return false;
        return memberNo != null && memberNo.equals(m.memberNo);
    }
    @Override public int hashCode() {
        return Objects.hash(memberNo);   // 불변 키만 사용
    }
}
```

```java
// (B) 비즈니스 키가 없으면: id 기반 equals + hashCode는 '상수'로 고정
@Override public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Member m)) return false;
    return id != null && id.equals(m.id);
}
@Override public int hashCode() {
    return getClass().hashCode();   // 컬렉션 동작은 보장, 분포는 포기
}
```

> **핵심 원칙**: 엔티티의 hashCode는 **객체 생애 동안 변하면 안 됩니다.** 그래서 "값이 바뀌는 필드"나 "나중에 채워지는 id"를 hashCode에 직접 쓰면 위험합니다.

### 따라하기 (실습 11-A)

1. equals만 재정의한 `PhoneNumber`로 `HashMap` get이 null이 되는 것을 재현한다.
2. hashCode를 추가해 정상 동작을 확인한다.
3. (심화) 간단한 JPA 엔티티에 `@Data`를 붙였다가, 양방향 연관관계에서 `equals` 호출 시 무슨 일이 생기는지 관찰하고 (A)/(B) 패턴으로 교체한다.

### 체크리스트

- [ ] equals를 손댔다면 hashCode도 손댔는가?
- [ ] 엔티티 hashCode가 객체 수명 동안 불변인가?
- [ ] Lombok `@Data`를 엔티티에 쓰고 있지 않은가?

### 퀴즈

**Q. hashCode를 항상 같은 상수로 반환하면 정상 동작은 하는데 왜 권장하지 않는가?**

**A.** equals/hashCode **규약은 지키므로 오작동은 없지만**, 모든 객체가 같은 버킷에 들어가 해시 테이블이 **연결 리스트처럼 O(n)으로 퇴화**해 성능이 무너집니다. 비즈니스 키가 있으면 그것을 쓰는 편이 좋습니다.

---

## 아이템 12. toString을 항상 재정의하라

### 한 줄 요약

`toString`을 재정의하면 **디버깅·로그가 쉬워진다.** 단, **민감정보는 절대 넣지 마라.**

### 비유 — "명함"

객체를 출력했을 때 `PhoneNumber@1a2b3c`(의미 없는 해시)가 찍히면, 명함에 사번만 적힌 꼴입니다. 사람이 읽을 수 있는 **이름·소속**(의미 있는 정보)을 담아야 합니다.

### 기본값의 문제

```java
System.out.println(member);   // Member@7f8e9d  ← 디버깅 불가
```

### 재정의

```java
@Override public String toString() {
    return "Member{id=%d, name='%s'}".formatted(id, name);
}
```

로그/예외 메시지/디버거에서 자동으로 유용하게 쓰입니다.

### 현업 예제 — 민감정보 노출 사고 ⭐ (ISMS-P 직결)

toString에 모든 필드를 넣으면 **비밀번호, 주민번호, 카드번호**가 로그에 남습니다. 이는 개인정보 보호·ISMS-P 관점에서 사고입니다.

```java
// ❌ 위험: 비밀번호/주민번호가 로그로 흘러나감
@ToString   // Lombok이 모든 필드를 포함
public class User {
    private String email;
    private String password;     // 로그 노출!
    private String residentNo;   // 로그 노출!
}

// ✅ 안전: 민감 필드 제외 + 마스킹
public class User {
    private String email;
    private String password;
    private String residentNo;

    @Override public String toString() {
        return "User{email='%s', residentNo='%s'}"
                .formatted(maskEmail(email), maskRrn(residentNo));
        // password는 아예 포함하지 않음
    }
}
```

Lombok을 쓴다면 `@ToString(exclude = {"password", "residentNo"})`로 명시적으로 제외하세요.

### 추가 지침

- toString이 반환하는 정보는 **포맷을 문서화할지** 결정한다. 문서화하면 그 포맷에 **묶이므로**, 향후 변경 가능성이 있으면 "포맷은 변경될 수 있다"고 남긴다.
- 양방향 연관관계 엔티티의 toString이 서로를 출력하면 **무한 재귀(StackOverflow)**가 납니다 → 연관 엔티티는 toString에서 제외.

### 따라하기 (실습 12-A)

1. `User`에 `@ToString`(전체)을 붙이고 로그를 찍어 비밀번호가 노출되는지 확인한다.
2. 민감 필드를 제외하고 마스킹하는 toString으로 교체한다.
3. 양방향 연관관계 엔티티 두 개를 만들어 toString 무한 재귀를 재현하고, 한쪽을 제외해 해결한다.

### 체크리스트

- [ ] 로그/예외에 객체가 찍히는데 `Xxx@hex`로 나오는가? → 재정의
- [ ] toString에 비밀번호·주민번호·카드번호가 들어가 있지 않은가?
- [ ] 양방향 연관관계를 toString에 넣지 않았는가?

### 퀴즈

**Q. 엔티티의 toString에서 양방향 연관 필드를 빼야 하는 이유는?**

**A.** 서로의 toString을 호출하며 **무한 재귀(StackOverflowError)**가 발생하고, 지연 로딩 필드를 강제로 초기화하는 부작용도 있기 때문입니다.

---

## 아이템 13. clone 재정의는 주의해서 진행하라 (현업: 가급적 회피)

### 한 줄 요약

`Cloneable`/`clone`은 **설계가 망가진 메커니즘**이다. 복제가 필요하면 **복사 생성자·복사 팩터리**를 써라.

### 비유 — "위험한 복제기"

`clone`은 생성자를 거치지 않고 객체를 통째로 복제하는 "이상한 복제기"입니다. 얕은 복사(shallow copy)로 인해 원본과 복제본이 **내부 배열을 공유**하면, 한쪽 수정이 다른 쪽에 번지는 버그가 납니다.

### Cloneable의 구조적 문제

- `Cloneable`에는 메서드가 없는데, `Object.clone`의 동작을 **바꾸는** 이상한 인터페이스다.
- `clone`은 생성자를 호출하지 않아 `final` 필드와 충돌하고, 가변 객체를 공유하는 **얕은 복사** 문제가 있다.
- 검사 예외(`CloneNotSupportedException`) 처리까지 강요한다.

### 권장 대안: 복사 생성자 / 복사 팩터리

```java
// 복사 생성자
public Yum(Yum yum) { /* 필드 복사 */ }

// 복사 팩터리
public static Yum newInstance(Yum yum) { /* ... */ }
```

장점: 생성자/팩터리의 모든 이점(이름, 검증, 형변환 자유)을 누리고, **인터페이스 타입을 인자로 받아** 변환 복사도 가능합니다(예: `HashSet` → `TreeSet`).

```java
TreeSet<E> tree = new TreeSet<>(someCollection);   // 변환 복사
```

### 현업 예제

실무에서는 불변 객체(아이템 17)를 선호하므로 복제 자체가 드뭅니다. 복제가 필요하면 거의 항상 **복사 생성자**나 빌더(아이템 2), 또는 `record`의 파생 메서드로 충분합니다.

```java
public record Money(long amount, String currency) {
    public Money withAmount(long newAmount) {   // 불변 + 파생 복사
        return new Money(newAmount, currency);
    }
}
```

### 체크리스트

- [ ] 정말 clone이 필요한가? → 대부분 "아니오". 복사 생성자/팩터리로 대체
- [ ] 불변 객체로 설계할 수 있는가? → 그러면 복제 자체가 불필요

### 퀴즈

**Q. clone 대신 복사 생성자/팩터리가 나은 점을 두 가지 들어라.**

**A.** ①정상적인 생성자를 거치므로 `final` 필드·불변식·검증과 충돌하지 않는다. ②인터페이스 타입을 인자로 받아 **다른 구현으로의 변환 복사**(예: List→ArrayList)가 가능하다.

---

## 아이템 14. Comparable을 구현할지 고려하라

### 한 줄 요약

**자연적인 순서**가 있는 값 클래스라면 `Comparable`을 구현하라. 정렬·검색·`TreeSet`/`TreeMap`이 공짜로 따라온다.

### 비유 — "키 순 줄 세우기"

`compareTo`는 "두 명을 세웠을 때 누가 앞인가"의 기준입니다. 기준만 정의하면, 정렬·중복 없는 순서 집합 등이 자동으로 동작합니다.

### compareTo 규약 (equals와 유사)

- 대칭성: `sgn(x.compareTo(y)) == -sgn(y.compareTo(x))`
- 추이성, 일관성
- (권장) `compareTo`가 0이면 `equals`도 true가 되도록 — 안 그러면 `TreeSet`과 `HashSet`이 다르게 동작.

### 작성법 — Comparator 조합 사용 (Java 8+)

```java
public class PhoneNumber implements Comparable<PhoneNumber> {
    private static final Comparator<PhoneNumber> COMPARATOR =
            Comparator.comparingInt((PhoneNumber p) -> p.areaCode)
                      .thenComparingInt(p -> p.prefix)
                      .thenComparingInt(p -> p.lineNum);

    @Override public int compareTo(PhoneNumber p) {
        return COMPARATOR.compare(this, p);
    }
}
```

### 중요 함정: 정수 빼기로 비교하지 말 것

```java
// ❌ 오버플로/부동소수 오류 위험
return o1.value - o2.value;

// ✅ 정적 compare 사용
return Integer.compare(o1.value, o2.value);
```

### 현업 예제 — 도메인 객체 정렬

계약 목록을 "체결일 → 금액 내림차순"으로 정렬하는 등 **여러 키 정렬**이 흔합니다. `Comparator` 체이닝이 가독성도 좋습니다.

```java
contracts.sort(
    Comparator.comparing(Contract::signedDate)
              .thenComparing(Contract::amount, Comparator.reverseOrder())
);
```

> **실무 팁**: 클래스의 "자연 순서"가 하나로 명확할 때만 `Comparable`을 구현하고, **상황별 정렬**은 그때그때 `Comparator`로 넘기는 편이 유연합니다.

### 따라하기 (실습 14-A)

1. `Contract`에 `Comparable`(체결일 기준)을 구현하고 `TreeSet`에 넣어 정렬을 확인한다.
2. `compareTo`가 0인데 equals가 false가 되도록 만들어, `TreeSet`과 `HashSet`의 크기가 달라지는 현상을 재현한다.
3. 빼기 비교(`a - b`)를 오버플로가 나는 값으로 깨뜨려 본 뒤 `Integer.compare`로 고친다.

### 체크리스트

- [ ] 이 객체에 "자연 순서"가 하나로 명확한가? → Comparable
- [ ] 정렬 기준이 상황마다 다른가? → Comparable 대신 Comparator 전달
- [ ] 비교에 `-` 연산 대신 `Integer.compare` 등을 썼는가?

### 퀴즈

**Q. `o1.value - o2.value` 방식의 비교가 위험한 이유는?**

**A.** 값의 차이가 `int` 범위를 넘으면 **오버플로**로 부호가 뒤집혀 잘못된 순서가 나옵니다. 부동소수에서도 정밀도 문제가 생깁니다. `Integer.compare`/`Double.compare`를 써야 안전합니다.

---

## 3장 종합 정리

### 한눈에 보는 결정 가이드

|상황|선택|
|---|---|
|값이 같으면 같은 객체로 보고 싶다|**equals 재정의(10)**|
|equals를 재정의했다|**hashCode도 재정의(11)** — 세트|
|로그/디버깅을 편하게, 단 민감정보 제외|**toString 재정의(12)**|
|객체를 복제하고 싶다|clone 회피(13) → **복사 생성자/팩터리**|
|자연 순서로 정렬·검색하고 싶다|**Comparable 구현(14)** / 상황별은 Comparator|

### 종합 체크리스트 (코드 리뷰용)

- [ ] equals와 hashCode를 **항상 함께** 손댔는가
- [ ] **엔티티에 `@Data` 금지**, equals/hashCode는 불변 키 기반인가
- [ ] toString에 **비밀번호·주민번호·카드번호**가 없는가 (ISMS-P)
- [ ] 양방향 연관관계가 toString/equals 무한 재귀를 일으키지 않는가
- [ ] 비교에 `-` 대신 `Integer.compare`/`Comparator`를 썼는가

### 종합 퀴즈

**Q1. "값 객체"와 "엔티티"의 equals 전략은 어떻게 다른가?**

**A.** 값 객체는 **모든(또는 핵심) 필드 값**이 같으면 같다고 본다. 엔티티는 **정체성(불변 비즈니스 키 또는 id)** 기준으로 같음을 판단하며, 변하는 필드나 나중에 채워지는 id를 hashCode에 직접 넣지 않는다.

**Q2. equals만 재정의하고 hashCode를 빠뜨리면 가장 먼저 어디서 터지는가?**

**A.** `HashMap`/`HashSet` 같은 **해시 기반 컬렉션**에서 넣은 객체를 못 찾거나(get=null), 중복이 제대로 제거되지 않습니다.

**Q3. toString 재정의 시 현업에서 가장 조심할 한 가지는?**

**A.** **민감정보 노출.** 비밀번호·주민번호 등이 로그/예외 메시지로 새어 나가지 않도록 제외·마스킹해야 합니다(개인정보·ISMS-P 위반 방지).

---

## 다음 장 예고 — 4장: 클래스와 인터페이스

캡슐화(접근 권한 최소화), **불변 클래스**, **상속 대신 컴포지션**, 인터페이스 우선 설계 등 "좋은 타입 설계"의 핵심이 모여 있습니다. 도메인 모델링을 중시하는 분께는 이 장이 2~3장보다 더 와닿을 가능성이 큽니다.