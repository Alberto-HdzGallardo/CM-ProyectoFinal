//
//  appFinanzasApp.swift
//  appFinanzas
//
//  Created by Alumno on 19/05/25.
//

import SwiftUI

@main
struct appFinanzasApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
