import ArgumentParser
import Lifecycle
import LifecycleNIOCompat
import Logging
import NIO

internal let logger = Logger(label: "one.ordo.swift-frostflake")

@main
struct SwiftFrostflake: AsyncParsableCommand {
    // Add swift-argument-parser flags/options/etc here for command line options:
    //  @Option(
    //    name: [.short, .customLong("destination")],
    //    help: "The output directory (e.g. ~/mydatamodel_output)"
    //  )
    //  var destinationPath: String?
    // or
    //  @Flag(help: "Run as a client")
    //  var client = false

    mutating func run() async throws {
    }
}
