# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(crypto_openssl_library VERSION 0.0.1 LANGUAGES C)

add_library(crypto_openssl SHARED
  "crypto_openssl.c"
)

set_target_properties(crypto_openssl PROPERTIES
  PUBLIC_HEADER crypto_openssl.h
  OUTPUT_NAME "crypto_openssl"
)

target_compile_definitions(crypto_openssl PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(crypto_openssl PRIVATE "-Wl,-z,max-page-size=16384")

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

  target_include_directories(crypto_openssl PRIVATE ${CMAKE_SOURCE_DIR}/openssl/${OPENSSL_ARCH}/include)
  target_link_libraries(crypto_openssl PRIVATE ${CMAKE_SOURCE_DIR}/openssl/${OPENSSL_ARCH}/lib/libssl.a)
  target_link_libraries(crypto_openssl PRIVATE ${CMAKE_SOURCE_DIR}/openssl/${OPENSSL_ARCH}/lib/libcrypto.a)
else()
  find_package(OpenSSL REQUIRED)
  target_include_directories(crypto_openssl PRIVATE ${OPENSSL_INCLUDE_DIR})
  target_link_libraries(crypto_openssl PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()
