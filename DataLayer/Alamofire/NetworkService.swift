//
//  NetworkService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/11.
//

import Alamofire

protocol NetworkServiceable {
    init(session: Session)

    func request<Success: Codable, Failure: Codable>(
        router: Routable,
        completion: @escaping (RequestResult<Success, Failure>) -> Void
    )
}

final class NetworkService: NetworkServiceable {
    enum Error: Swift.Error, Equatable {
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
        session.request(router).responseDecodable(
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

