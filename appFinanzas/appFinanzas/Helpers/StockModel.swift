//
//  StockModel.swift
//  StockAPI
//
//  Created by Alumno on 28/05/25.
//

import Foundation

struct StockModel: Hashable {
    let symbol: String // AAPL
    let description: String? // Apple Inc
    let currentPrice: Double? // 150.20
    let percentageChange: Double?
    let candles: [CGFloat]
}
