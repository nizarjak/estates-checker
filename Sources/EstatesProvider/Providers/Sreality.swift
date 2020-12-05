import Foundation
import ComposableArchitecture
import Networking

public struct Sreality: EstatesProvider {

    static let vrsovice = "14968"
    static let vinohrady = "14967"
    static let nusle = "14960"
    static let vysehrad = "8723"
    static let podoli = "13677"
    static let noveMesto = "14959"
    static let karlin = "13707"
    static let smichov = "13687"
    static let strasnice = "14963"

    fileprivate static let regions: [String: [String]] = [
        "praha": [vrsovice, vinohrady, nusle, vysehrad, podoli, noveMesto, karlin, smichov, strasnice]
    ]

    static func flatUrl(with regionId: String) -> URL {
        return URL(string: "https://www.sreality.cz/api/cs/v2/estates?building_type_search=2%7C3&category_main_cb=1&category_type_cb=1&czk_price_summary_order2=0%7C8000000&locality_region_id=10&per_page=100&region_entity_id=\(regionId)&region_entity_type=ward&usable_area=50%7C10000000000")!
    }

    public static func exploreEffects(region: String) -> [Effect<Result<[Estate], Error>>] {
        let makeEffect: (URL, String) -> Effect<Result<[Estate], Error>> = { url, emoji in
            dataTask(with: url)
                .sync()
                .validate()
                .decode(as: Sreality.Response.self)
                .map { result in
                    switch result {
                    case .success(let response):
                        let estates = response._embedded.estates
                            .filter { $0.region_tip == 0 }
                            .map { Estate(title: $0.title, url: $0.url ?? "Unknown url") }
                        return .success(estates)
                    case .failure(let error):
                        return .failure(error)
                    }
                }
        }

        return regions[region]?.map { regionId in
            makeEffect(Sreality.flatUrl(with: regionId), "🏢")
        } ?? []
    }
}

// MARK: - Model

extension Sreality {

    struct Response: Decodable {
        let _embedded: Embedded

        struct Embedded: Decodable {
            let estates: [SrealityEstate]

            struct SrealityEstate: Decodable {
                let hash_id: Int
                let name: String
                let region_tip: Int
                let price: Int
                let seo: Seo

                var formattedPrice: String {
                    "\(numberFormatter.string(for: price)!) Kč"
                }

                var locality: String { seo.locality }
                var title: String {
                    "🏢 byt \(disposition ?? "") \(surface), \(formattedPrice)"
                }
                var disposition: String? {
                    name.matches(for: #"([1-9]\+(?:kk|1))"#).first
                }
                var surface: String {
                    name.matches(for: #"[1-9][0-9]+ m²"#).first ?? ""
                }

                var url: String? {
                    guard let disposition = disposition else { return nil }
                    return "https://www.sreality.cz/detail/prodej/byt/\(disposition)/\(locality)/\(hash_id)" } 

                struct Seo: Decodable {
                    let locality: String
                }
            }
        }
    }
}

// MARK: - EstatesProvider

extension EstatesProvider where Self == Sreality {
    public static var providerName: String { "sreality" }
    
    public static var availableRegions: [String] {
        Array(Self.regions.keys)
    }

    public static func isRegionNameValid(_ region: String) -> Bool {
        Self.regions.keys.contains(region)
    }
}
