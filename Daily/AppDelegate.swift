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

        // reset the current entry via flag
        resetToday: if env("--reset-today-entry") {
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

        // reset user preferences via flag
        if env("--reset-user-preferences") {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "requiresLocalAuthenticationToUnlock")
            defaults.removeObject(forKey: "selectedColorScheme")
            defaults.removeObject(forKey: "locationAssociationDisabled")
        }

        // remove exports temp saved in documents
        DispatchQueue.global(qos: .background).async {
            let fileManager = FileManager()
            guard let documentFolder = try? fileManager.url(for: .cachesDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true) else { return }

            guard let caches = try? fileManager.contentsOfDirectory(at: documentFolder,
                                                                    includingPropertiesForKeys: nil) else { return }

            // find only temporary exports (json & has "daily-export-")
            let exports = caches.filter { return $0.pathExtension == "json" && $0.path.contains("daily-export-") }
            exports.forEach { try? fileManager.removeItem(at: $0) }
        }


        return true
    }
}
