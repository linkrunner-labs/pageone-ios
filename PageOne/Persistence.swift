//
//  Persistence.swift
//  PageOne
//
//  Created by Darshil Rathod on 17/06/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleNote = NoteEntity(context: viewContext)
        sampleNote.id = UUID()
        sampleNote.title = "Note 2025-06-17 14-30"
        sampleNote.body = "This is a sample note for preview purposes. You can start typing right away when the app opens."
        sampleNote.createdAt = Date()
        sampleNote.updatedAt = Date()
        
        let sampleNote2 = NoteEntity(context: viewContext)
        sampleNote2.id = UUID()
        sampleNote2.title = "Note 2025-06-17 12-15"
        sampleNote2.body = "Another sample note to demonstrate the list view."
        sampleNote2.createdAt = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        sampleNote2.updatedAt = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PageOne")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
