//
//  Command.swift
//  Build
//
//  Created by Jan Cislinsky (admin) on 30. 11. 2019.
//

import Foundation
import TSCUtility

protocol Command {
    var command: String { get }
    var overview: String { get }

    init(parser: ArgumentParser)
    func run(with arguments: ArgumentParser.Result) throws
}

extension Command {
    /// Saves given tips to PersistentStore
    func save(tips: [FinalTip], to model: inout PersistentModel, for account: Account) {
        if model.accounts[account] == nil {
            model.accounts[account] = PersistentModel.Data(recommendedTips: .init(), balances: .init())
        }
        tips.forEach { tip in
            var savedTips = model.accounts[account]?.recommendedTips[tip.provider] ?? []
            savedTips.append(tip.prediction.name)
            model.accounts[account]?.recommendedTips[tip.provider] = savedTips
        }
    }
}
