#!/bin/bash
echo "=== Flutter Clean & Build Script ==="

# Hapus semua build artifacts
echo "Removing build artifacts..."
rm -rf build/
rm -rf android/build/
rm -rf android/app/build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Install ulang dependencies
echo "Running flutter clean..."
flutter clean

echo "Running flutter pub get..."
flutter pub get

# Build Android khusus
echo "Running Android gradle clean..."
cd android
./gradlew clean
./gradlew --stop
cd ..

# Build Flutter
# echo "Building Flutter APK..."
# flutter build apk --debug --verbose

echo "=== Script Completed ==="