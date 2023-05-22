/// Copyright (c) 2023 Kodeco LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
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
    ("x0", x0_register),
    ("x1", x1_register),
    ("x2", x2_register),
    ("x3", x3_register),
    ("x4", x4_register),
    ("x5", x5_register),
    ("x6", x6_register),
    ("x7", x7_register),
    ("x8", x8_register),
    ("x9", x9_register),
    ("x10", x10_register),
    ("x11", x11_register),
    ("x12", x12_register),
    ("x13", x13_register),
    ("x14", x14_register),
    ("x15", x15_register),
    ("sp", sp_register)
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
