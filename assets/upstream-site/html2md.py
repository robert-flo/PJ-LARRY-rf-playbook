import html, pathlib, re, sys

src_dir, out_dir, base_url, date = sys.argv[1:5]
out = pathlib.Path(out_dir)
out.mkdir(parents=True, exist_ok=True)


def text(s):
    return html.unescape(re.sub(r"<[^>]+>", "", s))


def convert(s):
    m = re.search(r"<main.*?</main>", s, re.S)
    s = m.group(0) if m else s
    s = re.sub(r"<(script|style|nav|svg|button)[^>]*>.*?</\1>", "", s, flags=re.S)
    blocks = []

    def keep_pre(m):
        blocks.append(text(m.group(1)).strip("\n"))
        return f"\n\n@@PRE{len(blocks) - 1}@@\n\n"

    s = re.sub(r"<pre[^>]*>(.*?)</pre>", keep_pre, s, flags=re.S)
    s = re.sub(r"<code[^>]*>(.*?)</code>", lambda m: "`" + text(m.group(1)) + "`", s, flags=re.S)
    s = re.sub(r"<h([1-6])[^>]*>(.*?)</h\1>",
               lambda m: "\n\n" + "#" * int(m.group(1)) + " " + re.sub(r"\s+", " ", text(m.group(2))).strip() + "\n\n",
               s, flags=re.S)
    s = re.sub(r'<a [^>]*href="([^"]+)"[^>]*>(.*?)</a>',
               lambda m: f"[{re.sub(r'\s+', ' ', text(m.group(2))).strip()}]({m.group(1)})", s, flags=re.S)
    s = re.sub(r"<(strong|b)>(.*?)</\1>", r"**\2**", s, flags=re.S)
    s = re.sub(r"<(em|i)>(.*?)</\1>", r"*\2*", s, flags=re.S)
    s = re.sub(r"<li[^>]*>", "\n- ", s)
    s = re.sub(r"<(br|/p|/li|/div|/tr|/table|/ul|/ol|/blockquote)[^>]*>", "\n", s)
    s = re.sub(r"<(td|th)[^>]*>", " | ", s)
    s = text(s)
    s = re.sub(r"[ \t]+\n", "\n", s)
    s = re.sub(r"\n{3,}", "\n\n", s).strip()
    for i, b in enumerate(blocks):
        s = s.replace(f"@@PRE{i}@@", "```\n" + b + "\n```")
    return s


for f in sorted(pathlib.Path(src_dir).glob("*.html")):
    raw = f.read_text(errors="replace")
    t = re.search(r"<title>(.*?)</title>", raw, re.S)
    title = text(t.group(1)).strip() if t else f.stem
    url = base_url + ("" if f.stem == "index" else f.name)
    body = convert(raw)
    head = (f"---\ntitle: \"{title.replace(chr(34), '')}\"\nsource: {url}\narchived: {date}\n"
            f"tags:\n  - archivo-upstream\n---\n\n> [!QUOTE] Copia de archivo\n"
            f"> Contenido original de <{url}>, convertido a Markdown el {date}. "
            f"No se edita: es la referencia contra la que se compara el playbook.\n\n")
    (out / (f.stem + ".md")).write_text(head + body + "\n")
    print(f.stem, len(body))
