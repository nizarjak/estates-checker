import Foundation
import ComposableArchitecture
import EstatesProvider
import Sreality
import BezRealitky
import Notifications

public func cliReducer(state: inout CLIState, action: CLIAction) -> [Effect<CLIAction>] {
    switch action {
    case .receivedSlackUrl(let url):
        state.slackUrl = url
        return []

    case let .validate(providerName, regionName):
        let providers: [EstatesProvider.Type] = [Sreality.self, BezRealitky.self]
        guard let provider = providers.first(where: { $0.providerName == providerName }) else {
            state.validationError = .invalidProvider(availableProviders: providers.map { $0.providerName })
            return []
        }
        guard provider.isRegionNameValid(regionName) else {
            state.validationError = .invalidRegion(availableRegions: provider.availableRegions)
            return []
        }
        return []

    case let .explore(provider, region):
        // TODO: 
        fatalError()
    }
}
