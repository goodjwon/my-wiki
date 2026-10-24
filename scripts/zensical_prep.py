"""Zensical은 MkDocs 훅을 실행하지 않는다 — seo.py·new_badge.py가 하던 일을 빌드 전후 단계로 옮긴다.

  pre  <docs> <mkdocs.yml> <out.yml> : docs/*.md frontmatter에 description·robots를 써 넣고,
                                       created가 30일 이내인 페이지 nav 제목에 🆕를 붙인 설정을 out.yml로 쓴다.
  post <docs> <site> <site_url>      : frontmatter `updated`를 lastmod로 쓰는 sitemap.xml을 만든다(robots 페이지 제외).
"""
import datetime as dt
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from seo import NOINDEX, describe  # noqa: E402
from new_badge import NEW_DAYS  # noqa: E402

FM = re.compile(r"\A---\n(.*?)\n---\n", re.S)


def field(fm, key):
    m = re.search(rf"^{key}:\s*['\"]?(.*?)['\"]?\s*$", fm, re.M)
    return m.group(1) if m else ""


def pages(docs):
    for root, _, names in os.walk(docs):
        for n in names:
            if n.endswith(".md"):
                path = os.path.join(root, n)
                yield os.path.relpath(path, docs), path


def pre(docs, config, out):
    today = dt.date.today()
    new = set()
    for rel, path in pages(docs):
        text = open(path, encoding="utf-8").read()
        m = FM.match(text)
        fm = m.group(1) if m else ""
        body = text[m.end():] if m else text
        add = []
        if not field(fm, "description"):
            desc = describe(body, field(fm, "title"))
            if desc:
                add.append(f"description: {json.dumps(desc, ensure_ascii=False)}")
        if NOINDEX.match(rel) and not field(fm, "robots"):
            add.append("robots: noindex")
        created = field(fm, "created")
        if re.fullmatch(r"\d{4}-\d{2}-\d{2}", created) and (today - dt.date.fromisoformat(created)).days <= NEW_DAYS:
            new.add(rel)
        if add:
            fm = "\n".join(([fm] if fm else []) + add)
            open(path, "w", encoding="utf-8").write(f"---\n{fm}\n---\n{body}")

    # nav 줄 `- 제목: 파일.md` 의 제목 앞에 🆕
    def badge(m):
        if m.group(3) not in new:
            return m.group(0)
        title = m.group(2)
        title = f"{title[0]}🆕 {title[1:]}" if title[:1] in "'\"" else f"🆕 {title}"
        return f"{m.group(1)}{title}: {m.group(3)}"

    cfg = open(config, encoding="utf-8").read()
    cfg = re.sub(r"^(\s*- )([^:\n]+): (\S+\.md)\s*$", badge, cfg, flags=re.M)
    open(out, "w", encoding="utf-8").write(cfg)


def post(docs, site, site_url):
    base = site_url.rstrip("/") + "/"
    urls = []
    for rel, path in sorted(pages(docs)):
        m = FM.match(open(path, encoding="utf-8").read())
        fm = m.group(1) if m else ""
        if field(fm, "robots"):
            continue
        slug = rel[:-3]
        if not os.path.exists(os.path.join(site, slug if slug != "index" else "", "index.html")):
            continue  # 빌드되지 않은 md
        loc = base if slug == "index" else f"{base}{slug}/"
        lastmod = field(fm, "updated")
        urls.append(f"  <url>\n    <loc>{loc}</loc>\n" + (f"    <lastmod>{lastmod}</lastmod>\n" if lastmod else "") + "  </url>")
    xml = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + "\n".join(urls) + "\n</urlset>\n"
    open(os.path.join(site, "sitemap.xml"), "w", encoding="utf-8").write(xml)
    print(f"sitemap.xml: {len(urls)} URL")


if __name__ == "__main__":
    {"pre": pre, "post": post}[sys.argv[1]](*sys.argv[2:])
