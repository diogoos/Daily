//
//  LicenseView.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import SwiftUI

struct LicenseView: View {
    var body: some View {
        let license = Bundle.main.url(forResource: "LICENSE", withExtension: nil)!
        let licenseText = try! String(contentsOf: license)

        return TextView(licenseText)
            .padding(.horizontal)
            .navigationTitle("License")
    }
}
