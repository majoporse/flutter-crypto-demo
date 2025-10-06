# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(native_add_library VERSION 0.0.1 LANGUAGES C)

add_library(native_add SHARED
  "native_add.c"
)

set_target_properties(native_add PROPERTIES
  PUBLIC_HEADER native_add.h
  OUTPUT_NAME "native_add"
)

target_compile_definitions(native_add PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(native_add PRIVATE "-Wl,-z,max-page-size=16384")
  
  # Determine the target architecture
  if(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
    set(OPENSSL_ARCH "x86_64")
  elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
    set(OPENSSL_ARCH "arm64-v8a")
  elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a")
    set(OPENSSL_ARCH "armeabi-v7a")
  else()
    message(FATAL_ERROR "Unsupported Android architecture: ${CMAKE_ANDROID_ARCH_ABI}")
  endif()

  target_include_directories(native_add PRIVATE ${CMAKE_SOURCE_DIR}/openssl/${OPENSSL_ARCH}/include)
  target_link_libraries(native_add PRIVATE ${CMAKE_SOURCE_DIR}/openssl/${OPENSSL_ARCH}/lib/libssl.a)
  target_link_libraries(native_add PRIVATE ${CMAKE_SOURCE_DIR}/openssl/${OPENSSL_ARCH}/lib/libcrypto.a)
endif()
