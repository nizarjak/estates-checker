//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 07. 04. 2020.
//

import Foundation
import TSCUtility
import TSCBasic

struct TestingCommand: Command {

    let command = "test"
    let overview = "Downloads Sreality and BezRealitky estates in Kladno as functional test of crawlers."

    let estatesStochovChannelUrl: PositionalArgument<String>


    init(parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        estatesStochovChannelUrl = subparser.add(positional: "Slack Webhook URL for #estates-stochov", kind: String.self, optional: false, usage: "estates-checker test https://hooks.slack.com/services/…", completion: nil)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let slackUrlString = arguments.get(estatesStochovChannelUrl), let slackUrl = URL(string: slackUrlString) else {
            print("Missing or invalid `estatesStochovChannelUrl` argument")
            return
        }
        do {
            let bezRealitkyEstates = try BezRealitky.downloadEstates(region: BezRealitky.kladnoRegion)
            let srealityEstates = try Sreality.downloadEstates(regionId: Sreality.kladnoRegionId)
            try SlackMessage(title: "🔧 Ověření funčnosti", content: "Nalezeno \(bezRealitkyEstates.count) výsledků na BezRealitky v oblasti Kladno.\nNalezeno \(srealityEstates.count) výsledků na Sreality v oblasti Kladno.").send(to: slackUrl)
        } catch {
            try? SlackMessage(title: "BezRealitky: Unknown Error", content: "\(error)").send(to: slackUrl)
            print("BezRealitky Error: \(error)")
        }
    }
}
