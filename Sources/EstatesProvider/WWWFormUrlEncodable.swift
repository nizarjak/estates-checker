//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 05. 04. 2020.
//

import Foundation

protocol WWWFormUrlEncodable {
    var params: [String: String] { get }
    func encode() -> Data
}

extension WWWFormUrlEncodable {
    func encode() -> Data {
        return params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)!
    }
}
