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

public struct Migration: Identifiable, Hashable, Sendable {
    public let id: ID
    public let upSQL: String
    public let downSQL: String

    public init(id: ID, upSQL: String, downSQL: String) {
        self.id = id
        self.upSQL = upSQL
        self.downSQL = downSQL
    }

    public struct ID: RawRepresentable, Hashable, Sendable {
        public let rawValue: String

        public static let length = 14

        public init?(rawValue: String) {
            guard rawValue.count == Self.length else { return nil }
            self.rawValue = rawValue
        }
    }
}

extension Migration.ID: Comparable {
    public static func < (lhs: Migration.ID, rhs: Migration.ID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Migration.ID: CustomStringConvertible {
    public var description: String { rawValue }
}
