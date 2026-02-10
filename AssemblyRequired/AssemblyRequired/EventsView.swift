//
//  EventsView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var auth: AuthStore
    @State private var events: [Event] = []
    @State private var output = "Tap Load Events"
    @State private var isBusy = false

    var body: some View {
        NavigationStack {
            VStack {

                Button("Load Events") {
                    Task { await loadEvents() }
                }
                .disabled(isBusy || auth.jwt == nil)

                List(events) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.headline)

                        if let desc = event.description {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let starts = event.starts_at {
                            Text("Starts: \(starts)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Spacer()
            }
            .navigationTitle("Events")
        }
    }

    private func loadEvents() async {
        isBusy = true
        defer { isBusy = false }

        do {
            events = try await APIClient.shared.fetchEvents(jwt: auth.jwt)
        } catch let err as APIClientError {
            if case .http(let code, _) = err, code == 401 {
                auth.signOut()
            }
            output = err.localizedDescription
        } catch {
            output = error.localizedDescription
        }
    }
}


