//
//  EventDetailView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var auth: AuthStore

    let event: Event

    @State private var rsvpStatus: RsvpStatus? = nil
    @State private var isBusy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                Text(event.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                if let start = event.startsDate {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("When")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let end = event.endsDate {
                            Text("\(DateFormatting.friendly(start)) – \(DateFormatter.localizedString(from: end, dateStyle: .none, timeStyle: .short))")
                                .font(.body)
                        } else {
                            Text(DateFormatting.friendly(start))
                                .font(.body)
                        }
                    }
                } else {
                    Text("Date TBD")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let desc = event.description, !desc.isEmpty {
                    Divider()
                    Text(desc)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                HStack {
                    Text("RSVP")
                        .font(.headline)

                    Spacer()

                    if isBusy {
                        ProgressView()
                    }
                }

                VStack(spacing: 10) {
                    ForEach(RsvpStatus.allCases) { status in
                        Button {
                            Task {
                                await rsvpTapped(status)
                            }
                        } label: {
                            HStack {
                                Text(status.label)
                                Spacer()
                                if rsvpStatus == status {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isBusy)
                    }

                    Button(role: .destructive) {
                        Task { await clearTapped() }
                    } label: {
                        Text("Clear RSVP")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isBusy || rsvpStatus == nil)
                }

            }
            .padding(16)
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let raw = event.rsvp?.status, let parsed = RsvpStatus(rawValue: raw) {
                rsvpStatus = parsed
            } else {
                rsvpStatus = nil
            }
        }
    }

    // MARK: - Actions (MainActor-safe UI updates)

    @MainActor
    private func rsvpTapped(_ status: RsvpStatus) async {

        // UX guard (APIClient also enforces auth via TokenStore).
        guard let jwt = auth.jwt, !jwt.isEmpty else {
            return
        }

        _ = jwt

        isBusy = true

        let previous = rsvpStatus
        rsvpStatus = status // optimistic UI

        do {
            _ = try await APIClient.shared.setRsvp(eventId: event.id, status: status)
        } catch let err as APIClientError {
            rsvpStatus = previous
            if case .http(let code, _) = err, code == 401 {
                auth.signOut()
            }
        } catch {
            rsvpStatus = previous
        }

        isBusy = false
    }

    @MainActor
    private func clearTapped() async {
        guard let jwt = auth.jwt, !jwt.isEmpty else {
            return
        }

        _ = jwt

        isBusy = true

        let previous = rsvpStatus
        rsvpStatus = nil // optimistic UI

        do {
            try await APIClient.shared.clearRsvp(eventId: event.id)
        } catch let err as APIClientError {
            rsvpStatus = previous
            if case .http(let code, _) = err, code == 401 {
                auth.signOut()
            }
        } catch {
            rsvpStatus = previous
        }

        isBusy = false
    }
}




