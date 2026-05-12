# Script setup development untuk Miftahul Ulum mobile
# Jalankan setiap habis colok USB / restart adb sebelum 'flutter run'.
# Cara pakai:
#   .\dev-setup.ps1

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adb)) {
    Write-Host "❌ ADB tidak ditemukan di $adb" -ForegroundColor Red
    Write-Host "   Cek path Android SDK Anda." -ForegroundColor Yellow
    exit 1
}

Write-Host "🔌 Cek device terkoneksi..." -ForegroundColor Cyan
$devices = & $adb devices
$devices | Write-Host

if (-not ($devices -match "device$")) {
    Write-Host "❌ Tidak ada device yang terdeteksi via USB." -ForegroundColor Red
    Write-Host "   Pastikan USB Debugging aktif & kabel terkoneksi." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔁 Setup adb reverse port forwarding..." -ForegroundColor Cyan
& $adb reverse tcp:8000 tcp:8000
& $adb reverse tcp:8080 tcp:8080

Write-Host ""
Write-Host "✅ Port forwarding aktif:" -ForegroundColor Green
& $adb reverse --list

Write-Host ""
Write-Host "📋 Reminder server yang harus running:" -ForegroundColor Cyan
Write-Host "   1. php artisan serve              (port 8000)" -ForegroundColor White
Write-Host "   2. php artisan reverb:start       (port 8080)" -ForegroundColor White
Write-Host "   3. npm run dev                    (Vite untuk web)" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Sekarang siap: flutter run" -ForegroundColor Green
