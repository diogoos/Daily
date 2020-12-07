//
//  UIViewController+Tab.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import UIKit

extension UIViewController {
    static func tab(title: String, systemImage: String, tag: Int) -> Self {
        let vc = Self()
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: systemImage), tag: tag)
        return vc
    }

    func tab(title: String, systemImage: String, tag: Int) -> Self {
        tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: systemImage), tag: tag)
        return self
    }
}
