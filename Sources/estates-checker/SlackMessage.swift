//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 04. 04. 2020.
//

import Foundation

struct SlackMessage {
    let title: String?
    let content: String
}

extension SlackMessage {
    func send(to channel: URL) throws {
        var request = URLRequest(url: channel)
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
