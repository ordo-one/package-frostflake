#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

/// Default number of bits allocated to sequence, default 20 bits, 1.048.576 id:s max per second
public let sequenceNumberBits = 20
/// Default number of bits allocated to generator part, default 12 bits, 4096 unique concurrent generators in the system
public let generatorIdentifierBits = 12

/// We will try to generate a new second timestamp every N generations (for low-flow components this will reset the
/// timestamp a few times per day, for high-flow users it will cause a call to `gettimeofday()` needlessly instead.)
public let forcedSecondRegenerationInterval: UInt32 = 1_000

/// Get current seconds since UNIX epoch
/// 32 bit number of seconds gives us ~136 years
@inlinable
@inline(__always)
public func currentSecondsSinceEpoch() -> UInt32 {
    var currentTime = timespec()

    let result = clock_gettime(CLOCK_REALTIME, &currentTime)

    guard result == 0 else {
        fatalError("Failed to get current time in clock_gettime(), errno = \(errno)")
    }

    return UInt32(currentTime.tv_sec)
}

/// Pretty printer for frostflakes for debugging
public extension UInt64 {
    func frostflakeDescription() -> String {
        let seconds = self >> 32
        let sequenceNumber = (self & 0xFFFF_FFFF) >> generatorIdentifierBits
        let generatorIdentifier = (self & 0xFFFF_FFFF) & (0xFFFF_FFFF >> sequenceNumberBits)
        return "(\(seconds), \(sequenceNumber), \(generatorIdentifier))"
    }
}

/// Blackhole that will disable the optimizer when defined in a different module,
/// useful for benchmarks and just consumes the argument.
/// **It's important that this function is in another module than the tests which are using it.**
@inline(never)
public func blackHole<T>(_: T) {}
