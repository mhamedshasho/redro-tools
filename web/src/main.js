import "./style.css";
import * as pdfjsLib from "pdfjs-dist";
import pdfWorker from "pdfjs-dist/build/pdf.worker.min.mjs?url";
import { Document, Packer, Paragraph, TextRun, AlignmentType } from "docx";
import { registerSW } from "virtual:pwa-register";

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorker;
registerSW({ immediate: true });

const translations = {
  en: {
    local:"LOCAL PROCESSING", eyebrow:"OFFLINE DOCUMENT CONVERTER", headline:"PDF to Word.", headlineAccent:"Made simple.",
    intro:"Convert your documents into editable Word files. Your files stay on your device.",
    chooseTitle:"Choose a PDF file", dropHint:"Drag and drop a document here, or browse your device.",
    browse:"Choose PDF", noFile:"No file selected", outputFormat:"Output format", processing:"Processing",
    onDevice:"On this device · Offline", convert:"Convert to Word", selectStart:"Select a PDF to begin.",
    privateTitle:"Private by design", privateText:"Documents are processed in your browser. No upload server.",
    offlineTitle:"Works offline", offlineText:"Install the app once, then convert locally without a connection.",
    editableTitle:"Editable DOCX", editableText:"Extracted text is rebuilt as editable Word paragraphs.",
    notice:"Complex layouts, scanned pages, and exact positioning may need manual adjustment. OCR support is not included in this web build.",
    footer:"Free · Offline · Private", invalid:"Please select a PDF file.", ready:"Ready to convert locally.",
    opening:"Opening PDF locally…", reading:"Reading page {page} of {total}…", building:"Building Word document…",
    noText:"No selectable text was found. This PDF may contain scanned images and needs OCR.",
    complete:"Conversion complete. Downloaded {name}", finished:"Finished · {count} page(s) processed on this device.",
    failed:"Conversion failed."
  },
  ar: {
    local:"معالجة محلية", eyebrow:"تحويل المستندات دون اتصال", headline:"حوّل PDF إلى Word.", headlineAccent:"بكل بساطة.",
    intro:"حوّل مستنداتك إلى ملفات Word قابلة للتعديل. تبقى ملفاتك على جهازك.",
    chooseTitle:"اختر ملف PDF", dropHint:"اسحب الملف وأفلته هنا، أو تصفّح ملفات جهازك.",
    browse:"اختيار ملف PDF", noFile:"لم يتم اختيار ملف", outputFormat:"صيغة الإخراج", processing:"طريقة المعالجة",
    onDevice:"على جهازك · دون اتصال", convert:"تحويل إلى Word", selectStart:"اختر ملف PDF للبدء.",
    privateTitle:"خصوصيتك أولاً", privateText:"تتم معالجة المستند داخل المتصفح دون رفعه إلى خادم.",
    offlineTitle:"يعمل دون إنترنت", offlineText:"ثبّت التطبيق مرة واحدة، ثم حوّل ملفاتك محلياً دون اتصال.",
    editableTitle:"ملف Word قابل للتعديل", editableText:"يُعاد بناء النص المستخرج ضمن فقرات قابلة للتعديل.",
    notice:"قد تحتاج التخطيطات المعقدة والصفحات الممسوحة ضوئياً إلى تعديل يدوي. لا يتضمن إصدار الويب حالياً تقنية OCR.",
    footer:"مجاني · دون اتصال · يحافظ على الخصوصية", invalid:"يرجى اختيار ملف PDF.", ready:"الملف جاهز للتحويل محلياً.",
    opening:"جارٍ فتح ملف PDF محلياً…", reading:"جارٍ قراءة الصفحة {page} من {total}…", building:"جارٍ إنشاء ملف Word…",
    noText:"لم يتم العثور على نص قابل للاستخراج. قد يكون الملف صوراً ممسوحة ويحتاج إلى OCR.",
    complete:"اكتمل التحويل. تم تنزيل {name}", finished:"اكتمل · تمت معالجة {count} صفحة على هذا الجهاز.",
    failed:"فشل التحويل."
  }
};

let language = "en";
const t = key => translations[language][key] || translations.en[key] || key;
const languageButton = document.querySelector("#languageButton");

function setLanguage(next) {
  language = next;
  document.documentElement.lang = next;
  document.documentElement.dir = next === "ar" ? "rtl" : "ltr";
  document.querySelectorAll("[data-i18n]").forEach(element => {
    const key = element.dataset.i18n;
    if (translations[next][key]) element.textContent = translations[next][key];
  });
  languageButton.textContent = next === "ar" ? "English" : "العربية";
  if (!selectedFile) fileName.textContent = t("noFile");
  if (!selectedFile) status.textContent = t("selectStart");
}
languageButton.addEventListener("click", () => setLanguage(language === "en" ? "ar" : "en"));

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
    status.textContent = t("invalid");
    return;
  }
  selectedFile = file;
  fileName.textContent = file.name + " · " + (file.size / 1024 / 1024).toFixed(2) + " MB";
  convertButton.disabled = false;
  result.hidden = true;
  status.textContent = t("ready");
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
  status.textContent = t("opening");
  try {
    const bytes = new Uint8Array(await selectedFile.arrayBuffer());
    const pdf = await pdfjsLib.getDocument({ data: bytes }).promise;
    const paragraphs = [];
    for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber += 1) {
      status.textContent = t("reading").replace("{page}", pageNumber).replace("{total}", pdf.numPages);
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
    if (!paragraphs.length) throw new Error(t("noText"));
    status.textContent = t("building");
    const doc = new Document({ sections: [{ properties: {}, children: paragraphs }] });
    const blob = await Packer.toBlob(doc);
    const url = URL.createObjectURL(blob);
    const outputName = selectedFile.name.replace(/\.pdf$/i, "") + ".docx";
    const link = document.createElement("a");
    link.href = url;
    link.download = outputName;
    document.body.appendChild(link);
    link.click();
    link.remove();
    result.textContent = t("complete").replace("{name}", outputName);
    result.hidden = false;
    status.textContent = t("finished").replace("{count}", pdf.numPages);
    setTimeout(() => URL.revokeObjectURL(url), 30000);
  } catch (error) {
    status.textContent = error?.message || t("failed");
  } finally {
    convertButton.disabled = false;
  }
}
convertButton.addEventListener("click", convert);
