//
//  PersistentServiceTestable.swift
//  DataLayerTests
//
//  Created by Jeongho Moon on 2022/09/21.
//

import XCTest
@testable import DataLayer

protocol PersistentServiceTestable: AnyObject {
    var sut: PersistentServiceable! { get }

    var key: String { get }

    var valueForCreate: String { get }

    var valueForUpdate: String { get }

    func expressError(
        _ expression: @autoclosure () throws -> Void,
        expected expect: PersistentService.Error
    )

    func expressNoError(_ expression: @autoclosure () throws -> Void)

    func createData() throws

    func readData(expected expect: String) throws

    func updateData() throws

    func deleteData() throws
}

extension PersistentServiceTestable {
    var key: String {
        "key"
    }
    var valueForCreate: String {
        "create"
    }

    var valueForUpdate: String {
        "update"
    }

    func expressError(
        _ expression: @autoclosure () throws -> Void,
        expected expect: PersistentService.Error
    ) {
        XCTAssertThrowsError(
            try expression()
        ) { error in let error = error as? PersistentService.Error
            XCTAssertEqual(error, expect)
        }
    }

    func expressNoError(
        _ expression: @autoclosure () throws -> Void
    ) {
        XCTAssertNoThrow(try expression())
    }

    func createData() throws {
        do {
            try sut.create(valueForCreate, forKey: key)
        } catch {
            throw error
        }
    }

    func readData(expected expect: String) throws {
        do {
            let value: String = try sut.read(forKey: key)

            XCTAssertEqual(value, expect)
        } catch {
            throw error
        }
    }

    func updateData() throws {
        do {
            try sut.update(valueForUpdate, forKey: key)
        } catch {
            throw error
        }
    }

    func deleteData() throws {
        do {
            try sut.delete(forKey: key)
        } catch {
            throw error
        }
    }
}
