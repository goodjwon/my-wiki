# raw/harness-engineering/

하네스 엔지니어링 실습 커리큘럼 원본 자료 모음.

## 자료 구성

| 파일 | 형식 | 설명 |
|------|------|------|
| `harness_engineering.pdf` | PDF | 원본 슬라이드 덱 (10페이지) |
| `harness_engineering.md` | MD | 위 PDF의 마크다운 변환본 (검색·열람용) |
| `하네스엔지니어링_슬라이드해설_강의교안.docx` | DOCX | 슬라이드별 강사용 해설 교안 (원본) |
| `하네스엔지니어링_슬라이드해설_강의교안.md` | MD | 위 DOCX의 마크다운 변환본 (검색·열람용) |
| `harness-engineering-tutor-prompt.md` | MD | 튜터(LLM)에게 주는 진행 프롬프트 |
| `harness-kit/` | DIR | 5모듈 실습 키트 (module1~5) |

## 추천 읽기 순서

1. **`harness_engineering.md`** — 전체 5모듈 한눈에 (슬라이드 압축본, 빠른 개요)
2. **`하네스엔지니어링_슬라이드해설_강의교안.md`** — 슬라이드 + 강의 멘트 + 용어 + 이론 (가장 풍부)
3. **`harness-kit/`** — 실제 적용용 템플릿/스크립트 (CLAUDE.md, guard.sh, AGENTS.md 등)
4. **`harness-engineering-tutor-prompt.md`** — Claude 튜터 모드로 실습 진행하고 싶을 때

## harness-kit 구조

```
harness-kit/
├── module1/  — 왜 프롬프트로는 부족한가
├── module2/  — CLAUDE.md 에이전트 헌법 (★ Spring Boot DDD 템플릿)
├── module3/  — Claude Code Hooks (★ guard.sh, lint-fix.sh, hooks-config.json)
├── module4/  — 멀티 에이전트 (★ AGENTS.md, task-list.md, claude-progress.txt)
└── module5/  — 하네스 진화 (주간 리뷰 템플릿)
```

## 위키 페이지 매핑

| Wiki 페이지 | 주로 참조하는 원본 |
|-------------|------------------|
| [`wiki/src-harness-engineering.md`](../../wiki/src-harness-engineering.md) | 전체 |
| [`wiki/concept-harness-engineering.md`](../../wiki/concept-harness-engineering.md) | 슬라이드 1·2·4·8 |
| [`wiki/concept-claude-md.md`](../../wiki/concept-claude-md.md) | 슬라이드 5 + `harness-kit/module2/CLAUDE.md` |
| [`wiki/concept-claude-hooks.md`](../../wiki/concept-claude-hooks.md) | 슬라이드 6 + `harness-kit/module3/` |
| [`wiki/concept-multi-agent-pattern.md`](../../wiki/concept-multi-agent-pattern.md) | 슬라이드 7 + `harness-kit/module4/` |

## 출처

- Karpathy CLAUDE.md — https://github.com/forrestchang/andrej-karpathy-skills
- OpenAI Harness Engineering — https://openai.com/index/harness-engineering/
- Mitchell Hashimoto 블로그 — https://mitchellh.com
- Claude Code Hooks 공식 문서 — https://docs.anthropic.com/claude-code/hooks
