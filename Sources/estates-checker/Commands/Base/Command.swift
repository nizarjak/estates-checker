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
