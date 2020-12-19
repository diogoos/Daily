//
//  TextView.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    let text: String
    init(_ text: String) { self.text = text }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isScrollEnabled = true
        view.text = text
        view.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        view.isEditable = false
        view.showsVerticalScrollIndicator = false
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {}
}
