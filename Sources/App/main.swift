import Foundation
import ComposableArchitecture
import CLI
import EstatesProvider
import Notifications
import Storage

enum AppAction {
    case cli(CLIAction)

    // MARK: -

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

struct AppState: Hashable {
    var cli = CLIState()
}

//func notifications<Value>(
//    _ reducer: @escaping Reducer<Value, AppAction>
//) -> Reducer<Value, AppAction> {
//
//    return { value, action in
//        let effects = reducer(&value, action)
//        return [Effect { _ in
//            switch action {
//            case .cli(.receivedEstates(let estates)):
//                print(estates.map({ $0.title }).joined(separator: "\n"))
//            default: break
//            }
//        }] + effects
//    }
//}

let appReducer = combine(
    pullback(cliReducer, value: \AppState.cli, action: \AppAction.cli)
)

var store = Store(initialValue: AppState(), reducer: logging(appReducer))

// MARK: - Start CLI

MainCLI.store = store.view(
    value: { $0.cli },
    action: { .cli($0) }
)
MainCLI.main()
