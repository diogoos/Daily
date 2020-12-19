//
//  MapViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/07/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var mapView = MKMapView()
    var tableView = UITableView()
    var provider: EntryProvider

    init(provider: EntryProvider) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        mapView.register(AutoclusteringAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reuseIdentifier)
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

        // setup delegates
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    func layoutAnnotations() {
        try? provider
        .allEntries()
        .compactMap({ entry -> ((entry: Entry, location: CLLocationCoordinate2D))? in
            if let location = entry.metadata.location {
                return (entry: entry, location: location)
            } else { return nil }
        })
        .map { item -> EntryAnnotation in
            let annotation = EntryAnnotation(entry: item.entry)
            annotation.coordinate = item.location
            return annotation
        }
        .forEach { annotation in
            mapView.addAnnotation(annotation)
        }
    }

    override func viewDidLoad() {
        layoutAnnotations()
    }

    var annotationsDisplayedInTable = [EntryAnnotation]()
    var overrideTable = [EntryAnnotation]()

    lazy var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d MMMM y")
        return formatter
    }()
}

extension MapViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        overrideTable.count > 0 ? overrideTable.count : annotationsDisplayedInTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let annotation = overrideTable.count > 0 ? overrideTable[indexPath.row] : annotationsDisplayedInTable[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reuseIdentifier, for: indexPath)
        (cell as? SubtitleTableViewCell)?.associatedEntry = annotation.associatedEntry

        cell.textLabel?.text = annotation.associatedEntry.title
        cell.detailTextLabel?.text = dateFormatter.string(from: annotation.associatedEntry.date)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let entry = (cell as? SubtitleTableViewCell)?.associatedEntry else { return }

        if let mockProvider = provider as? MockEntryProvider {
            mockProvider.storage = [entry] // hack for mock entry provider usage
        }
        let vc = EntryViewController(provider: provider)

        // set correct picker date
        let previousPickerDate = vc.entryView.picker.date
        vc.entryView.picker.setDate(entry.date, animated: false)

        // hide buttons
        vc.entryView.advanceButton.isHidden = true
        vc.entryView.previousButton.isHidden = true

        // disable picker
        vc.entryView.picker.isEnabled = false

        // add top padding
        vc.entryView.picker.isHidden = true
        vc.entryView.mainStack.setCustomSpacing(20, after: vc.entryView.headerView)

        // show navigation bar
        let nav = UINavigationController(rootViewController: vc)
        vc.title = "Entry on \(dateFormatter.string(for: entry.date) ?? "unknown")"

        let doneItem = UIBarButtonItem()
        doneItem.title = "Done"
        doneItem.target = self
        doneItem.action = #selector(dismissModal)

        nav.navigationBar.topItem?.rightBarButtonItem = doneItem

        // present modal
        present(nav, animated: true, completion: {
            tableView.deselectRow(at: indexPath, animated: true)
            vc.entryView.picker.setDate(previousPickerDate, animated: false)
        })
    }

    @objc func dismissModal() { dismiss(animated: true) }
}

extension MapViewController: MKMapViewDelegate {
    func updateTableToMatch() {
        guard overrideTable.count == 0 else { return }

        let visibleInMap = Set(mapView.annotations(in: mapView.visibleMapRect).compactMap({ $0 as? EntryAnnotation }))
        let visibleInTable = Set(annotationsDisplayedInTable)

        let toRemove = visibleInTable.subtracting(visibleInMap)
        let toAdd = visibleInMap.subtracting(visibleInTable)

        let deleteIndicies = toRemove.map { IndexPath(row: annotationsDisplayedInTable.firstIndex(of: $0)!, section: 0) }

        let currentCapacity = visibleInTable.count - deleteIndicies.count
        let addIndicies = (currentCapacity..<visibleInMap.count).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            annotationsDisplayedInTable.removeAll(where: toRemove.contains)
            annotationsDisplayedInTable += Array(toAdd)
            
            tableView.deleteRows(at: deleteIndicies, with: .automatic)
            tableView.insertRows(at: addIndicies, with: .automatic)
        }

        // now, sort the table from distance to center of the map
        let presort = annotationsDisplayedInTable
        let center = mapView.centerCoordinate
        annotationsDisplayedInTable.sort(by: { (lhs: EntryAnnotation, rhs: EntryAnnotation) -> Bool in
            lhs.coordinate.distance(to: center) < rhs.coordinate.distance(to: center)
        })

        tableView.beginUpdates()
        for i in 0..<annotationsDisplayedInTable.count {
            let newRow = annotationsDisplayedInTable.firstIndex(of: presort[i])!
            tableView.moveRow(at: IndexPath(row: i, section: 0), to: IndexPath(row: newRow, section: 0))
        }
        tableView.endUpdates()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateTableToMatch()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }

        if let cluster = annotation as? MKClusterAnnotation {
            overrideTable.append(contentsOf: cluster.memberAnnotations.compactMap({ $0 as? EntryAnnotation }))
        }
        else if let entryAnnotation = annotation as? EntryAnnotation {
            overrideTable.append(entryAnnotation)
        }

        tableView.reloadSections([0], with: .automatic)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }

        if let cluster = annotation as? MKClusterAnnotation {
            overrideTable.removeAll(where: { x in
                (cluster.memberAnnotations as? [EntryAnnotation])?.contains(where: { y in
                    x.associatedEntry == y.associatedEntry
                }) ?? false
            })
        }
        else if let entryAnnotation = annotation as? EntryAnnotation, let index = overrideTable.firstIndex(of: entryAnnotation) {
            overrideTable.remove(at: index)
        }

        tableView.reloadSections([0], with: .automatic)
    }
}

