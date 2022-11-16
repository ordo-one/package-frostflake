// swiftlint:disable line_length
/// Alias for Frostflake identifier type
public typealias FrostflakeIdentifier = UInt64

public extension Frostflake {
    /// Default number of bits allocated to sequence, default 20 bits, 1.048.576 id:s max per second - 2.097.152
    static let secondsBits = 32

    /// Default number of bits allocated to sequence, default 20 bits, 1.048.576 id:s max per second - 2.097.152
    static let sequenceNumberBits = 20

    /// Default number of bits allocated to generator part, default 12 bits, 4096 unique concurrent generators in the system
    static let generatorIdentifierBits = 12

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
