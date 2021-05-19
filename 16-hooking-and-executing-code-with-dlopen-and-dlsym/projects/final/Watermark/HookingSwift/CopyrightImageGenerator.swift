/// Copyright (c) 2018 Razeware LLC
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
import PrivateData.Private

public class CopyrightImageGenerator {

  // MARK: - Properties
  private var imageData: Data? {
    guard let data = ds_private_data else { return nil }

    return Data(bytes: data, count: Int(ds_private_data_len))
  }

  private var originalImage: UIImage? {
    guard let imageData = imageData else { return nil }
    return UIImage(data: imageData)
  }

  public var watermarkedImage: UIImage? {
    guard let originalImage = originalImage,
      let topImage = UIImage(named: "copyright",
                             in: Bundle(identifier: "com.razeware.HookingSwift"),
                             compatibleWith: nil) else {
      return nil
    }

    let size = originalImage.size
    UIGraphicsBeginImageContext(size)

    let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    originalImage.draw(in: area)

    topImage.draw(in: area, blendMode: .normal, alpha: 0.50)

    let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return mergedImage
  }

  // MARK: - Initializers
  public init() {  }
}
