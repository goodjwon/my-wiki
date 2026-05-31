---
title: Vannevar Bush
type: entity
tags: [인물, 역사, 컴퓨터과학, 하이퍼텍스트]
sources: [llm-wiki-pattern/llm-wiki-pattern.md]
external: [https://en.wikipedia.org/wiki/Vannevar_Bush, https://en.wikipedia.org/wiki/As_We_May_Think]
created: 2026-04-18
updated: 2026-05-31
---

# Vannevar Bush

미국의 공학자·과학 행정가 (1890.3.11 ~ 1974.6.28). 1945년 에세이 **"As We May Think"** 에서 [[concept-memex|Memex]]를 제안하여 개인 지식 관리와 하이퍼텍스트의 사상적 기초를 놓았다.

## 생애·주요 업적

| 시기 | 역할 |
|------|------|
| 1919 | MIT 전기공학과 합류 |
| 1932 | MIT 부총장 겸 공학대학원장 |
| 1941~1947 | **OSRD**(Office of Scientific Research and Development) 초대 디렉터 — 2차 대전기 미국 과학자 약 6,000명의 연구를 총괄 |
| 1942~ | 맨해튼 프로젝트 군사정책위원회 의장. Trinity 핵실험(1945.7.16) 참관 |
| 1945 | 보고서 _Science, The Endless Frontier_ — 연방 연구비 지원 체계를 주창, **NSF**(1950 설립) 설계의 기반 |
| 1945.7 | _The Atlantic_ 에 "As We May Think" 발표 |

## "As We May Think" (1945)

전후, 과학자들이 파괴에서 **지식 접근성 향상**으로 방향을 돌려야 한다는 호소문. 핵심 진단:

> "When data of any sort are placed in storage, they are filed alphabetically or numerically, and information is found (when it is) by tracing it down from subclass to subclass."

→ 알파벳·계층적 인덱싱은 인간 사고 방식과 맞지 않는다. **연상적(associative) 연결**이 필요하다.

## Memex 구상

마이크로필름 기반 책상 크기 장치. 두 개의 뷰어 화면, 마이크로필름 상에 부호화된 점으로 항목을 연결. 사용자는 임의의 두 항목 사이에 **trail(연상의 길)** 을 만들고 나중에 이름을 붙여 다시 호출할 수 있다 — 이것이 **하이퍼링크의 직접적 선조**.

자세한 개념 분리: [[concept-memex]]

## 후세에 미친 영향

- **Douglas Engelbart** — 1945년 직후 에세이를 읽고 Memex를 염두에 두며 마우스·워드프로세서·하이퍼링크 개념 발전.
- **Ted Nelson** — Xanadu 프로젝트 / "hypertext" 용어의 출발점으로 As We May Think를 명시 인용.
- **Tim Berners-Lee** — WWW 설계의 사상적 배경 중 하나.

→ 개인 컴퓨터·인터넷·위키피디아 자체를 예언한 글로 평가된다.

## LLM Wiki와의 관계

[[src-llm-wiki-pattern|LLM Wiki 패턴]]은 Bush의 Memex 비전 — 개인이 큐레이팅하는 지식 저장소, 문서 간 연상적 연결 — 을 LLM으로 실용적으로 구현한 것으로 위치시킨다. **Bush가 해결하지 못한 유지보수 문제를 LLM이 담당한다.**

> 원본 인용 (`raw/llm-wiki-pattern/llm-wiki-pattern.md`):
> "The part he couldn't solve was who does the maintenance. The LLM handles that."

## 원본 출처

- raw: `raw/llm-wiki-pattern/llm-wiki-pattern.md` (마지막 단락)
- 외부: [Wikipedia — Vannevar Bush](https://en.wikipedia.org/wiki/Vannevar_Bush) / [Wikipedia — As We May Think](https://en.wikipedia.org/wiki/As_We_May_Think)

## 관련

- [[concept-memex]] — Bush가 제안한 장치
- [[src-llm-wiki-pattern]] — LLM Wiki 패턴 (Memex 비전의 현대 구현)
- [[concept-compounding-knowledge]] — 시간에 따라 누적되는 지식의 가치
