# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


if(CMAKE_HIP_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  set(CMAKE_HIP_COMPILER_WORKS TRUE)
  return()
endif()

set(__CMAKE_HIP_FLAGS "${CMAKE_HIP_FLAGS}")
string(APPEND CMAKE_HIP_FLAGS "--cuda-host-only")

include(CMakeTestCompilerCommon)

# work around enforced code signing and / or missing executable target type
set(__CMAKE_SAVED_TRY_COMPILE_TARGET_TYPE ${CMAKE_TRY_COMPILE_TARGET_TYPE})
if(_CMAKE_FEATURE_DETECTION_TARGET_TYPE)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE ${_CMAKE_FEATURE_DETECTION_TARGET_TYPE})
endif()

# Remove any cached result from an older CMake version.
# We now store this in CMakeHIPCompiler.cmake.
unset(CMAKE_HIP_COMPILER_WORKS CACHE)

# Try to identify the ABI and configure it into CMakeHIPCompiler.cmake
include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerABI.cmake)
CMAKE_DETERMINE_COMPILER_ABI(HIP ${CMAKE_ROOT}/Modules/CMakeHIPCompilerABI.hip)
if(CMAKE_HIP_ABI_COMPILED)
  # The compiler worked so skip dedicated test below.
  set(CMAKE_HIP_COMPILER_WORKS TRUE)
  message(STATUS "Check for working HIP compiler: ${CMAKE_HIP_COMPILER} - skipped")
endif()

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that the selected C++ compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.
if(NOT CMAKE_HIP_COMPILER_WORKS)
  PrintTestCompilerStatus("HIP")
  __TestCompiler_setTryCompileTargetType()
  file(WRITE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testHIPCompiler.hip
    "#ifndef __HIP__\n"
    "# error \"The CMAKE_HIP_COMPILER is set to a C/CXX compiler\"\n"
    "#endif\n"
    "int main(){return 0;}\n")
  # Clear result from normal variable.
  unset(CMAKE_HIP_COMPILER_WORKS)
  # Puts test result in cache variable.
  try_compile(CMAKE_HIP_COMPILER_WORKS ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testHIPCompiler.hip
    OUTPUT_VARIABLE __CMAKE_HIP_COMPILER_OUTPUT)
  # Move result from cache to normal variable.
  set(CMAKE_HIP_COMPILER_WORKS ${CMAKE_HIP_COMPILER_WORKS})
  unset(CMAKE_HIP_COMPILER_WORKS CACHE)
  __TestCompiler_restoreTryCompileTargetType()
  if(NOT CMAKE_HIP_COMPILER_WORKS)
    PrintTestCompilerResult(CHECK_FAIL "broken")
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Determining if the HIP compiler works failed with "
      "the following output:\n${__CMAKE_HIP_COMPILER_OUTPUT}\n\n")
    string(REPLACE "\n" "\n  " _output "${__CMAKE_HIP_COMPILER_OUTPUT}")
    message(FATAL_ERROR "The HIP compiler\n  \"${CMAKE_HIP_COMPILER}\"\n"
      "is not able to compile a simple test program.\nIt fails "
      "with the following output:\n  ${_output}\n\n"
      "CMake will not be able to correctly generate this project.")
  endif()
  PrintTestCompilerResult(CHECK_PASS "works")
  file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
    "Determining if the HIP compiler works passed with "
    "the following output:\n${__CMAKE_HIP_COMPILER_OUTPUT}\n\n")
endif()

set(CMAKE_HIP_FLAGS "${__CMAKE_HIP_FLAGS}")
unset(__CMAKE_HIP_FLAGS)


# Try to identify the compiler features
include(${CMAKE_ROOT}/Modules/CMakeDetermineCompileFeatures.cmake)
CMAKE_DETERMINE_COMPILE_FEATURES(HIP)


# Setup the following:
# Configure the new template file CMakeHipRuntime.cmake to
# - ${CMAKE_PLATFORM_INFO_DIR}/
# This file will do the actual find_package query. We than have
# CMakeHIPInformation.cmake include `CMakeHipRuntime`
# So it is included once system information has been finished
#
configure_file(
 ${CMAKE_ROOT}/Modules/CMakeHIPRuntime.cmake.in
 ${CMAKE_PLATFORM_INFO_DIR}/CMakeHIPRuntime.cmake
 @ONLY
)

# Re-configure to save learned information.
configure_file(
  ${CMAKE_ROOT}/Modules/CMakeHIPCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeHIPCompiler.cmake
  @ONLY
  )
include(${CMAKE_PLATFORM_INFO_DIR}/CMakeHIPCompiler.cmake)

if(CMAKE_HIP_SIZEOF_DATA_PTR)
  foreach(f ${CMAKE_HIP_ABI_FILES})
    include(${f})
  endforeach()
  unset(CMAKE_HIP_ABI_FILES)
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE ${__CMAKE_SAVED_TRY_COMPILE_TARGET_TYPE})
unset(__CMAKE_SAVED_TRY_COMPILE_TARGET_TYPE)
unset(__CMAKE_HIP_COMPILER_OUTPUT)

# Load the file and find the relevant HIP runtime.
# This file will only exist after all compiler detection has finished
include(${CMAKE_PLATFORM_INFO_DIR}/CMakeHIPRuntime.cmake)
if(COMMAND _CMAKE_FIND_HIP_RUNTIME)
  _CMAKE_FIND_HIP_RUNTIME()
endif()
