//
//  NetworkService+.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/11.
//

import Alamofire
@testable import DataLayer

extension NetworkService {
    convenience init() {
        let configuration = URLSessionConfiguration.af.ephemeral
        configuration.protocolClasses?.insert(MockURLProtocol.self, at: 0)

        let session = Session(configuration: configuration)

        self.init(session: session)
    }
}
