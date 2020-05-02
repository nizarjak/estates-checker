import Foundation
import ComposableArchitecture

public let allEstatesProviders: [EstatesProvider.Type] = [Sreality.self, BezRealitky.self]

public protocol EstatesProvider {
    static var providerName: String { get }
    static var availableRegions: [String] { get }
    static func isRegionNameValid(_ region: String) -> Bool

    static func exploreEffects(region: String) -> [Effect<Result<[Estate], Error>>]
}
