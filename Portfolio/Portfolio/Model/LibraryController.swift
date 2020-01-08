//
//  LibraryController.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/8/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class LibraryController {
    func create(libraryNamed name: String, context: NSManagedObjectContext) {
        Library(name: name, context: context)
        CoreDataStack.shared.save(context: context)
    }
    
    func delete(library: Library, context: NSManagedObjectContext) {
        context.delete(library)
        CoreDataStack.shared.save(context: context)
    }
}
