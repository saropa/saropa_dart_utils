#!/usr/bin/env python3
"""Add Done column to ROADMAP_TO_700.md and mark completed items."""
import os
import re

path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "ROADMAP_TO_700.md"))

# Completed idea numbers per section (from implemented exports)
DONE = {
    (401, 440): [401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 413, 416, 417, 418, 419, 420, 422, 423, 424, 425, 426, 429, 430, 437, 438, 439, 440],
    (441, 490): [441, 442, 443, 444, 445, 446, 447, 449, 451, 452, 453, 455, 456, 457, 459, 462, 464, 465, 466, 468, 469, 470, 471, 472, 473, 474, 475, 481, 482, 484],
    (491, 530): [491, 496, 498, 500, 511, 514, 518, 525],
    (531, 560): [531, 532, 533, 534, 536, 537, 538, 539, 546, 547, 550, 553, 555, 556, 557, 558],
    (561, 590): [561, 562, 563, 564, 565, 569, 570, 572, 575, 576, 580, 581, 583, 584, 587, 589],
    (591, 620): [600, 610, 614, 616, 618],
    (621, 650): [621, 624, 628, 635, 639, 644, 647],
    (651, 680): [651, 652, 656, 657, 660, 664, 667, 668, 669, 671, 675, 676, 677],
    (681, 700): [681, 682, 686, 687, 688, 691, 692, 693, 694, 695, 696, 697, 700],
}

def section_for(num: int) -> tuple[int, int] | None:
    for (lo, hi) in DONE:
        if lo <= num <= hi:
            return (lo, hi)
    return None

def main():
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split("\n")
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Table header: add Done column if not present
        if re.match(r"^\| # \| Idea \|", line) and "| Done |" not in line:
            out.append(line.rstrip().rstrip("|").rstrip() + " | Done |")
            i += 1
            # Next line is separator
            if i < len(lines) and re.match(r"^\|---\|", lines[i]):
                sep = lines[i].rstrip().rstrip("|").rstrip() + "|------|"
                out.append(sep)
                i += 1
            continue
        # Data row: | NNN | ... | Size | [Done]
        m = re.match(r"^\| (\d+) \| (.+)$", line)
        if m and line.rstrip().endswith("|"):
            num = int(m.group(1))
            sec = section_for(num)
            if sec:
                done_set = set(DONE[sec])
                mark = " ✅ |" if num in done_set else " |"
                # Row has 6 pipes = 5 cells (no Done yet); 7 pipes = already has Done
                pipe_count = line.count("|")
                if pipe_count < 7:
                    out.append(line.rstrip() + mark)
                else:
                    out.append(line)
            else:
                out.append(line)
            i += 1
            continue
        out.append(line)
        i += 1

    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out))

if __name__ == "__main__":
    main()
