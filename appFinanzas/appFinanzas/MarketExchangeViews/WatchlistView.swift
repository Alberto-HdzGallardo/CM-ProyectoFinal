//
//  WatchlistView.swift
//  StockAPI
//
//  Created by Alumno on 27/05/25.
//

import SwiftUI

struct WatchlistView: View {
    @StateObject var stocksVM: StocksViewModel
        
        var body: some View {
            VStack {
                HStack {
                    Text("Watchlist")
                        .font(.title)
                        .bold()
                        .foregroundColor(.darkBlue)
                    Spacer()
                }
                
                // stock cards
                ScrollView {
                    VStack {
                        
                        ForEach(stocksVM.stocks, id: \.self) { stock in
                           StockCard(stockModel: stock)
                        }
                        
                    }
                }
                .padding(3)
                
            }
        }
    }


