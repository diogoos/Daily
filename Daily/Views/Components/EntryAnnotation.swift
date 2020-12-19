//
//  EntryAnnotation.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import MapKit

class EntryAnnotation: MKPointAnnotation {
    let associatedEntry: Entry

    init(entry: Entry) {
        self.associatedEntry = entry
        super.init()
        title = entry.title
    }
}
