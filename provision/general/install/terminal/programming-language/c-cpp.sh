#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"C/C++"* ]]; then
  return 0
fi
echo "==> Installing C/C++ build tools..."
sudo apt-get install -y build-essential gcc g++ clang clangd clang-format clang-tidy make cmake ninja-build gdb pkg-config valgrind llvm
