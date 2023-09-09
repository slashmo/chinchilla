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

final class MigrationIDTests: XCTestCase {
    func test_initRawValue_withFourteenCharacters_initializesID() throws {
        let id = try XCTUnwrap(Migration.ID(rawValue: "00000000000042"))

        XCTAssertEqual(id, .stub(suffix: "42"))
    }

    func test_initRawValue_withLessThanFourteenCharacters_returnsNil() {
        XCTAssertNil(Migration.ID(rawValue: "42"))
    }

    func test_lessThan_whenLhsIsSmaller_returnsTrue() throws {
        let lhsID = try XCTUnwrap(Migration.ID(rawValue: "00000000000001"))
        let rhsID = try XCTUnwrap(Migration.ID(rawValue: "00000000000002"))

        XCTAssertLessThan(lhsID, rhsID)
    }

    func test_lessThan_whenLhsEqualsRhs_returnsFalse() throws {
        let lhsID = try XCTUnwrap(Migration.ID(rawValue: "00000000000001"))
        let rhsID = try XCTUnwrap(Migration.ID(rawValue: "00000000000001"))

        XCTAssertFalse(lhsID < rhsID)
    }

    func test_lessThan_whenLhsIsGreaterThanRhs_returnsFalse() throws {
        let lhsID = try XCTUnwrap(Migration.ID(rawValue: "00000000000002"))
        let rhsID = try XCTUnwrap(Migration.ID(rawValue: "00000000000001"))

        XCTAssertFalse(lhsID < rhsID)
    }

    func test_description_returnsRawValue() throws {
        let rawValue = "00000000000042"
        let id = try XCTUnwrap(Migration.ID(rawValue: rawValue))

        XCTAssertEqual(id.description, rawValue)
    }
}
