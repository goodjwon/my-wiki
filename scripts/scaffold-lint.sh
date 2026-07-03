#!/usr/bin/env bash
# §7-7 실습 스캐폴드 표준(guide-wiki-authoring-standards.md)의 기계 검출 가능한 위반을 검사한다.
# 토큰 0 무료 게이트 — 위반이 있으면 exit 1 + 목록 출력, 없으면 exit 0.
#
# 검사 항목:
#   ① 파일 리드인(**파일**: path / **파일명 N: X.java** / 파일명: `X.java`) ↔ 바로 다음
#      java 펜스의 package 선언·public 클래스명 정합
#   ② 리드인이 붙은 java 펜스 안에 public 최상위 타입이 2개 이상이면 위반
#   ③ 어디서든 `public class Main` 이면 위반 (드라이버 Main 금지 — 퀴즈는 non-public 허용)
#   ④ java 파일 리드인이 있는 h2 절(## N.M)에는 실행 명령 bash 블록과 `예상 결과` 펜스가
#      최소 1개씩 있어야 함 (절 대표 1회 방식 허용 — 예제마다 요구하지 않음)
#
# 사용법: bash scripts/scaffold-lint.sh <wiki/파일.md> [...]
set -uo pipefail

if [ "$#" -eq 0 ]; then
  echo "사용법: bash scripts/scaffold-lint.sh <wiki/파일.md> [...]" >&2
  exit 2
fi

python3 - "$@" <<'PYEOF'
import re, sys, os

LEADIN_PATTERNS = [
    re.compile(r'^\*\*파일\*\*\s*:\s*`?([^`*]+?)`?\s*$'),          # **파일**: path
    re.compile(r'^\*\*파일명[^:]*:\s*`?([^`*]+?\.java)`?\*\*\s*$'),  # **파일명 3: Main.java**
    re.compile(r'^파일명\s*:\s*`?([^`*]+?\.java)`?\s*$'),            # 파일명: `X.java`
]
PKG_RE = re.compile(r'^\s*package\s+([\w.]+)\s*;')
TYPE_RE = re.compile(r'^(public\s+)?(?:final\s+|abstract\s+|sealed\s+|non-sealed\s+|static\s+)*(class|interface|enum|record)\s+(\w+)')
PUBLIC_MAIN_RE = re.compile(r'^public\s+(?:final\s+|abstract\s+)*class\s+Main\b')

total = 0

def parse_fence(lines, start):
    """start = 펜스 여는 줄 인덱스. (내용 줄 리스트, 끝 인덱스) 반환."""
    open_line = lines[start]
    ticks = len(open_line) - len(open_line.lstrip('`'))
    body = []
    i = start + 1
    while i < len(lines):
        stripped = lines[i].rstrip()
        if stripped.startswith('`' * max(ticks, 3)) and set(stripped) <= {'`'}:
            return body, i
        body.append(lines[i])
        i += 1
    return body, i

def expected_pkg_from_path(path):
    """경로에서 기대 package 도출. (기대pkg 또는 None, 검사가능 여부)"""
    for marker in ('src/main/java/', 'src/test/java/'):
        if marker in path:
            sub = path.split(marker, 1)[1]
            d = os.path.dirname(sub)
            return (d.replace('/', '.') if d else None), True
    if '/' not in path:
        return None, True   # 단일 파일 실습 — package 없어야 함
    return None, False      # 루트 불명 — package 검사 생략

for fname in sys.argv[1:]:
    print(f"── {fname} ──")
    if not os.path.isfile(fname):
        print("  ❌ 파일 없음"); total += 1; continue
    lines = open(fname, encoding='utf-8').read().splitlines()
    violations = 0

    # ①② 리드인 검사
    i = 0
    while i < len(lines):
        m = None
        for pat in LEADIN_PATTERNS:
            m = pat.match(lines[i].strip())
            if m: break
        if not m:
            i += 1; continue
        path = m.group(1).strip()
        # 다음 5줄 안의 java 펜스 찾기
        fence_at = None
        for j in range(i + 1, min(i + 6, len(lines))):
            s = lines[j].strip()
            if s.startswith('```'):
                if 'java' in s:
                    fence_at = j
                break
        if fence_at is None or not path.endswith('.java'):
            i += 1; continue
        body, end = parse_fence(lines, fence_at)

        pkg = None
        types = []       # (public여부, 이름)
        for bl in body:
            pm = PKG_RE.match(bl)
            if pm: pkg = pm.group(1)
            tm = TYPE_RE.match(bl)   # 최상위 = 들여쓰기 없음
            if tm: types.append((bool(tm.group(1)), tm.group(3)))

        fname_expected = os.path.basename(path)
        publics = [t for t in types if t[0]]
        primary = publics[0][1] if publics else (types[0][1] if types else None)

        if primary and primary + '.java' != fname_expected:
            print(f"  [리드인↔클래스명 불일치] L{i+1} 파일 '{fname_expected}' ↔ 코드 클래스 '{primary}'")
            violations += 1
        exp_pkg, checkable = expected_pkg_from_path(path)
        if checkable:
            if exp_pkg and pkg != exp_pkg:
                print(f"  [리드인↔package 불일치] L{i+1} 경로 기대 '{exp_pkg}' ↔ 선언 '{pkg}'")
                violations += 1
            if exp_pkg is None and pkg is not None:
                print(f"  [단일 파일인데 package 선언] L{i+1} 경로 '{path}' ↔ 선언 '{pkg}'")
                violations += 1
        if len(publics) > 1:
            names = ', '.join(t[1] for t in publics)
            print(f"  [한 블록에 public 타입 {len(publics)}개] L{fence_at+1} ({names}) — 블록 분리 필요")
            violations += 1
        i = end + 1

    # ④ h2 절 단위 — java 리드인 있는 절에 실행 명령 bash + 예상 결과 존재 검사
    RUN_CMD_RE = re.compile(r'(^|\s)(mvn|\./mvnw|mvnw\.cmd|\./gradlew|gradlew\.bat|gradle|javac|java)(\s|$)')
    sections = []   # (제목, 시작, 끝)
    starts = [(idx, l) for idx, l in enumerate(lines) if l.startswith('## ')]
    for si, (idx, title) in enumerate(starts):
        end_idx = starts[si + 1][0] if si + 1 < len(starts) else len(lines)
        sections.append((title.strip('# ').strip(), idx, end_idx))
    for title, s, e in sections:
        has_java_leadin = False
        has_run = False
        has_expected = False
        j = s
        while j < e:
            st = lines[j].strip()
            for pat in LEADIN_PATTERNS:
                lm = pat.match(st)
                if lm and lm.group(1).strip().endswith('.java'):
                    has_java_leadin = True
            if st.startswith('```bash'):
                b, endb = parse_fence(lines, j)
                if any(RUN_CMD_RE.search(x) for x in b):
                    has_run = True
                j = endb
            elif st.startswith('```text'):
                b, endb = parse_fence(lines, j)
                if b and b[0].strip() == '예상 결과':
                    has_expected = True
                j = endb
            j += 1
        if has_java_leadin and not has_run:
            print(f"  [절에 실행 명령 없음] '{title}' — java 실습 예제가 있는데 실행 bash 블록이 없음")
            violations += 1
        if has_java_leadin and not has_expected:
            print(f"  [절에 예상 결과 없음] '{title}' — java 실습 예제가 있는데 예상 결과 펜스가 없음")
            violations += 1

    # ③ public class Main 전역 검사 (java 펜스 안)
    i = 0
    in_java = False
    ticks = 0
    while i < len(lines):
        s = lines[i].strip()
        if not in_java and s.startswith('```') and 'java' in s:
            in_java = True; ticks = len(s) - len(s.lstrip('`'))
        elif in_java and s.startswith('`' * max(ticks, 3)) and set(s) <= {'`'}:
            in_java = False
        elif in_java and PUBLIC_MAIN_RE.match(lines[i]):
            print(f"  [public class Main 금지] L{i+1} — <주제>Demo 로 개명 (퀴즈면 non-public class Main)")
            violations += 1
        i += 1

    if violations == 0:
        print("  ✅ 위반 없음")
    total += violations

print("────────────────")
if total == 0:
    print("✅ scaffold-lint 통과 (위반 0건)")
    sys.exit(0)
else:
    print(f"❌ scaffold-lint 실패 — 위반 {total}건")
    sys.exit(1)
PYEOF
