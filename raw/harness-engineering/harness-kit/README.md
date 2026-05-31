# 하네스 엔지니어링 실습 키트

> Karpathy CLAUDE.md × OpenAI Harness Engineering × Mitchell Hashimoto
> Spring Boot DDD 프로젝트에 하네스 엔지니어링을 적용하는 실습 자료 모음

---

## 파일 구조

```
harness-kit/
│
├── module1/  ─── 왜 프롬프트로는 부족한가
│   ├── 01_failure_audit_prompt.md     # 실패 패턴 감사 프롬프트
│   └── 02_baseline_prompt.md          # 베이스라인 측정 가이드
│
├── module2/  ─── CLAUDE.md 에이전트 헌법
│   ├── CLAUDE.md                      # ★ Spring Boot DDD용 템플릿
│   ├── 01_draft_claude_md_prompt.md   # CLAUDE.md 초안 작성 프롬프트
│   └── 02_before_after_prompt.md      # Before/After 비교 프롬프트
│
├── module3/  ─── Claude Code Hooks
│   ├── guard.sh                       # ★ Pre-Tool Hook: 위험 명령 차단
│   ├── lint-fix.sh                    # ★ Post-Tool Hook: 자동 포맷
│   ├── hooks-config.json              # ★ Hooks 설정 파일 예시
│   ├── 01_hooks_setup_prompt.md       # Hooks 설정 구현 프롬프트
│   └── 02_self_verify_prompt.md       # 자기검증 루프 구축 프롬프트
│
├── module4/  ─── 멀티 에이전트
│   ├── AGENTS.md                      # ★ Planner/Coder/Critic 역할 정의
│   ├── task-list.md                   # ★ 태스크 목록 템플릿
│   ├── claude-progress.txt            # ★ 세션 인계 파일 템플릿
│   └── 01_threettier_workflow_prompt.md # 3-tier 워크플로우 프롬프트
│
└── module5/  ─── 하네스 진화
    ├── weekly-harness-review.md       # ★ 주간 리뷰 템플릿
    ├── 01_repo_and_rippable_prompt.md # 저장소 구조화 + Rippable 점검
    └── 02_weekly_review_prompt.md     # 주간 리뷰 실습 프롬프트
```

---

## 빠른 시작 (Quick Start)

### 1단계: 베이스라인 측정
```
module1/02_baseline_prompt.md 열기
→ 태스크 A, B, C를 하네스 없이 실행
→ 결과를 베이스라인 기록 시트에 기록
```

### 2단계: CLAUDE.md 배포
```
module2/CLAUDE.md를 프로젝트 루트에 복사
→ module2/01_draft_claude_md_prompt.md로 커스터마이징
→ git commit
```

### 3단계: Hooks 설치
```bash
mkdir -p .claude/hooks
cp module3/guard.sh .claude/hooks/
cp module3/lint-fix.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

### 4단계: 멀티 에이전트 구조
```
module4/AGENTS.md를 프로젝트 루트에 복사
module4/task-list.md를 프로젝트 루트에 복사
module4/claude-progress.txt를 프로젝트 루트에 복사
→ module4/01_threettier_workflow_prompt.md로 첫 실습
```

### 5단계: 주간 루틴
```
매주 금요일:
module5/02_weekly_review_prompt.md 실행
→ 발견된 패턴을 CLAUDE.md + guard.sh에 추가
→ git commit
```

---

## 핵심 원칙

| 원칙 | 설명 |
|------|------|
| 부탁 대신 구조 | 프롬프트는 부탁이다. guard.sh가 막으면 에이전트는 못 한다. |
| 실패가 규칙이 된다 | 같은 실수 두 번 → 즉시 CLAUDE.md 추가. |
| 검증 가능한 목표 | [단계] → verify: [확인법]. 성공 기준이 없으면 루프를 멈춘다. |
| 하네스는 자산이다 | 팀원과 모델이 바뀌어도 하네스는 남는다. |

---

## 참고 자료

- [Karpathy CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills)
- [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/)
- [Mitchell Hashimoto 블로그](https://mitchellh.com)
- [Claude Code Hooks 공식 문서](https://docs.anthropic.com/claude-code/hooks)
