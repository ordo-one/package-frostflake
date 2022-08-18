import ConcurrencyHelpers

/// Frostflake generator
public final class Frostflake {
    public var seconds: UInt32
    public var sequenceNumber: UInt32
    public let generatorIdentifier: UInt16
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
        if privateSharedGenerator != nil {
            preconditionFailure("called setup multiple times")
        }
        privateSharedGenerator = sharedGenerator
    }

    /// Convenience static variable when using the same generator in many places
    /// The global generator identifier **must** be set using `setup(generatorIdentifier:)` before accessing
    /// this shared generator of we'll fatalError().
    ///
    ///  Sample usage:
    ///  ```swift
    /// Frostflake.setup(generatorIdentifier: 1)
    /// let frostflake1 =  Frostflake.generate()
    /// let frostflake2 =  Frostflake.generate()
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
    ///   - concurrentAccess: Specifies whether the generator can be accessed from multiple
    ///   tasks/threads concurrently - if the generator is **only** used from a synchronized state
    ///   like .eg. an Actor context, you can specify false here to avoid the internal locking overhead
    @inlinable
    public init(generatorIdentifier: UInt16, concurrentAccess: Bool = true) {
        let allowedGeneratorIdentifierRange = 0 ..< (1 << generatorIdentifierBits)
        assert(allowedGeneratorIdentifierRange.contains(Int(generatorIdentifier)),
               "Frostflake generatorIdentifier \(generatorIdentifier) used more than \(generatorIdentifierBits) bits")
        assert((sequenceNumberBits + generatorIdentifierBits) == 32,
               "Frostflake sequenceNumberBits (\(sequenceNumberBits)) + " +
                   "generatorIdentifierBits (\(generatorIdentifierBits)) != 32")
        if concurrentAccess {
            lock = Lock()
        } else {
            lock = nil
        }
        sequenceNumber = 0
        self.generatorIdentifier = generatorIdentifier
        seconds = currentSecondsSinceEpoch()
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
        let allowedSequenceNumberRange = 0 ..< (1 << sequenceNumberBits)

        lock?.lock()

        assert(allowedSequenceNumberRange.contains(Int(sequenceNumber)), "sequenceNumber ouf of allowed range")

        sequenceNumber += 1

        // Have we used all the sequence number bits, we need get a new base timestamp
        if allowedSequenceNumberRange.contains(Int(sequenceNumber)) == false {
            assert(sequenceNumber == (1 << sequenceNumberBits), "sequenceNumber != 1 << sequenceNumberBits")

            let currentSecond = currentSecondsSinceEpoch()

            // The maximum rate is 1 << sequenceNumberBits per second (defaults to over 1M per second)
            // Currently we'll bail here - one could consider sleeping / retrying, but really synthetic problem.
            precondition(currentSecond > seconds, "too many FrostflakeIdentifiers generated in one second, aborting")

            seconds = currentSecond
            sequenceNumber = 1
        } else if (sequenceNumber % forcedSecondRegenerationInterval) == 0 {
            let currentSecond = currentSecondsSinceEpoch()
            if currentSecond > seconds {
                seconds = currentSecond
                sequenceNumber = 1
            }
        }

        var returnValue = UInt64(seconds) << 32
        returnValue += UInt64(sequenceNumber) << generatorIdentifierBits
        returnValue += UInt64(generatorIdentifier)

        lock?.unlock()

        return returnValue
    }
}
