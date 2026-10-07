#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo "=== Building ${PROJECT_NAME} ==="

# -----------------------------------------------------------------------------
# Prepare build directory
# -----------------------------------------------------------------------------

rm -rf "$PROJECT_DIR/build"
mkdir -p "$PROJECT_DIR/build"

# -----------------------------------------------------------------------------
# Compile C to assembly
# -----------------------------------------------------------------------------

echo "=== Compiling C code ==="

/usr/local/Vircon32/DevTools/compile \
    "$PROJECT_DIR/source/main.c" \
    -o "$PROJECT_DIR/build/${PROJECT_NAME}.asm"

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# -----------------------------------------------------------------------------
# Assemble
# -----------------------------------------------------------------------------

echo "=== Assembling ==="

/usr/local/Vircon32/DevTools/assemble \
    "$PROJECT_DIR/build/${PROJECT_NAME}.asm" \
    -o "$PROJECT_DIR/build/${PROJECT_NAME}.vbin"

if [ $? -ne 0 ]; then
    echo "Assembly failed."
    exit 1
fi

# -----------------------------------------------------------------------------
# Convert PNG textures
# -----------------------------------------------------------------------------

echo "=== Converting textures ==="

for file in "$PROJECT_DIR/Assets/"*.png; do
    [ -e "$file" ] || continue

    filename="$(basename "$file" .png)"

    /usr/local/Vircon32/DevTools/png2vircon \
        "$file" \
        -o "$PROJECT_DIR/build/${filename}.vtex"

    if [ $? -ne 0 ]; then
        echo "Texture conversion failed."
        exit 1
    fi
done

# -----------------------------------------------------------------------------
# Convert WAV sounds
# -----------------------------------------------------------------------------

echo "=== Converting sounds ==="

for file in "$PROJECT_DIR/Assets/"*.wav; do
    [ -e "$file" ] || continue

    filename="$(basename "$file" .wav)"

    /usr/local/Vircon32/DevTools/wav2vircon \
        "$file" \
        -o "$PROJECT_DIR/build/${filename}.vsnd"

    if [ $? -ne 0 ]; then
        echo "Sound conversion failed."
        exit 1
    fi
done

# -----------------------------------------------------------------------------
# Generate ROM definition
# -----------------------------------------------------------------------------

echo "=== Generating ROM definition ==="

ROM_XML="$PROJECT_DIR/build/rom.xml"

cat > "$ROM_XML" << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<rom-definition version="1.0">
    <rom type="cartridge" title="${PROJECT_NAME}" version="1.0" />
    <binary path="${PROJECT_NAME}.vbin" />
    <textures>
EOF

for file in "$PROJECT_DIR/build/"*.vtex; do
    [ -e "$file" ] || continue

    filename="$(basename "$file")"

    echo "        <texture path=\"${filename}\" />" >> "$ROM_XML"
done

cat >> "$ROM_XML" << EOF
    </textures>
    <sounds>
EOF

for file in "$PROJECT_DIR/build/"*.vsnd; do
    [ -e "$file" ] || continue

    filename="$(basename "$file")"

    echo "        <sound path=\"${filename}\" />" >> "$ROM_XML"
done

cat >> "$ROM_XML" << EOF
    </sounds>
</rom-definition>
EOF

# -----------------------------------------------------------------------------
# Pack ROM
# -----------------------------------------------------------------------------

echo "=== Packing ROM ==="

/usr/local/Vircon32/DevTools/packrom \
    "$ROM_XML" \
    -o "$PROJECT_DIR/build/${PROJECT_NAME}.v32"

if [ $? -ne 0 ]; then
    echo "ROM packing failed."
    exit 1
fi

# -----------------------------------------------------------------------------
# Build successful
# -----------------------------------------------------------------------------

echo "=== Build successful ==="
echo "Output: build/${PROJECT_NAME}.v32"

# -----------------------------------------------------------------------------
# Start emulator
# -----------------------------------------------------------------------------

echo "=== Starting Vircon32 ==="

/usr/local/Vircon32/Emulator/Vircon32 \
    "$PROJECT_DIR/build/${PROJECT_NAME}.v32"

