//
//  TodoItemTests.swift
//  YTodoTests
//
//  Created by Vlad V on 13.06.2023.
//

import XCTest
@testable import YTodo

final class TodoItemTests: XCTestCase {
    
    func testTodoItemInitialization() {
        
        let id = "12345"
        let text = "Buy groceries"
        let priority = Priority.high
        let deadline = Date()
        let isCompleted = false
        let dateOfCreation = Date()
        let dateOfChange = Date()
        
        let todoItem = TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, dateOfCreation: dateOfCreation, dateOfChange: dateOfChange)
        
        let secondText = "Wash the car"
        let secondPriority = Priority.normal
        let secondIsCompleted = true
        let secondDateOfCreation = Date()
        
        let secondTodoItem = TodoItem(text: secondText, priority: secondPriority, isCompleted: secondIsCompleted, dateOfCreation: secondDateOfCreation)
        
        XCTAssertEqual(todoItem.id, id)
        XCTAssertEqual(todoItem.text, text)
        XCTAssertEqual(todoItem.priority, priority)
        XCTAssertEqual(todoItem.deadline, deadline)
        XCTAssertEqual(todoItem.isCompleted, isCompleted)
        XCTAssertEqual(todoItem.dateOfCreation, dateOfCreation)
        XCTAssertEqual(todoItem.dateOfChange, dateOfChange)
        
        XCTAssertEqual(secondTodoItem.text, secondText)
        XCTAssertEqual(secondTodoItem.priority, secondPriority)
        XCTAssertNil(secondTodoItem.deadline)
        XCTAssertEqual(secondTodoItem.isCompleted, secondIsCompleted)
        XCTAssertEqual(secondTodoItem.dateOfCreation, secondDateOfCreation)
        XCTAssertNil(secondTodoItem.dateOfChange)
    }
    
    func testTodoItemJSONSerialization() {
        
        let id = "12345"
        let text = "Buy groceries"
        let priority = Priority.high
        let deadline = Date()
        let isCompleted = false
        let dateOfCreation = Date()
        let dateOfChange = Date()
        
        let todoItem = TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, dateOfCreation: dateOfCreation, dateOfChange: dateOfChange)
        
        let json = todoItem.json
        
        XCTAssertNotNil(json)
        XCTAssertTrue(json is [String: Any])
        
        if let jsonDictionary = json as? [String: Any] {
            XCTAssertEqual(jsonDictionary["id"] as? String, id)
            XCTAssertEqual(jsonDictionary["text"] as? String, text)
            XCTAssertEqual(jsonDictionary["isCompleted"] as? Bool, isCompleted)
            XCTAssertEqual(jsonDictionary["dateOfCreation"] as? TimeInterval, dateOfCreation.timeIntervalSince1970)
            XCTAssertEqual(jsonDictionary["priority"] as? String, priority.rawValue)
            XCTAssertEqual(jsonDictionary["deadline"] as? TimeInterval, deadline.timeIntervalSince1970)
            XCTAssertEqual(jsonDictionary["dateOfChange"] as? TimeInterval, dateOfChange.timeIntervalSince1970)
        }
    }
    
    func testTodoItemJSONDeserialization() {
        
        let id = "12345"
        let text = "Buy groceries"
        let priority = Priority.high
        let isCompleted = false
        let dateOfCreation = Date()
        
        let json: [String: Any] = [
            "id": id,
            "text": text,
            "priority": priority.rawValue,
            "isCompleted": isCompleted,
            "dateOfCreation": Double(dateOfCreation.timeIntervalSince1970)
        ]
        
        let todoItem = TodoItem.parse(json: json)
        
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.id, id)
        XCTAssertEqual(todoItem?.text, text)
        XCTAssertEqual(todoItem?.priority, priority)
        XCTAssertNil(todoItem?.deadline)
        XCTAssertEqual(todoItem?.isCompleted, isCompleted)
        
        if let itemDate = todoItem?.dateOfCreation {
            XCTAssertEqual(itemDate.timeIntervalSince1970, dateOfCreation.timeIntervalSince1970)
        } else {
            XCTFail("Failed to unwrap dateOfCreation")
        }

        XCTAssertNil(todoItem?.dateOfChange)
    }
    
    func testTodoItemInccorectJSONDeserialization() {
    
        let text = "Buy groceries"
        let priority = Priority.high
        let isCompleted = false
        let dateOfCreation = Date()
        
        let json: [String: Any] = [
            "text": text,
            "priority": priority.rawValue,
            "isCompleted": isCompleted,
            "dateOfCreation": Double(dateOfCreation.timeIntervalSince1970)
        ]
        
        XCTAssertNil(TodoItem.parse(json: json))
    }
    
    func testTodoItemCSVSerialization() {
        
        let id = "12345"
        let text = "Buy groceries"
        let priority = Priority.high
        let deadline = Date()
        let isCompleted = false
        let dateOfCreation = deadline
        let dateOfChange = dateOfCreation
        
        let dateString = String(deadline.timeIntervalSince1970)
        
        let todoItem = TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, dateOfCreation: dateOfCreation, dateOfChange: dateOfChange)
        
        let csv = todoItem.csv
        
        XCTAssertEqual(csv, "\(id);\(text);\(priority.rawValue);\(dateString);\(isCompleted);\(dateString);\(dateString)")
    }
    
    func testTodoItemCSVDeserialization() {
        let id = "12345"
        let text = "Buy groceries, equipment"
        let priority = Priority.high
        let isCompleted = false
        let dateOfCreation = Date()
        
        let dateString = String(Double(dateOfCreation.timeIntervalSince1970))
        
        let csv = "\(id);\(text);\(priority.rawValue);;\(isCompleted);\(dateString);"
        
        let todoItem = TodoItem.parse(csv: csv)
        
        XCTAssertNotNil(todoItem)
        XCTAssertEqual(todoItem?.id, id)
        XCTAssertEqual(todoItem?.text, text)
        XCTAssertEqual(todoItem?.priority, priority)
        XCTAssertNil(todoItem?.deadline)
        XCTAssertEqual(todoItem?.isCompleted, isCompleted)
        
        if let itemDate = todoItem?.dateOfCreation {
            XCTAssertEqual(itemDate.timeIntervalSince1970, dateOfCreation.timeIntervalSince1970)
        } else {
            XCTFail("Failed to unwrap dateOfCreation")
        }
        
        XCTAssertNil(todoItem?.dateOfChange)
    }
    
    func testTodoItemIncorrectCSVDeserialization() {
        let id = "id"
        let text = "Buy groceries"
        let priority = Priority.high
        let isCompleted = false
        
        let csv = "\(id);\(text);\(priority.rawValue);;\(isCompleted);;"
        
        XCTAssertNil(TodoItem.parse(csv: csv))
    }
}

