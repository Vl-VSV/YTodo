//
//  FileCache.swift
//  YTodo
//
//  Created by Vlad V on 13.06.2023.
//

import Foundation

// MARK: - File Cache Errors enum
enum FileCacheErrors: Error {
    case noSuchFileOrDirectory
    case upparsableData
}

// MARK: - File Cache class
final class FileCache {
    private(set) var todoItems = [TodoItem]()
    
    func add(_ item: TodoItem) {
        if !todoItems.contains(where: { $0.id == item.id }) {
            todoItems.append(item)
        } else {
            delete(withId: item.id)
            add(item)
        }
    }
    
    func update(at id: String, to item: TodoItem) {
        let itemIndex = todoItems.firstIndex(where: {$0.id == id})
        if let itemIndex = itemIndex {
            todoItems[itemIndex].text = item.text
            todoItems[itemIndex].deadline = item.deadline
            todoItems[itemIndex].dateOfCreation = item.dateOfCreation
            todoItems[itemIndex].isCompleted = item.isCompleted
            todoItems[itemIndex].priority = item.priority
            todoItems[itemIndex].dateOfChange = .now
        }
    }
    
    func delete(withId id: String) {
        todoItems.removeAll(where: { $0.id == id})
    }
    
    func saveJSON(to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        let path = dir.appending(path: file)
        
        let data = try JSONSerialization.data(withJSONObject: todoItems.map({ $0.json }))
        try data.write(to: path)
    }
    
    func loadJSON(from file: String) throws {
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
        
        todoItems = array.compactMap({TodoItem.parse(json: $0)})
    }
}

// MARK: - FileCache CSV extension
extension FileCache {
    func loadCSV(from file: String) throws {
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
        
        todoItems = []
        for rowIndex in 1 ..< rows.count {
            if let todoItem = TodoItem.parse(csv: rows[rowIndex]) {
                add(todoItem)
            }
        }
    }
    
    func saveCSV(to file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.noSuchFileOrDirectory
        }
        
        let path = dir.appending(path: file)
        var dataString = "id;text;priority;deadline;isCompleted;dateOfCreation;dateOfChange"
        for item in todoItems {
            dataString += "\n" + item.csv
        }
        let data = Data(dataString.utf8)
        try data.write(to: path)
    }
}
