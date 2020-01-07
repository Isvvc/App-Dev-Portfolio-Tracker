//
//  AppController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData
import SwiftyJSON

extension Notification.Name {
    static var loadAppArtwork = Notification.Name("loadAppArtwork")
}

class AppController {

    let networkingController = NetworkingController()

    func search(appName: String, completion: @escaping ([AppRepresentation], Error?) -> Void) {
        networkingController.search(appName: appName) { data, error in
            if let error = error {
                return completion([], error)
            }

            guard let data = data else {
                NSLog("No data returned from search")
                return completion([], nil)
            }

            do {
                let json = try JSON(data: data)
                guard let results = json["results"].array else {
                    return completion([], json["results"].error)
                }

                var apps: [AppRepresentation] = []

                for appJSON in results {
                    guard let name = appJSON["trackName"].string,
                        let bundleID = appJSON["bundleId"].string,
                        let artworkURL = appJSON["artworkUrl512"].url,
                        let ageRating = appJSON["contentAdvisoryRating"].string,
                        let description = appJSON["description"].string,
                        let appStoreURL = appJSON["trackViewUrl"].url else { continue }

                    let app = AppRepresentation(name: name,
                                                bundleID: bundleID,
                                                artworkURL: artworkURL,
                                                ageRating: ageRating,
                                                description: description,
                                                appStoreURL: appStoreURL)

                    self.fetchArtwork(app: app, index: apps.count)

                    apps.append(app)
                }

                return completion(apps, nil)
            } catch {
                return completion([], error)
            }
        }
    }

    func fetchArtwork(app: AppRepresentation, index: Int) {
        networkingController.fetchImage(from: app.artworkURL) { image, error in
            if let error = error {
                return NSLog("Error fetching artwork: \(error)")
            }

            guard let image = image else {
                return NSLog("No image data returned from artwork fetch.")
            }

            app.artwork = image
            NotificationCenter.default.post(name: .loadAppArtwork, object: nil, userInfo: ["index": index])
        }
    }

    func create(apps representations: [AppRepresentation], context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<App> = App.fetchRequest()
        let existingApps = try context.fetch(fetchRequest)

        for representation in representations {
            if !existingApps.contains(where: { $0.id == representation.bundleID }) {
                App(representation: representation, context: context)
            }
        }

        CoreDataStack.shared.save(context: context)
    }

    func delete(app: App, context: NSManagedObjectContext) {
        context.delete(app)
        CoreDataStack.shared.save(context: context)
    }
}
