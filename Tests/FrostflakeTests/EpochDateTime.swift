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
        var tm = tm()
        gmtime_r(&timestamp, &tm)
        year = Int(tm.tm_year + 1900)
        month = Int(tm.tm_mon + 1)
        day = Int(tm.tm_mday)
        hour = Int(tm.tm_hour)
        minute = Int(tm.tm_min)
        second = Int(tm.tm_sec)
    }
}
