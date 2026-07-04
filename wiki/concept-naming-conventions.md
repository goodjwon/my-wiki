---
title: 작명 규약 — 이름이 곧 문서이자 계약
type: concept
tags: [clean-code, naming, java, spring, code-quality, code-review]
sources: [clean-code/클린 코드 실전 강의 교재 2장.md, clean-code/클린 코드 실전 강의 교재 17장.md]
created: 2026-07-04
updated: 2026-07-04
---

# 작명 규약 — 이름이 곧 문서이자 계약

## 정의

이름은 코드에서 가장 자주 마주치고 가장 싸게 고칠 수 있는 품질 지점입니다. 좋은 이름은 주석 없이도 "이게 무엇이고, 무엇을 하며, 어떻게 쓰는가"를 답하는 **문서**이고, `findById`·`isPosted`처럼 호출부가 기대할 동작을 약속하는 **계약**입니다. 이 페이지는 *Clean Code* 2장(의미 있는 이름)의 핵심 원칙과 17장 이름 휴리스틱 N1~N7을 한 장으로 압축하고, Java/Spring 실무에서 이름이 실제 계약으로 작동하는 사례까지 연결합니다.

## 2장 핵심 원칙 — 의미 있는 이름

2장의 처방을 세 묶음(드러내라 / 헷갈리게 말라 / 일관·맥락)으로 정리하면 다음과 같습니다.

| 묶음 | 원칙 | 한 줄 처방 | 위반 → 교정 예 |
|------|------|-----------|---------------|
| 드러내라 | 의도를 분명히 (2.1) | 주석으로 변수를 설명하고 싶으면 이름을 고칩니다 | `int d;` → `int elapsedTimeInDays;` |
| 드러내라 | 발음하기 쉽게 (2.4) | 회의·페어에서 입으로 말할 수 있어야 합니다 | `genymdhms` → `generationTimestamp` |
| 드러내라 | 검색하기 쉽게 (2.5) | 매직 넘버는 명명 상수로 — grep/IDE에 걸리게 (17장 G25와 동일) | `5` → `WORK_DAYS_PER_WEEK` |
| 헷갈리게 말라 | 그릇된 정보 금지 (2.2) | 타입이 아닌데 타입을 암시하지 않습니다 | `Map`인데 `accountList` → `accountsById` |
| 헷갈리게 말라 | 의미 있는 구분 (2.3) | `Info`/`Data`/`a1` 같은 불용어로 대충 가르지 않습니다 | `getActiveAccountInfo()` → `findActiveAccount(id)` |
| 헷갈리게 말라 | 인코딩 금지 (2.6) | 헝가리식·`m_`·인터페이스 `I` 접두어는 잡음입니다 (N6와 동일) | `IShapeFactory` → `ShapeFactory` |
| 헷갈리게 말라 | 기발한 이름 금지 (2.10) | 농담은 한 번이지만 코드는 영원합니다 | `whack()` → `kill()` |
| 일관·맥락 | 한 개념 한 단어 (2.11) | 조회를 `fetch`/`retrieve`/`get`으로 섞지 않습니다 | 전부 `findById`로 통일 |
| 일관·맥락 | 말장난 금지 (2.12) | 같은 단어를 다른 개념에 재사용하지 않습니다 | 산술 `add` vs 컬렉션 `append` 구분 |
| 일관·맥락 | 해법/문제 영역 용어 (2.13·2.14) | 전산 용어(`Visitor`·`Queue`)와 도메인 용어(`ContractAward`)를 구분해 씁니다 | 독자가 기술/업무 개념을 즉시 분간 |
| 일관·맥락 | 맥락 추가/제거 (2.15·2.16) | 흩어진 변수는 클래스로 묶고, 프로젝트 접두어는 뗍니다 | `state` → `Address.state`, `GSDAccountAddress` → `Address` |

2.11과 2.12는 한 원칙의 양면입니다 — **단어와 개념을 1:1로** 묶으라는 것입니다. 같은 개념엔 늘 같은 단어를 쓰고, 같은 단어를 다른 개념에 재사용하지 않습니다.

### Before / After — 원칙이 겹쳐 적용되는 모습

아래 참고 코드는 의도 불명 이름·매직 넘버·불용어가 겹친 코드가 원칙 적용 후 어떻게 달라지는지 보여 줍니다.

```java
// before: 이름이 아무것도 말하지 않는다
public List<int[]> getThem() {
    List<int[]> list1 = new ArrayList<>();
    for (int[] x : theList)
        if (x[0] == 4) list1.add(x);
    return list1;
}

// after: 이름이 도메인(지뢰찾기)을 그대로 말한다
public List<Cell> getFlaggedCells() {
    List<Cell> flaggedCells = new ArrayList<>();
    for (Cell cell : gameBoard)
        if (cell.isFlagged()) flaggedCells.add(cell);
    return flaggedCells;
}
```

코드 구조는 한 줄도 바뀌지 않았지만, `theList`가 게임판이고 `x[0] == 4`가 "깃발 꽂힘"이라는 사실이 이름만으로 전달됩니다. 이것이 2장의 핵심 주장입니다 — **가독성의 병목은 알고리즘이 아니라 이름**입니다.

생성자 오버로드가 헷갈릴 때의 처방도 같은 결입니다. 이름 없는 생성자 대신 이름 있는 정적 팩터리 메서드를 씁니다.

```java
// before: 23.0이 실수부인지 크기인지 호출부가 외워야 한다
Complex point = new Complex(23.0);

// after: 이름이 의도를 드러낸다 — Effective Java Item 1과 동일 처방
Complex point = Complex.fromRealNumber(23.0);
```

## 17장 이름 휴리스틱 — N1~N7

17장 냄새와 휴리스틱 카탈로그(66개) 중 이름(Names) 카테고리 7개입니다. PR 리뷰에서 "N1", "N7"처럼 코드로 인용하면 코멘트 한 줄로 합의가 빨라집니다.

| 코드 | 휴리스틱 | 한 줄 | PR 코멘트 예 |
|------|---------|------|-------------|
| **N1** ⭐ | 서술적 이름 | `x`·`data`·`info` 같은 모호한 이름을 피하고 책임이 드러나게 짓습니다 | "N1 — `data`보다 의미 있는 이름" |
| **N2** | 적절한 추상화 수준 | 이름은 구현이 아니라 의도를 말합니다 — `getProcessedRecords()`가 `getRecords()`보다 명확 | "N2 — 이름이 구현 세부를 노출" |
| **N3** | 표준 명명법 | `findBy*`·`is*`·`to*` 같은 관례를 따릅니다 | "N3 — boolean은 `is*`/`has*`로" |
| **N4** | 명확한 이름 | 긴 이름이라도 모호한 짧은 이름보다 낫습니다 | "N4 — 축약으로 뜻이 사라짐" |
| **N5** | 긴 범위 = 긴 이름 | 지역 변수 `i`는 허용, 멤버 변수 `i`는 금지입니다 | "N5 — 필드명이 한 글자" |
| **N6** | 인코딩 회피 | 헝가리식(`strName`)·멤버 접두어(`mName`)를 쓰지 않습니다 (2.6과 동일) | "N6 — `m_` 접두어 제거" |
| **N7** | 이름이 부수효과를 설명 | `createUserAndSendEmail()` — 이름이 숨긴 일까지 말해야 하고, `And`가 보이면 분리 검토 신호입니다 | "N7 — 검증 함수가 이메일도 보냄" |

N7은 이중 역할을 합니다. 우선 이름이 함수가 하는 **모든 일**을 말하게 만들어 놀라움을 없애고, 그렇게 정직해진 이름에 `And`가 드러나면 "함수는 한 가지만"(G30) 위반의 신호로 읽어 분리를 검토합니다.

## Java/Spring 실무 연결 — 이름이 실제로 계약이 되는 곳

Java 생태계의 명명 관례는 취향이 아니라 도구·프레임워크가 의존하는 계약입니다.

| 대상 | 관례 | 계약으로 작동하는 이유 |
|------|------|----------------------|
| 클래스 | 명사/명사구 (`Customer`, `AddressParser`) | `Manager`·`Processor` 같은 모호어는 SRP 위반의 은신처가 됩니다 |
| 메서드 | 동사/동사구 (`postPayment`, `deletePage`) | 접근자 `get*`·변경자 `set*`·조건자 `is*`는 JavaBeans 규약 — Jackson·JPA·SpEL이 이 이름을 보고 프로퍼티를 찾습니다 |
| 상수 | `UPPER_SNAKE_CASE` | 검색 가능성(2.5) + 불변임을 시각으로 전달합니다 |
| 정적 팩터리 | `of`·`from`·`valueOf` | *Effective Java* Item 1 관례 어휘 — 변환/집계 의도를 이름이 실어 나릅니다 |
| 테스트 | `should*`·`given_when_then` | 테스트 이름이 곧 요구사항 문장이 됩니다 |

가장 극적인 사례가 Spring Data JPA 쿼리 메서드입니다. 아래 참고 코드처럼 메서드 **이름 자체를 파싱해서 쿼리를 생성**하므로, 이름이 은유가 아니라 문자 그대로 실행 계약입니다.

```java
public interface OrderRepository extends JpaRepository<Order, Long> {

    // 이름이 파싱되어 JPQL이 된다:
    // select o from Order o where o.status = ?1 and o.createdAt > ?2
    List<Order> findByStatusAndCreatedAtAfter(OrderStatus status, LocalDateTime after);

    // 속성명이 엔티티와 다르면(예: oldStatus 필드가 없으면)
    // 컨텍스트 기동 시점에 PropertyReferenceException으로 실패한다
    List<Order> findByOldStatus(OrderStatus status);   // 컴파일은 되지만 기동 실패
}
```

공식 문서가 "Spring Data JPA does a property check and traverses nested properties"라고 명시하듯, 프레임워크가 이름을 검사해 엔티티 속성과 대조합니다. 오타 하나가 런타임 어딘가가 아니라 **애플리케이션 기동 실패**로 드러나므로, 여기서는 잘못된 이름이 곧 잘못된 프로그램입니다. 2장의 "그릇된 정보를 피하라"가 프레임워크 수준에서 강제되는 셈입니다.

## 같은 인사이트 패턴 — "이름이 곧 문서/계약"

이름 하나가 설명 전체를 실어 나른다는 인사이트는 이 위키의 여러 페이지에 이미 누적되어 있습니다.

| 위키 페이지 | 이름이 실어 나르는 것 | 이 페이지와의 접점 |
|-------------|----------------------|---------------------|
| (이 페이지) | 변수·클래스·메서드의 의도와 부수효과 | 2장 원칙 + N1~N7 |
| [[guide-code-authoring-and-review]] | "G19"·"N1"·"Item 18" — 리뷰 코드 한 마디가 책 한 권을 인용 | N1~N7이 그 리뷰 어휘의 이름(N) 카테고리 |
| [[concept-functional-interfaces]] | `Function`·`Supplier` 등 표준 어휘 재사용 → 학습·합의 비용 절감 | "모두가 아는 이름은 이름만 말해도 계약 전체가 전달"과 동일 원리 |
| [[concept-design-patterns]] | 패턴 이름(Strategy, Facade) = 팀 공용어 | 해법 영역 용어 사용(2.13)의 확장판 |
| [[entity-refactoring]] | 악취 1번이 "기이한 이름"(3.1), 처방은 6.5·6.7 이름 바꾸기 | 이름이 리팩터링의 출발점이라는 같은 진단 |
| [[entity-clean-code]] | "암묵 < 명시" — 가독성은 다음 사람이 한 번에 아는가에 달림 | 이름은 명시의 최소 단위 |

공통 원리는 하나입니다 — **공유된 이름은 그 자체로 압축된 문서**이고, 이름을 잘못 지으면 문서가 거짓말을 하는 것과 같습니다.

## 빠른 진단 체크리스트

- [ ] 이름만 보고 "무엇을/왜/어떻게"가 읽히는가? (N1·2.1)
- [ ] `Map`인데 `~List`처럼 타입 거짓 정보를 담고 있지 않은가? (2.2)
- [ ] `Info`/`Data`/`a1` 같은 불용어로 대충 구분하고 있지 않은가? (2.3)
- [ ] 매직 넘버를 검색 가능한 명명 상수로 바꿨는가? (2.5·G25)
- [ ] 인터페이스 `I` 접두어·헝가리식·`m_` 인코딩이 없는가? (2.6·N6)
- [ ] 조회·저장에 팀 전체가 같은 단어를 쓰는가? (2.11·G11)
- [ ] 이름 길이가 범위에 비례하는가 — 멤버 변수가 한 글자는 아닌가? (N5)
- [ ] 함수 이름에 숨은 부수효과가 없는가 — `And`가 보이면 분리 검토했는가? (N7)
- [ ] Spring Data 쿼리 메서드·JavaBeans 접근자처럼 이름이 프레임워크 계약인 자리에서 관례를 지켰는가? (N3)

## 원본 출처

- raw: `raw/clean-code/클린 코드 실전 강의 교재 2장.md` — 의미 있는 이름 (위키 정리본: [[lecture-clean-code-ch2]])
- raw: `raw/clean-code/클린 코드 실전 강의 교재 17장.md` — 냄새와 휴리스틱 중 N1~N7 (위키 정리본: [[lecture-clean-code-ch17]])
- 검증: [Spring Data JPA — Query Methods 공식 문서](https://docs.spring.io/spring-data/jpa/reference/jpa/query-methods.html) — 메서드 이름 파싱으로 쿼리 파생, "does a property check and traverses nested properties" 확인 (2026-07-04)
- 참고: *Effective Java* Item 1 (정적 팩터리 메서드) — 2.9 생성자 대신 이름 부여와 동일 처방

## 관련 페이지

- [[lecture-clean-code-ch2]] — 2장 전문 (비유·퀴즈 포함 강의 교재)
- [[lecture-clean-code-ch17]] — 17장 전체 휴리스틱 66개 (N 외 C·E·F·G·J·T)
- [[entity-clean-code]] — *Clean Code* 책 전체 지도, 5권 도서 오각형
- [[guide-code-authoring-and-review]] — PR 리뷰 어휘로서의 N1~N7 활용 (같은 인사이트 패턴)
- [[concept-functional-interfaces]] — 표준 어휘 재사용의 경제학 (같은 인사이트 패턴)
- [[concept-design-patterns]] — 패턴 이름 = 팀 공용어 (같은 인사이트 패턴)
- [[entity-refactoring]] — 악취 3.1 기이한 이름, 기법 6.5·6.7 이름 바꾸기
- [[entity-effective-java]] — Item 1 정적 팩터리, 표준 명명 관례
