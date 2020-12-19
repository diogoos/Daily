//
//  SettingsView.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import SwiftUI
import LocalAuthentication

struct SettingsView<Provider: EntryProvider>: View {
    // Provided by controller
    var viewController: UIViewController? = nil
    var provider = Provider()

    // Saved Settings
    @AppStorage("requiresLocalAuthenticationToUnlock") var authToUnlock = false
    @AppStorage("selectedColorScheme") var colorScheme: UIUserInterfaceStyle = .unspecified
    @AppStorage("locationAssociationDisabled") var locationAssociationDisabled: Bool = false

    // Markers
    @State var confirmDeletion = false
    @State var isExporting: Bool = false

    // Computed
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
                        Toggle("Require \(biometry) to unlock", isOn: $authToUnlock.overriding(onEnv: "activate-biometric-locking", to: true))
                            .disabled(!env("enable-biometric-locking") || env("activate-biometric-locking"))
                            .onChange(of: authToUnlock, perform: { _ in
                                LockingDelegate.isLockingEnabled = authToUnlock
                            })
                    }

                    Toggle("Save location to entries",
                           isOn: $locationAssociationDisabled
                                    .flipped()
                                    .overriding(onEnv: "always-enable-location", to: true))
                        .disabled(env("always-enable-location"))
                        .onChange(of: locationAssociationDisabled, perform: { _ in
                            LocationManager.isLocationEnabled = !locationAssociationDisabled
                        })
                }

                Section(header: Text("Color scheme")) {
                    List {
                        SelectableListItem("System", value: .unspecified, for: $colorScheme)
                        SelectableListItem("Light", value: .light, for: $colorScheme)
                        SelectableListItem("Dark", value: .dark, for: $colorScheme)
                    }
                    .onChange(of: colorScheme, perform: { _ in
                        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                window.overrideUserInterfaceStyle = colorScheme
                            }, completion: nil)
                        }
                    })
                }

                Section(header: Text("Storage")) {
                    Button("Export Entries", action: {
                        isExporting = true
                        DispatchQueue.global(qos: .userInitiated).async {
                            guard let export = provider.export() else { return }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isExporting = false

                                let activityViewController = UIActivityViewController(activityItems: [export], applicationActivities: nil)
                                viewController?.present(activityViewController, animated: true)
                            }
                        }
                    })

                    Button("Delete all entries", action: {
                        confirmDeletion.toggle()
                    })
                        .foregroundColor(.red)
                }

                Section(header: Text("About")) {
                    NavigationLink("License", destination: LicenseView())
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

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView<MockEntryProvider>()
    }
}
#endif
