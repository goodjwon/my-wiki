---
title: "Clean Code 실전 강의 — 2장"
type: source
tags: [book, clean-code, uncle-bob, lecture]
sources: [clean-code/클린 코드 실전 강의 교재 2장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 클린 코드 실전 강의 교재

## 2장 — 의미 있는 이름

> **원서**: 로버트 C. 마틴 『Clean Code』 **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 원칙 → 비유 → before/after 예시 → 현업 메모 → 핵심 교훈 → 체크리스트 → 퀴즈(정답 분리)

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 변수·함수·클래스 이름만 보고도 **의도가 읽히는** 이름을 짓는다.
- 그릇된 정보·불용어·인코딩 같은 **이름의 함정**을 피한다.
- 클래스(명사)·메서드(동사) 명명 규칙과 **일관성**을 몸에 익힌다.

### 0.2 큰 그림 — 이름은 "표지판"

이름은 코드 곳곳에 붙은 **표지판**입니다. 좋은 표지판은 한 번에 길을 알려주고, 나쁜 표지판(그릇된 정보)은 사람을 엉뚱한 곳으로 보냅니다. 이름은 가장 자주 마주치고, 가장 싸게 고칠 수 있는 품질 지점입니다.

```
[ 드러내라 ]            [ 헷갈리게 말라 ]          [ 일관·맥락 ]
 의도 드러내기           그릇된 정보 피하기          한 개념 한 단어
 발음/검색 쉽게          의미 있게 구분             맥락 추가/불필요한 맥락 제거
 인코딩 피하기           기발한 이름·말장난 금지     해법/문제 영역 용어
```

### 0.3 현업에서 왜 중요한가

- Repository 메서드, DTO 필드, 빈 이름의 **일관성**이 깨지면 팀 전체가 매번 코드를 다시 읽습니다.
- 리팩터링 3장의 첫 악취가 "**기이한 이름**"이었습니다. 이름은 리팩터링의 출발점입니다.

---

## 2.1 의도를 분명히 밝혀라

### 비유 — "라벨 없는 약병"

`int d;`는 라벨 없는 약병입니다. 무슨 약(값)인지 매번 본문을 뒤져야 합니다.

```java
// before: 무엇을 담는 변수인지, 단위는 무엇인지 알 수 없다
int d; // 경과 시간(일)

// after: 이름이 곧 설명서
int elapsedTimeInDays;
int daysSinceCreation;
```

좋은 이름은 "이게 무엇이고, 무엇을 하며, 어떻게 쓰는가"를 **주석 없이** 답합니다. 주석으로 변수를 설명하고 싶어지면, 그건 이름을 고치라는 신호입니다.

---

## 2.2 그릇된 정보를 피하라

### 비유 — "잘못된 표지판"

틀린 표지판은 표지판이 없는 것보다 나쁩니다.

- 실제 `List`가 아닌데 `accountList`라 부르지 마라 → `accounts`.
- 서로 거의 같은 긴 이름(`...HandlingOfStrings` vs `...StorageOfStrings`)은 구분이 안 된다.
- 소문자 `l`, 대문자 `O`는 숫자 1·0과 헷갈리니 변수명으로 쓰지 마라.

```java
// before: List가 아니면 'List'라는 거짓 정보
Map<String, Account> accountList;
// after
Map<String, Account> accountsById;
```

---

## 2.3 의미 있게 구분하라

### 비유 — "불용어로 채운 빈칸"

`Info`, `Data`, `a1/a2`, `theMessage` 같은 **불용어(noise word)**는 구분에 아무 도움이 안 됩니다.

```java
// before: 무엇이 다른지 알 수 없는 세 메서드
getActiveAccount();
getActiveAccounts();
getActiveAccountInfo();   // Info? 위와 뭐가 다른가?

// after: 호출부가 의도로 선택할 수 있게
findActiveAccount(id);
findAllActiveAccounts();
```

`ProductInfo`와 `ProductData`처럼 의미 없이 갈린 이름도 금물입니다. 읽는 사람이 차이를 **추측**해야 한다면 실패입니다.

---

## 2.4 발음하기 쉬운 이름을 사용하라

### 비유 — "동료에게 소리 내어 말할 수 있는가"

이름은 회의·페어프로그래밍에서 **입으로 말해집니다.** 발음할 수 없으면 토론할 수 없습니다.

```java
// before: "젠와이엠디에이치엠에스"...?
Date genymdhms;
// after: 그대로 읽힌다
Date generationTimestamp;
```

---

## 2.5 검색하기 쉬운 이름을 사용하라

### 비유 — "본문에서 한 번에 찾을 수 있는가"

한 글자 변수나 매직 넘버는 `grep`/IDE 검색에 걸리지 않습니다.

```java
// before: 7이 무엇인지, 어디서 쓰이는지 검색 불가
for (int j = 0; j < 34; j++) s += (t[j] * 4) / 5;

// after: 이름이 검색 가능하고 의미를 담는다
static final int WORK_DAYS_PER_WEEK = 5;
static final int NUMBER_OF_TASKS = 34;
int realDaysPerIdealDay = 4;
for (int task = 0; task < NUMBER_OF_TASKS; task++) {
    int realTaskDays = taskEstimate[task] * realDaysPerIdealDay;
    sum += realTaskDays / WORK_DAYS_PER_WEEK;
}
```

> **연결**: 매직 넘버를 명명 상수로 — 리팩터링 9.6(매직 리터럴 바꾸기), 클린코드 17장 G25와 같은 규칙.

---

## 2.6 인코딩을 피하라

### 비유 — "이름에 군더더기 메타데이터 붙이기"

타입·범위를 이름에 욱여넣던 옛 관습은, 현대 IDE에서는 잡음일 뿐입니다.

- **헝가리식 표기법**: `strName`, `iCount`, `m_dsc` → 타입이 바뀌면 이름이 거짓이 됩니다. IDE가 타입을 알려주므로 불필요.
- **멤버 변수 접두어** `m_`: 클래스가 작고 IDE가 색으로 구분하므로 필요 없음.
- **인터페이스/구현**: 인터페이스에 `IShapeFactory`처럼 `I`를 붙이지 마라. 클라이언트는 그것이 인터페이스인지 몰라도 된다. 굳이 인코딩해야 한다면 **구현 클래스 쪽**에 표시한다.

```java
// before
interface IShapeFactory { ... }
class ShapeFactory implements IShapeFactory { ... }

// after: 인터페이스가 더 깨끗한 이름을 갖는다
interface ShapeFactory { ... }
class ShapeFactoryImpl implements ShapeFactory { ... }   // 또는 구체적인 구현명
```

---

## 2.7 자신의 기억력을 자랑하지 마라

### 비유 — "독자에게 암산을 시키지 마라"

`r`이 "소문자화한 URL"이라는 걸 독자가 머릿속으로 매핑(mental mapping)하게 만들지 마세요. 똑똑한 프로그래머가 아니라 **명료한 프로그래머**가 됩시다.

- 루프 카운터 `i, j, k`는 범위가 짧을 때 관례상 허용됩니다(전통적 의미가 있으니까).
- 그 외에 한 글자 변수로 독자가 의미를 외우게 하는 것은 피합니다.

---

## 2.8 클래스 이름

### 핵심 — **명사 / 명사구**

- 좋음: `Customer`, `WikiPage`, `Account`, `AddressParser`.
- 피하기: `Manager`, `Processor`, `Data`, `Info` 같은 **모호한 단어**. 동사는 클래스명에 쓰지 않는다.

> **현업 메모**: `XxxManager`/`XxxService`가 거대해지면 보통 책임이 여러 개라는 신호입니다(10장 단일 책임). 도메인 명사로 쪼개세요.

---

## 2.9 메서드 이름

### 핵심 — **동사 / 동사구**

- `postPayment`, `deletePage`, `save`. 접근자·변경자·조건자는 표준 규약을 따른다: `getName`, `setName`, `isPosted`.
- **생성자 오버로드가 헷갈리면 정적 팩터리 메서드**로 이름을 부여하라.

```java
// before: 무엇을 받는 생성자인지 호출부가 외워야 함
Complex point = new Complex(23.0);
// after: 이름이 의도를 드러냄
Complex point = Complex.fromRealNumber(23.0);
```

> **이펙티브 자바 연결**: 이 규칙이 바로 **EJ 아이템 1(생성자 대신 정적 팩터리 메서드)**입니다. 두 책이 같은 처방을 공유합니다.

---

## 2.10 기발한 이름은 피하라

### 비유 — "농담은 한 번이지만 코드는 영원하다"

`whack()`(=kill), `eatMyShorts()`(=abort), `holyHandGrenade`(=deleteItems) 같은 재치 있는 이름은 그 농담을 모르는 사람에게는 암호입니다. **재미보다 명료함.**

```java
// after
account.kill();      // not whack()
process.abort();     // not eatMyShorts()
```

---

## 2.11 한 개념에 한 단어를 사용하라

### 비유 — "같은 일에 같은 단어"

조회를 어떤 클래스에선 `fetch`, 어떤 데선 `retrieve`, 또 다른 데선 `get`으로 쓰면 독자는 매번 "차이가 있나?" 의심합니다.

```java
// before: 같은 '조회'인데 단어가 제각각
userRepository.fetchById(id);
orderRepository.retrieveById(id);
itemRepository.getById(id);

// after: 한 개념엔 한 단어 (팀 컨벤션으로 통일)
userRepository.findById(id);
orderRepository.findById(id);
itemRepository.findById(id);
```

`Controller`/`Manager`/`Driver`가 섞여 있어도 같은 혼란이 옵니다. 하나로 정하세요.

---

## 2.12 말장난을 하지 마라

### 비유 — "한 단어, 한 뜻"

2.11의 짝입니다. "한 단어를 일관되게"는 좋지만, **다른 개념에 같은 단어를 재사용**하면 안 됩니다.

```java
// add가 곳곳에서 '더하기'였는데, 여기선 컬렉션 끝에 '삽입'이라면?
list.add(item);     // 이건 삽입 → append/insert가 더 정확
total = add(a, b);  // 이건 산술 더하기
```

의미가 다르면 단어도 달라야 합니다(`add` vs `append`/`insert`).

---

## 2.13 해법 영역에서 가져온 이름을 사용하라

### 핵심

코드를 읽는 사람은 **프로그래머**입니다. 자료구조·패턴·알고리즘 같은 **전산 용어(해법 영역)**는 적극 사용하세요. 그게 가장 정확한 소통입니다.

```java
class AccountVisitor { ... }   // 방문자 패턴임을 즉시 전달
BlockingQueue<Job> jobQueue;   // 동시성 큐임을 전달
```

---

## 2.14 문제 영역에서 가져온 이름을 사용하라

### 핵심

적절한 전산 용어가 없으면, **도메인(문제 영역) 용어**를 씁니다. 도메인 전문가가 이해하는 이름이라야 합니다.

```java
// 공공 계약 도메인 용어를 그대로
class ContractAward { ... }      // 낙찰
class LiquidatedDamages { ... }  // 지체상금
```

> **현업 메모**: 해법 영역 용어와 문제 영역 용어를 **구분**해 쓰면, 독자가 "이건 기술 개념" "이건 업무 개념"을 즉시 분간합니다.

---

## 2.15 의미 있는 맥락을 추가하라

### 비유 — "단어 하나만으로는 길을 못 찾는다"

`state` 변수 하나만 보면 그게 "주소의 시/도"인지 "상태값"인지 모릅니다. 맥락이 필요합니다.

```java
// before: 흩어진 변수들 — state가 무슨 state인지 모호
String firstName, lastName, street, city, state, zipcode;

// after: 클래스로 묶어 맥락 부여 → 'Address의 state'임이 분명
class Address {
    String street, city, state, zipcode;
}
```

맥락이 정 부족하면 접두어(`addrState`)도 차선책이지만, **클래스로 묶는 것**이 정석입니다.

---

## 2.16 불필요한 맥락을 없애라

### 비유 — "모든 방에 회사 이름을 붙이지 마라"

프로젝트가 "GSD"라고 해서 모든 클래스에 `GSD` 접두어를 붙이면, 자동완성이 `GSD...`로 도배되어 오히려 검색을 방해합니다.

```java
// before: 과한 맥락
class GSDAccountAddress { ... }
// after: 짧고 충분
class Address { ... }
```

의미를 해치지 않는 한, 이름은 **짧을수록** 좋습니다.

---

## 핵심 교훈

1. 이름은 **의도를 드러내야** 한다 — 주석으로 변수를 설명하고 싶으면 이름을 고쳐라.
2. 그릇된 정보·불용어(Info/Data)·인코딩(헝가리식·`m_`·`I`접두어)을 피하라.
3. **발음·검색** 가능한 이름을 써라(매직 넘버 → 명명 상수).
4. **클래스=명사, 메서드=동사**. 생성자 대신 정적 팩터리로 이름 부여(EJ 1).
5. **한 개념엔 한 단어**(2.11), **한 단어엔 한 뜻**(2.12) — 일관성이 생명.
6. 해법/문제 영역 용어를 구분해 쓰고, 변수는 **클래스로 묶어 맥락**을 준다.

---

## 체크리스트 (이름 리뷰용)

- [ ] 이름만 보고 "무엇/무엇을/어떻게"가 읽히는가
- [ ] 타입이 아닌데 `...List`처럼 거짓 정보를 담고 있지 않은가
- [ ] `Info`/`Data`/`a1` 같은 불용어로 대충 구분하고 있지 않은가
- [ ] 매직 넘버를 명명 상수로 바꿨는가(검색 가능)
- [ ] 인터페이스에 `I` 접두어, 필드에 `m_` 같은 인코딩이 없는가
- [ ] 조회/저장 등에 팀 전체가 **같은 단어**를 쓰는가
- [ ] 변수 묶음을 클래스로 묶어 맥락을 줬는가, 불필요한 접두어는 없는가

---

## 퀴즈

1. `Map<String, Account> accountList;`의 이름에서 무엇이 잘못됐고 어떻게 고치는가?
2. `getActiveAccount()`, `getActiveAccounts()`, `getActiveAccountInfo()`가 함께 있을 때의 문제는?
3. 인터페이스 이름에 `I`를 붙이지 말라는 이유는?
4. 생성자 오버로드가 헷갈릴 때 클린코드(와 이펙티브 자바)가 권하는 처방은?
5. "한 개념에 한 단어"(2.11)와 "말장난을 하지 마라"(2.12)는 어떻게 짝을 이루는가?

### 정답·해설

1. 실제 타입이 `List`가 아닌데 `List`라는 **그릇된 정보**를 담습니다. `accountsById`처럼 실제 자료구조/키를 반영해 고칩니다.
2. `Info`/복수형 차이만으로는 무엇이 다른지 알 수 없어, 호출부가 차이를 **추측**해야 합니다. `findActiveAccount(id)` / `findAllActiveAccounts()`처럼 의미로 구분되게 합니다.
3. `I` 접두어는 **인코딩(잡음)**이며, 클라이언트는 그것이 인터페이스인지 알 필요가 없습니다. 인터페이스가 더 깨끗한 이름을 갖게 두고, 굳이 표시하려면 구현 클래스 쪽에 합니다.
4. **정적 팩터리 메서드**로 이름을 부여합니다(예: `Complex.fromRealNumber(23.0)`). 이는 이펙티브 자바 **아이템 1**과 동일한 처방입니다.
5. 2.11은 "같은 개념엔 늘 같은 단어"(fetch/retrieve/get 혼용 금지), 2.12는 "같은 단어를 다른 개념에 재사용 금지"(add를 산술과 삽입에 동시 사용 금지). 즉 **단어↔개념을 1:1로** 묶으라는 한 원칙의 양면입니다.

---

## 다음 장 예고 — 3장: 함수

이 책에서 가장 유명한 장입니다. **작게 만들어라, 한 가지만 해라, 추상화 수준을 하나로, 인수는 적게, 부수 효과 금지, 명령과 조회 분리**. 리팩터링의 "함수 추출"과 직결되며, 1장 워크스루의 원리를 규칙으로 정리합니다.