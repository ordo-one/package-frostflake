internal let sequenceNumberBits = 20 // Default 20 bits, 1.048.576 id:s max per second
internal let generatorIdentifierBits = 12 // Default 12 bits, 4096 unique concurrent generators in the system

public extension UInt64 {
    func frostflakeDescription() -> String {
        let seconds = self >> 32
        let sequenceNumber = (self & 0xFFFF_FFFF) >> generatorIdentifierBits
        let generatorIdentifier = (self & 0xFFFF_FFFF) & (0xFFFF_FFFF >> sequenceNumberBits)
        return "(\(seconds), \(sequenceNumber), \(generatorIdentifier))"
    }
}

// Just consume the argument.
// It's important that this function is in another module than the tests
// which are using it.
@inline(never)
public func blackHole<T>(_: T) {}
