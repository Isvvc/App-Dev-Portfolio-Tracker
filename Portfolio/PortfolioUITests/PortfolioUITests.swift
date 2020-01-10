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

    }

    func testCreateApp() {

    }

    func testDeleteApp() {

    }

}
