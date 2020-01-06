//
//  AppRepresentation.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class AppRepresentation {
    let name: String
    let bundleID: String
    let artworkURL: URL
    let ageRating: String
    var artwork: UIImage?
    
    init(name: String, bundleID: String, artworkURL: URL, ageRating: String) {
        self.name = name
        self.bundleID = bundleID
        self.artworkURL = artworkURL
        self.ageRating = ageRating
    }
}
