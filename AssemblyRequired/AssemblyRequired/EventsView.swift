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
            VStack(spacing: 12) {

                Button(isBusy ? "Loading…" : "Load Events") {
                    Task { await loadEvents() }
                }
                .disabled(isBusy || auth.jwt == nil)

                if auth.jwt == nil {
                    Text("Sign in to load events.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if !output.isEmpty && output != "Tap Load Events" {
                    Text(output)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                List(events) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title)
                            .font(.headline)

                        if let desc = event.description, !desc.isEmpty {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        if let start = event.startsDate {
                            Text(DateFormatting.friendly(start))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Date TBD")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .navigationTitle("Events")
        }
    }

    private func loadEvents() async {
        isBusy = true
        output = ""
        defer { isBusy = false }

        do {
            events = try await APIClient.shared.fetchEvents(jwt: auth.jwt)
            if events.isEmpty {
                output = "No events yet."
            }
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



