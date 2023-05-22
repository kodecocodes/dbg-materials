/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <unistd.h>

@interface NSObject (DS_SwiftObject_Swizzle)
@end

@implementation NSObject (DS_SwiftObject_Swizzle)

+ (void)load { 

    __unused void (^swizzle)(NSString *, BOOL) = ^(NSString *method, BOOL isClassMethod ) {
    NSString *randString = @"SwiftObject";
    NSString *swizzledString = [(NSString *)[(NSString *)[@"ds" stringByAppendingString:randString] stringByAppendingString:@"_"] stringByAppendingString:method];
    
    Class cls = NSClassFromString(@"SwiftObject");

    SEL originalSelector = NSSelectorFromString(method);
    SEL swizzledSelector = NSSelectorFromString(swizzledString);
    
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod([NSObject class], swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(cls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
      class_replaceMethod(cls,
                          swizzledSelector,
                          method_getImplementation(originalMethod),
                          method_getTypeEncoding(originalMethod));
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  };
  
  static dispatch_once_t onceToken;
  dispatch_once (&onceToken, ^{
    swizzle(@"debugDescription", NO);
  });

}

- (id)dsSwiftObject_debugDescription {
  return [NSString stringWithFormat:@"<%@: %p>", [self class], self];
}


@end

