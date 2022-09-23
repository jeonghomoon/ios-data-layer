//
//  PersistentService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/23.
//

import Foundation

protocol PersistentStoreable: AnyObject {
    init(identifier: String?)

    func create(_ data: Data, forKey key: String) throws

    func read(forKey key: String) throws -> Data

    func update(_ data: Data, forKey key: String) throws

    func delete(forKey key: String) throws

    func removePersistent()
}

class PersistentService {
    enum Error: Swift.Error, Equatable {
        case notFound
        case duplicateItem
        case unexpectedData
        case unhandledError(status: OSStatus)
    }

    static let initializeFailureMessage = """
        Failed to initialize store. Bundle Identifier isn't defined.
    """
}
