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
import Social

let MyScheduleSomethingChangedNotification = "com.razeware.rwdevcon.notifications.myScheduleChanged"

class SessionViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  var session: Session!
  var scheduleDataSource: ScheduleDataSource!
  
  struct Sections {
    static let info = 0
    static let description = 1
    static let presenters = 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = session?.title

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 76

    navigationController?.navigationBar.barStyle = UIBarStyle.default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), for: UIBarMetrics.default)
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.white]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func share(_ sender: UIBarButtonItem) {
    let actionSheet = UIAlertController(title: "Compose Tweet", message: "Would you like to include a picture with your Tweet? (Please do!)", preferredStyle: .actionSheet)
    
    let takePictureAction = UIAlertAction(title: "Take Picture", style: .default) { [weak self] (_) in
      guard let strongSelf = self else { return }
      strongSelf.present(strongSelf.imagePickerController(sourceType: .camera), animated: true, completion: nil)
    }
    
    let selectPictureAction = UIAlertAction(title: "Select from Library", style: .default) { [weak self] (_) in
      guard let strongSelf = self else { return }
      strongSelf.present(strongSelf.imagePickerController(sourceType: .photoLibrary), animated: true, completion: nil)
    }
    
    let noPictureAction = UIAlertAction(title: "No Picture", style: .default) { [weak self] (_) in
      self?.presentTwitterShareSheet(with: nil)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    actionSheet.addAction(takePictureAction)
    actionSheet.addAction(selectPictureAction)
    actionSheet.addAction(noPictureAction)
    actionSheet.addAction(cancelAction)
    
    present(actionSheet, animated: true, completion: nil)
  }
  
  private func imagePickerController(sourceType: UIImagePickerControllerSourceType) -> UIImagePickerController {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = sourceType
    
    if sourceType == .camera {
      imagePickerController.cameraFlashMode = .off
    }
    
    imagePickerController.delegate = self
    
    return imagePickerController
  }
  
  fileprivate func presentTwitterShareSheet(with image: UIImage?) {
    
//    guard let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
//    
//    let presenters = Array(session.presenters) as? [Person]
//    let twitterHandles = presenters?.flatMap { $0.twitter }
//    
//    let replacementString: String
//    if let twitterHandles = twitterHandles {
//      switch twitterHandles.count {
//      case 1: replacementString = "with @\(twitterHandles[0])"
//      case 2: replacementString = "with @\(twitterHandles[0]) and @\(twitterHandles[1])"
//      default: replacementString = ""
//      }
//    } else {
//      replacementString = ""
//    }
//    
//    let tweetBody = session.tweetBody.replacingOccurrences(of: "{with}", with: replacementString)
//    
//    composeViewController.setInitialText(tweetBody)
//    
//    if let image = image {
//      composeViewController.add(image)
//    }
//    
//    present(composeViewController, animated: true, completion: nil)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    if session == nil {
      return 0
    } else {
      return 3
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == Sections.info {
      return 4
    } else if section == Sections.description {
      return 1
    } else if section == Sections.presenters {
      return session.presenters.count
    }

    return 0
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == Sections.info {
      if session.sessionNumber == "" {
        return "Summary"
      } else {
        return "Session #\(session.sessionNumber)"
      }
    } else if section == Sections.description {
      return "Description"
    } else if section == Sections.presenters {
      if session.presenters.count == 1 {
        return "Presenter"
      } else if session.presenters.count > 1 {
        return "Presenters"
      }
    }
    return nil
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == Sections.info && indexPath.row == 3){
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath) as! DetailTableViewCell

      cell.keyLabel.text = "My Schedule".uppercased()
      if session.isFavorite {
        cell.valueButton.setTitle("Remove from My Schedule", for: UIControlState())
      } else {
        cell.valueButton.setTitle("Add to My Schedule", for: UIControlState())
      }
      cell.valueButton.addTarget(self, action: #selector(SessionViewController.myScheduleButton(_:)), for: .touchUpInside)

      return cell
    } else if indexPath.section == Sections.info && indexPath.row == 2 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath) as! DetailTableViewCell

      cell.keyLabel.text = "Where".uppercased()
      cell.valueButton.setTitle(session.room.name, for: UIControlState())
      if session.isParty {
        cell.valueButton.setTitleColor(view.tintColor, for: UIControlState())
        cell.valueButton.addTarget(self, action: #selector(SessionViewController.roomDetails(_:)), for: .touchUpInside)
      } else {
        cell.valueButton.setTitleColor(view.tintColor, for: UIControlState())
        cell.valueButton.addTarget(self, action: #selector(SessionViewController.generalMap(_:)), for: .touchUpInside)
      }
      return cell
    } else if indexPath.section == Sections.info {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailTableViewCell

      if indexPath.row == 0 {
        cell.keyLabel.text = "Track".uppercased()
        cell.valueLabel.text = session.track.name
      } else if indexPath.row == 1 {
        cell.keyLabel.text = "When".uppercased()
        cell.valueLabel.text = session.startDateTimeString
      }

      return cell
    } else if indexPath.section == Sections.description {
      let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath) as! LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections.presenters {
      let cell = tableView.dequeueReusableCell(withIdentifier: "presenter", for: indexPath) as! PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as! Person

      if let image = UIImage(named: presenter.identifier) {
        cell.squareImageView.image = image
      } else {
        cell.squareImageView.image = UIImage(named: "RW_logo")
      }
      cell.nameLabel.text = presenter.fullName
      cell.bioLabel.text = presenter.bio
      if presenter.twitter != "" {
        cell.twitterButton.isHidden = false
        cell.twitterButton.setTitle("@\(presenter.twitter)", for: UIControlState())
        cell.twitterButton.addTarget(self, action: #selector(SessionViewController.twitterButton(_:)), for: .touchUpInside)
      } else {
        cell.twitterButton.isHidden = true
      }

      return cell
    } else {
      assertionFailure("Unhandled session table view section")
      let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as UITableViewCell
      return cell
    }
  }

  @objc func roomDetails(_ sender: UIButton) {
    if let roomVC = storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as? RoomViewController {
      roomVC.room = session.room
      roomVC.title = session.room.name
      navigationController?.pushViewController(roomVC, animated: true)
    }
  }
  
  @objc func generalMap(_ sender: UIButton) {
    performSegue(withIdentifier: "GeneralMapViewController", sender: nil)
  }

  @objc func myScheduleButton(_ sender: UIButton) {
    
    let setFavoriteBlock = { [weak self] in
      guard let strongSelf = self else { return }
      
      strongSelf.session.isFavorite = !strongSelf.session.isFavorite
      
      strongSelf.tableView.reloadSections(IndexSet(integer: Sections.info), with: .automatic)
      NotificationCenter.default.post(name: Notification.Name(rawValue: MyScheduleSomethingChangedNotification), object: self, userInfo: ["session": strongSelf.session])
    }
    
    if let conflictingIdentifier = Config.conflictingFavoriteIdentifier(session), let conflictingSession = scheduleDataSource.session(with: conflictingIdentifier) {
      let alert = UIAlertController(title: "Replace Existing Session?", message: "You've already added \"\(conflictingSession.title)\" to your schedule for this timeslot. Do you want to replace it?", preferredStyle: .actionSheet)
      let replaceAction = UIAlertAction(title: "Replace", style: .destructive) { (_) in
        setFavoriteBlock()
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      alert.addAction(replaceAction)
      alert.addAction(cancelAction)
      
      present(alert, animated: true, completion: nil)
    } else {
      setFavoriteBlock()
    }
  }

  @objc func twitterButton(_ sender: UIButton) {
    UIApplication.shared.open(URL(string: "http://twitter.com/\(sender.title(for: UIControlState())!)")!, options: [:], completionHandler: nil)
  }
}

extension SessionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
    let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
    dismiss(animated: true) { [weak self] in
      self?.presentTwitterShareSheet(with: editedImage ?? originalImage)
    }
  }
}
