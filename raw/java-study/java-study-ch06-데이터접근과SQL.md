# 6. 데이터접근과SQL
원본: Notion 데이터베이스 "[2024-2025]java 스터디 자료"

---

## 6.0 데이터베이스 설계

#### 개요

이 문서는 서비스 요구사항을 관계형 데이터베이스 구조로 옮길 때 어떤 순서와 기준으로 설계해야 하는지 정리한 출판용 가이드입니다. JPA를 쓰든 MyBatis를 쓰든, 결국 애플리케이션은 **잘 설계된 테이블과 제약조건 위에서만 안정적으로 동작**합니다.

초중급 개발자는 종종 엔티티 클래스부터 만들고 나중에 테이블을 맞추려 합니다. 하지만 실제로는 반대가 더 안전합니다. 먼저 저장해야 할 사실과 관계를 분리하고, 그다음 애플리케이션 코드를 얹어야 합니다.

#### 왜 데이터베이스 설계가 먼저인가

잘못된 DB 설계는 아래 문제를 거의 항상 함께 부릅니다.

- 같은 사실이 여러 테이블과 컬럼에 중복 저장됩니다.
- 조회는 되지만 수정 시 데이터가 어긋납니다.
- FK가 없어 고아 데이터가 남습니다.
- 인덱스 없이 조회가 느려지고, 뒤늦게 응급처방이 붙습니다.
즉, DB 설계는 저장소 구조만의 문제가 아니라 도메인 모델, 쿼리, 운영 안정성까지 이어지는 출발점입니다.

#### 1. 요구사항을 테이블이 아니라 개체와 관계로 읽어야 한다

예를 들어 도서 주문 서비스를 만든다고 가정하면 처음에는 아래 개체가 보입니다.

- 회원
- 도서
- 주문
- 주문 항목
- 결제
- 배송
이 단계에서는 컬럼부터 정하지 않습니다. 먼저 무엇이 독립된 개체인지, 무엇이 관계를 표현하는 중간 구조인지 분리해야 합니다.

가장 흔한 실수는 주문에 여러 도서를 담는 구조를 `book_ids = "1,2,3"` 같은 문자열이나 JSON으로 임시 저장해 버리는 것입니다. 이렇게 시작하면 검색, 집계, 무결성 검증, 수정 로직이 전부 복잡해집니다.

#### 2. 관계형 설계의 핵심은 책임 분리다

좋은 테이블은 "필드를 많이 담는 테이블"이 아니라 **한 가지 책임이 분명한 테이블**입니다.

- `members`: 회원 자체의 정보
- `books`: 도서 자체의 정보
- `orders`: 주문 행위 자체의 정보
- `order_items`: 주문과 도서의 연결, 수량과 주문 시점 가격
이 기준이 잡히면 자연스럽게 관계도 정리됩니다.

```plain text
members 1 --- N orders
orders  1 --- N order_items
books   1 --- N order_items
```

`order_items`가 필요한 이유는 주문과 도서가 논리적으로 다대다 관계이기 때문입니다. 관계형 데이터베이스에서는 이런 구조를 보통 **중간 테이블로 푼다**고 이해하면 됩니다.

#### 3. PK와 FK는 단순 문법이 아니라 규칙이다

##### PK는 행의 정체성을 보장한다

PK는 한 행을 유일하게 구분하는 기준입니다. 실무에서는 보통 대체키를 PK로 두고, 이메일 같은 비즈니스 식별자는 `UNIQUE`로 별도 관리하는 편이 안정적입니다.

##### FK는 참조 무결성을 강제한다

FK는 "이 값이 저쪽 테이블에 실제로 존재해야 한다"는 규칙입니다. 애플리케이션 코드로만 검증하고 DB에는 FK를 두지 않으면, 결국 데이터 정합성이 느슨해집니다.

```sql
CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL,
    ordered_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_orders_member
        FOREIGN KEY (member_id) REFERENCES members(id)
);
```

관계형 DB는 `PRIMARY KEY`, `UNIQUE`, `NOT NULL`, `CHECK`, `FOREIGN KEY` 같은 제약조건으로 데이터를 보호할 수 있습니다. 이 규칙은 애플리케이션 안에만 두기보다 DB에도 함께 두는 편이 더 강합니다.

#### 4. 정규화는 먼저, 역정규화는 나중이다

정규화의 목적은 이론 시험을 통과하는 것이 아니라, **중복과 이상 현상을 줄이는 것**입니다.

정규화를 먼저 하는 이유는 단순합니다.

- 같은 사실을 한 곳에만 저장하게 해줍니다.
- 수정 시 누락 가능성을 줄여줍니다.
- 엔티티 책임이 더 분명해집니다.
예를 들어 상품명과 상품 가격을 주문 테이블마다 복제하면 처음에는 조회가 편해 보일 수 있습니다. 하지만 상품명이 바뀌거나 가격 정책이 달라질 때 어떤 값을 현재 기준으로 볼지, 주문 당시 기준으로 볼지 혼란이 생깁니다.

다만 실무에서는 항상 정규화만이 답은 아닙니다. 읽기 성능이 매우 중요하고, 집계 비용이 큰 값을 반복해서 보여줘야 할 때는 역정규화를 고려할 수 있습니다. 하지만 그 판단은 **정규화된 설계와 실제 조회 병목을 먼저 확인한 뒤**에 하는 편이 맞습니다.

#### 5. 인덱스는 나중 옵션이 아니라 설계의 일부다

초보 단계에서는 테이블만 만들고 인덱스를 튜닝 단계의 일로 미루기 쉽습니다. 하지만 실제로는 인덱스도 설계의 일부입니다.

인덱스를 먼저 의식해야 하는 대표 상황은 아래와 같습니다.

- FK로 조인되는 컬럼
- `WHERE` 조건에 반복적으로 등장하는 컬럼
- 정렬과 페이징 기준 컬럼
- 유일성을 보장해야 하는 컬럼
```sql
CREATE INDEX idx_orders_member_id_ordered_at
    ON orders(member_id, ordered_at DESC);
```

이 인덱스는 "회원의 최근 주문 목록"처럼 자주 나오는 조회 패턴을 염두에 둔 예시입니다. 즉, 인덱스는 막연히 많이 만드는 것이 아니라 **실제 접근 경로를 기준으로 배치**해야 합니다.

반대로 인덱스가 너무 많으면 쓰기 비용이 늘고 관리도 어려워집니다. 조회 성능만 보고 무제한으로 추가하는 방식은 오래 못 갑니다.

#### 6. 컬럼 설계도 의미 중심으로 해야 한다

컬럼 이름은 짧은 것보다 **뜻이 분명한 것**이 중요합니다.

좋은 예시:

- `created_at`
- `ordered_at`
- `total_amount`
- `stock_quantity`
- `delivery_status`
피해야 할 예시:

- `value1`
- `data`
- `info`
- `flag`
또한 한 컬럼에는 한 가지 의미만 담아야 합니다. 예를 들어 여러 상품 ID를 문자열에 이어 붙여 넣거나, 주소 전체를 무조건 한 칸에만 몰아넣는 방식은 이후 검색과 검증을 어렵게 만듭니다.

#### 7. 예제 스키마로 보면 더 분명하다

아래는 도서 주문 도메인을 단순화한 예시입니다.

```sql
CREATE TABLE members (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE books (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL,
    ordered_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_orders_member
        FOREIGN KEY (member_id) REFERENCES members(id)
);

CREATE TABLE order_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    order_price NUMERIC(10, 2) NOT NULL CHECK (order_price >= 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_order_items_book
        FOREIGN KEY (book_id) REFERENCES books(id),
    CONSTRAINT uq_order_items_order_book UNIQUE (order_id, book_id)
);

CREATE INDEX idx_orders_member_id_ordered_at
    ON orders(member_id, ordered_at DESC);
```

이 예시에서 중요한 포인트는 세 가지입니다.

- 다대다 관계를 `order_items`로 풀었다.
- 애플리케이션 규칙 일부를 `CHECK`, `UNIQUE`, `FK`로 DB에 반영했다.
- 조회 패턴을 고려해 인덱스를 함께 설계했다.
#### 8. JPA를 쓰더라도 DB 설계 감각은 따로 필요하다

JPA를 사용하면 테이블과 엔티티를 자동으로 연결하기 쉬워집니다. 하지만 JPA가 설계를 대신해 주지는 않습니다.

보통 아래처럼 대응된다고 이해하면 됩니다.

- 테이블 -> 엔티티
- PK/FK -> 식별자와 연관관계
- `UNIQUE`, `NOT NULL` -> 도메인 제약과 DB 제약
- 금액, 주소 -> 값 객체 후보
즉, 좋은 엔티티 설계는 좋은 DB 설계 위에서 나옵니다. 엔티티 코드만 예쁘게 짠다고 구조 문제가 사라지지 않습니다.

#### 자주 하는 실수

- 다대다 관계를 문자열 배열이나 JSON 한 칸으로 처리하는 것
- FK 없이 애플리케이션 코드만 믿는 것
- 상태값을 의미 없는 숫자로만 저장해 해석을 외부에 떠넘기는 것
- 모든 조회를 나중에 해결하겠다고 인덱스를 설계에서 완전히 빼는 것
- 정규화도 하지 않은 채 너무 빨리 역정규화를 시작하는 것
#### 함께 보면 좋은 부록 실습

- [추가시나리오 예제](https://www.notion.so/1d21e21f383680baa0aef5472cc2d448)
이 문서는 본문에서 설명한 `개체 -> 관계 -> 제약조건 -> 인덱스` 기준을 다른 도메인에 다시 적용해 보는 연습 자료입니다. 첫 시나리오는 예시처럼 읽고, 뒤 시나리오는 직접 설계해 보는 방식으로 활용하면 좋습니다.

#### 공식 문서 기준으로 더 보면 좋은 자료

- [PostgreSQL Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [PostgreSQL Indexes](https://www.postgresql.org/docs/current/indexes.html)
#### 정리

데이터베이스 설계는 ERD를 예쁘게 그리는 작업이 아니라, 서비스의 규칙과 관계를 **중복 없이, 무결하게, 조회 가능하게** 구조화하는 과정입니다. 초중급 개발자에게 가장 중요한 기준은 "테이블 수가 적은가"가 아니라, **책임이 섞이지 않았는가**입니다.

#### 한 줄 정리

좋은 DB 설계는 컬럼을 많이 아는 것보다, `개체`, `관계`, `제약조건`, `인덱스`를 한 흐름으로 설계하는 데서 시작합니다.


---

## 6.0-1 추가시나리오 예제

### 시나리오 1: 온라인 학습 플랫폼

"우리 서비스는 학생과 교사가 온라인에서 효과적으로 학습할 수 있는 교육 플랫폼을 목표로 합니다. 사용자는 학생과 교사로 구분되어 회원가입 및 로그인할 수 있어야 합니다. 교사는 다양한 주제의 강의를 생성하고, 각 강의에는 제목, 설명, 난이도, 대상 학년이 포함되어야 합니다.

강의 내에서 교사는 여러 개의 강의 자료(문서, 비디오, 퀴즈 등)를 업로드할 수 있어야 하며, 각 자료는 특정 순서로 정렬되어야 합니다. 학생들은 강의에 등록하고, 진도율을 확인할 수 있어야 합니다.

상호작용을 위해 학생들은 각 강의 자료에 질문을 남길 수 있으며, 교사나 다른 학생들이 이에 답변할 수 있어야 합니다. 또한 질문에 대한 추가 질문(대댓글)도 가능해야 합니다.

효과적인 학습 관리를 위해 각 학생의 퀴즈 점수와 과제 제출 현황을 추적할 수 있어야 하며, 교사는 전체 학생의 성취도를 대시보드에서 확인할 수 있어야 합니다.

마지막으로, 검색 기능을 통해 학생들이 관심 있는 주제나 키워드로 강의를 찾을 수 있도록 각 강의에는 여러 주제 태그를 지정할 수 있어야 합니다."



### 온라인 학습 플랫폼 테이블 정의서

#### 1. 사용자(users)

<!-- table -->
#### 2. 학생(students)

<!-- table -->
#### 3. 교사(teachers)

<!-- table -->
#### 4. 강의(courses)

<!-- table -->
#### 5. 강의 자료(course_contents)

<!-- table -->
#### 6. 문서(Contents)

<!-- table -->
#### 7. 비디오(videos)

<!-- table -->
#### 8. 퀴즈(quizzes)

<!-- table -->
#### 9. 퀴즈 문항(quiz_questions)

<!-- table -->
#### 10. 퀴즈 보기(quiz_options)

<!-- table -->
#### 11. 과제(assignments)

<!-- table -->
#### 12. 질문(questions)

<!-- table -->
#### 13. 답변(answers)

<!-- table -->
#### 14. 퀴즈 제출(quiz_submissions)

<!-- table -->
#### 15. 퀴즈 답안(quiz_answers)

<!-- table -->
#### 16. 과제 제출(assignment_submissions)

<!-- table -->
#### 17. 태그(tags)

<!-- table -->
#### 18. 강의-태그(course_tags)

<!-- table -->
#### 19. 학생-강의(student_courses)

<!-- table -->
#### 20. 학생 컨텐츠 진도(student_content_progress)

<!-- table -->


##### 시나리오 2: 레시피 공유 애플리케이션

"우리 앱은 요리 애호가들이 자신만의 레시피를 공유하고 다른 사람들의 레시피를 발견할 수 있는 플랫폼을 제공합니다. 사용자는 고유 아이디로 가입하여 프로필을 설정할 수 있으며, 각 프로필에는 요리 전문 분야와 짧은 자기소개가 포함됩니다.

사용자는 레시피를 등록할 수 있으며, 각 레시피에는 제목, 요리 시간, 난이도, 재료 목록, 조리 단계, 완성된 요리 사진이 포함되어야 합니다. 조리 단계는 순서대로 표시되어야 하며, 각 단계마다 텍스트 설명과 선택적으로 사진을 추가할 수 있어야 합니다.

사용자들은 레시피에 별점을 매기고 리뷰를 남길 수 있으며, 리뷰에는 텍스트 설명과 함께 실제로 요리해본 사진을 첨부할 수 있어야 합니다. 레시피 작성자는 리뷰에 답변을 달 수 있어야 합니다.

사용자들이 원하는 레시피를 쉽게 찾을 수 있도록 요리 종류(한식, 중식, 양식 등), 재료, 조리 방법(찜, 볶음, 구이 등)에 따라 레시피를 분류하고 태그를 지정할 수 있어야 합니다.

추가 기능으로, 사용자들은 마음에 드는 레시피를 저장하여 나중에 쉽게 찾아볼 수 있어야 하며, 일주일치 식단을 계획할 수 있는 캘린더 기능도 제공되어야 합니다."



##### 시나리오 3: 프리랜서 마켓플레이스

"우리 플랫폼은 프리랜서와 프로젝트 의뢰인을 연결하는 마켓플레이스입니다. 사용자는 프리랜서나 의뢰인으로 회원가입하고 프로필을 작성할 수 있습니다. 프리랜서 프로필에는 이름, 직업, 전문 분야, 경력, 포트폴리오, 시간당 요율이 포함되어야 합니다.

의뢰인은 프로젝트를 등록할 수 있으며, 각 프로젝트에는 제목, 상세 설명, 필요한 기술, 예산 범위, 마감일이 명시되어야 합니다. 프리랜서들은 이에 맞춰 제안서를 제출할 수 있어야 하며, 제안서에는 가격 견적, 작업 기간, 접근 방식 등이 포함됩니다.

의뢰인은 제출된 제안서들을 검토하고 프리랜서를 선택할 수 있어야 하며, 계약이 체결되면 작업 진행 상태를 추적할 수 있어야 합니다. 작업은 여러 단계(마일스톤)로 나뉠 수 있으며, 각 단계가 완료될 때마다 결제가 이루어질 수 있어야 합니다.

프로젝트 완료 후에는 의뢰인과 프리랜서가 서로에 대한 리뷰와 평점을 남길 수 있어야 하며, 이는 각 사용자의 평판 점수에 반영됩니다.

효율적인 검색을 위해 프로젝트와 프리랜서 모두 관련 기술이나 산업 분야로 태그를 지정할 수 있어야 하며, 의뢰인은 필요한 기술을 갖춘 프리랜서를 쉽게 찾을 수 있어야 합니다."

##### 시나리오 4: 여행 계획 및 리뷰 플랫폼

"우리 서비스는 여행자들이 여행 경험을 공유하고 새로운 여행을 계획할 수 있는 플랫폼입니다. 사용자는 개인 프로필을 만들어 방문한 국가와 도시, 여행 스타일 등을 설정할 수 있습니다.

사용자는 방문한 장소에 대한 리뷰를 작성할 수 있으며, 각 리뷰에는 장소명, 방문 날짜, 평점, 상세 설명, 사진 등이 포함됩니다. 또한 방문한 장소의 카테고리(숙소, 식당, 관광지 등)를 지정하고 예산 범위, 추천 방문 시간대 등의 정보도 제공할 수 있어야 합니다.

사용자들은 다른 사람의 리뷰에 댓글을 남기거나 질문을 할 수 있으며, 리뷰 작성자는 이에 대해 답변할 수 있어야 합니다. 유용한 정보를 제공한 리뷰에는 '도움이 됨' 표시를 할 수 있습니다.

여행 계획 기능을 통해 사용자는 방문할 도시와 날짜를 선택하고, 일별 일정에 방문할 장소를 추가할 수 있어야 합니다. 계획된 여행은 다른 사용자들과 공유하거나 비공개로 설정할 수 있어야 합니다.

효과적인 검색을 위해 리뷰와 장소에는 지역, 활동 유형(모험, 문화, 휴식 등), 여행자 유형(가족, 커플, 솔로 등)에 따른 태그를 지정할 수 있어야 합니다."

##### 시나리오 5: 헬스케어 및 피트니스 트래킹 앱

"우리 앱은 사용자들이 건강 목표를 설정하고 일상적인 운동과 영양 섭취를 추적할 수 있는 종합적인 헬스케어 플랫폼입니다. 사용자는 가입 시 기본 정보(나이, 성별, 키, 체중)와 함께 건강 목표(체중 감량, 근육 증가, 전반적인 건강 개선 등)를 설정할 수 있습니다.

사용자는 매일의 운동 세션을 기록할 수 있으며, 각 세션에는 운동 유형, 지속 시간, 강도, 소모 칼로리, 운동 중 느낌 등을 포함할 수 있습니다. 특히 웨이트 트레이닝의 경우 각 운동별 세트, 횟수, 무게를 상세히 기록할 수 있어야 합니다.

식단 추적 기능을 통해 사용자는 매 끼니마다 섭취한 음식과 양을 기록할 수 있으며, 이를 통해 총 칼로리와 영양소(단백질, 탄수화물, 지방, 비타민 등) 섭취량을 자동으로 계산해야 합니다.

사용자들은 자신만의 운동 루틴이나 건강식 레시피를 커뮤니티에 공유할 수 있으며, 다른 사용자들은 이에 댓글을 달거나 '좋아요'를 표시할 수 있습니다. 또한 비슷한 목표를 가진 사용자들이 서로 응원하고 동기부여할 수 있는 그룹 기능도 필요합니다.

정기적인 건강 체크를 위해 사용자는 체중, 체지방률, 근육량 등의 신체 측정치를 기록할 수 있어야 하며, 이러한 데이터를 기반으로 한 진행 상황 그래프와 분석 정보를 제공해야 합니다."





게시판.



블로그.



sns.



cal ai. ⇒ 칼로리 계산.



rpg ⇒ 던전게임 (도스 커맨드)  ⇒ 유니티 ⇒ json 

### 시나리오 1: 온라인 학습 플랫폼

"우리 서비스는 학생과 교사가 온라인에서 효과적으로 학습할 수 있는 교육 플랫폼을 목표로 합니다. 사용자는 학생과 교사로 구분되어 회원가입 및 로그인할 수 있어야 합니다. 교사는 다양한 주제의 강의를 생성하고, 각 강의에는 제목, 설명, 난이도, 대상 학년이 포함되어야 합니다.

강의 내에서 교사는 여러 개의 강의 자료(문서, 비디오, 퀴즈 등)를 업로드할 수 있어야 하며, 각 자료는 특정 순서로 정렬되어야 합니다. 학생들은 강의에 등록하고, 진도율을 확인할 수 있어야 합니다.

상호작용을 위해 학생들은 각 강의 자료에 질문을 남길 수 있으며, 교사나 다른 학생들이 이에 답변할 수 있어야 합니다. 또한 질문에 대한 추가 질문(대댓글)도 가능해야 합니다.

효과적인 학습 관리를 위해 각 학생의 퀴즈 점수와 과제 제출 현황을 추적할 수 있어야 하며, 교사는 전체 학생의 성취도를 대시보드에서 확인할 수 있어야 합니다.

마지막으로, 검색 기능을 통해 학생들이 관심 있는 주제나 키워드로 강의를 찾을 수 있도록 각 강의에는 여러 주제 태그를 지정할 수 있어야 합니다."



### 온라인 학습 플랫폼 테이블 정의서

#### 1. 사용자(users)

<!-- table -->
#### 2. 학생(students)

<!-- table -->
#### 3. 교사(teachers)

<!-- table -->
#### 4. 강의(courses)


---

## 6.10 Querydsl 페이징과 성능

### 개요

이 문서는 Querydsl을 사용할 때 가장 자주 부딪히는 **목록 API, 페이징, count 쿼리, fetch join, N+1** 문제를 실무 기준으로 정리한 가이드입니다. Querydsl의 난이도는 문법이 아니라 **조회 전략**에서 올라갑니다.

#### 이 문서의 역할

앞선 문서에서 조회 문법과 리포지토리 구조를 정리했다면, 이제는 같은 조회를 **어떻게 더 적게 읽고, 더 안정적으로 페이지로 나눌지**를 결정해야 합니다. 이 문서는 `5장`의 마무리이자, 이후 API 설계를 현실로 끌어내리는 문서입니다.

#### 현재 저장소에서 먼저 확인할 것

현재 `day_by_spring` 저장소는 Querydsl 페이징을 쓰지 않고, Spring Data JPA `Pageable`과 JPQL `JOIN FETCH`를 함께 사용합니다. 따라서 이 문서는 **현재 구현 설명**이 아니라 **향후 목록 API를 Querydsl로 옮기거나 확장할 때 지켜야 할 성능 기준**으로 읽는 편이 정확합니다.

```java
public interface OrderRepository extends JpaRepository<Order, Long> {

    Page<Order> findByStatus(OrderStatus status, Pageable pageable);
}
```

```plain text
예상 결과
주문 상태별 목록이 페이지 단위로 조회된다.
현재 저장소는 이 페이징을 Querydsl이 아니라 Spring Data JPA 메서드 쿼리로 처리하고 있다.
```

```java
public interface LoanRepository extends JpaRepository<Loan, Long>, JpaSpecificationExecutor<Loan> {

    @Query("SELECT l FROM Loan l JOIN FETCH l.member JOIN FETCH l.book")
    List<Loan> findAllWithMemberAndBook();
}
```

```plain text
예상 결과
대출 목록을 읽을 때 회원과 도서 정보를 한 번에 함께 가져와 N+1을 줄일 수 있다.
다만 이런 fetch join 방식은 목록 페이징의 기본값으로 쓰기보다 상세 조회나 제한된 목록 최적화로 보는 편이 안전하다.
```

#### 1. 페이지 조회는 사실 두 개의 쿼리입니다

목록 API를 `Page`로 반환한다면 보통 두 종류의 쿼리를 생각해야 합니다.

- 현재 페이지의 실제 데이터 목록을 가져오는 content 쿼리
- 전체 개수를 계산하는 count 쿼리
둘의 목적이 다르기 때문에, 같은 모양으로 만들 필요가 없습니다.

```java
List<MemberListItem> content = queryFactory
        .select(Projections.constructor(MemberListItem.class,
                member.id,
                member.username,
                team.name))
        .from(member)
        .leftJoin(member.team, team)
        .where(usernameEq(condition.username()))
        .orderBy(member.id.desc())
        .offset(pageable.getOffset())
        .limit(pageable.getPageSize())
        .fetch();

Long total = queryFactory
        .select(member.count())
        .from(member)
        .where(usernameEq(condition.username()))
        .fetchOne();
```

content 쿼리는 화면에 필요한 데이터를 읽는 데 집중하고, count 쿼리는 전체 개수 계산에만 집중해야 합니다.

#### 2. count 쿼리는 복사본이 아니라 별도 설계입니다

실무에서 가장 흔한 실수는 content 쿼리를 거의 그대로 복사해서 count 쿼리를 만드는 것입니다. 하지만 count 쿼리에는 보통 아래가 불필요합니다.

- 불필요한 `left join`
- DTO projection
- `fetch join`
- 복잡한 `order by`
즉, count 쿼리는 “같은 쿼리의 축약판”이 아니라 **전체 개수 계산 전용 쿼리**로 다시 보는 편이 맞습니다.

#### 3. `fetchResults()`에 의존하지 않습니다

예전 Querydsl 예제에서는 `fetchResults()`나 `fetchCount()`를 많이 볼 수 있지만, Querydsl 릴리즈 노트는 복잡한 `group by`나 `having`이 있는 경우 이 방식에 한계가 있음을 분명히 드러냅니다. 출판 기준에서는 **content 쿼리와 count 쿼리를 직접 분리하는 방식**을 기본값으로 두는 편이 안전합니다.

#### 4. `PageableExecutionUtils`는 최적화 도구입니다

항상 count 쿼리를 바로 실행할 필요는 없습니다. 마지막 페이지가 명확하거나 결과 크기로 전체 개수를 유추할 수 있는 경우에는 `PageableExecutionUtils`를 사용할 수 있습니다.

```java
return PageableExecutionUtils.getPage(content, pageable, () ->
        queryFactory
                .select(member.count())
                .from(member)
                .where(usernameEq(condition.username()))
                .fetchOne()
);
```

하지만 이것은 **count를 없애 주는 마법**이 아닙니다. count 쿼리를 언제 늦게 실행할지 도와주는 최적화 도구일 뿐입니다.

#### 5. fetch join은 상세 조회와 목록 조회를 구분해서 씁니다

`fetch join`은 N+1 문제를 줄이는 데 강력하지만, 페이지 조회에 무조건 좋은 선택은 아닙니다.

특히 Hibernate 공식 문서는 **fetch join은 제한된 결과나 페이지 조회에서 보통 피하는 편이 좋다**고 설명합니다. 컬렉션 fetch join과 페이징을 섞으면 중복, 메모리 후처리, 예상과 다른 row 수 같은 문제가 쉽게 생깁니다.

책 기준에서는 아래처럼 구분하는 편이 자연스럽습니다.

- 상세 조회: 필요하면 fetch join 사용
- 목록 조회: DTO projection + 필요한 조인만 사용
- 컬렉션 탐색이 늦게 일어나는 경우: 배치 크기 최적화 검토
#### 6. 목록 API의 기본값은 DTO projection입니다

목록 화면은 보통 엔티티 전체가 아니라 일부 필드만 필요합니다. 이때 엔티티를 그대로 노출하는 것보다 DTO projection이 더 안전합니다.

```java
List<MemberListItem> content = queryFactory
        .select(Projections.constructor(MemberListItem.class,
                member.id,
                member.username,
                team.name))
        .from(member)
        .leftJoin(member.team, team)
        .fetch();
```

이 방식의 장점은 다음과 같습니다.

- API 응답 모양이 엔티티 구조에 덜 끌려갑니다.
- 목록 조회와 상세 조회의 목적을 분리하기 쉽습니다.
- 불필요한 연관 엔티티 로딩을 줄이기 좋습니다.
#### 7. `Page`가 꼭 필요하지 않다면 `Slice`도 고려합니다

무한 스크롤이나 “다음 페이지가 있는지만” 알면 되는 화면이라면 전체 count가 꼭 필요하지 않을 수 있습니다. 이 경우 `Page` 대신 `Slice`를 고려하면 count 쿼리 자체를 생략할 수 있습니다.

기준은 단순합니다.

- 전체 페이지 수가 필요하다: `Page`
- 다음 페이지 존재 여부만 필요하다: `Slice`
#### 8. N+1은 Querydsl 문법 문제가 아닙니다

N+1은 Querydsl 자체의 문제가 아니라 **조회 전략 문제**입니다. 해결도 문법 암기가 아니라 아래 선택에서 나옵니다.

- 지금 이 API가 목록인가 상세인가
- 엔티티가 필요한가 DTO면 충분한가
- 조인을 즉시 가져와야 하는가, 나중에 배치로 읽어도 되는가
- count 쿼리를 정말 정확히 계산해야 하는가
즉, 성능 최적화의 핵심은 Querydsl 문장을 더 복잡하게 쓰는 것이 아니라 **읽기 모델을 더 정확히 정의하는 것**입니다.

#### 자주 하는 실수

- content 쿼리와 count 쿼리를 거의 똑같이 만드는 것
- 목록 API에 컬렉션 fetch join을 붙이는 것
- DTO 대신 엔티티를 그대로 응답에 노출하는 것
- `Page`가 꼭 필요하지 않은데도 습관적으로 count를 계산하는 것
- 성능 문제를 Querydsl 문법 부족으로 오해하는 것
#### 공식 문서

- [Spring Data Commons - PageableExecutionUtils](https://docs.spring.io/spring-data/commons/docs/current/api/org/springframework/data/support/PageableExecutionUtils.html)
- [Spring Data JPA - Projections](https://docs.spring.io/spring-data/jpa/reference/repositories/projections.html)
- [Hibernate ORM User Guide](https://docs.hibernate.org/orm/current/userguide/html_single/)
- [Querydsl Reference Guide](https://querydsl.com/static/querydsl/latest/reference/html/)
- [Querydsl Releases](https://querydsl.com/releases.html)
#### 정리

Querydsl 페이징 최적화의 핵심은 메서드를 외우는 것이 아니라 **목록 조회, count 계산, 연관 로딩 전략을 목적에 따라 분리하는 것**입니다. 상세 조회와 목록 조회를 같은 방식으로 다루면 성능과 구조가 함께 흔들립니다.

#### 한 줄 정리

Querydsl 페이징과 성능의 핵심은 **content 쿼리, count 쿼리, fetch join, DTO 조회를 같은 문제로 보지 않는 것**입니다.


---

## 6.12 SQL 연습 문제

#### 개요

이 문서는 `SQL 기본기: DDL, DML, JOIN, 집계`를 읽은 뒤 바로 이어서 푸는 실전문제 모음입니다. 초중급 Java 개발자가 SQL 기본기와 실무 감각을 함께 익힐 수 있도록 구성했습니다. 단순히 문법을 외우기보다, 스키마를 읽고 JOIN, 집계, 서브쿼리, 윈도우 함수를 상황에 맞게 선택하는 힘을 기르는 것을 목표로 합니다.

#### 어떻게 활용하면 좋은가

- 먼저 스키마를 직접 생성합니다.
- 샘플 데이터를 넣고 문제를 한 번 스스로 풉니다.
- 그 다음 `EXPLAIN`, 인덱스, 실행 순서를 함께 생각합니다.
- 가능하면 JPA 또는 MyBatis 코드로도 한 번 연결해봅니다.
#### 실습용 스키마

```sql
CREATE DATABASE company_db;
USE company_db;

CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  department_name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  hire_date DATE,
  department_id INT,
  CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

CREATE TABLE salaries (
  salary_id INT PRIMARY KEY,
  employee_id INT,
  salary_amount DECIMAL(10,2),
  start_date DATE,
  end_date DATE,
  CONSTRAINT fk_employee FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);
```

#### 샘플 데이터

이 문서는 기존 샘플 데이터를 그대로 사용해도 좋고, 직접 직원을 몇 명 더 추가해서 난이도를 높여도 좋습니다. 중요한 것은 문제를 풀 수 있는 최소 데이터셋을 직접 손에 익히는 것입니다.

#### 문제 구성

##### 1. 기본 SELECT와 JOIN

- 모든 직원 조회
- 특정 부서 직원 조회
- 직원과 부서를 조인해서 조회
- 현재 급여만 필터링해서 조회
- 입사일 기준 정렬과 상위 N건 조회
##### 2. DDL과 DML

- 부서 추가
- 직원 추가
- 컬럼 추가
- 특정 직원 수정
- 트랜잭션 시작 후 ROLLBACK 연습
##### 3. 집계와 GROUP BY

- 부서별 직원 수
- 부서별 평균 급여
- 급여 구간별 분포
- 중복 이메일 탐지
##### 4. 서브쿼리와 고급 JOIN

- 두 번째로 높은 급여 찾기
- 평균 이상 급여 직원 찾기
- 부서 평균보다 높은 급여 찾기
- 직원 수가 평균 이상인 부서 찾기
##### 5. 윈도우 함수

- `ROW_NUMBER()`로 입사 순위 매기기
- `RANK()`로 부서별 급여 순위 계산
- `LAG()`로 급여 증가율 계산
- `SUM() OVER (...)`로 누적합 계산
#### 예시 문제

##### 문제 1. 현재 재직 중인 직원의 현재 급여 조회

```sql
SELECT e.employee_id, e.first_name, e.last_name, s.salary_amount
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.end_date = '9999-12-31';
```

##### 문제 2. 부서별 평균 급여 구하기

```sql
SELECT d.department_name, ROUND(AVG(s.salary_amount), 2) AS avg_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.end_date = '9999-12-31'
GROUP BY d.department_name;
```

##### 문제 3. 급여 순위 매기기

```sql
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       s.salary_amount,
       DENSE_RANK() OVER (ORDER BY s.salary_amount DESC) AS salary_rank
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.end_date = '9999-12-31';
```

#### 연습할 때 체크할 포인트

- `INNER JOIN`과 `LEFT JOIN`의 차이를 정확히 구분했는가
- 집계 쿼리에서 `GROUP BY`와 `WHERE`, `HAVING` 순서를 이해했는가
- 서브쿼리 대신 JOIN으로 바꿀 수 있는지 생각해봤는가
- 윈도우 함수가 일반 집계와 어떻게 다른지 이해했는가
#### Java 프로젝트와 연결하기

이 연습은 SQL만의 문제가 아닙니다.

- JPA에서는 어떤 쿼리가 N+1로 이어질지 감을 잡게 해줍니다.
- MyBatis에서는 어떤 조회를 XML로 분리하면 좋은지 감을 잡게 해줍니다.
- Querydsl에서는 어떤 조건 조합이 동적 쿼리 후보인지 보이기 시작합니다.
#### 정리

SQL 실력은 문법 암기보다 문제를 많이 풀어보는 과정에서 자랍니다. 특히 JOIN, 집계, 윈도우 함수는 실무에서 계속 반복되므로, 단순한 정답 작성보다 왜 그 쿼리를 선택했는지 설명할 수 있어야 합니다.

#### 한 줄 정리

SQL 연습의 목표는 쿼리를 쓰는 손보다, 데이터를 읽는 눈을 기르는 데 있습니다.


---

## 6.2 SQL 기본기: DDL, DML, JOIN, 집계

#### 개요

이 문서는 Java 개발자가 데이터 접근 계층을 읽고 설계할 때 꼭 알아야 하는 SQL 기본기를 한 흐름으로 정리한 가이드입니다. JPA나 Querydsl을 쓰더라도 실제로는 SQL의 구조를 이해해야 조회와 변경 로직을 제대로 설계할 수 있습니다.

#### 왜 SQL 기본기가 먼저 필요한가

애플리케이션 코드가 아무리 깔끔해도, 결국 데이터베이스와 대화하는 언어는 SQL입니다.

- 조회가 왜 느린지 이해하려면 `WHERE`, `JOIN`, `GROUP BY`, 인덱스를 함께 봐야 합니다.
- Querydsl을 읽으려면 `select`, `join`, `groupBy`, `orderBy`, `limit`가 SQL에서 어떤 의미인지 먼저 잡혀 있어야 합니다.
- JPA를 쓸 때도 N+1, 잘못된 fetch join, 과한 update 같은 문제는 SQL 감각이 없으면 원인을 놓치기 쉽습니다.
#### 1. SQL은 크게 세 가지 축으로 보면 된다

##### DDL: 구조를 정의한다

DDL은 테이블, 인덱스, 제약조건처럼 저장 구조를 만드는 언어입니다.

```sql
CREATE TABLE books (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0)
);

CREATE INDEX idx_books_title ON books(title);
```

대표 명령은 `CREATE`, `ALTER`, `DROP`입니다.

##### DML: 데이터를 조회하고 바꾼다

DML은 애플리케이션이 실제로 가장 자주 쓰는 축입니다.

```sql
INSERT INTO books (title, price)
VALUES ('객체지향의 사실과 오해', 18000);

UPDATE books
SET price = 19000
WHERE id = 1;

DELETE FROM books
WHERE id = 1;
```

실무에서는 `INSERT`, `UPDATE`, `DELETE`보다 `SELECT`가 훨씬 많이 보입니다.

##### TCL/DCL: 트랜잭션과 권한을 다룬다

책의 중심은 아니지만, `COMMIT`, `ROLLBACK`, `GRANT`, `REVOKE`도 SQL 문맥 안에서 이해해야 합니다. 특히 서비스 개발에서는 트랜잭션 경계와 롤백이 중요합니다.

#### 2. 조회 SQL은 실행 순서를 기준으로 읽어야 한다

처음 SQL을 배울 때는 위에서 아래로 읽기 쉽지만, DB는 논리적으로 아래 순서에 가깝게 평가합니다.

1. `FROM`
1. `JOIN`
1. `WHERE`
1. `GROUP BY`
1. `HAVING`
1. `SELECT`
1. `ORDER BY`
1. `LIMIT/OFFSET`
예를 들어 아래 SQL은 "주문 테이블에서 회원별 총 주문 금액을 계산한 뒤, 금액이 큰 순서로 상위 10명만 보여준다"는 뜻입니다.

```sql
SELECT o.member_id, SUM(o.total_amount) AS total_amount
FROM orders o
WHERE o.status = 'PAID'
GROUP BY o.member_id
HAVING SUM(o.total_amount) >= 50000
ORDER BY total_amount DESC
LIMIT 10;
```

이 순서를 이해하면 Querydsl 코드도 훨씬 읽기 쉬워집니다.

#### 3. JOIN은 테이블을 붙이는 문법이 아니라 관계를 읽는 도구다

관계형 데이터베이스에서는 데이터를 보통 한 테이블에 몰아넣지 않습니다. 그래서 조회할 때는 관계를 따라 JOIN이 필요합니다.

##### INNER JOIN

양쪽에 모두 매칭되는 행만 가져옵니다.

```sql
SELECT o.id, m.name
FROM orders o
JOIN members m ON m.id = o.member_id;
```

##### LEFT JOIN

왼쪽 테이블은 유지하고, 오른쪽이 없으면 `NULL`로 채웁니다.

```sql
SELECT b.id, b.title, c.name
FROM books b
LEFT JOIN categories c ON c.id = b.category_id;
```

이 차이를 이해하지 못하면 "왜 데이터가 빠졌지?" 같은 문제를 자주 만납니다.

#### 4. 집계는 한 행이 아니라 그룹을 다룬다

집계 함수는 여러 행을 하나의 결과로 요약합니다.

- `COUNT`: 개수
- `SUM`: 합계
- `AVG`: 평균
- `MIN`, `MAX`: 최소/최대
```sql
SELECT category_id, COUNT(*) AS book_count, AVG(price) AS avg_price
FROM books
GROUP BY category_id;
```

`GROUP BY`를 쓰면 이제 한 행이 아니라 그룹 단위로 생각해야 합니다. 그래서 `WHERE`와 `HAVING`도 역할이 다릅니다.

- `WHERE`: 그룹핑 전 행 필터
- `HAVING`: 그룹핑 후 결과 필터
#### 5. 정렬과 페이징은 조회 설계의 마지막 단계다

목록 API는 대개 정렬과 페이징이 함께 붙습니다.

```sql
SELECT id, title, price
FROM books
WHERE price >= 10000
ORDER BY created_at DESC, id DESC
LIMIT 20 OFFSET 0;
```

실무에서는 `ORDER BY` 기준 컬럼에 인덱스가 없으면 페이지가 뒤로 갈수록 느려질 수 있습니다. 그래서 정렬은 화면 요구사항이 아니라 성능 설계와도 연결됩니다.

#### 6. 변경 SQL은 조건과 영향 범위를 먼저 봐야 한다

조회보다 더 위험한 SQL은 변경문입니다.

```sql
UPDATE books
SET price = price * 1.1
WHERE category_id = 3;
```

이때 가장 먼저 봐야 할 것은 `WHERE`가 맞는지입니다. 조건이 빠진 `UPDATE`나 `DELETE`는 전체 데이터를 바꿉니다. 서비스 코드에서도 같은 기준이 필요합니다.

#### 7. Java 개발자는 SQL을 어느 수준까지 알아야 하나

초중급 Java 개발자라면 최소한 아래는 직접 읽고 설명할 수 있어야 합니다.

- `SELECT`, `INSERT`, `UPDATE`, `DELETE`
- `INNER JOIN`, `LEFT JOIN`
- `GROUP BY`, `HAVING`
- `ORDER BY`, `LIMIT/OFFSET`
- PK, FK, UNIQUE, CHECK 같은 기본 제약조건
이 정도가 잡혀 있어야 JPA와 Querydsl도 단순 복붙이 아니라 설계 도구로 쓸 수 있습니다.

#### 8. Querydsl과 JPA로 이어지는 연결점

이 장 다음 문서들이 중요한 이유는 SQL 기본기가 바로 거기서 재사용되기 때문입니다.

- Querydsl의 `select`, `from`, `join`, `where`는 SQL 조회 구조를 코드로 옮긴 것입니다.
- JPA의 연관관계와 fetch 전략도 결국 어떤 JOIN SQL이 나갈지와 연결됩니다.
- 쿼리 최적화는 SQL을 모르면 증상을 봐도 원인을 해석하기 어렵습니다.
#### 자주 하는 실수

- JOIN 조건 없이 테이블을 붙여 카티전 곱을 만드는 것
- `GROUP BY` 없이 집계와 일반 컬럼을 섞는 것
- `LEFT JOIN`이 필요한 상황에서 `JOIN`을 써서 데이터가 빠지는 것
- 정렬 기준 없이 페이징을 걸어 결과가 흔들리는 것
- 변경문에서 `WHERE` 범위를 충분히 검토하지 않는 것
#### 정리

SQL은 ORM을 쓰더라도 사라지지 않습니다. Java 개발자에게 SQL 기본기는 DB와 애플리케이션 사이의 번역 감각에 가깝습니다. 결국 좋은 데이터 접근 코드는 SQL 구조를 이해한 상태에서만 제대로 설계할 수 있습니다.

#### 한 줄 정리

SQL 기본기는 문법 암기가 아니라, `조회 구조`, `관계`, `집계`, `변경 범위`를 읽는 감각입니다.


---

## 6.3 쿼리 최적화

[TOC]

#### 개요

이 문서는 SQL을 작성한 뒤 한 단계 더 나아가, 왜 느린지 판단하고 어떤 방향으로 개선해야 하는지를 정리한 최적화 가이드입니다. 초중급 Java 개발자에게는 쿼리를 작성하는 능력만큼, 병목을 읽는 능력이 중요합니다.

#### 왜 중요한가

- 기능은 맞는데 응답이 느린 상황은 실무에서 매우 흔합니다.
- JPA, Querydsl, MyBatis를 쓰더라도 결국 데이터베이스는 SQL을 실행합니다.
- 따라서 실행 계획과 인덱스를 읽을 수 있어야 ORM의 한계도 판단할 수 있습니다.
#### 가장 먼저 볼 것

##### 1. 필요한 컬럼만 조회했는가

```sql
SELECT product_id, product_name, price
FROM products
WHERE category_id = 1;
```

`SELECT *`는 학습 단계에서는 편하지만, 실무에서는 네트워크 비용과 메모리 사용량까지 같이 늘립니다.

##### 2. 인덱스를 탈 수 있는 조건인가

```sql
-- 비추천
SELECT * FROM orders WHERE YEAR(order_date) = 2023;

-- 권장
SELECT * FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';
```

컬럼에 함수를 직접 적용하면 인덱스 활용이 깨질 수 있습니다.

#### 인덱스 설계 기본

```sql
CREATE INDEX idx_products_category_price ON products(category_id, price);
EXPLAIN SELECT *
FROM products
WHERE category_id = 1 AND price > 100;
```

인덱스는 아래 기준으로 검토합니다.

- WHERE 조건
- JOIN 조건
- ORDER BY
- 페이징 정렬 컬럼
복합 인덱스는 컬럼 순서가 중요하며, 실제 조회 패턴과 함께 봐야 합니다.

#### EXPLAIN으로 실행 계획 읽기

`EXPLAIN`은 쿼리가 어떤 순서로 실행될지 보여주는 도구입니다.

중점적으로 볼 항목은 아래와 같습니다.

- `type`: `ALL`이면 전체 스캔 가능성이 큽니다.
- `key`: 실제 사용된 인덱스입니다.
- `rows`: 읽을 것으로 예상하는 행 수입니다.
- `Extra`: `Using filesort`, `Using temporary` 같은 추가 비용을 확인합니다.
```sql
EXPLAIN SELECT
    c.category_name,
    p.product_name,
    p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.price > 50
ORDER BY p.price DESC;
```

#### 자주 보는 비효율 패턴

##### 1. 상관 서브쿼리 남용

```sql
-- 비효율적인 형태
SELECT p.product_name, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(price)
    FROM products
    WHERE category_id = p.category_id
);
```

이 경우는 집계 결과를 미리 구해서 JOIN하는 방식이 더 읽기 쉽고 빠를 수 있습니다.

##### 2. 불필요한 LEFT JOIN

필터 조건 때문에 사실상 INNER JOIN처럼 동작하는 경우가 많습니다.

##### 3. 앞에 `%`가 붙는 LIKE 검색

```sql
SELECT * FROM products WHERE product_name LIKE '%phone%';
```

이런 검색은 일반 인덱스를 활용하기 어렵습니다.

#### 실무에서 자주 쓰는 개선 방향

##### 집계 쿼리 분리

복잡한 보고서 쿼리는 한 번에 끝내려 하지 말고, 중간 집계 결과를 만들어 단계적으로 분리할 수 있습니다.

##### 임시 테이블 또는 뷰 검토

반복되는 분석 쿼리는 뷰나 별도 집계 구조를 둘 수 있습니다.

```sql
CREATE VIEW product_sales_summary AS
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity) AS total_quantity,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;
```

##### 캐시와 읽기 모델 고려

조회 빈도가 매우 높다면 인덱스만으로는 한계가 있습니다. 이때는 캐시, 읽기 전용 테이블, 비동기 집계까지 같이 검토합니다.

#### ORM과 연결해서 보기

##### JPA

- N+1 문제
- fetch join과 페이징 충돌
- 불필요한 지연 로딩
##### Querydsl

- 동적 쿼리는 편하지만, 결국 생성되는 SQL을 확인해야 합니다.
##### MyBatis

- 복잡한 조회 SQL을 명시적으로 다루기 좋지만, 인덱스 설계와 실행 계획 검토는 여전히 필요합니다.
#### 체크리스트

- 이 쿼리에 정말 필요한 컬럼만 조회하는가
- 인덱스를 탈 수 있는 조건인가
- `EXPLAIN` 결과에서 전체 스캔이 발생하는가
- 상관 서브쿼리를 JOIN으로 바꿀 수 있는가
- 정렬과 페이징 기준이 인덱스와 맞는가
- 문제를 SQL 하나로 해결하려다 지나치게 복잡해진 것은 아닌가
#### 정리

쿼리 최적화는 비밀스러운 트릭 모음이 아니라, 데이터 접근량을 줄이고 실행 계획을 읽는 기본기에서 시작합니다. 초중급 개발자라면 먼저 느린 이유를 설명할 수 있어야 하고, 그 다음에 개선안을 선택할 수 있어야 합니다.

#### 한 줄 정리

쿼리 최적화의 출발점은 빠른 SQL을 쓰는 것이 아니라, 느린 이유를 읽는 능력을 갖추는 데 있습니다.


---

## 6.4 Querydsl 도입과 프로젝트 구성

#### 개요

이 문서는 `6장 데이터 접근과 SQL` 안에서 Querydsl 묶음을 시작하는 안내 문서입니다. Querydsl은 단순히 JPQL을 다른 문법으로 바꾸는 도구가 아니라, **복잡한 조회를 더 안전하고 읽기 좋은 구조로 옮기기 위한 선택지**입니다.

이 문서의 목적은 설정 방법만 나열하는 데 있지 않습니다. Querydsl을 언제 도입해야 하는지, Spring Data JPA와 어떤 역할로 나눠 써야 하는지, 그리고 이후 문서를 어떤 순서로 읽어야 하는지를 먼저 정리하는 데 있습니다.

#### 왜 Querydsl이 필요한가

JPA를 쓰다 보면 기본 CRUD는 편하지만, 조회가 복잡해질수록 아래 문제가 빠르게 드러납니다.

- JPQL 문자열이 길어지고 오타에 취약해집니다.
- 동적 조건이 늘어나면서 `if` 분기가 복잡해집니다.
- DTO 조회와 조인 로직이 읽기 어려워집니다.
- 페이징과 count 최적화, fetch join 같은 조회 전략 판단이 까다로워집니다.
Querydsl은 이 지점에서 장점이 드러납니다. 핵심은 SQL을 숨기는 것이 아니라, **조회 구조를 타입 안전한 코드로 표현한다**는 데 있습니다.

#### Querydsl을 모든 곳에 쓰는 것이 답은 아니다

입문 단계에서 흔한 오해는 Querydsl을 도입하면 모든 조회를 다 Querydsl로 옮겨야 한다는 생각입니다. 실제로는 그럴 필요가 없습니다.

보통 더 현실적인 기준은 아래와 같습니다.

- 단순 CRUD와 간단한 단건 조회: Spring Data JPA
- 복잡한 검색 조건과 다중 조인: Querydsl
- 화면/API 전용 조회 DTO: Querydsl
즉, Querydsl은 JPA를 대체하는 기술이라기보다 **복잡한 조회를 분리하는 도구**로 보는 편이 맞습니다.

#### 현재 저장소 기준에서 먼저 확인할 것

이 책은 Querydsl을 설명하지만, **현재 ****`day_by_spring`**** 저장소 자체가 아직 Querydsl을 사용하고 있지는 않습니다.**

현재 저장소에서 확인되는 기준은 아래와 같습니다.

- `pom.xml`에 Querydsl 의존성이 없습니다.
- Q 타입 생성 설정이 없습니다.
- 리포지토리는 `JpaRepository`, `JpaSpecificationExecutor`, `@Query` 중심입니다.
- 예를 들어 `BookRepository`, `MemberRepository`, `LoanRepository`는 Spring Data JPA 방식으로 조회를 구성합니다.
즉, 이 묶음은 "현재 프로젝트가 이미 이렇게 구현돼 있다"는 설명이 아니라, **복잡한 조회가 더 커질 때 어떤 방향으로 확장할 수 있는가**를 설명하는 참고 축으로 읽어야 합니다.

#### 이 묶음에서 먼저 잡아야 할 세 가지

##### 1. Q 타입

Querydsl은 엔티티를 기반으로 `QMember`, `QBook`, `QLoan` 같은 Q 타입을 생성합니다. 이 타입이 있어야 문자열이 아니라 코드로 조건을 표현할 수 있습니다.

##### 2. `JPAQueryFactory`

실제 Querydsl 쿼리를 조합할 때 중심이 되는 객체입니다. 보통 설정에서 빈으로 등록하고 조회 리포지토리에서 주입받아 사용합니다.

##### 3. 조회 전용 구조

Querydsl은 단순 문법보다, **어디에 조회 로직을 둘 것인가**와 더 강하게 연결됩니다. 그래서 서비스에 직접 쿼리를 쌓기보다, 조회 전용 리포지토리나 커스텀 리포지토리 구조로 분리하는 편이 자연스럽습니다.

#### 프로젝트 구성에서 먼저 확인할 것

Spring Boot 3.x와 Jakarta 환경에서는 Querydsl 의존성도 그 기준에 맞춰야 합니다.

```xml
<dependency>
    <groupId>com.querydsl</groupId>
    <artifactId>querydsl-jpa</artifactId>
    <version>5.1.0</version>
    <classifier>jakarta</classifier>
</dependency>

<dependency>
    <groupId>com.querydsl</groupId>
    <artifactId>querydsl-apt</artifactId>
    <version>5.1.0</version>
    <classifier>jakarta</classifier>
    <scope>provided</scope>
</dependency>
```

이 설정은 "Querydsl을 도입하려는 프로젝트" 기준 예시입니다. 현재 `day_by_spring`에 이미 들어 있는 설정이 아니라, **추가 도입 시 검토해야 하는 방향**으로 읽어야 합니다.

도입 초기에 가장 많이 막히는 부분도 설정 자체보다 아래입니다.

- Q 타입이 생성되지 않음
- generated sources 경로를 IDE가 인식하지 못함
- Jakarta/JPA 버전 조합이 맞지 않음
- DTO 프로젝션 구조가 어긋남
#### 권장 읽는 순서

1. `Querydsl 기본 문법`
1. `Querydsl 프로젝션과 DTO 조회`
1. `Querydsl 동적 쿼리와 조건 조합`
1. `Querydsl 조회 리포지토리와 API 설계`
1. `Spring Data JPA와 Querydsl 통합 전략`
1. `Querydsl 페이징과 성능 최적화`
이 순서를 추천하는 이유는 단순합니다. 먼저 문법을 익히고, 그다음 DTO 조회와 동적 조건을 보고, 이후에 구조와 성능으로 확장하는 흐름이 가장 자연스럽기 때문입니다.

#### Querydsl을 공부할 때 계속 붙잡아야 할 질문

- 이 조회는 Querydsl까지 필요한 복잡도인가
- 엔티티 조회가 맞는가, DTO 조회가 맞는가
- 조건 조합이 늘어날 때 코드가 읽히는가
- 페이징과 count 쿼리를 분리해야 하는가
- 이 조회 로직은 어느 계층에 두는 것이 자연스러운가
이 질문이 있어야 Querydsl이 단순 문법 학습을 넘어, 실제 설계 도구로 보이기 시작합니다.

#### 공식 문서 기준으로 더 보면 좋은 자료

- [Querydsl GitHub](https://github.com/querydsl/querydsl)
- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/reference/)
#### 정리

Querydsl 도입의 핵심은 설정을 완료하는 데 있지 않습니다. 어떤 조회가 복잡해지고 있는지, 그 조회를 더 안전하고 유지보수하기 좋은 구조로 바꾸기 위해 Querydsl을 어디에 적용할지를 판단하는 데 있습니다.

#### 한 줄 정리

Querydsl 입문의 핵심은 `문법`보다, **복잡한 조회를 어떤 구조로 분리할 것인가를 판단하는 것**입니다.


---

## 6.5 Querydsl 기본 문법

#### 개요

이 문서는 Querydsl을 처음 접하는 개발자를 위해 **가장 자주 쓰는 기본 문법**을 정리한 자료입니다. 여기서 중요한 것은 문법을 외우는 것이 아니라, JPQL과 비교했을 때 Querydsl이 왜 읽기 쉬운지 체감하는 것입니다.

#### 왜 중요한가

Querydsl은 문법이 어렵다기보다, 처음에 Q 타입과 메서드 체인 형태가 낯설게 느껴집니다. 기본 문법만 익숙해지면 이후의 DTO 조회, 동적 쿼리, 페이징도 같은 패턴으로 읽히기 시작합니다.

중요한 점은 Querydsl이 SQL을 없애는 도구가 아니라, **조회 구조를 타입 안전한 코드로 표현하는 도구**라는 점입니다. 그래서 기본 문법 단계에서는 `select`, `where`, `join`, `orderBy`, `offset`, `limit`이 SQL과 어떻게 대응되는지만 정확히 잡아도 충분합니다.

#### 현재 저장소 기준에서 먼저 확인할 것

현재 `day_by_spring` 저장소는 Querydsl을 아직 도입하지 않았습니다. 실제 리포지토리는 Spring Data JPA 메서드 쿼리, `@Query`, `JpaSpecificationExecutor`를 사용합니다. 따라서 이 문서는 **현재 구현 설명**이 아니라 **도입 시 읽는 기본 문법**으로 받아들이는 편이 정확합니다.

```java
public interface LoanRepository extends JpaRepository<Loan, Long>, JpaSpecificationExecutor<Loan> {

    @Query("SELECT l FROM Loan l WHERE l.member.id = :memberId AND l.returnDate IS NULL ORDER BY l.loanDate DESC")
    List<Loan> findByMemberIdAndReturnDateIsNull(@Param("memberId") Long memberId);
}
```

```plain text
예상 결과
특정 회원의 미반납 대출 목록이 대출일 역순으로 반환된다.
현재 저장소에서는 이런 조회 구조를 Querydsl 체인이 아니라 Spring Data JPA + JPQL 문자열로 표현하고 있다.
```

Querydsl을 도입하면 같은 의도를 `selectFrom`, `where`, `orderBy` 체인으로 옮겨 적는다고 이해하면 된다.

#### 1. JPQL과 Querydsl 비교

```java
List<Member> members = em.createQuery(
        "select m from Member m where m.age > 18", Member.class)
    .getResultList();
```

```java
QMember member = QMember.member;

List<Member> members = queryFactory
        .selectFrom(member)
        .where(member.age.gt(18))
        .fetch();
```

JPQL은 문자열 기반이고, Querydsl은 코드 기반입니다. 이 차이 때문에 오타와 리팩터링 대응성에서 큰 차이가 납니다.

#### 2. 가장 기본이 되는 조회

```java
QMember member = QMember.member;

Member result = queryFactory
        .selectFrom(member)
        .where(member.username.eq("member1"))
        .fetchOne();
```

- `selectFrom(member)`: `select member from Member member`와 비슷한 역할입니다.
- `where(...)`: 조건절입니다.
- `fetchOne()`: 단건 조회입니다.
#### 3. 자주 쓰는 조건식

- `eq()`: 같음
- `ne()`: 다름
- `gt()`, `goe()`: 초과, 이상
- `lt()`, `loe()`: 미만, 이하
- `between()`: 범위 조회
- `contains()`, `startsWith()`: 문자열 검색
```java
.where(member.age.between(20, 30))
.where(member.username.startsWith("mem"))
```

#### 4. 정렬과 페이징

```java
List<Member> result = queryFactory
        .selectFrom(member)
        .orderBy(member.age.desc(), member.username.asc())
        .offset(0)
        .limit(10)
        .fetch();
```

초중급 개발자 입장에서는 이 구문이 SQL의 `order by`, `offset`, `limit`과 거의 그대로 연결된다고 이해하면 됩니다.

#### 5. 조인

```java
QMember member = QMember.member;
QTeam team = QTeam.team;

List<Member> result = queryFactory
        .selectFrom(member)
        .join(member.team, team)
        .where(team.name.eq("teamA"))
        .fetch();
```

조인은 Querydsl을 쓰는 가장 큰 이유 중 하나입니다. 문자열 조인보다 훨씬 구조적으로 읽힙니다.

#### 6. 페치 조인

```java
Member findMember = queryFactory
        .selectFrom(member)
        .join(member.team, team).fetchJoin()
        .where(member.username.eq("member1"))
        .fetchOne();
```

페치 조인은 연관 엔티티를 즉시 함께 읽어와서 N+1 문제를 줄이는 데 도움을 줍니다. 다만 컬렉션 fetch join과 페이지네이션은 함께 사용할 때 주의가 필요합니다.

#### 7. 집계와 그룹화

```java
List<Tuple> result = queryFactory
        .select(team.name, member.age.avg())
        .from(member)
        .join(member.team, team)
        .groupBy(team.name)
        .fetch();
```

그룹화 결과는 `Tuple`로 많이 받지만, 실무에서는 DTO로 매핑하는 편이 더 안전합니다.

#### 8. 서브쿼리와 Case 문

```java
QMember memberSub = new QMember("memberSub");

List<Member> result = queryFactory
        .selectFrom(member)
        .where(member.age.eq(
                JPAExpressions.select(memberSub.age.max())
                        .from(memberSub)
        ))
        .fetch();
```

서브쿼리와 Case 문도 지원하지만, 너무 복잡해지면 Querydsl 자체보다 쿼리 설계가 맞는지 먼저 점검해야 합니다.

#### 자주 하는 실수

- `fetchOne()`을 여러 건 결과에 사용해서 예외를 내는 것
- `Tuple`을 서비스나 컨트롤러까지 그대로 넘기는 것
- Q 타입과 엔티티 타입을 혼동하는 것
#### 공식 문서 기준으로 더 보면 좋은 자료

- [Querydsl GitHub](https://github.com/querydsl/querydsl)
- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/reference/)
#### 정리

기본 문법 단계에서는 `select`, `where`, `join`, `orderBy`, `offset`, `limit`만 익숙해져도 충분합니다. 이 다섯 축만 잡히면 Querydsl은 갑자기 어렵지 않게 느껴집니다.

#### 한 줄 정리

Querydsl 기본 문법은 **SQL의 핵심 구조를 코드 기반으로 옮긴 형태**라고 이해하면 가장 빠릅니다.


---

## 6.6 Querydsl 프로젝션과 DTO 조회

#### 개요

이 문서는 Querydsl에서 **엔티티 대신 DTO로 결과를 조회하는 방법**을 정리한 자료입니다. 실무에서는 엔티티 전체를 그대로 반환하기보다, 화면과 API에 필요한 필드만 조회하는 경우가 훨씬 많습니다.

#### 왜 중요한가

엔티티를 그대로 노출하면 조회 범위가 과해지고, 연관관계 로딩과 직렬화 이슈가 따라오기 쉽습니다. DTO 프로젝션은 조회 결과를 필요한 형태로 제한하는 가장 현실적인 방법입니다.

특히 목록 조회, 검색 결과, 관리자 화면처럼 읽기 전용 응답이 중심인 경우에는 엔티티보다 DTO 조회가 훨씬 자연스러운 경우가 많습니다. 반대로 변경을 위해 엔티티 상태를 다뤄야 하는 명령 흐름에서는 엔티티 조회가 더 적합할 수 있습니다.

#### 현재 저장소에서 먼저 구분할 것

Spring Data JPA 공식 문서만으로도 인터페이스 기반 프로젝션, DTO 생성자 프로젝션, 동적 프로젝션, `Page`/`Slice` 조회가 가능합니다. 따라서 **DTO 조회 = 반드시 Querydsl**은 아닙니다.

현재 `day_by_spring` 저장소는 Querydsl DTO 프로젝션을 사용하지 않고, 리포지토리에서 엔티티와 스칼라 값을 조회하는 구조가 중심입니다.

```java
public interface OrderRepository extends JpaRepository<Order, Long> {

    @Query("SELECT COALESCE(SUM(o.totalAmount.amount - COALESCE(o.discountAmount.amount, 0)), 0) FROM Order o WHERE o.status <> :excludeStatus")
    BigDecimal calculateTotalRevenue(@Param("excludeStatus") OrderStatus excludeStatus);
}
```

```plain text
예상 결과
주문 엔티티 목록이 아니라 취소 상태를 제외한 총 매출 합계 한 값이 반환된다.
현재 저장소는 이런 스칼라 조회를 Spring Data JPA + JPQL로 처리하고 있다.
```

Querydsl 프로젝션은 조회 모델이 더 복잡해질 때 선택하는 확장 카드로 이해하는 편이 정확하다.

#### 1. 단일 필드 조회

```java
List<String> result = queryFactory
        .select(member.username)
        .from(member)
        .fetch();
```

이 방식은 가장 단순하지만, 필드가 두 개 이상이면 구조화된 반환 타입이 필요해집니다.

#### 2. Tuple 조회

```java
List<Tuple> result = queryFactory
        .select(member.username, member.age)
        .from(member)
        .fetch();
```

`Tuple`은 Querydsl 내부에서는 편하지만, 서비스 계층 바깥으로 넘기기에는 적합하지 않습니다.

#### 3. DTO 조회 방식

##### `Projections.bean`

```java
List<MemberDto> result = queryFactory
        .select(Projections.bean(MemberDto.class,
                member.username,
                member.age))
        .from(member)
        .fetch();
```

Setter 기반 주입입니다.

##### `Projections.fields`

```java
List<MemberDto> result = queryFactory
        .select(Projections.fields(MemberDto.class,
                member.username,
                member.age))
        .from(member)
        .fetch();
```

필드 직접 주입 방식입니다.

##### `Projections.constructor`

```java
List<MemberDto> result = queryFactory
        .select(Projections.constructor(MemberDto.class,
                member.username,
                member.age))
        .from(member)
        .fetch();
```

생성자 기반이지만, 컴파일 시점에 타입 불일치를 완전히 잡아주지는 못합니다.

#### 4. 필드명이 다를 때

```java
List<UserDto> result = queryFactory
        .select(Projections.fields(UserDto.class,
                member.username.as("name")))
        .from(member)
        .fetch();
```

DTO 필드명과 엔티티 필드명이 다르면 `as()`로 맞춰줘야 합니다.

#### 5. `@QueryProjection`

```java
public class MemberDto {
    private final String username;
    private final int age;

    @QueryProjection
    public MemberDto(String username, int age) {
        this.username = username;
        this.age = age;
    }
}
```

```java
List<MemberDto> result = queryFactory
        .select(new QMemberDto(member.username, member.age))
        .from(member)
        .fetch();
```

이 방식은 타입 안전성이 높지만, DTO가 Querydsl에 의존하게 됩니다.

#### 6. 어떤 방식을 선택할까

- 단순 조회: `fields` 또는 `constructor`
- 타입 안정성 중시: `@QueryProjection`
- 외부 라이브러리 의존 최소화: `constructor`
정답은 하나가 아니라, 팀의 기준과 DTO 관리 방식에 따라 달라집니다.

책 기준으로는 아래처럼 정리해두면 판단이 쉬워집니다.

- 빠르게 읽히는 조회 모델이 필요하다: DTO 프로젝션
- 엔티티 변경이 이어지는 흐름이다: 엔티티 조회
- DTO가 Querydsl 의존을 가져도 괜찮고 컴파일 안정성이 더 중요하다: `@QueryProjection`
- DTO를 순수하게 유지하고 싶다: `constructor` 또는 `fields`
#### 자주 하는 실수

- `Tuple`을 컨트롤러까지 그대로 반환하는 것
- DTO 필드명과 별칭을 맞추지 않는 것
- 엔티티 조회와 DTO 조회의 목적을 혼동하는 것
#### 실무 연결 포인트

목록 API, 검색 결과, 관리자 화면 조회는 대부분 DTO 프로젝션과 잘 맞습니다. 반대로 엔티티 변경을 동반하는 명령 처리에서는 엔티티 조회가 더 자연스러운 경우가 많습니다.

#### 공식 문서 기준으로 더 보면 좋은 자료

- [Querydsl GitHub](https://github.com/querydsl/querydsl)
- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/reference/)
#### 정리

DTO 조회는 Querydsl의 실전 활용에서 매우 중요한 축입니다. 조회 모델과 도메인 모델을 분리하면 API와 화면 요구사항에 더 유연하게 대응할 수 있습니다.

#### 한 줄 정리

Querydsl 프로젝션은 **필요한 데이터만 안전하게 조회해 DTO로 반환하기 위한 핵심 기법**입니다.


---

## 6.8 Spring Data JPA와 Querydsl 통합 전략

### 개요

이 문서는 Spring Data JPA와 Querydsl을 함께 사용할 때 **어디까지를 기본 리포지토리에 맡기고, 어디서부터 조회 전용 설계를 분리할지** 정리한 가이드입니다. 핵심은 기능 비교가 아니라 **역할 분담 기준**을 세우는 것입니다.

#### 이 문서의 역할

앞선 문서에서 Querydsl 문법, DTO 조회, 동적 조건 조합을 다뤘다면, 이제는 그것을 실제 프로젝트 구조 안에 어떻게 배치할지를 결정해야 합니다. 책 기준으로 이 문서는 `문법` 다음, `조회 리포지토리 설계` 직전의 연결 문서입니다.

#### 1. 역할을 먼저 나눕니다

Spring Data JPA와 Querydsl은 경쟁 관계가 아니라 역할 분담 관계로 보는 편이 자연스럽습니다.

- Spring Data JPA: 기본 CRUD, 단건 조회, 단순한 조건 조회
- Querydsl: 동적 검색, 여러 엔티티 조인, 목록 API, DTO 프로젝션, 복잡한 정렬과 페이지 조회
기준은 단순합니다. **애그리거트의 생애주기를 다루는 작업**은 JPA 리포지토리가 맡고, **읽기 모델을 조립하는 작업**은 Querydsl 쿼리 쪽으로 보냅니다.

#### 현재 저장소는 어디까지 와 있는가

현재 `day_by_spring` 저장소는 이미 Spring Data JPA 구조를 적극적으로 사용하고 있습니다.

- `BookRepository`, `MemberRepository`, `LoanRepository` 등이 `JpaRepository`를 확장합니다.
- 일부 리포지토리는 `JpaSpecificationExecutor`도 함께 사용합니다.
- 단순 조회와 복합 조회는 메서드 이름 기반 쿼리와 `@Query`로 구성되어 있습니다.
반면 Querydsl fragment나 `JPAQueryFactory` 기반 구현은 아직 없습니다. 따라서 이 문서는 "현재 코드 설명"이라기보다, **현재 JPA 구조를 앞으로 어떻게 확장할 수 있는지 보여주는 설계 문서**에 가깝습니다.

#### 2. 기본 리포지토리와 조회 전용 Fragment를 함께 둡니다

Spring Data JPA 공식 문서와 실무 관점에서 보면, Querydsl을 붙일 때는 기본 리포지토리와 조회 전용 fragment를 분리하는 편이 읽기 쉽습니다.

```java
public interface MemberRepository extends JpaRepository<Member, Long>, MemberQueryRepository {
}

public interface MemberQueryRepository {
    Page<MemberListItem> search(MemberSearchCondition condition, Pageable pageable);
}

@Repository
public class MemberQueryRepositoryImpl implements MemberQueryRepository {

    private final JPAQueryFactory queryFactory;

    public MemberQueryRepositoryImpl(JPAQueryFactory queryFactory) {
        this.queryFactory = queryFactory;
    }

    @Override
    public Page<MemberListItem> search(MemberSearchCondition condition, Pageable pageable) {
        // Querydsl 조회 구현
        return Page.empty(pageable);
    }
}
```

이 구조는 **도입 이후의 권장 방향**입니다. 현재 저장소의 실제 구조는 아직 여기에 도달해 있지 않고, 아래에 더 가깝습니다.

```java
public interface MemberRepository extends JpaRepository<Member, Long>, JpaSpecificationExecutor<Member> {
    Optional<Member> findByEmail(String email);
    List<Member> findByNameContainingIgnoreCase(String name);
}
```

즉, 현재 저장소는 Spring Data JPA 기본 리포지토리와 메서드 쿼리, `@Query`, Specification 기반 동적 조건 쪽에 서 있고, Querydsl fragment 구조는 이후 확장안으로 보는 편이 정확합니다.

이 구조의 장점은 세 가지입니다.

- 기본 저장 기능과 조회 전용 로직의 책임이 섞이지 않습니다.
- 서비스 계층이 Querydsl 세부 구현에 덜 의존합니다.
- 목록 API가 복잡해져도 조회 모델을 별도 진화시키기 쉽습니다.
#### 3. `QuerydslPredicateExecutor`는 기본 해법이 아닙니다

간단한 데모에서는 편해 보이지만, 책 원고 기준에서는 기본 권장안으로 두기 어렵습니다.

이유는 다음과 같습니다.

- 조인과 DTO 프로젝션 제어가 약합니다.
- 실제 검색 화면에서 필요한 조건 조합을 세밀하게 표현하기 어렵습니다.
- count 쿼리 분리나 목록 응답 최적화 같은 실무 제어가 제한됩니다.
- API 요구사항이 바뀔수록 Predicate 조립이 서비스나 컨트롤러로 새기 쉽습니다.
즉, `PredicateExecutor`는 간단한 필터에는 쓸 수 있어도, **출판용 기준의 실무 검색 설계 기본값**으로 두기에는 약합니다.

#### 4. 서비스 계층은 쿼리를 조립하지 않습니다

복잡한 조회가 생겼다고 해서 서비스 계층에 `BooleanBuilder`, `where()` 조립 코드를 쌓기 시작하면 구조가 금방 흐려집니다.

서비스 계층의 역할은 다음 쪽에 더 가깝습니다.

- 유스케이스를 조합한다.
- 트랜잭션 경계를 관리한다.
- 입력 조건을 검증하고 조회 리포지토리에 전달한다.
반대로 아래 작업은 조회 전용 리포지토리 쪽으로 보내는 편이 낫습니다.

- 어떤 조인을 사용할지 결정
- 엔티티 대신 어떤 DTO를 반환할지 결정
- count 쿼리를 어떻게 분리할지 결정
- 페이징과 정렬 전략 결정
#### 5. 실무 권장 조합

출판 기준에서 가장 안정적인 기본 조합은 아래와 같습니다.

- `JpaRepository`: 저장, 수정, 삭제, 단건 조회
- Querydsl fragment: 검색, 목록, 조인, 페이징
- DTO projection: API 응답 모델
이 조합이 좋은 이유는 **쓰기 모델과 읽기 모델의 관심사를 최소한으로 분리**하기 때문입니다. CQRS를 과하게 도입하지 않아도, 읽기 복잡도가 높아지는 지점에서 구조가 버텨 줍니다.

#### 6. 언제 `@Query`로 충분한가

모든 조회를 Querydsl로 옮길 필요는 없습니다. 아래 정도면 `@Query`나 쿼리 메서드로도 충분합니다.

- 단일 엔티티 중심의 단순 조회
- 조건이 거의 고정된 조회
- 조인 수가 적고 응답 형태가 안정적인 경우
반대로 아래부터는 Querydsl이 더 자연스럽습니다.

- 조건이 화면 입력에 따라 달라짐
- 정렬, 검색, 범위 조건이 함께 붙음
- 목록 API와 count 최적화가 중요함
- 엔티티가 아니라 DTO 조회가 중심임
#### 7. 추천 구조 예시

패키지 이름은 프로젝트마다 다를 수 있지만, 책임 분리는 비슷하게 가져가는 편이 좋습니다.

```plain text
repository/
  MemberRepository.java
  MemberQueryRepository.java
  MemberQueryRepositoryImpl.java
application/
  dto/
    MemberSearchCondition.java
    MemberListItem.java
```

핵심은 **리포지토리 인터페이스는 도메인에 가깝게, 구현은 조회 기술에 가깝게** 두는 것입니다.

#### 자주 하는 실수

- Querydsl을 붙였는데도 서비스 계층에 조회 로직을 쌓는 것
- 모든 조회를 엔티티 반환으로 통일하는 것
- `PredicateExecutor` 하나로 검색 API를 끝내려는 것
- CRUD 리포지토리와 목록 조회 리포지토리의 책임을 구분하지 않는 것
#### 공식 문서

- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/reference/)
- [Spring Data JPA - Custom Repository Implementations](https://docs.spring.io/spring-data/jpa/reference/repositories/custom-implementations.html)
- [Spring Data JPA - Projections](https://docs.spring.io/spring-data/jpa/reference/repositories/projections.html)
- [Querydsl Reference Guide](https://querydsl.com/static/querydsl/latest/reference/html/)
#### 정리

Spring Data JPA와 Querydsl을 함께 쓸 때 핵심은 “둘 다 쓴다”가 아니라 **무엇을 어느 계층에 맡길지 먼저 결정하는 것**입니다. CRUD는 기본 리포지토리에 남기고, 검색과 목록은 조회 전용 Querydsl fragment로 분리하는 편이 가장 오래 버팁니다.

#### 한 줄 정리

Spring Data JPA와 Querydsl은 **기본 저장 작업과 복잡한 조회를 분리할 때 가장 잘 맞는 조합**입니다.


---

## 6.9 Querydsl 조회 리포지토리 설계

### 개요

이 문서는 Querydsl을 사용할 때 **조회 전용 리포지토리의 인터페이스를 어떻게 만들고, API와 어떤 경계로 연결할지** 정리한 가이드입니다. 핵심은 Querydsl 문법이 아니라 **조회 모델의 표면을 설계하는 것**입니다.

#### 이 문서의 역할

앞 문서에서 Spring Data JPA와 Querydsl의 역할 분담을 정했다면, 이제는 그 결정을 실제 메서드와 DTO 형태로 드러내야 합니다. 책 기준으로 이 문서는 `통합 전략` 다음, `페이징과 성능` 직전의 설계 문서입니다.

#### 현재 저장소 기준에서 읽는 법

현재 `day_by_spring` 저장소는 `MemberQueryRepository` 같은 Querydsl 전용 조회 리포지토리를 아직 두지 않았습니다. 대신 Spring Data JPA 리포지토리 인터페이스 안에서 메서드 쿼리, `@Query`, `JpaSpecificationExecutor`를 섞어 사용합니다.

```java
public interface MemberRepository extends JpaRepository<Member, Long>, JpaSpecificationExecutor<Member> {

    List<Member> findByMembershipTypeAndNameContainingIgnoreCase(MembershipType membershipType, String name);
}
```

```plain text
예상 결과
회원 유형과 이름 조건을 조합한 조회가 Spring Data JPA 리포지토리 한 곳에서 처리된다.
현재 저장소는 조회 전용 리포지토리를 따로 나누기 전 단계이며, 이 문서는 조회 복잡도가 더 커졌을 때의 다음 구조를 설명한다.
```

검색, 목록, 통계 API가 더 늘어나면 그때 Querydsl fragment 또는 조회 전용 리포지토리 분리가 자연스러운 다음 단계가 된다.

#### 1. 조회 전용 리포지토리를 두는 이유

검색 API가 복잡해질수록 서비스 계층에 쿼리 상세가 새어 나오기 쉽습니다. 이때 조회 전용 리포지토리를 두면 책임이 선명해집니다.

- 서비스: 유스케이스 조합, 검증, 트랜잭션 경계
- 조회 리포지토리: 조인, 조건 조합, projection, 페이징
- 컨트롤러: 요청을 DTO로 받고 응답을 반환
즉, Querydsl을 직접 노출하지 않고 **조회 요구사항을 하나의 읽기 전용 경계**로 감싸는 것이 목적입니다.

#### 2. 입력 DTO와 출력 DTO를 분리합니다

조회 API 설계에서 가장 먼저 정리해야 할 것은 메서드 이름보다 데이터 형태입니다.

```java
public record MemberSearchCondition(
        String username,
        String teamName,
        Integer ageGoe,
        Integer ageLoe
) {
}

public record MemberListItem(
        Long memberId,
        String username,
        int age,
        String teamName
) {
}
```

검색 조건과 응답 모델을 분리하면 아래 장점이 생깁니다.

- API 요구사항이 엔티티 구조에 덜 끌려갑니다.
- 조회 조건이 늘어나도 서비스 메서드 시그니처가 덜 무너집니다.
- 목록, 상세, 통계 응답을 목적별로 나누기 쉬워집니다.
#### 3. 리포지토리 인터페이스는 Querydsl 세부사항을 숨깁니다

조회 전용 리포지토리는 `BooleanBuilder`, `JPAQuery`, `Tuple` 같은 구현 세부를 바깥으로 새기지 않는 편이 좋습니다.

```java
public interface MemberQueryRepository {
    Page<MemberListItem> search(MemberSearchCondition condition, Pageable pageable);

    Optional<MemberDetailItem> findDetail(Long memberId);
}
```

좋은 인터페이스의 기준은 단순합니다.

- 입력은 조건 객체와 페이징 정보
- 출력은 DTO, `Page`, `Slice`, `Optional`
- Querydsl 타입은 구현 내부에만 존재
이 원칙을 지키면 나중에 조회 전략이 바뀌어도 서비스와 컨트롤러 수정 범위를 줄일 수 있습니다.

#### 4. 구현은 목록 API 목적에 맞게 작성합니다

```java
@Repository
public class MemberQueryRepositoryImpl implements MemberQueryRepository {

    private final JPAQueryFactory queryFactory;

    public MemberQueryRepositoryImpl(JPAQueryFactory queryFactory) {
        this.queryFactory = queryFactory;
    }

    @Override
    public Page<MemberListItem> search(MemberSearchCondition condition, Pageable pageable) {
        List<MemberListItem> content = queryFactory
                .select(Projections.constructor(MemberListItem.class,
                        member.id,
                        member.username,
                        member.age,
                        team.name))
                .from(member)
                .leftJoin(member.team, team)
                .where(
                        usernameEq(condition.username()),
                        teamNameEq(condition.teamName()),
                        ageGoe(condition.ageGoe()),
                        ageLoe(condition.ageLoe())
                )
                .offset(pageable.getOffset())
                .limit(pageable.getPageSize())
                .fetch();

        Long total = queryFactory
                .select(member.count())
                .from(member)
                .leftJoin(member.team, team)
                .where(
                        usernameEq(condition.username()),
                        teamNameEq(condition.teamName()),
                        ageGoe(condition.ageGoe()),
                        ageLoe(condition.ageLoe())
                )
                .fetchOne();

        return new PageImpl<>(content, pageable, total == null ? 0L : total);
    }
}
```

핵심은 “Querydsl을 썼다”가 아니라 **목록 API가 필요로 하는 응답 모양과 페이징 규칙을 리포지토리 구현 안에서 완결**하는 것입니다.

#### 5. 컨트롤러와 서비스는 얇게 유지합니다

```java
@RestController
@RequiredArgsConstructor
public class MemberController {

    private final MemberQueryService memberQueryService;

    @GetMapping("/members")
    public Page<MemberListItem> searchMembers(MemberSearchCondition condition, Pageable pageable) {
        return memberQueryService.search(condition, pageable);
    }
}
```

```java
@Service
@RequiredArgsConstructor
public class MemberQueryService {

    private final MemberQueryRepository memberQueryRepository;

    @Transactional(readOnly = true)
    public Page<MemberListItem> search(MemberSearchCondition condition, Pageable pageable) {
        return memberQueryRepository.search(condition, pageable);
    }
}
```

여기서 서비스는 쿼리 문장을 조립하지 않습니다. 조회 리포지토리가 읽기 모델을 담당하고, 서비스는 유스케이스 경계만 유지합니다.

#### 6. 목록, 상세, 통계는 같은 방식으로 다루지 않습니다

출판 기준에서는 조회 API를 한 덩어리로 보지 않는 편이 중요합니다.

- 목록 API: DTO projection + 페이징
- 상세 API: 필요한 경우 fetch join 또는 전용 DTO
- 통계 API: 집계 쿼리 전용 메서드
이 구분이 있어야 나중에 `Page`, `Slice`, count 분리, N+1 대응 전략도 자연스럽게 따라옵니다.

#### 7. 메서드 수보다 응답 목적을 먼저 봅니다

`findAll`, `search`, `searchByCondition`, `findList`처럼 이름만 늘리는 것은 큰 도움이 되지 않습니다. 더 중요한 것은 아래 질문입니다.

- 이 API는 목록인가 상세인가
- 엔티티가 필요한가 DTO면 충분한가
- 전체 개수가 필요한가, 다음 페이지 존재 여부만 알면 되는가
- 정렬 기준은 무엇인가
즉, 조회 전용 리포지토리 설계의 핵심은 메서드 개수보다 **읽기 요구사항을 명시적으로 드러내는 것**입니다.

#### 자주 하는 실수

- 조회 로직을 서비스 계층에 직접 작성하는 것
- 엔티티를 그대로 응답 DTO처럼 사용하는 것
- 검색 조건 객체 없이 파라미터를 계속 늘리는 것
- 목록 API와 상세 API를 같은 조회 메서드로 처리하려는 것
- Querydsl 타입을 인터페이스 바깥으로 노출하는 것
#### 공식 문서

- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/reference/)
- [Spring Data JPA - Custom Repository Implementations](https://docs.spring.io/spring-data/jpa/reference/repositories/custom-implementations.html)
- [Spring Data JPA - Projections](https://docs.spring.io/spring-data/jpa/reference/repositories/projections.html)
- [Querydsl Reference Guide](https://querydsl.com/static/querydsl/latest/reference/html/)
#### 정리

Querydsl 조회 설계의 핵심은 복잡한 검색을 한곳에 몰아 넣는 것이 아니라, **읽기 전용 경계를 만들고 그 안에서 조건, projection, 페이징을 책임지게 하는 것**입니다. 이 구조가 잡혀 있어야 이후 성능 최적화도 흔들리지 않습니다.

#### 한 줄 정리

Querydsl 조회 리포지토리 설계의 핵심은 **Querydsl을 노출하지 않고, 읽기 요구사항을 DTO와 메서드 경계로 명확하게 드러내는 것**입니다.


---

## 6.1 데이터베이스 설계 Q&A

#### 개요

이 문서는 데이터베이스 설계를 공부할 때 자주 마주치는 질문을 정리한 Q&A 문서입니다.

#### 정규화를 하면 성능이 떨어지나요

정규화 자체가 문제라기보다, 정규화된 구조 위에서 어떤 조회 패턴이 반복되는지가 더 중요합니다. 성능이 걱정된다면 보통은 역정규화보다 인덱스, 쿼리 최적화, 캐시를 먼저 검토합니다.

#### 인덱스는 어떻게 잡아야 하나요

인덱스는 많이 만드는 것이 아니라, 자주 조회되는 조건에 맞게 만드는 것입니다. `WHERE` 조건에 자주 등장하는 컬럼, `JOIN`에 사용되는 FK 컬럼, 정렬과 페이징에 자주 사용되는 컬럼을 기준으로 잡습니다.

#### 트랜잭션과 락은 언제부터 의식해야 하나요

한 번의 처리에서 여러 데이터가 함께 바뀌는 순간부터 트랜잭션을 생각해야 합니다. 주문 생성과 재고 차감, 계좌 이체, 좌석 예약 같은 상황입니다.

#### 한 줄 정리

DB 설계의 좋은 답은 항상 하나가 아니라, 일관성·성능·운영 비용 사이의 균형에서 나옵니다.

---

## 6.7 Querydsl 동적 쿼리와 조건 조합

#### 개요

이 문서는 Querydsl에서 **동적 쿼리를 어떻게 읽기 좋게 구성할 것인가**를 정리한 자료입니다.

#### 1. BooleanBuilder 방식

```java
public List<Member> search(String usernameCond, Integer ageCond) {
    BooleanBuilder builder = new BooleanBuilder();
    if (usernameCond != null) builder.and(member.username.eq(usernameCond));
    if (ageCond != null) builder.and(member.age.eq(ageCond));
    return queryFactory.selectFrom(member).where(builder).fetch();
}
```

#### 2. BooleanExpression 분리 방식

```java
public List<Member> search(String usernameCond, Integer ageCond) {
    return queryFactory.selectFrom(member)
            .where(usernameEq(usernameCond), ageEq(ageCond))
            .fetch();
}

private BooleanExpression usernameEq(String cond) {
    return cond != null ? member.username.eq(cond) : null;
}
```

#### 한 줄 정리

Querydsl 동적 쿼리는 **조건을 메서드 단위로 잘게 나누어 조합하는 방식**으로 읽기 쉽게 만드는 것이 핵심입니다.

---

## 6.12-1 SQL 연습 문제 풀이

#### 개요

이 문서는 `SQL 연습 문제`의 풀이 가이드입니다. 정답만 나열하기보다, 왜 그 쿼리를 선택했는지와 다른 방식으로 풀 수 있는지까지 함께 보는 것이 목적입니다.

#### 기본 SELECT와 JOIN 풀이

```sql
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Sales';
```

#### 집계와 GROUP BY 풀이

```sql
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;
```

#### 한 줄 정리

좋은 SQL 풀이란 정답을 맞히는 것보다, 왜 그 쿼리가 적절한지 설명할 수 있는 풀이입니다.

---

