import Foundation

// MARK: - Partner API

final class PartnerAPI {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Profile
    
    func getMyProfile() async throws -> PartnerProfile {
        try await apiClient.request(path: "/auth/partner/profile/")
    }
    
    func createProfile(displayName: String, bio: String?, city: String?, birthDate: String?, gender: String?) async throws -> PartnerProfile {
        var body: [String: Any] = [
            "display_name": displayName
        ]
        if let bio = bio, !bio.isEmpty { body["bio"] = bio }
        if let city = city, !city.isEmpty { body["city"] = city }
        if let birthDate = birthDate, !birthDate.isEmpty { body["birth_date"] = birthDate }
        if let gender = gender, !gender.isEmpty { body["gender"] = gender }
        
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await apiClient.request(path: "/auth/partner/profile/create/", method: .post, body: data)
    }
    
    func deleteProfile() async throws {
        try await apiClient.requestVoid(path: "/auth/partner/profile/delete/", method: .delete)
    }
    
    // MARK: - Search
    
    func searchProfiles(city: String? = nil, gender: String? = nil, minAge: Int? = nil, maxAge: Int? = nil) async throws -> [PartnerProfile] {
        var path = "/auth/partner/search/"
        var params: [String] = []
        if let city = city, !city.isEmpty { params.append("city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") }
        if let gender = gender, !gender.isEmpty { params.append("gender=\(gender)") }
        if let minAge = minAge { params.append("min_age=\(minAge)") }
        if let maxAge = maxAge { params.append("max_age=\(maxAge)") }
        if !params.isEmpty { path += "?" + params.joined(separator: "&") }
        
        let response: PaginatedResponse<PartnerProfile> = try await apiClient.request(path: path)
        return response.results
    }
    
    // MARK: - Likes
    
    func likeProfile(toUserId: String, isLike: Bool) async throws -> PartnerLikeResponse {
        let body: [String: Any] = [
            "to_user": toUserId,
            "is_like": isLike
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await apiClient.request(path: "/auth/partner/like/", method: .post, body: data)
    }
    
    // MARK: - Matches
    
    func getMatches() async throws -> [PartnerProfile] {
        try await apiClient.request(path: "/auth/partner/matches/")
    }
}
