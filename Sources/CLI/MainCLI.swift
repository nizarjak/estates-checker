import Foundation
import ArgumentParser
import ComposableArchitecture

public struct MainCLI: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "EstatesChecker",
        abstract: "A Swift command-line tool to monitor available estates for buy.",
        subcommands: []
    )

    public static var store: Store<CLIState, CLIAction>!

    // MARK: - CLI

    @Option(
        name: .shortAndLong,
        help: "The Slack channel's URL used for notifications."
    )
    private var slackUrl: String

    @Option(
        name: .shortAndLong,
        help: "The name of the provider."
    )
    private var provider: String

    @Option(
        name: .shortAndLong,
        help: "The name of the region."
    )
    private var region: String

    // MARK: - Initialization

    public init() {}

    // MARK: - Validation

    public func validate() throws {
        guard URL(string: slackUrl) != nil else {
            throw CLIError.invalidSlackUrl
        }
        Self.store.send(.validate(provider: provider, region: region))
        if let error = Self.store.value.inner.validationError {
            throw error
        }
    }

    // MARK: - Run

    public func run() throws {
        Self.store.send(.receivedSlackUrl(URL(string: slackUrl)!))
        Self.store.send(.explore(provider: provider, region: region))
        Self.store.send(.finishedRun)
        print("################## End of program ##################")
    }
}

