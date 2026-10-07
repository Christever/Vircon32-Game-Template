#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo "=== Building ${PROJECT_NAME} ==="

rm -rf "$PROJECT_DIR/build"
mkdir -p "$PROJECT_DIR/build"

# Compile C to assembly
/usr/local/Vircon32/DevTools/compile \
    "$PROJECT_DIR/source/main.c" \
    -o "$PROJECT_DIR/build/${PROJECT_NAME}.asm"

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Assemble
/usr/local/Vircon32/DevTools/assemble \
    "$PROJECT_DIR/build/${PROJECT_NAME}.asm" \
    -o "$PROJECT_DIR/build/${PROJECT_NAME}.vbin"

if [ $? -ne 0 ]; then
    echo "Assembly failed."
    exit 1
fi

# Generate ROM definition
sed "s/PROJECT_NAME/${PROJECT_NAME}/g" \
    "$PROJECT_DIR/rom.xml" \
    > "$PROJECT_DIR/build/rom.xml"

# Pack ROM
/usr/local/Vircon32/DevTools/packrom \
    "$PROJECT_DIR/build/rom.xml" \
    -o "$PROJECT_DIR/build/${PROJECT_NAME}.v32"

if [ $? -ne 0 ]; then
    echo "ROM packing failed."
    exit 1
fi

echo "=== Build successful ==="
echo "Output: build/${PROJECT_NAME}.v32"

echo "=== Starting Vircon32 ==="
/usr/local/Vircon32/Emulator/Vircon32 \
    "$PROJECT_DIR/build/${PROJECT_NAME}.v32"
