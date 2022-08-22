#if canImport(Darwin)

    import Darwin
    import Foundation

    func leaksExit() {
        @discardableResult
        func leaksTo(_ file: String) -> Process {
            let out = FileHandle(forWritingAtPath: file)!
            defer {
                do {
                    try out.close()
                } catch {}
            }
            let process = Process()
            process.launchPath = "/usr/bin/leaks"
            process.arguments = ["\(getpid())"]
            process.standardOutput = out
            process.standardError = out
            process.launch()
            process.waitUntilExit()
            return process
        }
        let process = leaksTo("/dev/null")
        guard process.terminationReason == .exit, [0, 1].contains(process.terminationStatus) else {
            print("Weird, \(process.terminationReason): \(process.terminationStatus)")
            exit(255)
        }
        if process.terminationStatus == 1 {
            print("================")
            print("Oh no, we leaked")
            print("================")
            leaksTo("/dev/null") // TODO : find out whu it crash if /dev/tty
        } else {
            print("No leaks detected with 'leaks'")
        }
        exit(process.terminationStatus)
    }
#endif
