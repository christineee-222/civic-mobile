//
//  MeView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct MeView: View {
    @EnvironmentObject private var auth: AuthStore
    @State private var output: String = "Not signed in."
    @State private var isBusy = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                if auth.jwt != nil {
                    Button("Refresh /me") {
                        Task { await loadMe() }
                    }
                    .disabled(isBusy)

                    Button("Sign Out") {
                        auth.signOut()
                        output = "Signed out."
                    }
                    .disabled(isBusy)
                } else {
                    Button(auth.isAuthenticating ? "Signing in..." : "Sign In") {
                        Task { await signIn() }
                    }
                    .disabled(auth.isAuthenticating || isBusy)
                }

                ScrollView {
                    Text(output)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxHeight: 420)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Me")
            .onAppear {
                if auth.jwt != nil && output == "Not signed in." {
                    Task { await loadMe() }
                }
            }
        }
    }

    private func signIn() async {
        isBusy = true
        defer { isBusy = false }

        do {
            output = "Opening login…"
            try await auth.signIn()
            output = "✅ Signed in. Loading /me…"
            await loadMe()
        } catch {
            output = "❌ Sign-in error: \(error.localizedDescription)"
        }
    }

    private func loadMe() async {
        guard let jwt = auth.jwt else {
            output = "Not signed in."
            return
        }

        isBusy = true
        defer { isBusy = false }

        do {
            output = try await AuthAPI.shared.fetchMe(jwt: jwt)
        } catch let apiErr as APIError {
            if case .unauthenticated = apiErr {
                auth.signOut()
            }
            output = "❌ \(apiErr.localizedDescription)"
        } catch {
            output = "❌ /me error: \(error.localizedDescription)"
        }
    }
}
