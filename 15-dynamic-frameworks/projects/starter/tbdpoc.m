// clang Ex.m  -I.  -L/tmp/ -lPrivateFramework -fmodules -o /tmp/tbdpoc

@import Foundation;
#include <Private.h>

int main(void) {
    // OjbC part
    PrivateObjcClass *p = [PrivateObjcClass new];
    [p  doStuff];
    
    // C symbol part
    SomeCode();
    return 0;
}
