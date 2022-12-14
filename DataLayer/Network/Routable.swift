//
//  Routable.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/10.
//

import Alamofire

protocol Routable: URLRequestConvertible {
    var baseURL: URL { get }

    var method: HTTPMethod { get }

    var path: String { get }

    var parameters: Parameters { get }

    var encoding: ParameterEncoding? { get }

    var multipartFormData: MultipartFormData? { get }
}

extension Routable {
    var baseURL: URL {
        URL(string: "localhost:8080")!
    }

    var parameters: Parameters {
        Parameters()
    }

    var encoding: ParameterEncoding? {
        nil
    }

    var multipartFormData: MultipartFormData? {
        nil
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method

        if let encoding = encoding {
            request = try encoding.encode(request, with: parameters)
        } else {
            let encoding: ParameterEncoding

            switch method {
            case .post, .put:
                encoding = JSONEncoding.default
            case .get, .delete:
                encoding = URLEncoding.default
            default:
                debugPrint(
                    """
                        Failed to endcode parameters, Check if API is RESTful,
                        Parameters is encodable, or Method is valid.
                    """
                )

                throw NetworkService.Error.parametersEncodingFailed
            }

            request = try encoding.encode(request, with: parameters)
        }

        return request
    }
}
