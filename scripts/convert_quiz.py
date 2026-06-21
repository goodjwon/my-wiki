#!/usr/bin/env python3
"""
<details><summary>Q. ...</summary> ... </details> 토글 퀴즈를
**Q. ...** + **A.** ... 형식으로 변환.
어떤 마크다운 뷰어에서도 깨끗하게 렌더링되고 raw로 봐도 명확.
"""
import re
import sys
from pathlib import Path


def html_to_md_inline(s: str) -> str:
    # <code>X</code> → `X`
    s = re.sub(r'<code>(.+?)</code>', r'`\1`', s)
    # 흔한 HTML 엔티티 디코드
    s = s.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&')
    s = s.replace('&quot;', '"').replace('&#39;', "'").replace('&nbsp;', ' ')
    return s


def convert(text: str) -> str:
    # 1) </details> <details> 가 같은 줄에 연속된 경우 → 줄 분리
    text = re.sub(r'</details>\s*<details>', '</details>\n\n<details>', text)

    # 2) <details><summary>Q</summary>\n\nA\n\n</details> 패턴 → **Q** + **A.** A
    pattern = re.compile(
        r'<details><summary>(?P<q>.+?)</summary>\s*\n+(?P<a>.*?)\n*</details>',
        re.DOTALL,
    )

    def replace(m: re.Match) -> str:
        q = html_to_md_inline(m.group('q').strip())
        a = m.group('a').strip()
        return f'**{q}**\n\n**A.** {a}'

    text = pattern.sub(replace, text)

    # 3) 변환 후 빈 줄 3개 이상 → 2개로 정리
    text = re.sub(r'\n{3,}', '\n\n', text)

    return text


def main():
    if len(sys.argv) < 2:
        print('usage: convert_quiz.py <file> [<file> ...]', file=sys.stderr)
        sys.exit(1)

    changed = 0
    for arg in sys.argv[1:]:
        p = Path(arg)
        if not p.exists():
            print(f'skip (not found): {p}')
            continue
        original = p.read_text(encoding='utf-8')
        converted = convert(original)
        if original != converted:
            p.write_text(converted, encoding='utf-8')
            print(f'converted: {p}')
            changed += 1
        else:
            print(f'unchanged: {p}')
    print(f'\ntotal changed: {changed}')


if __name__ == '__main__':
    main()
