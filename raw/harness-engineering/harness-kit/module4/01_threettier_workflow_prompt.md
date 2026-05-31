# 실습 4-1: Planner-Coder-Critic 워크플로우 프롬프트

## 목적
실제 기능 구현에 3-tier 에이전트 구조를 적용합니다.
이 실습에서는 "입찰 공고 등록" 기능을 예시로 사용합니다.
(본인 프로젝트의 실제 기능으로 교체하세요)

---

## Step 1: Planner Agent 프롬프트

```
너는 지금부터 Planner Agent로 동작해.
AGENTS.md의 Planner 역할 정의를 읽고 따라줘.

## 요구사항
다음 기능을 원자 단위 태스크로 분해해줘:

"지방계약법에 따른 입찰공고(BidNotice) 등록 기능
 - 공고번호 자동 생성 (연도-기관코드-일련번호)
 - 입찰방법 (일반경쟁/제한경쟁/지명경쟁) 선택
 - 추정가격 및 낙찰하한율 설정
 - 공고 등록 시 담당자 이메일 알림 발송"

## 출력 형식
task-list.md 형식으로 태스크 목록을 작성해줘.
각 태스크는:
- 2시간 이내 완료 가능한 크기
- 명확한 verify 기준
- DDD 레이어별로 분리 (domain → application → infrastructure → interfaces 순서)

## 제약
- BidNotice 도메인은 Contract 도메인과 별개의 Aggregate
- 공고번호 생성 로직은 도메인 서비스로 분리
- 이메일 발송은 도메인 이벤트로 처리 (직접 호출 금지)
```

---

## Step 2: Coder Agent 프롬프트 (태스크별 반복)

```
너는 지금부터 Coder Agent로 동작해.
AGENTS.md의 Coder 역할 정의를 먼저 읽어줘.

## 지금 할 태스크
task-list.md에서 다음 태스크를 구현해:
[TASK-001: BidNotice 도메인 엔티티 설계]

## 실행 순서
1. claude-progress.txt 읽기 (현재 상태 파악)
2. CLAUDE.md 섹션 7 (절대 금지) 재확인
3. 단계별 계획 제시 (구현 전):
   - Step 1: [내용] → verify: [방법]
   - Step 2: [내용] → verify: [방법]
4. 구현 실행
5. 자기검증 루프 실행 (컴파일 → 테스트)
6. 검증 완료 보고 형식으로 결과 보고

## 완료 기준
- [ ] BidNotice 엔티티 + 필요한 VO 정의
- [ ] BidNoticeId, BidMethod, EstimatedPrice VO 구현
- [ ] BidNoticeCreated 도메인 이벤트 정의
- [ ] 도메인 단위 테스트 작성 (최소 5개 케이스)
- [ ] ./gradlew test --tests "BidNoticeTest" 통과
```

---

## Step 3: Critic Agent 프롬프트

```
너는 지금부터 Critic Agent로 동작해.
AGENTS.md의 Critic 역할 정의를 먼저 읽어줘.

## 검토 대상
Coder Agent가 방금 구현한 BidNotice 도메인 엔티티를 검토해줘.

## 검토 명령
다음 파일들을 읽어줘:
- find src -name "BidNotice.java" -exec cat {} \;
- find src -name "BidNotice*Test.java" -exec cat {} \;
- find src -name "Bid*.java" -path "*/domain/*" -exec cat {} \;

## 검토 기준 (AGENTS.md Critic 체크리스트 사용)
[ ] 레이어 의존 방향 올바른가?
[ ] Entity가 Controller에 노출되지 않는 구조인가?
[ ] Aggregate 경계가 Contract와 분리되었는가?
[ ] 도메인 이벤트가 올바르게 정의되었는가?
[ ] 테스트가 실제로 의미 있는 케이스를 커버하는가?
[ ] 불필요한 코드가 추가되지 않았는가?

## 판정
APPROVE / CONDITIONAL REJECT / REJECT 중 하나로 판정하고
구체적 근거를 제시해줘.
CONDITIONAL REJECT의 경우 수정 방법을 명확히 제시해줘.
```
