public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]
