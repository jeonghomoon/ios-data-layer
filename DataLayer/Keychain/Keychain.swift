//
//  Keychain.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/12.
//

import Foundation

protocol Keychainable {
    var query: [String: Any] { get }

    init(itemClass: KeychainItemClass)
}

enum KeychainItemClass {
    case genericPassword
    case internetPassword
    case certificate
    case key
    case identity

    var value: CFString {
        switch self {
        case .genericPassword:
            return kSecClassGenericPassword
        case .internetPassword:
            return kSecClassInternetPassword
        case .certificate:
            return kSecClassCertificate
        case .key:
            return kSecClassKey
        case .identity:
            return kSecClassIdentity
        }
    }
}

final class Keychain: Keychainable {
    enum Error: Swift.Error, Equatable {
        case notFound
    
        case unexpectedData

        case duplicateItem

        case unhandledError(status: OSStatus)
    }

    var query: [String: Any] {
        return [
            kSecClass as String: itemClass.value,
            kSecAttrService as String: service
        ]
    }

    private let itemClass: KeychainItemClass
    private let service: String

    required init(itemClass: KeychainItemClass = .genericPassword) {
        guard let service = Bundle.main.bundleIdentifier else {
            fatalError(
                """
                    Faild to load bundle identifier,
                    CFBundleIdentifier is not defined.
                """
            )
        }

        self.itemClass = itemClass
        self.service = service
    }
}
