//
//  ViewLocking.swift
//  Daily
//
//  Created by Diogo Silva on 11/14/20.
//

import LocalAuthentication
import UIKit


// Authenticate with local authentication & coordinate views
class LockingDelegate {
    static var isLockingEnabled = env("enable-biometric-locking") && (env("activate-biometric-locking") ||
                                  UserDefaults.standard.bool(forKey: "requiresLocalAuthenticationToUnlock"))

    static let kLockBlurView = 0x1057_10CC

    static func lock(view: UIView) {
        guard view.viewWithTag(kLockBlurView) == nil else { return } // only lock if not already locked

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = view.frame
        blurredEffectView.tag = 0x1057_10CC // LOST_LOCK
        view.addSubview(blurredEffectView)
    }

    @discardableResult static func lockCurrent() -> Bool {
        guard let keyView = UIApplication.shared.keyController?.view else { return false }
        lock(view: keyView)
        return true
    }

    private static func unlock(view: UIView) {
        guard let blurredEffectView = view.viewWithTag(0x1057_10CC) else { return } // view already unlocked
        blurredEffectView.removeFromSuperview()
    }

    @objc static func authenticate() {
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
                        if let keyView = UIApplication.shared.keyController?.view {
                            unlock(view: keyView)
                        }
                    } else {
                        // there was a problem, show retry
                        let view = UIApplication.shared.keyController!.view!

                        let retryButton = AuthRetryButton()
                        retryButton.addAction(UIAction(handler: { _ in self.authenticate() }), for: .touchUpInside)
                        view.addSubview(retryButton)
                        NSLayoutConstraint.activate([
                            retryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        ])
                    }
                }
            }
        } else {
            // no biometrics
            if let keyView = UIApplication.shared.keyController?.view {
                unlock(view: keyView)
            }
        }

        UIApplication.shared.keyController?.view.viewWithTag(AuthRetryButton.tag)?.removeFromSuperview()
    }
}
