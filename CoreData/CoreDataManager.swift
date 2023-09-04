//
//  CoreDataManager.swift
//  Sonu_Martin_FE_8895003
//
//  Created by Sonu Martin on 12/08/23.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Sonu_Martin_FE_8895003")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // Other Core Data methods can be added here
}
