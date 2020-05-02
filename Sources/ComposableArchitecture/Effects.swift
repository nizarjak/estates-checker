import Foundation

public enum NetworkValidationError: Swift.Error {
    case invalidStatusCode(code: Int, response: String)
    case noResponseData
    case other(Error)
    case responseIsNotString
}

extension Effect where A == (Data?, URLResponse?, Error?) {
    public func validate() -> Effect<Result<Data, Error>> {
        self.map { data, response, error in
            Result {
                if let error = error {
                    throw NetworkValidationError.other(error)
                }
                guard (response as! HTTPURLResponse).statusCode == 200 else {
                    throw NetworkValidationError.invalidStatusCode(code: (response as! HTTPURLResponse).statusCode, response: data != nil ? (String(data: data!, encoding: .utf8) ?? "no response") : "no response")
                }
                guard let data = data, data.count > 0 else {
                    throw NetworkValidationError.noResponseData
                }
                return data
            }
        }
    }
}

extension Effect where A == (Result<Data, Error>) {
    public func decode<M: Decodable>(as type: M.Type) -> Effect<Result<M, Error>> {
        self.map { result in
            Result {
                let data = try result.get()
                return try JSONDecoder().decode(M.self, from: data)
            }
        }
    }

    public func decodeAsString() -> Effect<Result<String, Error>> {
        self.map { result in
            Result {
                guard let result = String(data: try result.get(), encoding: .utf8) else {
                    throw NetworkValidationError.responseIsNotString
                }
                return result
            }
        }
    }

    public func ignoreValue() -> Effect<Result<Void, Error>> {
        self.map { result in
            switch result {
            case .success: return Result.success(())
            case .failure(let error): return Result.failure(error)
            }
        }
    }
}

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

public func dataTask(with url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
    return dataTask(with: URLRequest(url: url))
}

public func dataTask(with request: URLRequest) -> Effect<(Data?, URLResponse?, Error?)> {
    return Effect { callback in
        let url = request.url!.absoluteString
        print(">>>>\n+ start data task \(url)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("– data task ended \(url)\n<<<<")
            callback((data, response, error))
        }
        .resume()
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
