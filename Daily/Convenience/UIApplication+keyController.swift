//
//  UIApplication+keyController.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import UIKit

extension UIApplication {
    // get the key view controller currently being presented
    var keyController: UIViewController? {
        (self.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
}
