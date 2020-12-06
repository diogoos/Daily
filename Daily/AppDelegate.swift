//
//  AppDelegate.swift
//  Daily
//
//  Created by Diogo Silva on 11/07/20.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // enable biometric app locking via flag
        if CommandLine.arguments.contains("--enable-biometric-locking") {
            Self.isLockingEnabled = true
        }

        resetToday: if CommandLine.arguments.contains("--reset-today-entry") {
            let provider = CoreDataEntryProvider()
            let calendar = Calendar.current
            guard let todayEntries = try? provider.entries(where: {
                calendar.isDateInToday($0.date)
            }) else { break resetToday }

            // delete the entries
            todayEntries.forEach({
                try? provider.delete($0)
            })

        }

        // remove exports temp saved in documents
        DispatchQueue.global(qos: .background).async {
            let fileManager = FileManager()
            guard let documentFolder = try? fileManager.url(for: .documentDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true) else { return }

            guard let documents = try? fileManager.contentsOfDirectory(at: documentFolder,
                                                                       includingPropertiesForKeys: nil) else { return }

            // find only temporary exports (json & has "daily-export-")
            let exports = documents.filter { return $0.pathExtension == "json" && $0.path.contains("daily-export-") }
            exports.forEach { try? fileManager.removeItem(at: $0) }
        }

        return true
    }
}
