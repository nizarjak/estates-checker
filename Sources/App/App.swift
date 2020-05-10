import Foundation
import ComposableArchitecture
import CLI
import EstatesProvider
import Persistence

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
