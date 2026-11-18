<!--
원본: 2026-11-19 Claude Code 세션에서 /ship 스킬을 만들며 정리한 메모 (작성: Claude, 사용자 검토 전).
코드 정본: wonslab-hub 저장소(비공개) release/ship/ — SKILL.md · store.mjs · keys.sh
API 문서: https://developers.google.com/android-publisher · https://developer.apple.com/documentation/appstoreconnectapi
공개 위키용 원본이라 계정 메일·키 ID·서비스 계정 주소는 일부러 넣지 않았다.
검증 상태: 세 앱 상태 조회와 promote·submit·share dry-run만 확인. 실제 프로덕션 승격·심사 제출은 미검증.
-->

# 앱 배포 자동화 — 키 관리부터 프로덕션까지

앱이 늘어나면 매번 하는 배포 작업이 부담이 됩니다. 빌드 번호 맞추기, AAB와 IPA 빌드, 콘솔에 업로드, 출시 노트 쓰기, 프로덕션 승격을 앱마다 Android와 iOS로 두 번씩 해야 합니다. 이 문서는 그 반복을 Claude Code 스킬 `/ship` 하나로 줄인 방식을 정리합니다. 스토어 첫 등록은 사람이 하고, 그 뒤 업데이트는 스킬이 합니다. 단, 프로덕션은 **사람이 승인한 뒤에만** 나갑니다.

!!! example "적용 범위"

    - **대상**: Flutter 앱 3개 (언제볼래·모닝브리핑·운동기록). 같은 개발자 계정의 앱이면 한 줄씩 추가해 늘린다
    - **환경**: Mac 2대 (한 사람이 사용), fvm, Xcode, Node 20+
    - **스토어 API**: Google Play Android Publisher API v3, App Store Connect API
    - **검증**: 2026-11-19 세 앱의 상태 조회와 승격·제출·공유 dry-run 확인. 실제 프로덕션 승격·심사 제출은 첫 실행 때 검증 예정

## 0. 한눈에 보기

| 명령 | 하는 일 | 빌드 | 승인 질문 |
|---|---|---|---|
| `/ship test [버전]` | Android·iOS 빌드 → Play 비공개 테스트 트랙 + TestFlight 업로드 → 테스터 공유 | 함 | 없음 |
| `/ship prod` | 테스트에 올라간 최신 빌드 → Play 프로덕션 승격 + App Store 심사 제출(승인되면 자동 출시) | **안 함** | **있음** |

- 앱 폴더에서 실행한다. 앱은 현재 폴더로 정해진다
- 기본은 두 플랫폼 모두다. 끝에 `android`나 `ios`를 붙이면 하나만 한다
- **prod는 새로 빌드하지 않는다.** 테스터가 확인한 바이너리가 그대로 나간다. 코드를 고쳤으면 test부터 다시 한다

### 파일 구성

```text
~/VsCodeProjects/wonslab-hub/release/ship/   ← 스킬 코드 (git, 비공개 저장소)
├── SKILL.md      ← Claude가 따르는 절차서 (명령·앱 표·실패 대응)
├── store.mjs     ← 스토어 API 호출 (의존성 없음)
└── keys.sh       ← 키 점검·암호화 이동
~/.claude/skills/ship → 위 폴더로 링크 (PC마다 한 번)
~/keystores/      ← 키 (git에 절대 넣지 않음)
```

역할은 둘로 나뉩니다. **SKILL.md는 순서와 판단**을 맡습니다. 어느 앱인지, 빌드 번호를 몇으로 할지, 출시 노트를 어떻게 쓸지, 언제 멈추고 물을지를 정합니다. **store.mjs는 API 호출**만 합니다. 빌드와 테스트 트랙 업로드는 새로 만들지 않고 앱마다 이미 있던 스크립트를 그대로 씁니다.

## 1. 키 관리 — PC 두 대가 같은 키를 쓴다

한 사람이 쓰는 PC 두 대라 PC마다 키를 따로 만들 이유가 없습니다. 키 묶음 하나를 두 PC에 똑같이 둡니다.

### 1-1. 필요한 키

| 키 | 용도 | 위치 | 잃어버리면 |
|---|---|---|---|
| Android 업로드 키 `<앱>-upload.jks` | AAB 서명 | `~/keystores/` | Play 콘솔에서 업로드 키 재설정 (앱 서명 키는 Google이 보관) |
| `key.properties` | 위 키의 비밀번호·경로 | 앱 `android/` (git 제외) | 비밀번호 관리자 백업으로 다시 작성 |
| Play 서비스 계정 JSON | Play API 인증 (모든 앱 공용) | `~/keystores/` | Google Cloud에서 키 재발급 |
| App Store Connect API 키 `.p8` + 설정 JSON | ASC API·업로드 인증 (모든 앱 공용) | `~/keystores/` | **재다운로드 불가.** ASC에서 새로 발급 |
| 앱별 env 파일 | 빌드 때 주입할 값 | 앱 `env/` 등 | 원본 콘솔에서 다시 복사 |

!!! warning "키는 하나로 모든 앱에 쓴다"
    Play 서비스 계정과 ASC API 키는 앱마다 만들지 않습니다. 개발자 계정 단위로 하나를 만들고, Play 콘솔에서 앱마다 그 계정에 권한만 줍니다. 앱이 5개로 늘어도 키 관리는 그대로입니다.

### 1-2. 옮기는 법

```sh
# 키가 있는 PC — 묶어서 암호화해 iCloud Drive에 올림 (비밀번호는 비밀번호 관리자에 저장)
~/.claude/skills/ship/keys.sh pack

# 다른 PC — 풀어서 같은 자리에 두고 점검까지
~/.claude/skills/ship/keys.sh unpack

# 언제든 — 이 PC에 키가 다 있는지
~/.claude/skills/ship/keys.sh check
```

`check`의 예상 결과는 `✓`가 붙은 목록입니다. `✗`가 하나라도 있으면 `/ship`이 시작 단계에서 멈추고 `unpack`하라고 안내합니다.

| 결정 | 이유 |
|---|---|
| iCloud Drive + `openssl enc -aes-256-cbc -pbkdf2` | 추가 설치 없이 macOS 기본 도구만으로 된다. 파일이 암호화돼 있어 클라우드 사업자를 믿지 않아도 된다 |
| 키는 git에 넣지 않음 | 비공개 저장소여도 히스토리에 남으면 지울 수 없다 |
| 스킬 코드는 git, 키는 iCloud | 코드는 변경 이력이 필요하고, 키는 바뀌는 일이 드물다 |
| 두 PC의 사용자 이름을 같게 | `key.properties`의 키 경로가 절대경로라서 |

### 1-3. 새 PC 셋업 (한 번)

```sh
cd ~/VsCodeProjects && git clone <wonslab-hub 저장소>   # 이미 있으면 git pull
ln -s ~/VsCodeProjects/wonslab-hub/release/ship ~/.claude/skills/ship
~/.claude/skills/ship/keys.sh unpack
```

## 2. 스토어 쪽 첫 설정 (사람이, 앱마다 한 번)

| 콘솔 | 할 일 |
|---|---|
| Play 콘솔 → 사용자 및 권한 | 서비스 계정을 초대하고 앱 권한에 **테스트 트랙에 앱 출시**와 **프로덕션에 앱 출시**를 준다. 반영까지 몇 분에서 하루 |
| App Store Connect → 사용자 및 액세스 → 통합 | API 키 역할이 **App Manager 이상**인지 확인한다. Developer 역할은 업로드만 되고 심사 제출이 안 된다 |
| TestFlight | 외부 테스터에게 공유하려면 외부 그룹을 한 번 만든다. 없으면 내부 테스터만 자동으로 받는다 |
| 첫 출시 | 앱 등록, 스크린샷, 설명, 개인정보 설문 같은 첫 출시는 사람이 콘솔에서 한다. 한 번도 공개되지 않은 앱은 Play API가 초안 출시만 받는다 |

## 3. /ship test — 빌드하고 테스터에게 공유

1. 키를 점검하고 앱의 런북(`docs/release/`)을 읽는다
2. 양 스토어의 최신 빌드 번호를 API로 조회해 **가장 큰 번호 + 1**로 pubspec을 올린다. 사람에게 묻던 단계를 조회가 대신한다
3. `flutter analyze`와 `flutter test`를 돌린다. 실패하면 멈춘다
4. 지난 업로드 이후 git log를 보고 테스트 노트를 쓴다
5. 앱의 기존 스크립트로 AAB와 IPA를 빌드하고 업로드한다
6. TestFlight 처리를 기다린다(`VALID`, 10~30분)
7. TestFlight 외부 그룹에 공유하고 베타 심사를 제출한다
8. 버전, 트랙, 테스트 노트를 보고한다

빌드 번호를 조회로 정하는 이유는 PC가 두 대이기 때문입니다. pubspec만 보면 다른 PC에서 올린 번호를 모릅니다. Play는 한 번 거부한 번호도 소비된 것으로 보기 때문에 번호가 겹치면 되돌릴 수 없습니다.

## 4. /ship prod — 승인받고 프로덕션으로

1. 내보낼 빌드를 정한다: Play 테스트 트랙의 최신 versionCode, ASC의 최신 `VALID` 빌드
2. 지난 **프로덕션** 이후 바뀐 내용으로 출시 노트를 쓴다 (한국어, Play 한도 500자)
3. 승격과 제출을 **dry-run**으로 돌린다. 스크립트는 `--go`가 없으면 할 일만 출력한다
4. **승인 질문**을 띄운다: 앱, 번호, dry-run 결과, 출시 노트 전문, 런북 게이트 중 남은 것. 선택지는 [둘 다 / Android만 / iOS만 / 중단]과 Play 단계 출시 비율 [20% / 100%]
5. 승인한 것만 `--go`로 실행한다
   - Play: 프로덕션 트랙에 해당 versionCode를 단계 출시 비율로 올린다
   - App Store: 버전을 만들거나 갱신하고, 빌드를 붙이고, "새로운 기능"을 넣고, 심사에 제출한다. 출시 방식은 **승인되면 자동 출시**
6. 단계 출시를 늘릴 때는 `/ship prod`를 다시 부른다. 같은 versionCode의 비율만 올리고, 이때도 승인을 받는다

!!! tip "승인 게이트가 두 겹인 이유"
    스크립트는 기본이 dry-run이고, 스킬은 승인 질문에 답이 있어야만 `--go`를 붙입니다. 실수로 스크립트를 직접 실행해도 아무것도 바뀌지 않고, Claude가 절차를 건너뛰어도 스크립트가 막습니다.

## 5. 같은 패턴 — "검증한 것을 그대로 낸다"

| 영역 | 함정 | 해결 | 관련 페이지 |
|---|---|---|---|
| 앱 배포 (이 문서) | 프로덕션 직전에 다시 빌드하면 테스트하지 않은 바이너리가 나간다 | prod는 빌드하지 않고 테스트 트랙의 빌드를 승격 | — |
| API 호환성 | 심사 중이거나 배포된 앱이 쓰는 API 모양을 서버에서 바꾼다 | 필드 추가·검사 완화만 하고 모양은 유지 | [[concept-api-backward-compatibility]] |
| 위키 배포 | 로컬 빌드와 배포 환경이 달라 새 PC에서 깨진다 | 동작 환경의 패키지 버전을 고정 | [[guide-deploy-mkdocs-firebase]] |

## 6. 실패할 때

| 증상 | 원인 · 대응 |
|---|---|
| Play 403 | 서비스 계정에 그 앱 권한이 없다 → 2장 |
| Play "draft"만 된다 | 앱이 한 번도 공개되지 않았다 → 첫 출시는 콘솔에서 [출시 검토] |
| 관리형 게시가 켜진 앱 | 제출은 됐다. 콘솔 [게시 개요 → 변경사항 게시]를 사람이 누른다 |
| ASC "수출 규정" 미답 | Info.plist에 `ITSAppUsesNonExemptEncryption` = false (HTTPS만 쓰는 앱) → test부터 다시 |
| ASC 403 | API 키 역할이 App Manager 미만 → 2장 |
| 심사 제출이 메타데이터 누락으로 거부 | 스크린샷이나 설명이 빠졌다 → 콘솔에서 채운다 |
| `keys.sh check`에 ✗ | 이 PC에 키가 없다 → 1-2 `unpack` |

## 7. 빠른 점검

- [ ] `keys.sh check`가 모두 ✓
- [ ] 앱이 SKILL.md의 앱 표에 있다 (새 앱은 한 줄 추가)
- [ ] Play 서비스 계정에 그 앱의 테스트·프로덕션 출시 권한이 있다
- [ ] ASC API 키 역할이 App Manager 이상이다
- [ ] 앱 런북의 출시 게이트(실기기 확인 등)를 승인 질문에서 확인했다

## 관련 페이지

- [[src-workout-history-launch]] — 운동기록 첫 출시 회고 (이 자동화 이전의 수동 제출 과정)
- [[src-morningbrief]] — 모닝브리핑 개발기
- [[concept-claude-md]] — Claude Code 규칙 파일. 스킬은 규칙이 아니라 필요할 때 불러 쓰는 절차서다
- [[concept-harness-engineering]] — 에이전트가 실수해도 막히게 만드는 장치 (dry-run 기본값과 승인 게이트)
- [[guide-deploy-mkdocs-firebase]] — 위키 배포 가이드

## 부록. 다음 작업 후보 — 스토어 등록 정보 갱신 (미구현)

첫 등록은 사람이 한다. 그 뒤 설명·스크린샷 갱신은 두 스토어 모두 API로 할 수 있다.

| 항목 | Google Play (edits API) | App Store Connect API |
|---|---|---|
| 앱 이름·짧은 설명·자세한 설명 | `edits/{id}/listings/ko-KR` PUT (title·shortDescription·fullDescription) | 이름·부제: `appInfoLocalizations` / 설명·키워드·프로모션 문구: `appStoreVersionLocalizations` |
| 스크린샷 | `edits/{id}/listings/ko-KR/phoneScreenshots` deleteall → 업로드 | `appScreenshotSets` → `appScreenshots` 예약 → 업로드 → 체크섬 확정 |
| 그래픽 이미지 1024×500 | `featureGraphic` 업로드 | 해당 없음 |
| 반영 시점 | edit commit 즉시 (설명만 바꾸면 검토 짧음) | 다음 버전 심사 때 같이. 프로모션 문구만 심사 없이 바로 |

- 이미지 원본은 앱마다 이미 있는 스크린샷 자동 촬영(integration_test)을 쓴다
- 아이디어: `/ship listing` — 문구 초안과 스크린샷을 만들고, 승인 뒤 양 스토어에 반영
