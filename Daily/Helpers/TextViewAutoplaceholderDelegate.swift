//
//  TextViewAutoplaceholderDelegate.swift
//  Daily
//
//  Created by Diogo Silva on 12/04/20.
//

import UIKit

class TextViewAutoPlaceholderDelegate: NSObject, UITextViewDelegate {
    var onChange: ((String)->Void)?
    var onEnd: (()->Void)?
    var onBegin: (()->Void)?

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Tap to edit" && textView.textColor == .gray {
            textView.text = ""
            textView.textColor = nil
        }

        onBegin?()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Tap to edit"
            textView.textColor = .gray
        }

        onEnd?()
    }

    func textViewDidChange(_ textView: UITextView) {
        onChange?(textView.text)
    }
}
