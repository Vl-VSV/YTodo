//
//  TodoItemNetwork.swift
//  YTodo
//
//  Created by Vlad V on 04.07.2023.
//

import UIKit

struct Response: Codable {
    let element: TodoItemForResponse?
    let list: [TodoItemForResponse]?
    let revision: Int32?
}

struct TodoItemForResponse: Codable {
    let id: String
    let text: String
    let priority: String
    let deadline: Int64?
    let isCompleted: Bool
    let color: String?
    let dateOfCreation: Int64
    let dateOfChange: Int64
    let lastUpdateBy: String
    
    init(_ todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        priority = todoItem.priority.rawValue
        isCompleted = todoItem.isCompleted
        dateOfCreation = Int64(todoItem.dateOfCreation.timeIntervalSince1970)
        dateOfChange = Int64(todoItem.dateOfChange?.timeIntervalSince1970 ?? todoItem.dateOfCreation.timeIntervalSince1970)
        deadline = todoItem.deadline == nil ? nil : Int64(todoItem.deadline?.timeIntervalSince1970 ?? 0)
        color = nil
        lastUpdateBy = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case priority = "importance"
        case deadline
        case isCompleted = "done"
        case color
        case dateOfCreation = "created_at"
        case dateOfChange = "changed_at"
        case lastUpdateBy = "last_updated_by"
    }
}
