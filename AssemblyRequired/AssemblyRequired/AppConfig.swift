import Foundation

enum AppConfig {
    #if DEBUG
    static let apiBaseURL = URL(string: "http://localhost")!
    #else
    static let apiBaseURL = URL(string: "https://YOUR_DOMAIN_HERE")!
    #endif
}


//
//  AppConfig.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

