import Foundation
import EstatesProvider

public struct BezRealitky: EstatesProvider {
    public typealias Region = (latMin: String, latMax: String, lngMin: String, lngMax: String)

    static let regions: [String: Region] = [
        "Stochov": ("50.134962", "50.154911", "13.946335", "13.979680"),
        "Kladno": ("50", "51", "14", "15")
    ]

    private static var region: Region!
    private static let sourceUrl = URL(string: "https://www.bezrealitky.cz/api/record/markers")!

    // MARK: - Start

    static func downloadEstates(region: Region) throws -> [Estate] {
        Self.region = region
        fatalError()
//        return try parse(downloadPozemkyAndDomy()).map { Estate(title: $0.title, url: $0.url) }
    }

    // MARK: -

//    private static func downloadPozemkyAndDomy() throws -> Data {
//        var request = URLRequest(url: sourceUrl)
//        request.httpMethod = "POST"
//        request.httpBody = RequestBody().encode()
//        return try request.download()
//    }
//
//    private static func parse(_ jsonData: Data) throws -> [BezRealitkyEstate] {
//        try JSONDecoder().decode([BezRealitkyEstate].self, from: jsonData)
//    }

    // MARK: - Model

//    struct RequestBody: WWWFormUrlEncodable {
//        var params: [String : String] = [
//            "offerType": "prodej",
//            "estateType": "pozemek,dum",
//            "boundary": "[[{\"lat\":\(region.latMax),\"lng\":\(region.lngMin)},{\"lat\":\(region.latMax),\"lng\":\(region.lngMax)},{\"lat\":\(region.latMin),\"lng\":\(region.lngMax)},{\"lat\":\(region.latMin),\"lng\":\(region.lngMin)},{\"lat\":\(region.latMax),\"lng\":\(region.lngMax)}]]"
//        ]
//    }

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
