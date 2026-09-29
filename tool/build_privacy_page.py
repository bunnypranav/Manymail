#!/usr/bin/env python3
"""Render PRIVACY.md into docs/privacy-policy.html.

Google Play requires a privacy policy at a public URL, and GitHub Pages serving
from /docs is the least-effort way to provide one. Generating the page from the
canonical PRIVACY.md means the hosted policy cannot silently drift out of sync
with the one in the repository -- which, for a legal document the Play listing
points at, matters more than it looks.

Handles only the markdown subset PRIVACY.md actually uses: headings,
paragraphs, pipe tables, bullet lists, bold, inline code and links.

Usage:  python tool/build_privacy_page.py
"""
import html
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / "PRIVACY.md"
TARGET = ROOT / "docs" / "privacy-policy.html"

PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Privacy Policy &middot; Manymail</title>
<meta name="description" content="Manymail collects no data. No analytics, no telemetry, no account. Everything stays on your device.">
<style>
  :root {{
    --bg: #ffffff;
    --fg: #1a1c1e;
    --muted: #5c6066;
    --rule: #e3e5e8;
    --accent: #3a5bd9;
    --code-bg: #f3f4f6;
  }}
  @media (prefers-color-scheme: dark) {{
    :root:not([data-theme="light"]) {{
      --bg: #16181c;
      --fg: #e6e8ea;
      --muted: #9aa0a6;
      --rule: #2c2f35;
      --accent: #8fa8ff;
      --code-bg: #22252b;
    }}
  }}
  :root[data-theme="dark"] {{
    --bg: #16181c;
    --fg: #e6e8ea;
    --muted: #9aa0a6;
    --rule: #2c2f35;
    --accent: #8fa8ff;
    --code-bg: #22252b;
  }}
  * {{ box-sizing: border-box; }}
  body {{
    background: var(--bg);
    color: var(--fg);
    margin: 0;
    font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
          Helvetica, Arial, sans-serif;
    -webkit-text-size-adjust: 100%;
  }}
  main {{ max-width: 46rem; margin: 0 auto; padding: 3rem 16px 5rem; }}
  h1 {{ font-size: 1.9rem; line-height: 1.2; margin: 0 0 .4rem; letter-spacing: -.02em; }}
  h2 {{
    font-size: 1.22rem; margin: 2.6rem 0 .8rem; padding-top: 1.4rem;
    border-top: 1px solid var(--rule); letter-spacing: -.01em;
  }}
  p {{ margin: 0 0 1rem; }}
  a {{ color: var(--accent); }}
  ul {{ padding-left: 1.3rem; margin: 0 0 1rem; }}
  li {{ margin-bottom: .45rem; }}
  code {{
    background: var(--code-bg); padding: .12em .38em; border-radius: 4px;
    font: .875em/1.4 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    word-break: break-word;
  }}
  strong {{ font-weight: 650; }}
  .meta {{ color: var(--muted); font-size: .92rem; margin-bottom: 2rem; }}
  .meta div {{ margin-bottom: .15rem; }}
  .table-wrap {{ overflow-x: auto; margin: 0 0 1.4rem; }}
  table {{ border-collapse: collapse; width: 100%; font-size: .93rem; }}
  th, td {{
    text-align: left; padding: .55rem .7rem;
    border-bottom: 1px solid var(--rule); vertical-align: top;
  }}
  th {{ font-weight: 650; white-space: nowrap; }}
  footer {{
    margin-top: 3.5rem; padding-top: 1.4rem; border-top: 1px solid var(--rule);
    color: var(--muted); font-size: .88rem;
  }}
</style>
</head>
<body>
<main>
{body}
<footer>
  Manymail is free software under the GNU General Public License v3.0.
  This page is generated from <code>PRIVACY.md</code> in the source repository.
</footer>
</main>
</body>
</html>
"""


def inline(text):
    """Escape, then re-introduce the inline markdown we support."""
    text = html.escape(text, quote=False)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    return text


def split_row(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def convert(markdown):
    lines = markdown.splitlines()
    out = []
    i = 0
    first_h1_done = False

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped:
            i += 1
            continue

        # Pipe table: a header row followed by a |---|---| separator.
        if (stripped.startswith("|") and i + 1 < len(lines)
                and re.match(r"^\s*\|[\s:|-]+\|\s*$", lines[i + 1])):
            headers = split_row(stripped)
            i += 2
            body_rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                body_rows.append(split_row(lines[i].strip()))
                i += 1
            out.append('<div class="table-wrap"><table>')
            out.append("<thead><tr>"
                       + "".join(f"<th>{inline(h)}</th>" for h in headers)
                       + "</tr></thead><tbody>")
            for row in body_rows:
                out.append("<tr>"
                           + "".join(f"<td>{inline(c)}</td>" for c in row)
                           + "</tr>")
            out.append("</tbody></table></div>")
            continue

        # Bullet list.
        if stripped.startswith("- "):
            out.append("<ul>")
            while i < len(lines) and lines[i].strip().startswith("- "):
                item = lines[i].strip()[2:]
                i += 1
                # Fold continuation lines into the same item.
                while (i < len(lines) and lines[i].strip()
                       and not lines[i].strip().startswith("- ")
                       and lines[i].startswith("  ")):
                    item += " " + lines[i].strip()
                    i += 1
                out.append(f"<li>{inline(item)}</li>")
            out.append("</ul>")
            continue

        # Headings.
        heading = re.match(r"^(#{1,3})\s+(.*)$", stripped)
        if heading:
            level = len(heading.group(1))
            text = inline(heading.group(2))
            out.append(f"<h{level}>{text}</h{level}>")
            i += 1
            # The two bold metadata lines that follow the title are a block of
            # their own, not a paragraph.
            if level == 1 and not first_h1_done:
                first_h1_done = True
                while i < len(lines) and not lines[i].strip():
                    i += 1
                meta = []
                while (i < len(lines) and lines[i].strip().startswith("**")
                       and lines[i].strip().endswith("**")):
                    meta.append(f"<div>{inline(lines[i].strip())}</div>")
                    i += 1
                if meta:
                    out.append('<div class="meta">' + "".join(meta) + "</div>")
            continue

        # Paragraph: gather until a blank line.
        para = [stripped]
        i += 1
        while i < len(lines) and lines[i].strip() and not re.match(
                r"^\s*(#{1,3}\s|[-*]\s|\|)", lines[i]):
            para.append(lines[i].strip())
            i += 1
        out.append(f"<p>{inline(' '.join(para))}</p>")

    return "\n".join(out)


def main():
    if not SOURCE.exists():
        print(f"missing {SOURCE}", file=sys.stderr)
        return 1
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(
        PAGE.format(body=convert(SOURCE.read_text(encoding="utf-8"))),
        encoding="utf-8",
        newline="\n",
    )
    print(f"wrote {TARGET.relative_to(ROOT)} "
          f"({TARGET.stat().st_size:,} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
