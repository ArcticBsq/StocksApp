//
//  Stock.swift
//  Tinkoff
//
//  Created by Илья Москалев on 03.09.2021.
//

import Foundation

// Акция
struct Stock: Codable {
    let symbol: String
    let companyName: String
    let latestPrice: Double
    let change: Double
}

// Ссылка на URL картинки логотипа компании
struct Logo: Codable {
    let url: String?
}

// Список акций для предзагрузки
typealias List = [Stock]
