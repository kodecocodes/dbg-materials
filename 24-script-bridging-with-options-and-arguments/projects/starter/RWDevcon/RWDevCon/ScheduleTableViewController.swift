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

class ScheduleTableViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  weak var dataSource: ScheduleDataSource!
  var startDate: Date?

  var selectedSession: Session?
  var selectedIndexPath: IndexPath?

  var lastSelectedIndexPath: IndexPath?

  var isActive = false
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = (tableView.dataSource as! ScheduleDataSource)
    dataSource.coreDataStack = coreDataStack
    dataSource.startDate = startDate
    if startDate == nil {
      dataSource.endDate = nil
      dataSource.favoritesOnly = true
    } else {
      dataSource.endDate = Date(timeInterval: 60*60*24, since: startDate!)
      dataSource.favoritesOnly = false
    }

    dataSource.tableCellConfigurationBlock = { (cell: ScheduleTableViewCell, indexPath: IndexPath, session: Session) -> () in
      let track = session.track.name
      let room = session.room.name
      let sessionNumber = session.sessionNumber

      cell.nameLabel.text = (!self.dataSource.favoritesOnly && session.isFavorite ? "★ " : "") + session.title

      if self.dataSource.favoritesOnly {
        cell.timeLabel.text = "\(session.startTimeString) • \(track) • \(room)"
      } else if sessionNumber != "" {
        cell.timeLabel.text = "\(sessionNumber) • \(track) • \(room)"
      } else {
        cell.timeLabel.text = "\(track) • \(room)"
      }
    }

    let logoImageView = UIImageView(image: UIImage(named: "logo-rwdevcon"))
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: logoImageView.frame.height + 48))
    header.backgroundColor = UIColor(patternImage: UIImage(named: "pattern-grey")!)
    header.addSubview(logoImageView)

    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: logoImageView, attribute: .centerX, relatedBy: .equal, toItem: header, attribute: .centerX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: logoImageView, attribute: .centerY, relatedBy: .equal, toItem: header, attribute: .centerY, multiplier: 1.0, constant: 0),
      ])

    tableView.tableHeaderView = header

    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MyScheduleSomethingChangedNotification), object: nil, queue: OperationQueue.main) { (notification) -> Void in
      if self.isActive || self.dataSource.favoritesOnly {
        self.refreshSelectively()
      }
    }
  }

  func refreshSelectively() {
    if dataSource.favoritesOnly {
      if let lastSelectedIndexPath = lastSelectedIndexPath {
        if selectedSession != nil && !selectedSession!.isFavorite {
          // selected session is no longer a favorite!
          tableView.reloadData()
          tableFooterOrNot()

          self.selectedSession = nil
          self.selectedIndexPath = nil
          self.lastSelectedIndexPath = nil
          
          if splitViewController != nil {
            if splitViewController!.isCollapsed {
              navigationController?.popViewController(animated: true)
            } else {
              performSegue(withIdentifier: "tableShowDetail", sender: self)
            }
          }
        } else {
          tableView.deselectRow(at: lastSelectedIndexPath, animated: true)
        }
      }

      return
    }

    if let selectedIndexPath = selectedIndexPath {
      tableView.reloadSections(IndexSet(integer: selectedIndexPath.section), with: .none)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    tableFooterOrNot()

    if splitViewController != nil && !(splitViewController!.isCollapsed) {
      if selectedIndexPath == nil {
        selectedIndexPath = lastSelectedIndexPath
      }
      if selectedIndexPath == nil && dataSource.allSessions.count > 0 {
        selectedIndexPath = IndexPath(row: 0, section: 0)
        lastSelectedIndexPath = selectedIndexPath
      }

      if selectedIndexPath != nil {
        tableView.selectRow(at: selectedIndexPath!, animated: false, scrollPosition: .none)
      }

      performSegue(withIdentifier: "tableShowDetail", sender: self)
    }
  }

  func tableFooterOrNot() {
    if !dataSource.favoritesOnly {
      return
    }

    if dataSource.allSessions.count == 0 {
      let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 500))
      let white = UIView()
      white.translatesAutoresizingMaskIntoConstraints = false
      white.backgroundColor = UIColor.white
      white.isOpaque = true
      footer.addSubview(white)

      let title = UILabel()
      title.translatesAutoresizingMaskIntoConstraints = false
      title.textColor = UIColor(red: 0, green: 109.0/255, blue: 55.0/255, alpha: 1.0)
      title.text = "SCHEDULE EMPTY"
      title.font = UIFont(name: "AvenirNext-Medium", size: 20)
      white.addSubview(title)

      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 0
      label.textAlignment = .center
      label.textColor = UIColor.black
      label.text = "Add talks to your schedule from each talk's detail page:\n\n1.\nFind the talk in the Friday or Saturday tabs.\n\n2.\nTap the talk title to see its detail page.\n\n3.\nTap 'Add to My Schedule'."
      label.font = UIFont(name: "AvenirNext-Regular", size: 19)
      white.addSubview(label)

      let filler = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
      filler.translatesAutoresizingMaskIntoConstraints = false
      white.addSubview(filler)

//      NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[white]|", options: nil, metrics: nil, views: ["white": white]))
//      NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[white]|", options: 0, metrics: nil, views: ["white": white]))

      NSLayoutConstraint.activate([
        white.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
        white.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
        white.topAnchor.constraint(equalTo: footer.topAnchor, constant: 20),
        white.bottomAnchor.constraint(equalTo: footer.bottomAnchor)
      ])
      
      NSLayoutConstraint.activate([
        NSLayoutConstraint(item: title, attribute: .centerX, relatedBy: .equal, toItem: white, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: white, attribute: .width, multiplier: 0.7, constant: 0),
        ])
      NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[title]-20-[label]-20-[filler]", options: .alignAllCenterX, metrics: nil, views: ["title": title, "label": label, "filler": filler]))

      tableView.tableFooterView = footer
    } else {
      tableView.tableFooterView = nil
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }

  override func willMove(toParentViewController parent: UIViewController?) {
    super.willMove(toParentViewController: parent)

    tableView.contentInset.bottom = bottomHeight
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destNav = segue.destination as? UINavigationController {
      if let dest = destNav.topViewController as? SessionViewController {
        dest.coreDataStack = coreDataStack
        dest.scheduleDataSource = dataSource

        selectedIndexPath = tableView.indexPathForSelectedRow
        lastSelectedIndexPath = tableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
          selectedSession = dataSource.sessionForIndexPath(selectedIndexPath!)
        } else {
          selectedSession = nil
        }
        dest.session = selectedSession
      }
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 48
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 48))
    header.backgroundColor = UIColor(patternImage: UIImage(named: "pattern-row\(section % 2)")!)

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = dataSource.distinctTimes[section].uppercased()
    label.textColor = UIColor.white
    label.font = UIFont(name: "AvenirNext-Medium", size: 18)
    header.addSubview(label)

//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[label]-|", options: nil, metrics: nil, views: ["label": label]) +
//      [NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: header, attribute: .CenterY, multiplier: 1.0, constant: 4)])
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(equalTo: header.trailingAnchor),
      label.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 4)
    ])
    
    return header
  }

  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }

}
