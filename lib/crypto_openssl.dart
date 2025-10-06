import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'crypto_openssl_bindings_generated.dart';

int encrypt(
  ffi.Pointer<ffi.UnsignedChar> string,
  int strLen,
  ffi.Pointer<ffi.UnsignedChar> buffer,
) => _bindings.encrypt(string, strLen, buffer);

int decrypt(
  ffi.Pointer<ffi.UnsignedChar> string,
  int strLen,
  ffi.Pointer<ffi.UnsignedChar> buffer,
) => _bindings.decrypt(string, strLen, buffer);

const String _libName = 'crypto_openssl';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final CryptoOpenSSLBindings _bindings = CryptoOpenSSLBindings(_dylib);
