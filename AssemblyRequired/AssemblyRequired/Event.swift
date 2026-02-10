//
//  Event.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import Foundation

struct EventsResponse: Decodable {
    let data: [Event]
}

struct Event: Decodable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let startsAt: String?
    let endsAt: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case status
    }

    // MARK: - Computed Date Helpers

    var startsDate: Date? {
        DateFormatting.parseISO8601(startsAt)
    }

    var endsDate: Date? {
        DateFormatting.parseISO8601(endsAt)
    }
}

