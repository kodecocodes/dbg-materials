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

// A date before the bundled plist date
private let beginningOfTimeDate = Date(timeIntervalSince1970: 1486080000) // 02-03-2017 12:00 AM
// The kill switch date to stop phoning the server
private let endOfTimeDate = Date(timeIntervalSince1970: 1541909808) //  Sunday, November 11, 2018 4:16:48 AM

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()
  var watchDataSource: WatchDataSource?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    guard let plist = Bundle.main.url(forResource: "RWDevCon2017", withExtension: "plist"), let data = NSDictionary(contentsOf: plist) else { return true }
    
    resetIfNeeded()
    
    let localLastUpdateDate = Config.userDefaults().object(forKey: "lastUpdated") as? Date ?? beginningOfTimeDate
    let metadata = data["metadata"] as? [String: Any]
    let plistLastUpdateDate = metadata?["lastUpdated"] as? Date ?? beginningOfTimeDate
    if Session.sessionCount(coreDataStack.context) == 0 || localLastUpdateDate.compare(plistLastUpdateDate) == .orderedAscending {
      loadDataFromDictionary(data)
    }
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState())
    
    let splitViewController = self.window!.rootViewController as! UISplitViewController
    splitViewController.delegate = self

    let navigationController = splitViewController.viewControllers[0] as! UINavigationController
    (navigationController.topViewController as! ScheduleViewController).coreDataStack = coreDataStack

    let detailWrapperController = splitViewController.viewControllers[1] as! UINavigationController
    (detailWrapperController.topViewController as! SessionViewController).coreDataStack = coreDataStack
    
    watchDataSource = WatchDataSource(context: coreDataStack.context)
    watchDataSource?.activate()
    
    return true
  }
  
  func resetIfNeeded() {
    let resetForNextConferenceKey = "reset-for-2017"
    if !Config.userDefaults().bool(forKey: resetForNextConferenceKey) {
    
      let storeURL = Config.applicationDocumentsDirectory().appendingPathComponent("\(CoreDataStack.modelName).sqlite")
      do {
        try FileManager.default.removeItem(at: storeURL)
      } catch { /* Don't need to do anything here; an error simply means the store didn't exist in the first place */ }
      Config.nukeFavorites()
      Config.userDefaults().set(true, forKey: resetForNextConferenceKey)
    }
  }
  
  func updateFromServer() {
    let task = URLSession.shared.dataTask(with: URL(string: "https://s3.amazonaws.com/cdn.raywenderlich.com/rwdevcon.com/2017/downloads/RWDevCon_lastUpdate.txt")!,
      completionHandler: { (data, response, error) -> Void in
        guard let data = data else { return }
        if let rawDateString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
          let dateString = rawDateString.trimmingCharacters(in: CharacterSet.newlines)
          let formatter = DateFormatter()
          formatter.timeZone = TimeZone(identifier: "US/Eastern")!
          formatter.locale = Locale(identifier: "en_US")
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
          if let serverLastUpdatedDate = formatter.date(from: dateString) {
            let localLastUpdatedDate = (Config.userDefaults().object(forKey: "lastUpdated") as? Date) ?? beginningOfTimeDate

            if localLastUpdatedDate.compare(serverLastUpdatedDate) == ComparisonResult.orderedAscending {
              DispatchQueue.global().async(execute: { () -> Void in
                if let dict = NSDictionary(contentsOf: URL(string: "https://s3.amazonaws.com/cdn.raywenderlich.com/rwdevcon.com/2017/downloads/RWDevCon.plist")!) {
                  let localPlistURL = Config.applicationDocumentsDirectory().appendingPathComponent("RWDevCon2016-latest.plist")
                  DispatchQueue.main.async(execute: { () -> Void in
                    NSLog("New data from remote! local \(localLastUpdatedDate) server \(serverLastUpdatedDate)")
                    
                    dict.write(to: localPlistURL, atomically: true)
                    self.loadDataFromDictionary(dict)
                  })
                }
              })
            } else {
              NSLog("No new data from remote: local \(localLastUpdatedDate) server \(serverLastUpdatedDate)")
            }

            Config.userDefaults().set(Date(), forKey: "lastServerCheck")
            Config.userDefaults().synchronize()
          }
        }
    })
    task.resume()
  }

  func loadDataFromPlist(_ url: URL) {
    if let data = NSDictionary(contentsOf: url) {
      loadDataFromDictionary(data)
    }
  }

  func loadDataFromDictionary(_ data: NSDictionary) {
    typealias PlistDict = [String: NSDictionary]
    typealias PlistArray = [NSDictionary]

    let metadata: NSDictionary! = data["metadata"] as? NSDictionary
    let sessions: PlistDict! = data["sessions"] as? PlistDict
    let people: PlistDict! = data["people"] as? PlistDict
    let rooms: PlistArray! = data["rooms"] as? PlistArray
    let tracks: [String]! = data["tracks"] as? [String]

    if metadata == nil || sessions == nil || people == nil || rooms == nil || tracks == nil {
      return
    }

    let lastUpdated = metadata["lastUpdated"] as? Date ?? beginningOfTimeDate
    Config.userDefaults().set(lastUpdated, forKey: "lastUpdated")

    var allRooms = [Room]()
    var allTracks = [Track]()
    var allPeople = [String: Person]()

    for (identifier, dict) in rooms.enumerated() {
      let room = Room.roomByRoomIdOrNew(identifier, context: coreDataStack.context)

      room.roomId = Int32(identifier)
      room.name = dict["name"] as? String ?? ""
      room.image = dict["image"] as? String ?? ""
      room.roomDescription = dict["roomDescription"] as? String ?? ""
      room.mapAddress = dict["mapAddress"] as? String ?? ""
      room.mapLatitude = dict["mapLatitude"] as? Double ?? 0
      room.mapLongitude = dict["mapLongitude"] as? Double ?? 0

      allRooms.append(room)
    }

    for (identifier, name) in tracks.enumerated() {
      let track = Track.trackByTrackIdOrNew(identifier, context: coreDataStack.context)

      track.trackId = Int32(identifier)
      track.name = name

      allTracks.append(track)
    }

    for (identifier, dict) in people {
      let person = Person.personByIdentifierOrNew(identifier, context: coreDataStack.context)

      person.identifier = identifier
      person.first = dict["first"] as? String ?? ""
      person.last = dict["last"] as? String ?? ""
      person.active = dict["active"] as? Bool ?? false
      person.twitter = dict["twitter"] as? String ?? ""
      person.bio = dict["bio"] as? String ?? ""

      allPeople[identifier] = person
    }

    for (identifier, dict) in sessions {
      let session = Session.sessionByIdentifierOrNew(identifier, context: coreDataStack.context)

      session.identifier = identifier
      session.active = dict["active"] as? Bool ?? false
      session.date = dict["date"] as? Date ?? beginningOfTimeDate
      session.duration = Int32(dict["duration"] as? Int ?? 0)
      session.column = Int32(dict["column"] as? Int ?? 0)
      session.sessionNumber = dict["sessionNumber"] as? String ?? ""
      session.sessionDescription = dict["sessionDescription"] as? String ?? ""
      session.title = dict["title"] as? String ?? ""
      session.tweetBody = dict["tweetBody"] as? String ?? ""

      session.track = allTracks[dict["trackId"] as! Int]
      session.room = allRooms[dict["roomId"] as! Int]

      var presenters = [Person]()
      if let rawPresenters = dict["presenters"] as? [String] {
        for presenter in rawPresenters {
          if let person = allPeople[presenter] {
            presenters.append(person)
          }
        }
      }
      session.presenters = NSOrderedSet(array: presenters)
    }

    coreDataStack.saveContext()

    NotificationCenter.default.post(name: Notification.Name(rawValue: SessionDataUpdatedNotification), object: self)
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // kick off the background refresh from the server if hasn't been too soon
    let tooSoonSeconds: TimeInterval = 5 // how many seconds is too soon?
    if endOfTimeDate.compare(Date()) == ComparisonResult.orderedDescending {
      let lastServerCheck = Config.userDefaults().value(forKey: "lastServerCheck") as? Date ?? beginningOfTimeDate
      if Date().timeIntervalSince(lastServerCheck) > tooSoonSeconds {
        NSLog("Checking with the server at \(Date()); last check was \(lastServerCheck)")
        updateFromServer()
      } else {
        NSLog("NOT checking with the server at \(Date()); last check was \(lastServerCheck)")
      }
    }
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    coreDataStack.saveContext()
  }

}

extension AppDelegate: UISplitViewControllerDelegate {
  
  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
      if let topAsDetailController = secondaryAsNavController.topViewController as? SessionViewController {
        if topAsDetailController.session == nil {
          // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
          return true
        }
      }
    }
    return false
  }

}
