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
    case normal
    case high
}

// MARK: - TodoItem struct
struct TodoItem {
    
    // MARK: - Properties
    let id: String
    let text: String
    let priority: Priority
    let deadline: Date?
    let isCompleted: Bool
    let dateOfCreation: Date
    let dateOfChange: Date?
    
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
