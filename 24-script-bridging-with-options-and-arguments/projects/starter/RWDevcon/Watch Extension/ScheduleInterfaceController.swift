/// Copyright (c) 2017 Razeware LLC
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

import WatchKit

class ScheduleInterfaceController: WKInterfaceController {
  
  enum State {
    case loading
    case empty
    case loaded([Session])
  }
  
  var state = State.loading {
    didSet {
      switch state {
      case .loading:
        table.setNumberOfRows(1, withRowType: "Loading")
      case .empty:
        table.setNumberOfRows(1, withRowType: "Empty")
        guard let schedule = schedule, let row = table.rowController(at: 0) as? EmptyRowController else { return }
        switch schedule {
        case .favorites:
          row.message = "Failed to load your schedule. Please make sure you have added some sessions, and your phone is within range."
        case .thursday, .friday, .saturday:
          row.message = "Failed to load the schedule. Please make sure your phone is within range."
        }
      case .loaded(let sessions):
        table.setNumberOfRows(sessions.count, withRowType: "Session")
        for (index, session) in sessions.enumerated() {
          guard let row = table.rowController(at: index) as? SessionRowController else { continue }
          row.session = session
        }
      }
    }
  }
  var schedule: Schedule?
  
  @IBOutlet weak var table: WKInterfaceTable!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    guard let schedule = context as? String else { return }
    self.schedule = Schedule(rawValue: schedule.lowercased())
    setTitle(schedule == "Favorites" ? "My Schedule" : schedule)
  }
  
  override func willActivate() {
    super.willActivate()
    guard let schedule = schedule else { return }
    if !Proxy.defaultProxy.hasCachedSessionsForSchedule(schedule) { state = .loading }
    Proxy.defaultProxy.sessionsForSchedule(schedule) { sessions in
      self.state = sessions.count > 0 ? .loaded(sessions) : .empty
    }
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    guard segueIdentifier == "Session" else { return nil }
    switch state {
    case .loading, .empty:
      return nil
    case .loaded(let sessions):
      return ["schedule": schedule!.rawValue, "id": sessions[rowIndex].id!]
    }
  }
  
  deinit {
    if let schedule = schedule, schedule == .favorites {
      Proxy.defaultProxy.removeSessionsForSchedule(.favorites)
    }
  }
  
}
