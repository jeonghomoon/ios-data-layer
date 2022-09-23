//
//  UserDefaultsStore.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/23.
//

import Foundation

final class UserDefaultsStore: PersistentStoreable {
    let userDefaults: UserDefaults

    private let suiteName: String

    required init(identifier: String?) {
        guard let suiteName = identifier,
              let userDefaults = UserDefaults(suiteName: suiteName)
        else {
            fatalError(PersistentService.initializeFailureMessage)
        }

        self.userDefaults = userDefaults
        self.suiteName = suiteName
    }

    func create(_ data: Data, forKey key: String) throws {
        do {
            try findObject(forKey: key)

            throw PersistentService.Error.duplicateItem
        } catch PersistentService.Error.notFound {
            userDefaults.set(data, forKey: key)
        }
    }

    func read(forKey key: String) throws -> Data {
        guard let data = try findObject(forKey: key) as? Data else {
            throw PersistentService.Error.unexpectedData
        }

        return data
    }

    func update(_ data: Data, forKey key: String) throws {
        try findObject(forKey: key)

        userDefaults.set(data, forKey: key)
    }

    func delete(forKey key: String) throws {
        try findObject(forKey: key)

        userDefaults.removeObject(forKey: key)
    }

    func removePersistent() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    @discardableResult
    private func findObject(forKey key: String) throws -> Any {
        guard let object = userDefaults.object(forKey: key) else {
            throw PersistentService.Error.notFound
        }

        return object
    }
}
