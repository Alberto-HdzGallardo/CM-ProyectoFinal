//
//  generadorDePrueba.swift
//  appFinanzas
//
//  Created by Alumno on 29/05/25.
//

import Foundation
import SwiftUI

func generarDatosDePrueba() -> [Movimiento] {
    let calendar = Calendar.current
    let now = Date()
    var movimientos: [Movimiento] = []
    
    // Generador de montos aleatorios
    func randomMonto() -> Double {
        return Double.random(in: 100...2000) * (Bool.random() ? 1 : -1)
    }
    
    // Categorias
    let nombres = ["Comida", "Transporte", "Ingreso", "Deudas", "Entretenimiento"]
    
    // Generar datos para los últimos 6 meses
    for monthOffset in 0..<6 {
        guard let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
        
        // Determinar cuántos días tiene el mes
        let range = calendar.range(of: .day, in: .month, for: date)!
        let daysCount = range.count
        
        // Generar 3-8 movimientos por mes
        let movimientosEnMes = Int.random(in: 3...8)
        
        for _ in 0..<movimientosEnMes {
            // Seleccionar un día aleatorio del mes
            let day = Int.random(in: 1...daysCount)
            
            // Crear fecha completa
            var components = calendar.dateComponents([.year, .month], from: date)
            components.day = day
            components.hour = Int.random(in: 8...20)
            components.minute = Int.random(in: 0...59)
            
            guard let fechaMovimiento = calendar.date(from: components) else { continue }
            
            // Crear movimiento
            let movimiento = Movimiento(
                tipo: nombres.randomElement()!,
                monto: randomMonto(),
                referencia: "General",
                fecha: fechaMovimiento
                
                
            )
            
            movimientos.append(movimiento)
        }
    }
    
    return movimientos
}
