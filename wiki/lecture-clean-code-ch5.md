---
title: "Clean Code 실전 강의 — 5장"
type: source
tags: [book, clean-code, uncle-bob, lecture]
sources: [clean-code/클린 코드 실전 강의 교재 5장.md]
created: 2026-06-20
updated: 2026-06-20
---

# 클린 코드 실전 강의 교재

## 5장 — 형식 맞추기

> **대상**: Java/Spring 백엔드 입문~중급 수강생 **형식**: 개념 → 비유 → Before/After → 함정 → 체크리스트 → 퀴즈 **전제 환경**: Java 17+, Spring Boot 3.x

---

## 0. 이 장을 시작하기 전에

### 0.1 학습 목표

- 코드 **세로·가로 형식** 의 합의된 규칙을 익힌다.
- "**신문 기사처럼** 작성하라" — 위에서 아래로 읽힘.
- **팀 규칙** 의 가치 — 개인 취향보다 합의된 일관성.
- IDE 포매터 자동화로 형식 논쟁 종결.

### 0.2 큰 그림

```
[ 목적 ]                  [ 세로 ]                       [ 가로 ]
 의사소통의 일부            5.2.1 신문 기사 패턴            5.3.1 공백·밀집도
 변화에 견디는 가독성        5.2.2 개념 빈 행 분리           5.3.2 정렬 (대개 X)
                            5.2.3 세로 밀집도               5.3.3 들여쓰기
                            5.2.4 수직 거리                 5.4 가짜 범위
                            5.2.5 세로 순서                 5.5 팀 규칙
```

> **비유 — 형식은 "글의 단락"입니다.**
>
> 문단 구분·줄 간격·서체 통일이 책의 읽힘을 만들 듯이, 코드도 그렇습니다. **형식은 의사소통의 일부** 이며, 의사소통은 직업 개발자의 1순위.

### 0.3 현업에서 왜 중요한가

- 형식은 한 번 잡히면 영원 — 매 PR이 그 형식 위에 쌓임.
- **IDE 포매터(EditorConfig·spotless·prettier)** 로 자동화하면 형식 논쟁 0.
- 팀 규칙 < 회사 규칙 < 언어 표준 — 충돌 시 우선순위.

---

## 5.1 형식을 맞추는 목적

### 한 줄 정의

형식의 1차 목적은 **의사소통**. 정확성·일관성·진화 가능성을 위해.

> 오늘 짠 코드의 가독성이 다음 변경의 품질을 결정한다.

### 책의 주장

- 코드는 사라져도 **스타일·규율** 은 계속.
- 형식이 어긋나면 신뢰가 깨짐. "이 클래스만 깔끔하면 뭐 하나, 옆이 엉망인데".

---

## 5.2 적절한 행 길이를 유지하라

### 책의 권장

- 한 파일 **200~500줄** 이내.
- 7개 자바 프로젝트(JUnit 등) 평균 **200~300줄**.

**큰 파일 = 거대 클래스 (악취)** 신호.

### 5.2.1 신문 기사처럼 작성하라

신문 기사:
- **헤드라인** (제목) → **요약** (리드) → **세부** (본문)

코드:
- **파일 이름** → **상위 개념·요약** → **저수준 함수·세부**

→ 위에서 아래로 갈수록 점점 세부. 이 흐름이 "**내려가기 규칙**" (3.3).

### 5.2.2 개념은 빈 행으로 분리하라

```java
package fitnesse.wikitext.widgets;

import java.util.regex.*;

public class BoldWidget extends ParentWidget {
    public static final String REGEXP = "'''.+?'''";

    public BoldWidget(ParentWidget parent, String text) throws Exception {
        super(parent);
        addChildWidgets(text.substring(3, text.length() - 3));
    }
}
```

- 패키지 / import / 클래스 정의가 빈 행으로 분리.
- 빈 행은 **새로운 개념의 시작** 신호.

### 5.2.3 세로 밀집도

서로 **밀접한 코드** 는 세로로 가깝게:

```java
// ❌ 함수의 두 변수가 빈 줄로 떨어짐
public class ReporterConfig {
    private String className;

    private List<Property> properties = new ArrayList<>();
}

// ✅ 밀접한 변수는 붙여서
public class ReporterConfig {
    private String className;
    private List<Property> properties = new ArrayList<>();
}
```

### 5.2.4 수직 거리

서로 호출하는 함수는 **가까이 두라**.

- 호출하는 함수 위, 호출되는 함수 아래.
- 변수 선언은 사용 직전.
- 인스턴스 변수는 클래스 최상단.

### 5.2.5 세로 순서

위 = 추상, 아래 = 구체. **신문 기사 패턴** 의 코드 버전.

---

## 5.3 가로 형식 맞추기

### 책의 권장

- 한 줄 **80~120자**. 책에서는 120 이상 거의 없음.
- 가로 스크롤 강제는 가독성 폭망.

### 5.3.1 가로 공백과 밀집도

```java
// 우선순위가 높은 연산자는 붙이고, 낮은 건 띄움
return b*b - 4*a*c;       // ✅
return b * b - 4 * a * c; // 책 권장은 위
```

함수 호출:
- 함수명과 `(` 붙임 (`compareTo(b)` X `compareTo (b)`)
- 인자 사이 `,` 뒤 공백

### 5.3.2 가로 정렬

```java
// ❌ — 책은 권장 안 함
private   String  name;
private   int     age;
protected boolean active;
```

이유: 정렬을 유지하기 위해 변수가 늘어날 때마다 모든 줄 수정. IDE Auto Format이 깨뜨림. **그냥 한 칸씩 띄워라**.

```java
// ✅
private String name;
private int age;
protected boolean active;
```

### 5.3.3 들여쓰기

```java
// ❌ — 들여쓰기 무시
public class CommentWidget extends TextWidget { public CommentWidget(ParentWidget parent, String text) { super(parent, text); } }

// ✅
public class CommentWidget extends TextWidget {
    public CommentWidget(ParentWidget parent, String text) {
        super(parent, text);
    }
}
```

작은 함수도 들여쓰기 유지. IDE 자동.

---

## 5.4 가짜 범위 (Dummy Scopes)

```java
while (dis.read(buf, 0, readBufferSize) != -1)
    ;   // 가짜 범위 — 세미콜론만
```

이런 경우 세미콜론을 **새 줄에 + 들여쓰기**:

```java
while (dis.read(buf, 0, readBufferSize) != -1)
    ;
```

빈 본문이 명시되어 실수 위험 ↓.

---

## 5.5 팀 규칙

### 한 줄 정의

**팀이 합의한 한 가지 형식** 을 따라라. 개인 취향 < 일관성.

### 권장

- **EditorConfig** (`.editorconfig`)
- **spotless** (Java), **prettier** (JS/TS), **black** (Python)
- IDE 자동 포매터 단축키 (`Cmd+Opt+L` / `Ctrl+Alt+L`)
- **CI에서 포매터 위반 = 빌드 실패**

### Spring 현업

```yaml
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
trim_trailing_whitespace = true
insert_final_newline = true

[*.{kt,kts,md,yml,yaml}]
indent_size = 2
```

---

## 5.6 밥 아저씨의 형식 규칙

책에서 Uncle Bob이 자기 코드에 적용하는 규칙 발췌.

- 한 파일 200~500줄
- 한 줄 120자 이내
- 변수는 첫 사용 가까이
- 인스턴스 변수는 클래스 상단
- 종속 함수는 호출 함수 아래
- 빈 행은 개념 사이에만

---

## 핵심 교훈

1. **형식은 의사소통의 일부** — 사소해 보이지만 큰 영향.
2. **신문 기사 패턴** — 위에서 아래로 갈수록 추상 → 구체.
3. **빈 행은 개념 분리의 신호** — 남용 금지.
4. **밀접한 코드는 가깝게**.
5. **팀 규칙 우선** — 개인 취향 < 일관성.
6. **IDE 포매터 + CI** 로 자동화하면 형식 논쟁 0.

---

## 함정 / 주의

- 가로 정렬은 **유지 비용 큼** → 책 권장 X.
- 들여쓰기 4 vs 2 칸은 팀 선택. 일관성이 핵심.
- **80자 vs 120자** — 모니터 시대엔 120이 합리적이지만, diff 가독성 위해 80도 정당.

---

## 체크리스트 (팀 합의용)

- [ ] `.editorconfig` 가 저장소 루트에 있는가
- [ ] IDE 자동 포매터가 모든 팀원에게 설정됐는가
- [ ] CI에 spotless·prettier 검증이 있는가
- [ ] 한 파일이 500줄 이하인가
- [ ] 한 줄이 120자 이하인가
- [ ] 인스턴스 변수가 클래스 상단인가
- [ ] 종속 함수가 호출 함수 아래인가

---

## 퀴즈

**Q1. "신문 기사 패턴" 을 코드에 적용하면?**

**A.** 위 = 상위 개념·요약, 아래로 갈수록 세부. 파일 상단에 추상 메서드·main 흐름, 하단에 저수준 헬퍼. 독자가 위에서 아래로 자연스럽게 추상 → 구체로 내려가게.

**Q2. 가로 정렬을 책이 권장 안 하는 이유?**

**A.** 변수가 추가될 때마다 모든 줄 재정렬 필요 + IDE 자동 포매터가 정렬을 깨뜨림. **유지 비용이 너무 큼**. 단순히 한 칸씩 띄우는 게 안정적.

**Q3. 팀 규칙이 개인 취향보다 우선인 이유?**

**A.** 일관된 형식이 **코드베이스 전체의 가독성** 을 결정. 한 클래스가 더 깔끔해도 옆 클래스가 다른 스타일이면 전체 신뢰가 깨짐. 그래서 모두가 같은 규칙을 따라야.

**Q4. 형식 자동화 (`spotless`·CI) 의 가치?**

**A.** **형식 논쟁 0**. PR에서 "탭/공백·세미콜론·들여쓰기" 논쟁이 사라지고 본질(설계·로직) 에만 집중 가능. 새 팀원도 1분 안에 팀 스타일 따름.

**Q5. 한 파일이 1,000줄을 넘으면 무엇을 의심?**

**A.** **거대 클래스** (악취 [[entity-refactoring]] 3.20) 신호. SRP 위배 가능성 높음. 형식 문제가 아니라 **구조 문제** — 클래스 추출 (7.5) 검토.

---

## 다음 장 예고 — 6장: 객체와 자료 구조

**자료 추상화·자료/객체 비대칭·디미터 법칙**. "자료 구조는 함수 추가에 강하고, 객체는 새 타입 추가에 강하다" 라는 핵심 통찰. *오브젝트* 의 책임 주도 설계와 직결.
