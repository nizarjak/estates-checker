import Foundation
import ComposableArchitecture
import Networking

public func sendNotification(_ message: (title: String?, content: String), _ channel: URL) -> Effect<Result<Void, Error>> {
    do {
        var request = URLRequest(url: channel)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = SlackMessageBody(with: message)
        request.httpBody = try JSONEncoder().encode(body)

        return dataTask(with: request)
            .sync()
            .validate()
            .ignoreValue()
    } catch {
        return Effect(value: .failure(error))
    }
}

// MARK: - Helpers

private struct SlackMessageBody: Encodable {
    let text: String

    init(with message: (title: String?, content: String)) {
        self.text = "\(message.title != nil ? "*" + message.title! + "*\n" : "")\(message.content)"
    }
}
