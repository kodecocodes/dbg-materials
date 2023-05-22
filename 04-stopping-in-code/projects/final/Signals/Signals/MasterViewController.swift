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

class MasterViewController: UITableViewController {

  // MARK: - Properties
  var detailViewController: DetailViewController? = nil

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleNotification(notification:)),
                                           name: NSNotification.Name.signalHandlerCountUpdated,
                                           object: nil)

    guard let navigationController = splitViewController?.viewControllers.last as? UINavigationController,
      let detailViewController = navigationController.topViewController as? DetailViewController else {
        return
    }

    self.detailViewController = detailViewController
  }

  override func viewWillAppear(_ animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
    super.viewWillAppear(animated)

    if let bottomInset = (parent as? MasterContainerViewController)?.suggestedBottomContentInset {
      var contentInset = tableView.contentInset
      contentInset.bottom = bottomInset
      tableView.contentInset = contentInset
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "showDetail",
      let indexPath = self.tableView.indexPathForSelectedRow,
      let navigationController = segue.destination as? UINavigationController,
      let controller = navigationController.topViewController as? DetailViewController else {
        return
    }

    let signal = UnixSignalHandler.shared().signals[indexPath.row]
    controller.signal = signal
  }
}

// MARK: - UITableViewDataSource
extension MasterViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }

    return UnixSignalHandler.shared().signals.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard indexPath.section > 0 else {
      return tableView.dequeueReusableCell(withIdentifier: "Toggle", for: indexPath)
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SignalsTableViewCell
    let signal = UnixSignalHandler.shared().signals[indexPath.row]
    cell.setupCellWithSignal(signal: signal)
    return cell
  }
}

// MARK: - IBActions
extension MasterViewController {

  @IBAction func breakpointButtonItemTapped(_ sender: AnyObject) {
    raise(SIGSTOP)
  }

  @IBAction func breakpointsEnableToggleTapped(_ sender: UISwitch) {
    let shouldEnable = sender.isOn

    if !shouldEnable {
      let controller = UIAlertController(title: "Signals Disabled",
                                         message: "All catchable Signals handlers will be ignored. Certain signals, like SIGSTOP, can not be caught",
                                         preferredStyle: .alert)
      controller.addAction(UIAlertAction(title: "Dismiss", style: .default))
      present(controller, animated: true)
    }

    UnixSignalHandler.shared().shouldEnableSignalHandling = shouldEnable
  }
}

// MARK: - Notifications
extension MasterViewController {

  @objc func handleNotification(notification: Notification) {
    tableView.reloadSections(IndexSet(integer: 1), with: .fade)
  }
}
