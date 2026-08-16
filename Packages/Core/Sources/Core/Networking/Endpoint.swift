import Foundation

/// Declarative description of an HTTP call, independent of any feature.
/// Feature modules (e.g., Pix) build `Endpoint`s and use Core's
/// `NetworkClient` to execute them — no feature should talk to `URLSession`
/// directly.
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
