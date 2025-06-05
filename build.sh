#!/bin/bash

mkdir -p bin disk

echo "Compiling bootloader..."
nasm -f bin boot.asm -o bin/boot.bin || exit 1

echo "Compiling kernel..."
nasm -f bin kernel.asm -o bin/kernel.bin || exit 1

echo "Creating disk image..."
dd if=/dev/zero of=disk/kernelmesh.img bs=512 count=2880 || exit 1

echo "Writing bootloader..."
dd if=bin/boot.bin of=disk/kernelmesh.img conv=notrunc || exit 1

echo "Writing kernel..."
dd if=bin/kernel.bin of=disk/kernelmesh.img seek=1 conv=notrunc || exit 1

echo "Build successful!"
echo "Binary files: bin/boot.bin, bin/kernel.bin"
echo "Disk image: disk/kernelmesh.img"
echo "To run: qemu-system-x86_64 -drive format=raw,file=disk/kernelmesh.img"
