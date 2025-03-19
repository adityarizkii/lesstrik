//
//  LesstrikApp.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 17/03/25.
//

import SwiftUI
import CoreData

@main
struct LesstrikApp: App {
    let persistentContainer = NSPersistentContainer(name: "DataModel")

        init() {
            persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Unresolved error \(error)")
                }
            }
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


