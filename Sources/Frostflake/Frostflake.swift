// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Atomics

/// Frostflake generator, we tried with an Actor but it was too slow.
public final class Frostflake {
    public var genNumber: ManagedAtomic<UInt64>
    public let generatorIdentifier: UInt16

    public let forcedTimeRegenerationInterval: UInt32

    // Class variables and functions
    private static var privateSharedGenerator: Frostflake?

    /// Convenience static variable when using the same generator in many places
    /// The global generator identifier must be set using `setup(generatorIdentifier:)` before accessing
    /// this shared generator or we'll fatalError().
    public static var sharedGenerator: Frostflake {
        guard let generator = privateSharedGenerator else {
            preconditionFailure("accessed sharedGenerator before calling setup")
        }
        return generator
    }

    /// Setup may only be called a single time for a global shared generator identifier
    public static func setup(sharedGenerator: Frostflake) {
        if privateSharedGenerator != nil {
            preconditionFailure("called setup multiple times")
        }
        privateSharedGenerator = sharedGenerator
    }

    public static func teardown() {
        privateSharedGenerator = nil
    }

    /// Convenience static variable when using the same generator in many places
    /// The global generator identifier **must** be set using `setup(generatorIdentifier:)` before accessing
    /// this shared generator of we'll fatalError(). This includes by creating `FrostflakeIdentifier()` instances too
    /// which uses this shared generator in the implementation.
    ///
    ///  Sample usage:
    ///  ```swift
    /// Frostflake.setup(generatorIdentifier: 1)
    /// let frostflake1 =  Frostflake.generate()
    /// let frostflake2 =  Frostflake.generate()
    /// let frostflake3 = FrostflakeIdentifier()
    ///  ```
    @inlinable
    @inline(__always)
    public static func generate() -> FrostflakeIdentifier {
        sharedGenerator.generate()
    }

    // instance functions

    /// Initialize the ``Frostflake`` class
    /// Creates an instance of the generator for a given unique generator id.
    ///
    /// - Parameters:
    ///   - generatorIdentifier: The unique generator identifier for this instances, must be unique at every
    ///   point in time in the whole system, so either should be persisted and reused across runs, or it should be
    ///   coordinated with a global service that assigns them during startup of the component.
    ///   - forcedTimeRegenerationInterval: Regenerate timestamp forcibly after this many events.
    ///   0 -> never force, 1-> always force, n -> after n events
    ///   - concurrentAccess: Specifies whether the generator can be accessed from multiple
    ///   tasks/threads concurrently - if the generator is **only** used from a synchronized state
    ///   like .eg. an Actor context, you can specify false here to avoid the internal locking overhead
    @inlinable
    public init(generatorIdentifier: UInt16,
                forcedTimeRegenerationInterval: UInt32 = defaultForcedTimeRegenerationInterval,
                concurrentAccess _: Bool = true) {
        assert(FrostflakeLayout.validGeneratorIdentifierRange.contains(Int(generatorIdentifier)),
               "Frostflake generatorIdentifier \(generatorIdentifier) used more than \(FrostflakeLayout.generatorIdentifierBits) bits")
        assert((FrostflakeLayout.sequenceNumberBits + Self.generatorIdentifierBits) == 32,
               "Frostflake sequenceNumberBits (\(FrostflakeLayout.sequenceNumberBits)) + " +
                   "generatorIdentifierBits (\(FrostflakeLayout.generatorIdentifierBits)) != 32")

        let initialValue = Self.composeInitialValue(genID: generatorIdentifier)
        genNumber = ManagedAtomic<UInt64>(initialValue)
        self.generatorIdentifier = generatorIdentifier
        self.forcedTimeRegenerationInterval = forcedTimeRegenerationInterval
    }

    @inlinable
    static func composeInitialValue(genID: UInt16, lastGenNum: UInt64 = 0) -> UInt64 {
        let currentSeconds = currentSecondsSinceEpoch()

        assert(
            currentSeconds > FrostflakeLayout.seconds(lastGenNum),
            "too many FrostflakeIdentifiers generated in one second (in release seqNums will increment seconds)")

        return FrostflakeLayout.composeIdentifier(generatorId: genID, seconds: currentSeconds)
    }

    @inlinable
    func checkRange(genNumber: UInt64) -> Bool {
        let sequenceNumber = FrostflakeLayout.sequenceNumber(genNumber) + 1

        if FrostflakeLayout.allowedSequenceNumberRange.contains(Int(sequenceNumber))
            || forcedTimeRegenerationInterval <= 0
            || sequenceNumber < forcedTimeRegenerationInterval
            || currentSecondsSinceEpoch() > FrostflakeLayout.seconds(genNumber) {
            return true
        }
        assert(sequenceNumber == (1 << FrostflakeLayout.sequenceNumberBits) || FrostflakeLayout.allowedSequenceNumberRange.contains(Int(sequenceNumber)), "sequenceNumber != 1 << sequenceNumberBits")

        return false
    }

    /// Generates a new Frostflake identifier for the generator
    ///
    /// - Returns: A unique Frostflake identifier
    ///
    ///  Sample usage:
    ///  ```swift
    /// let frostflakeFactory = Frostflake(generatorIdentifier: 1)
    /// let frostflake1 =  frostflakeFactory.generate()
    /// let frostflake2 =  frostflakeFactory.generate()
    ///  ```
    @inlinable
    @inline(__always)
    public func generate() -> FrostflakeIdentifier {
        repeat {
            let nextSeqNum = genNumber.wrappingIncrementThenLoad(ordering: .relaxed)
            guard checkRange(genNumber: nextSeqNum) else {
                let newSeq = Self.composeInitialValue(genID: generatorIdentifier, lastGenNum: nextSeqNum - 1)
                if genNumber.weakCompareExchange(expected: nextSeqNum, desired: newSeq, ordering: .relaxed).exchanged {
                    return newSeq
                }
                continue
            }
            return nextSeqNum
        } while true
    }
}
