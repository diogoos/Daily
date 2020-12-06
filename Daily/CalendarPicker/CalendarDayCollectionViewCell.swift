//
//  CalendarDayCollectionViewCell.swift
//  Daily
//
//  Created by Diogo Silva on 11/20/20.
//

import UIKit

class CalendarDayCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = NSStringFromClass(CalendarDayCollectionViewCell.self)

    var day: Int?
    let label = UILabel()

    var selectionBubble = UIView()
    let selectionBubbleSize: CGFloat = 30

    // Update view on selection and de-selection
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectionBubble.isHidden = false
                label.textColor = .white
            } else {
                selectionBubble.isHidden = true
                label.textColor = .label
            }
        }
    }

    override func layoutSubviews() {
        // create background highlight bubble
        selectionBubble.backgroundColor = .red
        selectionBubble.clipsToBounds = true
        selectionBubble.translatesAutoresizingMaskIntoConstraints = false
        selectionBubble.layer.cornerRadius = selectionBubbleSize/2

        contentView.addSubview(selectionBubble)
        NSLayoutConstraint.activate([
            selectionBubble.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBubble.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBubble.widthAnchor.constraint(equalToConstant: selectionBubbleSize),
            selectionBubble.heightAnchor.constraint(equalToConstant: selectionBubbleSize),
        ])

        // create label with the current date
        label.text = "\(day!)" // FIXME: Force unwrap
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}
