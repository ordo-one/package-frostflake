// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

import Foundation

/// Get current seconds since UNIX epoch
/// 32 bit number of seconds gives us ~136 years
func currentSecondsSinceEpoch() -> UInt32 {
    var currentTime = timespec()
    let result = clock_gettime(CLOCK_REALTIME, &currentTime)

    guard result == 0 else {
        fatalError("Failed to get current time in clock_gettime(), errno = \(errno)")
    }

    return UInt32(currentTime.tv_sec)
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

        var tm = tm()
        var time = Int(seconds)
        gmtime_r(&time, &tm)
        let year = Int(tm.tm_year + 1_900)
        let month = Int(tm.tm_mon + 1)
        let day = Int(tm.tm_mday)
        let hour = Int(tm.tm_hour)
        let minute = Int(tm.tm_min)
        let second = Int(tm.tm_sec)

        return """
        \(self) (\(year)-\(String(month).pad())-\(String(day).pad()) \
        \(String(hour).pad()):\(String(minute).pad()):\(String(second).pad()) UTC\
        , sequenceNumber:\(sequenceNumber), generatorIdentifier:\(generatorIdentifier))
        """
    }
}

// For tests
@inline(never)
public func blackHole(_: some Any) {}
