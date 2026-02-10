import Foundation

enum APIClientError: Error, LocalizedError {
    case notSignedIn
    case http(Int, String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Not signed in."
        case .http(let code, let body):
            return "Request failed (\(code)). \(body)"
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    /// Fetch raw JSON text (debug helper)
    func getRawJSON(path: String, jwt: String?) async throws -> String {
        guard let jwt, !jwt.isEmpty else { throw APIClientError.notSignedIn }

        let url = AppConfig.apiBaseURL.appendingPathComponent(path)

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse else {
            throw APIClientError.http(-1, "No HTTP response.")
        }

        let body = String(data: data, encoding: .utf8) ?? ""

        if http.statusCode == 401 {
            throw APIClientError.http(401, body.isEmpty ? "Unauthenticated." : body)
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIClientError.http(http.statusCode, body)
        }

        return body.isEmpty ? "<empty>" : body
    }

    /// Fetch events as typed Swift objects
    func fetchEvents(jwt: String?) async throws -> [Event] {
        guard let jwt, !jwt.isEmpty else { throw APIClientError.notSignedIn }

        let url = AppConfig.apiBaseURL.appendingPathComponent("api/v1/events")

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse else {
            throw APIClientError.http(-1, "No HTTP response.")
        }

        if http.statusCode == 401 {
            throw APIClientError.http(401, "Unauthenticated.")
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIClientError.http(http.statusCode, body)
        }

        let decoded = try JSONDecoder().decode(EventsResponse.self, from: data)
        return decoded.data
    }
}


//
//  APIClient.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

