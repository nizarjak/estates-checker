public struct Reducer<Value, Action, Environment> {
    let reducer: (inout Value, Action, Environment) -> [Effect<Action>]

    public init(_ reducer: @escaping (inout Value, Action, Environment) -> [Effect<Action>]) {
        self.reducer = reducer
    }
}

extension Reducer {
  public func callAsFunction(_ value: inout Value, _ action: Action, _ environment: Environment) -> [Effect<Action>] {
    self.reducer(&value, action, environment)
  }
}

extension Reducer {
    public static func combine(_ reducers: Reducer...) -> Reducer {
        .init { value, action, environment in
            let effects = reducers.flatMap { $0.reducer(&value, action, environment) }
            return effects
        }
    }
}

extension Reducer {
    public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
        _ reducer: Reducer<LocalValue, LocalAction, Environment>,
        value: WritableKeyPath<GlobalValue, LocalValue>,
        action: WritableKeyPath<GlobalAction, LocalAction?>
    ) -> Reducer<GlobalValue, GlobalAction, Environment> {
        .init { globalValue, globalAction, environment in
            guard let localAction = globalAction[keyPath: action] else { return [] }
            let localEffects = reducer(&globalValue[keyPath: value], localAction, environment)

            return localEffects.map { localEffect in
                Effect { callback in
                    localEffect.run { localAction in
                        var globalAction = globalAction
                        globalAction[keyPath: action] = localAction
                        callback(globalAction)
                    }
                }
            }
        }
    }
}

extension Reducer {
    public func logging(
        printer: @escaping (Environment) -> (String) -> Void = { _ in { print($0) } }
    ) -> Reducer {
        .init { value, action, environment in
            let effects = self.reducer(&value, action, environment)
            let newValue = value
            let print = printer(environment)
            return [.fireAndForget {
                print("Action: \(action)")
                print("Value:")
                var dumpedNewValue = ""
                dump(newValue, to: &dumpedNewValue)
                print(dumpedNewValue)
                print("---")
                }] + effects
        }
    }
}
