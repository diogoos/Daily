//
//  CalendarPickerViewCollectionManager.swift
//  Daily
//
//  Created by Diogo Silva on 11/20/20.
//

import UIKit

class CalendarPickerViewCollectionManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    // initalize calendar and the year
    private let calendar = Calendar.autoupdatingCurrent
    private(set) var calendarYear: Int = Calendar.current.component(.year, from: Date())

    // set a custom calendar year
    func setCalendarYear(_ year: Int, for collectionView: UICollectionView) {
        calendarYear = year
        collectionView.reloadData()
    }

    // initalize a manager by registering the components to the view
    // and setting its delegate and data source
    static func register(_ collectionView: UICollectionView) -> Self {
        collectionView.register(CalendarDayCollectionViewCell.self,
                                forCellWithReuseIdentifier: CalendarDayCollectionViewCell.reuseIdentifier)
        collectionView.register(EmptyCollectionViewCell.self,
                                forCellWithReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier)
        collectionView.register(SectionHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier)

        let manager = Self.init()

        collectionView.allowsSelection = true
        collectionView.delegate = manager
        collectionView.dataSource = manager

        return manager
    }

    // we should only allow this to be initalized by using the register(collectionView:) method
    // to make sure that the reuse components are always registered and that
    // selection is enabled by default
    override required init() { super.init() }

    // generate headers for the months
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        // only register headers
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderCollectionReusableView.reuseIdentifier, for: indexPath)
            sectionHeader.accessibilityLabel = calendar.monthSymbols[indexPath.section]
//            sectionHeader.label.text = calendar.monthSymbols[indexPath.section]
            return sectionHeader
        } else {
            return UICollectionReusableView()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        DateFormatter().monthSymbols.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var components = DateComponents()
        components.month = section+1
        components.year = calendarYear
        let date = calendar.date(from: components)!
        let numOfDays = calendar.range(of: .day, in: .month, for: date)!.upperBound-1

        // add padding to adjust for start of month
        return numOfDays + paddingForMonth(section + 1)
    }

    func paddingForMonth(_ month: Int) -> Int {
        var components = DateComponents()
        components.month = month
        components.year = calendarYear
        let monthDate = calendar.date(from: components)!
        let padding = calendar.firstWeekday(ofMonth: monthDate) - 1 // FIXME: proper localization needed
        return padding
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let padding = paddingForMonth(indexPath.section + 1)

        // empty out the padding
        if (0..<padding).contains(indexPath.row) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath)
        }

        // return actual dates
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCollectionViewCell.reuseIdentifier, for: indexPath) as! CalendarDayCollectionViewCell
        cell.day = indexPath.row-padding+1
        cell.isSelected = false

        return cell
    }

    // Only allow actual dates to be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return collectionView.cellForItem(at: indexPath)?.isKind(of: CalendarDayCollectionViewCell.self) ?? false
    }
}
