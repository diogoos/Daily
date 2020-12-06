//
//  CustomAreaTapGestureRecognizer.swift
//  Daily
//
//  Created by Diogo Silva on 11/20/20.
//

import UIKit

final class CustomAreaTapGestureRecognizer: UITapGestureRecognizer {
    var target: ()->()
    var ignoredView: UIView

    init(ignoringView: UIView, target: @escaping ()->()) {
        self.target = target
        self.ignoredView = ignoringView

        super.init(target: nil, action: nil)

        addTarget(self, action: #selector(_didTap))
        cancelsTouchesInView = false
    }

    @objc private func _didTap(sender: UITapGestureRecognizer) {
        guard let unwrappedView = view else {
            NSLog("\(NSStringFromClass(Self.self)): tap identified, but not associated to a view: ignoring gesture")
            return
        }

        if (sender.state == UIGestureRecognizer.State.ended) { // if tap has ended
            let location: CGPoint = sender.location(in: unwrappedView) // get tap of point in view
            let point = unwrappedView.convert(location, to: ignoredView) // convert to location of point inside ignored view
            if !ignoredView.point(inside: point, with: nil) { // if point tapped outside of ignored view
                target() // call desired action
            }
        }
    }
}
