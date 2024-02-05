// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import DateTime

/// Get current seconds since UNIX epoch
/// 32 bit number of seconds gives us ~136 years
@inlinable
@inline(__always)
func currentSecondsSinceEpoch() -> UInt32 {
    let timestamp = InternalUTCClock.now
    return UInt32(timestamp.seconds())
}

private extension String {
    func pad(_ padding: Int = 2) -> String {
        let toPad = padding - count
        if toPad < 1 {
            return self
        }
        return "".padding(toLength: toPad, withPad: "0", startingAt: 0) + self
    }
}

/// Pretty printer for frostflakes for debugging
public extension FrostflakeIdentifier {
    func frostflakeDescription() -> String {
        let seconds = self >> Frostflake.secondsBits
        let sequenceNumber = (self & 0xFFFF_FFFF) >> Frostflake.generatorIdentifierBits
        let generatorIdentifier = (self & 0xFFFF_FFFF) & (0xFFFF_FFFF >> Frostflake.sequenceNumberBits)

        var time = EpochDateTime.unixEpoch()
        time.convert(timestamp: Int(seconds))

        return """
        \(self) (\(time.year)-\(String(time.month).pad())-\(String(time.day).pad()) \
        \(String(time.hour).pad()):\(String(time.minute).pad()):\(String(time.second).pad()) UTC\
        , sequenceNumber:\(sequenceNumber), generatorIdentifier:\(generatorIdentifier))
        """
    }
}

// For tests
@inline(never)
public func blackHole(_: some Any) {}
