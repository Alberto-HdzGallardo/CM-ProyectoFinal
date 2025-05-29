//
//  HeaderReportes.swift
//  appFinanzas
//
//  Created by Alumno on 29/05/25.
//

import SwiftUI

struct HeaderReportes: View {
        var body: some View {
            HStack{
                Text("Balance de reportes")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.darkBlue)
                    
                
                Spacer()
                
                
                Image(systemName: "chart.bar.xaxis")
                    .accentColor(Color.darkBlue)
                    .font(.system(size: 40))
                    
                }
            }
        }

#Preview {
    HeaderReportes()
}
