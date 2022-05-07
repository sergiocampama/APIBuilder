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
