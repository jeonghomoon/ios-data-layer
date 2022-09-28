//
//  Response.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/10.
//

import Foundation

typealias ResponseResult<Success: Codable, Failure: Codable> =
    Result<Response<Success, Failure>, Error>

typealias Response<Success: Codable, Failure: Codable> =
    (statusCode: Int, body: Body<Success, Failure>)

enum Body<Success: Codable, Failure: Codable>: Codable {
    case success(Success)
    case failure(Failure)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(Failure.self))
        }
    }
}
