import Foundation

public enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

public struct APIEndpoint<T>: Equatable {
  public let path: String
  public let method: HTTPMethod
  public let parameters: [String: String]?

  public init(@APIEndpointBuilder<T> builder: () -> APIEndpoint) {
    self = builder()
  }

  public init(
    path: String,
    method: HTTPMethod = .get,
    parameters: [String: Any]? = nil
  ) {
    self.path = path
    self.method = method
    self.parameters = parameters?.mapValues { "\($0)" }
  }

  func replacing(path: String, parameters: [String: Any]? = nil) -> Self {
    return APIEndpoint(
      path: path,
      method: method,
      parameters: parameters?.mapValues { "\($0)" }
    )
  }
}

@resultBuilder
public struct APIEndpointBuilder<T> {
  public static func buildBlock(
    _ path: String,
    _ method: HTTPMethod = .get,
    _ parameters: [String: Any]? = nil
  ) -> APIEndpoint<T> {
    return APIEndpoint(
      path: path,
      method: method,
      parameters: parameters
    )
  }

  public static func buildBlock(
    _ path: String,
    _ parameters: [String: Any]
  ) -> APIEndpoint<T> {
    return APIEndpoint(
      path: path,
      method: .get,
      parameters: parameters
    )
  }

  public static func buildBlock(
    _ path: String
  ) -> APIEndpoint<T> {
    return APIEndpoint(
      path: path,
      method: .get,
      parameters: nil
    )
  }
}
