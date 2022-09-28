//
//  EmptyRouter.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/17.
//

import Alamofire
@testable import DataLayer

enum EmptyRouter: Routable {
    case emptyEncoding
    case emptyMultipartFormData

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return ""
    }
}
