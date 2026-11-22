import "./style.css";
import * as pdfjsLib from "pdfjs-dist";
import pdfWorker from "pdfjs-dist/build/pdf.worker.min.mjs?url";
import { Document, Packer, Paragraph, TextRun, AlignmentType } from "docx";
import { registerSW } from "virtual:pwa-register";

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorker;
registerSW({ immediate: true });

const input = document.querySelector("#fileInput");
const dropzone = document.querySelector("#dropzone");
const fileName = document.querySelector("#fileName");
const convertButton = document.querySelector("#convertButton");
const status = document.querySelector("#status");
const result = document.querySelector("#result");
let selectedFile = null;

function setFile(file) {
  if (!file) return;
  if (file.type !== "application/pdf" && !file.name.toLowerCase().endsWith(".pdf")) {
    status.textContent = "Please select a PDF file.";
    return;
  }
  selectedFile = file;
  fileName.textContent = file.name + " · " + (file.size / 1024 / 1024).toFixed(2) + " MB";
  convertButton.disabled = false;
  result.hidden = true;
  status.textContent = "Ready to convert locally.";
}

input.addEventListener("change", () => setFile(input.files?.[0]));
dropzone.addEventListener("dragover", event => {
  event.preventDefault();
  dropzone.classList.add("drag");
});
dropzone.addEventListener("dragleave", () => dropzone.classList.remove("drag"));
dropzone.addEventListener("drop", event => {
  event.preventDefault();
  dropzone.classList.remove("drag");
  setFile(event.dataTransfer.files?.[0]);
});

function groupTextItems(items) {
  const lines = new Map();
  for (const item of items) {
    const text = (item.str || "").trim();
    if (!text) continue;
    const y = Math.round(item.transform?.[5] || 0);
    if (!lines.has(y)) lines.set(y, []);
    lines.get(y).push({ x: item.transform?.[4] || 0, text });
  }
  return [...lines.entries()]
    .sort((a, b) => Number(b[0]) - Number(a[0]))
    .map(([, parts]) => parts.sort((a, b) => a.x - b.x).map(part => part.text).join(" ").trim())
    .filter(Boolean);
}

async function convert() {
  if (!selectedFile) return;
  convertButton.disabled = true;
  result.hidden = true;
  status.textContent = "Opening PDF locally…";
  try {
    const bytes = new Uint8Array(await selectedFile.arrayBuffer());
    const pdf = await pdfjsLib.getDocument({ data: bytes }).promise;
    const paragraphs = [];
    for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber += 1) {
      status.textContent = "Reading page " + pageNumber + " of " + pdf.numPages + "…";
      const page = await pdf.getPage(pageNumber);
      const content = await page.getTextContent();
      const lines = groupTextItems(content.items);
      for (const line of lines) {
        const rtl = /[\u0590-\u08ff]/.test(line);
        paragraphs.push(new Paragraph({
          bidirectional: rtl,
          alignment: rtl ? AlignmentType.RIGHT : AlignmentType.LEFT,
          spacing: { after: 100 },
          children: [new TextRun({ text: line, rightToLeft: rtl })]
        }));
      }
      if (pageNumber < pdf.numPages) paragraphs.push(new Paragraph({ pageBreakBefore: true, children: [new TextRun("")] }));
    }
    if (!paragraphs.length) throw new Error("No selectable text was found. This PDF may contain scanned images and needs OCR.");
    status.textContent = "Building Word document…";
    const doc = new Document({ sections: [{ properties: {}, children: paragraphs }] });
    const blob = await Packer.toBlob(doc);
    const url = URL.createObjectURL(blob);
    const outputName = selectedFile.name.replace(/\.pdf$/i, "") + ".docx";
    const link = document.createElement("a");
    link.href = url;
    link.download = outputName;
    link.click();
    result.textContent = "Conversion complete. Downloaded " + outputName;
    result.hidden = false;
    status.textContent = "Finished · " + pdf.numPages + " page(s) processed on this device.";
    setTimeout(() => URL.revokeObjectURL(url), 30000);
  } catch (error) {
    status.textContent = error?.message || "Conversion failed.";
  } finally {
    convertButton.disabled = false;
  }
}
convertButton.addEventListener("click", convert);
