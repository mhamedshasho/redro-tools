#!/usr/bin/env python3
"""Generate a small, deterministic multi-page PDF for the Windows render smoke test."""

from __future__ import annotations

import argparse
from pathlib import Path


PAGE_COUNT = 24


def pdf_text(value: str) -> str:
    return value.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def page_content(page_number: int) -> bytes:
    commands = [
        "q",
        "0.90 0.94 0.98 rg",
        "24 24 564 744 re f",
        "1 1 1 rg",
        "34 34 544 724 re f",
        "Q",
        "0.10 0.24 0.45 rg",
        "BT /F1 24 Tf 54 720 Td",
        f"({pdf_text('Redro PDF render smoke test')}) Tj",
        "ET",
        "0.12 0.12 0.12 rg",
        "BT /F1 16 Tf 54 680 Td",
        f"({pdf_text(f'Page {page_number:02d} of {PAGE_COUNT:02d}')}) Tj",
        "ET",
        "0.20 0.45 0.75 rg",
        "54 630 500 8 re f",
        "0.12 0.12 0.12 rg",
    ]
    for row in range(18):
        y = 600 - row * 27
        commands.extend(
            [
                f"BT /F1 11 Tf 54 {y} Td",
                f"({pdf_text(f'Render test content row {row + 1:02d} on page {page_number:02d}.')}) Tj",
                "ET",
            ]
        )
        bar_width = 120 + ((page_number * 31 + row * 17) % 340)
        commands.extend(
            [
                "0.74 0.82 0.90 rg",
                f"54 {y - 12} {bar_width} 3 re f",
                "0.12 0.12 0.12 rg",
            ]
        )
    return ("\n".join(commands) + "\n").encode("ascii")


def build_pdf() -> bytes:
    page_ids = [4 + 2 * index for index in range(PAGE_COUNT)]
    last_id = 3 + 2 * PAGE_COUNT
    objects: list[bytes | None] = [None] * (last_id + 1)
    objects[1] = b"<< /Type /Catalog /Pages 2 0 R >>"
    kids = " ".join(f"{page_id} 0 R" for page_id in page_ids)
    objects[2] = f"<< /Type /Pages /Kids [{kids}] /Count {PAGE_COUNT} >>".encode("ascii")
    objects[3] = b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"

    for index, page_id in enumerate(page_ids, start=1):
        content_id = page_id + 1
        content = page_content(index)
        objects[page_id] = (
            f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] "
            f"/Resources << /Font << /F1 3 0 R >> >> /Contents {content_id} 0 R >>"
        ).encode("ascii")
        objects[content_id] = (
            f"<< /Length {len(content)} >>\nstream\n".encode("ascii")
            + content
            + b"endstream"
        )

    output = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0] * (last_id + 1)
    for object_id in range(1, last_id + 1):
        body = objects[object_id]
        if body is None:
            raise ValueError(f"PDF object {object_id} was not created")
        offsets[object_id] = len(output)
        output.extend(f"{object_id} 0 obj\n".encode("ascii"))
        output.extend(body)
        output.extend(b"\nendobj\n")

    xref_offset = len(output)
    output.extend(f"xref\n0 {last_id + 1}\n".encode("ascii"))
    output.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        output.extend(f"{offset:010d} 00000 n \n".encode("ascii"))
    output.extend(
        f"trailer\n<< /Size {last_id + 1} /Root 1 0 R >>\n"
        f"startxref\n{xref_offset}\n%%EOF\n".encode("ascii")
    )
    return bytes(output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    output_path = parser.parse_args().output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(build_pdf())
    print(f"Created {PAGE_COUNT}-page PDF: {output_path} ({output_path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
