# 실습 3-1: Hooks 설정 구현 프롬프트

## 목적
guard.sh와 lint-fix.sh를 프로젝트에 연결하고, 실제로 차단이 작동하는지 검증합니다.

---

## Step 1: 폴더 구조 생성

```bash
mkdir -p .claude/hooks
cp harness-kit/module3/guard.sh .claude/hooks/guard.sh
cp harness-kit/module3/lint-fix.sh .claude/hooks/lint-fix.sh
chmod +x .claude/hooks/guard.sh
chmod +x .claude/hooks/lint-fix.sh
```

---

## Step 2: Claude Code에 붙여넣을 설정 프롬프트

```
현재 프로젝트에 Claude Code hooks를 설정해줘.

## 해야 할 일
1. .claude/hooks/ 디렉토리가 있는지 확인
2. 다음 파일들을 확인하고 실행 권한 부여:
   - .claude/hooks/guard.sh
   - .claude/hooks/lint-fix.sh

3. Claude Code settings에 hooks 설정 추가
   - PreToolUse: Bash 실행 전 guard.sh 실행
   - PostToolUse: Write/Edit 후 lint-fix.sh 실행

4. hooks 설정이 올바른지 확인하기 위해 다음을 실행해줘:
   - cat .claude/hooks/guard.sh | head -20 (파일 존재 확인)
   - bash .claude/hooks/guard.sh "git push origin main" (차단 테스트)

## 기대 결과
"git push origin main" 명령이 guard.sh에 의해 차단되어야 함
```

---

## Step 3: 차단 동작 검증 프롬프트

```
guard.sh가 올바르게 작동하는지 검증해줘.

다음 명령어들을 순서대로 테스트해줘:

## 차단되어야 하는 명령 (exit code 1이어야 함)
1. bash .claude/hooks/guard.sh "rm migration/V1__init.sql"
2. bash .claude/hooks/guard.sh "git push origin main"  
3. bash .claude/hooks/guard.sh "DROP TABLE contract"
4. bash .claude/hooks/guard.sh "echo $DB_PASSWORD"

## 허용되어야 하는 명령 (exit code 0이어야 함)
5. bash .claude/hooks/guard.sh "./gradlew build"
6. bash .claude/hooks/guard.sh "git checkout -b feature/add-email"
7. bash .claude/hooks/guard.sh "cat src/main/java/Contract.java"

각 테스트 결과를 표로 정리해줘:
| 명령 | 기대 | 실제 | 통과 |
|------|------|------|------|
```

---

## Step 4: 우리 프로젝트 특화 규칙 추가 프롬프트

```
guard.sh에 우리 프로젝트 특화 차단 규칙을 추가해줘.

## 추가할 규칙
1. 지방계약법 관련 테이블 직접 수정 차단
   - 차단 패턴: "ALTER TABLE contract_" 또는 "ALTER TABLE bid_"
   - 이유: 공공조달 시스템 스키마 변경은 반드시 Migration 파일 경유

2. application.properties 민감 정보 직접 입력 차단  
   - 차단 패턴: "datasource.password=" 값이 실제 비밀번호인 경우
   - 허용: "${DB_PASSWORD}" 형식의 환경변수 참조는 OK

3. 특정 레거시 패키지 import 차단
   - 차단 패턴: "import com.example.legacy."
   - 이유: 레거시 패키지는 신규 코드에서 사용 금지

## 추가 방법
guard.sh의 "차단 규칙" 섹션에 추가하고,
각 규칙에 block() 함수를 사용해서 명확한 에러 메시지 포함
```
