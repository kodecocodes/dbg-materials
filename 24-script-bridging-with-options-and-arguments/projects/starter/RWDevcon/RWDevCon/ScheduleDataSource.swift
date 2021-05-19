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
import UIKit
import CoreData

typealias TableCellConfigurationBlock = (_ cell: ScheduleTableViewCell, _ indexPath: IndexPath, _ session: Session) -> ()

class ScheduleDataSource: NSObject {
  var coreDataStack: CoreDataStack!

  var startDate: Date?
  var endDate: Date?
  var favoritesOnly = false

  let hourHeaderHeight: CGFloat = 40
  let numberOfTracksInSchedule = 3
  let numberOfHoursInSchedule = 11
  let trackHeaderWidth: CGFloat = 120
  let widthPerHour: CGFloat = 180
  let firstHour = 8
  
  var tableCellConfigurationBlock: TableCellConfigurationBlock?

  var allSessions: [Session] {
    let fetch = NSFetchRequest<Session>(entityName: "Session")

    if self.startDate != nil && self.endDate != nil {
      fetch.predicate = NSPredicate(format: "(active = %@) AND (date >= %@) AND (date <= %@)", argumentArray: [true, self.startDate!, self.endDate!])
    } else if favoritesOnly {
      fetch.predicate = NSPredicate(format: "active = %@ AND identifier IN %@", argumentArray: [true, Array(Config.favoriteSessions().values)])
    } else {
      fetch.predicate = NSPredicate(format: "active = %@", argumentArray: [true])
    }
    fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true), NSSortDescriptor(key: "track.trackId", ascending: true), NSSortDescriptor(key: "column", ascending: true)]
    
    do {
      let results = try coreDataStack.context.fetch(fetch)
      return results
    } catch {
      return []
    }
  }

  var distinctTimes: [String] {
    var times = [String]()

    if favoritesOnly {
      for session in self.allSessions {
        let last = times.last
        let thisDayOfWeek = session.startDateDayOfWeek

        if (last == nil) || (last != nil && last! != thisDayOfWeek) {
          times.append(thisDayOfWeek)
        }
      }
    } else {
      for session in self.allSessions {
        let last = times.last
        if (last == nil) || (last != nil && last! != session.startDateTimeString) {
          times.append(session.startDateTimeString)
        }
      }
    }

    return times
  }

  func session(with identifier: String) -> Session? {
    return allSessions.filter { $0.identifier == identifier }.first
  }

  internal func sessionForIndexPath(_ indexPath: IndexPath) -> Session {
    let sessions = arrayOfSessionsForSection(indexPath.section)
    return sessions[indexPath.row]
  }
  
  // MARK: Private Utilities
  
  fileprivate func arrayOfSessionsForSection(_ section: Int) -> [Session] {
    if favoritesOnly {
      let weekday = distinctTimes[section]
      return allSessions.filter({ (session) -> Bool in
        return session.startDateTimeString.hasPrefix(weekday)
      })
    } else {
      let startTimeString = distinctTimes[section]
      return allSessions.filter({ (session) -> Bool in
        return session.startDateTimeString == startTimeString
      })
    }
  }
  
  fileprivate func groupDictionaryForSection(_ section: Int) -> NSDictionary {
    return ["Header": distinctTimes[section]]
  }
  
}

extension ScheduleDataSource: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return distinctTimes.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayOfSessionsForSection(section).count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell") as! ScheduleTableViewCell
    let session = sessionForIndexPath(indexPath)
    if let configureBlock = tableCellConfigurationBlock {
      configureBlock(cell, indexPath, session)
    }
    return cell
  }

}
