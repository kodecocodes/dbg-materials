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
import AFramework

class CasinoViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var winLoseLabel: UILabel!
  @IBOutlet weak var casinoContainerView: CasinoContainerView!

  // MARK: - IBActions
  @IBAction func randomNumberToConsoleTapped(_ sender: Any) {
    SomeClassInAFramework.printARandomNumber()
  }

  @IBAction func spinTapped(_ sender: UIButton) {
    sender.isEnabled = false

    self.casinoContainerView.spin { [weak self] col0, col1, col2  in

      if col0.slotCharacter == col1.slotCharacter && col0.slotCharacter == col2.slotCharacter {
        
        let string = "\(col0.slotCharacter)x3, WINNER!!"
        let attributedString = NSMutableAttributedString(string:string)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.green,
                                      range: NSRange(location: 0, length: attributedString.length))
        self?.winLoseLabel.attributedText = attributedString
      } else {
        
        let string = "Try Again!"
        let attributedString = NSMutableAttributedString(string:string)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.red,
                                      range: NSRange(location: 0, length: attributedString.length))
        self?.winLoseLabel.attributedText = attributedString
      }

      sender.isEnabled = true
    }
  }
}
