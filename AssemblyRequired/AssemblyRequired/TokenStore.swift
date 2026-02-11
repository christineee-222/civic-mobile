//
//  TokenStore.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/11/26.
//

import Foundation
import Security

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private let service = "love.juggernaut.AssemblyRequired"
    private let account = "api_jwt"

    func readJWT() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func saveJWT(_ jwt: String) throws {
        let data = Data(jwt.utf8)

        // Delete any existing entry first to keep logic simple and reliable.
        _ = SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw NSError(domain: "TokenStore", code: Int(status), userInfo: nil)
        }
    }

    func clearJWT() {
        _ = SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ] as CFDictionary)
    }
}
