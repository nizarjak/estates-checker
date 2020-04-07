import Foundation
import TSCUtility

var registry = CommandRegistry(usage: "<command> <options>", overview: "BettingTips")

registry.register(command: SrealityCommand.self)
registry.register(command: BezRealitkyCommand.self)
registry.register(command: TestingCommand.self)

registry.run()
