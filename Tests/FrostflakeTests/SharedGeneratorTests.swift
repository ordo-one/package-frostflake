// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Frostflake
import Testing

@Suite("Shared Generator Tests", .sharedGenerator)
struct SharedGeneratorTests {
    private let smallRangeTest = 1 ..< 1_000

    @Test("Shared generator produces valid identifiers")
    func frostflakeSharedGenerator() {
        for _ in smallRangeTest {
            blackHole(Frostflake.generate())
        }
    }

    @Test("FrostflakeIdentifier initializer uses shared generator")
    func frostflakeSharedGeneratorWithCustomInit() {
        for _ in smallRangeTest {
            blackHole(FrostflakeIdentifier())
        }
    }
}
