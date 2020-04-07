//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 05. 04. 2020.
//

import Foundation
import TSCUtility
import TSCBasic

struct BezRealitkyCommand: Command {

    let command = "bezrealitky"
    let overview = "Downloads BezRealitky estates in Stochov."

    let estatesStochovChannelUrl: PositionalArgument<String>


    init(parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        estatesStochovChannelUrl = subparser.add(positional: "Slack Webhook URL for #estates-stochov", kind: String.self, optional: false, usage: "estates-checker bezrealitky https://hooks.slack.com/services/…", completion: nil)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let slackUrlString = arguments.get(estatesStochovChannelUrl), let slackUrl = URL(string: slackUrlString) else {
            print("Missing or invalid `estatesStochovChannelUrl` argument")
            return
        }
        do {
            guard var store = PersistentStore() else {
                return
            }

            let estates = try BezRealitky.downloadEstates()
            let slackedEstates = store.model.estates.map { $0.url }
            let newEstates = estates.filter { !slackedEstates.contains($0.url) }
            try newEstates.forEach { try SlackMessage(title: $0.title, content: $0.url  + " @jancislinsky").send(to: slackUrl) }

            store.model.estates.append(contentsOf: newEstates)
            store.save()
        } catch {
            try? SlackMessage(title: "BezRealitky: Unknown Error", content: "\(error)").send(to: slackUrl)
            print("BezRealitky Error: \(error)")
        }
    }
}
