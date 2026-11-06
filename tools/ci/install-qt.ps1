# SPDX-FileCopyrightText: 2026 WIN Infinite Desktop contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Installs Qt for MSVC from the official online repository (download.qt.io) for CI and the
# release build. From Qt 6.11 on the repository keeps one folder per architecture
# (qt6_<ver>/qt6_<ver>_<arch>/), which aqtinstall 3.3 does not read yet.
#
# Downloads the archives of the main package (qtbase, qtdeclarative, qtsvg, qttools,
# qttranslations), checks each against the SHA-1 the repository publishes, unpacks them and
# exports QT_ROOT_DIR, Qt6_DIR, CMAKE_PREFIX_PATH and PATH for the following steps.
#
# Usage: pwsh tools/ci/install-qt.ps1 -Version 6.11.3 [-Arch msvc2022_64] [-Output D:\Qt]

param(
    [Parameter(Mandatory = $true)][string]$Version,
    [string]$Arch = "msvc2022_64",
    [string]$Output = (Join-Path ($env:RUNNER_TEMP ?? $env:TEMP) "Qt")
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$compact = $Version -replace '\.', ''
$base = "https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt6_$compact/qt6_${compact}_$Arch"
$package = "qt.qt6.$compact.win64_$Arch"
$root = Join-Path $Output "$Version\$Arch"
$skip = @('^qtdoc-', '^opengl32sw-')

if (Test-Path (Join-Path $root "bin\Qt6Core.dll")) {
    Write-Host "Qt $Version ($Arch) is already in $root"
} else {
    $updates = [xml](Invoke-WebRequest -UseBasicParsing -Uri "$base/Updates.xml").Content
    $entry = $updates.Updates.PackageUpdate | Where-Object { $_.Name -eq $package } | Select-Object -First 1
    if (-not $entry) { throw "$package is not in $base/Updates.xml" }
    $archives = $entry.DownloadableArchives -split ',\s*' | Where-Object {
        $name = $_
        $_ -and -not ($skip | Where-Object { $name -match $_ })
    }
    $sevenZip = (Get-Command 7z -ErrorAction SilentlyContinue).Source
    if (-not $sevenZip) { $sevenZip = "C:\Program Files\7-Zip\7z.exe" }

    New-Item -ItemType Directory -Force $root | Out-Null
    $download = Join-Path ($env:RUNNER_TEMP ?? $env:TEMP) "qt-download"
    New-Item -ItemType Directory -Force $download | Out-Null
    foreach ($archive in $archives) {
        $url = "$base/$package/$($entry.Version)$archive"
        $file = Join-Path $download $archive
        Write-Host "Downloading $archive"
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $file
        # The .sha1 files come as application/octet-stream: read them from disk as text.
        Invoke-WebRequest -UseBasicParsing -Uri "$url.sha1" -OutFile "$file.sha1"
        $expected = ((Get-Content -Raw "$file.sha1").Trim() -split '\s+')[0]
        Remove-Item "$file.sha1"
        $actual = (Get-FileHash -Algorithm SHA1 $file).Hash
        if ($actual -ine $expected) { throw "SHA-1 of $archive is $actual, the repository says $expected" }
        & $sevenZip x -y -bso0 -bsp0 "-o$root" $file
        if ($LASTEXITCODE -ne 0) { throw "unpacking $archive failed" }
        Remove-Item $file
    }
    # Paths relative to bin\, so qtpaths and windeployqt find plugins and QML modules here.
    Set-Content -Path (Join-Path $root "bin\qt.conf") -Value "[Paths]`nPrefix=.." -Encoding ascii
}

$exports = @{
    QT_ROOT_DIR = $root
    Qt6_DIR = Join-Path $root "lib\cmake\Qt6"
    CMAKE_PREFIX_PATH = $root
    QT_PLUGIN_PATH = Join-Path $root "plugins"
    QML2_IMPORT_PATH = Join-Path $root "qml"
}
foreach ($name in $exports.Keys) {
    Set-Item -Path "env:$name" -Value $exports[$name]
    if ($env:GITHUB_ENV) { Add-Content -Path $env:GITHUB_ENV -Value "$name=$($exports[$name])" }
}
if ($env:GITHUB_PATH) { Add-Content -Path $env:GITHUB_PATH -Value (Join-Path $root "bin") }
Write-Host "Qt $Version ($Arch) in $root"
