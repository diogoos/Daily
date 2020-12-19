//
//  EntryProvider.swift
//  Daily
//
//  Created by Diogo Silva on 11/27/20.
//

import Foundation

protocol EntryProvider {
    init()

    // fetch entries
    func allEntries() throws -> [Entry]

    // manipulate entries
    func save(_ entry: Entry) throws // add entry
    func deleteAll() throws // delete all entries and reset state

    // automatically provided, but can be overwritten
    func entries(where whereClause: (Entry) throws -> Bool) throws -> [Entry]
    func entries(inDateRange dateRange: Range<Date>) throws -> [Entry]

    /// Get entry for given date
    /// - Note: When given the current date, never return nil. Instead, return an empty Entry with the correct Date.
    func entry(date: Date) throws -> Entry?
}

extension EntryProvider {
    // simple filtering, can be overrided if necessary
    func entries(where whereClause: (Entry) throws -> Bool) throws -> [Entry] { try allEntries().filter(whereClause) }

    // by default, filter through all entries
    // however, this can be replaced depending on the database
    // with a more efficient function
    func entries(inDateRange dateRange: Range<Date>) throws -> [Entry] { try allEntries().entries(inDateRange: dateRange) }

    // By default, just filter through all the entires
    // and return those in the same day. should be replaced with
    // more efficient methods whenever possible (ex NSPredicate)
    func entry(date: Date) throws -> Entry? {
        let calendar = Calendar.current

        let result = try allEntries().filter({
            calendar.isDate(date, inSameDayAs: $0.date)
        }).first

        if result == nil && calendar.isDateInToday(date) {
            return Entry(date: date, title: "", content: "", metadata: .empty)
        }

        return result
    }

    func export() -> URL? {
        // load all entries
        guard let entries = try? allEntries() else { return nil }

        // encode them to json
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        guard let json = try? encoder.encode(entries) else { return nil }

        // save to a file
        guard let caches = try? FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
        let url = caches.appendingPathComponent("daily-export-\(Int(Date().timeIntervalSince1970)).json")
        try? json.write(to: url)

        // return file location
        return url
    }
}

internal extension Array where Element == Entry {
    // convenience date filtering, very slow
    func entries(inDateRange dateRange: Range<Date>) -> [Entry] { filter { dateRange.contains($0.date) } }
}
