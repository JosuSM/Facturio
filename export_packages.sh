#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
DIST_ROOT="$PROJECT_DIR/dist/$TS"
APP_NAME="Facturio"

mkdir -p "$DIST_ROOT"/{android,web,linux,windows,macos,ios}

log() {
  printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$1"
}

skip_platform() {
  local platform="$1"
  local reason="$2"
  cat >"$DIST_ROOT/$platform/SKIPPED.txt" <<EOF
Plataforma: $platform
Motivo: $reason
Data: $(date)
EOF
}

log "A preparar dependências..."
flutter pub get

log "A gerar Android APK (release)..."
flutter build apk --release
cp "build/app/outputs/flutter-apk/app-release.apk" "$DIST_ROOT/android/${APP_NAME}.apk"

log "A gerar Android App Bundle (AAB, release)..."
flutter build appbundle --release
cp "build/app/outputs/bundle/release/app-release.aab" "$DIST_ROOT/android/${APP_NAME}.aab"

log "A gerar Web (release)..."
flutter build web --release
cp -R build/web/. "$DIST_ROOT/web/"
(
  cd "$DIST_ROOT/web"
  zip -qr "../${APP_NAME}-web.zip" .
)

log "A gerar Linux (release)..."
if flutter build linux --release; then
  cp -R build/linux/x64/release/bundle/. "$DIST_ROOT/linux/"
  (
    cd "$DIST_ROOT/linux"
    tar -czf "../${APP_NAME}-linux.tar.gz" .
  )
else
  skip_platform "linux" "Build Linux indisponível neste ambiente."
fi

skip_platform "windows" "Build Windows requer ambiente Windows."
skip_platform "macos" "Build macOS requer ambiente macOS."
skip_platform "ios" "Build iOS requer macOS/Xcode."

log "Pacotes exportados com sucesso para: $DIST_ROOT"
log "Resumo:"
find "$DIST_ROOT" -maxdepth 2 -type f | sort
