// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

// Adopted from SwiftNIO:s Lock, but changed to use os_unfair_lock on macOS
// and removed Windows lock support.

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

public final class Lock {
    #if os(macOS)
        fileprivate let mutex = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
    #else
        fileprivate let mutex: UnsafeMutablePointer<pthread_mutex_t> =
            UnsafeMutablePointer.allocate(capacity: 1)
    #endif

    /// Create a new lock.
    public init() {
        #if os(macOS)
            mutex.initialize(to: os_unfair_lock())
        #else
            var attr = pthread_mutexattr_t()
            pthread_mutexattr_init(&attr)

            let err = pthread_mutex_init(mutex, &attr)
            precondition(err == 0, "\(#function) failed in pthread_mutex with error \(err)")
        #endif
    }

    deinit {
        #if os(macOS)
            mutex.deinitialize(count: 1)
        #else
            let err = pthread_mutex_destroy(self.mutex)
            precondition(err == 0, "\(#function) failed in pthread_mutex with error \(err)")
        #endif
        mutex.deallocate()
    }

    /// Acquire the lock.
    ///
    /// Whenever possible, consider using `withLock` instead of this method and
    /// `unlock`, to simplify lock handling.
    public func lock() {
        #if os(macOS)
            os_unfair_lock_lock(mutex)
        #else
            let err = pthread_mutex_lock(mutex)
            precondition(err == 0, "\(#function) failed in pthread_mutex with error \(err)")
        #endif
    }

    /// Release the lock.
    ///
    /// Whenever possible, consider using `withLock` instead of this method and
    /// `lock`, to simplify lock handling.
    public func unlock() {
        #if os(macOS)
            os_unfair_lock_unlock(mutex)
        #else
            let err = pthread_mutex_unlock(mutex)
            precondition(err == 0, "\(#function) failed in pthread_mutex with error \(err)")
        #endif
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)
    extension Lock: Sendable {}
#endif
