//
//  TextFieldReturnNextResponderDelegate.swift
//  Daily
//
//  Created by Diogo Silva on 12/04/20.
//

import UIKit

class TextFieldReturnNextResponderDelegate: NSObject, UITextFieldDelegate {
    var onCommit: ((String)->Void)? = nil
    var onBegin: (()->Void)? = nil
    var nextResponder: UIView

    func textFieldDidBeginEditing(_ textField: UITextField) {
        onBegin?()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextResponder.becomeFirstResponder()
        onCommit?(textField.text ?? "")
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onCommit?(textField.text ?? "")
    }

    init(nextResponder: UIView) {
        self.nextResponder = nextResponder
    }
}

