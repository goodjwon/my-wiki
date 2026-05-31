# 실습 2-1: CLAUDE.md 초안 작성 프롬프트

## 목적
제공된 CLAUDE.md 템플릿을 내 프로젝트에 맞게 커스터마이징합니다.

---

## Claude Code에 붙여넣을 프롬프트

```
현재 프로젝트의 구조를 파악해서 CLAUDE.md를 커스터마이징해줘.

## 파악할 내용
다음을 실행하고 결과를 바탕으로 분석해줘:

1. 프로젝트 구조 파악
   - find src -name "*.java" -path "*/domain/*" | head -20
   - find src -name "*.java" -path "*/application/*" | head -20
   - cat build.gradle | grep "implementation\|testImplementation"

2. 현재 컨벤션 파악
   - 가장 최근 Entity 파일 3개 읽기
   - 가장 최근 Service 파일 2개 읽기
   - 가장 최근 Controller 파일 2개 읽기

## 커스터마이징 요청

분석 결과를 바탕으로 CLAUDE.md 템플릿에서 다음을 수정해줘:

1. **섹션 1 (Tech Stack)**: 실제 사용 라이브러리 버전 반영
2. **섹션 7 (절대 금지)**: 실제 프로젝트에서 발견된 위험한 패턴 추가
3. **섹션 10 (네이밍)**: 현재 코드에서 실제 쓰는 패턴으로 교체
4. **섹션 9 (빌드 명령)**: 실제 사용하는 명령어로 교체

## 출력 형식
수정된 CLAUDE.md 전체를 마크다운으로 출력해줘.
500줄 이하로 유지하고, 불필요한 섹션은 제거해도 돼.
```

---

## 실습 완료 기준

- [ ] 프로젝트 루트에 `CLAUDE.md` 파일 생성
- [ ] 500줄 이하 유지
- [ ] 섹션 7(절대 금지)에 프로젝트 특화 규칙 3개 이상 포함
- [ ] 빌드 명령어가 실제 작동하는지 확인
- [ ] git commit: `docs: add CLAUDE.md agent harness constitution`
