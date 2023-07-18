//
//  TodoItem.swift
//  YTodoSwiftUI
//
//  Created by Vlad V on 16.07.2023.
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
}
