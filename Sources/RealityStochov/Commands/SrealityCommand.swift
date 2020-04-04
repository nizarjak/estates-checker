//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 12. 12. 2019.
//

import Foundation
import TSCUtility
import TSCBasic
import SwiftSoup

struct SrealityCommand: Command {

    let command = "Sreality"
    let overview = "Downloads Sreality estates in Stochov."


    init(parser: ArgumentParser) {
        parser.add(subparser: command, overview: overview)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        do {
            guard var store = PersistentStore() else {
                return
            }

            // TODO:

            store.save()
        } catch {
            try! SlackMessage(title: "Sreality: Unknown Error", content: "\(error)").send(to: .estatesStochov)
            print("Sreality Error: \(error)")
        }
    }
}
