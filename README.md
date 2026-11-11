# Redro PDF Converter

Redro PDF is a Flutter app for Android and Windows. The current source includes a selectable-text highlighter with color choices and a Save Copy path for PDF annotations. It is not yet the full text-and-image editor or Office converter requested by the owner.

## Current build downloads

Fresh build-only artifacts were produced from source commit `82deb04`. Android and Windows builds succeeded; analyzer/tests and the Windows launch smoke check were skipped, as requested. These are Actions artifacts, not a published GitHub Release, and GitHub retains them for 30 days.

| Platform | Artifact filename | Size |
|---|---|---:|
| Android arm64 (most current phones) | `app-arm64-v8a-release.apk` | 21,944,651 bytes |
| Android 32-bit ARM | `app-armeabi-v7a-release.apk` | 19,904,675 bytes |
| Android x86_64 | `app-x86_64-release.apk` | 23,583,573 bytes |
| Windows | `redro-pdf-windows-portable.zip` | 16,903,428 bytes |

Download the split APKs from the [Android build run](https://github.com/mhamedshasho/redro-tools/actions/runs/43092534621) and the portable ZIP from the [Windows build run](https://github.com/mhamedshasho/redro-tools/actions/runs/43092540575). Extract the Windows ZIP and keep the executable, DLLs, and `data/` directory together.

## Current source features

The app opens local PDFs in multiple tabs, navigates pages, and provides highlighter mode with four colors. **Save Copy** serializes the PDF viewer's annotation bytes to a separate file. The source also contains page rotation, the supplied Redro logo, English/Arabic interface labels with LTR/RTL UI direction, and light/dark appearance. The owner will test PDF behavior; no PDF feature tests or app launch checks were run for this build.

## Still to implement

Editing existing PDF text in place; adding, moving, replacing, and deleting embedded image objects; editable Word and Excel conversion; Arabic/multilingual OCR; and stable app update signing remain outstanding. The selected Syncfusion viewer is commercial software; confirm Community License eligibility or arrange another valid license before distribution. See [`docs/EDITOR_REQUIREMENTS.md`](docs/EDITOR_REQUIREMENTS.md) and [`docs/EDITOR_TECHNICAL_DECISIONS.md`](docs/EDITOR_TECHNICAL_DECISIONS.md).

## Build locally

From `mobile/`, install Flutter stable and the target platform toolchain, then run:

```sh
flutter pub get
flutter build apk --release --split-per-abi
flutter build windows --release
```

The Android application ID is `com.redro.redro_pdf`, and the current package version is `0.2.0+2`. To update an existing installation, keep the application ID, use a signing certificate compatible with the installed app, and increase the version code. These CI APKs use a temporary debug-signing identity; they may not update a separately signed installation. A persistent release key is not configured. Windows is distributed as a portable ZIP; there is no installer/updater.
