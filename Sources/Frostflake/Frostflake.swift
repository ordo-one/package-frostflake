// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Synchronization

/// Frostflake generator, we tried with an Actor but it was too slow.
public final class Frostflake: Sendable {
    private struct MutableState: Sendable {
        var currentSeconds: UInt32
        var sequenceNumber: UInt32
    }

    private final class StateBox: @unchecked Sendable {
        var state: MutableState
        init(_ state: MutableState) { self.state = state }
    }

    private enum State: ~Copyable, Sendable {
        case synchronized(Mutex<MutableState>)
        case unsynchronized(StateBox)
    }

    private let state: State
    public let generatorIdentifier: UInt16
    public let forcedTimeRegenerationInterval: UInt32

    // Public accessors for state
    public var currentSeconds: UInt32 {
        switch state {
        case .synchronized(let mutex):
            mutex.withLock { $0.currentSeconds }
        case .unsynchronized(let box):
            box.state.currentSeconds
        }
    }

    public var sequenceNumber: UInt32 {
        switch state {
        case .synchronized(let mutex):
            mutex.withLock { $0.sequenceNumber }
        case .unsynchronized(let box):
            box.state.sequenceNumber
        }
    }

    // Class variables and functions
    private static let sharedGeneratorLock = Mutex<Frostflake?>(nil)

    /// Convenience static variable when using the same generator in many places
    /// The global generator identifier must be set using `setup(generatorIdentifier:)` before accessing
    /// this shared generator or we'll fatalError().
    public static var sharedGenerator: Frostflake {
        sharedGeneratorLock.withLock { generator in
            guard let generator else {
                preconditionFailure("accessed sharedGenerator before calling setup")
            }
            return generator
        }
    }

    /// Setup may only be called a single time for a global shared generator identifier
    public static func setup(sharedGenerator: Frostflake) {
        sharedGeneratorLock.withLock { generator in
            /// That check is very helpful for tests when `setup` function can be invoked several times from `setUp` XCTest function.
            if generator?.generatorIdentifier == sharedGenerator.generatorIdentifier {
                return
            }
            if generator != nil {
                preconditionFailure("called setup multiple times")
            }
            generator = sharedGenerator
        }
    }

    public static func teardown() {
        sharedGeneratorLock.withLock { generator in
            generator = nil
        }
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
    public init(generatorIdentifier: UInt16,
                forcedTimeRegenerationInterval: UInt32 = defaultForcedTimeRegenerationInterval,
                concurrentAccess: Bool = true) {
        assert(Self.validGeneratorIdentifierRange.contains(Int(generatorIdentifier)),
               "Frostflake generatorIdentifier \(generatorIdentifier) used more than \(Self.generatorIdentifierBits) bits")
        assert((Self.sequenceNumberBits + Self.generatorIdentifierBits) == 32,
               "Frostflake sequenceNumberBits (\(Self.sequenceNumberBits)) + " +
                   "generatorIdentifierBits (\(Self.generatorIdentifierBits)) != 32")

        let currentSeconds = currentSecondsSinceEpoch()
        let currentNanoSeconds = currentNanoSecondsSinceEpoch()

        let initialState = MutableState(
            currentSeconds: currentSeconds,
            sequenceNumber: UInt32((currentNanoSeconds / 1_000) % 1_000_000)
        )

        if concurrentAccess {
            state = .synchronized(Mutex(initialState))
        } else {
            state = .unsynchronized(StateBox(initialState))
        }

        self.generatorIdentifier = generatorIdentifier
        self.forcedTimeRegenerationInterval = forcedTimeRegenerationInterval
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
    public func generate() -> FrostflakeIdentifier {
        switch state {
        case .synchronized(let mutex):
            mutex.withLock { state in
                generateInternal(state: &state)
            }
        case .unsynchronized(let box):
            generateInternal(state: &box.state)
        }
    }

    private func generateInternal(state: inout MutableState) -> FrostflakeIdentifier {
        assert(Self.allowedSequenceNumberRange.contains(Int(state.sequenceNumber)), "sequenceNumber out of allowed range")

        state.sequenceNumber += 1

        // Have we used all the sequence number bits, we need get a new base timestamp
        if Self.allowedSequenceNumberRange.contains(Int(state.sequenceNumber)) == false {
            assert(state.sequenceNumber == (1 << Self.sequenceNumberBits), "sequenceNumber != 1 << sequenceNumberBits")

            let newCurrentSeconds = currentSecondsSinceEpoch()

            // The maximum rate is 1 << sequenceNumberBits per second (defaults to over 1M per second)
            // Currently we'll bail here - one could consider sleeping / retrying, but really synthetic problem.
            // Theoretically this could happen for NTP discrete timejumps back in time too, in which case
            // we'd rather abort and go down.
            precondition(newCurrentSeconds > state.currentSeconds, "too many FrostflakeIdentifiers generated in one second")

            state.currentSeconds = newCurrentSeconds
            state.sequenceNumber = 1
        } else if forcedTimeRegenerationInterval > 0, (state.sequenceNumber % forcedTimeRegenerationInterval) == 0 {
            let newCurrentSeconds = currentSecondsSinceEpoch()
            if newCurrentSeconds > state.currentSeconds {
                state.currentSeconds = newCurrentSeconds
                state.sequenceNumber = 1
            }
        }

        var returnValue = UInt64(state.currentSeconds) << Self.secondsBits
        returnValue += UInt64(state.sequenceNumber) << Self.generatorIdentifierBits
        returnValue += UInt64(generatorIdentifier)

        return .init(rawValue: returnValue)
    }
}
