import Foundation
import EstatesProvider

public struct PersistentModel: Codable {
    public let estates: [Estate]

    public init(estates: [Estate]) {
        self.estates = estates
    }
}
