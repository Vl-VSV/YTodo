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
        
        static let minDelay: Double = 2000
        static let maxDelay: Double = 120000
        static let factor: Double = 1.5
        static let jitter: Double = 0.05
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
    
    private var retryNum: Double = 0
    
    // MARK: - Load data
    func loadData() {
        guard !isDirty else {
            synchronization()
            return
        }
        
        delegate?.startLoading()
        networkService.fetchTodoList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Successful load to server")
                    self?.todoItems = data.0
                    self?.revision = data.1
                    self?.delegate?.updateData()
                    self?.delegate?.completeLoading()
                
                case .failure(let error):
                    print(error)
                    self?.delegate?.completeLoading()
                    
                    self?.isDirty = true
                    do {
                        self?.todoItems = try FileCache.loadCSV(from: Constants.fileName)
                        self?.delegate?.updateData()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    // MARK: - Delete
    func delete(withId id: String) {
        if !todoItems.contains(where: { $0.id == id }) { return }
        
        todoItems.removeAll { $0.id == id }
        delegate?.updateData()
        
        // MARK: - Save to local storage
            do {
                try FileCache.saveCSV(todoItems: self.todoItems, to: Constants.fileName)
            } catch {
                print(error)
            }
        
        guard !isDirty else {
            synchronization()
            return
        }
        
        // MARK: - Dalete from server
        delegate?.startLoading()
        networkService.deleteTodoItem(with: id, lastKnownRevision: revision) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let revision):
                    print("Successful delete to server")
                    self?.revision = revision
                    self?.delegate?.completeLoading()
                    self?.retryNum = 0
                    
                case.failure(let error):
                    print(error)
                    self?.delegate?.completeLoading()
                    self?.isDirty = true
                    self?.executeWithExponentialRetry {
                        self?.delete(withId: id)
                    }
                }
            }
        }
    }
    
    // MARK: - Update
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
        
        // MARK: - Save to local storage
            do {
                try FileCache.saveCSV(todoItems: self.todoItems, to: Constants.fileName)
            } catch {
                print(error)
            }
        
        guard !isDirty else {
            synchronization()
            return
        }
        
        // MARK: - Update item to server
        delegate?.startLoading()
        networkService.updateTodoItem(updatingItem: item, lastKnownRevision: revision) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let revision):
                    print("Successful update to server")
                    self?.revision = revision
                    self?.delegate?.completeLoading()
                    self?.retryNum = 0
                    
                case .failure(let error):
                    print(error)
                    self?.delegate?.completeLoading()
                    self?.isDirty = true
                    self?.executeWithExponentialRetry {
                        self?.update(item)
                    }
                }
            }
        }
    }
    
    // MARK: - Add
    func add(_ item: TodoItem) {
         guard !todoItems.contains(where: { $0.id == item.id }) else {
            update(item)
            return
        }
        
        todoItems.append(item)
        delegate?.updateData()
        
        // MARK: - Save to local storage
        do {
            try FileCache.saveCSV(todoItems: self.todoItems, to: Constants.fileName)
        } catch {
            print(error)
        }
        
        guard !isDirty else {
            synchronization()
            return
        }
         
        // MARK: - Add item to server
        delegate?.startLoading()
        networkService.createTodoItem(item, lastKnownRevision: revision) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let revision):
                    print("Successful adding to server")
                    self?.revision = revision
                    self?.delegate?.completeLoading()
                    self?.retryNum = 0
                    
                case .failure(let error):
                    print(error)
                    self?.delegate?.completeLoading()
                    self?.isDirty = true
                    self?.executeWithExponentialRetry {
                        self?.add(item)
                    }
                }
            }
        }
    }
    
    // MARK: - Sync
    private func synchronization() {
        // MARK: - Load local data
        do {
            todoItems = try FileCache.loadCSV(from: Constants.fileName)
        } catch {
            print(error)
        }
        
        // MARK: - Sync with server
        delegate?.startLoading()
        networkService.updateTodoList(with: todoItems, lastKnownRevision: revision) { [weak self] result in
            switch result {
            case .success(let data):
                print("Successful sync with server")
                self?.isDirty = false
                self?.todoItems = data.0
                self?.revision = data.1
                self?.delegate?.completeLoading()
                self?.retryNum = 0
                
            case .failure(let error):
                print(error)
                self?.delegate?.completeLoading()
                self?.executeWithExponentialRetry {
                    self?.synchronization()
                }
            }
        }
    }
}

extension SaveService {
    private func executeWithExponentialRetry(closure: @escaping () -> Void) {
        func getDelay() -> Int {
            let expDelay = Constants.minDelay * pow(Constants.factor, retryNum)
            let delay = min(expDelay, Constants.maxDelay)
            let resultDelay = delay * Double.random(in: (1 - Constants.jitter)...(1 + Constants.jitter))
            return Int(resultDelay.rounded())
        }
        
        let delay = getDelay()
        retryNum += 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay), execute: closure)
    }
}
