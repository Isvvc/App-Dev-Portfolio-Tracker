//
//  Portfolio+Convenience.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

extension App {
    @discardableResult convenience init(ageRating: String?,
                                        appDescription: String?,
                                        appStoreURL: URL?,
                                        artworkURL: URL?,
                                        bundleID: String,
                                        name: String,
                                        context: NSManagedObjectContext) {
        self.init(context: context)

        self.id = bundleID
        self.ageRating = ageRating
        self.appDescription = appDescription
        self.artworkURL = artworkURL
        self.appStoreURL = appStoreURL
        self.name = name
    }
}
