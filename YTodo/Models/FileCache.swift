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
