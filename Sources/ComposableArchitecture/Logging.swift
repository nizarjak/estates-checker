public func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {

    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [Effect { _ in
            print("===")
            print("Action: \(action)")
            print("Value:")
            dump(newValue)
            }] + effects
    }
}
