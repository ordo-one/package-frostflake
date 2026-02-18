import Testing
import Frostflake

struct SharedGeneratorSuiteTrait: SuiteTrait, TestScoping {
    let isRecursive = false

    func provideScope(for test: Test, testCase: Test.Case?, performing function: @concurrent @Sendable () async throws -> Void) async throws {
        let frostflake = Frostflake(generatorIdentifier: 47)
        Frostflake.setup(sharedGenerator: frostflake)
        try await function()
    }
}

extension SuiteTrait where Self == SharedGeneratorSuiteTrait {
    static var sharedGenerator: Self {
        Self()
    }
}