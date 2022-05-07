import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class APIProvider {
  let configuration: APIConfiguration
  let requestExecutor: RequestExecutor

  public init(
    configuration: APIConfiguration,
    requestExecutor: RequestExecutor? = nil
  ) {
    self.configuration = configuration
    self.requestExecutor = requestExecutor ?? DefaultRequestExecutor()
  }

  public func request(
    _ endpoint: APIEndpoint<Void>,
    parameters: [String: String]? = nil
  ) async throws {
    let request = try requestForEndpoint(endpoint, parameters: parameters)
    let response = try await requestExecutor.execute(request)
    try validate(response: response)
  }

  public func request<S: Encodable>(
    _ endpoint: APIEndpoint<Void>,
    body: S,
    parameters: [String: String]? = nil
  ) async throws {
    let request = try requestForEndpoint(endpoint, body: body, parameters: parameters)
    let response = try await requestExecutor.execute(request)
    try validate(response: response)
  }

  public func request<T: Codable>(
    _ endpoint: APIEndpoint<T>,
    parameters: [String: String]? = nil
  ) async throws -> T {
    let request = try requestForEndpoint(endpoint, parameters: parameters)
    let response = try await requestExecutor.execute(request)
    return try unpack(response: response)
  }

  public func request<S: Encodable, T: Codable>(
    _ endpoint: APIEndpoint<T>,
    body: S,
    parameters: [String: String]? = nil
  ) async throws -> T {
    let request = try requestForEndpoint(endpoint, body: body, parameters: parameters)
    let response = try await requestExecutor.execute(request)
    return try unpack(response: response)
  }

  public func request<T: Codable>(
    _ endpoint: APIEndpoint<T>,
    body: Data,
    contentType: String,
    parameters: [String: String]? = nil
  ) async throws -> T {
    let request = try requestForEndpoint(
      endpoint,
      body: body,
      contentType: contentType,
      parameters: parameters
    )
    let response = try await requestExecutor.execute(request)
    return try unpack(response: response)
  }
}

extension APIProvider {
  public func requestForEndpoint<T>(
    _ endpoint: APIEndpoint<T>,
    body: Data,
    contentType: String,
    parameters: [String: String]? = nil
  ) throws -> URLRequest {
    var request = try requestForEndpoint(endpoint, parameters: parameters)

    request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    request.httpBody = body

    return request
  }

  public func requestForEndpoint<S: Encodable, T>(
    _ endpoint: APIEndpoint<T>,
    body: S? = nil,
    parameters: [String: String]? = nil
  ) throws -> URLRequest {
    var request = try requestForEndpoint(endpoint, parameters: parameters)

    if let body = body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(body)
    }

    return request
  }

  public func requestForEndpoint<T>(
    _ endpoint: APIEndpoint<T>,
    parameters: [String: String]? = nil
  ) throws -> URLRequest {
    var components = URLComponents()
    components.host = configuration.host.host
    components.scheme = configuration.host.scheme
    components.path = endpoint.path

    let allParameters = (parameters ?? [:]).merging(endpoint.parameters ?? [:]) { old, new in old }

    if !allParameters.isEmpty {
      components.queryItems = allParameters.map { key, value in URLQueryItem(name: key, value: value) }
    }

    var request = URLRequest(url: components.url!)
    request.httpMethod = endpoint.method.rawValue

    configuration.requestHeaders.forEach { header, value in
      request.setValue(value, forHTTPHeaderField: header)
    }

    return request
  }

  private func validate(response: Response) throws {
    guard response.statusCode >= 200 && response.statusCode < 300 else {
      let body = String(decoding: response.data, as: UTF8.self)
      throw StringError("Received status code \(response.statusCode): \(body)")
    }
  }

  private func unpack<T: Codable>(response: Response) throws -> T {
    try validate(response: response)
    do {
      let decoded = try JSONDecoder().decode(T.self, from: response.data)
      return decoded
    } catch {
      let body = String(decoding: response.data, as: UTF8.self)
      throw StringError("Error decoding: \(error) \(body)")
    }
  }
}
