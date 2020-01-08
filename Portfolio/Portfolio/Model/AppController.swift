//
//  AppController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData
import SwiftyJSON
import UIKit

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
                        let appStoreURL = appJSON["trackViewUrl"].url,
                        let userRatingCount = appJSON["userRatingCount"].int16 else { continue }

                    let app = AppRepresentation(name: name,
                                                bundleID: bundleID,
                                                artworkURL: artworkURL,
                                                ageRating: ageRating,
                                                description: description,
                                                appStoreURL: appStoreURL,
                                                userRatingCount: userRatingCount)

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
        guard let artworkURL = app.artworkURL else { return }
        networkingController.fetchImage(from: artworkURL) { image, error in
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

    func fetchAndStoreArtwork(app: App) {
        guard let artworkURL = app.artworkURL,
            let bundleID = app.id else { return }
        networkingController.fetchImage(from: artworkURL) { image, error in
            if let error = error {
                return NSLog("Error fetching artwork: \(error)")
            }

            guard let image = image else {
                return NSLog("No image data returned from artwork fetch.")
            }

            self.store(image, forKey: bundleID)
        }
    }

    // MARK: Core Data

    func create(apps representations: [AppRepresentation], context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<App> = App.fetchRequest()
        let existingApps = try context.fetch(fetchRequest)

        for representation in representations {
            if !existingApps.contains(where: { $0.id == representation.bundleID }) {
                if let artwork = representation.artwork {
                    store(artwork, forKey: representation.bundleID)
                }
                App(representation: representation, context: context)
            }
        }

        CoreDataStack.shared.save(context: context)
    }

    func create(appNamed name: String,
                ageRating: String? = nil,
                description: String,
                appStoreURL: URL? = nil,
                artworkURL: URL? = nil,
                bundleID: String,
                userRatingCount: Int16? = nil,
                artwork: UIImage? = nil,
                context: NSManagedObjectContext) {
        let app = App(ageRating: ageRating,
            appDescription: description,
            appStoreURL: appStoreURL,
            artworkURL: artworkURL,
            bundleID: bundleID,
            name: name,
            userRatingCount: userRatingCount,
            context: context)
        CoreDataStack.shared.save(context: context)

        if let artwork = artwork {
            store(artwork, forKey: bundleID)
        } else if app.artworkURL != nil {
            fetchAndStoreArtwork(app: app)
        }
    }

    func delete(app: App, context: NSManagedObjectContext) {
        if let bundleID = app.id {
            deleteImage(forKey: bundleID)
        }
        context.delete(app)
        CoreDataStack.shared.save(context: context)
    }

    func update(app: App,
                name: String,
                ageRating: String? = nil,
                description: String,
                appStoreURL: URL? = nil,
                bundleID: String,
                userRatingCount: Int16? = nil,
                contributions: String? = nil,
                context: NSManagedObjectContext) {
        app.name = name
        app.ageRating = ageRating
        app.id = bundleID
        app.appDescription = description
        app.appStoreURL = appStoreURL
        app.userRatingCount = userRatingCount ?? 0
        app.contributions = contributions
        CoreDataStack.shared.save(context: context)
    }

    // MARK: Local Storage

    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager
            .urls(for: .documentDirectory,
                  in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }

        return documentURL.appendingPathComponent(key + ".png")
    }

    private func store(_ image: UIImage, forKey key: String) {
        guard let png = image.pngData(),
            let filePath = filePath(forKey: key) else { return }
        do {
            try png.write(to: filePath, options: .atomic)
        } catch {
            NSLog("Error saving image: \(error)")
        }
    }

    private func deleteImage(forKey key: String) {
        guard let filePath = filePath(forKey: key) else { return }
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            NSLog("Error deleting image: \(error)")
        }
    }

    func retrieveImage(forKey key: String) -> UIImage? {
        guard let filePath = filePath(forKey: key),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData) else { return nil }
        return image
    }
}
