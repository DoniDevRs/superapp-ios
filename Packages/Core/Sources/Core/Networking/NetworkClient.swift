import Foundation

/// Contrato mínimo de networking compartilhado entre módulos de feature.
///
/// Implementações concretas (ex.: `URLSessionNetworkClient`) vivem no Core e
/// são injetadas nos repositórios de cada feature (ver plan.md da feature
/// Pix: "Data ... usando networking do Core"). Isso mantém o Core como a
/// única fonte de acesso à API Java do backend (`superapp-api`).
public protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: Endpoint, decoding type: T.Type) async throws -> T
}

/// Implementação padrão sobre `URLSession`, pronta para quando a feature Pix
/// (ou qualquer outra) conectar à API real. Não é usada ainda pelo módulo
/// Pix, que hoje opera 100% com dados mockados.
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
