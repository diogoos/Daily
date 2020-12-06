//
//  DailyTests.swift
//  DailyTests
//
//  Created by Diogo Silva on 11/07/20.
//

import XCTest
import MapKit
@testable import Daily

class DailyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Test that entries can succesfully be encoded then decoded
    func testEntryEncodingDecoding() throws {
        let originalEntry = Entry(date: Date(timeIntervalSince1970: 1605305050),
                                  title: "My example entry",
                                  content: "Content",
                                  metadata: .init(temperature: 20,
                                                  location: CLLocationCoordinate2D(latitude: 100, longitude: 100)))

        let json = try originalEntry.json()
        let loadedEntry = try JSONDecoder.withStrategy(.compatible).decode(Entry.self, from: json)
        XCTAssert(originalEntry == loadedEntry)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
