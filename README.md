# Redro PDF

Redro PDF is an offline-first Flutter application foundation for reading local PDF files on Android and Windows. This branch delivers a reader milestone, not the full editor/converter described by the long-term project name.

## Implemented

- Open a local PDF using the platform file picker; validate that the selected path exists and is non-empty before parsing.
- Keep multiple PDFs open in tabs, switch among them, and close a tab without changing the source file.
- Navigate pages using previous/next controls or a page number.
- Pinch-to-zoom on Android. Windows uses the standard `pdfx` page viewer because its pinch viewer is not supported there.
- Switch English/Arabic interface labels and LTR/RTL direction, plus light/dark appearance.
- Process files locally; the app has no account, upload, or cloud-storage flow.

PDF editing/saving is not implemented. Highlights, annotations, text selection, signatures, page operations, merge/split, PDF-to-DOCX/XLSX, OCR, in-app updates, and persisted preferences are not available. No controls claim to perform these actions.

## Install from CI artifacts

Download the `redro-pdf-android-release-split` artifact from the successful [Android Actions run](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853686). Extract the artifact and install **one** APK that matches the device:

| APK | CI size | Use |
|---|---:|---|
| `app-arm64-v8a-release.apk` | 17,062,271 bytes (about 17.1 MB) | Most current Android phones/tablets |
| `app-armeabi-v7a-release.apk` | 14,416,087 bytes (about 14.4 MB) | 32-bit ARM devices |
| `app-x86_64-release.apk` | 18,570,121 bytes (about 18.6 MB) | x86_64 devices/emulators |

Copy the chosen APK to the device if needed, open it, and approve Android's install prompt. These are optimized release-mode builds, but CI signs them with an ephemeral debug key. They are not a stable update channel; installing a later build over an earlier one may require uninstalling the earlier build first. The artifact is retained by GitHub Actions for 30 days.

For Windows, download `redro-pdf-windows-portable.zip` from the successful [Windows Actions run](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853344), extract the entire archive, and launch `redro_pdf.exe`. Keep the DLLs and `data/` folder beside the executable. There is no installer or setup wizard. If Windows reports a missing Visual C++ runtime, install the Microsoft Visual C++ 2015–2022 Redistributable for x64.

## Build, test, and CI

Install Flutter stable and the Android SDK or Windows desktop toolchain. From `mobile/`, run:

```sh
flutter pub get
flutter analyze
flutter test
```

Android CI runs `flutter build apk --release --split-per-abi`, checks that all three APKs are below 100 MB, and uploads them as one artifact. The successful Android and Windows workflows for commit `5df7186` are [Android](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853686) and [Windows](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853344). Windows CI also checks the portable ZIP and starts the packaged executable for a five-second smoke test.

The Android application ID is `com.redro.redro_pdf` and the launcher label is `Redro PDF`. Do not change the application ID for a compatible upgrade. No stable Android signing key or versioned GitHub Release has been configured.

## Verification limits

Widget tests cover the start screen, language/direction switching, and light/dark switching; they do not open a real PDF. The Windows startup smoke test ran on GitHub's hosted runner, not a separate end-user machine. No Android-device installation, real-PDF viewing, Arabic/mixed-script document, large/encrypted/damaged/scanned PDF, save/reopen, or memory test has been completed. The app has not been network-monitored or independently privacy-audited; local processing does not imply encryption at rest or secure deletion.

See [`docs/MVP_ACCEPTANCE_CHECKLIST.md`](docs/MVP_ACCEPTANCE_CHECKLIST.md) for implemented and outstanding work.
