//
//  Entry.swift
//  Daily
//
//  Created by Diogo Silva on 11/13/20.
//

import Foundation
import MapKit
import CoreData

class Entry: Equatable, Encodable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.date == rhs.date && lhs.title == rhs.title && lhs.content == rhs.content
    }

    var date: Date
    var title: String
    var content: String
    var metadata: Metadata

    var managedObjectId: NSManagedObjectID? = nil

    enum CodingKeys: CodingKey {
        case date, title, content, metadata
    }

    class Metadata: Codable {
        var location: CLLocationCoordinate2D?
        var temperature: Double?

        init(location: CLLocationCoordinate2D? = nil, temperature: Double? = nil) {
            self.location = location
            self.temperature = temperature
        }

        static let empty = Metadata(location: nil, temperature: nil)
    }

    init( date: Date, title: String, content: String, metadata: Entry.Metadata) {
        self.date = date
        self.title = title
        self.content = content
        self.metadata = metadata
    }


    init?(from coreEntry: CoreEntry) {
        guard let date = coreEntry.date else { return nil }
        self.date = date

        self.title = coreEntry.title ?? ""
        self.content = coreEntry.content ?? ""

        if let metadata = coreEntry.storedMetadata {
            self.metadata = (try? JSONDecoder().decode(Metadata.self, from: metadata)) ?? Metadata()
        } else {
            self.metadata = Metadata()
        }

        self.managedObjectId = coreEntry.objectID
    }
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: CodingKey {
        case latitude, longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude as Double, forKey: .latitude)
        try container.encode(longitude as Double, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
