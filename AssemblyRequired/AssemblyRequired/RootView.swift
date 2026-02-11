//
//  RootView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthStore

    var body: some View {
        Group {
            if auth.jwt == nil {
                // Replace with your real login view if you have one.
                // If MeView contains the sign-in button, you can show MeView here instead.
                MeView()
            } else {
                TabView {
                    EventsView()
                        .tabItem { Label("Events", systemImage: "calendar") }

                    MeView()
                        .tabItem { Label("Me", systemImage: "person.crop.circle") }
                }
            }
        }
    }
}

