#include "Private.h"

// clang -shared -o /tmp/PrivateFramework.dylib Private.m -fmodules  -arch arm64e -arch arm64 -arch x86_64   
// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/tapi stubify /tmp/PrivateFramework.dylib -o /tmp/libPrivateFramework.tbd
// clang tbdpoc.m  -I. -L/tmp/ -lPrivateFramework -fmodules -o /tmp/tbdpoc

NSString *const SomeStringConstant = @"com.kodeco.tbd.example";

void SomeCode(void) {
  NSLog(@"SomeStringConstant is: %@", SomeStringConstant);
}

@implementation PrivateObjcClass
-(void)doStuff {
  NSLog(@"much wow, stuff of doing!");
}
@end
