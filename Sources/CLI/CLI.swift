import Foundation
import ComposableArchitecture
import EstatesProvider
import Notifications
import Storage

public struct CLIState: Hashable {
    var slackUrl: URL?
    var validationError: MainCLI.Error?
    var estates: [Estate] = []

    public init() {}

    public static func == (lhs: CLIState, rhs: CLIState) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

public enum CLIAction {
    case loadEstatesFromStorage
    case loadedEstatesFromStorage([Estate])
    case failedToLoadEstatesFromStorage(Error)
    case writeEstatesToStorage
    case estatesWrittenToStorage
    case failedToWriteEstatesToStorage(Error)

    case receivedSlackUrl(URL)
    case validate(provider: String, region: String)
    case explore(provider: String, region: String)
    case receivedEstates([Estate])
    case exploreFailed(provider: String, region: String, error: Error)

    case notifyAboutNewEstates([Estate])
    case failedToSendNotification(Error)
    case notificationSent
}

public func cliReducer(state: inout CLIState, action: CLIAction) -> [Effect<CLIAction>] {
    switch action {
    case .loadEstatesFromStorage:
        return [
            Storage.loadEffect()
                .map { (result: Result<PersistentModel?, Error>) in
                    switch result {
                    case .success(let storageEstates): return CLIAction.loadedEstatesFromStorage(storageEstates?.estates ?? [])
                    case .failure(let error): return CLIAction.failedToLoadEstatesFromStorage(error)
                    }
            }
        ]

    case .loadedEstatesFromStorage(let estates):
        state.estates = estates
        return []

    case .failedToLoadEstatesFromStorage(let error):
        return [
            sendNotification((title: "Failed to load estates from storage", content: error.localizedDescription), state.slackUrl!)
                .map(success: CLIAction.notificationSent, error: CLIAction.failedToSendNotification)
        ]

    case .writeEstatesToStorage:
        return [
            Storage.saveEffect(value: PersistentModel(estates: state.estates))
                .map {
                    switch $0 {
                    case .success: return CLIAction.estatesWrittenToStorage
                    case .failure(let error): return CLIAction.failedToWriteEstatesToStorage(error)
                    }
            }
        ]

    case .estatesWrittenToStorage:
        return []

    case .failedToWriteEstatesToStorage(let error):
        return [
            sendNotification((title: "Failed to save estates to storage", content: error.localizedDescription), state.slackUrl!)
                .map(success: CLIAction.notificationSent, error: CLIAction.failedToSendNotification)
        ]

    case .receivedSlackUrl(let url):
        state.slackUrl = url
        return []

    case let .validate(providerName, regionName):
        guard let provider = allEstatesProviders.first(where: { $0.providerName == providerName }) else {
            state.validationError = .invalidProvider(availableProviders: allEstatesProviders.map { $0.providerName })
            return []
        }
        guard provider.isRegionNameValid(regionName) else {
            state.validationError = .invalidRegion(availableRegions: provider.availableRegions)
            return []
        }
        return []

    case let .explore(provider, region):
        return allEstatesProviders
            .first { $0.providerName == provider }!
            .exploreEffects(region: region).map { effect in
                effect.map { result -> CLIAction in
                    switch result {
                    case .success(let estates): return .receivedEstates(estates)
                    case .failure(let error): return .exploreFailed(provider: provider, region: region, error: error)
                    }
                }
            }

    case .receivedEstates(let estates):
        let oldEstates = Set(state.estates)
        let allEstates = Set(state.estates + estates)
        state.estates = Array(allEstates)
        let newUniqEstates = allEstates.subtracting(oldEstates)
        return [Effect(value: .notifyAboutNewEstates(Array(newUniqEstates)))]

    case .exploreFailed(provider: let provider, region: let region, error: let error):
        return [
            sendNotification((title: "Failed to explore \(provider) for \(region)", content: error.localizedDescription), state.slackUrl!)
                .map(success: CLIAction.notificationSent, error: CLIAction.failedToSendNotification)

        ]

    case .notifyAboutNewEstates(let estates):
        return estates.map {
            sendNotification((title: "test" + $0.title, content: $0.url), state.slackUrl!)
                .map(success: CLIAction.notificationSent, error: CLIAction.failedToSendNotification)
        }

    case .failedToSendNotification:
        return []

    case .notificationSent:
        return []
    }
}
