//
//  AssemblyRequiredApp.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

@main
struct AssemblyRequiredApp: App {
    @StateObject private var auth = AuthStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}

