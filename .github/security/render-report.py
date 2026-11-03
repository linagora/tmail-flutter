#!/usr/bin/env python3
"""Renders the markdown report as sanitized, inline-styled HTML for email clients."""
import re
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
# mail clients (Twake Mail included) fold a trailing blockquote as quoted reply: show the LLM block as a div
QUOTE_DIV = '<div style="border-left:4px solid #d4a72c;padding:0 12px;margin:16px 0">'


def render(text: str) -> str:
    md = markdown.Markdown(extensions=["tables", "fenced_code", "sane_lists"])
    # raw HTML from scanned code/LLM output must stay text, so it can't close the quote or add attributes
    md.preprocessors.deregister("html_block")
    md.inlinePatterns.deregister("html")
    html = md.convert(text)
    # report text comes from scanned code and LLM output: no links, images or raw HTML survive
    html = nh3.clean(html, tags=TAGS, attributes={"*": set()})
    for tag, css in STYLE.items():
        html = re.sub(rf"<{tag}(?=[\s>])", f'<{tag} style="{css}"', html)
    html = html.replace("<blockquote>", QUOTE_DIV).replace("</blockquote>", "</div>")
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
