//
//  utils.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 23/03/25.
//

import Foundation

func addDays(to date: Date, days: Int) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
}
