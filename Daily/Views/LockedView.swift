//
//  LockedView.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import UIKit

class LockedView: UIView {
    static var isFirstUnlock = true // don't show blurs when first unlocking at first launch
    let unlocked: UIView // view that should be displayed when unlocked
    private var didLayoutSubviews: Bool = false
    private var stackView = UIStackView() // mian stack

    init(unlocked: UIView, frame: CGRect) {
        self.unlocked = unlocked
        super.init(frame: frame)


        if !Self.isFirstUnlock {
            // take screenshot
            let screenshot = UIApplication.shared.keyController?.view.screenshot()
            let screenshotView = UIImageView(image: screenshot)
            addSubview(screenshotView)

            // blur the screenshot
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.frame = frame
            addSubview(blurredEffectView)

            NSLayoutConstraint.activate([
                screenshotView.leadingAnchor.constraint(equalTo: leadingAnchor),
                screenshotView.trailingAnchor.constraint(equalTo: trailingAnchor),
                screenshotView.topAnchor.constraint(equalTo: topAnchor),
                screenshotView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        Self.isFirstUnlock = false
        backgroundColor = .systemBackground
    }

    // create "authenticate to unlock" message
    override func layoutSubviews() {
        if didLayoutSubviews { return }

        didLayoutSubviews = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])

        let label = UILabel()
        label.text = "Authenticate to Unlock"
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(20, after: label)

        let retryButton = UILabel()
        retryButton.text = "Retry"
        retryButton.textColor = .systemBlue
        retryButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(retryAuth))
        retryButton.addGestureRecognizer(tapGesture)

        stackView.addArrangedSubview(retryButton)
        stackView.isHidden = true
    }

    // show retry message
    func showRetryMessage() {
        stackView.isHidden = false
    }

    // reattempt authentication
    @objc func retryAuth() {
        stackView.isHidden = true
        (UIApplication.shared.delegate as! AppDelegate).authenticate()
    }

    required init?(coder: NSCoder) {
        fatalError("Unimplemented function \(#function)")
    }
}
