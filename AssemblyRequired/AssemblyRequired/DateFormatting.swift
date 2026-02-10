//
//  DateFormatting.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import Foundation

enum DateFormatting {
    // Handles: 2026-02-10T21:54:23.282963Z
    private static let isoWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    // Handles: 2026-02-10T21:54:23Z
    private static let isoNoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    static func parseISO8601(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        return isoWithFractional.date(from: value) ?? isoNoFractional.date(from: value)
    }

    /// Friendly display like:
    /// Today • 3:10 PM
    /// Tue • 7:00 PM
    /// Feb 21 • 10:00 AM
    static func friendly(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        let time = DateFormatter()
        time.locale = .current
        time.timeStyle = .short
        time.dateStyle = .none

        if calendar.isDateInToday(date) {
            return "Today • \(time.string(from: date))"
        }

        if let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: date)
        ).day, days >= 1 && days <= 6 {
            let dow = DateFormatter()
            dow.locale = .current
            dow.setLocalizedDateFormatFromTemplate("EEE")
            return "\(dow.string(from: date)) • \(time.string(from: date))"
        }

        let md = DateFormatter()
        md.locale = .current
        md.setLocalizedDateFormatFromTemplate("MMM d")
        return "\(md.string(from: date)) • \(time.string(from: date))"
    }
}
