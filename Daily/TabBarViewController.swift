//
//  TabBarViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/14/20.
//

import UIKit
import SwiftUI

class TabBarViewController: UITabBarController {
    lazy var entryViewController: EntryViewController<CoreDataEntryProvider> = {
        let vc = EntryViewController<CoreDataEntryProvider>()
        vc.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "book.closed.fill"), tag: 0)
        return vc
    }()

    lazy var mapViewController: MapViewController = {
        let vc = MapViewController()
        vc.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        return vc
    }()

    lazy var calendarViewController: BuiltinCalendarViewController = {
        let vc = BuiltinCalendarViewController()
        vc.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 2)
        return vc
    }()

    lazy var settingsViewController: UIHostingController<SettingsView<CoreDataEntryProvider>> = {
        let vc = UIHostingController(rootView: SettingsView<CoreDataEntryProvider>())
        vc.rootView.viewController = vc
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
        return vc
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [entryViewController, mapViewController, calendarViewController, settingsViewController]
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewControllers = [entryViewController, mapViewController, calendarViewController, settingsViewController]
    }
}

class BuiltinCalendarViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 2)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 2)
    }

    override func loadView() {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.backgroundColor = .systemBackground
        view = picker
    }
}
