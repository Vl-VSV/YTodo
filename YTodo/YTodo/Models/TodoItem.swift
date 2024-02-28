//
//  TodoItem.swift
//  YTodo
//
//  Created by Vlad V on 13.06.2023.
//

import Foundation

// MARK: - Priority enum
enum Priority: String {
    case low
    case normal = "basic"
    case high = "important"
}

// MARK: - TodoItem struct
struct TodoItem {
    
    // MARK: - Properties
    var id: String
    var text: String
    var priority: Priority
    var deadline: Date?
    var isCompleted: Bool
    var dateOfCreation: Date
    var dateOfChange: Date?
    
    // MARK: - Init
    init(id: String = UUID().uuidString, text: String, priority: Priority, deadline: Date? = nil, isCompleted: Bool, dateOfCreation: Date, dateOfChange: Date? = nil) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.dateOfCreation = dateOfCreation
        self.dateOfChange = dateOfChange
    }
    
    init(_ item: TodoItemForResponse) {
        id = item.id
        text = item.text
        priority = Priority(rawValue: item.priority) ?? .normal
        isCompleted = item.isCompleted
        dateOfCreation = Date(timeIntervalSince1970: Double(item.dateOfCreation))
        dateOfChange = Date(timeIntervalSince1970: Double(item.dateOfChange))
        
        if let deadline = item.deadline {
            self.deadline = Date(timeIntervalSince1970: Double(deadline))
        }
    }
}

// MARK: - TodoItem JSON extension
extension TodoItem {
    
    // MARK: - Deserialization
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let id = json["id"] as? String,
              let text = json["text"] as? String,
              let isCompleted = json["isCompleted"] as? Bool,
              let dateOfCreationDoubleValue = json["dateOfCreation"] as? Double
        else {
            return nil
        }
        
        let dateOfCreation = Date(timeIntervalSince1970: dateOfCreationDoubleValue)
        
        let priority = (json["priority"] as? String).flatMap(Priority.init(rawValue:)) ?? .normal
         
        var deadline: Date?
        if let deadlineDoubleValue = json["deadline"] as? Double {
            deadline = Date(timeIntervalSince1970: deadlineDoubleValue)
        }
        
        var dateOfChange: Date?
        if let dateOfChangeDoubleValue = json["dateOfChange"] as? Double {
            dateOfChange = Date(timeIntervalSince1970: dateOfChangeDoubleValue)
        }
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, dateOfCreation: dateOfCreation, dateOfChange: dateOfChange)
    }
    
    // MARK: - Serialization
    var json: Any {
        var result = [String: Any]()
        
        result["id"] = id
        result["text"] = text
        result["isCompleted"] = isCompleted
        result["dateOfCreation"] = Double(dateOfCreation.timeIntervalSince1970)
        
        if priority != .normal {
            result["priority"] = priority.rawValue
        }
        
        if let deadline = deadline {
            result["deadline"] = Double(deadline.timeIntervalSince1970)
        }
        
        if let dateOfChange = dateOfChange {
            result["dateOfChange"] = Double(dateOfChange.timeIntervalSince1970)
        }
        
        return result
    }
}

// MARK: - TodoItem CSV extension
extension TodoItem {
    
    // MARK: - Deserialization
    static func parse(csv: Any) -> TodoItem? {
        guard let csv = csv as? String else {
            return nil
        }
        
        let fields = csv.components(separatedBy: ";")
        
        guard fields.count == 7  else {
            return nil
        }
        
        let id = fields[0]
        let text = fields[1]
        let priorityString = fields[2]
        let deadlineString = fields[3]
        let isCompletedString = fields[4]
        let dateOfCreationString = fields[5]
        let dateOfChangeString = fields[6]
        
        let priority = Priority(rawValue: priorityString) ?? .normal
        let isCompleted = isCompletedString.lowercased() == "true"
        
        guard let dateOfCreationDoubleValue = Double(dateOfCreationString) else {
            return nil
        }
        let dateOfCreation = Date(timeIntervalSince1970: dateOfCreationDoubleValue)
        
        var deadline: Date?
        if let deadlineDoubleValue = Double(deadlineString) {
            deadline = Date(timeIntervalSince1970: deadlineDoubleValue)
        }
        
        var dateOfChange: Date?
        if let dateOfChangeDoubleValue = Double(dateOfChangeString) {
            dateOfChange = Date(timeIntervalSince1970: dateOfChangeDoubleValue)
        }
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isCompleted: isCompleted, dateOfCreation: dateOfCreation, dateOfChange: dateOfChange)
        
    }
    
    // MARK: - Serialization
    var csv: String {
        var result = ""
        
        result += id + ";" + text + ";" + (priority == .normal ? "" : priority.rawValue) + ";"
        
        if let deadline = deadline {
            result += String(deadline.timeIntervalSince1970) + ";"
        } else {
            result += ";"
        }
        result += String(isCompleted) + ";" + String(dateOfCreation.timeIntervalSince1970) + ";"
        if let dateOfChange = dateOfChange {
            result += String(dateOfChange.timeIntervalSince1970)
        }
        return result
    }
}
