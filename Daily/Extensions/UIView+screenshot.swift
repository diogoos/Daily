//
//  UIView+screenshot.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import UIKit

extension UIView {
    func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
