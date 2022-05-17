#if canImport(Darwin)

import Foundation
import Darwin

func leaksExit() {
    @discardableResult
    func leaksTo(_ file: String) -> Process {
        let out = FileHandle(forWritingAtPath: file)!
        defer {
            try! out.close()
        }
        let p = Process()
        p.launchPath = "/usr/bin/leaks"
        p.arguments = [ "\(getpid())" ]
        p.standardOutput = out
        p.standardError = out
        p.launch()
        p.waitUntilExit()
        return p
    }
    let p = leaksTo("/dev/null")
    guard p.terminationReason == .exit && [0, 1].contains(p.terminationStatus) else {
        print("Weird, \(p.terminationReason): \(p.terminationStatus)")
        exit(255)
    }
    if p.terminationStatus == 1 {
        print("================")
        print("Oh no, we leaked")
        print("================")
        leaksTo("/dev/tty")
    } else {
        print("No leaks detected with 'leaks'")
    }
    exit(p.terminationStatus)
}
#endif
