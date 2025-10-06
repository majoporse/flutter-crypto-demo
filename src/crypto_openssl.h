#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

FFI_PLUGIN_EXPORT int encrypt(unsigned char *plaintext, int plaintext_len, unsigned char *ciphertext);

FFI_PLUGIN_EXPORT int decrypt(unsigned char *ciphertext, int ciphertext_len, unsigned char *plaintext);
