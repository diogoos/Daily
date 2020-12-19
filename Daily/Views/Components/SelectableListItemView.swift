//
//  SelectableListItemView.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import SwiftUI

struct SelectableListItem<T: Equatable>: View {
    var text: String

    var value: T
    @Binding var binding: T

    init(_ text: String, value: T, for binding: Binding<T>) {
        self.text = text
        self.value = value
        self._binding = binding
    }

    var body: some View {
        Button(action: { binding = value }) {
            HStack {
                Text(text)
                    .foregroundColor(Color.primary)

                Spacer()

                if binding == value {
                    Image(systemName: "checkmark")
                        .renderingMode(.template)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
