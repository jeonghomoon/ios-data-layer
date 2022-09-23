//
//  KeychainStore.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/23.
//

import Foundation

final class KeychainStore: PersistentStoreable {
    let query: [String: Any]

    required init(identifier: String?) {
        guard let service = identifier else {
            fatalError(PersistentService.initializeFailureMessage)
        }

        self.query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
    }

    func create(_ data: Data, forKey key: String) throws {
        var query = query
        query[kSecAttrAccount as String] = key
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)

        try checkSecItem(status)
    }

    func read(forKey key: String) throws -> Data {
        var query = query
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
            throw PersistentService.Error.unexpectedData
        }

        return data
    }

    func update(_ data: Data, forKey key: String) throws {
        var query = query
        query[kSecAttrAccount as String] = key

        let attributes = [kSecValueData as String: data]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        try checkSecItem(status)
    }

    func delete(forKey key: String) throws {
        var query = query
        query[kSecAttrAccount as String] = key

        let status = SecItemDelete(query as CFDictionary)

        try checkSecItem(status)
    }

    func removePersistent() {
        SecItemDelete(query as CFDictionary)
    }

    private func checkSecItem(_ status: OSStatus) throws {
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            throw PersistentService.Error.duplicateItem
        case errSecItemNotFound:
            throw PersistentService.Error.notFound
        default:
            throw PersistentService.Error.unhandledError(status: status)
        }
    }
}
