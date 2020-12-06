//
//  SettingsView.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import SwiftUI
import LocalAuthentication

struct SettingsView<Provider: EntryProvider>: View {
    @AppStorage("requiresLocalAuthenticationToUnlock") var authToUnlock = false
    @State var confirmDeletion = false
    var viewController: UIViewController? = nil
    var provider = Provider()
    @State var isExporting: Bool = false

    @AppStorage("selectedColorScheme") var colorScheme: UIUserInterfaceStyle = .unspecified {
        didSet {
            UIApplication.shared.keyController?.overrideUserInterfaceStyle = colorScheme
        }
    }
//    enum ColorScheme {
//        case system, light, dark
//    }

    var biometryType: String? {
        let type = LAContext().biometryType
        switch type {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return nil
        @unknown default: return "biometrics"
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Privacy")) {
                    if let biometry = biometryType {
                        Toggle("Require \(biometry) to unlock", isOn: $authToUnlock)
                    }
                    Toggle("Save location to entries", isOn: .constant(true))
                }

                Section(header: Text("Color scheme")) {
                    ListSelection(text: "System",
                                  isActive: { colorScheme == .unspecified },
                                  setActive: { colorScheme = .unspecified })

                    ListSelection(text: "Light",
                                  isActive: { colorScheme == .light },
                                  setActive: { colorScheme = .light })

                    ListSelection(text: "Dark",
                                  isActive: { colorScheme == .dark },
                                  setActive: { colorScheme = .dark })
                }

                Section(header: Text("Storage")) {
                    Toggle("Enable iCloud synchronization", isOn: .constant(false))
                    Button("Export Entries", action: {
                        // get all data from provider
                        isExporting = true

                        guard let entries = try? provider.allEntries() else { isExporting = false; return }
                        let encoder = JSONEncoder()
                        encoder.dateEncodingStrategy = .iso8601
                        guard let json = try? encoder.encode(entries) else { isExporting = false; return }
                        guard let exportedData = String(data: json, encoding: .utf8) else { isExporting = false; return }

                        // save to a file
                        guard let documentsDirectoryURL = try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { isExporting = false; return }
                        let fileURL = documentsDirectoryURL.appendingPathComponent("daily-export-\(Int(Date().timeIntervalSince1970)).json")
                        do {
                            try exportedData.write(to: fileURL, atomically: false, encoding: .utf8)
                        } catch {
                            isExporting = false
                            return
                        }

                        isExporting = false
                        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        viewController?.present(activityViewController, animated: true)
                    })

                    Button("Delete all entries", action: {
                        confirmDeletion.toggle()
                    })
                        .foregroundColor(.red)
                }

                Section(header: Text("About")) {
                    NavigationLink("License", destination: AcknowledgementsView())
                }
            }
            .overlay(Group {
                if isExporting {
                    ProgressView("Exporting")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(40)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(15)
                } else {
                    EmptyView()
                }
            })
            .navigationTitle("Settings")
            .alert(isPresented: $confirmDeletion) {
                Alert(title: Text("Delete all entries?"),
                      message: Text("This cannot be undone later."),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Delete"), action: {
                        try? provider.deleteAll()
                      }))
            }
        }
    }
}

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

    func updateUIView(_ uiView: UITextView, context: Context) { }
}

struct AcknowledgementsView: View {
    var body: some View {
        TextView("""
MIT License

Copyright (c) 2020

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


""")
            .padding(.horizontal)
            .navigationTitle("License")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView<MockEntryProvider>()
    }
}

struct ListSelection: View {
    var text: String
    var isActive: ()->Bool
    var setActive: ()->()

    var body: some View {
        HStack {
            Text(text)
            if isActive() {
                Spacer()
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundColor(.blue)
            }
        }
        .onTapGesture(perform: setActive)
    }
}
