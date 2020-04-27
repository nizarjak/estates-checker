import Foundation
import ComposableArchitecture

public func notificationsReducer(state: inout NotificationState, action: NotificationsAction) -> [Effect<NotificationsAction>] {
    switch action {
    case .didSendNotification:
        return []

    case .failedToSendNotification(let error):
        state.error = error
        return []
    }
}

public func sendNotificationEffect(_ message: (title: String?, content: String), _ channel: URL) -> Effect<NotificationsAction> {
    var request = URLRequest(url: channel)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body = SlackMessageBody(with: message)
    request.httpBody = try! JSONEncoder().encode(body)

    return dataTask(with: request)
        .sync()
        .validate()
        .map { result -> NotificationsAction in
            switch result {
            case .success: return .didSendNotification
            case .failure(let e): return .failedToSendNotification(e)
        }
    }
}

// MARK: - Helpers

private struct SlackMessageBody: Encodable {
    let text: String

    init(with message: (title: String?, content: String)) {
        self.text = "\(message.title != nil ? "*" + message.title! + "*\n" : "")\(message.content)"
    }
}
