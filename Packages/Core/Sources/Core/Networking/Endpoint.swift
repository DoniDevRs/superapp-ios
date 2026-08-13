import Foundation

/// Descrição declarativa de uma chamada HTTP, independente de qualquer
/// feature. Módulos de feature (ex.: Pix) constroem `Endpoint`s e usam o
/// `NetworkClient` do Core para executá-los — nenhuma feature deve falar
/// com `URLSession` diretamente.
public struct Endpoint {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    public let path: String
    public let method: Method
    public let queryItems: [URLQueryItem]
    public let body: Data?
    public let headers: [String: String]

    public init(
        path: String,
        method: Method = .get,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        headers: [String: String] = [:]
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }
}
