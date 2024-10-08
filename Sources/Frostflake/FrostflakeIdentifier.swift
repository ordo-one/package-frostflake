#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

public struct FrostflakeIdentifier {
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    public var rawValue: UInt64
}

public extension FrostflakeIdentifier {
    var description: String {
        base58
    }
}

extension FrostflakeIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String {
        let seconds = rawValue >> Frostflake.secondsBits
        let sequenceNumber = (rawValue & 0xFFFF_FFFF) >> Frostflake.generatorIdentifierBits
        let generatorIdentifier = (rawValue & 0xFFFF_FFFF) & (0xFFFF_FFFF >> Frostflake.sequenceNumberBits)

        var tmStruct = tm()
        var time = Int(seconds)
        gmtime_r(&time, &tmStruct)
        let year = Int(tmStruct.tm_year + 1_900)
        let month = Int(tmStruct.tm_mon + 1)
        let day = Int(tmStruct.tm_mday)
        let hour = Int(tmStruct.tm_hour)
        let minute = Int(tmStruct.tm_min)
        let second = Int(tmStruct.tm_sec)

        return """
        \(self.description) \(rawValue) (\(year)-\(String(month).pad())-\(String(day).pad()) \
        \(String(hour).pad()):\(String(minute).pad()):\(String(second).pad()) UTC\
        , sequenceNumber:\(sequenceNumber), generatorIdentifier:\(generatorIdentifier))
        """
    }
}

extension String {
    func pad(_ padding: Int = 2) -> String {
        let toPad = padding - count
        if toPad < 1 {
            return self
        }
        return String(repeating: "0", count: toPad) + self
    }
}
