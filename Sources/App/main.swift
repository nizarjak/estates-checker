import Foundation
import ComposableArchitecture
import CLI
import EstatesProvider
import Persistence

var store = Store(initialValue: AppState(estates: []), reducer: logging(appReducer))

// Loads data from storage
store.send(.persistence(.loadEstatesFromStorage))

// Writes data to storage on change
store.addValueObserver(\AppState.estates) { estates in
    store.send(.persistence(.writeEstatesToStorage))
}

// MARK: - Start CLI

MainCLI.store = store.scope(
    value: { $0.cli },
    action: { .cli($0) }
)
MainCLI.main()
