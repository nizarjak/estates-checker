import Foundation

public struct Estate: Codable, Hashable {
    let title: String
    let url: String

    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}
