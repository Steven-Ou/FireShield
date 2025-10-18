import Foundation

// MARK: - Data Models

// These structs match the JSON structure your server uses.
// They must be Codable to be easily converted to and from JSON.

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let userId: String
    let displayName: String
    let email: String
}

// MARK: - Authentication Service

class AuthService {
    
    // The URL for your locally running server's login endpoint.
    private let loginURL = URL(string: "http://localhost:8080/auth/login")!

    func login(email: String, password: String) async throws -> AuthResponse {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData = LoginRequest(email: email, password: password)
        
        // Encode the login data into JSON.
        let requestBody = try JSONEncoder().encode(loginData)
        request.httpBody = requestBody

        // Perform the network request asynchronously.
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check for a successful HTTP status code (e.g., 200 OK).
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // If the server returns an error (like 401 Unauthorized), throw an error.
            throw URLError(.badServerResponse)
        }

        // Decode the JSON response from the server into our AuthResponse struct.
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return authResponse
    }
}
