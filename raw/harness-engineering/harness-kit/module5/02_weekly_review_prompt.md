# 실습 5-2: 주간 하네스 리뷰 실습 프롬프트

## 목적
지난 1주일 Claude Code 작업 실패를 수집하고,
각각을 CLAUDE.md 규칙 또는 guard.sh 항목으로 전환합니다.

---

## Claude Code에 붙여넣을 프롬프트

```
지난 1주일 작업 내역을 분석해서 하네스 리뷰를 도와줘.

## Step 1: 실패 패턴 수집

다음 명령들을 실행해서 실패 흔적을 찾아줘:

# 1. 수정을 여러 번 반복한 파일
git log --all --oneline --since="1 week ago" --follow -- "*.java" | \
  awk '{print $NF}' | sort | uniq -c | sort -rn | head -10

# 2. revert 커밋
git log --all --oneline --since="1 week ago" | grep -i "revert\|fix\|hotfix\|rollback"

# 3. TODO/FIXME가 새로 추가된 파일
git diff HEAD~7 HEAD --diff-filter=M | grep "^\+" | grep -i "TODO\|FIXME\|HACK\|XXX"

# 4. 테스트가 깨진 커밋
git log --all --oneline --since="1 week ago" | grep -i "test\|fix test\|broken"

## Step 2: 분류

발견된 패턴들을 다음 기준으로 분류해줘:

A. **CLAUDE.md 규칙으로 전환 가능**
   → "작업 전 [이런 것]을 확인하라" 형태의 규칙

B. **guard.sh 차단 규칙으로 전환 가능**
   → "이 명령/패턴은 실행을 막는다" 형태의 규칙

C. **프롬프트 개선으로 해결**
   → 사용자가 더 명확히 지시하면 해결되는 문제

D. **에이전트 한계 (허용)**
   → 현재 기술로는 방지 불가능한 문제

## Step 3: 규칙 초안 작성

A와 B에 해당하는 패턴에 대해 규칙 초안을 작성해줘:

A의 경우:
```
[섹션 7 추가 항목]
STOP: [금지 행동]
이유: [왜 금지인가]
대안: [대신 해야 할 것]
```

B의 경우:
```bash
# guard.sh 추가 항목
if echo "$COMMAND" | grep -qE "[패턴]"; then
  block "[이름]" \
    "[이유]" \
    "[대안]"
fi
```

## Step 4: weekly-harness-review.md 업데이트

위 분석 결과를 weekly-harness-review.md 형식에 맞게 작성해줘.
그리고 실제로 CLAUDE.md와 guard.sh를 업데이트하고 커밋해줘:

git add CLAUDE.md .claude/hooks/guard.sh
git commit -m "harness: weekly review - add N new rules

- [규칙 1 요약]
- [규칙 2 요약]

Reviewed-by: Critic Agent"
```
