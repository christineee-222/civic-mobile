import Foundation

enum AppConfig {
    static var apiBaseURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: raw)
        else {
            fatalError("Missing or invalid API_BASE_URL")
        }

        #if !DEBUG
        precondition(url.scheme == "https",
                     "Release builds must use HTTPS")
        #endif

        return url
    }
}




//
//  AppConfig.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

