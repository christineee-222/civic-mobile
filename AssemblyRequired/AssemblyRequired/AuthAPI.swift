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
    case unexpectedResponse(String)

    var errorDescription: String? {
        switch self {
        case .http(let code, let body):
            return "Request failed (\(code)). \(body)"
        case .unauthenticated(let msg):
            return msg.isEmpty ? "Unauthenticated." : msg
        case .unexpectedResponse(let raw):
            return "Unexpected response: \(raw)"
        }
    }
}

final class AuthAPI {
    static let shared = AuthAPI()
    private init() {}

    func exchangeCodeForJWT(code: String) async throws -> String {
        let url = AppConfig.apiBaseURL.appendingPathComponent("api/v1/mobile/exchange")

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["code": code])

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse else {
            throw APIError.unexpectedResponse("No HTTP response.")
        }

        let bodyText = String(data: data, encoding: .utf8) ?? ""

        if http.statusCode == 401 {
            throw APIError.unauthenticated(bodyText)
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.http(http.statusCode, bodyText)
        }

        if let decoded = try? JSONDecoder().decode(TokenResponse.self, from: data),
           let t = decoded.token ?? decoded.access_token ?? decoded.jwt {
            return t
        }

        throw APIError.unexpectedResponse(bodyText.isEmpty ? "<empty>" : bodyText)
    }

    func fetchMe(jwt: String) async throws -> String {
        let url = AppConfig.apiBaseURL.appendingPathComponent("api/v1/me")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse else {
            throw APIError.unexpectedResponse("No HTTP response.")
        }

        let bodyText = String(data: data, encoding: .utf8) ?? ""

        if http.statusCode == 401 {
            throw APIError.unauthenticated(bodyText)
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.http(http.statusCode, bodyText)
        }

        return bodyText.isEmpty ? "<empty>" : bodyText
    }
}


