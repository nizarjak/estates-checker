import Foundation

public protocol EstatesProvider {
    static var providerName: String { get }
    static var availableRegions: [String] { get }
    static func isRegionNameValid(_ region: String) -> Bool
}
