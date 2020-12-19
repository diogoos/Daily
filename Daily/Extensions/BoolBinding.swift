//
//  BoolBinding.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import SwiftUI

extension Binding where Value == Bool {
    func overriding(onEnv key: String, to overrideValue: Bool) -> Self {
        if env(key) { return .constant(overrideValue) }
        return self
    }

    func flipped() -> Self {
        Binding<Bool>(
            get: { !wrappedValue },
            set: { wrappedValue = !$0 }
        )
    }
}
