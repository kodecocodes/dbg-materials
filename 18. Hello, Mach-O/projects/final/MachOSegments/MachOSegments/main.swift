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
import MachO

func convertIntTupleToString(name : Any) -> String {
  var returnString = ""
  let mirror = Mirror(reflecting: name)
  for child in mirror.children {
    guard let val = child.value as? Int8,
      val != 0 else {
        break
    }
    returnString.append(Character(UnicodeScalar(UInt8(val))))
  }

  return returnString
}

for i in 0..<_dyld_image_count() {
  let imagePath = String(validatingUTF8: _dyld_get_image_name(i))!
  let imageName = (imagePath as NSString).lastPathComponent
  let header = _dyld_get_image_header(i)!
  print("\(i) \(imageName) \(header)")

  var curLoadCommandIterator = Int(bitPattern: header) + MemoryLayout<mach_header_64>.size
  for _ in 0..<header.pointee.ncmds {
    let loadCommand = UnsafePointer<load_command>(bitPattern: curLoadCommandIterator)!.pointee

    if loadCommand.cmd == LC_SEGMENT_64 {
      let segmentCommand = UnsafePointer<segment_command_64>(bitPattern: curLoadCommandIterator)!.pointee

      let segName = convertIntTupleToString(name:  segmentCommand.segname)
      print("\t\(segName)")

      for j in 0..<segmentCommand.nsects {
        let sectionOffset = curLoadCommandIterator + MemoryLayout<segment_command_64>.size
        let offset = MemoryLayout<section_64>.size * Int(j)
        let sectionCommand = UnsafePointer<section_64>(bitPattern: sectionOffset + offset)!.pointee

        let sectionName = convertIntTupleToString(name: sectionCommand.sectname)
        print("\t\t\(sectionName)")
      }
    }

    curLoadCommandIterator = curLoadCommandIterator + Int(loadCommand.cmdsize)
  }
}

CFRunLoopRun()
