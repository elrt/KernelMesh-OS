# KernelMesh OS
![alt text](https://github.com/elrt/KernelMesh/blob/77b18c942fd4dc2790dd29bf329b1b3c8a81314e/screenshots/photo_5336883528757015899_x.jpg)

A simple operating system with a basic file system(FAT12) and command shell.

## Features

- 16-bit bootloader
- Basic kernel with file system support
- Command shell with file operations
- Support for up to 32 files
- File creation, reading, writing, and deletion

```
kernelmesh-os/
├── bin/               # Compiled binaries
├── disk/              # Disk images
├── screenshots/       # OS screenshots
├── boot.asm           # Bootloader source
├── kernel.asm         # Kernel source
├── shell.asm          # Shell source
└── build.sh           # Build script
```

![alt text](https://github.com/elrt/KernelMesh/blob/a0374b911a9fa2c7caaeae149695b3ca6f9ede86/screenshots/photo_5336883528757015858_x.jpg)

## Building and Running

### Requirements
- NASM
- QEMU
- Linux or WSL (Windows Subsystem for Linux)

### Build Instructions
```bash
# Clone the repository
git clone https://github.com/elrt/KernelMesh
cd kernelmesh-os

# Make build script executable
chmod +x build.sh

# Build the OS
./build.sh
```

### Run in QEMU
```bash
qemu-system-x86_64 -drive format=raw,file=disk/kernelmesh.img
```

## Shell Commands
- `help` - Show available commands
- `clear` - Clear the screen
- `dir` - List files
- `create <name>` - Create empty file
- `write <name> <text>` - Create/update file
- `read <name>` - Read file contents
- `del <name>` - Delete file
- `reboot` - Reboot system

