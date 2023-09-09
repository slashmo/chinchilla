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

public final class Migrator<Repository: MigrationRepository, Target: MigrationTarget> {
    public let repository: Repository
    public let target: Target

    public init(repository: Repository, target: Target) {
        self.repository = repository
        self.target = target
    }

    public func apply() async throws {
        try await target.createMigrationsTableIfNeeded()

        let migrations = try await repository.migrations()
        guard !migrations.isEmpty else { return }

        let highestAppliedMigrationID = try await target.highestAppliedMigrationID()

        let pendingMigrations = migrations
            .lazy
            .filter { migration in
                guard let highestAppliedMigrationID else { return true }
                return migration.id > highestAppliedMigrationID
            }
            .sorted(by: { $0.id < $1.id })

        for migration in pendingMigrations {
            try await target.apply(id: migration.id, sql: migration.upSQL)
        }
    }

    public func rollBack() async throws {
        try await target.createMigrationsTableIfNeeded()

        let migrations = try await repository.migrations()
        guard let highestAppliedMigrationID = try await target.highestAppliedMigrationID() else { return }

        let migrationsToRollBack = migrations
            .lazy
            .filter { migration in migration.id <= highestAppliedMigrationID }
            .sorted(by: { $0.id > $1.id })

        for migration in migrationsToRollBack {
            try await target.rollBack(id: migration.id, sql: migration.downSQL)
        }
    }
}
