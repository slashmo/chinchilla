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

public protocol MigrationTarget {
    func createMigrationsTableIfNeeded() async throws

    func highestAppliedMigrationID() async throws -> Migration.ID?

    func apply(id: Migration.ID, sql: String) async throws
    func rollBack(id: Migration.ID, sql: String) async throws
}
