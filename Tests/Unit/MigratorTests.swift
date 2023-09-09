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

final class MigratorTests: XCTestCase {
    private let migrations = [
        Migration(id: .stub(suffix: "1"), upSQL: "UP-1", downSQL: "DOWN-1"),
        Migration(id: .stub(suffix: "2"), upSQL: "UP-2", downSQL: "DOWN-2"),
        Migration(id: .stub(suffix: "3"), upSQL: "UP-3", downSQL: "DOWN-3"),
        Migration(id: .stub(suffix: "4"), upSQL: "UP-4", downSQL: "DOWN-4"),
    ]

    func test_apply_withoutPreviouslyAppliedMigrations_appliesAllMigrations() async throws {
        var appliedMigrations = [AppliedMigration]()

        let repository = MigrationRepositoryMock(onMigrations: { self.migrations })

        let target = MigrationTargetMock(
            onCreateMigrationsTableIfNeeded: {},
            onHighestAppliedMigrationID: { nil },
            onApply: { appliedMigrations.append(AppliedMigration(id: $0, sql: $1)) }
        )

        let migrator = Migrator(repository: repository, target: target)

        try await migrator.apply()

        XCTAssertEqual(appliedMigrations, [
            AppliedMigration(id: .stub(suffix: "1"), sql: "UP-1"),
            AppliedMigration(id: .stub(suffix: "2"), sql: "UP-2"),
            AppliedMigration(id: .stub(suffix: "3"), sql: "UP-3"),
            AppliedMigration(id: .stub(suffix: "4"), sql: "UP-4"),
        ])
    }

    func test_apply_withPreviouslyAppliedMigrations_appliesRemainingMigrations() async throws {
        var appliedMigrations = [AppliedMigration]()

        let repository = MigrationRepositoryMock(onMigrations: { self.migrations })

        let target = MigrationTargetMock(
            onCreateMigrationsTableIfNeeded: {},
            onHighestAppliedMigrationID: { .stub(suffix: "2") },
            onApply: { appliedMigrations.append(AppliedMigration(id: $0, sql: $1)) }
        )

        let migrator = Migrator(repository: repository, target: target)

        try await migrator.apply()

        XCTAssertEqual(appliedMigrations, [
            AppliedMigration(id: .stub(suffix: "3"), sql: "UP-3"),
            AppliedMigration(id: .stub(suffix: "4"), sql: "UP-4"),
        ])
    }

    func test_apply_withoutMigrations_doesNotApplyMigrations() async throws {
        var appliedMigrations = [AppliedMigration]()

        let repository = MigrationRepositoryMock(onMigrations: { [] })
        let target = MigrationTargetMock(
            onCreateMigrationsTableIfNeeded: {},
            onApply: { appliedMigrations.append(AppliedMigration(id: $0, sql: $1)) }
        )
        let migrator = Migrator(repository: repository, target: target)

        try await migrator.apply()

        XCTAssertEqual(appliedMigrations, [])
    }

    func test_rollBack_previouslyAppliedAllMigrations_rollsBackAllMigrations() async throws {
        var rolledBackMigrations = [RolledBackMigration]()

        let repository = MigrationRepositoryMock(onMigrations: { self.migrations })

        let target = MigrationTargetMock(
            onCreateMigrationsTableIfNeeded: {},
            onHighestAppliedMigrationID: { .stub(suffix: "4") },
            onRollBack: { rolledBackMigrations.append(RolledBackMigration(id: $0, sql: $1)) }
        )

        let migrator = Migrator(repository: repository, target: target)

        try await migrator.rollBack()

        XCTAssertEqual(rolledBackMigrations, [
            RolledBackMigration(id: .stub(suffix: "4"), sql: "DOWN-4"),
            RolledBackMigration(id: .stub(suffix: "3"), sql: "DOWN-3"),
            RolledBackMigration(id: .stub(suffix: "2"), sql: "DOWN-2"),
            RolledBackMigration(id: .stub(suffix: "1"), sql: "DOWN-1"),
        ])
    }

    func test_rollBack_previouslyAppliedSomeMigrations_onlyRollsBackPreviouslyAppliedMigrations() async throws {
        var rolledBackMigrations = [RolledBackMigration]()

        let repository = MigrationRepositoryMock(onMigrations: { self.migrations })

        let target = MigrationTargetMock(
            onCreateMigrationsTableIfNeeded: {},
            onHighestAppliedMigrationID: { .stub(suffix: "2") },
            onRollBack: { rolledBackMigrations.append(RolledBackMigration(id: $0, sql: $1)) }
        )

        let migrator = Migrator(repository: repository, target: target)

        try await migrator.rollBack()

        XCTAssertEqual(rolledBackMigrations, [
            RolledBackMigration(id: .stub(suffix: "2"), sql: "DOWN-2"),
            RolledBackMigration(id: .stub(suffix: "1"), sql: "DOWN-1"),
        ])
    }

    func test_rollBack_withoutPreviouslyAppliedMigrations_doesNotRollBackAnyMigrations() async throws {
        var rolledBackMigrations = [RolledBackMigration]()

        let repository = MigrationRepositoryMock(onMigrations: { self.migrations })

        let target = MigrationTargetMock(
            onCreateMigrationsTableIfNeeded: {},
            onHighestAppliedMigrationID: { nil },
            onRollBack: { rolledBackMigrations.append(RolledBackMigration(id: $0, sql: $1)) }
        )

        let migrator = Migrator(repository: repository, target: target)

        try await migrator.rollBack()

        XCTAssertEqual(rolledBackMigrations, [])
    }
}

private struct AppliedMigration: Equatable {
    let id: Migration.ID
    let sql: String
}

private struct RolledBackMigration: Equatable {
    let id: Migration.ID
    let sql: String
}
