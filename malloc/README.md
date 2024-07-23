# GET Hard 
### a rhino pill for your computer
----- 
# Malloc scripts
## Overview

This repository contains two scripts designed to enhance the security of memory allocation on Arch Linux systems:

1. **`securemalloc.sh`**: Installs and configures `jemalloc`, a hardened memory allocator.
2. **`install_asan.sh`**: Installs AddressSanitizer (ASan), a tool for detecting memory errors.

## What the Scripts Do

### `securemalloc.sh`

- **Checks ASLR Status**: Ensures that Address Space Layout Randomization (ASLR) is enabled, which randomizes memory locations and enhances security.
- **Installs `jemalloc`**: If not already installed, this script installs `jemalloc`, a memory allocator with additional security features.
- **Configures `jemalloc`**: Sets up `jemalloc` to use guard pages and purge freed memory. These features help prevent and detect buffer overflows and memory corruption.

**results**:
- **`jemalloc`** is installed and configured with security features.
- **ASLR** is checked to ensure memory randomization is in place.

### `install_asan.sh`

- **Installs AddressSanitizer**: Adds AddressSanitizer (ASan) to the system, which is a tool for detecting various memory corruption issues during the development phase.

**results**:
- **AddressSanitizer** is installed.
- **Instructions** are provided for compiling programs with ASan to detect memory errors.



### Changes

1. **Enhanced Security**:
   - **ASLR**: Helps make memory layout unpredictable, making attacks like BufferOverflow, Heap Spraying, and ROP more difficult.
   - **`jemalloc`**: Provides a hardened memory allocator with features like guard pages and memory purging to prevent memory corruption.
   - **AddressSanitizer**: Detects various types of memory errors (e.g., buffer overflows, use-after-free) during development.


### Notes

1. **Performance Overhead**:
   - **`jemalloc`**: Might introduce some performance overhead due to security features like guard pages and memory purging.
   - **AddressSanitizer**: Can significantly slow down applications, making it more suitable for development and testing rather than production.

2. **Compatibility Issues**:
   - **LD_PRELOAD**: Using `jemalloc` via `LD_PRELOAD` may cause compatibility issues with certain applications that expect the default allocator.
   - **AddressSanitizer**: Requires recompiling applications with specific flags, which may not be feasible for all software.
---


