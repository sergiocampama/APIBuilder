import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class DefaultRequestExecutor: RequestExecutor {
  let urlSession = URLSession(configuration: .default)

  public init() {}

  public func execute(_ request: URLRequest) async throws -> Response {
    let (data, response) = try await urlSession.data(for: request) as (Data, URLResponse)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw StringError("Unknown error")
    }

    return Response(httpResponse: httpResponse, data: data)
  }
}

#if os(Linux)
extension URLSession {
  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    return try await withCheckedThrowingContinuation { continuation in
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }
        guard let response = response as? HTTPURLResponse else {
          continuation.resume(throwing: StringError("invalid url response"))
          return
        }
        guard let data = data else {
          continuation.resume(throwing: StringError("missing response data"))
          return
        }
        continuation.resume(returning: (data, response))
      }
      task.resume()
    }
  }
}
#endif  // os(Linux)
