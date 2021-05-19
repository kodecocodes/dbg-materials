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

class SessionInterfaceController: WKInterfaceController {
  
  @IBOutlet fileprivate weak var titleLabel: WKInterfaceLabel!
  @IBOutlet fileprivate weak var leftPresenterImage: WKInterfaceImage!
  @IBOutlet fileprivate weak var rightPresenterImage: WKInterfaceImage!
  @IBOutlet fileprivate weak var timeLabel: WKInterfaceLabel!
  @IBOutlet fileprivate weak var roomLabel: WKInterfaceLabel!
  @IBOutlet fileprivate weak var descriptionLabel: WKInterfaceLabel!
  
  var session: Session? {
    didSet {
      guard let session = session else { return }
      titleLabel.setText(session.title)
      timeLabel.setText(session.time)
      roomLabel.setText(session.room)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.hyphenationFactor = 1
      let description = NSAttributedString(string: session.description!, attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
      descriptionLabel.setAttributedText(description)
      guard let presenters = session.presenters else { return }
      for (index, image) in [leftPresenterImage, rightPresenterImage].enumerated() {
        guard index < presenters.count else { break }
        image?.setImage(Avatar.cache.avatarForIdentifier(presenters[index].id))
        image?.setHidden(false)
      }
    }
  }
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    guard let context = context as? [String: String], let rawValue = context["schedule"], let schedule = Schedule(rawValue: rawValue), let id = context["id"] else { return }
    Proxy.defaultProxy.sessionsForSchedule(schedule) { sessions in
      self.session = sessions.filter { $0.id == id }.first
    }
  }
  
}
