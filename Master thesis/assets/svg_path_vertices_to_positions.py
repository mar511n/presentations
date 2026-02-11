#!/usr/bin/env python3
"""Extract vertices from the first <path> in an SVG and print them as 2D points.

This is meant for workflows like:
  - Inkscape -> single polyline-like path
  - use all vertices as plotting points in Asymptote (positionsStr)

Supports: M/m, L/l, H/h, V/v, Z/z.
If your path contains curves (C/Q/A/...), either convert to polyline in Inkscape
or extend this script.

Usage:
  python3 svg_path_vertices_to_positions.py path.svg > points.txt
  # or print directly as a positionsStr literal:
  python3 svg_path_vertices_to_positions.py path.svg --asymptote-string

Optional:
  --flip-y    Flip Y using the SVG viewBox height (useful because SVG y-axis goes down).
"""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from typing import Iterable, Iterator, List, Optional, Tuple


COMMAND_RE = re.compile(r"[MmLlHhVvZz]")
TOKEN_RE = re.compile(r"[MmLlHhVvZz]|[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?")


@dataclass
class ViewBox:
    min_x: float
    min_y: float
    width: float
    height: float


def _strip_ns(tag: str) -> str:
    return tag.split("}")[-1] if "}" in tag else tag


def _find_first_path_d(svg_path: str) -> Tuple[str, Optional[ViewBox]]:
    tree = ET.parse(svg_path)
    root = tree.getroot()

    vb = None
    view_box = root.attrib.get("viewBox")
    if view_box:
        parts = view_box.replace(",", " ").split()
        if len(parts) == 4:
            vb = ViewBox(*(float(p) for p in parts))

    # Find first <path> element (ignore namespaces)
    for el in root.iter():
        if _strip_ns(el.tag) == "path":
            d = el.attrib.get("d")
            if d:
                return d, vb

    raise ValueError("No <path d=...> element found in SVG")


def _tokenize_path_d(d: str) -> List[str]:
    tokens = TOKEN_RE.findall(d)
    if not tokens:
        raise ValueError("Path 'd' attribute contains no tokens")
    return tokens


def _is_command(tok: str) -> bool:
    return bool(COMMAND_RE.fullmatch(tok))


def _as_float(tok: str) -> float:
    try:
        return float(tok)
    except ValueError as e:
        raise ValueError(f"Invalid number token: {tok!r}") from e


def extract_vertices_from_path_d(d: str) -> List[Tuple[float, float]]:
    """Return absolute vertices in SVG user units."""

    tokens = _tokenize_path_d(d)

    vertices: List[Tuple[float, float]] = []

    i = 0
    cmd: Optional[str] = None
    cur_x = 0.0
    cur_y = 0.0
    start_x = 0.0
    start_y = 0.0

    def lineto_abs(x: float, y: float) -> None:
        nonlocal cur_x, cur_y
        cur_x, cur_y = x, y
        vertices.append((cur_x, cur_y))

    def lineto_rel(dx: float, dy: float) -> None:
        lineto_abs(cur_x + dx, cur_y + dy)

    while i < len(tokens):
        tok = tokens[i]
        if _is_command(tok):
            cmd = tok
            i += 1
            if cmd in "Zz":
                # close path
                lineto_abs(start_x, start_y)
            continue

        if cmd is None:
            raise ValueError("Path data starts with a number; expected a command")

        if cmd in "Mm":
            # moveto: first pair starts a new subpath; subsequent pairs are lineto
            # Need at least one pair
            if i + 1 >= len(tokens):
                raise ValueError("Incomplete moveto coordinate pair")
            x = _as_float(tokens[i])
            y = _as_float(tokens[i + 1])
            i += 2

            if cmd == "m":
                cur_x += x
                cur_y += y
            else:
                cur_x = x
                cur_y = y

            start_x, start_y = cur_x, cur_y
            vertices.append((cur_x, cur_y))

            # Subsequent coordinate pairs are treated as implicit lineto with same absolute/relative mode
            cmd = "l" if cmd == "m" else "L"
            continue

        if cmd in "Ll":
            if i + 1 >= len(tokens):
                raise ValueError("Incomplete lineto coordinate pair")
            x = _as_float(tokens[i])
            y = _as_float(tokens[i + 1])
            i += 2
            if cmd == "l":
                lineto_rel(x, y)
            else:
                lineto_abs(x, y)
            continue

        if cmd in "Hh":
            x = _as_float(tokens[i])
            i += 1
            if cmd == "h":
                lineto_abs(cur_x + x, cur_y)
            else:
                lineto_abs(x, cur_y)
            continue

        if cmd in "Vv":
            y = _as_float(tokens[i])
            i += 1
            if cmd == "v":
                lineto_abs(cur_x, cur_y + y)
            else:
                lineto_abs(cur_x, y)
            continue

        # If you hit this, the path contains commands we didn't implement.
        raise ValueError(
            f"Unsupported SVG path command {cmd!r}. "
            "Convert the path to a polyline (only M/L/H/V/Z) or extend the script."
        )

    return vertices


def format_points_as_asymptote_string(points: Iterable[Tuple[float, float]]) -> str:
    return " ".join(f"({x:.8g},{y:.8g})" for x, y in points)


def main(argv: List[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("svg", help="Input SVG file")
    ap.add_argument(
        "--flip-y",
        action="store_true",
        help="Flip Y using the SVG viewBox height (y' = viewBoxHeight - y).",
    )
    ap.add_argument(
        "--asymptote-string",
        action="store_true",
        help="Print a single-line Asymptote positionsStr value like '(x,y) (x,y) ...'",
    )
    args = ap.parse_args(argv)

    d, vb = _find_first_path_d(args.svg)
    pts = extract_vertices_from_path_d(d)

    if args.flip_y:
        if vb is None:
            raise ValueError("--flip-y requires the SVG to have a viewBox")
        pts = [(x, vb.height - y) for (x, y) in pts]

    if args.asymptote_string:
        sys.stdout.write(format_points_as_asymptote_string(pts) + "\n")
    else:
        for x, y in pts:
            sys.stdout.write(f"{x} {y}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
