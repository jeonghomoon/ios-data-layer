//
//  Keychain.swift
//  DataLayer
//
//  Created by Jeongho Moon on 2022/09/12.
//

import Foundation

protocol Keychainable: AnyObject {
    var query: [String: Any] { get }

    init(service: String?)
}

final class Keychain: Keychainable {
    let query: [String: Any]

    required init(service: String? = nil) {
        let service: String = {
            if let service = service {
                return service
            } else if let service = Bundle.main.bundleIdentifier {
                return service
            } else {
                fatalError(
                    """
                        Failed to load service,
                        service or bundleIdentifier is not defined.
                    """
                )
            }
        }()

        query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
    }
}
