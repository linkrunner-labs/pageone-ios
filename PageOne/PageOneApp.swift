//
//  PageOneApp.swift
//  PageOne
//
//  Created by Darshil Rathod on 17/06/25.
//

import SwiftUI

@main
struct PageOneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
