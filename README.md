# بِسْــــــــــــــــــمِ اللهِ الرَّحْمَنِ الرَّحِيْمِ

## 📱 Flutter Stock Opname

![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue) ![Dart](https://img.shields.io/badge/Dart-3.2.0-blue) ![Laravel](https://img.shields.io/badge/Laravel-8-red)

## 📥 Download Demo
[Download APK Demo](https://github.com/CreatorB/flutter_stock_opname/raw/refs/heads/dev/showcase/mobile-store-release.apk)

Try to build a simple app that can be used to manage stocks by rebasing

## 🚀 Installation & Setup

### 1️⃣ Prerequisites

Ensure you have installed:

- Flutter SDK → [Download Flutter](https://fvmflutter.dev/docs/get-started/install)
- Android Studio / VS Code
- Emulator or physical device

### 2️⃣ Clone the Repository

```bash
git clone {repository_url}
cd {repository_name}
```

### 3️⃣ Install Dependencies

```bash
fvm flutter pub get
```

### 4️⃣ Run the Application

```bash
fvm flutter run
```

To run on a specific platform:

```bash
fvm flutter run -d android
fvm flutter run -d ios
fvm flutter run -d web
```

If you use fvm you can also debug by combine it commands

```sh
fvm flutter clean ; fvm flutter pub get ; fvm flutter run -d 127.0.0.1:5555 -v
```

You can also build apk by combine it fvm commands

```sh
fvm flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abi
```

## 🏗️ Project Structure

Combined Structure | BLoC and Cubit

## 📦 Build APK / iOS

To generate a **AAB (Android App Bundle)**:

```bash
fvm flutter build appbundle
```

To generate a **APKS (for Android Testing)**:

- FVM (Flutter Version Management) / Split APK by structure

```bash
fvm flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abifvm fvm flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abi
```

- [Bundletool](https://developer.android.com/studio/command-line/bundletool) (rename .apks to .zip and extract universal.apk from it)

```bash
java -jar D:\IT\HSN\Developments\sdk\bundletool-all-1.18.0.jar build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app-release.apks --mode=universal --ks=D:\IT\HSN\Developments\android\keystrok\creatorbe-bundle.jks --ks-key-alias=xxx --ks-pass=pass:xxx --key-pass=pass:xxx
```

To generate a **release APK**:

```bash
fvm flutter build apk
```

For **iOS (macOS required)**:

```bash
fvm flutter build ios
```

## Misscellaneous

### New Features (Task 0002)

#### Sale Feature
- Navigate to **PENJUALAN** menu from dashboard
- Supports **retail** and **grosir** price modes
- Price area selection (1, 2, 3) for retail
- Manual price input for grosir mode
- Cart management with quantity controls
- Payment via Cash or EDC

#### Stock Opname Feature
- Access via **OPNAME** menu after completing a sale
- Scanner integration for barcode input
- Real-time stock difference calculation

#### Workflow Rules
- **Sale must be completed before Stock Opname access** - A dialog will prompt if user attempts to access Opname without completing a sale first
- The sale completion flag resets when the app is closed

### Multi-language

```sh
fvm flutter clean
fvm flutter pub get
fvm flutter pub run easy_localization:generate -S assets/translations -O lib -f keys -o locale_keys.g.dart
```

Import locale_keys.g.dart to your class

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
```

Use it in your widget

```dart
Text('app_name'.tr()),
```

or

```dart
Text(LocaleKeys.app_name.tr()),
```

### Dart Utility

```sh
dart analyze
dart analyze --fatal-infos

dart fix --apply
dart fix --dry-run

dart fix --help
dart fix --apply --code=unused_import
dart fix --apply --code=unused_local_variable
dart fix --apply lib/main.dart
dart fix --apply lib/main.dart lib/utils.dart
```

settings.json

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true,
    "source.removeUnusedImports": true
  },
  "dart.autoImportCompletions": true,
  "dart.previewLsp": true
}
```

---

## 📝 License

This project is licensed under the **MIT** license.

If you need further customization, let me know! 🚀

[Hasan B](https://wa.me/6289619060672) / [CreatorB](https://github.com/CreatorB)