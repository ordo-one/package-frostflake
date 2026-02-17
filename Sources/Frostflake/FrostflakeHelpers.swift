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

/// Get current seconds since UNIX epoch
/// 32 bit number of seconds gives us ~136 years
func currentSecondsSinceEpoch() -> UInt32 {
    let currentTime = getCurrentTime()
    return UInt32(currentTime.tv_sec)
}

func currentNanoSecondsSinceEpoch() -> Int {
    let currentTime = getCurrentTime()
    return currentTime.tv_nsec
}

private func getCurrentTime() -> timespec {
    var currentTime = timespec()
    let result = clock_gettime(CLOCK_REALTIME, &currentTime)

    guard result == 0 else {
        fatalError("Failed to get current time in clock_gettime(), errno = \(errno)")
    }
    return currentTime
}

// For tests
@inline(never)
public func blackHole(_: some Any) {}
