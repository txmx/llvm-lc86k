# Install script for directory: C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/tools/llvm-objcopy

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/install/x64-Debug")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-objcopyx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/bin/llvm-objcopy.exe")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-install-name-toolx" OR NOT CMAKE_INSTALL_COMPONENT)
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/cmake/modules/LLVMInstallSymlink.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-install-name-toolx" OR NOT CMAKE_INSTALL_COMPONENT)
  install_symlink("llvm-install-name-tool.exe" "llvm-objcopy.exe" "bin" "copy")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-bitcode-stripx" OR NOT CMAKE_INSTALL_COMPONENT)
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/cmake/modules/LLVMInstallSymlink.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-bitcode-stripx" OR NOT CMAKE_INSTALL_COMPONENT)
  install_symlink("llvm-bitcode-strip.exe" "llvm-objcopy.exe" "bin" "copy")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-stripx" OR NOT CMAKE_INSTALL_COMPONENT)
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/cmake/modules/LLVMInstallSymlink.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xllvm-stripx" OR NOT CMAKE_INSTALL_COMPONENT)
  install_symlink("llvm-strip.exe" "llvm-objcopy.exe" "bin" "copy")
endif()

