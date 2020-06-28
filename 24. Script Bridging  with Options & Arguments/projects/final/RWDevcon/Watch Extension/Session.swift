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

struct Session: Decodable {
  
  static var formatter: DateFormatter {
    get {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: "US/Eastern")!
      formatter.locale = Locale(identifier: "en_US")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      return formatter
    }
  }
  
  static var timeFormatter: DateFormatter {
    get {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: "US/Eastern")!
      formatter.locale = Locale(identifier: "en_US")
      formatter.dateFormat = "h:mm a"
      return formatter
    }
  }
  
  let date: Date?
  let description: String?
  let duration: Int?
  let id: String?
  var isFavorite: Bool?
  let number: String?
  var presenters: [Person]?
  let room: String?
  var time: String? {
    get {
      guard let date = date else { return nil }
      return Session.timeFormatter.string(from: date)
    }
  }
  let title: String?
  let track: String?
  
  init?(json: JSON) {
    self.date = Decoder.decode(dateForKey: "date", dateFormatter: Session.formatter)(json)
    self.description = "description" <~~ json
    self.duration = "duration" <~~ json
    self.id = "id" <~~ json
    self.isFavorite = "isFavorite" <~~ json
    self.number = "number" <~~ json
    self.presenters = "presenters" <~~ json
    self.room = "room" <~~ json
    self.title = "title" <~~ json
    self.track = "track" <~~ json
  }
  
}
