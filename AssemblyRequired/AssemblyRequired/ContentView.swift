//
//  ContentView.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var output = "Ready."
    @State private var jwt: String? = nil
    @State private var isBusy = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Assembly Required")
                .font(.largeTitle)

            HStack(spacing: 12) {
                Button(isBusy ? "Working..." : "Sign In") {
                    Task { await signIn() }
                }
                .disabled(isBusy)

                Button("Call /v1/me") {
                    Task { await loadMe() }
                }
                .disabled(isBusy || jwt == nil)

                Button("Ping API") {
                    Task { await ping() }
                }
                .disabled(isBusy)
            }

            ScrollView {
                Text(output)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxHeight: 380)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }

    private func signIn() async {
        isBusy = true
        defer { isBusy = false }

        do {
            output = "Opening login…"
            let code = try await AuthSession.shared.startLogin()

            output = "Exchanging code for JWT…"
            let token = try await AuthAPI.shared.exchangeCodeForJWT(code: code)
            jwt = token

            output = "✅ Got JWT (in-memory for now)\nFirst 24 chars: \(token.prefix(24))…"
        } catch {
            output = "❌ Sign-in error: \(error.localizedDescription)"
        }
    }

    private func loadMe() async {
        guard let jwt else { return }
        isBusy = true
        defer { isBusy = false }

        do {
            output = "Calling /api/v1/me…"
            output = try await AuthAPI.shared.fetchMe(jwt: jwt)
        } catch {
            output = "❌ /me error: \(error.localizedDescription)"
        }
    }

    private func ping() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let url = AppConfig.apiBaseURL.appendingPathComponent("api/ping")
            let (data, resp) = try await URLSession.shared.data(from: url)

            guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }

            output = String(data: data, encoding: .utf8) ?? "No response text"
        } catch {
            output = "❌ Ping error: \(error.localizedDescription)"
        }
    }
}



