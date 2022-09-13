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
        completion: @escaping (RequestResult<Success, Failure>) -> Void
    )

    func upload<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (RequestResult<Success, Failure>) -> Void
    )
}

final class NetworkService: NetworkServiceable {
    enum Error: Swift.Error, Equatable {
        case multipartRequestFailed

        case parametersEncodingFailed
    }

    private let session: Session

    required init(session: Session = Session.default) {
        self.session = session
    }

    func request<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (RequestResult<Success, Failure>) -> Void
    ) {
        let request = session.request(router)

        performRequest(request, completion: completion)
    }

    func upload<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (RequestResult<Success, Failure>) -> Void
    ) {
        guard let data = router.multipartFormData else {
            return completion(.failure(Error.multipartRequestFailed))
        }

        let request = session.upload(multipartFormData: data, with: router)

        performRequest(request, completion: completion)
    }

    private func performRequest<Success: Codable, Failure: Codable>(
        _ request: DataRequest,
        completion: @escaping (RequestResult<Success, Failure>) -> Void
    ) {
        request.responseDecodable(
            of: Response<Success, Failure>.self
        ) { response in let result = response.result
            switch result {
            case let .success(data):
                return completion(.success(data))
            case let .failure(error):
                return completion(.failure(error))
            }
        }
    }
}
