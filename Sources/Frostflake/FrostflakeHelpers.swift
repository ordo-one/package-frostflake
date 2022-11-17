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
internal func currentSecondsSinceEpoch() -> UInt32 {
    let timestamp = InternalUTCClock.now
    return UInt32(timestamp.secondsSinceEpoch())
}

/// Pretty printer for frostflakes for debugging
public extension UInt64 {
    func frostflakeDescription() -> String {
        let seconds = self >> Frostflake.secondsBits
        let sequenceNumber = (self & 0xFFFF_FFFF) >> Frostflake.generatorIdentifierBits
        let generatorIdentifier = (self & 0xFFFF_FFFF) & (0xFFFF_FFFF >> Frostflake.sequenceNumberBits)

        var time = EpochDateTime.unixEpoch()
        time.convert(timestamp: Int(seconds))

        return """
        (\(time.year)-\(time.month)-\(time.day) \(time.hour):\(time.minute):\(time.second) UTC\
        , sequenceNumber:\(sequenceNumber), generatorIdentifier:\(generatorIdentifier))
        """
    }
}

// For tests
@inline(never)
public func blackHole(_: some Any) {}
