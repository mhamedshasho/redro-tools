from pathlib import Path
from pdf2docx import Converter


def convert_pdf_to_docx(source, destination):
    source_path = Path(source).expanduser().resolve()
    destination_path = Path(destination).expanduser().resolve()

    if not source_path.is_file():
        raise FileNotFoundError("PDF file was not found.")
    if source_path.suffix.lower() != ".pdf":
        raise ValueError("The input file must be a PDF.")
    if source_path.stat().st_size == 0:
        raise ValueError("The PDF file is empty.")
    if destination_path.suffix.lower() != ".docx":
        destination_path = destination_path.with_suffix(".docx")
    if source_path == destination_path:
        raise ValueError("Input and output files must be different.")

    converter = Converter(str(source_path))
    try:
        converter.convert(str(destination_path), start=0, end=None, pages=None)
    finally:
        converter.close()

    if not destination_path.exists() or destination_path.stat().st_size == 0:
        raise RuntimeError("The conversion did not produce a DOCX file.")

    return destination_path
