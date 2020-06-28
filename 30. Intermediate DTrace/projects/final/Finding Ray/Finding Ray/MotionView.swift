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

import UIKit

@IBDesignable public class MotionView: UIImageView {

  // Needed since IB won't add subviews to UIImageViews. Yay Xcode :]
  @IBInspectable public var inspectorHackImage: String? = nil {
    didSet {
      if let inspectorHackImage = inspectorHackImage {
        self.image = UIImage(named: inspectorHackImage)
      } else {
        self.image = nil
      }
    }
  }
  
  @IBInspectable public var zPosition: CGFloat = 0.0 {
    didSet {
      self.layer.zPosition = zPosition
    }
  }
  
  @IBInspectable public var transformAmount: CGFloat = 0.0
  @IBInspectable public var motionAmount: CGFloat = 0.0
  
  @IBInspectable public var shadowSize: CGSize = CGSize.zero {
    didSet {
      let xMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.shadowOffset", type: .tiltAlongHorizontalAxis)
      xMotionEffect.minimumRelativeValue = NSValue(cgSize: CGSize(width: shadowSize.width - 10.0,
                                                                  height: shadowSize.height - 8.0))
      xMotionEffect.maximumRelativeValue = NSValue(cgSize: CGSize(width: shadowSize.width,
                                                                  height: shadowSize.height))
      self.addMotionEffect(xMotionEffect)
      self.layer.shadowRadius = 20.0
      self.layer.shadowOpacity = 0.8
      self.layer.shadowOffset = shadowSize
    }
  }
  
  @IBInspectable var maskName: String? = nil {
    didSet {
      if let maskName = maskName {
        let imageLayer = CALayer()
        imageLayer.frame = self.bounds
        imageLayer.contents = UIImage(named: maskName)?.cgImage
        self.layer.mask =  imageLayer
      } else {
        self.mask = nil
      }
    }
  }

  func animate(isSelected: Bool) {

    let shadowAnimation = CABasicAnimation(keyPath: "shadowRadius")
    shadowAnimation.duration = 0.15
    shadowAnimation.fromValue = layer.presentation()?.shadowRadius
    shadowAnimation.toValue = isSelected ? 10 : 20
    
    let smallSize = CGSize(width: 3, height: 3)
    let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
    shadowOffsetAnimation.duration = 0.15
    shadowOffsetAnimation.fromValue = layer.presentation()?.shadowOffset
    shadowOffsetAnimation.toValue = isSelected ? smallSize : shadowSize
    
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [shadowOffsetAnimation, shadowAnimation]
    layer.add(groupAnimation, forKey: nil)
    layer.shadowOffset = isSelected ? smallSize : shadowSize
    layer.shadowRadius = isSelected ? 10 : 20
  }
  
  func recursivelyTransformByAmount(distance: CGPoint, baseView: UIView) {
    
    if self.transformAmount != 0 {
      var transform = CATransform3DIdentity
      transform.m34 = 1.0 / -500.0
      transform = CATransform3DRotate(transform, self.transformAmount / CGFloat.pi,
                                      distance.y,
                                      distance.x,
                                      0.0)
      self.layer.transform = transform
    }

    if self.motionAmount != 0 {
      let maxX = baseView.bounds.midX
      let maxY = baseView.bounds.midY
      var center = CGPoint(x: maxX, y: maxY)
      
      center.x += self.motionAmount * (distance.x / maxX)
      center.y += self.motionAmount * (distance.y / maxY)
      
      self.center = center
    }

    for view in subviews {
      if let view = view as? MotionView {
        view.recursivelyTransformByAmount(distance: distance, baseView: baseView)
      } 
    }
  }

  public override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    self.layer.shouldRasterize = true
    self.isUserInteractionEnabled = false
  }
}

extension UIView {

  func recursivelyResetViewsWithViews(with baseView: UIView) {
    if let superview = superview {
      self.center = CGPoint(x: superview.bounds.midX,
                            y: superview.bounds.midY)
    }
    
    self.layer.transform = CATransform3DIdentity
    for view in subviews {
      view.recursivelyResetViewsWithViews(with: baseView)
    }
  }
}
