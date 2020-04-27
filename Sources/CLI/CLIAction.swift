import Foundation

public enum CLIAction {
    case receivedSlackUrl(URL)
    case validate(provider: String, region: String)
    case explore(provider: String, region: String)
}
