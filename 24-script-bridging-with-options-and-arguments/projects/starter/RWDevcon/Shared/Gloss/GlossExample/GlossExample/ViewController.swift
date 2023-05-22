//
//  ViewController.swift
//  GlossExample
//
// Copyright (c) 2015 Harlan Kellaway
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Gloss
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repoJSON: JSON = [
            "id" : 40102424,
            "name": "Gloss",
            "description" : "A shiny JSON parsing library in Swift",
            "html_url" : "https://github.com/hkellaway/Gloss",
            "owner" : [
                "id" : 5456481,
                "login" : "hkellaway",
                "html_url" : "https://github.com/hkellaway"
            ],
            "language" : "Swift"
            ]
        
        guard let repo = Repo(json: repoJSON) else {
            print("DECODING FAILURE :(")
            return
        }
        
        print(repo.repoId)
        print(repo.name)
        print(repo.desc)
        print(repo.url)
        print(repo.owner)
        print(repo.ownerURL)
        print(repo.primaryLanguage?.rawValue)
        print("")
        
        print("JSON: \(repo.toJSON())")
        print("")
        
        guard let repos = [Repo].from(jsonArray: [repoJSON, repoJSON, repoJSON]) else {
            print("DECODING FAILURE :(")
            return
        }
        
        print("REPOS: \(repos)")
        print("")
        
        guard let jsonArray = repos.toJSONArray() else {
            print("ENCODING FAILURE :(")
            return
        }
        
        print("JSON ARRAY: \(jsonArray)")

    }
}

