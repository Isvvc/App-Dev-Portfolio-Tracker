//
//  LibraryControllerTests.swift
//  PortfolioTests
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import XCTest
import CoreData
@testable import Portfolio

class LibraryControllerTests: XCTestCase {

    //swiftlint:disable force_try
    func testCreateLibrary() {
        let libraryController = LibraryController()
        let context = CoreDataStack.shared.mainContext

        let initialFetchRequest: NSFetchRequest<Library> = Library.fetchRequest()
        let initialLibraries = try? context.fetch(initialFetchRequest)
        XCTAssertNotNil(initialLibraries)

        let name = "TEST CREATE LIBRARY"
        libraryController.create(libraryNamed: name, context: context)

        let newFetchRequest: NSFetchRequest<Library> = Library.fetchRequest()
        let newLibraries = try? context.fetch(newFetchRequest)
        XCTAssertNotNil(newLibraries)
        XCTAssertNotEqual(initialLibraries, newLibraries)

        let difference = newLibraries!.filter({ library -> Bool in
            return !initialLibraries!.contains(library)
        })
        XCTAssertEqual(difference.count, 1)
        XCTAssertEqual(difference.first?.name, name)

        libraryController.delete(library: difference.first!, context: context)
    }

    func testDeleteLibrary() {
        let libraryController = LibraryController()
        let context = CoreDataStack.shared.mainContext

        let name = "TEST DELETE LIBRARY"

        let initialFetchRequest: NSFetchRequest<Library> = Library.fetchRequest()
        let initialLibraries = try! context.fetch(initialFetchRequest)
        XCTAssertFalse(initialLibraries.contains(where: { $0.name == name }))

        libraryController.create(libraryNamed: name, context: context)

        let newFetchRequest: NSFetchRequest<Library> = Library.fetchRequest()
        let newLibraries = try! context.fetch(newFetchRequest)
        XCTAssertTrue(newLibraries.contains(where: { $0.name == name }))

        let testLibrary = newLibraries.first(where: { $0.name == name })!
        libraryController.delete(library: testLibrary, context: context)
        XCTAssertFalse(initialLibraries.contains(where: { $0.name == name }))
    }

}
