//
//  HeaderView.swift
//  StockAPI
//
//  Created by Alumno on 27/05/25.
//

import SwiftUI

struct HeaderView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        HStack{
            Text("Market Exchange")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.darkBlue)
                
            
            Spacer()
            
            Button(action:{
                showSheet.toggle()
            }){
                Image(systemName: "magnifyingglass.circle.fill")
                    .accentColor(Color.darkBlue)
                    .font(.system(size: 40))
                }
            }
        }
    }


/*#Preview
    HeaderView()
        .padding()
}*/
