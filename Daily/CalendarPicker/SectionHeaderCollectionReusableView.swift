//
//  SectionHeaderCollectionReusableView.swift
//  Daily
//
//  Created by Diogo Silva on 11/20/20.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = NSStringFromClass(SectionHeaderCollectionReusableView.self)

    private var label = UILabel()
    override var accessibilityLabel: String? {
        didSet {
            label.text = accessibilityLabel
        }
    }

    override func layoutSubviews() {
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.sizeToFit()
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 5),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
}
