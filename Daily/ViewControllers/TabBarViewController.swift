//
//  TabBarViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/14/20.
//

import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {
    // Tab view controllers
    let entryViewController = EntryViewController<CoreDataEntryProvider>.tab(title: "Entries", systemImage: "book.closed.fill", tag: 0)
    let mapViewController = MapViewController.tab(title: "Map", systemImage: "map", tag: 1)

    // Settings view requires further initalization
    lazy var settingsView = SettingsView(viewController: self, provider: CoreDataEntryProvider())
    lazy var settingsViewController = UIHostingController(rootView: settingsView).tab(title: "Settings", systemImage: "gear", tag: 3)

    // Initalize
    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [entryViewController, mapViewController, settingsViewController]
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewControllers = [entryViewController, mapViewController, settingsViewController]
    }
}
