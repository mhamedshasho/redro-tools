$ErrorActionPreference = "Stop"
python -m pip install --upgrade pip
python -m pip install -r requirements-desktop.txt pyinstaller
pyinstaller --noconfirm --clean --windowed --name "Redro PDF to Word" --collect-all pdf2docx --collect-all fitz --collect-all docx desktop/main.py
