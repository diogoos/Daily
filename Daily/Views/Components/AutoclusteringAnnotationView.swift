//
//  AutoclusteringAnnotationView.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import MapKit

class AutoclusteringAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "autocluster"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

