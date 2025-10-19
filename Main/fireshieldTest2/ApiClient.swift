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
    
    // MARK: Core requests with Retry Logic
    private func requestNoBody<T: Decodable>(_ path: String, method: String, auth: Bool) async throws -> T {
        for _ in 1...2 { // Try up to 2 times
            do {
                var url = baseURL; url.append(path: path)
                var req = URLRequest(url: url, timeoutInterval: 60) // Increased timeout
                req.httpMethod = method
                if auth, let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
                
                let (data, resp) = try await URLSession.shared.data(for: req)
                guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    if (resp as? HTTPURLResponse)?.statusCode == 401 { throw AuthError.unauthorized }
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                // If the first attempt fails, the loop will continue for the second try.
                // If the second try also fails, this error will be thrown.
                continue
            }
        }
        throw URLError(.timedOut) // Or a more specific error if you prefer
    }
    
    private func requestWithBody<T: Decodable, B: Encodable>(_ path: String, method: String, body: B, auth: Bool) async throws -> T {
        for _ in 1...2 { // Try up to 2 times
            do {
                var url = baseURL; url.append(path: path)
                var req = URLRequest(url: url, timeoutInterval: 60) // Increased timeout
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
            } catch {
                continue
            }
        }
        throw URLError(.timedOut)
    }
    
    enum AuthError: Error { case unauthorized }
}

// Keychain helper remains the same
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
