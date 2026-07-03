import Foundation

// MARK: - Auth Repository Implementation

final class AuthRepository: AuthRepositoryProtocol {
    
    private let apiClient: APIClient
    private var _currentUser: User?
    private var _relationship: Relationship?
    
    var isAuthenticated: Bool { apiClient.isAuthenticated }
    var currentUser: User? { _currentUser }
    var relationship: Relationship? { _relationship }
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Login
    
    func login(username: String, password: String) async throws {
        let request = LoginRequestDTO(username: username, password: password)
        let data = try JSONEncoder().encode(request)
        
        let response: TokenResponseDTO = try await apiClient.request(
            path: "/auth/login/",
            method: .post,
            body: data
        )
        
        apiClient.setTokens(access: response.access, refresh: response.refresh)
        try await fetchProfile()
    }
    
    // MARK: - Register
    
    func register(username: String, password: String, email: String, inviteCode: String?) async throws {
        // Step 1: Register user — backend returns user data (no tokens)
        let request = RegisterRequestDTO(
            username: username,
            password: password,
            email: email,
            inviteCode: inviteCode
        )
        _ = try await apiClient.request(
            path: "/auth/register/",
            method: .post,
            body: try JSONEncoder().encode(request)
        ) as UserProfileDTO
        
        // Step 2: Login immediately to get JWT tokens
        try await login(username: username, password: password)
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        if let refresh = apiClient.refreshToken {
            let request = LogoutRequestDTO(refresh: refresh)
            let data = try JSONEncoder().encode(request)
            do {
                try await apiClient.requestVoid(
                    path: "/auth/logout/",
                    method: .post,
                    body: data
                )
            } catch {
                // Ignore logout errors
            }
        }
        apiClient.clearTokens()
        _currentUser = nil
        _relationship = nil
    }
    
    // MARK: - Fetch Profile
    
    func fetchProfile() async throws {
        let dto: UserProfileDTO = try await apiClient.request(path: "/auth/me/")
        _currentUser = DataMapper.toDomain(dto)
        try await fetchRelationship()
    }
    
    // MARK: - Fetch Relationship
    
    private func fetchRelationship() async throws {
        do {
            let dto: RelationshipDTO = try await apiClient.request(path: "/auth/relationship/")
            _relationship = DataMapper.toDomain(dto)
        } catch {
            // Relationship might not exist yet - don't throw
            _relationship = nil
        }
    }
    
    // MARK: - Generate Invite Code
    
    func generateInviteCode() async throws -> String {
        let response: InviteCodeResponseDTO = try await apiClient.request(
            path: "/auth/invite/generate/",
            method: .post
        )
        return response.code
    }
    
    // MARK: - Refresh Tokens
    
    func refreshTokens() async throws {
        guard let refresh = apiClient.refreshToken else {
            throw APIError.unauthorized
        }
        
        let request: [String: String] = ["refresh": refresh]
        let data = try JSONEncoder().encode(request)
        
        let response: TokenResponseDTO = try await apiClient.request(
            path: "/auth/refresh/",
            method: .post,
            body: data
        )
        
        apiClient.setTokens(access: response.access, refresh: response.refresh)
    }
}