#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

public actor Frostflake {
    private var seconds: UInt32 // ~136 years
    private var sequenceNumber: UInt32
    private var generatorIdentifier: UInt16

    public init(generatorIdentifier: UInt16) {
        let allowedGeneratorIdentifierRange = 0 ..< (1 << generatorIdentifierBits)
        assert(allowedGeneratorIdentifierRange.contains(Int(generatorIdentifier)),
               "Frostflake generatorIdentifier \(generatorIdentifier) used more than \(generatorIdentifierBits) bits")
        assert((sequenceNumberBits + generatorIdentifierBits) == 32,
               "Frostflake sequenceNumberBits (\(sequenceNumberBits)) + " +
                   "generatorIdentifierBits (\(generatorIdentifierBits)) != 32")
        seconds = Self.currentSecondsSinceEpoch()
        sequenceNumber = 0
        self.generatorIdentifier = generatorIdentifier
    }

    internal static func currentSecondsSinceEpoch() -> UInt32 {
        var currentTime = timeval()
        gettimeofday(&currentTime, nil)
        //    print("currentSecondsSinceEpoch: \(UInt32(currentTime.tv_sec))")
        return UInt32(currentTime.tv_sec)
    }

    public func generatorFrostflakeIdentifier() -> UInt64 {
        let allowedSequenceNumberRange = 0 ..< (1 << sequenceNumberBits)

        assert(allowedSequenceNumberRange.contains(Int(sequenceNumber)), "sequenceNumber ouf of allowed range")

        sequenceNumber += 1

        // Have we used all the sequence number bits, we need get a new base timestamp
        if allowedSequenceNumberRange.contains(Int(sequenceNumber)) == false {
            assert(sequenceNumber == (1 << sequenceNumberBits), "sequenceNumber != 1 << sequenceNumberBits")

            let currentSecond = Self.currentSecondsSinceEpoch()

            // The maximum rate is 1 << sequenceNumberBits per second (defaults to over 1M per second)
            // Currently we'll bail here - one could have
            precondition(currentSecond > seconds, "too many FrostflakeIdentifiers generated in one second, aborting")

            seconds = currentSecond
            sequenceNumber = 0
        }

        var returnValue = UInt64(seconds) << 32
        returnValue += UInt64(sequenceNumber) << generatorIdentifierBits
        returnValue += UInt64(generatorIdentifier)

        return returnValue
    }
}
