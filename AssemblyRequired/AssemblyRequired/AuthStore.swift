//
//  AuthStore.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import Foundation
import Combine

@MainActor
final class AuthStore: ObservableObject {
    static let shared = AuthStore()

    @Published private(set) var jwt: String? = nil
    @Published private(set) var isAuthenticating = false

    private init() {
        refreshFromStorage()
    }

    /// Sync published state from Keychain (TokenStore).
    func refreshFromStorage() {
        let token = TokenStore.shared.readJWT()
        jwt = (token?.isEmpty == false) ? token : nil
    }

    /// Save token to Keychain (TokenStore) and update published state.
    func saveJWT(_ token: String) {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            signOut()
            return
        }

        do {
            try TokenStore.shared.saveJWT(trimmed)
            jwt = trimmed
        } catch {
            // If Keychain write fails, treat as signed out.
            jwt = nil
        }
    }

    func signOut() {
        TokenStore.shared.clearJWT()
        jwt = nil
    }

    func signIn() async throws {
        isAuthenticating = true
        defer { isAuthenticating = false }

        let code = try await AuthSession.shared.startLogin()
        let token = try await AuthAPI.shared.exchangeCodeForJWT(code: code)

        saveJWT(token)
    }

    #if DEBUG
    /// Dev helper: paste a JWT to unblock API work without completing auth flows.
    func devSetJWT(_ token: String) {
        saveJWT(token)
    }
    #endif
}

