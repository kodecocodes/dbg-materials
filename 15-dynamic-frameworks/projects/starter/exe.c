// exe.c
// clang exe.c -o /tmp/exe /tmp/libSwiftSharedLibrary.dylib
// or
// clang exe.c -o /tmp/exe -lSwiftSharedLibrary -L/tmp/
extern void swift_function(void);

int main() {
  swift_function();
  return 0;
}

