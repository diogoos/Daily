//
//  CoreEntryProvider.swift
//  Daily
//
//  Created by Diogo Silva on 12/04/20.
//

import CoreData

class CoreDataEntryProvider: EntryProvider {
    required init() { }

    static let entity: String = "CoreEntry"
    let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
    let request = NSFetchRequest<CoreEntry>(entityName: CoreDataEntryProvider.entity)

    func allEntries() throws -> [Entry] {
        try context.fetch(request).compactMap { Entry(from: $0) }
    }

    func deleteAll() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Self.entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
    }

    enum CoreDataProviderErrors: Error {
        case noAssociatedManagedObject, notImplemented, failedToLoadFromID, failedToParseEntry, entityNotFound, couldNotConvertDateIntoRange
    }

    func delete(_ entry: Entry) throws {
        guard let objectId = entry.managedObjectId else { throw CoreDataProviderErrors.noAssociatedManagedObject }
        let managedObject = context.object(with: objectId)
        context.delete(managedObject)
        try context.save()
    }

    func save(_ entry: Entry) throws {
        // check if the object is already stored in CoreData
        // by checking whether the entry was loaded using the
        // init(from:) initalizer that stores managed object
        // identifier
        if let objectId = entry.managedObjectId {
            guard let managedObject = context.object(with: objectId) as? CoreEntry else {
                throw CoreDataProviderErrors.failedToLoadFromID
            }

            guard let original = Entry(from: managedObject) else { throw CoreDataProviderErrors.failedToParseEntry }

            if original.date != entry.date       { managedObject.setValue(entry.date,    forKey: "date")    }
            if original.title != entry.title     { managedObject.setValue(entry.title,   forKey: "title")   }
            if original.content != entry.content { managedObject.setValue(entry.content, forKey: "content") }

            let originalMetadata = (try? JSONEncoder().encode(original.metadata)) ?? Data()
            let newMetadata = (try? JSONEncoder().encode(entry.metadata)) ?? Data()

            if originalMetadata != newMetadata { managedObject.setValue(newMetadata, forKey: "storedMetadata") }

            if context.hasChanges { try context.save() }
            return
        }

        // add a new entry to the database
        guard let entity = NSEntityDescription.entity(forEntityName: Self.entity, in: context) else {
            throw CoreDataProviderErrors.entityNotFound
        }

        // TO SAVE FRESH, WE MUST HAVE DATE & TITLE, NOT JUST METADATA
        // SOLUTION: START LOCATION MANAGER ONLY WHEN VALUE FO TITLE OR
        // BODY HAS CHANGED!!
        let managedEntry = NSManagedObject(entity: entity, insertInto: context)
        managedEntry.setValue(entry.date,    forKey: "date")
        managedEntry.setValue(entry.title,   forKey: "title")
        managedEntry.setValue(entry.content, forKey: "content")

        let storedMetadata = (try? JSONEncoder().encode(entry.metadata)) ?? Data()
        managedEntry.setValue(storedMetadata, forKey: "storedMetadata")

        if context.hasChanges { try context.save() }
    }

    func entries(inDateRange dateRange: Range<Date>) throws -> [Entry] {
        let dateFrom = dateRange.lowerBound as NSDate
        let dateTo = dateRange.upperBound as NSDate

        let fromPredicate = NSPredicate(format: "%K >= %@", #keyPath(CoreEntry.date), dateFrom)
        let toPredicate = NSPredicate(format: "%K < %@", #keyPath(CoreEntry.date), dateTo)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])

        let fetchRequest = NSFetchRequest<CoreEntry>(entityName: "CoreEntry")
        fetchRequest.predicate = datePredicate

        return try context.fetch(fetchRequest).compactMap({ Entry(from: $0) })
    }

    func entry(date: Date) throws -> Entry? {
        let calendar = Calendar.current

        guard let range = calendar.range(of: .day, in: date) else { throw CoreDataProviderErrors.couldNotConvertDateIntoRange }
        let loadedEntry = try entries(inDateRange: range).first

        if loadedEntry == nil && calendar.isDateInToday(date) {
            return Entry(date: date, title: "", content: "", metadata: .empty)
        }

        return loadedEntry
    }
}

extension CoreDataEntryProvider.CoreDataProviderErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "NSEntityDescription could not be formed because the specified entity was not found."
        case .failedToLoadFromID:
            return "Managed object identifier from CoreEntry stored in Entry, but unable to load managed object from context."
        case .failedToParseEntry:
            return "A CoreEntry object was found in the managed context, but it could not be parsed into 'Entry'."
        case .noAssociatedManagedObject:
            return "A managed object identifier from CoreEntrty is _required_, but was not found in the Entry."
        case .notImplemented:
            return "The method called is not yet implemented, and likely should not have been called."
        case .couldNotConvertDateIntoRange:
            return "Could not convert Date into Range<Date> necessary for fetching with NSPredicate."
        }
    }
}
