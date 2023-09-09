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

public final class FileSystemMigrationRepository {
    private let url: URL
    private let fileManager = FileManager.default

    public init(url: URL) throws {
        self.url = url
    }
}

enum FileSystemMigrationRepositoryError: Error, Equatable {
    case malformedMigrationID(String)
    case missingUpFileURL(Migration.ID)
    case missingDownFileURL(Migration.ID)
}

extension FileSystemMigrationRepository: MigrationRepository {
    public func migrations() throws -> [Migration] {
        let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        let fileURLsByID = Dictionary(grouping: urls, by: { $0.lastPathComponent.prefix(while: { $0 != "_" }) })

        return try fileURLsByID
            .lazy
            .map { id, fileURLs in
                let idRawValue = String(id)
                guard let id = Migration.ID(rawValue: idRawValue) else {
                    throw FileSystemMigrationRepositoryError.malformedMigrationID(idRawValue)
                }

                guard let upFileURL = fileURLs.first(where: { $0.path().hasSuffix(".up.sql") }) else {
                    throw FileSystemMigrationRepositoryError.missingUpFileURL(id)
                }
                let upSQL = try String(contentsOf: upFileURL)

                guard let downFileURL = fileURLs.first(where: { $0.path().hasSuffix(".down.sql") }) else {
                    throw FileSystemMigrationRepositoryError.missingDownFileURL(id)
                }
                let downSQL = try String(contentsOf: downFileURL)

                return Migration(id: id, upSQL: upSQL, downSQL: downSQL)
            }
            .sorted(by: { $0.id < $1.id })
    }
}
