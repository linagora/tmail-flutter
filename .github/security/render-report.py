#!/usr/bin/env python3
"""Renders the markdown report as sanitized, inline-styled HTML for email clients."""
import sys

import markdown
import nh3

TAGS = {"h1", "h2", "h3", "h4", "p", "ul", "ol", "li", "table", "thead", "tbody", "tr",
        "th", "td", "code", "pre", "strong", "em", "br", "hr", "blockquote"}
# mail clients drop <style>; inline styles are added after sanitizing
STYLE = {
    "table": "border-collapse:collapse;margin:8px 0;font-size:13px",
    "th": "border:1px solid #d0d7de;padding:4px 8px;background:#f6f8fa;text-align:left",
    "td": "border:1px solid #d0d7de;padding:4px 8px;vertical-align:top",
    "pre": "background:#f6f8fa;padding:8px;white-space:pre-wrap;font-size:12px",
    "h2": "border-bottom:1px solid #d0d7de;padding-bottom:4px;margin-top:24px",
}


def render(text: str) -> str:
    html = markdown.markdown(text, extensions=["tables", "fenced_code", "sane_lists"])
    # report text comes from scanned code and LLM output: no links, images or raw HTML survive
    html = nh3.clean(html, tags=TAGS, attributes={})
    for tag, css in STYLE.items():
        html = html.replace(f"<{tag}>", f'<{tag} style="{css}">')
    return ('<!doctype html><html><body style="font-family:-apple-system,Segoe UI,sans-serif;'
            'font-size:14px;line-height:1.45;color:#1f2328">' + html + "</body></html>\n")


def main() -> None:
    src, dst = sys.argv[1:3]
    with open(src, encoding="utf-8") as f:
        text = f.read()
    with open(dst, "w", encoding="utf-8") as f:
        f.write(render(text))


if __name__ == "__main__":
    main()
