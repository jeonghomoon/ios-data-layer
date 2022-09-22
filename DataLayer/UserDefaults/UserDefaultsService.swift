//
//  UserDefaultsService.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/22.
//

import Foundation

protocol UserDefaultsServiceable: AnyObject {
    init(identifier: String?)

    func create<Value: Codable>(_ value: Value, forKey key: String) throws

    func read<Value: Codable>(forKey key: String) throws -> Value

    func update<Value: Codable>(_ value: Value, forKey key: String) throws

    func delete(forKey key: String) throws
}

final class UserDefaultsService: UserDefaultsServiceable {
    enum Error: Swift.Error, Equatable {
        case notFound

        case unexpectedData

        case duplicateItem
    }

    let userDefaults: UserDefaults

    required init(identifier: String? = nil) {
        let suiteName: String?

        if let identifier = identifier {
            suiteName = identifier
        } else {
            suiteName = Bundle.main.bundleIdentifier
        }

        guard let suiteName = suiteName,
              let userDefaults = UserDefaults(suiteName: suiteName)
        else {
            fatalError("Failed to init store. Bundle Identifier isn't defined.")
        }

        self.userDefaults = userDefaults
    }

    func create<Value: Codable>(_ value: Value, forKey key: String) throws {
        do {
            try findObject(forKey: key)

            throw UserDefaultsService.Error.duplicateItem
        } catch UserDefaultsService.Error.notFound {
            let data = try JSONEncoder().encode(value)

            userDefaults.set(data, forKey: key)
        }
    }

    func read<Value: Codable>(forKey key: String) throws -> Value {
        guard let data = try findObject(forKey: key) as? Data else {
            throw UserDefaultsService.Error.unexpectedData
        }

        return try JSONDecoder().decode(Value.self, from: data)
    }

    func update<Value: Codable>(_ value: Value, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)

        try findObject(forKey: key)

        userDefaults.set(data, forKey: key)
    }

    func delete(forKey key: String) throws {
        try findObject(forKey: key)

        userDefaults.removeObject(forKey: key)
    }

    @discardableResult
    private func findObject(forKey key: String) throws -> Any {
        guard let object = userDefaults.object(forKey: key) else {
            throw UserDefaultsService.Error.notFound
        }

        return object
    }
}
