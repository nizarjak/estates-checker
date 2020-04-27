import Foundation

public struct CLIState: Hashable {
    var slackUrl: URL?
    var validationError: MainCLI.Error?

    public init() {}
    
    public static func == (lhs: CLIState, rhs: CLIState) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
