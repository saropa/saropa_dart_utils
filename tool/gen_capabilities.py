#!/usr/bin/env python3
"""Generate CAPABILITIES.md — a per-symbol index of every public util in lib/.

This is the maintained source for the team-facing capabilities catalog. Run it
after adding or renaming utilities so CAPABILITIES.md stays complete:

    python tool/gen_capabilities.py

Heuristic: the project documents every public member, so a declaration that is
immediately preceded by a `///` doc block is a public API symbol. That filter
captures extensions, classes, typedefs, top-level functions, methods, getters,
and named constructors with high precision while excluding locals and control
flow (which carry no doc comment). Output is grouped by category (top-level dir
under lib/) then by file, with each file's import path.
"""
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
LIB = os.path.join(ROOT, "lib")
DEST = os.path.join(ROOT, "CAPABILITIES.md")
BARREL = "saropa_dart_utils.dart"

# Human label per top-level dir under lib/.
CATEGORY = {
    "string": "String", "datetime": "DateTime", "iterable": "Iterable",
    "list": "List", "collections": "Collections", "graph": "Graph",
    "stats": "Stats", "validation": "Validation", "async": "Async",
    "num": "Number", "int": "Integer", "double": "Double", "bool": "Bool",
    "map": "Map", "parsing": "Parsing", "caching": "Caching", "url": "URL & Path",
    "niche": "Niche", "object": "Object & Null", "enum": "Enum", "json": "JSON",
    "base64": "Base64", "hex": "Hex", "html": "HTML", "uuid": "UUID",
    "random": "Random", "regex": "Regex", "gesture": "Gesture", "testing": "Testing",
}

KEYWORDS = {"if", "for", "while", "switch", "catch", "return", "else", "do",
            "assert", "throw", "await", "yield", "super", "this", "new", "in",
            "is", "as", "set", "final", "const", "var", "void"}

decl_type = re.compile(r"^\s*(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+|mixin\s+)*(class|mixin|enum)\s+(\w+)")
decl_ext = re.compile(r"^\s*extension(?:\s+(\w+))?\s+on\s+(.+?)\s*\{")
decl_exttype = re.compile(r"^\s*extension\s+type\s+(\w+)")
decl_typedef = re.compile(r"^\s*typedef\s+(\w+)")
decl_getter = re.compile(r"\bget\s+(\w+)")
decl_callable = re.compile(r"([A-Za-z_]\w*)\s*(?:<[^>]*>)?\s*\(")


def first_sentence(doc):
    text = re.sub(r"\s+", " ", " ".join(doc)).strip()
    text = text.split("```")[0].strip()
    m = re.search(r"\.(\s|$)", text)
    if m:
        text = text[: m.start() + 1]
    if len(text) > 160:
        text = text[:157].rstrip() + "..."
    return text


def symbol_name(line):
    g = decl_getter.search(line)
    if g and "get " in line.split("(")[0]:
        return g.group(1), "getter"
    m = decl_callable.search(line)
    if m and m.group(1) not in KEYWORDS:
        return m.group(1), "method"
    return None, None


def parse_file(path):
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()
    doc = []
    symbols = []
    for raw in lines:
        stripped = raw.strip()
        if stripped.startswith("///"):
            doc.append(stripped[3:].strip())
            continue
        if stripped.startswith("@"):  # annotations sit between doc and decl
            continue
        if stripped == "" or stripped.startswith("//"):
            doc = []
            continue
        if doc:
            kind = name = target = None
            m = decl_ext.match(raw)
            mt = decl_type.match(raw)
            mx = decl_exttype.match(raw)
            mtd = decl_typedef.match(raw)
            if m:
                kind, name, target = "extension", (m.group(1) or "(unnamed)"), m.group(2)
            elif mx:
                kind, name = "extension type", mx.group(1)
            elif mt:
                kind, name = mt.group(1), mt.group(2)
            elif mtd:
                kind, name = "typedef", mtd.group(1)
            else:
                name, kind = symbol_name(raw)
            if name and not name.startswith("_"):
                # A callable whose name is TypeCase is a constructor, not a method.
                if kind == "method" and name[0].isupper():
                    kind = "constructor"
                entry = (kind, name, target, first_sentence(doc))
                if not symbols or symbols[-1][:2] != entry[:2]:
                    symbols.append(entry)
        doc = []

    # File purpose = the first /// block at the very top of the file.
    top = []
    for raw in lines:
        s = raw.strip()
        if s.startswith("///"):
            top.append(s[3:].strip())
        elif top:
            break
        elif s == "" or s.startswith("//") or s == "library;":
            continue
        else:
            break
    return first_sentence(top) if top else "", symbols


def import_path(rel):
    return "package:saropa_dart_utils/" + rel.replace(os.sep, "/")


def main():
    cats = {}
    total_files = total_syms = 0
    for root, _, files in os.walk(LIB):
        for fn in sorted(files):
            if not fn.endswith(".dart") or fn == BARREL:
                continue
            rel = os.path.relpath(os.path.join(root, fn), LIB)
            cat = CATEGORY.get(rel.split(os.sep)[0], rel.split(os.sep)[0].capitalize())
            purpose, syms = parse_file(os.path.join(root, fn))
            if not syms:
                continue
            total_files += 1
            total_syms += len(syms)
            cats.setdefault(cat, []).append((rel, purpose, syms))

    out = ["# Capabilities Index", ""]
    out.append(
        "A complete, per-symbol catalog of every public utility in "
        "`saropa_dart_utils` — for teams evaluating or adopting the library. "
        f"Covers **{total_syms} public symbols** across **{total_files} files**."
    )
    out += [
        "",
        "Each file is independently importable for minimal bundle size "
        "(`import 'package:saropa_dart_utils/<path>';`), or import the barrel "
        "`package:saropa_dart_utils/saropa_dart_utils.dart` for everything.",
        "",
        "> Generated by `tool/gen_capabilities.py` from the documented public API "
        "under `lib/`. Run it after adding utilities to keep this complete.",
        "",
        "---",
        "",
        "## Categories",
        "",
    ]
    for cat in sorted(cats):
        anchor = cat.lower().replace(" & ", "--").replace(" ", "-")
        out.append(f"- [{cat}](#{anchor}) — {sum(len(s) for _, _, s in cats[cat])} symbols")
    out += ["", "---", ""]

    for cat in sorted(cats):
        out += [f"## {cat}", ""]
        for rel, purpose, syms in sorted(cats[cat]):
            out.append(f"### `{rel.replace(os.sep, '/')}`")
            if purpose:
                out += ["", purpose]
            out += ["", f"`import '{import_path(rel)}';`", "",
                    "| Symbol | Kind | Description |", "|--------|------|-------------|"]
            for kind, name, target, desc in syms:
                label = f"`{name}` on `{target}`" if kind == "extension" and target else f"`{name}`"
                out.append(f"| {label} | {kind} | {(desc or '').replace('|', chr(92) + '|')} |")
            out.append("")
        out += ["---", ""]

    with open(DEST, "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")
    print(f"Wrote {DEST}: {total_syms} symbols, {total_files} files")


if __name__ == "__main__":
    main()
