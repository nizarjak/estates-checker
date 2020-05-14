import Foundation
import ComposableArchitecture
import Storage
import EstatesProvider
import Notifications

public struct PersistenceState: Hashable {
    public var slackUrl: URL?
    public var estates: [Estate]

    public init(estates: [Estate], slackUrl: URL?) {
        self.estates = estates
        self.slackUrl = slackUrl
    }
}

public enum PersistenceAction {
    case loadEstatesFromStorage
    case loadedEstatesFromStorage([Estate])
    case failedToLoadEstatesFromStorage(Error)
    case writeEstatesToStorage
    case estatesWrittenToStorage
    case failedToWriteEstatesToStorage(Error)

    case notificationSent
    case failedToSendNotification(Error)
}

public func persistenceReducer(state: inout PersistenceState, action: PersistenceAction) -> [Effect<PersistenceAction>] {
    switch action {
        case .loadEstatesFromStorage:
            return [
                // TODO: Move to environment: loadEffect
                Storage.loadEffect()
                    .map { (result: Result<PersistentModel?, Error>) in
                        switch result {
                        case .success(let storageEstates): return PersistenceAction.loadedEstatesFromStorage(storageEstates?.estates ?? [])
                        case .failure(let error): return PersistenceAction.failedToLoadEstatesFromStorage(error)
                        }
                }
            ]

        case .loadedEstatesFromStorage(let estates):
            state.estates = estates
            return []

        case .failedToLoadEstatesFromStorage(let error):
            return [
                // TODO: Move to environment: sendNotification
                sendNotification((title: "Failed to load estates from storage", content: error.localizedDescription), state.slackUrl!)
                    .map(success: PersistenceAction.notificationSent, error: PersistenceAction.failedToSendNotification)
            ]

        case .writeEstatesToStorage:
            return [
                // TODO: Move to environment: saveEffect
                Storage.saveEffect(value: PersistentModel(estates: state.estates))
                    .map {
                        switch $0 {
                        case .success: return PersistenceAction.estatesWrittenToStorage
                        case .failure(let error): return PersistenceAction.failedToWriteEstatesToStorage(error)
                        }
                }
            ]

        case .estatesWrittenToStorage:
            return []

        case .failedToWriteEstatesToStorage(let error):
            return [
                // TODO: Move to environment: sendNotification
                sendNotification((title: "Failed to save estates to storage", content: error.localizedDescription), state.slackUrl!)
                    .map(success: PersistenceAction.notificationSent, error: PersistenceAction.failedToSendNotification)
            ]

    case .notificationSent:
        return []

    case .failedToSendNotification(_):
        return []
    }
}
