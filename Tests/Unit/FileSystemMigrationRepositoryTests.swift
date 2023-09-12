//===----------------------------------------------------------------------===//
//
// This source file is part of the Chinchilla open source project
//
// Copyright (c) 2023 Moritz Lang and the Chinchilla project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import Chinchilla
import Foundation
import XCTest

final class FileSystemMigrationRepositoryTests: XCTestCase {
    private var migrationsFolderURL: URL!

    override func setUp() async throws {
        migrationsFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: migrationsFolderURL, withIntermediateDirectories: false)
    }

    override func tearDown() async throws {
        try FileManager.default.removeItem(at: migrationsFolderURL)
    }

    func test_migrations_withNonEmptyMigrationsFolder_returnsMigrations() throws {
        let migrationIDs = try (1 ... 100).map { try XCTUnwrap(Migration.ID.stub(suffix: "\($0)")) }

        func upSQL(id: Migration.ID) -> String { "SELECT 'UP-\(id)';" }
        func downSQL(id: Migration.ID) -> String { "SELECT 'DOWN-\(id)';" }

        for id in migrationIDs {
            let upFileURL = migrationsFolderURL.appendingPathComponent("\(id)_stub.up.sql")
            try upSQL(id: id).write(to: upFileURL, atomically: false, encoding: .utf8)
            let downFileURL = migrationsFolderURL.appendingPathComponent("\(id)_stub.down.sql")
            try downSQL(id: id).write(to: downFileURL, atomically: false, encoding: .utf8)
        }

        let repository = try FileSystemMigrationRepository(url: migrationsFolderURL)

        let migrations = try repository.migrations()

        XCTAssertEqual(
            migrations,
            migrationIDs.map { Migration(id: $0, upSQL: upSQL(id: $0), downSQL: downSQL(id: $0)) }
        )
    }

    func test_migrations_withMalformedMigrationID_throwsMalformedMigrationIDError() throws {
        let upFileURL = migrationsFolderURL.appendingPathComponent("42_stub.up.sql")
        try "".write(to: upFileURL, atomically: false, encoding: .utf8)
        let downFileURL = migrationsFolderURL.appendingPathComponent("42_stub.down.sql")
        try "".write(to: downFileURL, atomically: false, encoding: .utf8)

        let repository = try FileSystemMigrationRepository(url: migrationsFolderURL)

        XCTAssertThrowsError(try repository.migrations()) { error in
            XCTAssertEqual(error as? FileSystemMigrationRepositoryError, .malformedMigrationID("42"))
        }
    }

    func test_migrations_withoutUpFileURL_throwsMissingUpFileError() throws {
        let id = try XCTUnwrap(Migration.ID.stub(suffix: "42"))
        let downFileURL = migrationsFolderURL.appendingPathComponent("\(id)_stub.down.sql")
        try "".write(to: downFileURL, atomically: false, encoding: .utf8)

        let repository = try FileSystemMigrationRepository(url: migrationsFolderURL)

        XCTAssertThrowsError(try repository.migrations()) { error in
            XCTAssertEqual(error as? FileSystemMigrationRepositoryError, .missingUpFileURL(id))
        }
    }

    func test_migrations_withoutDownFileURL_throwsMissingDownFileError() throws {
        let id = try XCTUnwrap(Migration.ID.stub(suffix: "42"))
        let downFileURL = migrationsFolderURL.appendingPathComponent("\(id)_stub.up.sql")
        try "".write(to: downFileURL, atomically: false, encoding: .utf8)

        let repository = try FileSystemMigrationRepository(url: migrationsFolderURL)

        XCTAssertThrowsError(try repository.migrations()) { error in
            XCTAssertEqual(error as? FileSystemMigrationRepositoryError, .missingDownFileURL(id))
        }
    }
}
