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

    private let service = "love.juggernaut.assemblyrequired"
    private let account = "jwt"

    private init() {
        loadFromKeychain()
    }

    func loadFromKeychain() {
        guard let data = Keychain.get(service: service, account: account),
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty
        else {
            jwt = nil
            return
        }
        jwt = token
    }

    func saveToKeychain(_ token: String) {
        jwt = token
        _ = Keychain.set(Data(token.utf8), service: service, account: account)
    }

    func signOut() {
        jwt = nil
        _ = Keychain.delete(service: service, account: account)
    }

    func signIn() async throws {
        isAuthenticating = true
        defer { isAuthenticating = false }

        let code = try await AuthSession.shared.startLogin()
        let token = try await AuthAPI.shared.exchangeCodeForJWT(code: code)
        saveToKeychain(token)
    }
}
