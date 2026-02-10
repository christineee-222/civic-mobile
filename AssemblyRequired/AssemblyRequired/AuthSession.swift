//
//  AuthSession.swift
//  AssemblyRequired
//
//  Created by Christine Tacha on 2/10/26.
//

import Foundation
import AuthenticationServices
import UIKit

final class AuthSession {
    static let shared = AuthSession()
    private init() {}

    private var session: ASWebAuthenticationSession?
    private let presenter = AuthSessionPresenter()

    func startLogin() async throws -> String {
        let startURL = AppConfig.apiBaseURL.appendingPathComponent("mobile/complete")
        let callbackScheme = "assemblyrequired"

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            let authSession = ASWebAuthenticationSession(
                url: startURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }

                guard
                    let callbackURL,
                    let comps = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                    let code = comps.queryItems?.first(where: { $0.name == "code" })?.value,
                    !code.isEmpty
                else {
                    cont.resume(throwing: URLError(.badURL))
                    return
                }

                cont.resume(returning: code)
            }

            authSession.presentationContextProvider = self.presenter
            authSession.prefersEphemeralWebBrowserSession = false
            self.session = authSession

            if authSession.start() == false {
                cont.resume(throwing: URLError(.cannotLoadFromNetwork))
            }
        }
    }
}

final class AuthSessionPresenter: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Always return an existing window from the active scene (no deprecated initializers)
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        // Prefer foreground active scenes
        let orderedScenes = scenes.sorted {
            let a = $0.activationState == .foregroundActive
            let b = $1.activationState == .foregroundActive
            return a && !b
        }

        for scene in orderedScenes {
            if let key = scene.windows.first(where: { $0.isKeyWindow }) {
                return key
            }
            if let any = scene.windows.first {
                return any
            }
        }

        // If somehow there is no window yet, this is an app lifecycle issue.
        // Returning an empty anchor is better than creating deprecated UIWindow().
        return ASPresentationAnchor()
    }
}

