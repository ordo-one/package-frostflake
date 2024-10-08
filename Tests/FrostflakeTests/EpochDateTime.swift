//
//  EpochDateTime.swift
//  package-frostflake
//
//  Created by Joakim Hassila on 2024-10-08.
//

#if canImport(Darwin)
import Darwin
#endif

#if canImport(Glibc)
import Glibc
#endif

public struct EpochDateTime {
    public var year: Int
    public var month: Int
    public var day: Int
    public var hour: Int
    public var minute: Int
    public var second: Int

    public static func unixEpoch() -> Self {
        Self(year: 1_970, month: 1, day: 1, hour: 0, minute: 0, second: 0)
    }

    public static func testEpoch() -> Self {
        Self(year: 2_022, month: 5, day: 20, hour: 14, minute: 0, second: 0)
    }

    /// Converts a timestamp in seconds to the appropriate year/month/day/hour/minute/second from the Unix epoch
    public mutating func convert(timestamp: Int) {
        var timestamp = timestamp
        var time = tm()
        gmtime_r(&timestamp, &time)
        year = Int(time.tm_year + 1_900)
        month = Int(time.tm_mon + 1)
        day = Int(time.tm_mday)
        hour = Int(time.tm_hour)
        minute = Int(time.tm_min)
        second = Int(time.tm_sec)
    }
}
