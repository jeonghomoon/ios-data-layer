//
//  KeychainService+.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/19.
//

import Foundation
@testable import DataLayer

extension KeychainService {
    convenience init() {
        self.init(keychain: Keychain())
    }
}
