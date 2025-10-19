import Foundation
import Security

// MARK: - Client Errors (surface real causes in UI)
enum ClientError: Error, LocalizedError {
    case http(code: Int, body: String)
    case badURL
    case unauthorized
    case decode(String)

    var errorDescription: String? {
        switch self {
        case let .http(code, body): return "HTTP \(code): \(body)"
        case .badURL:               return "Bad URL"
        case .unauthorized:         return "Unauthorized (401)"
        case let .decode(msg):      return "Decode error: \(msg)"
        }
    }
}

// MARK: - API Client
final class ApiClient {
    /// Base URL, e.g. https://fireshield-tdpy.onrender.com/
    var baseURL: URL

    /// Persisted JWT
    var token: String? {
        didSet {
            let key = "fireshield.jwt"
            if let t = token { FSKeychain.set(Data(t.utf8), for: key) }
            else { FSKeychain.delete(key) }
        }
    }

    /// Optional request/response logging
    var debugLogging = false

    // --- SOLUTION ---
        // AuthError is now correctly nested inside the ApiClient class.
        enum AuthError: Error { case unauthorized }

        init(baseURL: URL) {
            self.baseURL = baseURL
            if let data = FSKeychain.get("fireshield.jwt"),
               let t = String(data: data, encoding: .utf8) {
                self.token = t
            }
        }

    // MARK: - Auth
    struct LoginBody: Encodable { let email: String; let password: String }

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginBody(email: email, password: password)
        let resp: AuthResponse = try await requestWithBody(
            path: "auth/login",
            method: "POST",
            body: body,
            auth: false
        )
        // Save token for subsequent calls
        self.token = resp.token
        return resp
    }

    // MARK: - Insights
    func fetchReport(hours: Int = 24) async throws -> InsightsReport {
        try await requestNoBody(
            path: "insights/report",
            method: "GET",
            auth: true,
            query: [URLQueryItem(name: "hours", value: String(hours))]
        )
    }

    // MARK: - Series (for trend chart)
    func fetchSeries(hours: Int = 24, bucket: String = "hour") async throws -> [TimePoint] {
        try await requestNoBody(
            path: "series",
            method: "GET",
            auth: true,
            query: [
                URLQueryItem(name: "hours", value: String(hours)),
                URLQueryItem(name: "bucket", value: bucket)
            ]
        )
    }

    // MARK: - Core request helpers
    private func requestNoBody<T: Decodable>(
        path: String,
        method: String,
        auth: Bool,
        query: [URLQueryItem]? = nil
    ) async throws -> T {
        let url = try buildURL(path: path, query: query)

        var req = URLRequest(url: url, timeoutInterval: 60)
        req.httpMethod = method
        if auth {
            guard let token else { throw ClientError.unauthorized }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        return try decodeResponse(data: data, response: resp)
    }

    private func requestWithBody<T: Decodable, B: Encodable>(
        path: String,
        method: String,
        body: B,
        auth: Bool,
        query: [URLQueryItem]? = nil
    ) async throws -> T {
        let url = try buildURL(path: path, query: query)

        var req = URLRequest(url: url, timeoutInterval: 60)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        if auth {
            guard let token else { throw ClientError.unauthorized }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        return try decodeResponse(data: data, response: resp)
    }

    // MARK: - URL Builder
    private func buildURL(path: String, query: [URLQueryItem]? = nil) throws -> URL {
        guard var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw ClientError.badURL
        }
        let basePath = comps.path.hasSuffix("/") ? comps.path : comps.path + "/"
        comps.path = basePath + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        comps.queryItems = query?.isEmpty == false ? query : nil

        guard let url = comps.url else { throw ClientError.badURL }
        if debugLogging { print("➡️ \(url.absoluteString)") }
        return url
    }

    // MARK: - Response handling
    private func decodeResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if debugLogging {
            if let body = String(data: data, encoding: .utf8) {
                print("⬅️ HTTP \(http.statusCode)\n\(body)")
            } else {
                print("⬅️ HTTP \(http.statusCode) (binary \(data.count) bytes)")
            }
        }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            if http.statusCode == 401 { throw ClientError.unauthorized }
            throw ClientError.http(code: http.statusCode, body: body)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            throw ClientError.decode("\(error.localizedDescription)\nRaw: \(raw)")
        }
    }
}

// MARK: - Minimal Keychain helper
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
