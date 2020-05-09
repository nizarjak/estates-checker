import Foundation

extension Effect where A == Result<Void, Error> {
    public func map<Action>(success: Action, error: @escaping (Error) -> Action) -> Effect<Action> {
        self.map { result in
            switch result {
            case .success: return success
            case .failure(let err): return error(err)
            }
        }
    }
}

extension Effect {
    public func receive(on queue: DispatchQueue) -> Effect {
        return Effect { callback in
            self.run { a in
                queue.async {
                    callback(a)
                }
            }
        }
    }

    public func sync() -> Effect {
        return Effect { callback in
            let sema = DispatchSemaphore(value: 0)
            var result: A!
            self.run { a in
                result = a
                sema.signal()
            }
            sema.wait()
            callback(result)
        }
    }
}
