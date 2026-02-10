//
//  RootView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var auth = AuthStore.shared

    var body: some View {
        TabView {
            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }

            MeView()
                .tabItem { Label("Me", systemImage: "person.crop.circle") }
        }
        .environmentObject(auth)
    }
}
