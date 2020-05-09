import Foundation
import ComposableArchitecture
import Networking

public struct BezRealitky: EstatesProvider {
    public typealias Region = (latMin: String, latMax: String, lngMin: String, lngMax: String)

    static let regions: [String: Region] = [
        "Stochov": ("50.134962", "50.154911", "13.946335", "13.979680"),
        "Kladno": ("50", "51", "14", "15")
    ]

    private static let sourceUrl = URL(string: "https://www.bezrealitky.cz/api/record/markers")!

    // MARK: - Start

    public static func exploreEffects(region: String) -> [Effect<Result<[Estate], Error>>] {
        var request = URLRequest(url: sourceUrl)
        request.httpMethod = "POST"
        request.httpBody = RequestBody(region: Self.regions[region]!).encode()
        return [dataTask(with: request)
            .sync()
            .validate()
            .decode(as: [BezRealitkyEstate].self)
            .map { result in
                switch result {
                case .success(let response):
                    let estates = response.map { Estate(title: $0.title, url: $0.url) }
                    return .success(estates)
                case .failure(let error): return .failure(error)
                }
            }
        ]
    }
}

// MARK: - Model

extension BezRealitky {

    struct RequestBody: WWWFormUrlEncodable {
        let region: Region
        var params: [String : String] {[
            "offerType": "prodej",
            "estateType": "pozemek,dum",
            "boundary": "[[[{\"lat\":\(region.latMax),\"lng\":\(region.lngMin)},{\"lat\":\(region.latMax),\"lng\":\(region.lngMax)},{\"lat\":\(region.latMin),\"lng\":\(region.lngMax)},{\"lat\":\(region.latMin),\"lng\":\(region.lngMin)},{\"lat\":\(region.latMax),\"lng\":\(region.lngMax)}]]]"
        ]}
    }

    static private let numberFormatter: NumberFormatter = {
        let rVal = NumberFormatter()
        rVal.groupingSeparator = " "
        rVal.numberStyle = .decimal
        return rVal
    }()

    struct BezRealitkyEstate: Decodable {
        let id: String
        let uri: String
        let advertEstateOffer: [Offer]
        var offer: Offer { advertEstateOffer[0] }

        var title: String { return offer.keyEstateType.emoji + " \(offer.keyEstateType == .dum ? "dům \(numberFormatter.string(for: offer.surface)!) m², pozemek \(numberFormatter.string(for: offer.surfaceLand ?? 0)!) m²" : "pozemek \(numberFormatter.string(for: offer.surface)!) m²"), \(numberFormatter.string(for: offer.price)!) Kč" }
        var url: String { return "https://www.bezrealitky.cz/nemovitosti-byty-domy/\(uri)" }

        struct Offer: Decodable {
            let price: Int
            let surface: Int
            let surfaceLand: Int?
            let keyEstateType: EstateType

            enum EstateType: String, Decodable {
                case dum, pozemek

                var emoji: String {
                    switch self {
                    case .dum: return "🏠"
                        case .pozemek: return "🗺"
                    }
                }
            }
        }
    }
}

// MARK: - EstatesProvider

extension EstatesProvider where Self == BezRealitky {
    public static var providerName: String { "bezrealitky" }

    public static var availableRegions: [String] {
        Array(Self.regions.keys)
    }

    public static func isRegionNameValid(_ region: String) -> Bool {
        Self.regions.keys.contains(region)
    }
}
