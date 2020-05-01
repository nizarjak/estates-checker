public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void

    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }

    public init(value: A) {
        self.run = { callback in
            callback(value)
        }
    }

    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in
            self.run { a in
                callback(f(a))
            }
        }
    }
}
