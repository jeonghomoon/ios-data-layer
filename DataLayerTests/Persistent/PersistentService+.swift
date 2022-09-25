//
//  PersistentService+.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/25.
//

@testable import DataLayer

extension PersistentService {
    convenience init(type: StoreType) {
        let identifier = BundleProvider.shared.bundle.bundleIdentifier

        self.init(identifier: identifier, type: type)

        store.removePersistent()
    }
}
