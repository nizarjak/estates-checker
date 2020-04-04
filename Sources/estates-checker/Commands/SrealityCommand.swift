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


    init(parser: ArgumentParser) {
        parser.add(subparser: command, overview: overview)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        do {
            guard var store = PersistentStore() else {
                return
            }

            let estates = try Sreality.downloadEstates()
            let slackedEstates = store.model.estates.map { $0.url }
            let newEstates = estates.filter { !slackedEstates.contains($0.url) }
            try newEstates.forEach { try SlackMessage(title: $0.title, content: $0.url).send() }

            store.model.estates.append(contentsOf: newEstates)
            store.save()
        } catch {
//            try! SlackMessage(title: "Sreality: Unknown Error", content: "\(error)").send()
            print("Sreality Error: \(error)")
        }
    }
}
