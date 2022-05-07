import APIBuilder
import TestHelpers
import XCTest

final class ProviderTests: XCTestCase {
  let configuration = MockConfiguration(host: URL(string: "https://some.api.com")!)

  struct SomeCodable: Codable, Equatable {
    let message: String
  }

  func testAsyncDataRequest() async throws {
    let expectedMessage = SomeCodable(message: "hello, world!")

    let expectedResponse = try Response(statusCode: 200, data: JSONEncoder().encode(expectedMessage))
    let mockExecutor = MockRequestExecutor(expectedResult: .success(expectedResponse))
    let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")

    let apiProvider = APIProvider(configuration: configuration, requestExecutor: mockExecutor)

    let response = try await apiProvider.request(endpoint)
    XCTAssertEqual(response, expectedMessage)
  }

  func testBasicEndpointRequest() throws {
    let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")
    let apiProvider = APIProvider(configuration: configuration)
    let urlRequest = apiProvider.requestForEndpoint(endpoint)
    XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource")
    XCTAssertEqual(urlRequest.httpMethod, "GET")
  }

  func testComplexEndpointRequest() throws {
    let endpoint = APIEndpoint<SomeCodable>(
      path: "/someResource",
      method: .post,
      parameters: ["query": "item"],
      body: Data([1, 2, 3]),
      contentType: "application/octet-stream"
    )

    let apiProvider = APIProvider(configuration: configuration)
    let urlRequest = apiProvider.requestForEndpoint(endpoint)
    XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource?query=item")
    XCTAssertEqual(urlRequest.httpMethod, "POST")
    XCTAssertEqual(urlRequest.httpBody, Data([1, 2, 3]))
    XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
  }

  func testConfiguration() throws {
    let configuration = MockConfiguration(
      host: URL(string: "https://some.api.com")!,
      requestHeaders: ["Authorization": "my_api_token"]
    )
    let endpoint = APIEndpoint<SomeCodable>(path: "/someResource")
    let apiProvider = APIProvider(configuration: configuration)
    let urlRequest = apiProvider.requestForEndpoint(endpoint)
    XCTAssertEqual(urlRequest.url?.absoluteString, "https://some.api.com/someResource")
    XCTAssertEqual(urlRequest.httpMethod, "GET")
    XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Authorization"), "my_api_token")
  }
}
