# Install script for directory: C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/examples

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

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/BrainF/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/Fibonacci/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/HowToUseJIT/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/HowToUseLLJIT/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/IRTransforms/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/Kaleidoscope/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/ModuleMaker/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/OrcV2Examples/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/SpeculativeJIT/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/txmxc/Documents/moms/lc86k-llvm/llvm-project/llvm/out/build/x64-Debug/examples/Bye/cmake_install.cmake")
endif()

