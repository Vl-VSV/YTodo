//
//  FileCache.swift
//  YTodo
//
//  Created by Vlad V on 13.06.2023.
//

import Foundation
import SQLite

// MARK: - File Cache Errors enum
enum FileCacheErrors: Error {
    case noSuchFileOrDirectory
    case upparsableData
    case databaseConnetionError
}

// MARK: - File Cache class
final class FileCache {
    
    static func saveJSON(todoItems: [TodoItem], to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        let path = dir.appending(path: file)
        
        let data = try JSONSerialization.data(withJSONObject: todoItems.map({ $0.json }))
        try data.write(to: path)
    }
    
    static func loadJSON(from file: String) throws -> [TodoItem] {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        let path = dir.appending(path: file)
        
        guard FileManager.default.fileExists(atPath: path.path) else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        let data = try Data(contentsOf: path)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            throw FileCacheErrors.upparsableData
        }
        
        guard let array = json as? [[String: Any]] else {
            throw FileCacheErrors.upparsableData
        }
        
        return array.compactMap({TodoItem.parse(json: $0)})
    }
}

// MARK: - FileCache CSV extension
extension FileCache {
    static func loadCSV(from file: String) throws -> [TodoItem] {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        let path = dir.appending(path: file)
        
        guard let csvString = try? String(contentsOf: path) else {
            throw FileCacheErrors.upparsableData
        }
        
        let rows = csvString.components(separatedBy: "\n")
        
        if rows[0] != "id;text;priority;deadline;isCompleted;dateOfCreation;dateOfChange" {
            throw FileCacheErrors.upparsableData
        }
        
        var todoItems: [TodoItem] = []
        for rowIndex in 1 ..< rows.count {
            if let todoItem = TodoItem.parse(csv: rows[rowIndex]) {
                todoItems.append(todoItem)
            }
        }
        return todoItems
    }
    
    static func saveCSV(todoItems: [TodoItem], to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        print(path)
        var dataString = "id;text;priority;deadline;isCompleted;dateOfCreation;dateOfChange"
        for item in todoItems {
            dataString += "\n" + item.csv
        }
        let data = Data(dataString.utf8)
        try data.write(to: path)
    }
}

extension FileCache {
    
    /// Save Todo Items to SQLite database
    /// - Parameters:
    ///   - todoItems: Array of TodoItem, which need to save
    ///   - file: The name of the SQLite file
    /// - Throws: Errors that occur when saving data to the database
    static func saveSQLite(todoItems: [TodoItem], to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        print(path)
        let db = try Connection(path.absoluteString)
        
        let table = Table("todo_items")
        
        let id = Expression<String>("id")
        let text = Expression<String>("text")
        let priority = Expression<String>("priority")
        let deadline = Expression<Date?>("deadline")
        let isCompleted = Expression<Bool>("isCompleted")
        let dateOfCreation = Expression<Date>("dateOfCreation")
        let dateOfChange = Expression<Date?>("dateOfChange")
        
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, unique: true)
            t.column(text)
            t.column(priority)
            t.column(deadline)
            t.column(isCompleted)
            t.column(dateOfCreation)
            t.column(dateOfChange)
        })
        
        try db.run(table.delete())
        
        for item in todoItems {
            let insert = table.insert(id <- item.id, text <- item.text, priority <- item.priority.rawValue, deadline <- item.deadline, isCompleted <- item.isCompleted, dateOfCreation <- item.dateOfCreation, dateOfChange <- item.dateOfChange)
            
            try db.run(insert)
        }
        
    }
    
    /// Load data from SQLite database and return array of TodoItem
    /// - Parameter file: Name of SQLite database file
    /// - Returns: Array of TodoItem
    /// - Throws: Errors that occur when loading data from the database
    static func loadSQLite(from file: String) throws -> [TodoItem] {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        
        let db = try Connection(path.absoluteString)
        
        let table = Table("todo_items")
        
        let id = Expression<String>("id")
        let text = Expression<String>("text")
        let priority = Expression<String>("priority")
        let deadline = Expression<Date?>("deadline")
        let isCompleted = Expression<Bool>("isCompleted")
        let dateOfCreation = Expression<Date>("dateOfCreation")
        let dateOfChange = Expression<Date?>("dateOfChange")
        
        var todoItems: [TodoItem] = []
        for item in try db.prepare(table) {
            todoItems.append(TodoItem(id: item[id], text: item[text], priority: Priority(rawValue: item[priority]) ?? .normal, deadline: item[deadline], isCompleted: item[isCompleted], dateOfCreation: item[dateOfCreation], dateOfChange: item[dateOfChange]))
        }
        
        return todoItems
    }
    
    /// Add a TodoItem to the SQLite database
    /// - Parameters:
    ///   - item: The TodoItem to be added
    ///   - file: The name of the SQLite file
    static func addSQLite(_ item: TodoItem, to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        
        let db = try Connection(path.absoluteString)
        print(path)
        let table = Table("todo_items")
        
        let id = Expression<String>("id")
        let text = Expression<String>("text")
        let priority = Expression<String>("priority")
        let deadline = Expression<Date?>("deadline")
        let isCompleted = Expression<Bool>("isCompleted")
        let dateOfCreation = Expression<Date>("dateOfCreation")
        let dateOfChange = Expression<Date?>("dateOfChange")
        
        let insert = table.insert(or: .replace, id <- item.id, text <- item.text, priority <- item.priority.rawValue, deadline <- item.deadline, isCompleted <- item.isCompleted, dateOfCreation <- item.dateOfCreation, dateOfChange <- item.dateOfChange)
        
        try db.run(insert)
    }
    
    /// Update a TodoItem to the SQLite database
    /// - Parameters:
    ///   - item: The TodoItem to be updated
    ///   - file: The name of the SQLite file
    static func updateItemSQLite(_ item: TodoItem, to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        
        let db = try Connection(path.absoluteString)
        
        let table = Table("todo_items")
        
        let id = Expression<String>("id")
        let text = Expression<String>("text")
        let priority = Expression<String>("priority")
        let deadline = Expression<Date?>("deadline")
        let isCompleted = Expression<Bool>("isCompleted")
        let dateOfCreation = Expression<Date>("dateOfCreation")
        let dateOfChange = Expression<Date?>("dateOfChange")
        
        let itemForUpdate = table.filter(id == item.id)
        
        let update = itemForUpdate.update(text <- item.text, priority <- item.priority.rawValue, deadline <- item.deadline, isCompleted <- item.isCompleted, dateOfCreation <- item.dateOfCreation, dateOfChange <- .now)
        
        try db.run(update)
    }
    
    /// Delete a TodoItem to the SQLite database
    /// - Parameters:
    ///   - item: The TodoItem to be deleted
    ///   - file: The name of the SQLite file
    static func deleteItemSQLite(_ itemId: String, to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        
        let db = try Connection(path.absoluteString)
        
        let table = Table("todo_items")
        
        let id = Expression<String>("id")
        
        let itemForDelete = table.filter(id == itemId)
        
        try db.run(itemForDelete.delete())
    }
}
