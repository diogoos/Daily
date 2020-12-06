//
//  MapViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/07/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var mapView: MKMapView!
    var tableView: UITableView!

    var annotationTable = [MKAnnotation]()// {

    //}
//        let selected = mapView.selectedAnnotations
//        if selected.count > 0 {
//            return selected.map {
//                if $0.isKind(of: MKClusterAnnotation.self) {
//                    return ($0 as! MKClusterAnnotation).memberAnnotations
////                    return [$0]
//                } else {
//                    return [$0]
//                }
//            }.reduce([], +)
//        } else {
//            return Array(mapView.annotations(in: mapView.visibleMapRect)).compactMap { $0 as? MKAnnotation }
//        }
//        return []
//    }

    init() {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        self.tabBarItem.accessibilityIdentifier = "tabbar-map-button"
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        self.tabBarItem.accessibilityIdentifier = "tabbar-map-button"
    }

    // alternative code-based layout
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        mapView = MKMapView()
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "entryMarker")
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "simple_cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 20

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 250),

            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 25)
        ])

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        for _ in 0..<40 {
            let city = MKPointAnnotation()
            city.coordinate = MockEntryProvider.makeRandomUSCoordinate()
            city.title = MockEntryProvider.makeTitle()
            mapView.addAnnotation(city)
        }

        tableView.delegate = self
        tableView.dataSource = self

    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) { tableView.reloadData() }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) { tableView.reloadData() }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        annotationTable = Array(mapView.annotations(in: mapView.visibleMapRect)).compactMap({ $0 as? MKAnnotation })
        tableView.reloadData()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "entryMarker", for: annotation)
        marker.clusteringIdentifier = marker.reuseIdentifier
        (marker as? MKMarkerAnnotationView)?.markerTintColor = .systemBlue
        (marker as? MKMarkerAnnotationView)?.titleVisibility = .hidden
        (marker as? MKMarkerAnnotationView)?.subtitleVisibility = .hidden
        return marker
    }

    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let annotation = annotationTable[indexPath.row]

        // move camera to pin
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.mapView.selectAnnotation(annotation, animated: true)
            self.mapView.zoomToPoint(annotation.coordinate, animated: true)

        })
        CATransaction.commit()
    }
}

extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0//annotationTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simple_cell", for: indexPath)

//        let annotationSet = mapView.annotations(in: mapView.visibleMapRect)
//        cell.textLabel?.text = (annotationSet.randomElement() as? MKAnnotation?)??.title ?? "unknwon"



//        cell.textLabel?.text = Array(mapView.annotations(in: mapView.visibleMapRect))[indexPath.row].title ?? "unknown"
//        cell.textLabel?.text = annotationTable.removeFirst().title ?? "unknown"
//        cell.detailTextLabel!.text = "Hello"
        return cell
//            ??
//                   UITableViewCell(style: .subtitle, reuseIdentifier: "simple_cell")
//
//        let annotation = annotationTable[indexPath.row]
//        cell.textLabel?.text = annotation.title ?? "Unknown"
//
//        DemoData.demoAddressForLocation(annotation.coordinate) { address in
//
//            // this causes crashing!!!
////            DispatchQueue.main.async {
////            cell.detailTextLabel?.text = address == "Bogustown" ? "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)" : address //"\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
////            }
//        }
//
//        return cell
    }
}

extension CLLocationCoordinate2D: Equatable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && rhs.longitude == rhs.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine("(\(self.latitude),\(self.longitude))")
    }

}

extension MKMapView {
    func zoomToPoint(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.setRegion(coordinateRegion, animated: animated)
    }
}
