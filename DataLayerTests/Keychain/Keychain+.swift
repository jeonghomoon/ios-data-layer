//
//  Keychain+.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/19.
//

import Foundation
@testable import DataLayer

extension Keychain {
    convenience init() {
        self.init(service: "")

        SecItemDelete(query as CFDictionary)
    }
}
