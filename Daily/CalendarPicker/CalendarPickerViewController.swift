//
//  CalendarPickerViewController.swift
//  Daily
//
//  Created by Diogo Silva on 11/15/20.
//

import UIKit

class CalendarPickerViewController<CollectionManager: CalendarPickerViewCollectionManager>: UIViewController {
    private var collectionView: UICollectionView!
    private var collectionManager: CollectionManager!

    // Set tab bar item on init
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 2)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 2)
    }

    // create view
    override func loadView() {
        view = UIView()

        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(UIView()) // spacer


        let yearSelector = UIStackView()
        yearSelector.axis = .horizontal
        yearSelector.spacing = 20
        yearSelector.distribution = .equalSpacing

        yearSelector.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        yearSelector.isLayoutMarginsRelativeArrangement = true

        let previousYearButton = UIButton()
        previousYearButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        yearSelector.addArrangedSubview(previousYearButton)


        let yearLabel = UILabel()
        yearLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        yearLabel.text = "2020"

        yearSelector.addArrangedSubview(yearLabel)


        let nextYearButton = UIButton()
        nextYearButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        yearSelector.addArrangedSubview(nextYearButton)

        stack.addArrangedSubview(yearSelector)
        stack.spacing = 15

        //UIRect stack.frame.width

        // setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        // colection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
//        collectionView.translatesAutoresizingMaskIntoConstraints = false

        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 40)

        if isModalInPresentation {
            collectionView.backgroundColor = .systemGroupedBackground
            stack.backgroundColor = .systemGroupedBackground
            stack.layer.cornerRadius = 20
            collectionView.layer.cornerRadius = 20

            let dismissGesture = CustomAreaTapGestureRecognizer(ignoringView: stack, target: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(dismissGesture)
        } else {
            collectionView.backgroundColor = .systemBackground
            view.backgroundColor = .systemBackground
        }

        // constrain
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(collectionView)
        view.addSubview(stack)
        if isModalInPresentation {
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
                stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
                stack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
            ])
        } else {
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                stack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
            ])
        }

        // register view with manager
        collectionManager = CollectionManager.register(collectionView)// as! CollectionManager
    }
}

extension Calendar {
    func firstWeekday(ofMonth baseDate: Date) -> Int {
        let firstDayOfMonth = date(from: dateComponents([.year, .month], from: baseDate))!
        return component(.weekday, from: firstDayOfMonth)
    }
}

