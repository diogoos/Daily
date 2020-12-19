//
//  AuthRetryButton.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import UIKit

class AuthRetryButton: UIButton {
    static let tag = 0x10CC_1ABE1

    convenience init() {
        self.init(type: .system)

        translatesAutoresizingMaskIntoConstraints = false
        setTitle("Retry authentication", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
        tag = Self.tag
    }
}

