//
//  JWTInterceptor.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/28.
//

import Alamofire

protocol JWTAuthorizable: Codable {
    static var key: String { get }

    var access: String { get }
}

final class JWTInterceptor<
    Success: JWTAuthorizable,
    Failure: Codable
>: RequestInterceptor {
    private let refreshRouter: Routable
    private let networkService: NetworkServiceable
    private let keychainService: PersistentServiceable

    init(
        refreshRouter: Routable,
        networkService: NetworkServiceable = NetworkService(),
        keychainService: PersistentServiceable = PersistentService(
            type: .keychain
        )
    ) {
        self.refreshRouter = refreshRouter
        self.networkService = networkService
        self.keychainService = keychainService
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest

        if let token: Success = try? keychainService.read(forKey: Success.key) {
            urlRequest.headers.add(.authorization(bearerToken: token.access))
        }

        return completion(.success(urlRequest))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard request.response?.statusCode == 401 else {
            return completion(.doNotRetryWithError(error))
        }

        networkService.request(
            router: refreshRouter
        ) { [weak self] (result: ResponseResult<Success, Failure>) in
            guard
                case let .success(response) = result,
                case let .success(success) = response.body,
                let _ = try? self?.keychainService.update(
                    success,
                    forKey: Success.key
                )
            else {
                return completion(.doNotRetryWithError(error))
            }

            return completion(.doNotRetry)
        }
    }
}
