//
//  SearchStockView.swift
//  StockAPI
//
//  Created by Alumno on 28/05/25.
//

import SwiftUI

struct SearchStockView: View {
    @State private var searchSymbol: String = ""
        var body: some View {
            VStack {
                TextField("Stock Ticker Symbol", text: $searchSymbol)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.darkBlue, lineWidth: 1)
                    ).padding()
                    .textInputAutocapitalization(.never)
                Divider()
                
                StockCell(stock: "AAPL", description: "Apple Computers")
                Divider()
                StockCell(stock: "NVDA", description: "NVidia")
                Divider()
                StockCell(stock: "NFLX", description: "Netflix")
                Divider()
                
                Spacer()
            }
        }
    }

#Preview {
    SearchStockView()
}
