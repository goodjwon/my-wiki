---
title: API 계약 고정 후 서버 교체 — 손으로 고치는 OpenAPI와 생성 클라이언트
type: concept
tags: [openapi, api-contract, code-generation, server-migration, cloud-functions, flutter, react, app-store-review]
sources:
  - gather/TECH_NOTES.md
  - gather/TIMELINE.md
external:
  - https://spec.openapis.org/oas/v3.1.0
  - https://openapi-ts.dev/
  - https://openapi-generator.tech/docs/generators/dart/
created: 2026-11-19
updated: 2026-11-19
---

# API 계약 고정 후 서버 교체

## 정의

화면(앱·웹)과 서버 사이의 약속을 **계약 파일 하나**(OpenAPI)로 두고, 클라이언트 코드는 그 파일에서 생성합니다. 이렇게 하면 서버 언어·런타임을 통째로 바꿔도 계약과 저장 문서 모양만 같으면 클라이언트의 통신 코드는 한 줄도 바뀌지 않습니다.

> 서버를 바꿀 때 지켜야 할 것은 서버 코드가 아니라 **계약 파일과 저장 문서의 모양**입니다.

이 페이지는 [[src-gather]](언제볼래)에서 MVP 4일 뒤(2026-11-11) Spring Boot 서버를 TypeScript Cloud Functions로 옮긴 기록에서 뽑은 패턴입니다.

## 언제볼래에서 일어난 일

| 날짜 | 계약의 출처 | 사건 | 근거 |
|------|-------------|------|------|
| 11-07 | 서버(Java)가 스펙을 내보냄 | MVP: OpenAPI → TS·Dart 클라이언트 생성(`clients/generate.sh`) | `1529649` |
| 11-09 | 서버 테스트가 스펙을 내보냄 | 저장소 목으로 스펙 내보내기 테스트를 따로 떼어 로컬에서도 돌게 | `4b2a97c` |
| 11-11 | **손으로 고치는 `clients/openapi.json`** | 서버를 TypeScript Cloud Functions로 이전. 커밋 변경 파일에 `apps/web`·`apps/app`이 없음 | `ed81fea` |
| 11-12~13 | 손으로 고치는 계약 | 기능 5건이 각각 계약 + 생성물(TS·Dart) + 서버 + 화면을 한 커밋에 함께 바꿈 | `870cf8c` `6cdebfa` `c10f214` `6eea53a` `c3d2aa6` |

이전 동기는 콜드 스타트였습니다. Cloud Run의 JVM은 0대에서 깨어날 때 첫 요청이 7~11초 걸려 "응답 화면 2초" 목표를 넘겼습니다. 서버를 바꾼 뒤에도 앱과 웹의 통신 코드는 그대로였고, 커밋 메시지에는 "저장 문서·응답 JSON이 Java와 같다(에뮬레이터에서 같은 흐름을 돌려 비교)"고 남아 있습니다.

## 구조

| 층 | 파일 | 누가 고치나 |
|----|------|-------------|
| 계약 | `clients/openapi.json`(OpenAPI 3.1, 경로 17개) | 사람(서버 변경과 같은 커밋) |
| TS 생성물 | `clients/ts/schema.d.ts`(openapi-typescript) | 생성기만 |
| Dart 생성물 | `clients/dart`(openapi-generator, 패키지 `gather_api`) | 생성기 + 버그 패치 스크립트 |
| 서버 | `functions/src/app.ts`(HTTP), `domain.ts`(규칙) | 사람 |
| 웹 | `openapi-fetch`에 생성 타입 `paths`를 넣어 호출 | 사람 |
| 앱 | `pubspec.yaml`에서 `gather_api`를 path 의존성으로 | 사람 |

웹 쪽 연결은 타입만 가져다 씁니다. 계약에 없는 경로나 필드를 쓰면 컴파일이 먼저 막습니다:

```ts
import createClient from 'openapi-fetch'
import type { components, paths } from '../../../clients/ts/schema'
export const api = createClient<paths>({ baseUrl: '' })
```

### 계약 출처를 서버에서 파일로 옮긴 이유

| 방식 | 장점 | 서버 교체 때 |
|------|------|--------------|
| 서버 코드에서 스펙 생성(code-first) | 스펙과 구현이 항상 일치 | 새 서버가 같은 스펙을 내보내도록 애너테이션·스키마를 다시 맞춰야 함 |
| 손으로 고치는 계약 파일(contract-first) | 언어와 무관한 정본이 하나 | 새 서버가 파일에 맞추기만 하면 됨 |

언제볼래는 서버 언어를 바꾸는 시점에 정본을 서버에서 파일로 옮겼습니다. 서버가 하나뿐이고 사람이 계약과 서버를 같은 커밋에 고치는 규모라 가능한 선택입니다.

## 계약을 바꾸는 규칙 — 심사 중인 앱이 있을 때

스토어에 제출한 앱 빌드는 바로 고칠 수 없습니다. 그래서 저장소의 이어받기 문서(NEXT.md)는 "심사 중에는 제출한 빌드를 바꾸지 않는다. 서버·웹은 따로 배포되지만 API 모양은 바꾸지 않는다(필드 추가는 괜찮다)"고 정했습니다.

실제 사례(`6eea53a`, 11-13, App Store 1.0.0(6) 제출 이후): 약속 분류를 여러 개 고르게 하면서 단수 필드 `type`을 지우지 않고 배열 `types`를 **추가**했습니다. `type`은 대표 분류로 계속 채워 옛 앱이 그대로 읽습니다:

```json
"type":  { "$ref": "#/components/schemas/GatheringType" },
"types": { "type": "array", "items": { "$ref": "#/components/schemas/GatheringType" },
           "description": "분류 여러 개(최대 3, 첫째가 대표). 있으면 type 대신 쓴다" }
```

| 변경 | 심사 중 허용 | 이유 |
|------|--------------|------|
| 응답에 필드 추가 | 예 | 옛 클라이언트는 모르는 필드를 무시해야 함 → [[concept-api-backward-compatibility]] |
| 요청에 선택 필드 추가 | 예 | 옛 앱은 안 보내고, 서버는 없을 때 기존 동작 |
| 필드 이름 변경·삭제 | 아니오 | 옛 빌드 파싱 실패 |
| 필드 의미 변경(단수 → 복수) | 아니오 | 새 필드를 추가하고 옛 필드는 대표값으로 유지 |

## 함정

**1) 생성기 버그를 생성물에서 직접 고치면 다음 생성 때 사라진다**

openapi-generator의 Dart 생성기(7.x)는 날짜 목록과 enum 값 맵 역직렬화를 잘못 만듭니다. 언제볼래는 생성물을 손으로 고치지 않고, `generate.sh` 안에서 생성 직후 perl 치환으로 고칩니다. 생성 → 패치가 한 스크립트라 다시 생성해도 수정이 유지됩니다:

```sh
npx -y @openapitools/openapi-generator-cli generate -i clients/openapi.json -g dart -o clients/dart ...
# openapi-generator dart의 버그 두 가지를 고친다(생성기 7.x): 날짜 목록과 enum 값 맵
perl -pi -e "s/DateTime\.listFromJson\(.../.../g; ..." clients/dart/lib/model/*.dart
```

**2) 계약만 같고 저장 문서가 다르면 교체가 아니다**

옛 서버가 쓴 Firestore 문서를 새 서버가 읽어야 합니다. 언제볼래는 API 응답만이 아니라 저장 문서 모양도 Java와 같게 맞추고, 에뮬레이터에서 같은 흐름을 돌려 비교했습니다.

**3) 손으로 고치는 계약은 서버와 어긋날 수 있다**

code-first의 장점(자동 일치)을 버린 대가입니다. 언제볼래의 대응은 계약·생성물·서버·화면을 한 커밋에 묶는 관행과, Firestore 에뮬레이터 위의 API 흐름 테스트입니다. 계약과 서버 응답을 자동 대조하는 검사는 저장소에 없습니다(2026-11-19 기준).

## 같은 인사이트 패턴 — "제출한 것과 같은 것을 유지한다"

| 페이지 | 바뀌는 쪽 | 고정하는 쪽 | 장치 |
|--------|-----------|-------------|------|
| **API 계약 고정 후 서버 교체 (이 페이지)** | 서버 구현 전체 | 계약 파일 + 저장 문서 | 같은 흐름을 두 서버에 돌려 비교 |
| [[src-gather]] | 서버 런타임, 기능 | 심사 중 빌드가 쓰는 API 모양 | 필드 추가만 허용 |
| [[concept-api-backward-compatibility]] | 서버 응답 | 클라이언트 파서 | Tolerant Reader 계약 |
| [[concept-thin-client-idempotent-sync]] | 폰의 기록 | 워치가 받는 메시지 형식 | 멱등 ID + 스냅샷 |

## 빠른 진단

- [ ] 클라이언트가 쓰는 타입이 계약 파일에서 생성됩니까(손으로 쓴 DTO가 없습니까)?
- [ ] 생성기 버그 패치가 생성 스크립트 안에 있습니까?
- [ ] 서버를 바꿀 때 API 응답과 함께 저장 문서 모양도 비교했습니까?
- [ ] 심사 중인 빌드가 있을 때 필드 삭제·이름 변경을 막는 규칙이 문서에 있습니까?

```sh
# 서버 교체 커밋이 클라이언트를 건드렸는지 확인
git show --stat --format= <커밋> | grep -E 'apps/(web|app)/' || echo "클라이언트 무변경"
```

## 원본 출처

- raw: `raw/gather/TECH_NOTES.md` 5절, `raw/gather/TIMELINE.md`
- 공식: [OpenAPI 3.1.0 명세](https://spec.openapis.org/oas/v3.1.0), [openapi-typescript](https://openapi-ts.dev/), [openapi-generator Dart](https://openapi-generator.tech/docs/generators/dart/)

## 관련 페이지

- [[src-gather]] — 이 패턴이 나온 앱
- [[concept-api-backward-compatibility]] — 필드 추가가 안전하려면 클라이언트가 지켜야 할 계약
- [[concept-api-versioning]] — 모양을 바꿔야 할 때의 대안(버전 분리)과 그 유지 부담
- [[concept-thin-client-idempotent-sync]] — 클라이언트를 얇게 두는 다른 사례

## 이 개념을 다룬 글

블로그 [트렌드나침반](https://blog.wonslab.dev/)에서 이 주제를 다룬 글입니다.

- [언제볼래 — 단톡방 약속을 링크 하나로 정하는 앱을 만든 이유와 과정](https://blog.wonslab.dev/2026-11-19-gather-intro/)
