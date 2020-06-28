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

#import "NSObject+ExecuteLotsOfMethods.h"
#import <objc/runtime.h>

@implementation NSObject (ExecuteLotsOfMethods)

- (void)executeLotsOfMethods {
  
  void (^executeMethodsWithNoParamsBlock)(BOOL) = ^(BOOL useClass) {
    int unsigned count;
    Class class = useClass ? objc_getMetaClass(class_getName([self class])) : [self class];
    
    Method *methods = class_copyMethodList(class, &count);
    
    NSSet *blackListMethods = [NSSet setWithArray:@[@"dealloc", @"retain", @"release"]];
    
    for (int i = 0; i < count; i++) {
      
      SEL sel = method_getName(methods[i]);
      NSString *methodName = NSStringFromSelector(sel);
      
      
      if ([methodName containsString:@":"]) {
        continue;
      }
      
      if ([methodName containsString:@".cxx_destruc"]) {
        continue;
      }
      
      if ([blackListMethods containsObject:methodName]) {
        continue;
      }
      
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      if (useClass) {
        [[self class] performSelector:sel];
      } else {
        [self performSelector:sel];
      }
#pragma clang diagnostic pop
    }
    free(methods);
  };
  
  executeMethodsWithNoParamsBlock(NO);
  executeMethodsWithNoParamsBlock(YES);
}

@end
