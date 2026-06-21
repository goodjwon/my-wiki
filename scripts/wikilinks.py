#!/usr/bin/env python3
r"""Convert Obsidian [[wikilink]] to standard markdown links.

- 코드블록 (```...```) 과 인라인 코드 (`...`) 안의 [[...]] 는 보호
- [[name]]       → [name](name.md)
- [[name|alias]] → [alias](name.md)
- ![[image.png]] → ![image.png](image.png) (이미지 임베드)
- 백슬래시 이스케이프 \[\[name\]\] 는 변환하지 않고 \[ \] 만 풀어줌

Usage: python3 scripts/wikilinks.py <docs_dir>
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

CODE_BLOCK = re.compile(r"```[\s\S]*?```")
INLINE_CODE = re.compile(r"`[^`\n]*`")
WIKILINK = re.compile(r"!?\[\[([^\[\]\n]+?)\]\]")
ESCAPED = re.compile(r"\\\[\\\[([^\n]+?)\\\]\\\]")


def _convert(match: re.Match[str]) -> str:
    raw = match.group(0)
    inner = match.group(1)
    is_embed = raw.startswith("!")
    if "|" in inner:
        target, _, alias = inner.partition("|")
    else:
        target, alias = inner, inner
    target = target.strip()
    alias = alias.strip()
    if is_embed:
        return f"![{alias}]({target})"
    # 이미 .md 확장자가 있거나 URL인 경우 그대로
    if target.startswith(("http://", "https://", "/")) or target.endswith(".md"):
        return f"[{alias}]({target})"
    return f"[{alias}]({target}.md)"


def _unescape(match: re.Match[str]) -> str:
    return f"[[{match.group(1)}]]"


def convert(text: str) -> str:
    placeholders: list[str] = []

    def stash(m: re.Match[str]) -> str:
        placeholders.append(m.group(0))
        return f"\x00WIKI_STASH_{len(placeholders) - 1}\x00"

    text = CODE_BLOCK.sub(stash, text)
    text = INLINE_CODE.sub(stash, text)
    text = WIKILINK.sub(_convert, text)
    text = ESCAPED.sub(_unescape, text)

    def restore(m: re.Match[str]) -> str:
        return placeholders[int(m.group(1))]

    text = re.sub(r"\x00WIKI_STASH_(\d+)\x00", restore, text)
    return text


def main(docs_dir: str) -> None:
    root = Path(docs_dir)
    converted = 0
    for md_file in root.rglob("*.md"):
        original = md_file.read_text(encoding="utf-8")
        new = convert(original)
        if new != original:
            md_file.write_text(new, encoding="utf-8")
            converted += 1
    print(f"  wikilinks 변환: {converted}개 파일")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 scripts/wikilinks.py <docs_dir>", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])
