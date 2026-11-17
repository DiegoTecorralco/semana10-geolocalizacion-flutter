$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter no esta en PATH. Ejecuta flutter doctor.'
}
flutter create --project-name semana10_osm --platforms android,ios --no-pub .
if ($LASTEXITCODE -ne 0) { throw 'Fallo flutter create' }
$manifestFile = 'android/app/src/main/AndroidManifest.xml'
$manifest = Get-Content $manifestFile -Raw
if ($manifest -notmatch 'android.permission.ACCESS_FINE_LOCATION') {
  $permissions = @'
<uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <application
'@
  $manifest = $manifest.Replace('<application', $permissions)
}
Set-Content $manifestFile $manifest -Encoding utf8
$plistFile = 'ios/Runner/Info.plist'
$plist = Get-Content $plistFile -Raw
if ($plist -notmatch 'NSLocationWhenInUseUsageDescription') {
  $privacy = @'
<dict>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Usamos tu ubicacion para mostrarte en el mapa y calcular distancias.</string>
'@
  $plist = $plist.Replace('<dict>', $privacy)
}
Set-Content $plistFile $plist -Encoding utf8
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Fallo flutter pub get' }
Write-Host 'Listo. Inicia Android Studio y ejecuta flutter run.'
