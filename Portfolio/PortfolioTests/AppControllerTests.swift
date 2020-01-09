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

}
