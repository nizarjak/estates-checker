//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 04. 04. 2020.
//

import Foundation

struct Sreality {
    private static let pozemkyUrl = URL(string: "https://www.sreality.cz/api/cs/v2/estates?category_main_cb=3&category_type_cb=1&locality_region_id=11&per_page=20&region=obec+Stochov&region_entity_id=3729&region_entity_type=municipality")!
    private static let domyUrl = URL(string: "https://www.sreality.cz/api/cs/v2/estates?category_main_cb=2&category_type_cb=1&per_page=20&region=obec+Stochov&region_entity_id=3729&region_entity_type=municipality")!

    // MARK: - Start

    static func downloadEstates() throws -> [Estate] {
        let pozemky = try parse(downloadPozemky()).map { Estate(title: "🗺 " + $0.title, url: $0.url) }
        let domy = try parse(downloadDomy()).map { Estate(title: "🏠 " + $0.title, url: $0.url) }
        return pozemky + domy
    }

    // MARK: -

    private static func downloadPozemky() throws -> Data {
        try Data(contentsOf: pozemkyUrl)
    }

    private static func downloadDomy() throws -> Data {
        try Data(contentsOf: domyUrl)
    }

    private static func parse(_ jsonData: Data) throws -> [Response.Embedded.SrealityEstate] {
        let response = try JSONDecoder().decode(Response.self, from: jsonData)
        return response._embedded.estates
    }

    // MARK: - Model

    private struct Response: Decodable {
        let _embedded: Embedded

        struct Embedded: Decodable {
            let estates: [SrealityEstate]

            struct SrealityEstate: Decodable {
                let hash_id: Int
                let name: String
                var title: String { return name }
                var url: String { return "https://www.sreality.cz/detail/prodej/pozemek/bydleni/stochov-stochov-/\(hash_id)" }
            }
        }
    }
}
