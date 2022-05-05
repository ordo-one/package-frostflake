/// Frostflake generator
public actor Frostflake {
    private var seconds: UInt32
    private var sequenceNumber: UInt32
    private let generatorIdentifier: UInt16

    /// Initialize the ``Frostflake`` actor
    /// Creates an instance of the generator for a given unique generator id.
    ///
    /// - Parameters:
    ///   - generatorIdentifier: The unique generator identifier for this instances, must be unique at every
    ///   point in time in the whole system, so either should be persisted and reused across runs, or it should be
    ///   coordinated with a global service that assigns them during startup of the component.
    public init(generatorIdentifier: UInt16) {
        let allowedGeneratorIdentifierRange = 0 ..< (1 << generatorIdentifierBits)
        assert(allowedGeneratorIdentifierRange.contains(Int(generatorIdentifier)),
               "Frostflake generatorIdentifier \(generatorIdentifier) used more than \(generatorIdentifierBits) bits")
        assert((sequenceNumberBits + generatorIdentifierBits) == 32,
               "Frostflake sequenceNumberBits (\(sequenceNumberBits)) + " +
                   "generatorIdentifierBits (\(generatorIdentifierBits)) != 32")
        seconds = currentSecondsSinceEpoch()
        sequenceNumber = 0
        self.generatorIdentifier = generatorIdentifier
    }

    /// Generates a new Frostflake identifier for the generator
    ///
    /// - Returns: A unique Frostflake identifier
    ///
    ///  Sample usage:
    ///  ```swift
    /// let frostflakeGenerator = Frostflake(generatorIdentifier: 1)
    /// let frostflake1 = await frostflakeGenerator.generatorFrostflakeIdentifier()
    /// let frostflake2 = await frostflakeGenerator.generatorFrostflakeIdentifier()
    ///  ```
    public func generatorFrostflakeIdentifier() -> UInt64 {
        let allowedSequenceNumberRange = 0 ..< (1 << sequenceNumberBits)

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
        }

        var returnValue = UInt64(seconds) << 32
        returnValue += UInt64(sequenceNumber) << generatorIdentifierBits
        returnValue += UInt64(generatorIdentifier)

        return returnValue
    }
}
