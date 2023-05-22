// dlsym_poc.c
// clang dlsym_poc.c -o /tmp/dlsym_poc /tmp/libSwiftSharedLibrary.dylib
#include <dlfcn.h>
#include <stdlib.h>

int main() {
  void (*mangled_function)(void) = NULL;
  mangled_function = dlsym(RTLD_NEXT, "$s14SwiftSharedLibrary16mangled_functionyyF");

  if (mangled_function) {
    mangled_function();
  }
  return 0;
}
