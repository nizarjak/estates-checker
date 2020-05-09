import Foundation

public protocol WWWFormUrlEncodable {
    var params: [String: String] { get }
    func encode() -> Data
}

public extension WWWFormUrlEncodable {
    func encode() -> Data {
        return params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)!
    }
}
