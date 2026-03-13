$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "HH:mm:ss"
    Write-Host "`n[$ts] $Message"
}

$actualOS = $env:OS
if ($actualOS -notlike "*Windows*") {
    Write-Error "Este script so pode ser executado em Windows."
}

Write-Log "A ativar plataforma Windows desktop..."
flutter config --enable-windows-desktop

Write-Log "A validar ambiente Flutter..."
flutter doctor -v

Write-Log "A instalar dependencias do projeto..."
flutter pub get

Write-Log "A correr validacoes rapidas..."
flutter analyze
flutter test test/backup_service_e2e_test.dart

Write-Log "A gerar build Windows release..."
flutter build windows --release

Write-Log "Builds concluidos. Artefatos principais:"
Write-Host "- Windows: build\windows\x64\runner\Release\"