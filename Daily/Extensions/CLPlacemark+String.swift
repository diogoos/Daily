//
//  Placemark+String.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import MapKit

extension CLPlacemark {
    var formattedString: String {
        var metadataString = ""

        if let subLocality = subLocality {
            metadataString += subLocality
            if let locality = locality {
                metadataString += ", " + locality
            }
        } else if let locality = locality {
            metadataString += locality
        }

        return metadataString
    }
}
