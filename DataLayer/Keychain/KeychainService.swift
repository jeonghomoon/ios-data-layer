//
//  KeychainService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/13.
//

import Foundation

protocol KeychainServiceable {
    init(keychain: Keychainable)

    func create<Key: Hashable, Value: Codable>(
        value: Value,
        forKey key: Key
    ) throws

    func read<Key: Hashable, Value: Codable>(forKey key: Key) throws -> Value

    func update<Key: Hashable, Value: Codable>(
        value: Value,
        forKey key: Key
    ) throws

    func delete<Key: Hashable>(forKey key: Key) throws
}

final class KeychainService: KeychainServiceable {
    private let keychain: Keychainable

    required init(keychain: Keychainable = Keychain()) {
        self.keychain = keychain
    }

    func create<Key: Hashable, Value: Codable>(
        value: Value,
        forKey key: Key
    ) throws {
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

    func read<Key: Hashable, Value: Codable>(forKey key: Key) throws -> Value {
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
            throw Keychain.Error.unexpectedData
        }

        do {
            let value = try JSONDecoder().decode(Value.self, from: data)
            return value
        } catch {
            throw error
        }
    }

    func update<Key: Hashable, Value: Codable>(
        value: Value,
        forKey key: Key
    ) throws {
        do {
            let data = try JSONEncoder().encode(value)

            var query = keychain.query
            query[kSecAttrAccount as String] = key

            let attributes: [String: Any] = [
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]

            let status = SecItemUpdate(
                query as CFDictionary,
                attributes as CFDictionary
            )

            try checkSecItem(status)
        } catch {
            throw error
        }
    }

    func delete<Key: Hashable>(forKey key: Key) throws {
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
        guard status != errSecDuplicateItem else {
            throw Keychain.Error.duplicateItem
        }

        guard status != errSecItemNotFound else {
            throw Keychain.Error.notFound
        }

        guard status == errSecSuccess else {
            throw Keychain.Error.unhandledError(status: status)
        }
    }
}
