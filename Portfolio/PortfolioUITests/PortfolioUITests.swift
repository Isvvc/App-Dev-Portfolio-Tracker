//
//  PortfolioUITests.swift
//  PortfolioUITests
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import XCTest

class PortfolioUITests: XCTestCase {

    private var app: XCUIApplication {
        return XCUIApplication()
    }

    override func setUp() {
        continueAfterFailure = false

        XCUIApplication().launch()
    }

    func testSearch() {
        app.buttons.firstMatch.tap()

        app.sheets.firstMatch.buttons["Search"].tap()
        sleep(1)

        app.searchFields.firstMatch.tap()
        app.typeText("Nextcloud\n")
        sleep(2)

        app.staticTexts["Nextcloud"].tap()
        app.navigationBars.buttons["Add App"].tap()
        app.staticTexts["Nextcloud"].tap()
    }

    func testAppDetails() {
        app.staticTexts["Nextcloud"].tap()
        usleep(100)
        XCTAssertEqual(app.navigationBars.staticTexts.firstMatch.label, "Nextcloud")
    }

    func testEditApp() {
        app.staticTexts["Nextcloud"].tap()
        usleep(100)
        app.navigationBars.buttons["Edit"].tap()
        app.textViews.firstMatch.tap()
        app.typeText("Test Edit ")
        app.navigationBars.buttons["Save"].tap()
        app.navigationBars.buttons["Apps"].tap()
        app.staticTexts["Test Edit Nextcloud"].tap()
    }

    func testCreateApp() {
        app.buttons.firstMatch.tap()
        app.sheets.firstMatch.buttons["Create New"].tap()
        app.textFields.firstMatch.typeText("test.app.ui")
        app.alerts.firstMatch.buttons["Done"].tap()
        app.textViews["App Name"].tap()
        app.typeText("Test App")
        app.textViews["App Description"].tap()
        app.typeText("Test App Description")
        app.navigationBars.buttons["Save"].tap()
        app.staticTexts["Test App"].tap()
    }

    func testDeleteApp() {

    }

}
