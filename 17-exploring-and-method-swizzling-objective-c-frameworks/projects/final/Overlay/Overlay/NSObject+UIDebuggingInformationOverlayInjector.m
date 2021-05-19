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

@import UIKit;
@import Foundation;
@import ObjectiveC.runtime; // you mean ObjectiveC.funtime, ooooooooooooooHHHHHH

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wundeclared-selector"

//*****************************************************************************/
#pragma mark - Section 0 - Private Declarations
//*****************************************************************************/

@interface NSObject()
- (void)_setWindowControlsStatusBarOrientation:(BOOL)orientation;
@end

//*****************************************************************************/
#pragma mark - Section 1 - FakeWindowClass
//*****************************************************************************/

@interface FakeWindowClass : UIWindow
@end

@implementation FakeWindowClass

- (instancetype)initSwizzled
{
  if (self= [super init]) {
    [self _setWindowControlsStatusBarOrientation:NO];
  }
  return self;
}

@end

//*****************************************************************************/
#pragma mark - Section 2 - Initialization
//*****************************************************************************/

@implementation NSObject (UIDebuggingInformationOverlayInjector)

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = NSClassFromString(@"UIDebuggingInformationOverlay");
    NSAssert(cls, @"DBG Class is nil?");
    
    // Swizzle code here
    [FakeWindowClass swizzleOriginalSelector:@selector(init) withSizzledSelector:@selector(initSwizzled) forClass:cls isClassMethod:NO];
    
    [self swizzleOriginalSelector:@selector(prepareDebuggingOverlay) withSizzledSelector:@selector(prepareDebuggingOverlaySwizzled) forClass:cls isClassMethod:YES];
  });
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withSizzledSelector:(SEL)swizzledSelector forClass:(Class)class isClassMethod:(BOOL)isClassMethod
{
  
  Method originalMethod;
  Method swizzledMethod;
  
  if (isClassMethod) {
    originalMethod = class_getClassMethod(class, originalSelector);
    swizzledMethod = class_getClassMethod([self class], swizzledSelector);
  } else {
    originalMethod = class_getInstanceMethod(class, originalSelector);
    swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
  }
  
  NSAssert(originalMethod, @"originalMethod should not be nil");
  NSAssert(swizzledMethod, @"swizzledMethod should not be nil");
  
  method_exchangeImplementations(originalMethod, swizzledMethod);
}

//*****************************************************************************/
#pragma mark - Section 3 - prepareDebuggingOverlay
//*****************************************************************************/

+ (void)prepareDebuggingOverlaySwizzled {

  Class cls = NSClassFromString(@"UIDebuggingInformationOverlay");
  SEL sel = @selector(prepareDebuggingOverlaySwizzled);
  Method m = class_getClassMethod(cls, sel); 

  IMP imp =  method_getImplementation(m);
  void (*methodOffset) = (void *)((imp + (long)27));
  void *returnAddr = &&RETURNADDRESS;
  
  __asm__ __volatile__(
      "pushq  %0\n\t"
      "pushq  %%rbp\n\t"
      "movq   %%rsp, %%rbp\n\t"
      "pushq  %%r15\n\t"
      "pushq  %%r14\n\t"
      "pushq  %%r13\n\t"
      "pushq  %%r12\n\t"
      "pushq  %%rbx\n\t"
      "pushq  %%rax\n\t"
      "jmp  *%1\n\t"
      :
      : "r" (returnAddr), "r" (methodOffset));
  
  RETURNADDRESS: ;
}

@end
#pragma clang diagnostic pop
