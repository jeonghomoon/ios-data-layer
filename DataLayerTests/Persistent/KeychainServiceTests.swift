//
//  KeychainServiceTests.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/19.
//

import Foundation
import XCTest
@testable import DataLayer

class KeychainServiceTests: XCTestCase {
    var sut: KeychainServiceable!

    private let key = "key",
                valueForCreate = "create",
                valueForUpdate = "update"

    override func setUp() {
        super.setUp()

        sut = KeychainService()
    }

    override func tearDown() {
        sut = nil
    }

    func testCreateSuccess() {
        expressNoError(try self.createKeychainItem())
    }

    func testCreateErrorDuplicateItem() {
        expressNoError(try self.createKeychainItem())

        expressError(try self.createKeychainItem(), expected: .duplicateItem)
    }

    func testReadSuccess() {
        expressNoError(try self.createKeychainItem())

        expressNoError(try self.readKeychainItem(expected: valueForCreate))
    }

    func testReadErrorNotFound() {
        expressError(
            try self.readKeychainItem(expected: valueForUpdate),
            expected: .notFound
        )
    }

    func testUpdateSuccess() {
        expressNoError(try self.createKeychainItem())

        expressNoError(try self.updateKeychainItem())
    }

    func testUpdateErrorNotFound() {
        expressError(try self.updateKeychainItem(), expected: .notFound)
    }

    func testDeleteSuccess() {
        expressNoError(try self.createKeychainItem())

        expressNoError(try self.deleteKeychainItem())
    }

    func testDeleteErrorNotFound() {
        expressError(try self.deleteKeychainItem(), expected: .notFound)
    }

    private func expressError(
        _ expression: @autoclosure () throws -> Void,
        expected expect: KeychainService.Error
    ) {
        XCTAssertThrowsError(
            try expression()
        ) { error in let error = error as? KeychainService.Error
            XCTAssertEqual(error, expect)
        }
    }

    private func expressNoError(
        _ expression: @autoclosure () throws -> Void
    ) {
        XCTAssertNoThrow(try expression())
    }

    private func createKeychainItem() throws {
        do {
            try sut.create(valueForCreate, forKey: key)
        } catch {
            throw error
        }
    }

    private func readKeychainItem(expected expect: String?) throws {
        do {
            let value: String = try sut.read(forKey: key)

            guard let expect = expect else { return }

            XCTAssertEqual(value, expect)
        } catch {
            throw error
        }
    }

    private func updateKeychainItem() throws {
        do {
            try sut.update(valueForUpdate, forKey: key)
        } catch {
            throw error
        }
    }

    private func deleteKeychainItem() throws {
        do {
            try sut.delete(forKey: key)
        } catch {
            throw error
        }
    }
}
