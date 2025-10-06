import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:native_add/native_add.dart' as native_add;
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _encryptController = TextEditingController();
  final TextEditingController _decryptController = TextEditingController();
  String _encryptedResult = '';
  String _decryptedResult = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _encryptController.dispose();
    _decryptController.dispose();
    super.dispose();
  }

  void _encryptText() {
    final text = _encryptController.text;
    if (text.isNotEmpty) {
      // Convert string to bytes
      final bytes = utf8.encode(text);
      final strLen = bytes.length;

      // move the bytes to a malloc'd pointer
      final string = malloc<UnsignedChar>(strLen);
      for (int i = 0; i < bytes.length; i++) {
        string[i] = bytes[i];
      }

      // AES block size is 16 bytes, so output can be up to input + 16 bytes
      final bufLen = strLen * 2;
      final buffer = malloc<UnsignedChar>(bufLen);

      final resultLen = native_add.encrypt(string, strLen, buffer);

      if (resultLen > 0) {
        // Convert encrypted bytes to hex string
        final bytesOut = Uint8List(resultLen);
        for (int i = 0; i < resultLen; i++) {
          bytesOut[i] = buffer[i];
        }

        final encrypted = bytesOut
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join('');

        setState(() {
          _encryptedResult = encrypted; // Remove the "Encrypted bytes: " prefix
        });
      } else {
        setState(() {
          _encryptedResult = 'Encryption failed with code: $resultLen';
        });
      }

      malloc.free(string);
      malloc.free(buffer);
    }
  }

  void _decryptText() {
    final text = _decryptController.text;
    if (text.isNotEmpty) {
      // Convert hex string to bytes
      if (text.length % 2 != 0) {
        setState(() {
          _decryptedResult = 'Invalid hex string length';
        });
        return;
      }

      // convert hex string to bytes
      final byteLen = text.length ~/ 2;
      final bytes = Uint8List(byteLen);

      for (int i = 0; i < text.length; i += 2) {
        final byteStr = text.substring(i, i + 2);
        try {
          bytes[i ~/ 2] = int.parse(byteStr, radix: 16);
        } catch (e) {
          setState(() {
            _decryptedResult = 'Invalid hex string';
          });
          return;
        }
        bytes[i ~/ 2] = int.parse(byteStr, radix: 16);
      }

      // move the bytes to a malloc'd pointer
      final string = malloc<UnsignedChar>(byteLen);
      for (int i = 0; i < byteLen; i++) {
        string[i] = bytes[i];
      }

      final buffer = malloc<UnsignedChar>(
        byteLen,
      ); // Should be enough for decryption

      final resultLen = native_add.decrypt(string, byteLen, buffer);

      if (resultLen > 0) {
        final bytesOut = Uint8List(resultLen); // Use actual result length
        for (int i = 0; i < resultLen; i++) {
          bytesOut[i] = buffer[i];
        }

        // Convert bytes back to string, removing any null padding
        final decrypted = utf8.decode(bytesOut.where((b) => b != 0).toList());

        setState(() {
          _decryptedResult = decrypted;
        });
      } else {
        setState(() {
          _decryptedResult = 'Decryption failed with code: $resultLen';
        });
      }

      malloc.free(string);
      malloc.free(buffer);
    }
  }

  @override
  Widget build(BuildContext context) {
    const spacerSmall = SizedBox(height: 10);
    const spacerMedium = SizedBox(height: 20);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Packages')),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'Encryption/Decryption',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                spacerMedium,
                // Encryption Section
                TextField(
                  controller: _encryptController,
                  decoration: const InputDecoration(
                    labelText: 'Text to Encrypt',
                    border: OutlineInputBorder(),
                    hintText: 'Enter text to encrypt...',
                  ),
                ),
                spacerSmall,
                ElevatedButton(
                  onPressed: _encryptText,
                  child: const Text('Encrypt'),
                ),
                spacerSmall,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SelectableText(
                    _encryptedResult.isEmpty
                        ? 'Encrypted text will appear here...'
                        : _encryptedResult,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                spacerMedium,
                // Decryption Section
                TextField(
                  controller: _decryptController,
                  decoration: const InputDecoration(
                    labelText: 'Text to Decrypt',
                    border: OutlineInputBorder(),
                    hintText: 'Enter text to decrypt...',
                  ),
                ),
                spacerSmall,
                ElevatedButton(
                  onPressed: _decryptText,
                  child: const Text('Decrypt'),
                ),
                spacerSmall,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SelectableText(
                    _decryptedResult.isEmpty
                        ? 'Decrypted text will appear here...'
                        : _decryptedResult,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
