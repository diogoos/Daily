//
//  UIDatePicker+Stylize.swift
//  Daily
//
//  Created by Diogo Silva on 12/03/20.
//

import UIKit

extension UIDatePicker {
    // very weird hack to remove the background selection halo around the date
    // and sets the label text color to, well, .label. This is a hacky-hack!
    // It can break very easily, and it is far from ideal. However, it works
    // perfectly fine right now, and there's still no crashing, so...
    func stylize(recursed: UIView? = nil) {
        let view: UIView = recursed ?? self

        for subview in view.subviews {
            if subview.backgroundColor != nil && subview.layer.cornerRadius > 0 {
                subview.backgroundColor = .systemBackground // override background colors of all cornered elements that already have a background color
            }

            if subview.isKind(of: UILabel.self), let subview = subview as? UILabel {
                subview.tintColor = .label // for whatever reason, setting the .textColor attribute doesn't work here, so instead we will set the tintColor, which will be reflected upon the label. again, subject to easy breakage.
            }

            stylize(recursed: subview)
        }
    }
}
