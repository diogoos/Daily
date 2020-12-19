//
//  SubtitleTableViewCell.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    static let reuseIdentifier = NSStringFromClass(SubtitleTableViewCell.self)
    var associatedEntry: Entry? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

