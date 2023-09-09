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

import Chinchilla
import XCTest

struct MigrationTargetMock: MigrationTarget {
    var onCreateMigrationsTableIfNeeded: () async throws -> Void = {
        XCTFail("Unhandled call to MigrationTargetMock.createMigrationsTableIfNeeded()")
    }

    var onHighestAppliedMigrationID: () async throws -> Migration.ID? = {
        XCTFail("Unhandled call to MigrationTargetMock.highestAppliedMigrationID()")
        return nil
    }

    var onApply: (Migration.ID, String) async throws -> Void = { _, _ in
        XCTFail("Unhandled call to MigrationTargetMock.apply()")
    }

    var onRollBack: (Migration.ID, String) async throws -> Void = { _, _ in
        XCTFail("Unhandled call to MigrationTargetMock.rollBack()")
    }

    func createMigrationsTableIfNeeded() async throws { try await onCreateMigrationsTableIfNeeded() }
    func highestAppliedMigrationID() async throws -> Migration.ID? { try await onHighestAppliedMigrationID() }
    func apply(id: Migration.ID, sql: String) async throws { try await onApply(id, sql) }
    func rollBack(id: Migration.ID, sql: String) async throws { try await onRollBack(id, sql) }
}
