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
    let appDescription: String
    let appStoreURL: URL

    var artwork: UIImage?

    init(name: String, bundleID: String, artworkURL: URL, ageRating: String, description: String, appStoreURL: URL) {
        self.name = name
        self.bundleID = bundleID
        self.artworkURL = artworkURL
        self.ageRating = ageRating
        self.appDescription = description
        self.appStoreURL = appStoreURL
    }
}
