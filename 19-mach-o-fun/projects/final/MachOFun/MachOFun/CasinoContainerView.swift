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

public typealias SlotMachineIcon = (slotCharacter: Character, totalEarnings: Int)

public let casinoDataSource: [SlotMachineIcon] = [
  ("💩", 1),
  ("❤️", 20),
  ("⚽️", 5),
  ("🌻", 20),
  ("🕷", 1),
  ("🌈", 100),
  ("💧", 30),
  ("🕶", 150),
  ("🙌", 80),
  ("🤮", 2)
]

private let totalPickerViews = casinoDataSource.count * 200

typealias SpinCompletionCallbackClosure = ((SlotMachineIcon, SlotMachineIcon, SlotMachineIcon) -> ())

@IBDesignable class CasinoContainerView: UIView {

  // MARK: - IBOutlets
  @IBOutlet var picker : UIPickerView!
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
      layer.masksToBounds = cornerRadius > 0
    }
  }
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  @IBInspectable var borderColor: UIColor? {
    didSet {
      layer.borderColor = borderColor?.cgColor
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.picker.selectRow(totalPickerViews / 2,
                          inComponent: 0,
                          animated: false)
    self.picker.selectRow(totalPickerViews / 2,
                          inComponent: 1,
                          animated: false)
    self.picker.selectRow(totalPickerViews / 2,
                          inComponent: 2,
                          animated: false)
    
    // Ugly hack to get rid of those UIPickerView lines
    if self.picker.subviews.count > 3 {
      self.picker.subviews[1].isHidden = true
      self.picker.subviews[2].isHidden = true
    }
  }
  
  func spin(completion: @escaping SpinCompletionCallbackClosure) {
    let notifyDispatchGroup = DispatchGroup()
    
    notifyDispatchGroup.enter()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.animateRow(index: 0)
      notifyDispatchGroup.leave()
    }
  
    notifyDispatchGroup.enter()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.animateRow(index: 1)
      notifyDispatchGroup.leave()
    }
  
    notifyDispatchGroup.enter()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
      self?.animateRow(index: 2)
      notifyDispatchGroup.leave()
    }
    
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      _ = notifyDispatchGroup.wait(timeout: .now() + 2)
      
      notifyDispatchGroup.notify(queue: .main) { [weak self] in
        guard let self = self else {
          return
        }

        let col0 = casinoDataSource[self.picker.selectedRow(inComponent: 0) % casinoDataSource.count]
        let col1 = casinoDataSource[self.picker.selectedRow(inComponent: 1) % casinoDataSource.count]
        let col2 = casinoDataSource[self.picker.selectedRow(inComponent: 2) % casinoDataSource.count]

        completion(col0, col1, col2)
      }
    }
  }
  
  func animateRow(index: Int) {
    self.picker.selectRow(self.getRandomNumber(),
                          inComponent: index,
                          animated: true)
    
    // Reset it back to a row in the middle position...
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
      guard let self = self else {
        return
      }

      let currentRow = self.picker.selectedRow(inComponent: index)
      self.picker.selectRow(totalPickerViews / 2 + currentRow % casinoDataSource.count,
                            inComponent: index,
                            animated: false)
    }
  }
  
  func getRandomNumber() -> Int {
    var random = Int(arc4random_uniform(UInt32(casinoDataSource.count)))
    random = random + totalPickerViews / 2 + 200 // some number to give a spin
    return random
  }
}

// MARK: - UIPickerViewDelegate
extension CasinoContainerView: UIPickerViewDelegate {
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let count = casinoDataSource.count
    return String(casinoDataSource[row % count].slotCharacter)
  }
}

// MARK: - UIPickerViewDataSource
extension CasinoContainerView: UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 3
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return totalPickerViews
  }
}
