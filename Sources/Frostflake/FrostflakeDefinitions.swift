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

// Internal Layout
@usableFromInline
enum FrostflakeLayout {
    /// Default number of bits allocated to generator part, default 11 bits, 2.048 unique concurrent generators in the system
    @usableFromInline
    static let generatorIdentifierBits = 11

    /// Default number of bits allocated to seconds, default 32 bits, gives us ~136 years
    @usableFromInline
    static let secondsBits = 32

    /// Default number of bits allocated to sequence, default 21 bits, 2.097.152 id:s max per second
    @usableFromInline
    static let sequenceNumberBits = 21

    /// <generatorIdentifierBits: 11><secondsBits: 32><sequenceNumberBits: 21>

    private static let sequenceNumberBitsLayout = 0 ..< sequenceNumberBits
    private static let secondsBitsLayout = sequenceNumberBitsLayout.upperBound ..< sequenceNumberBitsLayout.upperBound + secondsBits
    private static let generatorIdentifierBitsLayout = secondsBitsLayout.upperBound ..< secondsBitsLayout.upperBound + generatorIdentifierBits

    /// The range of valid generator identifiers
    @usableFromInline
    static let validGeneratorIdentifierRange = 0 ..< (1 << generatorIdentifierBits)

    /// The range of valid sequence numbers
    @usableFromInline
    static let allowedSequenceNumberRange = 0 ..< (1 << sequenceNumberBits)

    /// Convenience default manual generator identifier for the command line utility will pick the highest available identifier
    @usableFromInline
    static let defaultManualGeneratorIdentifier = (1 << generatorIdentifierBits) - 1

    @usableFromInline
    static func composeIdentifier(generatorId: UInt16, seconds: UInt32, seqNum: UInt32 = 0) -> UInt64 {
        var retValue = UInt64(generatorId)
        retValue = retValue << secondsBits
        retValue += UInt64(seconds)
        retValue = retValue << sequenceNumberBits
        retValue += UInt64(seqNum)
        return retValue
    }

    @usableFromInline
    static func maskValue<T: BinaryInteger>(_ id: UInt64, from: Int, to: Int) -> T {
        T(truncatingIfNeeded: (id >> from) & UInt64((1 << (to - from)) - 1))
    }

    @usableFromInline
    static func seconds(_ id: UInt64) -> UInt32 {
        maskValue(id, from: secondsBitsLayout.lowerBound, to: secondsBitsLayout.upperBound)
    }

    @usableFromInline
    static func generatorId(_ id: UInt64) -> UInt16 {
        maskValue(id, from: generatorIdentifierBitsLayout.lowerBound, to: generatorIdentifierBitsLayout.upperBound)
    }

    @usableFromInline
    static func sequenceNumber(_ id: UInt64) -> UInt32 {
        maskValue(id, from: sequenceNumberBitsLayout.lowerBound, to: sequenceNumberBitsLayout.upperBound)
    }
}

public extension Frostflake {
    /// Default number of bits allocated to seconds, default 32 bits, gives us ~136 years
    static let secondsBits = FrostflakeLayout.secondsBits

    /// Default number of bits allocated to sequence, default 21 bits, 2.097.152 id:s max per second
    static let sequenceNumberBits = FrostflakeLayout.sequenceNumberBits

    /// Default number of bits allocated to generator part, default 11 bits, 2.048 unique concurrent generators in the system
    static let generatorIdentifierBits = FrostflakeLayout.generatorIdentifierBits

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
