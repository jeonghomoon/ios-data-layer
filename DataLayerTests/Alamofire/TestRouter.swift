//
//  TestRouter.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/11.
//

import Alamofire
@testable import DataLayer

enum TestRouter: Routable {
    case validRequest
    case validEncodingRequest
    case invalidEncodingRequest
    case validUpload
    case invalidUpload

    var method: HTTPMethod {
        switch self {
        case .validRequest:
            return .get
        case .validEncodingRequest:
            return .patch
        case .invalidEncodingRequest:
            return .connect
        case .validUpload:
            return .post
        case .invalidUpload:
            return .post
        }
    }

    var path: String {
        ""
    }

    var encoding: ParameterEncoding? {
        guard case .validEncodingRequest = self else {
            return nil
        }

        return JSONEncoding.default
    }

    var multipartFormData: MultipartFormData? {
        guard case .validUpload = self else {
            return nil
        }

        return MultipartFormData()
    }
}
