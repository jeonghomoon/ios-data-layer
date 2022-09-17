//
//  NetworkServiceTests.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/11.
//

import Alamofire
import XCTest
@testable import DataLayer

private struct SuccessReponse: Codable {
    let foo: String
}

private struct FailureReponse: Codable {
    let baz: String
}

private typealias TestResult = ResponseResult<SuccessReponse, FailureReponse>

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
        requestSuccess(router: .validRequest, request: sut.request)
    }

    func testInvalidRequestFailure() {
        requestFailure(router: .validRequest, request: sut.request)
    }

    func testValidEncodingRequestSuccess() {
        requestSuccess(router: .validEncodingRequest, request: sut.request)
    }

    func testValidEncodingRequestFailure() {
        requestFailure(router: .validEncodingRequest, request: sut.request)
    }

    func testInvalidEncodingRequestError() {
        requestError(
            .parametersEncodingFailed,
            router: .invalidEncodingRequest,
            request: sut.request
        )
    }

    func testValidUploadSuccess() {
        requestSuccess(router: .validUpload, request: sut.upload)
    }

    func testValidUploadFailure() {
        requestFailure(router: .validUpload, request: sut.upload)
    }

    func testInvalidUploadError() {
        requestError(
            .multipartRequestFailed,
            router: .invalidUpload,
            request: sut.upload
        )
    }

    func testInvalidHTTPURLResponseError() {
        requestError(
            .invalidHTTPURLResponse,
            router: .validRequest,
            request: sut.request
        )
    }

    private func requestSuccess(router: TestRouter, request: TestRequest) {
        let expect = "bar"

        initSuccess(with: expect)

        let expectation = XCTestExpectation()

        request(router) { result in
            guard
                case let .success(response) = result,
                case let .success(success) = response.body
            else {
                return
            }

            XCTAssertEqual(response.statusCode, self.successStatusCode)
            XCTAssertEqual(success.foo, expect)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func requestFailure(router: TestRouter, request: TestRequest) {
        let expect = "qux"

        initFailure(with: expect)

        let expectation = XCTestExpectation()

        request(router) { result in
            guard
                case let .success(response) = result,
                case let .failure(failure) = response.body
            else {
                return
            }

            XCTAssertEqual(response.statusCode, self.failureStatusCode)
            XCTAssertEqual(failure.baz, expect)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func requestError(
        _ expectedError: NetworkService.Error,
        router: TestRouter,
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
            guard case let .failure(error) = result else { return }

            let clientError: Error

            if let error = error as? AFError,
               case let .createURLRequestFailed(error) = error {
                clientError = error
            } else {
                clientError = error
            }

            guard let error = clientError as? NetworkService.Error else {
                return
            }

            XCTAssertEqual(error, expectedError)

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

    private func initInvalidHTTPURLResponse(with expect: String) {
        MockURLProtocol.requestHandler = { request in
            let exampleData = "{\"foo\": \"\(expect)\",}".data(using: .utf8)!

            let response = URLResponse()

            return (response, exampleData)
        }
    }
}
