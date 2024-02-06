// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import ArgumentParser
import FrostflakeKit

@main
struct FrostflakeUtility: AsyncParsableCommand {
    @Option(help: "Specify generatorIdentifier to create a Frostflake with that generator id.")
    var generatorIdentifier: Int = Frostflake.defaultManualGeneratorIdentifier

    @Option(help: "Decode a Frostflake timestamp by specifying a frostflake identifier")
    var identifier: String?

    @Flag(help: "Output Frostflake encoded in base58") var base58 = false

    mutating func run() async throws {
        if let frostflakeIdentifier = identifier {
            if let value = UInt64(frostflakeIdentifier) {
                print("Frostflake \(frostflakeIdentifier) decoded:")
                print("\(value.frostflakeDescription())")
            } else {
                if let value = UInt64(base58: frostflakeIdentifier) {
                    print("Frostflake \(frostflakeIdentifier) decoded:")
                    print("\(value.frostflakeDescription())")
                } else {
                    print("Could not decode \(frostflakeIdentifier)")
                }
            }
        } else {
            guard Frostflake.validGeneratorIdentifierRange.contains(generatorIdentifier) else {
                print("Frostflake generatorIdentifier should be in the range \(Frostflake.validGeneratorIdentifierRange)")
                return
            }

            let frostflakeFactory = Frostflake(generatorIdentifier: UInt16(generatorIdentifier),
                                               concurrentAccess: false)
            if base58 {
                print("\(frostflakeFactory.generate().base58)")
            } else {
                print("\(frostflakeFactory.generate())")
            }
        }
    }
}
