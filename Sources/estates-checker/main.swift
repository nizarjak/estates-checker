import Foundation
import ComposableArchitecture
import CLI

//enum AppAction {
//    case insertedSlackUrl(Foundation.URL)
//    case explore([AppState.Provider])
//    case test([AppState.Provider])
//    case loadModel
//    case loadedModel(PersistentModel)
//    case loadEstates
//    case loadedEstates([Estate])
//    case reportError(Error?)
//    case saveNewEstates([Estate])
//    case sendNotification(title: String, content: String)
//}
//
//struct AppState: Hashable {
//    enum Provider: Hashable {
//        case sreality(Sreality.Region)
//        case bezRealitky(BezRealitky.Region)
//    }
//
//    var model: PersistentModel?
//    var slackUrl: Foundation.URL?
//    var provider: Provider?
//}
//
//extension AppState {
//    static func == (lhs: AppState, rhs: AppState) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
//}
//
//extension AppState.Provider {
//    static func == (lhs: AppState.Provider, rhs: AppState.Provider) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
//}
//
//func appReducer(state: inout AppState, action: AppAction) -> [Effect<AppAction>] {
//    switch action {
//    case .insertedSlackUrl(let value):
//        state.slackUrl = value
//        return []
//
//    case .sreality:
//        state.provider = .sreality
//        return [Effect { $0(.loadModel) }]
//
//    case .loadModel:
//        return [Effect { callback in
//            guard let model = PersistentStore()?.model else { fatalError() }
//            callback(AppAction.loadedModel(model))
//        }]
//
//    case .loadedModel(let model):
//        state.model = model
//        return [Effect { $0(.loadEstates) } ]
//
//    case .loadEstates:
//        return [Effect { callback in
//            do {
//                callback(.loadedEstates(try Sreality.downloadEstates()))
//            } catch {
//                callback(.reportError(error))
//            }
//        }]
//
//    case .loadedEstates(let estates):
//        guard let model = state.model else { fatalError() }
//        let oldEstates = model.estates.map { $0.url }
//        let newEstates = estates.filter { !oldEstates.contains($0.url) }
//        return newEstates.map { estate in
//            Effect { callback in callback(AppAction.sendNotification(title: estate.title, content: estate.url)) }
//        }
//        + [Effect { callback in
//            callback(AppAction.saveNewEstates(newEstates))
//        }]
//
//    case .reportError(let error):
//        return [Effect { callback in
//            callback(.sendNotification(title: "Unknown Error", content: "\(String(describing: error))"))
//        }]
//
//    case let .sendNotification(title, content):
//        guard let slackUrl = state.slackUrl else { fatalError() }
//        return [Effect { callback in
//            do {
//                try SlackMessage(title: title, content: content).send(to: slackUrl)
//            } catch {
//                print("Failed to send Slack message, error: \(error)")
//            }
//        }]
//
//    case .saveNewEstates(let newEstates):
//        guard var model = state.model else { fatalError() }
//        model.estates += newEstates
//        var store = PersistentStore()
//        store?.model = model
//        store?.save()
//        return []
//    }
//}
//
//var store = Store(initialValue: AppState(model: nil), reducer: appReducer)

var store = Store(initialValue: CLIState(), reducer: cliReducer)
//store.addValueObserver { state in
//    dump(state)
//    print("===")
//}

// MARK: - Start CLI

MainCLI.store = store
MainCLI.main()
