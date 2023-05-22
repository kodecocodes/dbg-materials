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

class MasterContainerViewController: UIViewController {
  
  // MARK: - Properties
  var suggestedBottomContentInset: CGFloat {
    get { return bottomImageView.bounds.height }
  }

  // MARK: - IBOutlets
  @IBOutlet weak var bottomImageView: UIImageView!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Quarterback"
  }
}

// MARK: - IBActions
extension MasterContainerViewController {

  @IBAction func stopButtonTapped(_ sender: UIBarButtonItem) {
    raise(SIGSTOP)
  }

  @IBAction func callPlayButtonTapped(_ sender: UIButton) {
    let alertController = UIAlertController(title: "Signals",
                                            message: "Select a signal to raise",
                                            preferredStyle: .actionSheet)

    for signalName in GetAllSignals() where signalName != "SIGSTOP" {
      let alertAction = UIAlertAction(title: signalName, style: .default) { _ in
        let signal = signalNameToInt(signalName)
        raise(signal)
      }
      alertController.addAction(alertAction)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancelAction)

    alertController.popoverPresentationController?.sourceView = sender
    alertController.popoverPresentationController?.sourceRect = sender.bounds

    present(alertController, animated: true)
  }
}
