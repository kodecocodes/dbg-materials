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

import CoreData

open class CoreDataStack {
  
  public static let modelName = "RWDevCon"
  
  public let context: NSManagedObjectContext
  let psc: NSPersistentStoreCoordinator
  let model: NSManagedObjectModel
  let store: NSPersistentStore?
  
  public init() {
    
    let bundle = Bundle.main
    let modelURL =
    bundle.url(forResource: type(of: self).modelName, withExtension:"momd")!
    model = NSManagedObjectModel(contentsOf: modelURL)!
    
    psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    let documentsURL = Config.applicationDocumentsDirectory()
    let storeURL = documentsURL.appendingPathComponent("\(type(of: self).modelName).sqlite")

    NSLog("Store is at \(storeURL)")

    let options = [NSInferMappingModelAutomaticallyOption:true,
        NSMigratePersistentStoresAutomaticallyOption:true]
    
    do {
      store = try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
    } catch {
      do {
        try FileManager.default.removeItem(at: storeURL)
        print("Model has changed, removing.")
      } catch {
        print("Error removing persistent store: \(error)")
        abort()
      }
      do {
       store = try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
      } catch {
        print("Error adding persistent store: \(error)")
        abort()
      }
    }
  }
  
  func saveContext() {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        print("Could not save: \(error)")
        abort()
      }
    }
  }
  
}

