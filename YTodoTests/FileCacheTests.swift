//
//  FileCacheTests.swift
//  YTodoTests
//
//  Created by Vlad V on 13.06.2023.
//

import XCTest
@testable import YTodo

final class FileCacheTests: XCTestCase {
    var fileCache: FileCache!
    
    override func setUp() {
        super.setUp()
        fileCache = FileCache()
    }
    
    override func tearDown() {
        fileCache = nil
        super.tearDown()
    }
    
    func testAddItem() {
        
        let item = TodoItem(id: "1", text: "Buy groceries", priority: .normal, isCompleted: false, dateOfCreation: Date())
        
        fileCache.add(item)
        
        XCTAssertTrue(fileCache.todoItems.contains(where: {$0.id == item.id}))
    }
    
    func testAddDuplicateItem() {
        
        let item = TodoItem(id: "1", text: "Buy groceries", priority: .normal, isCompleted: false, dateOfCreation: Date())
        fileCache.add(item)
        fileCache.add(item)
        
        XCTAssertEqual(fileCache.todoItems.count, 1)
    }
    
    func testDeleteItem() {
        
        let item = TodoItem(id: "1", text: "Buy groceries", priority: .normal, isCompleted: false, dateOfCreation: Date())
        
        fileCache.add(item)
        fileCache.delete(withId: "1")
        
        XCTAssertTrue(fileCache.todoItems.count == 0)
    }
    
    func testSaveToFile() {
        
        let item1 = TodoItem(id: "1", text: "Buy groceries", priority: .normal, isCompleted: false, dateOfCreation: Date())
        let item2 = TodoItem(id: "2", text: "Do laundry", priority: .high, isCompleted: true, dateOfCreation: Date())
        fileCache.add(item1)
        fileCache.add(item2)
        
        let filePath = "testFile.json"
        
        do {
            try fileCache.save(to: filePath)
        } catch {
            XCTFail("Saving to file failed with error: \(error)")
        }
        
        XCTAssertNotNil(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.pathComponents.contains(filePath))
    }
    
    func testLoadFromFile() {
        
        let filePath = "testFile.json"
        let item1 = TodoItem(id: "1", text: "Buy groceries", priority: .normal, isCompleted: false, dateOfCreation: Date())
        let item2 = TodoItem(id: "2", text: "Do laundry", priority: .high, isCompleted: true, dateOfCreation: Date())
        fileCache.add(item1)
        fileCache.add(item2)
        
        do {
            try fileCache.save(to: filePath)
        } catch {
            XCTFail("Saving to file failed with error: \(error)")
        }
        
        do {
            try fileCache.load(from: filePath)
        } catch {
            XCTFail("Loading from file failed with error: \(error)")
        }
        
        XCTAssertEqual(fileCache.todoItems.count, 2)
        XCTAssertTrue(fileCache.todoItems.contains(where: {$0.id == item1.id}))
        XCTAssertTrue(fileCache.todoItems.contains(where: {$0.id == item2.id}))
    }
    
    func testLoadFromNonExistentFile() {
        
        let nonExistentFilePath = "NonExistentFile.json"
        
        XCTAssertThrowsError(try fileCache.load(from: nonExistentFilePath), "Expected error to be thrown") { error in
            XCTAssertEqual(error as? FileCacheErrors, FileCacheErrors.noSuchFileOrDirectory)
        }
        
        XCTAssertEqual(fileCache.todoItems.count, 0)
    }
    
    func testLoadFromInvalidFile() {
        
        let invalidFilePath = "InvalidFile.json"
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = dir.appendingPathComponent(invalidFilePath)
        
        do {
            try Data().write(to: fileURL)
        } catch {
            print("error")
        }
        
        XCTAssertThrowsError(try fileCache.load(from: invalidFilePath), "Expected error to be thrown") { error in
            XCTAssertEqual(error as? FileCacheErrors, FileCacheErrors.upparsableData)
        }
        print(fileCache.todoItems)
        XCTAssertEqual(fileCache.todoItems.count, 0)
    }

}
