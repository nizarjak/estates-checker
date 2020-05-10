import Foundation

public final class Store<Value: Hashable, Action> {
    private let reducer: Reducer<Value, Action>
    public private(set) var value: Value {
        didSet {
            valueDidSetObservers.forEach { $0(oldValue, value) }
        }
    }
    @Atomic private var valueDidSetObservers: [(_ old: Value, _ new: Value) -> Void] = []

    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.reducer = reducer
        self.value = initialValue
    }

    public func addValueObserver<LocalValue: Hashable>(
        _ value: WritableKeyPath<Value, LocalValue>,
        observer: @escaping (LocalValue) -> Void
    ) {
        $valueDidSetObservers.mutate {
            $0.append { old, new in
                guard old[keyPath: value].hashValue != new[keyPath: value].hashValue else { return } // skip repeats
                observer(new[keyPath: value])
            }
        }
    }

    public func send(_ action: Action) {
        let effects = self.reducer(&self.value, action)
        effects.forEach { effect in
            effect.run(self.send)
        }
    }

    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {

        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            }
        )
        $valueDidSetObservers.mutate { observers in
            observers.append { [weak localStore] _, new in
                localStore?.value = toLocalValue(new)
            }
        }
        return localStore
    }
}
