import Foundation
import ComposableArchitecture
import CLI

import Storage
import EstatesProvider
import Notifications

// TODO: Save
struct PersistenceState: Hashable {
    public var slackUrl: URL?
    public var estates: [Estate]

    public init(estates: [Estate], slackUrl: URL?) {
        self.estates = estates
        self.slackUrl = slackUrl
    }
}

enum PersistenceAction {
    case loadEstatesFromStorage
    case loadedEstatesFromStorage([Estate])
    case failedToLoadEstatesFromStorage(Error)
    case writeEstatesToStorage
    case estatesWrittenToStorage
    case failedToWriteEstatesToStorage(Error)

    case notificationSent
    case failedToSendNotification(Error)
}

func persistenceReducer(state: inout PersistenceState, action: PersistenceAction) -> [Effect<PersistenceAction>] {
    switch action {
        case .loadEstatesFromStorage:
            return [
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
                sendNotification((title: "Failed to load estates from storage", content: error.localizedDescription), state.slackUrl!)
                    .map(success: PersistenceAction.notificationSent, error: PersistenceAction.failedToSendNotification)
            ]

        case .writeEstatesToStorage:
            return [
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
                sendNotification((title: "Failed to save estates to storage", content: error.localizedDescription), state.slackUrl!)
                    .map(success: PersistenceAction.notificationSent, error: PersistenceAction.failedToSendNotification)
            ]

    case .notificationSent:
        return []

    case .failedToSendNotification(_):
        return []
    }
}

struct AppState: Hashable {
    var estates: [Estate]
    var slackUrl: URL?
    var persistence: PersistenceState {
        get {
            PersistenceState(estates: self.estates, slackUrl: self.slackUrl)
        }
        set {
            self.estates = newValue.estates
        }
    }
    var cliInner = CLIState.Inner()
    var cli: CLIState {
        get {
            CLIState(
                shared: .init(slackUrl: self.slackUrl, estates: self.estates),
                inner: cliInner
            )
        }
        set {
            self.cliInner = newValue.inner
            self.estates = newValue.shared.estates
            self.slackUrl = newValue.shared.slackUrl
        }
    }
}

enum AppAction {
    case persistence(PersistenceAction)
    case cli(CLIAction)

    // MARK: -

    var persistence: PersistenceAction? {
      get {
        guard case let .persistence(value) = self else { return nil }
        return value
      }
      set {
        guard case .persistence = self, let newValue = newValue else { return }
        self = .persistence(newValue)
      }
    }

    var cli: CLIAction? {
      get {
        guard case let .cli(value) = self else { return nil }
        return value
      }
      set {
        guard case .cli = self, let newValue = newValue else { return }
        self = .cli(newValue)
      }
    }
}

let appReducer = combine(
    pullback(persistenceReducer, value: \AppState.persistence, action: \AppAction.persistence),
    pullback(cliReducer, value: \AppState.cli, action: \AppAction.cli)
)

var store = Store(initialValue: AppState(estates: []), reducer: logging(appReducer))

// Loads data from storage
store.send(.persistence(.loadEstatesFromStorage))

// MARK: - Start CLI

MainCLI.store = store.view(
    value: { $0.cli },
    action: { .cli($0) }
)
MainCLI.main()
