//
//  LineChart.swift
//  StockAPI
//
//  Created by Alumno on 27/05/25.
//

import SwiftUI

struct LineChart: Shape {
    var data: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        guard data.count >= 2 else { return Path() }
        
        func convertToPoint(index: Int) -> CGPoint {
            let point = data[index]
            let x = rect.width * CGFloat(index) / CGFloat(data.count - 1)
            let y = (1 - point) * rect.height
            return CGPoint(x: x, y: y)
        }
        
        var path = Path()
        path.move(to: convertToPoint(index: 0))
        
        for index in 1..<data.count {
            path.addLine(to: convertToPoint(index: index))
        }
        
        return path
    }
}

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: StockMockData.apple.normalizedValues)
            .stroke(Color.lightGreen)
            .frame(width: 400, height: 500)
            .padding()
    }
}
