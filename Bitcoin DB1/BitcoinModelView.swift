//
//  BitcoinModelView.swift
//  Bitcoin DB1
//
//  Created by Lucas Franco Bernardes on 29/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import Foundation

struct Cotacao: Decodable {
    let status: String
    let name: String
    let unit: String
    let period: String
    let description: String
    let cordenadas: [Cordenada]
    
    enum CodingKeys : String, CodingKey {
        case status
        case name = "name"
        case unit = "unit"
        case period = "period"
        case description = "description"
        case cordenadas = "values"
    }
}
struct Cordenada: Decodable {
    let x: Double
    let y: Double
}
