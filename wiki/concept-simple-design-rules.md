---
title: 단순한 설계 4규칙 (Kent Beck)
type: concept
tags: [clean-code, kent-beck, simple-design, emergence, dry, refactoring, tdd]
sources: [clean-code/클린 코드 실전 강의 교재 12장.md]
created: 2026-07-04
updated: 2026-07-04
---

# 단순한 설계 4규칙 — 좋은 설계는 창발한다

## 정의

Kent Beck이 제시한 **"단순한 설계(Simple Design)"의 판정 기준 4가지**입니다. 설계 문서를 먼저 완성하는 대신, 코드가 매 순간 이 4가지 검사를 통과하도록 유지하면 좋은 설계가 **사후에 떠오른다(창발, emerge)** 는 관점의 핵심 도구입니다. *Clean Code* 12장(창발성)이 이 4규칙을 책 전체(1~11장)의 요약으로 제시합니다.

> **원출처**: 4규칙은 *Clean Code* 의 발명품이 아니라 Kent Beck이 1990년대 후반 XP(Extreme Programming)를 정립하며 만든 기준으로, 가장 권위 있는 출전은 *Extreme Programming Explained* 초판(1999)의 Simple Design 실천 절입니다. Clean Code 12장 자체도 Uncle Bob이 아니라 공저자 Jeff Langr가 집필한 장입니다.

## 4규칙 한눈에 (Clean Code 12장 기준 순서 = 중요 순)

| 순서 | 규칙 | 한 줄 의미 | 담당 영역 |
|------|------|-----------|----------|
| **1** | 모든 테스트를 실행하라 | 시스템이 의도대로 **작동함을 검증**할 수 있어야 합니다 | 작동·안전망 |
| **2** | 중복을 없애라 | 같은 코드·구조·알고리즘이 두 곳에 있으면 안 됩니다 | DRY |
| **3** | 프로그래머 의도를 표현하라 | 코드가 스스로 자기 목적을 말해야 합니다 | 가독성 |
| **4** | 클래스와 메서드 수를 최소로 줄여라 | 1·2·3을 지킨 위에서, 요소 수는 적을수록 좋습니다 | 최소 |

### 규칙별 실무 판단 기준

| 규칙 | 실무에서 이렇게 판정합니다 | 연결 |
|------|---------------------------|------|
| 1 테스트 | CI에서 전체 테스트가 항상 초록인가. 테스트하기 어려운 클래스(new 남발·전역 상태)가 있으면 이미 결합도가 높다는 신호입니다 | [[entity-tdd]]·Clean Code 9장 |
| 2 중복 | 같은 코드는 함수 추출(6.1), 같은 구조는 슈퍼클래스 추출(12.8) 또는 컴포지션, 같은 알고리즘은 추상화로 제거합니다 | [[entity-refactoring]] 악취 3.2 |
| 3 표현 | 이름이 책임을 말하는가, 함수·클래스가 작고 한 가지인가, `findBy*`·`is*` 같은 표준 명명을 따르는가, 테스트가 사용 예시 문서 역할을 하는가로 판정합니다 | [[entity-clean-code]] 2·3장 |
| 4 최소 | 단일 구현 인터페이스, 쓰이지 않는 확장 포인트, "나중에 필요할까 봐" 만든 계층이 보이면 제거 대상입니다 | [[entity-refactoring]] 악취 3.15 (추측성 일반화) |

### 순서 표기는 책마다 다릅니다

Martin Fowler의 정리(bliki: BeckDesignRules)는 "테스트 통과 → **의도 표현** → **중복 없음** → 최소 요소" 순으로 쓰고, Clean Code 12장은 중복 제거를 의도 표현보다 앞에 둡니다. Fowler 자신은 2·3번의 순서 논쟁에 대해 "둘은 서로를 정련하며 맞물리므로 순서는 중요하지 않다"고 정리합니다. 이 페이지는 위키의 원 소스인 [[lecture-clean-code-ch12]]를 따라 Clean Code 순서로 표기합니다. 어느 표기든 **1번(테스트)이 첫째, 4번(최소)이 마지막**이라는 점은 동일합니다.

## 창발적 설계 — 규칙이 설계를 낳습니다

집을 짓는 현장을 떠올려 보겠습니다. 좋은 집은 천재 건축가가 첫날 그린 완벽한 도면에서 나오지 않습니다. 대신 검사관이 매 공정이 끝날 때마다 현장에 옵니다. 배선이 규격에 맞는지 재고, 같은 배관이 쓸데없이 두 번 지나가지 않는지 확인하고, 도면과 실물이 일치해 다음 작업자가 헤매지 않을지 보고, 불필요한 기둥이 서 있지 않은지 살핍니다. 어느 한 공정도 검사를 건너뛰지 않았을 뿐인데, 준공일에 돌아보면 구조가 좋은 집이 서 있습니다.

단순한 설계 4규칙이 바로 이 검사표입니다. 매 공정의 검사가 규칙 1~4이고, 공정 하나가 커밋 하나입니다. 좋은 설계는 "설계하는 날"에 만들어지는 것이 아니라, 모든 커밋이 4가지 검사를 통과한 결과로 **나중에 드러납니다**. 이것이 창발(emergence)입니다. 큰 설계 한 번이 아니라 작은 정련의 누적이 구조를 만든다는 이 관점은 [[entity-tdd]]의 빨강·초록·리팩터 사이클, [[entity-refactoring]]의 "큰 아키텍처도 작은 리팩터링의 누적으로 도달한다"(2.6)와 정확히 같은 결론입니다.

## 규칙이 충돌할 때 — 우선순위와 흔한 오독

규칙끼리 부딪히면 **번호가 곧 우선순위**입니다.

| 충돌 상황 | 판정 |
|-----------|------|
| 중복을 제거하면 테스트가 깨진다 | 제거하지 않습니다. 테스트(1) > 중복 제거(2) — 안전망 없는 정련은 리팩터링이 아니라 도박입니다 |
| 중복을 제거했더니 이름 없는 범용 헬퍼가 생겼다 | 추출 조각에 의도가 드러나는 이름을 붙일 수 있을 때까지 쪼갭니다. 2와 3은 맞물려 있어 보통 함께 좋아집니다 |
| 클래스를 합치면 수는 줄지만 책임이 섞인다 | 합치지 않습니다. 표현(3) > 최소화(4) — 작은 클래스 여럿이 거대 클래스 하나보다 낫습니다 (Clean Code 10장) |

### 4번 규칙의 흔한 오독

"클래스와 메서드 수를 최소로"를 **클래스 수 줄이기가 목적**이라고 읽으면 정반대의 코드가 나옵니다. 1,000줄짜리 God 클래스 하나가 명목상 "최소"이기 때문입니다. 4번 규칙의 진짜 의미는 Fowler의 표현이 정확합니다 — **"앞의 세 규칙에 봉사하지 않는 요소를 제거하라"**. 즉 테스트·중복 제거·의도 표현에 기여하지 않는 인터페이스, 추측성 확장 포인트, 빈 계층을 걷어내라는 뜻이지, 응집도를 희생해 파일 수를 줄이라는 뜻이 아닙니다. 4번은 언제나 1·2·3을 충족한 **다음의** 최소화입니다.

## Java 예제 — 중복 제거가 의도 표현을 데려옵니다

주문 결제 금액과 미리보기 금액을 따로 계산하는 서비스입니다. 두 메서드에 같은 계산이 복사되어 있습니다.

**참고 코드 (Before)** — 규칙 2 위반이 규칙 3 위반을 함께 만든 상태입니다.

```java
public class OrderService {

    public int checkoutPrice(Order order) {
        int total = 0;
        for (OrderLine line : order.lines()) {
            total += line.unitPrice() * line.quantity();
        }
        if (order.customer().isVip()) {
            total = total - (total * 10 / 100);  // 10이 뭔지 코드가 말하지 않음
        }
        return total;
    }

    public int previewPrice(Order order) {
        int total = 0;
        for (OrderLine line : order.lines()) {
            total += line.unitPrice() * line.quantity();
        }
        if (order.customer().isVip()) {
            total = total - (total * 10 / 100);  // 같은 계산이 두 번째
        }
        return total;
    }
}
```

**참고 코드 (After)** — 함수 추출([[entity-refactoring]] 6.1) 한 가지 변환으로 두 규칙이 함께 좋아진 상태입니다.

```java
public class OrderService {

    private static final int VIP_DISCOUNT_PERCENT = 10;

    public int checkoutPrice(Order order) {
        return priceWithDiscount(order);
    }

    public int previewPrice(Order order) {
        return priceWithDiscount(order);
    }

    private int priceWithDiscount(Order order) {
        int total = sumLineTotals(order);
        return order.customer().isVip() ? applyVipDiscount(total) : total;
    }

    private int sumLineTotals(Order order) {
        return order.lines().stream()
                .mapToInt(line -> line.unitPrice() * line.quantity())
                .sum();
    }

    private int applyVipDiscount(int total) {
        return total - total * VIP_DISCOUNT_PERCENT / 100;
    }
}
```

중복을 없애려고 공통 조각을 추출하는 순간 그 조각에 **이름을 붙여야만 하고**, `sumLineTotals`·`applyVipDiscount`·`VIP_DISCOUNT_PERCENT`라는 이름이 붙는 순간 주석 없이 의도가 드러납니다. 규칙 2가 규칙 3을 데려오는 전형적인 장면입니다. 메서드 수는 2개에서 5개로 늘었지만 4번 규칙 위반이 아닙니다 — 각 메서드가 1·2·3에 봉사하기 때문입니다. 그리고 이 변환 전체는 `checkoutPrice`·`previewPrice`의 테스트가 초록일 때만 안전합니다 — 매 단계에서 규칙 1이 나머지를 떠받칩니다.

## 같은 인사이트 패턴 — "테스트가 설계 개선의 안전망"

규칙 1이 첫째인 이유는 위키의 다른 페이지에 이미 누적된 결론과 같습니다. **검증 수단이 없으면 정련할 자유도 없습니다.**

| 영역 | 안전망 | 안전망이 허락하는 것 | 참조 |
|------|--------|---------------------|------|
| **단순 설계 4규칙** | 규칙 1 (모든 테스트 통과) | 규칙 2·3·4의 정련 (창발) | (이 페이지) |
| **리팩터링** | 4장 자가 테스트 코드 | 외부 동작 보존을 증명하며 구조 개선 | [[entity-refactoring]] "테스트 없이는 리팩터링 못 한다" |
| **TDD** | 빨강 → 초록의 초록 막대 | 사이클 셋째 단계(리팩터)의 과감함 | [[entity-tdd]] 빨강·초록·리팩터 |
| **AI 루프** | 테스트·타입체크의 거부 신호 | 에이전트 자동 수정 루프의 발산 방지 | [[concept-loop-engineering]] |
| **Spring 실무** | 슬라이스·통합 테스트 | 의존성 업그레이드·구조 변경 | [[src-spring-testing-ref]] |

세 책이 같은 자리를 서로 다른 문장으로 가리킵니다. Beck(4규칙·TDD)은 "테스트가 첫째"라 하고, Fowler(리팩터링)는 "테스트 없이는 리팩터링이 아니다"라 하고, Clean Code 12장은 둘을 "창발"이라는 한 단어로 묶습니다. 한편 4규칙이 도달하는 종착지 — 작고, 이름이 책임을 말하는 클래스 — 는 [[entity-object]]의 책임 주도 설계가 처음부터 겨냥하는 바로 그 그림이라는 점에서, 5권 세트 안에서 이 규칙은 "목적지(오브젝트)로 가는 매 커밋의 검사표" 자리에 놓입니다.

## 빠른 진단 — 4규칙 셀프 체크

- [ ] CI에서 전체 테스트가 항상 통과하는가 (규칙 1)
- [ ] 새 PR에 같은 코드·구조가 두 곳에 들어가지 않았는가 (규칙 2)
- [ ] 함수·클래스·상수 이름만 읽고 의도를 알 수 있는가 (규칙 3)
- [ ] 구현이 하나뿐인 인터페이스, 쓰지 않는 확장 포인트가 있는가 (규칙 4)
- [ ] "클래스 수를 줄이자"는 리뷰 코멘트가 응집도를 해치고 있지 않은가 (4번 오독)

## 원본 출처

- `raw/clean-code/클린 코드 실전 강의 교재 12장.md` — 위키 내 발췌: [[lecture-clean-code-ch12]]
- Kent Beck, *Extreme Programming Explained* 1st ed. (1999) — 4규칙의 원출전
- Martin Fowler, bliki "BeckDesignRules" (https://martinfowler.com/bliki/BeckDesignRules.html) — 순서 논쟁 정리·4번 규칙 해석 (2026-07-04 확인)

## 관련 페이지

- [[lecture-clean-code-ch12]] — 이 개념의 원 소스 (Clean Code 12장 창발성)
- [[entity-clean-code]] — *Clean Code* 전체 지도 (12장 = 1~11장의 요약)
- [[entity-refactoring]] — 규칙 2·3·4를 실행하는 카탈로그, 4장 = 규칙 1의 근거
- [[entity-tdd]] — 규칙 1을 사이클로 만든 원전, "설계가 창발"의 실습판
- [[entity-object]] — 4규칙의 종착지인 책임 주도 설계
- [[concept-loop-engineering]] — "안전망(거부 신호) 없는 자동 루프는 발산" 패턴의 AI 확장
