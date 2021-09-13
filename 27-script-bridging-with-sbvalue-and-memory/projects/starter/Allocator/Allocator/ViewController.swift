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

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var pickerView: UIPickerView!
  @IBOutlet weak var descriptionLabel: UILabel!
  var retainedObject: Any? = nil
  
  var dataSource = [
    "DSObjectiveCObject",
    "Allocator.ASwiftClass",
    "Allocator.ASwiftNSObjectClass",
    "UIAlertController",
    "SomeClassThatHopefullyDoesntExist"
  ]
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let index = self.pickerView.selectedRow(inComponent: 0)
    self.textField.text = self.dataSource[index]
  }

  @IBAction func allocatorButtonTapped(_ sender: Any) {
    
    guard let className = textField.text,
      let cls = NSClassFromString(className) else {
        let name = self.textField.text ?? "[BLANK]"
        self.descriptionLabel.text = "Unable to find class '" + name + "'"
        return
    }

    if let clsNSObject = cls as? NSObject.Type {
      let object = clsNSObject.init()
      let description = object.debugDescription
      
      self.descriptionLabel.text = object.debugDescription
      self.retainedObject = object
      
      print("\(description)")
      
    } else if let clsSwift = cls as? ASwiftClass.Type {
      let object = clsSwift.init()
      let description = (object as AnyObject).debugDescription
      
      self.descriptionLabel.text = description
      self.retainedObject = object
      
      if let description = description {
        print("\(description)")
      }
    }
  }
}

extension ViewController: UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.dataSource.count
  }
}

extension ViewController: UIPickerViewDelegate {

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.textField.text = self.dataSource[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return dataSource[row]
  }
}

extension ViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
