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

import Cocoa

class ViewController: NSViewController {

  @IBOutlet weak var progressBar: NSProgressIndicator!
  @IBOutlet weak var tableView: NSTableView!
  
  let dataSource = [
    ("RAX", RAX_register),
    ("RBX", RBX_register),
    ("RCX", RCX_register),
    ("RDX", RDX_register),
    ("RDI", RDI_register),
    ("RSI", RSI_register),
    ("RBP", RBP_register),
    ("RSP", RSP_register),
    ("R8", R8_register),
    ("R9", R9_register),
    ("R10", R10_register),
    ("R11", R11_register),
    ("R12", R12_register),
    ("R13", R13_register),
    ("R14", R14_register),
    ("R15", R15_register)
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func reloadAssemblyClicked(_ sender: AnyObject) {
    tableView.reloadData()
  }
}

extension ViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    let (value, closure) = self.dataSource[row]
    if tableColumn == tableView.tableColumns[0] {
      return value
    } else {
      let register = closure()
      let formattedString = "0x" + String(register, radix:16)
      return formattedString
    }
  }
}
