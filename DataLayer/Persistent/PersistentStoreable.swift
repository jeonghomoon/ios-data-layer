//
//  PersistentStoreable.swift
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
