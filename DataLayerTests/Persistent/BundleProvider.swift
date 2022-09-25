//
//  BundleProvider.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/25.
//

import Foundation

final class BundleProvider {
    static let shared = BundleProvider()

    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    private init() {}
}
