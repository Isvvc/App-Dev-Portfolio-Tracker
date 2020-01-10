//
//  AppControllerTests.swift
//  PortfolioTests
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import XCTest
import CoreData
@testable import Portfolio

class AppControllerTests: XCTestCase {

    //swiftlint:disable force_try
    func testCreateApp() {
        let appController = AppController()
        let context = CoreDataStack.shared.mainContext

        let initialFetchRequest: NSFetchRequest<App> = App.fetchRequest()
        let initialApps = try? context.fetch(initialFetchRequest)
        XCTAssertNotNil(initialApps)

        let name = "TEST CREATE APP"
        let description = "TEST APP DESCRIPTION"
        let bundleID = "test.app.create"
        appController.create(appNamed: name, description: description, bundleID: bundleID, context: context)

        let newFetchRequest: NSFetchRequest<App> = App.fetchRequest()
        let newApps = try? context.fetch(newFetchRequest)
        XCTAssertNotNil(newApps)
        XCTAssertNotEqual(initialApps, newApps)

        let difference = newApps!.filter({ library -> Bool in
            return !initialApps!.contains(library)
        })
        XCTAssertEqual(difference.count, 1)
        XCTAssertEqual(difference.first!.name, name)
        XCTAssertEqual(difference.first!.appDescription, description)
        XCTAssertEqual(difference.first!.id, bundleID)

        appController.delete(app: difference.first!, context: context)
    }

    func testDeleteApp() {
        let appController = AppController()
        let context = CoreDataStack.shared.mainContext

        let name = "TEST DELETE APP"
        let description = "TEST APP DESCRIPTION"
        let bundleID = "test.app.delete"

        let initialFetchRequest: NSFetchRequest<App> = App.fetchRequest()
        let initialApps = try! context.fetch(initialFetchRequest)
        XCTAssertFalse(initialApps.contains(where: { $0.name == name }))

        appController.create(appNamed: name, description: description, bundleID: bundleID, context: context)

        let newFetchRequest: NSFetchRequest<App> = App.fetchRequest()
        let newApps = try! context.fetch(newFetchRequest)
        XCTAssertTrue(newApps.contains(where: { $0.name == name }))

        let testApp = newApps.first(where: { $0.id == bundleID })!
        appController.delete(app: testApp, context: context)
        XCTAssertFalse(initialApps.contains(where: { $0.name == name }))
    }

    func testFetchArtwork() {
        let appController = AppController()
        let appRepresentation = AppRepresentation(
            name: "TEST APP",
            bundleID: "test.app.fetch",
            //swiftlint:disable line_length
            artworkURL: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Purple113/v4/15/39/16/15391683-ff50-2a3f-1418-c76d20a24986/source/512x512bb.jpg")!,
            //swiftlint:enable line_length
            ageRating: nil,
            description: "TEST APP DESCRIPTION",
            appStoreURL: nil,
            userRatingCount: nil,
            screenshots: nil)
        XCTAssertNil(appRepresentation.artwork)

        expectation(forNotification: .loadAppArtwork, object: nil, handler: nil)
        appController.fetchArtwork(app: appRepresentation, index: 0)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(appRepresentation.artwork)
    }

    func testAppSearch() {
        let appController = AppController()
        let expectation = self.expectation(description: "Search")

        appController.search(appName: "Pages") { appRepresentations, error in
            XCTAssertNil(error)
            XCTAssertNotNil(appRepresentations)
            XCTAssertTrue(appRepresentations.contains(where: { $0.bundleID == "com.apple.Pages" }))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testStoreImage() {
        let appController = AppController()

        //swiftlint:disable line_length
        let imageData = try! Data(contentsOf: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Purple113/v4/da/de/9f/dade9ff5-bfa3-c8d1-5828-635c03058b73/source/512x512bb.jpg")!)
        //swiftlint:enable line_length
        let image = UIImage(data: imageData)

        let key = "test.app.store"
        appController.store(image!, forKey: key)
        let retrievedImage = appController.retrieveImage(forKey: key)

        let png1 = image?.pngData()
        let png2 = retrievedImage?.pngData()
        XCTAssertEqual(png1, png2)

        appController.deleteImage(forKey: key)
    }

    func testDeleteImage() {
        let appController = AppController()

        //swiftlint:disable line_length
        let imageData = try! Data(contentsOf: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Purple113/v4/da/de/9f/dade9ff5-bfa3-c8d1-5828-635c03058b73/source/512x512bb.jpg")!)
        //swiftlint:enable line_length
        let image = UIImage(data: imageData)

        let key = "test.app.store"
        appController.store(image!, forKey: key)
        let retrievedImage = appController.retrieveImage(forKey: key)

        XCTAssertNotNil(retrievedImage)
        appController.deleteImage(forKey: key)
        let retrievedImageAgain = appController.retrieveImage(forKey: key)
        XCTAssertNil(retrievedImageAgain)
    }

}
