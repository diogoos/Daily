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
//        let originalEntry = Entry(date: Date(timeIntervalSince1970: 1605305050),
//                                  title: "My example entry",
//                                  content: "Content",
//                                  metadata: .init(location: CLLocationCoordinate2D(latitude: 100, longitude: 100),
//                                                  temperature: 20))

//        let json = try originalEntry.json()
//        let loadedEntry = try JSONDecoder.withStrategy(.compatible).decode(Entry.self, from: json)
//        XCTAssert(originalEntry == loadedEntry)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testFilterTimes() throws {
        let entryProvider = CoreDataEntryProvider()
        let calendar = Calendar.current
        let currentDate = Date()

        self.measure {
            _ = try? entryProvider.entries(where: { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate)
            }).first
        }
    }

    func testFetchTimes() throws {
        let entryProvider = CoreDataEntryProvider()
        let calendar = Calendar.current
        let currentDate = Date()

        self.measure {
            guard let range = calendar.range(of: .day, in: currentDate) else { assertionFailure("Failed to make date"); return }
            let _ = try? entryProvider.entries(inDateRange: range).first
        }
    }

    func testUpdatingLogic() throws {
        let visibleOnTable = Set([0, 1, 2])
        let visibleOnMap = Set([1, 2, 3])

        // modifications
        let remove = visibleOnTable.subtracting(visibleOnMap) // visible on table but not on map, remove
        let add = visibleOnMap.subtracting(visibleOnTable) // visible on map but not table, add to table

        print("Table: \(visibleOnTable)")
        print("Map: \(visibleOnMap)")
        print("Should remove \(remove)")
        print("Should add \(add)")
    }

}
