//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 04. 04. 2020.
//

import Foundation

enum SlackChannel: String {
    case estatesStochov = "https://hooks.slack.com/services/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"
}

struct SlackMessage {
    let title: String?
    let content: String
}

extension SlackMessage {
    func send(to channel: SlackChannel = .estatesStochov) throws {
        var request = URLRequest(url: URL(string: channel.rawValue)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = Body(text: "\(title != nil ? "*" + title! + "*\n" : "")\(content)")
        request.httpBody = try JSONEncoder().encode(body)
        try request.download()
    }

    private struct Body: Encodable {
        let text: String
    }
}
