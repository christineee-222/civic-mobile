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

    // MARK: - Public API

    func getRawJSON(path: String) async throws -> String {
        let data = try await request(
            method: "GET",
            path: path,
            body: nil
        )

        let body = String(data: data, encoding: .utf8) ?? ""
        return body.isEmpty ? "<empty>" : body
    }

    func fetchEvents() async throws -> [Event] {
        let response: EventsResponse = try await requestDecodable(
            method: "GET",
            path: "api/v1/events",
            body: Optional<Data>.none
        )

        return response.data
    }

    func setRsvp(eventId: Int, status: RsvpStatus) async throws -> EventRsvp {

        struct Body: Encodable { let status: String }
        let path = "api/v1/events/\(eventId)/rsvp"
        let body = Body(status: status.rawValue)

        do {
            let response: EventRsvpResponse = try await requestEncodable(
                method: "PUT",
                path: path,
                body: body
            )
            return response.data
        } catch let err as APIClientError {
            if case .http(let code, _) = err, code == 404 || code == 405 {
                let response: EventRsvpResponse = try await requestEncodable(
                    method: "POST",
                    path: path,
                    body: body
                )
                return response.data
            }
            throw err
        }
    }

    func clearRsvp(eventId: Int) async throws {
        _ = try await request(
            method: "DELETE",
            path: "api/v1/events/\(eventId)/rsvp",
            body: nil
        )
    }

    // MARK: - Core request helpers

    private func request(
        method: String,
        path: String,
        body: Data?
    ) async throws -> Data {

        guard let jwt = TokenStore.shared.readJWT(), !jwt.isEmpty else {
            throw APIClientError.notSignedIn
        }

        let url = AppConfig.apiBaseURL.appendingPathComponent(path)

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = body
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        


        guard let http = resp as? HTTPURLResponse else {
            throw APIClientError.http(-1, "No HTTP response.")
        }

        let responseBody = String(data: data, encoding: .utf8) ?? ""

        if http.statusCode == 401 {
            TokenStore.shared.clearJWT()
            throw APIClientError.http(
                401,
                responseBody.isEmpty ? "Unauthenticated." : responseBody
            )
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIClientError.http(http.statusCode, responseBody)
        }

        return data
    }

    private func requestDecodable<T: Decodable>(
        method: String,
        path: String,
        body: Data?
    ) async throws -> T {
        let data = try await request(
            method: method,
            path: path,
            body: body
        )

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func requestEncodable<Body: Encodable, T: Decodable>(
        method: String,
        path: String,
        body: Body
    ) async throws -> T {
        let encoded = try JSONEncoder().encode(body)
        return try await requestDecodable(
            method: method,
            path: path,
            body: encoded
        )
    }
}

private struct EventRsvpResponse: Decodable {
    let data: EventRsvp
}






//
//  APIClient.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

