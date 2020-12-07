//
//  ViewLocking.swift
//  Daily
//
//  Created by Diogo Silva on 11/14/20.
//

import LocalAuthentication
import UIKit

// Lock views by changing their root views
extension UIViewController {
    func lockView() {
        if self.view.isKind(of: LockedView.self) { return } // never lock twice
        self.view = LockedView(unlocked: self.view, frame: self.view.frame)
    }

    func unlockView() {
        if self.view.isKind(of: LockedView.self) {
            self.view = (self.view as! LockedView).unlocked
        }
    }
}


// Authenticate with local authentication & coordinate views
extension AppDelegate {
    static var isLockingEnabled = false

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && Self.isLockingEnabled {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                        UIApplication.shared.keyController?.unlockView()
                    } else {
                        // there was a problem
                        if UIApplication.shared.keyController?.view.isKind(of: LockedView.self) ?? false {
                            // the view is actually locked
                            let view = UIApplication.shared.keyController?.view as! LockedView?
                            view?.showRetryMessage()
                        }

                        // if the view isn't locked, we don't have to do anything
                    }
                }
            }
        } else {
            // no biometrics
            UIApplication.shared.keyController?.unlockView()
        }
    }
}

extension UIApplication {
    // get the key view controller currently being presented
    var keyController: UIViewController? {
        (self.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
}
