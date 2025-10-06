# FLUTTER CRYPTO DEMO

Simple demo: Flutter app that calls native C code (OpenSSL) via FFI + CMake to encrypt/decrypt.

## Prerequisites

- Flutter (stable)
- Android SDK + NDK
- CMake 3.10+
- OpenSSL static libs and headers placed under `src/openssl/<abi>/` (you said these are included)

## Quick build & install (example/)

1. flutter clean
2. flutter pub get

## For a real ARM device (most phones — recommended)

- Ensure `android/build.gradle` `abiFilters` includes the ABI you built OpenSSL for (e.g. `'arm64-v8a'`).
- Build and install:
  - flutter build apk --target-platform android-arm64 --debug
  - adb install -r build/app/outputs/flutter-apk/app-debug.apk

## For emulator (x86_64)

- flutter build apk --debug
- adb install -r build/app/outputs/flutter-apk/app-debug.apk

## Run for debugging

- flutter run -d <device-id>
- View native prints: flutter logs (or adb logcat)

## Notes / tips

- Allocate output buffer >= input + AES block size (e.g. input + 16).
- Always use the integer returned by the C function as the actual output length.
- If native prints don't appear, fflush(stdout) or log to stderr/file from C.
- If you get linker errors, verify `src/openssl/<abi>/` contains libssl.a and libcrypto.a matching the target ABI.

## Windows (recommended if OpenSSL not installed)
If OpenSSL isn't installed on Windows, I recommend using vcpkg — this is the method that worked for me.

Quick steps:
1. Clone and bootstrap vcpkg:
   - git clone https://github.com/microsoft/vcpkg.git
   - .\vcpkg\bootstrap-vcpkg.bat
2. Install OpenSSL for your target triplet (example x64):
   - .\vcpkg\vcpkg.exe install openssl:x64-windows
3. Use vcpkg with CMake:
   - Add -DCMAKE_TOOLCHAIN_FILE=C:/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake to your CMake invocation
   - Or copy the built headers/libs into `src/openssl/<abi>/` matching your ABI

## License

- See repository files for license details.
