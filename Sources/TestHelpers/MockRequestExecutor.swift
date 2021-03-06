import APIBuilder
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class MockRequestExecutor: RequestExecutor {
  public let expectedResult: Result<Response, Error>

  public init(expectedResult: Result<Response, Error>) {
    self.expectedResult = expectedResult
  }

  public func execute(_ request: URLRequest) async throws -> Response {
    return try expectedResult.get()
  }
}

extension Response {
  public init(statusCode: Int, data: Data) {
    self.init(
      httpResponse: HTTPURLResponse(
        url: URL(string: "http://some.data")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!,
      data: data
    )
  }
}
