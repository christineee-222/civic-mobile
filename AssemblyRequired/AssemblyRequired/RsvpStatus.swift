//
//  RsvpStatus.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import Foundation

enum RsvpStatus: String, CaseIterable, Identifiable {
    case going = "going"
    case interested = "interested"
    case notGoing = "not_going"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .going:
            return "Going"
        case .interested:
            return "Interested"
        case .notGoing:
            return "Not going"
        }
    }
}
