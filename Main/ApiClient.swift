import Foundation
import Security

final class ApiClient {
    var baseURL: URL
    var token: String? {
        didSet {
            let key = "fireshield.jwt"
            if let t = token { FSKeychain.set(Data(t.utf8), for: key) }
            else { FSKeychain.delete(key) }
        }
    }

    init(baseURL: URL) {
        self.baseURL = baseURL
        if let data = FSKeychain.get("fireshield.jwt"),
           let t = String(data: data, encoding: .utf8) {
            self.token = t
        }
    }

    // MARK: Auth
    func login(email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let email: String; let password: String }
        let body = Body(email: email, password: password)
        return try await requestWithBody("auth/login", method: "POST", body: body, auth: false)
    }

    // MARK: Insights
    func fetchReport(hours: Int = 24) async throws -> InsightsReport {
        try await requestNoBody("insights/report?hours=\(hours)", method: "GET", auth: true)
    }

    // MARK: Core requests (split overloads to avoid generic inference errors)
    private func requestNoBody<T: Decodable>(_ path: String, method: String, auth: Bool) async throws -> T {
        var url = baseURL; url.append(path: path)
        var req = URLRequest(url: url, timeoutInterval: 20)
        req.httpMethod = method
        if auth, let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if (resp as? HTTPURLResponse)?.statusCode == 401 { throw AuthError.unauthorized }
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func requestWithBody<T: Decodable, B: Encodable>(_ path: String, method: String, body: B, auth: Bool) async throws -> T {
        var url = baseURL; url.append(path: path)
        var req = URLRequest(url: url, timeoutInterval: 20)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        if auth, let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if (resp as? HTTPURLResponse)?.statusCode == 401 { throw AuthError.unauthorized }
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    enum AuthError: Error { case unauthorized }
}

// Rename to avoid collisions — no more “Ambiguous use of set/delete”
enum FSKeychain {
    static func set(_ data: Data, for key: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(q as CFDictionary)
        SecItemAdd(q as CFDictionary, nil)
    }
    static func get(_ key: String) -> Data? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &item) == errSecSuccess else { return nil }
        return item as? Data
    }
    static func delete(_ key: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(q as CFDictionary)
    }
}
