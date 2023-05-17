// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

/// Alias for Frostflake identifier type
public typealias FrostflakeIdentifier = UInt64

public extension FrostflakeIdentifier {
    @inlinable
    @inline(__always)
    init() {
        self = Frostflake.sharedGenerator.generate()
    }
}

public extension Frostflake {
    /// Default number of bits allocated to seconds, default 32 bits, gives us ~136 years
    static let secondsBits = 32

    /// Default number of bits allocated to sequence, default 21 bits, 2.097.152 id:s max per second
    static let sequenceNumberBits = 21

    /// Default number of bits allocated to generator part, default 11 bits, 2.048 unique concurrent generators in the system
    static let generatorIdentifierBits = 11

    /// The range of valid generator identifiers
    static let validGeneratorIdentifierRange = 0 ..< (1 << generatorIdentifierBits)

    /// The range of valid sequence numbers
    static let allowedSequenceNumberRange = 0 ..< (1 << Frostflake.sequenceNumberBits)

    /// Convenience default manual generator identifier for the command line utility will pick the highest available identifier
    static let defaultManualGeneratorIdentifier = (1 << generatorIdentifierBits) - 1

    /// We will try to generate a new second timestamp every N generations (for low-flow components this will reset the
    /// timestamp a few times per day, for high-flow users it will cause a call to `gettimeofday()` needlessly instead.)
    /// This should be set to the value of `1` if one can't guarantee that the system clock will not jump due to e.g. NTP
    /// changes. Then a timestamp will be done for every Frostflake generation.
    static let defaultForcedTimeRegenerationInterval: UInt32 = 1_000
}
