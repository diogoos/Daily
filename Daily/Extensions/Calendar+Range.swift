//
//  Calendar+Range.swift
//  Daily
//
//  Created by Diogo Silva on 12/07/20.
//

import Foundation

extension Calendar {
    func range(of period: Calendar.Component, in baseDate: Date) -> Range<Date> {
        var startDate: NSDate? = nil
        (self as NSCalendar).range(of: .day, start: &startDate, interval: nil, for: baseDate)
        let endDate = date(byAdding: period, value: 1, to: startDate! as Date)

        guard startDate != nil, endDate != nil else {
            return baseDate..<(date(byAdding: period, value: 1, to: baseDate) ?? baseDate) // should never occur
        }

        return (startDate! as Date)..<endDate!
    }
}

