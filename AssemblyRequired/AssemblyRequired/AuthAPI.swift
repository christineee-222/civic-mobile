//
//  AuthAPI.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import Foundation

struct TokenResponse: Decodable {
    let token: String?
    let access_token: String?
    let jwt: String?
}

enum APIError: Error, LocalizedError {
    case http(Int, String)
    case unauthenticated(String)
    case notSignedIn
    case unexpectedResponse(String)

    var errorDescription: String? {
        switch self {
        case .http(let code, let body):
            return "Request failed (\(code)). \(body)"
        case .unauthenticated(let msg):
            return msg.isEmpty ? "Unauthenticated." : msg
        case .notSignedIn:
            return "Not signed in."
        case .unexpectedResponse(let raw):
            return "Unexpected response: \(raw)"
        }
    }
}

final class AuthAPI {
    static let shared = AuthAPI()
    private init() {}

    // MARK: - Exchange WorkOS code for JWT

    func exchangeCodeForJWT(code: String) async throws -> String {
        // AppConfig.apiBaseURL should already be something like:
        // https://supreme-being-main-ifbs53.laravel.cloud/api/v1
        let url = AppConfig.apiBaseURL.appendingPathComponent("api/v1/mobile/exchange")
        print("➡️ EXCHANGE CALL:", url.absoluteString, "codeLen:", code.count)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["code": code])

        print("🧩 EXCHANGE sending request…")

        let (data, resp) = try await URLSession.shared.data(for: req)

        let status = (resp as? HTTPURLResponse)?.statusCode ?? -1

        // Cap response size so simulator doesn’t kill app if server returns big HTML error
        let capped = data.prefix(2048)
        let bodyPreview = String(decoding: capped, as: UTF8.self)

        print("⬅️ EXCHANGE RESPONSE:", status,
              bodyPreview.replacingOccurrences(of: "\n", with: " ").prefix(300))

        if status == 401 {
            throw APIError.unauthenticated(bodyPreview)
        }

        guard (200...299).contains(status) else {
            throw APIError.http(status, bodyPreview)
        }

        if let decoded = try? JSONDecoder().decode(TokenResponse.self, from: data),
           let t = decoded.token ?? decoded.access_token ?? decoded.jwt {
            return t
        }

        throw APIError.unexpectedResponse(bodyPreview.isEmpty ? "<empty>" : bodyPreview)
    }

    // MARK: - Fetch current user (/me)

    func fetchMe() async throws -> String {
        guard let jwt = TokenStore.shared.readJWT(), !jwt.isEmpty else {
            throw APIError.notSignedIn
        }

        // Same rule: apiBaseURL already includes /api/v1
        let url = AppConfig.apiBaseURL.appendingPathComponent("api/v1/me")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)

        let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
        let capped = data.prefix(2048)
        let bodyPreview = String(decoding: capped, as: UTF8.self)

        if status == 401 {
            throw APIError.unauthenticated(bodyPreview)
        }

        guard (200...299).contains(status) else {
            throw APIError.http(status, bodyPreview)
        }

        return bodyPreview.isEmpty ? "<empty>" : bodyPreview
    }
}






