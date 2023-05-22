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
import CoreData
import WatchConnectivity

let oneDayInSeconds: TimeInterval = 24*60*60
let thursdayEpoch: TimeInterval = 1490832000
let fridayEpoch = thursdayEpoch + oneDayInSeconds
let saturdayEpoch = fridayEpoch + oneDayInSeconds


class WatchDataSource: NSObject {
  
  fileprivate var predicates = [
    "thursday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        Date(timeIntervalSince1970: thursdayEpoch),
        Date(timeIntervalSince1970: thursdayEpoch + oneDayInSeconds - 1)
      ]
    ),
    "friday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        Date(timeIntervalSince1970: fridayEpoch),
        Date(timeIntervalSince1970: fridayEpoch + oneDayInSeconds - 1)
      ]
    ),
    "saturday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        Date(timeIntervalSince1970: saturdayEpoch),
        Date(timeIntervalSince1970: saturdayEpoch + oneDayInSeconds - 1)
      ]
    )
  ]
  
  struct Person: Encodable {
    
    let id: String
    let name: String
    
    init(person: RWDevCon.Person) {
      self.id = person.identifier
      self.name = person.fullName
    }
    
    func toJSON() -> JSON? {
      return jsonify([
        "id" ~~> self.id,
        "name" ~~> self.name
        ])
    }
    
  }
  
  struct Session: Encodable {
    
    static var formatter: DateFormatter {
      get {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "US/Eastern")!
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
      }
    }
    
    let date: Date?
    let description: String?
    let duration: Int?
    let id: String?
    let isFavorite: Bool?
    let number: String?
    var presenters: [Person]?
    let room: String?
    let title: String?
    let track: String?
    
    init(session: RWDevCon.Session) {
      self.date = session.date as Date
      self.description = session.sessionDescription
      self.duration = Int(session.duration)
      self.id = session.identifier
      self.isFavorite = session.isFavorite
      self.number = session.sessionNumber
      self.presenters = [Person]()
      self.room = session.room.name
      self.title = session.title
      self.track = session.track.name
      
      guard let presenters = session.presenters.array as? [RWDevCon.Person] else { return }
      presenters.forEach { presenter in
        self.presenters?.append(Person(person: presenter))
      }
    }
    
    func toJSON() -> JSON? {
      return jsonify([
        Encoder.encode(dateForKey: "date", dateFormatter: Session.formatter)(self.date),
        "description" ~~> self.description,
        "duration" ~~> self.duration,
        "id" ~~> self.id,
        "isFavorite" ~~> self.isFavorite,
        "number" ~~> self.number,
        "presenters" ~~> self.presenters?.toJSONArray(),
        "room" ~~> self.room,
        "title" ~~> self.title,
        "track" ~~> self.track
        ])
    }
    
  }
  
  let context: NSManagedObjectContext
  var session: WCSession?
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func activate() {
    if WCSession.isSupported() {
      session = WCSession.default
      session?.delegate = self
      session?.activate()
    }
  }
  
  fileprivate func sesssionsForPredicate(_ predicate: NSPredicate) -> [JSON] {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    fetch.predicate = predicate
    fetch.sortDescriptors = [
      NSSortDescriptor(key: "date", ascending: true),
      NSSortDescriptor(key: "track.trackId", ascending: true),
      NSSortDescriptor(key: "column", ascending: true)
    ]
    
    do {
      guard let results = try context.fetch(fetch) as? [RWDevCon.Session] else { return [] }
      var sessions = [Session]()
      results.forEach { session in
        sessions.append(Session(session: session))
      }
      return sessions.toJSONArray() ?? []
    } catch {
      return []
    }
  }
  
  fileprivate func refreshFavoritesPredicate() {
    predicates["favorites"] = NSPredicate(
      format: "active = %@ AND identifier IN %@",
      argumentArray: [
        true,
        Array(Config.favoriteSessions().values)
      ]
    )
  }
  
}

extension WatchDataSource: WCSessionDelegate {
  /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
  @available(iOS 9.3, *)
  public func sessionDidDeactivate(_ session: WCSession) {
    
  }
  
  /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
  @available(iOS 9.3, *)
  public func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
  @available(iOS 9.3, *)
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    refreshFavoritesPredicate()
    guard let schedule = message["schedule"] as? String, let predicate = predicates[schedule] else {
      replyHandler(["sessions": [JSON]()])
      return
    }
    replyHandler(["sessions": sesssionsForPredicate(predicate)])
  }
  
}
