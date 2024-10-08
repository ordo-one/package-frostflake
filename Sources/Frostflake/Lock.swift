// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

// Adopted from SwiftNIO:s Lock, but changed to use os_unfair_lock on macOS
// and removed Windows lock support. This should be replaced with Swift 6 Mutex
// when older platform support is dropped

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#else
    #error("Unsupported Platform")
#endif

final class Lock {
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

extension Lock: Lockable {}

#if compiler(>=5.5) && canImport(_Concurrency)
    extension Lock: Sendable {}
#endif

/// Protocol any lock can implement.
public protocol Lockable {
    /// Default initializer.
    init()

    /// Acquire the lock.
    func lock()

    /// Release the lock.
    func unlock()
}

public extension Lockable {
    /// Acquire the lock for the duration of the given block.
    ///
    /// This convenience method should be preferred to `lock` and `unlock` in
    /// most situations, as it ensures that the lock will be released regardless
    /// of how `body` exits.
    ///
    /// - Parameter body: The block to execute while holding the lock.
    /// - Returns: The value returned by the block.
    @inlinable
    @inline(__always)
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer {
            self.unlock()
        }
        return try body()
    }

    // specialise Void return (for performance)
    @inlinable
    @inline(__always)
    func withLockVoid(_ body: () throws -> Void) rethrows {
        try withLock(body)
    }
}
