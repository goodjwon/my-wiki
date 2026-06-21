---
description: 위키 사이트 빌드 + Git push + Firebase 배포 일괄 실행
argument-hint: <커밋 메시지> (생략 시 git diff 보고 자동 제안)
---

# /deploy — 빌드·푸시·Firebase 배포 워크플로

대상 커밋 메시지: `$ARGUMENTS`

위키 변경사항을 한 번에 (1) MkDocs 빌드 검증 → (2) Git 커밋·푸시 → (3) Firebase Hosting 배포까지 일괄 처리한다.

## 사전 점검

1. **git status 확인** — 변경된 파일이 있는지.
   - 변경 없으면 "배포할 변경 없음" 보고 후 종료.
   - `.obsidian/` 안의 변경은 자동 제외 (graph.json·snippets/).
   - `무제.md` 같이 이번 작업과 무관한 파일도 사용자에게 확인 후 제외.

2. **커밋 대상 파일 추출**
   - `wiki/*.md`, `raw/`, `mkdocs.yml`, `scripts/`, 기타 명시적 변경.

## 절차

### 1. 빌드 검증 (필수)

```bash
bash scripts/build-site.sh
```

- **WARNING 0건** 인지 확인. 워닝 있으면 사용자에게 보고 후 진행 여부 확인.
- 빌드 실패 시 즉시 중단 + 오류 보고. 절대 깨진 상태로 배포하지 않음.

### 2. Git 커밋·푸시

`$ARGUMENTS` 가 비어있으면:
- `git diff --stat` 으로 변경 요약 + 직전 `wiki/log.md` 갱신 내용 분석.
- **CLAUDE.md "대화 규칙"** 의 한국어 + 영어 prefix (feat·docs·fix·refactor) 형식 따름.
- 사용자에게 제안한 메시지를 보여주고 확인받기. (사용자가 즉시 다른 메시지 줄 수 있음)

`$ARGUMENTS` 가 있으면:
- 그대로 사용. 단, prefix (`feat:`·`docs:` 등) 누락 시 자동 추가.

```bash
git add <대상 파일들>   # 명시적 — git add -A 절대 금지
git commit -m "<메시지>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

- **CLAUDE.md "git 안전 규칙"** 준수: amend 금지·force push 금지·`.obsidian/` 자동 제외·hooks 우회 금지.

### 3. Firebase Hosting 배포

```bash
bash scripts/deploy.sh
```

- 내부적으로 `build-site.sh` 재실행 + `firebase deploy --only hosting` 실행.
- 업로드 파일 수·URL 보고.

## 보고 형식

배포 완료 후 한 표로:

| | 결과 |
|---|------|
| 빌드 | ✅ 워닝 0건 |
| Git push | `<old>..<new> main -> main` (N files, +X/-Y) |
| Firebase | `wons-wiki.web.app` — N개 파일 업로드 |

새 페이지가 추가됐다면 핵심 URL 1~3개 함께 표시:
- `https://wons-wiki.web.app/<new-page>/` — 한 줄 설명

## 안전 규칙

- **빌드 워닝이 있는 채로 배포 금지** — 사용자 명시적 승인 필요.
- **사용자가 워크플로 중간에 취소 가능** — 빌드만 하고 push 안 하기·push 만 하고 배포 안 하기 등.
- **`.obsidian/snippets/`·`graph.json` 자동 제외** — Obsidian 자동 갱신 잡음.
- **메모리 정책 [[feedback-preferences]]** 의 push 확인 규칙 준수 — 큰 변경 시 사용자 확인 후 push.

## 사용 예

```
/deploy                            # 메시지 자동 제안
/deploy feat: Loop 엔지니어링 ingest  # 명시적 메시지
/deploy docs: lint 결과 반영          # docs prefix
```
