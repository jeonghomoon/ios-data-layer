//
//  NetworkServiceTests.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/11.
//

import Alamofire
import XCTest
@testable import DataLayer

private struct SuccessResponse: Codable {
    let foo: String
}

private struct FailureResponse: Codable {
    let baz: String
}

extension FailureResponse {
    static var decodingError: DecodingError {
        let key = Self.CodingKeys.baz
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription:
                "No value associated with key \(key) (\"\(key.stringValue)\")."
        )

        return DecodingError.keyNotFound(key, context)
    }
}

private typealias TestResult = ResponseResult<SuccessResponse, FailureResponse>

private typealias TestRequest = (
    Routable, @escaping (TestResult) -> Void
) -> Void

class NetworkServiceTests: XCTestCase {
    var sut: NetworkServiceable!

    private let successStatusCode = 200, failureStatusCode = 400

    override func setUp() {
        super.setUp()

        sut = NetworkService()
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    func testValidRequestSuccess() {
        requestSuccess(router: TestRouter.validRequest, request: sut.request)
    }

    func testInvalidRequestFailure() {
        requestFailure(router: TestRouter.validRequest, request: sut.request)
    }

    func testValidEncodingRequestSuccess() {
        requestSuccess(
            router: TestRouter.validEncodingRequest,
            request: sut.request
        )
    }

    func testValidEncodingRequestFailure() {
        requestFailure(
            router: TestRouter.validEncodingRequest,
            request: sut.request
        )
    }

    func testInvalidEncodingRequestError() {
        requestNetworkServiceError(
            .parametersEncodingFailed,
            router: TestRouter.invalidEncodingRequest,
            request: sut.request
        )
    }

    func testValidUploadSuccess() {
        requestSuccess(router: TestRouter.validUpload, request: sut.upload)
    }

    func testValidUploadFailure() {
        requestFailure(router: TestRouter.validUpload, request: sut.upload)
    }

    func testInvalidUploadError() {
        requestNetworkServiceError(
            .multipartRequestFailed,
            router: TestRouter.invalidUpload,
            request: sut.upload
        )
    }

    func testInvalidHTTPURLResponseError() {
        requestNetworkServiceError(
            .invalidHTTPURLResponse,
            router: TestRouter.validRequest,
            request: sut.request
        )
    }

    func testInvalidResponseError() {
        requestDecodingError(
            FailureResponse.decodingError,
            router: TestRouter.validRequest,
            request: sut.request
        )
    }

    func testEmptyEncodingResponse() {
        requestSuccess(router: EmptyRouter.emptyEncoding, request: sut.request)

        requestFailure(router: EmptyRouter.emptyEncoding, request: sut.request)
    }

    func testEmptyMultipartFormDataResponseError() {
        requestNetworkServiceError(
            .multipartRequestFailed,
            router: EmptyRouter.emptyMultipartFormData,
            request: sut.upload
        )
    }

    private func requestSuccess(router: Routable, request: TestRequest) {
        let expect = "bar"

        initSuccess(with: expect)

        let expectation = XCTestExpectation()

        request(router) { result in
            guard
                case let .success(response) = result,
                case let .success(success) = response.body
            else {
                return XCTFail()
            }

            XCTAssertEqual(response.statusCode, self.successStatusCode)
            XCTAssertEqual(success.foo, expect)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func requestFailure(router: Routable, request: TestRequest) {
        let expect = "qux"

        initFailure(with: expect)

        let expectation = XCTestExpectation()

        request(router) { result in
            guard
                case let .success(response) = result,
                case let .failure(failure) = response.body
            else {
                return XCTFail()
            }

            XCTAssertEqual(response.statusCode, self.failureStatusCode)
            XCTAssertEqual(failure.baz, expect)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func requestNetworkServiceError(
        _ expectedError: NetworkService.Error,
        router: Routable,
        request: TestRequest
    ) {
        let expect = "bar"

        switch (expectedError) {
        case .multipartRequestFailed, .parametersEncodingFailed:
            initSuccess(with: expect)
        case .invalidHTTPURLResponse:
            initInvalidHTTPURLResponse(with: expect)
        }
            
        let expectation = XCTestExpectation()

        request(router) { (result: TestResult) in
            guard case let .failure(error) = result else {
                return XCTFail()
            }

            let clientError: Error

            if let error = error as? AFError,
               case let .createURLRequestFailed(error) = error {
                clientError = error
            } else {
                clientError = error
            }

            guard let error = clientError as? NetworkService.Error else {
                return XCTFail()
            }

            XCTAssertEqual(error, expectedError)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func requestDecodingError(
        _ expectedError: DecodingError,
        router: Routable,
        request: TestRequest
    ) {
        let expectation = XCTestExpectation()

        initInvalidResponse()

        request(router) { (result: TestResult) in
            guard case let .failure(error) = result,
                  let error = error as? DecodingError,
                  case let .keyNotFound(key, _) = error,
                  case let .keyNotFound(expectedKey, _) = expectedError,
                  key.stringValue == expectedKey.stringValue
            else {
                return XCTFail()
            }

            XCTAssert(true)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func initSuccess(with expect: String) {
        MockURLProtocol.requestHandler = { request in
            let exampleData = "{\"foo\": \"\(expect)\",}".data(using: .utf8)!

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: self.successStatusCode,
                httpVersion: "2.0",
                headerFields: nil
            )!

            return (response, exampleData)
        }
    }

    private func initFailure(with expect: String) {
        MockURLProtocol.requestHandler = { request in
            let exampleData = "{\"baz\": \"\(expect)\",}".data(using: .utf8)!

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: self.failureStatusCode,
                httpVersion: "2.0",
                headerFields: nil
            )!

            return (response, exampleData)
        }
    }

    private func initInvalidResponse() {
        MockURLProtocol.requestHandler = { request in
            let exampleData = "{\"foobar\": \"bazqux\",}".data(using: .utf8)!

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: self.failureStatusCode,
                httpVersion: "2.0",
                headerFields: nil
            )!

            return (response, exampleData)
        }
    }

    private func initInvalidHTTPURLResponse(with expect: String) {
        MockURLProtocol.requestHandler = { request in
            let exampleData = "{\"foo\": \"\(expect)\",}".data(using: .utf8)!

            let response = URLResponse()

            return (response, exampleData)
        }
    }
}
