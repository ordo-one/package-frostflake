// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import PackageConcurrencyHelpers

/// Frostflake generator, we tried with an Actor but it was too slow.
public final class Frostflake {
    public var currentSeconds: UInt32
    public var sequenceNumber: UInt32
    public let generatorIdentifier: UInt16
    public let forcedTimeRegenerationInterval: UInt32
    public let lock: Lock?

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
        guard privateSharedGenerator !== sharedGenerator else { // To allow for better testing
            return
        }

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
                concurrentAccess: Bool = true) {
        assert(Self.validGeneratorIdentifierRange.contains(Int(generatorIdentifier)),
               "Frostflake generatorIdentifier \(generatorIdentifier) used more than \(Self.generatorIdentifierBits) bits")
        assert((Self.sequenceNumberBits + Self.generatorIdentifierBits) == 32,
               "Frostflake sequenceNumberBits (\(Self.sequenceNumberBits)) + " +
                   "generatorIdentifierBits (\(Self.generatorIdentifierBits)) != 32")

        if concurrentAccess {
            lock = Lock()
        } else {
            lock = nil
        }

        sequenceNumber = 0
        self.generatorIdentifier = generatorIdentifier
        self.forcedTimeRegenerationInterval = forcedTimeRegenerationInterval
        currentSeconds = currentSecondsSinceEpoch()
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
        lock?.lock()

        assert(Self.allowedSequenceNumberRange.contains(Int(sequenceNumber)), "sequenceNumber ouf of allowed range")

        sequenceNumber += 1

        // Have we used all the sequence number bits, we need get a new base timestamp
        if Self.allowedSequenceNumberRange.contains(Int(sequenceNumber)) == false {
            assert(sequenceNumber == (1 << Self.sequenceNumberBits), "sequenceNumber != 1 << sequenceNumberBits")

            let newCurrentSeconds = currentSecondsSinceEpoch()

            // The maximum rate is 1 << sequenceNumberBits per second (defaults to over 1M per second)
            // Currently we'll bail here - one could consider sleeping / retrying, but really synthetic problem.
            // Theoretically this could happen for NTP discrete timejumps back in time too, in which case
            // we'd rather abort and go down.
            precondition(newCurrentSeconds > currentSeconds, "too many FrostflakeIdentifiers generated in one second")

            currentSeconds = newCurrentSeconds
            sequenceNumber = 1
        } else if forcedTimeRegenerationInterval > 0, (sequenceNumber % forcedTimeRegenerationInterval) == 0 {
            let newCurrentSeconds = currentSecondsSinceEpoch()
            if newCurrentSeconds > currentSeconds {
                currentSeconds = newCurrentSeconds
                sequenceNumber = 1
            }
        }

        var returnValue = UInt64(currentSeconds) << Self.secondsBits
        returnValue += UInt64(sequenceNumber) << Self.generatorIdentifierBits
        returnValue += UInt64(generatorIdentifier)

        lock?.unlock()

        return returnValue
    }
}
