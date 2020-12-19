//
//  MockEntryProvider.swift
//  Daily
//
//  Created by Diogo Silva on 11/27/20.
//

import Foundation
import MapKit

#if DEBUG
class MockEntryProvider: EntryProvider {
    // Singleton
    static var shared = MockEntryProvider()

    // initalizer
    required init() {}

    // Fetching
    var storage: [Entry]? = nil

    func allEntries() -> [Entry] {
        if let storage = storage { return storage }
        else { // generate fake storage
            storage = makeDates().map { date in
                let title = Self.makeTitle()
                return Entry(date: date,
                             title: title,
                             content: Self.makeContent(forTitle: title),
                             metadata: makeMetadata())
            }
            return storage ?? []
        }
    }

    // Modifying
    func save(_ entry: Entry) throws {
        guard let index = storage?.firstIndex(where: { $0 == entry }) else {
            storage?.append(entry)
            return
        }
        storage?[index] = entry
    }

    func deleteAll() throws {
        storage = []
    }

    // MARK: - Content Generation
    var entryCount = Int.random(in: 6...14)

    static var titleClauses = [
        ["Fun", "Amazing", "Regular", "Interesting", "Profound", "Superb", "Ambitious", "Fabulous", "Absurd", "Active", "Agitated", "Common", "Complicated", "Awesome", "Dazzling", "Overwhelming", "Classic", "Mundane", "Cool", "Incredible"],
        ["Day", "Experience", "Trip", "Adventure", "Excursion", "Journey", "Voyage", "Expedition", "Encounter", "Occurence", "Thrill", "Venture", "Occurence", "Matter"],
        ["with Friends", "with Family", "with Coworkers", "with Pet", "with Parents", "with Grandparents", "with Actor", "with Reporter"],
    ]

    static func makeTitle() -> String {
        let wordCount = Self.titleClauses.count - max(Int.random(in: 0...2) - 1, 0)

        var title = ""
        for row in 0..<wordCount {
            title += Self.titleClauses[row].randomElement()!
            if row != wordCount - 1 { title += " " }
        }

        return title
    }

    static func makeContent(forTitle title: String? = nil) -> String {
        var content = ""
        content += "Today was an " + (title?.lowercased() ?? makeTitle().lowercased()) + ". It was full of "

        for _ in 0..<Int.random(in: 2...6) {
            content += Self.titleClauses[0].randomElement()!.lowercased() + ", "
        }

        content += "and " + Self.titleClauses[0].randomElement()!.lowercased() + " things. "
        content += "Overall, I think that spending time " + Self.titleClauses[2].randomElement()!.lowercased() + " is a valuable thing, which we cannot take for granted."

        return content
    }

    func makeDates() -> [Date] {
        var dates = [Date]()
        let baseDate = Date()
        var currentDate = baseDate

        var i = 1
        while dates.count < entryCount {
            currentDate = currentDate.addingTimeInterval(TimeInterval(-24*60*60*i))
            if Int.random(in: 0...100) != 1 { dates.append(currentDate) }
            i += 1
        }

        return dates
    }

    static func makeRandomUSCoordinate() -> CLLocationCoordinate2D {
        let latitude: CLLocationDegrees = Double.random(in: 24.9493...49.5904)
        let longitude: CLLocationDegrees = Double.random(in: -125.0011...(-66.9326))
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func makeTemperature() -> Double {
        Double.random(in: 10...40)
    }

    func makeMetadata() -> Entry.Metadata {
        Entry.Metadata(location: Self.makeRandomUSCoordinate(),
                       temperature: Self.makeTemperature())
    }
}
#endif
