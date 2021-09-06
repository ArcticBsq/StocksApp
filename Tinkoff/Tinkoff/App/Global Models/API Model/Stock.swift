//
//  Stock.swift
//  Tinkoff
//
//  Created by Илья Москалев on 03.09.2021.
//

import Foundation

struct Stock: Codable {
    let symbol: String
    let companyName: String
    let latestPrice: Double
    let change: Double
}


typealias List = [Stock]
