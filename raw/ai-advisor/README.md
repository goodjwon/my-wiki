# ai-advisor — Advisor–Worker 에이전트 스크립트

Claude Code에서 **판단(Advisor)과 구현(Worker)을 분리**하는 협업 모델의 에이전트 정의·프로젝트 지침 세트.

## 자료 구성

| 파일 | 내용 | 배치 위치 (사용 시) |
|------|------|--------------------|
| `advisor_script.md` | Advisor 에이전트 정의 — 요구사항 분석·작업 분해·브리프 작성·검증·커밋 승인 (Fable 5) | `.claude/agents/advisor.md` |
| `worker_script.md` | Worker 에이전트 정의 — 브리프대로 구현·자체 검증·구조화 보고 (Opus 4.8) | `.claude/agents/worker.md` |
| `claude_script.md` | 프로젝트 지침 템플릿 — 협업 모델·위임 규율·설계 원칙·브리프 형식 | 프로젝트 루트 `CLAUDE.md` |
| `a.md` | (빈 파일) | — |

## 읽기 순서

1. `claude_script.md` — 협업 모델 전체 그림
2. `advisor_script.md` — Advisor의 판단·검증 규율
3. `worker_script.md` — Worker의 실행·보고 규율

## 위키 페이지

- [[src-ai-advisor-worker]] — 이 자료의 source 페이지
