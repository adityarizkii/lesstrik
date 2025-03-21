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
    @StateObject var route = AppRoute()

    
    var body: some Scene {
        WindowGroup {
            HomePage()
                .environmentObject(route)
        }
    }
}


