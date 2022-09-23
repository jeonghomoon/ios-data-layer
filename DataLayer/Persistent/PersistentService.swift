//
//  PersistentService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/23.
//

import Foundation

protocol PersistentServiceable: AnyObject {
    init(identifier: String?, type: PersistentService.StoreType)

    func create<Value: Codable>(_ value: Value, forKey key: String) throws

    func read<Value: Codable>(forKey key: String) throws -> Value

    func update<Value: Codable>(_ value: Value, forKey key: String) throws

    func delete(forKey key: String) throws
}

final class PersistentService: PersistentServiceable {
    enum Error: Swift.Error, Equatable {
        case notFound
        case duplicateItem
        case unexpectedData
        case unhandledError(status: OSStatus)
    }

    enum StoreType {
        case keychain
        case userDefaults
    }

    static let initializeFailureMessage = """
        Failed to initialize store. Bundle Identifier isn't defined.
    """

    let store: PersistentStoreable

    required init(
        identifier: String? = Bundle.main.bundleIdentifier,
        type: StoreType
    ) {
        switch type {
        case .keychain:
            store = KeychainStore(identifier: identifier)
        case .userDefaults:
            store = UserDefaultsStore(identifier: identifier)
        }
    }

    func create<Value: Codable>(_ value: Value, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)

        try store.create(data, forKey: key)
    }

    func read<Value: Codable>(forKey key: String) throws -> Value {
        let data = try store.read(forKey: key)

        return try JSONDecoder().decode(Value.self, from: data)
    }

    func update<Value: Codable>(_ value: Value, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)

        try store.update(data, forKey: key)
    }

    func delete(forKey key: String) throws {
        try store.delete(forKey: key)
    }
}
