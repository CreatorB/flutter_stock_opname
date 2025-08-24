بِسْــــــــــــــــــمِ اللهِ الرَّحْمَنِ الرَّحِيْمِ

# 📱 Flutter Stock Opname

![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue) ![Dart](https://img.shields.io/badge/Dart-3.2.0-blue) ![Laravel](https://img.shields.io/badge/Laravel-8-red)

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

### Multi-language

```sh
fvm flutter clean
fvm flutter pub get
fvm flutter pub run easy_localization:generate -S assets/translations -O lib -f keys -o locale_keys.g.dart
```

---

## 📝 License

This project is licensed under the **MIT** license.

If you need further customization, let me know! 🚀

[Hasan B](https://wa.me/6289619060672) / [CreatorB](https://github.com/CreatorB)