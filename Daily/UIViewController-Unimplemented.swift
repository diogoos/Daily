//
//  UIViewController-Unimplemented.swift
//  Daily
//
//  Created by Diogo Silva on 11/13/20.
//

import UIKit

#if DEBUG
extension UIViewController {
    func unimplementedAlert(_ function: String = #function) {
        let alert = UIAlertController(title: "Unimplemented",
                                      message: "Function \(function) is not yet implemented.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
#endif
