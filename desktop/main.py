import sys
from pathlib import Path
from PySide6.QtCore import QThread, Signal
from PySide6.QtWidgets import QApplication, QFileDialog, QLabel, QMainWindow, QPushButton, QProgressBar, QVBoxLayout, QWidget

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from core.converter import convert_pdf_to_docx


class ConvertWorker(QThread):
    finished_path = Signal(str)
    failed = Signal(str)

    def __init__(self, source, destination):
        super().__init__()
        self.source = source
        self.destination = destination

    def run(self):
        try:
            result = convert_pdf_to_docx(self.source, self.destination)
            self.finished_path.emit(str(result))
        except Exception as exc:
            self.failed.emit(str(exc))


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Redro PDF to Word")
        self.setMinimumSize(520, 360)
        self.source = None
        self.worker = None

        title = QLabel("Redro PDF to Word")
        title.setObjectName("title")
        subtitle = QLabel("Convert PDF files to editable Word documents. Files stay on this device.")
        subtitle.setWordWrap(True)
        self.file_label = QLabel("No PDF selected")
        self.file_label.setObjectName("fileLabel")
        self.choose_button = QPushButton("Choose PDF")
        self.choose_button.clicked.connect(self.choose_pdf)
        self.convert_button = QPushButton("Convert to Word")
        self.convert_button.setObjectName("primary")
        self.convert_button.setEnabled(False)
        self.convert_button.clicked.connect(self.convert)
        self.progress = QProgressBar()
        self.progress.setRange(0, 0)
        self.progress.hide()
        self.status = QLabel("Ready")
        self.status.setWordWrap(True)

        layout = QVBoxLayout()
        layout.setSpacing(16)
        for widget in (title, subtitle, self.file_label, self.choose_button, self.convert_button, self.progress, self.status):
            layout.addWidget(widget)
        layout.addStretch()

        container = QWidget()
        container.setLayout(layout)
        container.setStyleSheet("""
            QWidget { background: #111216; color: #f4f4f5; font: 14px 'Segoe UI'; }
            QLabel { color: #c4c4cc; }
            #title { color: white; font-size: 27px; font-weight: 800; }
            #fileLabel { background: #1d1f25; border: 1px solid #30323a; border-radius: 12px; padding: 16px; }
            QPushButton { background: #292b32; border: 1px solid #3b3d46; border-radius: 10px; padding: 13px; color: white; }
            QPushButton:hover { border-color: #e11d48; }
            QPushButton:disabled { color: #777; }
            #primary { background: #e11d48; border: 0; font-weight: 700; }
            QProgressBar { border: 0; background: #292b32; height: 8px; border-radius: 4px; }
            QProgressBar::chunk { background: #e11d48; border-radius: 4px; }
        """)
        self.setCentralWidget(container)

    def choose_pdf(self):
        path, _ = QFileDialog.getOpenFileName(self, "Choose PDF", "", "PDF files (*.pdf)")
        if path:
            self.source = path
            self.file_label.setText(Path(path).name)
            self.convert_button.setEnabled(True)
            self.status.setText("PDF selected. Ready to convert.")

    def convert(self):
        if not self.source:
            return
        destination, _ = QFileDialog.getSaveFileName(self, "Save Word document", str(Path(self.source).with_suffix(".docx")), "Word document (*.docx)")
        if not destination:
            return
        if not destination.lower().endswith(".docx"):
            destination += ".docx"
        self.choose_button.setEnabled(False)
        self.convert_button.setEnabled(False)
        self.progress.show()
        self.status.setText("Converting locally. Large files may take some time.")
        self.worker = ConvertWorker(self.source, destination)
        self.worker.finished_path.connect(self.done)
        self.worker.failed.connect(self.error)
        self.worker.start()

    def done(self, path):
        self.progress.hide()
        self.choose_button.setEnabled(True)
        self.convert_button.setEnabled(True)
        self.status.setText("Conversion complete: " + path)

    def error(self, message):
        self.progress.hide()
        self.choose_button.setEnabled(True)
        self.convert_button.setEnabled(True)
        self.status.setText("Conversion failed: " + message)


app = QApplication(sys.argv)
window = MainWindow()
window.show()
sys.exit(app.exec())
