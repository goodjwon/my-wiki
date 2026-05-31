# 실습 5-1: 하네스 저장소 구조화 프롬프트

## 목적
지금까지 만든 모든 하네스 파일을 git으로 관리하고,
팀원이 클론하면 동일한 환경이 되도록 구조화합니다.

---

## Step 1: 저장소 구조 설계 프롬프트

```
지금까지 만든 하네스 파일들을 git 저장소에 정리해줘.

## 현재 있는 파일들
- CLAUDE.md (프로젝트 루트)
- AGENTS.md (프로젝트 루트)
- .claude/hooks/guard.sh
- .claude/hooks/lint-fix.sh
- .claude/hooks/update-progress.sh
- claude-progress.txt
- task-list.md

## 해야 할 일
1. 현재 파일 위치 확인
   find . -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "*.sh" | grep -v node_modules

2. .gitignore 확인 및 수정
   - claude-progress.txt: 개인용이면 .gitignore에 추가, 팀 공유면 추적
   - task-list.md: 팀 공유 → git 추적
   - .claude/hooks/: git 추적 (팀 공유 하네스)

3. README.md에 하네스 사용법 섹션 추가

4. 전체 커밋
   git add CLAUDE.md AGENTS.md .claude/ task-list.md
   git commit -m "harness: add agent harness configuration"
```

---

## Step 2: 팀 온보딩 체크리스트 추가 프롬프트

```
README.md에 새 팀원을 위한 하네스 온보딩 섹션을 추가해줘.

## 포함할 내용

### 하네스 설정 (신규 팀원용)

1. CLAUDE.md 읽기
   - Claude Code 시작 전 반드시 읽을 것

2. Hooks 권한 설정
   chmod +x .claude/hooks/*.sh

3. Claude Code 시작 방법
   claude (프로젝트 루트에서)

4. 첫 세션에서 실행할 명령
   cat claude-progress.txt  # 현재 상태 파악
   cat task-list.md          # 진행 중인 태스크 확인

5. 주간 리뷰 참여
   매주 금요일 weekly-harness-review.md 작성 후 PR

형식: 마크다운, 기존 README 스타일에 맞게
```

---

# 실습 5-3: Rippable 하네스 점검 프롬프트

## 목적
모델 개선으로 이미 불필요해진 하네스 규칙을 찾아 제거합니다.
과엔지니어링을 방지하고 하네스를 가볍게 유지합니다.

---

## Claude Code에 붙여넣을 프롬프트

```
현재 CLAUDE.md와 guard.sh를 분석해서 불필요한 규칙을 찾아줘.

## 분석 방법

### 1. 지난 4주 git log에서 위반 사례 검색
git log --all --oneline --since="4 weeks ago" > /tmp/recent_commits.txt
cat /tmp/recent_commits.txt

각 CLAUDE.md 규칙에 대해:
- 이 규칙이 위반된 커밋이 있는가?
- 없다면: 모델이 자연스럽게 지키는 것인가, 아니면 애초에 발생하지 않는 상황인가?

### 2. guard.sh 차단 로그 분석 (있다면)
cat /tmp/guard-blocked.log 2>/dev/null || echo "차단 로그 없음"

### 3. 규칙 분류

다음 표를 채워줘:

| 규칙 | 위치 | 지난 4주 위반 | 판단 | 권고 |
|------|------|------------|------|------|
| Entity 직접 노출 금지 | CLAUDE.md #7 | 0회 | 모델이 자연 준수 | 유지 (중요) |
| @Autowired 금지 | CLAUDE.md #7 | 0회 | Spring 최신 관례 | 삭제 검토 |
| ... | ... | ... | ... | ... |

### 4. 삭제 권고 기준
- 지난 4주 위반 0회 AND 현재 모델이 기본적으로 지키는 관례
→ 삭제 또는 주석으로 이동 권고

- 지난 4주 위반 0회 BUT 한 번 위반 시 큰 피해
→ 유지 (중요한 안전장치)

### 5. 결론
삭제해도 되는 규칙 N개, 유지해야 하는 규칙 M개를 구분해서 PR 형태로 제안해줘.
```
