# Redro PDF to Word

Offline-first PDF to DOCX converter by Redro.

## Editions

- Web/PWA: browser-side text extraction and DOCX generation. After installation and asset caching, conversion works offline.
- Windows: native Python desktop edition using PySide6 and pdf2docx.
- Android: native packaging is planned; it is not yet published.

## Web development

```bash
cd web
npm install
npm run dev
npm run build
```

## Windows development

```bash
python -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements-desktop.txt
python desktop/main.py
```

Build a Windows executable with `scripts/build_windows.ps1`.

## Conversion notes

PDF is a fixed-layout format, not a word-processing format. The web edition extracts text and rebuilds editable DOCX paragraphs; complex layouts, scanned pages, tables, and exact positioning may differ. The Windows edition uses pdf2docx for layout-aware conversion. Scanned PDFs require OCR, which is not included yet.

## Privacy

Files are processed locally. No upload endpoint, account, analytics, or remote conversion service is included.

## License

MIT
