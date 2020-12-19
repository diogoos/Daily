//
//  TabBarViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/14/20.
//

import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {
    // Data provider
    static let provider = CoreDataEntryProvider()

    // Tab view controllers
    let entryViewController = EntryViewController(provider: provider).tab(title: "Entries", systemImage: "book.closed.fill", tag: 0)
    let mapViewController = MapViewController(provider: provider).tab(title: "Map", systemImage: "map", tag: 1)

    // Settings view requires further initalization
    lazy var settingsView = SettingsView(viewController: self, provider: Self.provider)
    lazy var settingsViewController = UIHostingController(rootView: settingsView).tab(title: "Settings", systemImage: "gear", tag: 3)

    // Initalize
    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [entryViewController, mapViewController, settingsViewController]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set display mode
        let displayMode = UserDefaults.standard.integer(forKey: "selectedColorScheme") // defaults to 0 (aka unspecified)
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: displayMode) ?? .unspecified
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewControllers = [entryViewController, mapViewController, settingsViewController]
    }
}
