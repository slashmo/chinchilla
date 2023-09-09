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

extension Migration.ID {
    static func stub(suffix: String) -> Migration.ID {
        precondition(suffix.count <= Migration.ID.length, "Stub ID suffix must not be longer than the ID length.")
        return Migration.ID(rawValue: suffix.leftPadded(to: Migration.ID.length))!
    }
}

extension String {
    fileprivate func leftPadded(to count: Int) -> String {
        guard count > self.count else { return self }
        return String(repeating: "0", count: count - self.count) + self
    }
}
