//
//  KeychainService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/13.
//

import Foundation

protocol KeychainServiceable: AnyObject {
    init(keychain: Keychainable)

    func create<Value: Codable>(_ value: Value, forKey key: String) throws

    func read<Value: Codable>(forKey key: String) throws -> Value

    func update<Value: Codable>(_ value: Value, forKey key: String) throws

    func delete(forKey key: String) throws
}

final class KeychainService: KeychainServiceable {
    enum Error: Swift.Error, Equatable {
        case notFound

        case unexpectedData

        case duplicateItem

        case unhandledError(status: OSStatus)
    }

    private let keychain: Keychainable

    required init(keychain: Keychainable = Keychain()) {
        self.keychain = keychain
    }

    func create<Value: Codable>(_ value: Value, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(value)

            var query = keychain.query
            query[kSecAttrAccount as String] = key
            query[kSecValueData as String] = data

            let status = SecItemAdd(query as CFDictionary, nil)

            try checkSecItem(status)
        } catch {
            throw error
        }
    }

    func read<Value: Codable>(forKey key: String) throws -> Value {
        var query = keychain.query
        query[kSecAttrAccount as String] = key
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        try checkSecItem(status)

        guard
            let existingItem = item as? [CFString: Any],
            let data = existingItem[kSecValueData] as? Data
        else {
            throw KeychainService.Error.unexpectedData
        }

        do {
            let value = try JSONDecoder().decode(Value.self, from: data)
            return value
        } catch {
            throw error
        }
    }

    func update<Value: Codable>(_ value: Value, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(value)

            var query = keychain.query
            query[kSecAttrAccount as String] = key

            let attributes: [String: Any] = [kSecValueData as String: data]

            let status = SecItemUpdate(
                query as CFDictionary,
                attributes as CFDictionary
            )

            try checkSecItem(status)
        } catch {
            throw error
        }
    }

    func delete(forKey key: String) throws {
        do {
            var query = keychain.query
            query[kSecAttrAccount as String] = key

            let status = SecItemDelete(query as CFDictionary)

            try checkSecItem(status)
        } catch {
            throw error
        }
    }

    private func checkSecItem(_ status: OSStatus) throws {
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            throw KeychainService.Error.duplicateItem
        case errSecItemNotFound:
            throw KeychainService.Error.notFound
        default:
            throw KeychainService.Error.unhandledError(status: status)
        }
    }
}
