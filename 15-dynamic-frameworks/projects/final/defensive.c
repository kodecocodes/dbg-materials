// defensive.c
// clang defensive.c -o /tmp/defensive /tmp/libSwiftSharedLibrary.dylib -undefined dynamic_lookup
// or, if you want to specify by individual symbols
// clang defensive.c -o /tmp/defensive /tmp/libSwiftSharedLibrary.dylib -Wl,-U,_bad_function,-U,_swift_function
#include <stdio.h>

__attribute__((weak))
extern void swift_function(void);

__attribute__((weak))
extern void bad_function(void);

int main() {
  swift_function ? swift_function() : printf("swift_function not found!\n");
  bad_function ? bad_function() : printf("bad_function not found!\n");
  return 0;
}
