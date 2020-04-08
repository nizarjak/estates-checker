//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 12. 12. 2019.
//

import Foundation
import TSCUtility
import TSCBasic

struct SrealityCommand: Command {

    let command = "sreality"
    let overview = "Downloads Sreality estates in Stochov."

    let estatesStochovChannelUrl: PositionalArgument<String>


    init(parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        estatesStochovChannelUrl = subparser.add(positional: "Slack Webhook URL for #estates-stochov", kind: String.self, optional: false, usage: "estates-checker sreality https://hooks.slack.com/services/…", completion: nil)
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

            let estates = try Sreality.downloadEstates()
            let slackedEstates = store.model.estates.map { $0.url }
            let newEstates = estates.filter { !slackedEstates.contains($0.url) }
            try newEstates.forEach { try SlackMessage(title: $0.title, content: $0.url  + " <@URGFS9DT9>").send(to: slackUrl) }

            store.model.estates.append(contentsOf: newEstates)
            store.save()
        } catch {
            try? SlackMessage(title: "Sreality: Unknown Error", content: "\(error)").send(to: slackUrl)
            print("Sreality Error: \(error)")
        }
    }
}
