Write-Host "=== Flutter Clean & Build Script ===" -ForegroundColor Green

# Hapus semua build artifacts
Write-Host "Removing build artifacts..." -ForegroundColor Yellow
$foldersToRemove = @("build", "android/build", "android/app/build", ".dart_tool", ".flutter-plugins", ".flutter-plugins-dependencies")
foreach ($folder in $foldersToRemove) {
    if (Test-Path $folder) {
        Remove-Item -Recurse -Force $folder -ErrorAction SilentlyContinue
        Write-Host "Removed: $folder" -ForegroundColor Cyan
    }
}

# Install ulang dependencies
Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

# Build Android khusus
Write-Host "Running Android gradle clean..." -ForegroundColor Yellow
Set-Location android
./gradlew clean
./gradlew --stop
Set-Location ..

# Build Flutter
# Write-Host "Building Flutter APK..." -ForegroundColor Yellow
# flutter build apk --debug --verbose

Write-Host "=== Script Completed ===" -ForegroundColor Green