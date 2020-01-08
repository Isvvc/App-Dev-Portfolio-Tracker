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
                                        appDescription: String,
                                        appStoreURL: URL?,
                                        artworkURL: URL?,
                                        bundleID: String,
                                        name: String,
                                        userRatingCount: Int16?,
                                        context: NSManagedObjectContext) {
        self.init(context: context)

        self.id = bundleID
        self.ageRating = ageRating
        self.appDescription = appDescription
        self.artworkURL = artworkURL
        self.appStoreURL = appStoreURL
        self.name = name
        self.userRatingCount = userRatingCount ?? 0
    }

    @discardableResult convenience init(representation: AppRepresentation, context: NSManagedObjectContext) {
        self.init(context: context)

        self.id = representation.bundleID
        self.ageRating = representation.ageRating
        self.appDescription = representation.appDescription
        self.artworkURL = representation.artworkURL
        self.appStoreURL = representation.appStoreURL
        self.name = representation.name
        self.userRatingCount = representation.userRatingCount ?? 0
    }
}

extension Library {
    @discardableResult convenience init(name: String,
                                        context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
    }
}
