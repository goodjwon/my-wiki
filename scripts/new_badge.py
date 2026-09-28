"""MkDocs hook — frontmatter `created`가 NEW_DAYS일 이내인 페이지의 메뉴 제목에 🆕를 붙인다.

빌드 시점 기준이므로, 배지는 30일이 지난 뒤 다음 빌드·배포에서 사라진다.
"""
import datetime as dt
import re

NEW_DAYS = 30
CREATED = re.compile(r"^created:\s*(\d{4}-\d{2}-\d{2})", re.M)


def on_nav(nav, config, files):
    today = dt.date.today()
    for page in nav.pages:
        try:
            head = open(page.file.abs_src_path, encoding="utf-8").read(2000)
        except OSError:
            continue
        m = CREATED.search(head)
        if m and page.title and (today - dt.date.fromisoformat(m.group(1))).days <= NEW_DAYS:
            page.title = "🆕 " + page.title
    return nav
