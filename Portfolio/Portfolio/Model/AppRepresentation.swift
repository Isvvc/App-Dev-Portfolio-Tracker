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
    let artworkURL: URL
    let ageRating: String
    var artwork: UIImage?
    
    init(name: String, artworkURL: URL, ageRating: String) {
        self.name = name
        self.artworkURL = artworkURL
        self.ageRating = ageRating
    }
}
