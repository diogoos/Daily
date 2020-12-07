//
//  Calendar+Range.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import Foundation

extension Calendar {
    func range(of period: Calendar.Component, in baseDate: Date) -> Range<Date>? {
        var cStartDate: NSDate? = nil
        (self as NSCalendar).range(of: .day, start: &cStartDate, interval: nil, for: baseDate)

        guard let startDate = cStartDate as Date? else { return nil }
        guard let endDate = date(byAdding: period, value: 1, to: startDate as Date) else { return nil }

        return startDate..<endDate
    }
}

