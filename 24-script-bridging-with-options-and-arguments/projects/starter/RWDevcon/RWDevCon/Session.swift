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

private let formatter = DateFormatter()

@objc(Session)
class Session: NSManagedObject {
  @NSManaged var identifier: String
  @NSManaged var active: Bool
  @NSManaged var title: String
  @NSManaged var date: Date
  @NSManaged var duration: Int32
  @NSManaged var column: Int32
  @NSManaged var sessionNumber: String
  @NSManaged var sessionDescription: String
  @NSManaged var room: Room
  @NSManaged var track: Track
  @NSManaged var presenters: NSOrderedSet
  @NSManaged var tweetBody: String

  var fullTitle: String {
    return (sessionNumber != "" ? "\(sessionNumber): " : "") + title
  }

  var startDateDayOfWeek: String {
    return formatDate("EEEE")
  }

  var startDateTimeString: String {
    return formatDate("EEEE h:mm a")
  }

  var startTimeString: String {
    return formatDate("h:mm a")
  }

  var isFavorite: Bool {
    get {
      let favorites = Config.favoriteSessions()
      return Array(favorites.values).contains(identifier)
    }
    set {
      if newValue {
        Config.registerFavorite(self)
      } else {
        Config.unregisterFavorite(self)
      }
    }
  }
  
  var isParty: Bool {
    return title.lowercased().contains("party")
  }

  func formatDate(_ format: String) -> String {
    // TODO: more efficient way than setting the format each time?
    formatter.dateFormat = format
    formatter.timeZone = TimeZone(identifier: "US/Eastern")!

    return formatter.string(from: date)
  }

  class func sessionCount(_ context: NSManagedObjectContext) -> Int {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    fetch.includesSubentities = false
    return (try? context.count(for: fetch)) ?? 0
  }

  class func sessionByIdentifier(_ identifier: String, context: NSManagedObjectContext) -> Session? {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Session else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func sessionByIdentifierOrNew(_ identifier: String, context: NSManagedObjectContext) -> Session {
    return sessionByIdentifier(identifier, context: context) ?? Session(entity: NSEntityDescription.entity(forEntityName: "Session", in: context)!, insertInto: context)
  }
}
