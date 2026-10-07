#!/bin/bash


PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo "=== Packaging ${PROJECT_NAME} for Linux ==="œ

rm -rf "$PROJECT_DIR/Distribution/AppDir"

mkdir -p "$PROJECT_DIR/Distribution/AppDir/usr/bin"

echo "=== Copying Vircon32 emulator ==="

cp -a /usr/local/Vircon32/Emulator/. \
      "$PROJECT_DIR/Distribution/AppDir/usr/bin/"

cp "$PROJECT_DIR/build/${PROJECT_NAME}.v32" \
   "$PROJECT_DIR/Distribution/AppDir/usr/bin/"

echo "=== Creating AppRun ==="

cat > "$PROJECT_DIR/Distribution/AppDir/AppRun" << EOF
#!/bin/bash

APPDIR="\$(dirname "\$(readlink -f "\$0")")"

DATA_DIR="\$(dirname "\${APPIMAGE:-\$APPDIR/../..}")/${PROJECT_NAME}-Data"
RUNTIME_DIR="\$(mktemp -d)"

cp -a "\$APPDIR/usr/bin/." "\$RUNTIME_DIR/"

mkdir -p "\$RUNTIME_DIR/Cards"

if [ -f "\$DATA_DIR/Cards/${PROJECT_NAME}.memc" ]; then
    cp "\$DATA_DIR/Cards/${PROJECT_NAME}.memc" "\$RUNTIME_DIR/Cards/"
fi

cd "\$RUNTIME_DIR"

./Vircon32 ${PROJECT_NAME}.v32

if [ -f "\$RUNTIME_DIR/Cards/${PROJECT_NAME}.memc" ]; then
    mkdir -p "\$DATA_DIR/Cards"
    cp "\$RUNTIME_DIR/Cards/${PROJECT_NAME}.memc" "\$DATA_DIR/Cards/"
fi

rm -rf "\$RUNTIME_DIR"
EOF

chmod +x "$PROJECT_DIR/Distribution/AppDir/AppRun"

echo "=== Creating desktop file ==="

mkdir -p "$PROJECT_DIR/Distribution/AppDir/usr/share/applications"

cat > "$PROJECT_DIR/Distribution/AppDir/${PROJECT_NAME}.desktop" << EOF
[Desktop Entry]
Name=${PROJECT_NAME}
Comment=${PROJECT_NAME} - Vircon32 game
Exec=AppRun
Icon=${PROJECT_NAME}
Type=Application
Categories=Game;
EOF

cp "$PROJECT_DIR/Distribution/AppDir/${PROJECT_NAME}.desktop" \
   "$PROJECT_DIR/Distribution/AppDir/usr/share/applications/"

echo "=== Copying icon ==="

cp "$PROJECT_DIR/Assets/icone.png" \
   "$PROJECT_DIR/Distribution/AppDir/${PROJECT_NAME}.png"

echo "=== Building AppImage ==="

APPIMAGETOOL="$HOME/Téléchargements/appimagetool-x86_64.AppImage"

chmod +x "$APPIMAGETOOL"

"$APPIMAGETOOL" \
    "$PROJECT_DIR/Distribution/AppDir" \
    "$PROJECT_DIR/Distribution/${PROJECT_NAME}-x86_64.AppImage"

echo "=== AppImage created ==="
echo "Output: Distribution/${PROJECT_NAME}-x86_64.AppImage"

