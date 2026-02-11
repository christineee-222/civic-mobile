//
//  EventDetailView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event

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

                if let status = event.status, !status.isEmpty {
                    Divider()

                    HStack(spacing: 8) {
                        Text("Status")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(status)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
    }
}
