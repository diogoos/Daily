//
//  EntryView.swift
//  Daily
//
//  Created by Diogo Silva on 12/03/20.
//

import UIKit

class EntryView: UIView {
    // MARK: - View components
    lazy var headerView: UIStackView = {
        var headerView = UIStackView(arrangedSubviews: [previousButton, picker, advanceButton])
        headerView.axis = .horizontal
        headerView.distribution = .equalSpacing
        headerView.setCustomSpacing(1, after: previousButton) // for whatever reason, setting `1` here will center the picker

        // dismiss gesture
        let dismissKeyboardRecognizer = UITapGestureRecognizer()
        dismissKeyboardRecognizer.addTarget(textView, action: #selector(resignFirstResponder))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(dismissKeyboardRecognizer)

        return headerView
    }()

    // MARK: Header Views
    var advanceButton: UIButton = {
        let advanceButton = UIButton()
        advanceButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        advanceButton.tag = 1
        advanceButton.accessibilityLabel = "Next entry"
        advanceButton.accessibilityIdentifier = "entries-header-nextEntryButton"
        return advanceButton
    }()

    var picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        return picker
    }()

    var previousButton: UIButton = {
        let previousButton = UIButton()
        previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousButton.tag = -1
        previousButton.accessibilityLabel = "Previous entry"
        previousButton.accessibilityIdentifier = "entries-header-previousEntryButton"
        return previousButton
    }()

    // MARK: Title & Metadata
    lazy var titleViewDelegate = TextFieldReturnNextResponderDelegate(nextResponder: textView)
    var textViewPlaceholderDelegate = TextViewAutoPlaceholderDelegate()

    lazy var titleView: UITextField = {
        let titleView = UITextField()
        titleView.placeholder = "Title"
        titleView.font = UIFont.preferredFont(forTextStyle: .title2)
        titleView.adjustsFontForContentSizeCategory = true
        titleView.returnKeyType = .next
        titleView.delegate = titleViewDelegate
        return titleView
    }()

    var metadataView: MetadataLabel = {
        let metadataView = MetadataLabel()
        metadataView.textColor = .secondaryLabel
        metadataView.text = "" // only show label if appropriate text
        metadataView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        metadataView.adjustsFontForContentSizeCategory = true
        return metadataView
    }()

    // MARK: Text Input View
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.allowsEditingTextAttributes = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.insetsLayoutMarginsFromSafeArea = false
        textView.delegate = textViewPlaceholderDelegate
        return textView
    }()

    // MARK: No entry label
    var noEntriesLabel: UILabel = {
        let noEntriesLabel = UILabel()
        noEntriesLabel.text = "No entries for this date"
        noEntriesLabel.translatesAutoresizingMaskIntoConstraints = false
        return noEntriesLabel
    }()

    lazy var mainStack: UIStackView = {
        let mainStack = UIStackView(arrangedSubviews: [headerView, titleView, metadataView, textView])
        mainStack.axis = .vertical
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.setCustomSpacing(10, after: headerView)
        return mainStack
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }

    private func createSubviews() {
        backgroundColor = .systemBackground
        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])


        // no entries label
        addSubview(noEntriesLabel)
        NSLayoutConstraint.activate([
            noEntriesLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            noEntriesLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    // MARK: - Actions
    private func disableInput() {
        textView.isEditable = false
        titleView.isEnabled = false
        textView.textColor = nil
    }

    private func enableInput() {
        textView.isEditable = true
        titleView.isEnabled = true
    }

    func showPlaceholderIfNecessary() {
        textViewPlaceholderDelegate.textViewDidEndEditing(textView)
    }

    private func hide() {
        titleView.isHidden = true
        metadataView.isHidden = true
        textView.text = ""
        noEntriesLabel.isHidden = false
    }

    private func show() {
        titleView.isHidden = false
        metadataView.isHidden = false
        noEntriesLabel.isHidden = true
        showPlaceholderIfNecessary()
    }

    // MARK: - Global switches
    var isEditable: Bool = false {
        didSet {
            if isEditable { enableInput() }
            else { disableInput() }
        }
    }

    var hasEntry: Bool = false {
        didSet {
            if hasEntry { show() }
            else { hide() }
        }
    }
}

class MetadataLabel: UILabel {
    var locationText: String = "" {
        didSet { makeLabel() }
    }

    var temperatureText: String = "" {
        didSet { makeLabel() }
    }

    func makeLabel() {
        switch (!locationText.isEmpty, !temperatureText.isEmpty) {
        case (true, true): text = locationText + " - " + temperatureText // both location & temperature are present
        case (true, false): text = locationText // only location is present
        case (false, true): text = temperatureText // only temperature is present
        case (false, false): text = "" // neither location nor temperature is present
        }
    }
}
