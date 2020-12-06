//
//  DailyUITests.swift
//  DailyUITests
//
//  Created by Diogo Silva on 11/07/20.
//

import XCTest

class DailyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTabBarsExist() throws {
        // this makes sure that all tab bar items exist
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.tabBars.buttons["tabbar-entries-button"].exists, "Entries menu bar item does not exist")
        XCTAssert(app.tabBars.buttons["tabbar-map-button"].exists, "Map menu bar item does not exist")
    }

    // test that the correct date shows on entries when changing dates with the chevrons
    func testDateUpdatingOnEntries() throws {
        let app = XCUIApplication()
        app.launch()

        let df = DateFormatter()
        df.locale = Locale.current
        df.setLocalizedDateFormatFromTemplate("MMMMd")

        // test current date
        XCTAssert(app.staticTexts["entries-header-dateLabel"].label == df.string(from: Date()))

        // test previous ten days
        for i in 1...5 {
            app.images["entries-header-previousEntryButton"].tap()

            let expectedDate = df.string(from: Date(timeIntervalSinceNow: TimeInterval(-24*60*60*i)))
            XCTAssert(app.staticTexts["entries-header-dateLabel"].label == expectedDate)
        }

        // make sure next ten days also update correctly
        for i in 1...5 {
            app.images["entries-header-nextEntryButton"].tap()

            let expectedDate = df.string(from: Date(timeIntervalSinceNow: TimeInterval(-24*60*60*(5-i))))
            XCTAssert(app.staticTexts["entries-header-dateLabel"].label == expectedDate)
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
