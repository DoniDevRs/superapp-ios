import Foundation

/// Minimal networking contract shared between feature modules.
///
/// Concrete implementations (e.g., `URLSessionNetworkClient`) live in Core
/// and are injected into each feature's repositories (see the Pix feature's
/// plan.md: "Data ... using Core's networking"). This keeps Core as the
/// single source of access to the backend's Java API (`superapp-api`).
public protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: Endpoint, decoding type: T.Type) async throws -> T
}

/// Default implementation on top of `URLSession`, ready for when the Pix
/// feature (or any other) connects to the real API. Not yet used by the Pix
/// module, which today operates 100% on mocked data.
public final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    public init(baseURL: URL, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func request<T: Decodable>(_ endpoint: Endpoint, decoding type: T.Type) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noConnection
        } catch let error as URLError where error.code == .timedOut {
            throw NetworkError.timeout
        } catch {
            throw NetworkError.unknown
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.server(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}
