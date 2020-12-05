import Foundation
import ComposableArchitecture
import Networking
import CoreLocation

public struct BezRealitky: EstatesProvider {

    struct PropertyLocation {
        enum OfferType: String {
            case sell = "prodej"
        }

        enum EstateType: String {
            case land = "pozemek"
            case house = "dum"
            case flat = "byt"
        }

        let boundary: String
        let estateTypes: [EstateType]
        let offerType: OfferType = .sell
        let priceTo: String = "8 000 000"
        let surfaceFrom: String = "60"
    }

    private static let smichov: PropertyLocation = .init(
        boundary: #"[[[{"lat":50.076301275988186,"lng":14.41010798777208},{"lat":50.0696631874535,"lng":14.412253930740604},{"lat":50.06810513557534,"lng":14.398745043854944},{"lat":50.07122118871544,"lng":14.398252532354576},{"lat":50.07596262024708,"lng":14.398463608712262},{"lat":50.07770102767509,"lng":14.401172421967516},{"lat":50.0781525517601,"lng":14.4097210144499},{"lat":50.076301275988186,"lng":14.41010798777208}]]]"#,
        estateTypes: [.flat]
    )

    private static let vrsovice: PropertyLocation = .init(
        boundary: #"[[[{"lat":50.092223338460656,"lng":14.415323370970839},{"lat":50.088442292618254,"lng":14.412068837948311},{"lat":50.07704091599882,"lng":14.41118923442869},{"lat":50.05548719511907,"lng":14.415535400166078},{"lat":50.05460509257699,"lng":14.43670934038417},{"lat":50.06249155137536,"lng":14.454973884238143},{"lat":50.062561878723926,"lng":14.459662074924353},{"lat":50.066109424524115,"lng":14.468240693230456},{"lat":50.063198383430574,"lng":14.493328805262507},{"lat":50.061205912744384,"lng":14.51640281673383},{"lat":50.06414742797551,"lng":14.51851370022814},{"lat":50.06930290715724,"lng":14.513004809159014},{"lat":50.085378685705365,"lng":14.51692225971206},{"lat":50.084957178705565,"lng":14.494604056667129},{"lat":50.08063537219451,"lng":14.461409421220736},{"lat":50.082575823316546,"lng":14.45921019071443},{"lat":50.08239942191486,"lng":14.456048796861921},{"lat":50.08398701116141,"lng":14.453505936590716},{"lat":50.08526178811093,"lng":14.44044470787125},{"lat":50.086570026078476,"lng":14.437409100600718},{"lat":50.0878445349754,"lng":14.437649875061368},{"lat":50.089350729067604,"lng":14.45408273196739},{"lat":50.09552204448204,"lng":14.476043344948096},{"lat":50.10257265734745,"lng":14.460097976823334},{"lat":50.09945236935641,"lng":14.455693181373704},{"lat":50.092223338460656,"lng":14.415323370970839}]]]"#,
        estateTypes: [.flat]
    )

    static let regions: [String: [PropertyLocation]] = [
        "praha": [smichov, vrsovice]
    ]

    private static let sourceUrl = URL(string: "https://www.bezrealitky.cz/api/record/markers")!

    // MARK: - Start

    public static func exploreEffects(region: String) -> [Effect<Result<[Estate], Error>>] {

        return regions[region]!
            .map { propertyLocation in
                var request = URLRequest(url: sourceUrl)
                request.httpMethod = "POST"
                request.httpBody = RequestBody(propertyLocation: propertyLocation).encode()

                return dataTask(with: request)
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
            }
    }
}

// MARK: - Model

extension BezRealitky {

    struct RequestBody: WWWFormUrlEncodable {
        let propertyLocation: PropertyLocation
        var params: [String : String] {[
            "offerType": propertyLocation.offerType.rawValue,
            "estateType": propertyLocation.estateTypes.map { $0.rawValue }.joined(separator: ","),
            "boundary": propertyLocation.boundary,
            "surfaceFrom": propertyLocation.surfaceFrom,
            "priceTo": propertyLocation.priceTo
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

        var disposition: String { offer.keyDisposition.replacingOccurrences(of: "-", with: "+") }

        var title: String {
            switch offer.keyEstateType {
            case .byt:
                return "🏢 byt \(disposition) \(offer.surface) m², \(price)"
            case .dum:
                return "🏠 dům \(offer.surface) m², pozemek \(offer.surfaceLand.map { "\($0) m²" } ?? "🤷‍♂️") , \(price)"
            case .pozemek:
                return "🗺 pozemek \(offer.surfaceLand ?? offer.surface) m², \(price)"
            }
        }

        var price: String {
            "\(numberFormatter.string(for: offer.price)!) Kč"
        }

        var url: String { return "https://www.bezrealitky.cz/nemovitosti-byty-domy/\(uri)" }

        struct Offer: Decodable {
            let price: Int
            let surface: Int
            let surfaceLand: Int?
            let keyEstateType: EstateType
            let keyDisposition: String

            enum EstateType: String, Decodable {
                case dum, pozemek, byt
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
