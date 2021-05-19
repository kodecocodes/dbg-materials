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

class ViewController: UIViewController {
  
  @IBOutlet weak var containerView: MotionView!
  var dynamicAnimator: UIDynamicAnimator!
  var snapBehavior: UISnapBehavior!

  override func viewDidLoad() {
    super.viewDidLoad()

    dynamicAnimator = UIDynamicAnimator(referenceView: view)
    snapBehavior = UISnapBehavior(item: containerView, snapTo: view.center)
    
    let gesture = QuickTouchPanGestureRecognizer(target: self,
                                                 action:#selector(handleGesture(panGesture:)))
    
    self.view.addGestureRecognizer(gesture)
  }

  @objc func handleGesture(panGesture: UIPanGestureRecognizer) {
    
    switch panGesture.state {
    case .began:
      dynamicAnimator.addBehavior(snapBehavior)
      self.containerView.animate(isSelected: true)
    case .cancelled:
      break
    case .ended:
      self.containerView.animate(isSelected: false)
    case .changed:
      let offset = CGPoint(x: panGesture.translation(in: view).x,
                           y: panGesture.translation(in: view).y)
      
      containerView.recursivelyTransformByAmount(distance: offset, baseView: containerView)
    case .possible:
      break
    case .failed:
      break
    }
  }
  
  @IBAction func resetViewsTapped(_ sender: UIBarButtonItem) {
    containerView.recursivelyResetViewsWithViews(with: containerView)
  }
  
  @IBAction func tweetAtAndAnnoyRayWenderlichButtonTapped(_ sender: UIBarButtonItem) {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let activityItems: [Any]
    if let image = image {
      activityItems = [TweetContent.generate(), image]
    } else {
      activityItems = [TweetContent.generate()]
    }
    
    let activityViewController = UIActivityViewController(
      activityItems: activityItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [.addToReadingList,
                                                    .airDrop,
                                                    .assignToContact,
                                                    .openInIBooks,
                                                    .postToWeibo,
                                                    .postToTencentWeibo,
                                                    .postToVimeo,
                                                    .mail,
                                                    .message]
    
    if let popoverPresentationController = activityViewController.popoverPresentationController {
      popoverPresentationController.barButtonItem = sender
    }

    present(activityViewController, animated: true)
  }
}
