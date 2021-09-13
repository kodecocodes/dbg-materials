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

#import "RayView.h"

@implementation RayView

- (instancetype)initWithFrame:(CGRect)frame {
  
  CGFloat randomSize = arc4random_uniform(70) + 60.0;
  CGRect bounds = [[UIScreen mainScreen] bounds];
  
  CGFloat centerX = CGRectGetMidX(bounds);
  CGFloat centerY = CGRectGetMidY(bounds);
  CGFloat randomX = centerX - (randomSize / 2.0) - arc4random_uniform(CGRectGetWidth(bounds))/3.0 + arc4random_uniform(CGRectGetWidth(bounds))/3.0;
  CGFloat randomY = centerY - (randomSize / 2.0) - arc4random_uniform(CGRectGetHeight(bounds))/3.0 + arc4random_uniform(CGRectGetHeight(bounds))/3.0;

  CGRect newRect= CGRectMake(randomX, randomY, randomSize, randomSize);
  self = [super initWithFrame:newRect];
  if (self) {
    self.backgroundColor = [UIColor redColor];
    self.userInteractionEnabled = NO;
    NSArray *rays = @[@"ray1", @"ray2", @"ray3", @"ray4"];
    NSString *rayName = rays[arc4random_uniform(4)];
    UIImage *image = [UIImage imageNamed:rayName];
    self.layer.contents = (__bridge id _Nullable)([image CGImage]);
  }
  
  NSLog(@"RayView generated! %@", self);
  return self;
}

@end
