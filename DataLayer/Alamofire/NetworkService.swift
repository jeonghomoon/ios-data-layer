//
//  NetworkService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/11.
//

import Alamofire

protocol NetworkServiceable: AnyObject {
    init(session: Session)

    func request<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (ResponseResult<Success, Failure>) -> Void
    )

    func upload<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (ResponseResult<Success, Failure>) -> Void
    )
}

final class NetworkService: NetworkServiceable {
    enum Error: Swift.Error, Equatable {
        case multipartRequestFailed

        case parametersEncodingFailed

        case invalidHTTPURLResponse
    }

    private let session: Session

    required init(session: Session = Session.default) {
        self.session = session
    }

    func request<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (ResponseResult<Success, Failure>) -> Void
    ) {
        let request = session.request(router)

        performRequest(request, completion: completion)
    }

    func upload<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (ResponseResult<Success, Failure>) -> Void
    ) {
        guard let data = router.multipartFormData else {
            return completion(.failure(Error.multipartRequestFailed))
        }

        let request = session.upload(multipartFormData: data, with: router)

        performRequest(request, completion: completion)
    }

    private func performRequest<Success: Codable, Failure: Codable>(
        _ request: DataRequest,
        completion: @escaping (ResponseResult<Success, Failure>) -> Void
    ) {
        request.responseDecodable(
            of: Body<Success, Failure>.self
        ) { dataResponse in
            switch dataResponse.result {
            case let .success(body):
                guard let statusCode = dataResponse.response?.statusCode else {
                    return completion(.failure(Error.invalidHTTPURLResponse))
                }

                return completion(.success((statusCode, body)))
            case let .failure(error):
                return completion(.failure(error))
            }
        }
    }
}
