//
//  AirDoodleUITests.swift
//  AirDoodleUITests
//
//  Created by CETYS Universidad  on 24/03/25.
//

import XCTest

final class AirDoodleUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    @MainActor
    func testImport() throws {
        #if os(iOS)
            let app = XCUIApplication()
            app.launch()
            app.buttons["🌠 Saved doodles"].tap()
            app.buttons["Import AirDoodle"].tap()
            app.buttons["Cancel"].tap()
        #endif
    }
    
    @MainActor
    func testExport() throws {
        #if os(iOS)
            let app = XCUIApplication()
            app.launch()
            app.buttons["🌠 Saved doodles"].tap()
            app.buttons["square.and.arrow.up"].tap()
            app.buttons["Cancel"].tap()
        #endif
    }
    @MainActor
    func testRename() throws {
        #if os(iOS)
            let app = XCUIApplication()
            app.launch()
            app.buttons["🌠 Saved doodles"].tap()
            app.buttons["pencil"].tap()
            app.textFields["New name"].tap()
            app.textFields["New name"].typeText("Testing")
            app.buttons["Save"].tap()
        #endif
    }
    

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
