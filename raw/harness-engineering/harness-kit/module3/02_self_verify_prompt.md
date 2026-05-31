# 실습 3-2: 자기검증 루프 구축 프롬프트

## 목적
에이전트가 코드를 작성한 후 스스로 테스트를 실행하고, 실패하면 수정하는 루프를 만듭니다.
"완료"라고 말하기 전에 반드시 검증하게 강제합니다.

---

## Claude Code에 붙여넣을 프롬프트

```
지금부터 모든 구현 작업에 자기검증 루프를 적용해줘.

## 자기검증 루프 규칙

구현이 끝났다고 판단되면, "완료"라고 말하기 전에 반드시:

### 1단계: 컴파일 확인
./gradlew compileJava compileTestJava
→ 실패하면 수정 후 재시도. 통과할 때까지 반복.

### 2단계: 단위 테스트
./gradlew test --tests "${변경된 클래스와 관련된 테스트}"
→ 실패하면 원인 파악 후 수정. 통과할 때까지 반복.

### 3단계: 전체 테스트 (선택)
./gradlew test
→ 기존 테스트가 깨졌으면 내 변경이 원인인지 확인.
   내 변경이 원인이면 수정. 기존 버그면 보고만 한다.

### 4단계: 검증 완료 보고
다음 형식으로 보고한다:

---검증 완료 보고---
구현 내용: [한 줄 요약]
컴파일: ✅ 통과
단위 테스트: ✅ N개 통과 (0개 실패)
전체 테스트: ✅ N개 통과 (0개 실패)
추가된 테스트: [테스트 클래스명 및 메서드명]
변경된 파일: [파일 목록]
---

## 지금 적용할 태스크
위 자기검증 루프를 적용해서 다음을 구현해줘:

[여기에 태스크 내용 입력]
```

---

## 고급: 통합 테스트 루프 (API 레벨)

```
구현 완료 후 API 레벨 자기검증도 추가해줘.

## API 검증 단계

### RestAssured 통합 테스트 실행
./gradlew integrationTest

### 실패 케이스 자동 수정 루프
테스트가 실패하면:
1. 실패 메시지 읽기
2. 원인 파악 (비즈니스 로직? API 스펙? 데이터 설정?)
3. 수정
4. 재실행
5. 최대 3회까지 자동 시도, 3회 초과 시 나에게 보고

### 검증 완료 기준
- 신규 API: 정상 케이스 + 경계값 + 에러 케이스 모두 통과
- 수정 API: 기존 테스트 + 새 케이스 모두 통과
```

---

## update-progress.sh (세션 종료 시 자동 실행)

아래 스크립트를 `.claude/hooks/update-progress.sh`에 저장:

```bash
#!/bin/bash
# 세션 종료 시 claude-progress.txt 자동 업데이트

DATE=$(date '+%Y-%m-%d %H:%M')
LAST_COMMIT=$(git log --oneline -1)
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | head -10)
TEST_RESULT=$(./gradlew test --quiet 2>&1 | tail -3)

cat > claude-progress.txt << EOF
# Claude Progress — 마지막 업데이트: $DATE

## 마지막 커밋
$LAST_COMMIT

## 변경된 파일 (최근)
$CHANGED_FILES

## 테스트 상태
$TEST_RESULT

## 다음 태스크
(task-list.md 참조)

## 주의사항
(세션 중 발견된 이슈를 여기에 기록)
EOF

echo "✅ claude-progress.txt 업데이트 완료"
```
