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
}

extension EntryProvider {
    // simple filtering, can be overrided if necessary
    func entries(where whereClause: (Entry) throws -> Bool) throws -> [Entry] { try allEntries().filter(whereClause) }

    // by default, filter through all entries
    // however, this can be replaced depending on the database
    // with a more efficient function
    func entries(inDateRange dateRange: Range<Date>) throws -> [Entry] { try allEntries().entries(inDateRange: dateRange) }
}

internal extension Array where Element == Entry {
    // convenience date filtering, very slow
    func entries(inDateRange dateRange: Range<Date>) -> [Entry] { filter { dateRange.contains($0.date) } }
}
