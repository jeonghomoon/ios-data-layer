//
//  UserDefaultsStoreTests.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/25.
//

import XCTest
@testable import DataLayer

final class UserDefaultsStoreTests: XCTestCase, PersistentServiceTestable {
    var sut: PersistentServiceable!

    override func setUp() {
        super.setUp()

        sut = PersistentService(type: .userDefaults)
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    func testCreateSuccess() {
        expressNoError(try self.createData())
    }

    func testCreateErrorDuplicateItem() {
        expressNoError(try self.createData())

        expressError(try self.createData(), expected: .duplicateItem)
    }

    func testReadSuccess() {
        expressNoError(try self.createData())

        expressNoError(try self.readData(expected: valueForCreate))
    }

    func testReadErrorNotFound() {
        expressError(
            try self.readData(expected: valueForUpdate),
            expected: .notFound
        )
    }

    func testUpdateSuccess() {
        expressNoError(try self.createData())

        expressNoError(try self.updateData())
    }

    func testUpdateErrorNotFound() {
        expressError(try self.updateData(), expected: .notFound)
    }

    func testDeleteSuccess() {
        expressNoError(try self.createData())

        expressNoError(try self.deleteData())
    }

    func testDeleteErrorNotFound() {
        expressError(try self.deleteData(), expected: .notFound)
    }
}
