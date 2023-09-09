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

import Foundation

extension Migrator where Repository == FileSystemMigrationRepository {
    public convenience init(migrationsFolderPath: String, target: Target) throws {
        try self.init(
            repository: FileSystemMigrationRepository(url: URL(filePath: migrationsFolderPath)),
            target: target
        )
    }
}
