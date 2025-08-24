@echo off
echo === Flutter Clean & Build Script ===

REM Hapus semua build artifacts
echo Removing build artifacts...
rmdir /s /q build 2>nul
rmdir /s /q android\build 2>nul
rmdir /s /q android\app\build 2>nul
rmdir /s /q .dart_tool 2>nul
del .flutter-plugins 2>nul
del .flutter-plugins-dependencies 2>nul

REM Install ulang dependencies
echo Running flutter clean...
flutter clean

echo Running flutter pub get...
flutter pub get

REM Build Android khusus
echo Running Android gradle clean...
cd android
call gradlew clean
call gradlew --stop
cd ..

REM Build Flutter
REM echo Building Flutter APK...
REM flutter build apk --debug --verbose

echo === Script Completed ===
pause