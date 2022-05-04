import Logging
import NIO

// Connect using e.g. `nc localhost 9999` for testing
private final class EchoHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        context.write(data, promise: nil)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    func channelRegistered(context: ChannelHandlerContext) {
      logger.info("Client connected: \(String(describing: context.remoteAddress))")
    }

    func channelUnregistered(context: ChannelHandlerContext) {
      logger.info("Client disconnected")
    }

    func errorCaught(context: ChannelHandlerContext, error _: Error) {
        context.close(promise: nil)
    }
}

struct MyServer {
    var eventLoopGroup: EventLoopGroup

    func run() throws {
        let bootstrap = ServerBootstrap(group: eventLoopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 16)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(EchoHandler())
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator,
                                value: AdaptiveRecvByteBufferAllocator(minimum: 1_024,
                                                                       initial: 2_048,
                                                                       maximum: 1_024 * 1_024))

        // First argument is the program path
        let arguments = CommandLine.arguments
        let arg1 = arguments.dropFirst().first
        let arg2 = arguments.dropFirst(2).first

        let defaultHost = "::1"
        let defaultPort = 9_999

        enum BindTo {
            case ipAddress(host: String, port: Int)
            case unixDomainSocket(path: String)
        }

        let bindTarget: BindTo
        switch (arg1, arg1.flatMap(Int.init), arg2.flatMap(Int.init)) {
        case let (.some(host), _, .some(port)):
            /* we got two arguments, let's interpret that as host and port */
            bindTarget = .ipAddress(host: host, port: port)
        case let (.some(portString), .none, _):
            /* couldn't parse as number, expecting unix domain socket path */
            bindTarget = .unixDomainSocket(path: portString)
        case let (_, .some(port), _):
            /* only one argument --> port */
            bindTarget = .ipAddress(host: defaultHost, port: port)
        default:
            bindTarget = .ipAddress(host: defaultHost, port: defaultPort)
        }

        let channel = try { () -> Channel in
            switch bindTarget {
            case let .ipAddress(host, port):
                return try bootstrap.bind(host: host, port: port).wait()
            case let .unixDomainSocket(path):
                return try bootstrap.bind(unixDomainSocketPath: path).wait()
            }
        }()

        logger.info("Server started and listening on \(channel.localAddress!)")

        //        try channel.closeFuture.wait()
    }
}
