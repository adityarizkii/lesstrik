//
//  Lesstrik.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 19/03/25.
//

import Foundation
import CoreData



class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataModel")
        
        container.loadPersistentStores { _, error in
            
            
            if let error {
      
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
            
            
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
           return persistentContainer.viewContext
   }
        
    public init() { }
}
