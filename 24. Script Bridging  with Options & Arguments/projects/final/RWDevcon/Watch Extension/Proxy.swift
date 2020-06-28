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

import Foundation
import WatchConnectivity

enum Schedule: String {
  case thursday = "thursday"
  case friday = "friday"
  case saturday = "saturday"
  case favorites = "favorites"
}

class Proxy: NSObject {
  
  static let defaultProxy = Proxy()
  
  fileprivate var session: WCSession?
  fileprivate var cache = [Schedule: [Session]]()
  
  func activate() -> Bool {
    guard WCSession.isSupported() else { return false }
    session = WCSession.default
    session?.delegate = self
    session?.activate()
    return true
  }
  
  func hasCachedSessionsForSchedule(_ schedule: Schedule) -> Bool {
    guard let _ = cache[schedule] else { return false }
    return true
  }
  
  func removeSessionsForSchedule(_ schedule: Schedule) {
    cache.removeValue(forKey: schedule)
  }
  
  func sessionsForSchedule(_ schedule: Schedule, handler: @escaping (([Session]) -> Void)) {
    if let cached = cache[schedule] {
      handler(cached)
    } else {
      session?.sendMessage(["schedule": schedule.rawValue], replyHandler: { response in
        if let JSON = response["sessions"] as? [JSON], let sessions = [Session].from(jsonArray: JSON) {
          if sessions.count > 0 { self.cache[schedule] = sessions }
          handler(sessions)
        } else {
          handler([])
        }
      }, errorHandler: { error in
        handler([])
      })
    }
  }
  
}

extension Proxy: WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
