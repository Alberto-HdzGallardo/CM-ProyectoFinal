//
//  ContentView.swift
//  Swift-Animation-CM-02
//
//  Created by Alumno on 07/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var change = false
    var body: some View {
        VStack {
            /*Circle()
                .foregroundStyle(.orange)
                .frame(width: change ? 200:100, height: change ? 200:100)
                .offset(x:0 , y: 300)
                .animation(Animation.easeOut(duration: 5), value: change)*/
            
            Rectangle().cornerRadius(10)
                .foregroundStyle(.red)
                .frame(width: 100, height: 100)
                .offset(x: change ? 150:-150,y:300)
            
            Spacer()
            
            Button("Animar"){
                change.toggle()
            }.padding()
        }
        .padding(.bottom)
        
    }
}

#Preview {
    ContentView()
}
