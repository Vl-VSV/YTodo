//
//  SaveService.swift
//  YTodo
//
//  Created by Vlad V on 06.07.2023.
//

import Foundation

class SaveService {
    private enum Constants {
        static let lastKnownRevision = "LastKnownRevision"
        static let isDirty = "isDirty"
        static let fileName = "SavedItems.csv"
    }
    
    // MARK: - Properties
    private(set) var todoItems = [TodoItem]()
    
    private var networkService: NetworkService = NetworkService()
    
    private var isDirty: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.isDirty) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.isDirty) }
    }
        
    private var revision: Int32 {
        get { Int32(UserDefaults.standard.integer(forKey: Constants.lastKnownRevision)) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.lastKnownRevision) }
    }
    
    var delegate: UpdateTable?
    
    func loadData() {
        delegate?.startLoading()
        networkService.fetchTodoList { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.todoItems = data.0
                    self.revision = data.1
                    self.delegate?.updateData()
                    self.delegate?.completeLoading()
                
                case .failure(let error):
                    print(error)
                    self.delegate?.completeLoading()
                    
                    self.isDirty = true
                    do {
                        self.todoItems = try FileCache.loadCSV(from: Constants.fileName)
                        self.delegate?.updateData()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func delete(withId id: String) {
        if !todoItems.contains(where: { $0.id == id }) { return }
        
        todoItems.removeAll { $0.id == id }
        delegate?.updateData()
        
        guard !isDirty else {
            synchronization()
            return
        }
        
        // MARK: - Save to local storage
        DispatchQueue.global().async {
            do {
                try FileCache.saveCSV(todoItems: self.todoItems, to: Constants.fileName)
            } catch {
                print(error)
            }
        }
        
        // MARK: - Save to server
        delegate?.startLoading()
        networkService.deleteTodoItem(with: id, lastKnownRevision: revision) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let revision):
                    self.revision = revision
                    self.delegate?.completeLoading()
                
                case.failure(let error):
                    print(error)
                    self.isDirty = true
                }
            }
        }
    }
    
    func update(_ item: TodoItem) {
        guard let itemIndex = todoItems.firstIndex(where: {$0.id == item.id}) else {
            return
        }
        
        todoItems[itemIndex].text = item.text
        todoItems[itemIndex].deadline = item.deadline
        todoItems[itemIndex].dateOfCreation = item.dateOfCreation
        todoItems[itemIndex].isCompleted = item.isCompleted
        todoItems[itemIndex].priority = item.priority
        todoItems[itemIndex].dateOfChange = .now
        
        delegate?.updateData()
        
        guard !isDirty else {
            synchronization()
            return
        }
        
        // MARK: - Save to local storage
        DispatchQueue.global().async {
            do {
                try FileCache.saveCSV(todoItems: self.todoItems, to: Constants.fileName)
            } catch {
                print(error)
            }
        }
        
        // MARK: - Save to server
        delegate?.startLoading()
        networkService.updateTodoItem(updatingItem: item, lastKnownRevision: revision) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let revision):
                    self.revision = revision
                    self.delegate?.completeLoading()
                case .failure(let error):
                    print(error)
                    self.isDirty = true
                }
            }
        }
    }
    
    func add(_ item: TodoItem) {
        guard !todoItems.contains(where: { $0.id == item.id }) else {
            update(item)
            return
        }
        
        todoItems.append(item)
        delegate?.updateData()
        
        guard !isDirty else {
            synchronization()
            return
        }
        
        // MARK: - Save to local storage
        DispatchQueue.global().async {
            do {
                try FileCache.saveCSV(todoItems: self.todoItems, to: Constants.fileName)
            } catch {
                print(error)
            }
        }
        
        // MARK: - Save to server
        delegate?.startLoading()
        networkService.createTodoItem(item, lastKnownRevision: revision) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let revision):
                    self.revision = revision
                    self.delegate?.completeLoading()
                case .failure(let error):
                    print(error)
                    self.isDirty = true
                }
            }
        }
    }
    
    private func synchronization() {
        delegate?.startLoading()
        networkService.updateTodoList(with: todoItems, lastKnownRevision: revision) { result in
            switch result {
            case .success(let data):
                self.isDirty = false
                self.todoItems = data.0
                self.revision = data.1
                self.delegate?.completeLoading()
            case .failure(let error):
                print(error)
                self.delegate?.completeLoading()
            }
        }
    }
}
