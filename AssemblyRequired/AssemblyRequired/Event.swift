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
    let starts_at: String?
    let ends_at: String?
    let status: String?
}
