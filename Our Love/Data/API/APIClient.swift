import Foundation

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case encodingError
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case tokenRefreshFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .noData: return "Нет данных"
        case .decodingError: return "Ошибка декодирования данных"
        case .encodingError: return "Ошибка кодирования данных"
        case .unauthorized: return "Требуется авторизация"
        case .forbidden: return "Доступ запрещён"
        case .notFound: return "Ресурс не найден"
        case .serverError(let code, let msg): return msg ?? "Ошибка сервера (\(code))"
        case .networkError(let err): return err.localizedDescription
        case .tokenRefreshFailed: return "Ошибка обновления токена"
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Client

final class APIClient {
    static let shared = APIClient()
    
    // Для продакшена замените на реальный URL
    private let baseURL: String = {
        #if DEBUG
            // Для симулятора: localhost
            // Для устройства: IP вашего компьютера
            return "http://localhost:8000/api/v1"
        #else
            return "https://your-domain.com/api/v1"
        #endif
    }()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Token Storage (Keychain)
    
    private var accessToken: String? {
        get { KeychainWrapper.string(forKey: "access_token") }
        set { KeychainWrapper.set(newValue, forKey: "access_token") }
    }
    
    var refreshToken: String? {
        get { KeychainWrapper.string(forKey: "refresh_token") }
        set { KeychainWrapper.set(newValue, forKey: "refresh_token") }
    }
    
    // MARK: - Auth State
    
    var isAuthenticated: Bool { accessToken != nil }
    
    // MARK: - Initialization
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    // MARK: - Token Management
    
    func setTokens(access: String, refresh: String) {
        self.accessToken = access
        self.refreshToken = refresh
    }
    
    func clearTokens() {
        self.accessToken = nil
        self.refreshToken = nil
        KeychainWrapper.remove(forKey: "access_token")
        KeychainWrapper.remove(forKey: "refresh_token")
    }
    
    // MARK: - Request
    
    private func buildRequest(
        path: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Add auth token if needed
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> T {
        if let error = error {
            // 401 Unauthorized
            if (error as NSError).code == 401 || (error as NSError).domain == NSURLErrorDomain {
                // Check if it's actually auth error from server
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
            }
            throw APIError.networkError(error)
        }
        
        guard let data = data else {
            throw APIError.noData
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        // Handle 401 - token expired
        if httpResponse.statusCode == 401 {
            clearTokens()
            throw APIError.unauthorized
        }
        
        // Handle 403
        if httpResponse.statusCode == 403 {
            throw APIError.forbidden
        }
        
        // Handle 404
        if httpResponse.statusCode == 404 {
            throw APIError.notFound
        }
        
        // Handle 204 No Content
        if httpResponse.statusCode == 204 {
            throw APIError.noData // Will be handled by caller
        }
        
        // Handle errors
        if httpResponse.statusCode >= 400 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: detail)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        // Decode success
        do {
            return try self.decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        body: Data? = nil
    ) async throws -> T {
        let request = try buildRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response, error: nil)
    }
    
    func requestVoid(
        path: String,
        method: HTTPMethod = .post,
        body: Data? = nil
    ) async throws {
        let request = try buildRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        if httpResponse.statusCode == 204 || httpResponse.statusCode == 200 {
            return
        }
        
        if httpResponse.statusCode == 401 {
            clearTokens()
            throw APIError.unauthorized
        }
        
        if httpResponse.statusCode >= 400 {
            if let json = try? JSONSerialization.jsonObject(with: data ?? Data()) as? [String: Any],
               let detail = json["detail"] as? String {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: detail)
            }
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
    }
    
    // MARK: - Multipart Upload

    func uploadMultipart(
        path: String,
        method: HTTPMethod = .post,
        fields: [String: String] = [:],
        fileData: Data,
        fileName: String,
        fieldName: String,
        mimeType: String
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        func appendBoundary(_ text: String) {
            body.append(contentsOf: text.data(using: .utf8) ?? Data())
        }
        
        // Add form fields
        for (key, value) in fields {
            appendBoundary("--\(boundary)\r\n")
            appendBoundary("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            appendBoundary("\(value)\r\n")
        }
        
        // Add file
        appendBoundary("--\(boundary)\r\n")
        appendBoundary("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        appendBoundary("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        appendBoundary("\r\n")
        
        // Close boundary
        appendBoundary("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        if httpResponse.statusCode == 401 {
            clearTokens()
            throw APIError.unauthorized
        }
        
        if httpResponse.statusCode >= 400 {
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        return data
    }
}

// MARK: - Keychain Wrapper

private enum KeychainWrapper {
    static func set(_ value: String?, forKey key: String) {
        let data = value?.data(using: .utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data ?? Data()
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func string(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func remove(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
