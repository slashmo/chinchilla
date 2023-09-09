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

struct MigrationRepositoryMock: MigrationRepository {
    var onMigrations: () throws -> [Migration] = {
        XCTFail("Unhandled call to MigrationRepositoryMock.migrations()")
        return []
    }

    func migrations() throws -> [Migration] {
        try onMigrations()
    }
}
