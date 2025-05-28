//
//  Extensions.swift
//  StockAPI
//
//  Created by Alumno on 27/05/25.
//

import UIKit
import SwiftUI

extension Color {
    public static var darkBlue: Color {
        return Color(UIColor(red: 3/255, green: 49/255, blue: 75/255, alpha: 1.0))
    }
    
    public static var lightGreen: Color {
        return Color(UIColor(red: 30/255, green: 204/255, blue: 151/255, alpha: 1.0))
    }
    
}

extension Array where Element == CGFloat {
    var normalizedValues: [CGFloat] {
        guard let min = self.min(), let max = self.max(), max - min > 0 else {
            return Array(repeating: 0.5, count: self.count) // Línea centrada si no hay variación
        }
        return self.map { ($0 - min) / (max - min) }
    }
}
