#if canImport(Darwin)

    import Darwin
    import Foundation

    func leaksExit() {
        @discardableResult
        func leaks() -> Process {
            let process = Process()
            process.launchPath = "/usr/bin/leaks"
            process.arguments = ["\(getpid())"]
            process.standardOutput = FileHandle.standardOutput
            process.standardError = FileHandle.nullDevice
            process.launch()
            process.waitUntilExit()
            return process
        }
        let process = leaks()
        guard process.terminationReason == .exit, [0, 1].contains(process.terminationStatus) else {
            print("Weird, \(process.terminationReason): \(process.terminationStatus)")
            exit(255)
        }
        if process.terminationStatus == 1 {
            print("================")
            print("Oh no, we leaked")
            print("================")
        } else {
            print("No leaks detected with 'leaks'")
        }
        exit(process.terminationStatus)
    }
#endif
