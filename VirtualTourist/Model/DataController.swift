//
//  DataController.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/1/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    let backgroundContext : NSManagedObjectContext
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts(){
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    //Loading persistent store and setting config + starting autosave
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("Couldn't load store \(error!.localizedDescription)")
            }
            
            self.configureContexts()
            //self.autoSaveViewContext()
            completion?()
        }
    }
}

//Autosaving
extension DataController {
    func autoSaveViewContext(timeInterval: TimeInterval = 30){
        guard timeInterval > 0 else{
            fatalError("Time interval should be positive")
        }
        
        if(viewContext.hasChanges){
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            self.autoSaveViewContext(timeInterval: timeInterval)
        }
    }
}
