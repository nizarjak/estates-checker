import Foundation

public struct NotificationState: Hashable {
    var slackUrl: URL?
    var error: Error?
}

extension NotificationState {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(slackUrl)
        hasher.combine(error?.localizedDescription)
    }

    public static func == (lhs: NotificationState, rhs: NotificationState) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
