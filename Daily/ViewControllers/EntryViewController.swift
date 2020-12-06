//
//  EntryViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/07/20.
//

import UIKit
import CoreData
import Combine

class EntryViewController<Provider: EntryProvider>: UIViewController, UITextViewDelegate {
    // MARK: - Providers and dates
    private let calendar = Calendar.autoupdatingCurrent

    // current date and entry
    private var entryProvider = Provider()
    private var currentDate: Date { entryView.picker.date }
    private var currentEntry: Entry? {
        do {
            let loadedEntry = try entryProvider.entries(where: { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate)
            }).first

            if loadedEntry == nil && calendar.isDateInToday(currentDate) {
                return Entry(date: currentDate, title: "", content: "", metadata: Entry.Metadata(location: nil, temperature: nil))
            }

            return loadedEntry
        } catch {
            handleError(error)
            return nil
        }
    }

    // MARK: - Publishers and Subscripbers
    var locationManager = LocationManager()
    var subscriptions = Set<AnyCancellable>()
    func setupPublishers() {
        let metadataPublishers = MetadataPublishers(locationPublisher: locationManager.location)

        // 1. save location
        metadataPublishers.locationPublisher
            .map(\.coordinate)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { location in
                    DispatchQueue.main.async {
                        let metadata = self.currentEntry?.metadata ?? Entry.Metadata(location: nil, temperature: nil)
                        metadata.location = location
                        self.saveContext(metadata: metadata)
                    }
                  })
            .store(in: &subscriptions)

        // 2. Fetch temperatue, save, & display in metadata view
        metadataPublishers.temperaturePublisher
            .map(\.main.temp)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { temperature in
                    DispatchQueue.main.async {
                        // save to entry
                        let metadata = self.currentEntry?.metadata ?? Entry.Metadata(location: nil, temperature: nil)
                        metadata.temperature = temperature
                        self.saveContext(metadata: metadata)

                        // update metadata label
                        let measurement = Measurement(value: temperature, unit: UnitTemperature.celsius)
                        self.entryView.metadataView.temperatureText = MeasurementFormatter().string(from: measurement)
                    }
                  })
            .store(in: &subscriptions)

        // 3. Fetch location string & display in metadata view
        metadataPublishers.placemarkPublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { location in DispatchQueue.main.async { self.entryView.metadataView.locationText = location } })
            .store(in: &subscriptions)
    }

    // MARK: - View setup

    // stylize picker and refresh view
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        entryView.picker.stylize()
        selectDate(sender: nil)
        entryView.showPlaceholderIfNecessary()
    }


    // Load view
    let entryView = EntryView()
    override func loadView() {
        entryView.advanceButton.addTarget(self, action: #selector(changeDate), for: .touchUpInside)
        entryView.picker.addTarget(self, action: #selector(selectDate), for: UIControl.Event.valueChanged)
        entryView.previousButton.addTarget(self, action: #selector(changeDate), for: .touchUpInside)

        entryView.textViewPlaceholderDelegate.onBegin = locationManager.startMonitoring
        entryView.textViewPlaceholderDelegate.onChange = saveContext(body:)
        entryView.textViewPlaceholderDelegate.onEnd = locationManager.stopMonitoring

        entryView.titleViewDelegate.onBegin = locationManager.startMonitoring
        entryView.titleViewDelegate.onCommit = { title in
            self.locationManager.stopMonitoring()
            self.saveContext(title: title)
        }

        view = entryView

        setupPublishers()
    }

    // Save context
    func saveContext(body: String) {
        guard let currentEntry = currentEntry else { return }
        guard currentEntry.content != body else { return }

        currentEntry.content = body
        do {
            try entryProvider.save(currentEntry)
        } catch {
            handleError(error)
        }
    }

    func saveContext(title: String) {
        guard let currentEntry = currentEntry else { return }
        guard currentEntry.title != title else { return }

        currentEntry.title = title
        do {
            try entryProvider.save(currentEntry)
        } catch {
            handleError(error)
        }
    }
    
    func saveContext(metadata: Entry.Metadata) {
        guard let currentEntry = currentEntry else { return }
        currentEntry.metadata = metadata
        do {
            try entryProvider.save(currentEntry)
        } catch {
            handleError(error)
        }
    }

    // Handle saving error
    func handleError(_ error: Error? = nil, function: String = #function) {
        let alert = UIAlertController(title: "Failed to save!",
                                      message: "There was an unknown problem attempting to save this entry. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        alert.addAction(UIAlertAction(title: "Details", style: .default, handler: { _ in
            let infoalert = UIAlertController(title: "Reported exception",
                                              message: error?.localizedDescription ?? "Unknown exception at \(function)",
                                              preferredStyle: .alert)
            infoalert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(infoalert, animated: true)
        }))

        present(alert, animated: true)
    }

    // refresh the entire view
    private func refreshView() {
        // there is an entry to display, either because there is a saved entry
        entryView.hasEntry = currentEntry != nil

        // make the text views editable when the user
        // is in the view for the current date & start location
        // manager
        if calendar.isDateInToday(currentDate) {
            entryView.isEditable = true
            entryView.advanceButton.isEnabled = false
        } else {
            entryView.isEditable = false
            entryView.advanceButton.isEnabled = true
        }
    }

    
    // MARK: - Intents

    @objc func changeDate(sender: UIButton) {
        entryView.textView.resignFirstResponder()
        let newDate = calendar.date(byAdding: .day, value: sender.tag, to: currentDate)!
        if calendar.startOfDay(for: newDate) > calendar.startOfDay(for: Date()) { return } // don't go into the future
        entryView.picker.setDate(newDate, animated: false)
        selectDate(sender: nil)
    }

    @objc func selectDate(sender: Any?) {
        if let entry = currentEntry {
            entryView.titleView.text = entry.title
            entryView.textView.text = entry.content

            entryView.metadataView.locationText = ""
            entryView.metadataView.temperatureText = ""

            if let location = entry.metadata.location {
                let geocoder = CLGeocoder()

                if let degrees = entry.metadata.temperature {
                    let measurement = Measurement(value: degrees, unit: UnitTemperature.celsius)
                    let temperature = MeasurementFormatter().string(from: measurement)

                    entryView.metadataView.temperatureText = temperature
                }


                geocoder.reverseGeocodeLocationPublisher(location.location())
                    .map(\.formattedString)
                    .sink(receiveCompletion: { _ in },
                          receiveValue: { placemark in
                            self.entryView.metadataView.locationText = placemark
                    })
                    .store(in: &self.subscriptions)
            }
        } else {
            entryView.titleView.text = ""
            entryView.metadataView.locationText = ""
            entryView.metadataView.temperatureText = ""
        }

        entryView.picker.stylize()
        refreshView()
    }
}
