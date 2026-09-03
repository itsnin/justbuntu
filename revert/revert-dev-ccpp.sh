#!/bin/bash
# Uninstall C/C++ build tools
sudo apt-get purge -y build-essential gcc g++ clang clangd clang-format clang-tidy make cmake ninja-build gdb pkg-config valgrind llvm
sudo apt-get autoremove -y --purge
