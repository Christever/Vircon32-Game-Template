#!/bin/bash

echo "=== Building HelloVircon ==="

rm -rf build
mkdir -p build

# Compile C to assembly
/usr/local/Vircon32/DevTools/compile source/main.c -o build/HelloVircon.asm

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

# Assemble
/usr/local/Vircon32/DevTools/assemble build/HelloVircon.asm -o build/HelloVircon.vbin

if [ $? -ne 0 ]; then
    echo "Assembly failed."
    exit 1
fi

# Pack ROM
/usr/local/Vircon32/DevTools/packrom rom.xml -o build/HelloVircon.v32

if [ $? -ne 0 ]; then
    echo "ROM packing failed."
    exit 1
fi

echo "=== Build successful ==="
echo "Output: build/HelloVircon.v32"


# Start 
echo "=== Starting Vircon32 ==="
/usr/local/Vircon32/Emulator/Vircon32 build/HelloVircon.v32