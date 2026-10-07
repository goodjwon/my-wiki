"""MkDocs hook — 페이지별 검색 메타데이터.

- description: frontmatter에 없으면 H1 뒤 첫 문단에서 뽑는다(전 페이지가 site_description 하나를 공유하던 문제).
- sitemap lastmod: 빌드 날짜 대신 frontmatter `updated`.
- robots noindex: 저자용 운영 메모(backlog·plan-*) — sitemap에서도 빠진다(overrides/sitemap.xml).
"""
import re

MAX_LEN = 155
NOINDEX = re.compile(r"^(backlog|plan-.*)\.md$")
SKIP = re.compile(r"^(#|\||```|~~~|<|!!!|\?\?\?|!\[|---|\{|:::|\s)")
CLEAN = [
    (re.compile(r"\[\[([^\]|]+)\|([^\]]+)\]\]"), r"\2"),
    (re.compile(r"\[\[([^\]]+)\]\]"), r"\1"),
    (re.compile(r"!\[[^\]]*\]\([^)]*\)"), ""),
    (re.compile(r"\[([^\]]+)\]\([^)]*\)"), r"\1"),
    (re.compile(r"<[^>]+>"), ""),
    (re.compile(r"\{:[^}]*\}"), ""),
    (re.compile(r"[*_`]{1,3}"), ""),
    (re.compile(r"^>\s*(\[![^\]]+\]\s*)?"), ""),
    (re.compile(r'"'), "'"),  # Material이 content="…"를 이스케이프하지 않음
    (re.compile(r"\s+"), " "),
]


def describe(markdown, title=""):
    h1 = re.search(r"^# .*$", markdown, re.M)  # 첫 H1 = 페이지 제목(코드블록 속 `# 주석`보다 앞)
    body = markdown[h1.end():] if h1 else markdown
    para, fallback, fence = [], [], False
    for line in body.splitlines() + [""]:
        if line.lstrip().startswith(("```", "~~~")):
            fence = not fence
            if para:
                break
            continue
        if fence:
            continue
        if not line.strip():
            if para:
                break
            continue
        if SKIP.match(line):
            if para:
                break
            continue
        if line.lstrip().startswith((">", "- ", "* ")) or re.match(r"\d+\. ", line):
            if not para and not fallback:
                fallback.append(re.sub(r"^\s*([-*]|\d+\.)\s+", "", line))
            if para:
                break
            continue
        para.append(line)
    text = " ".join(para or fallback)
    for pat, rep in CLEAN:
        text = pat.sub(rep, text)
    text = text.strip()
    if title and (len(text) < 40 or text.endswith((":", "다음과 같습니다."))):
        text = f"{title} — {text}" if text else title
    if len(text) > MAX_LEN:
        text = text[:MAX_LEN].rsplit(" ", 1)[0].rstrip(",.·—:;(") + "…"
    return text


def on_page_markdown(markdown, page, config, files):
    meta = page.meta
    if meta.get("updated"):
        page.update_date = str(meta["updated"])
    if not meta.get("description"):
        desc = describe(markdown, str(meta.get("title", "")))
        if desc:
            meta["description"] = desc
    if NOINDEX.match(page.file.src_uri):
        meta["robots"] = "noindex"
    return markdown


if __name__ == "__main__":
    md = "# 제목\n\n[[a|링크]]와 **굵게** `코드` 설명입니다.\n둘째 줄.\n\n## 다음\n본문"
    assert describe(md) == "링크와 굵게 코드 설명입니다. 둘째 줄.", describe(md)
    assert describe("# t\n\n> 인용만\n\n| 표 |") == "인용만"
    assert describe("# t\n\n" + "가" * 10 + " " + "나" * 200).endswith("…")
    assert describe('# t\n\n```\n# 주석\n코드\n```\n\n"인용" 문장', "t") == "t — '인용' 문장"
    print("ok")
