import Foundation
import TSCUtility

var registry = CommandRegistry(usage: "<command> <options>", overview: "BettingTips")

registry.register(command: SrealityCommand.self)

registry.run()
