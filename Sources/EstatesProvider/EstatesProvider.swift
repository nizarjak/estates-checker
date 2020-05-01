import Foundation
import ComposableArchitecture
public protocol EstatesProvider {
    static var providerName: String { get }
    static var availableRegions: [String] { get }
    static func isRegionNameValid(_ region: String) -> Bool

    static func exploreEffects(region: String) -> [Effect<Result<[Estate], Error>>]
}
