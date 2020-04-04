//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 04. 04. 2020.
//

import Foundation

enum NetworkError: Swift.Error {
    case unknown
    case invalidStatusCode(code: Int, response: String)
    case noResponseData
    case responseIsNotString
    case withDescription(Error, description: String)
}


extension URLRequest {
    @discardableResult func download() throws -> Data {
        var result: Data!
        var taskError: Error?
        let sem = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: self) { data, response, error in
            defer { sem.signal() }
            do {
                if let error = error {
                    throw error
                }
                guard (response as! HTTPURLResponse).statusCode == 200 else {
                    taskError = NetworkError.invalidStatusCode(code: (response as! HTTPURLResponse).statusCode, response: data != nil ? (String(data: data!, encoding: .utf8) ?? "no response") : "no response")
                    return
                }
                guard let data = data else {
                    throw NetworkError.noResponseData
                }
                result = data
            } catch {
                taskError = error
            }
        }
        print("- start \(url!.absoluteString)")
        task.resume()
        sem.wait()
        if let error = taskError {
            print("- end with error \(url!.absoluteString)")
            throw error
        }
        print("- end \(url!.absoluteString)")
        return result
    }
}

extension Data {
    func string() throws -> String {
        guard let result = String(data: self, encoding: .utf8) else {
            throw NetworkError.responseIsNotString
        }
        return result
    }
    func decoded<ResultType: Decodable>() throws -> ResultType {
        do {
            return try JSONDecoder().decode(ResultType.self, from: self)
        } catch {
            throw NetworkError.withDescription(error, description: String(data: self, encoding: .utf8) ?? "Data is not valid String.")
        }
    }
}
