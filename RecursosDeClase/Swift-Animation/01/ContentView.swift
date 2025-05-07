//
//  ContentView.swift
//  Swift-Animation-CM-01
//
//  Created by Alumno on 07/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var change = false
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .foregroundStyle(.orange)
                .frame(width:100,height:100)
                .offset(x:0,y: change ? 300:0)
            
            Spacer()
            
            Button("Cambiar"){
                change.toggle()
            }.padding(.bottom)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
