import ArgumentParser
import Lifecycle
import LifecycleNIOCompat
import Logging
import NIO

internal let logger = Logger(label: "one.ordo.swift-template-server")

@main
struct SwiftTemplateServer: AsyncParsableCommand {
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
        let signal = ServiceLifecycle.Signal.INT
        let lifecycle = ServiceLifecycle(configuration: .init(shutdownSignal: [signal]))

        // Set up NIO
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let server = MyServer(eventLoopGroup: eventLoopGroup)

        lifecycle.registerShutdown(
            label: "SwiftNIO eventLoopGroup",
            .sync(eventLoopGroup.syncShutdownGracefully)
        )

        lifecycle.register(
            label: "swift-template-server",
            start: .sync(server.run),
            shutdown: .none
        )

        lifecycle.start { error in
            if let error = error {
                print("ERROR: \(error)")
            }
        }

        lifecycle.wait()
    }
}
