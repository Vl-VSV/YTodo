//
//  NetworkService.swift
//  YTodo
//
//  Created by Vlad V on 02.07.2023.
//

import Foundation

enum NetworkErrors: Error {
    case invalidURL
    case invalidResponse
    case invalidRequest
    case networkError
    case unknownError
    case noResponseData
}

enum JSONErros: Error {
    case serializationError
    case deserializationError
}

protocol NetworkServiceProtocol {
    func fetchTodoList(completion: @escaping (Result<([TodoItem], Int32), Error>) -> Void)
    func updateTodoList(with items: [TodoItem], lastKnownRevision: Int32, completion: @escaping (Result<([TodoItem], Int32), Error>) -> Void)
    func fetchTodoItem(with id: String, completion: @escaping (Result<(TodoItem, Int32), Error>) -> Void)
    func createTodoItem(_ item: TodoItem, lastKnownRevision: Int32, completion: @escaping (Result<Int32, Error>) -> Void)
    func updateTodoItem(updatingItem: TodoItem, lastKnownRevision: Int32, completion: @escaping (Result<Int32, Error>) -> Void)
    func deleteTodoItem(with id: String, lastKnownRevision: Int32, completion: @escaping (Result<Int32, Error>) -> Void)
}

class NetworkService {
    private let networkServiceQueue = DispatchQueue.global(qos: .default)
    private let customSession: URLSession = {
        let session = URLSession.init(configuration: .default)
        session.configuration.timeoutIntervalForRequest = Constants.timeoutInterval
        return session
    }()
}

// MARK: - Implementation Network Service Protocol
extension NetworkService: NetworkServiceProtocol {
    func fetchTodoList(completion: @escaping (Result<([TodoItem], Int32), Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/list") else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }
        
        guard let request = createRequest(with: url, httpMethod: .get) else {
            completion(.failure(NetworkErrors.invalidResponse))
            return
        }
        
        let task = createTask(with: request) { result in
            switch result {
            case .success(let response):
                guard let revision = response.revision, let todoItemsForResponse = response.list else {
                    completion(.failure(NetworkErrors.noResponseData))
                    return
                }
                
                let todoItems = todoItemsForResponse.map { TodoItem($0) }
                completion(.success((todoItems, revision)))
                
            case .failure(let error):
                completion(.failure(error))
                
            }
        }
        
        networkServiceQueue.async {
            task.resume()
        }
    }
    
    func updateTodoList(with items: [TodoItem], lastKnownRevision: Int32, completion: @escaping (Result<([TodoItem], Int32), Error>) -> Void) {
        let todoItemsForResponse = items.map { TodoItemForResponse($0) }
        
        guard let url = URL(string: "\(Constants.baseURL)/list") else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }
        
        guard let body = try? JSONEncoder().encode(Response(element: nil, list: todoItemsForResponse, revision: nil)) else {
            completion(.failure(JSONErros.serializationError))
            return
        }
        
        guard let request = createRequest(with: url, httpMethod: .patch, httpBody: body, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.invalidResponse))
            return
        }
        
        let task = createTask(with: request) { result in
            switch result {
            case .success(let response):
                guard let revision = response.revision, let todoItemsForResponse = response.list else {
                    completion(.failure(NetworkErrors.noResponseData))
                    return
                }
                
                let todoItems = todoItemsForResponse.map { TodoItem($0) }
                completion(.success((todoItems, revision)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        networkServiceQueue.async {
            task.resume()
        }
    }
    
    func fetchTodoItem(with id: String, completion: @escaping (Result<(TodoItem, Int32), Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/list/\(id)") else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }
        
        guard let request = createRequest(with: url, httpMethod: .get) else {
            completion(.failure(NetworkErrors.invalidRequest))
            return
        }
        
        let task = createTask(with: request) { result in
            switch result {
            case .success(let response):
                guard let revision = response.revision, let todo = response.element else {
                    completion(.failure(NetworkErrors.noResponseData))
                    return
                }
                
                completion(.success((TodoItem(todo), revision)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        networkServiceQueue.async {
            task.resume()
        }
    }
    
    func createTodoItem(_ item: TodoItem, lastKnownRevision: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
        let todoItemForResponce = TodoItemForResponse(item)
        guard let url = URL(string: "\(Constants.baseURL)/list") else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }
        
        guard let body = try? JSONEncoder().encode(Response(element: todoItemForResponce, list: nil, revision: nil)) else {
            completion(.failure(JSONErros.serializationError))
            return
        }
        
        guard let request = createRequest(with: url, httpMethod: .post, httpBody: body, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.invalidRequest))
            return
        }
        
        let task = createTask(with: request) { result in
            switch result {
            case .success(let response):
                guard let revision = response.revision else {
                    completion(.failure(NetworkErrors.noResponseData))
                    return
                }
                
                completion(.success(revision))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        networkServiceQueue.async {
            task.resume()
        }
    }
    
    func updateTodoItem(updatingItem: TodoItem, lastKnownRevision: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
        let todoItemForResponse = TodoItemForResponse(updatingItem)
        
        guard let url = URL(string: "\(Constants.baseURL)/list/\(todoItemForResponse.id)") else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }
        
        guard let body = try? JSONEncoder().encode(Response(element: todoItemForResponse, list: nil, revision: nil)) else {
            completion(.failure(JSONErros.serializationError))
            return
        }
        
        guard let request = createRequest(with: url, httpMethod: .put, httpBody: body, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.invalidRequest))
            return
        }
        
        let task = createTask(with: request) { result in
            switch result {
            case .success(let response):
                guard let revision = response.revision else {
                    completion(.failure(NetworkErrors.noResponseData))
                    return
                }
                
                completion(.success(revision))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        networkServiceQueue.async {
            task.resume()
        }
    }
    
    func deleteTodoItem(with id: String, lastKnownRevision: Int32, completion: @escaping (Result<Int32, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/list/\(id)") else {
            completion(.failure(NetworkErrors.invalidURL))
            return
        }
        
        guard let request = createRequest(with: url, httpMethod: .delete, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.invalidRequest))
            return
        }
        
        let task = createTask(with: request) { result in
            switch result {
            case .success(let response):
                guard let revision = response.revision else {
                    completion(.failure(NetworkErrors.noResponseData))
                    return
                }
                
                completion(.success(revision))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        networkServiceQueue.async {
            task.resume()
        }
    }
}

// MARK: - Support Functions
extension NetworkService {
    private func createRequest(with url: URL, httpMethod: HTTPMethods, httpBody: Data? = nil, revision: Int32? = nil) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue(Constants.headerBearerTokenValue, forHTTPHeaderField: Constants.headerBearerTokenField)
        
        if let httpBody = httpBody {
            request.setValue(Constants.headerContentTypeValue, forHTTPHeaderField: Constants.headerContentTypeField)
            request.httpBody = httpBody
        }
        
        if let revision = revision {
            request.setValue("\(revision)", forHTTPHeaderField: Constants.headerRevisionField)
        }
        
        request.timeoutInterval = Constants.timeoutInterval
        
        return request
    }
    
    private func createTask(with request: URLRequest, completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionTask {
        let task = customSession.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                completion(.failure(NetworkErrors.networkError))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(error ?? NetworkErrors.unknownError))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(NetworkErrors.invalidRequest))
                return
            }
            
            guard let networkResponse = try? JSONDecoder().decode(Response.self, from: data) else {
                completion(.failure(JSONErros.deserializationError))
                return
            }
            
            completion(.success(networkResponse))
        }
        
        return task
    }
}

// MARK: Constants
extension NetworkService {
    private enum HTTPMethods: String {
        case get = "GET"
        case patch = "PATCH"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }

    private enum Constants {
        static let baseURL = "https://beta.mrdekk.ru/todobackend"
        static let queueLabel = "networkServiceQueue"
        static let headerContentTypeField = "Content-Type"
        static let headerContentTypeValue = "application/json"
        static let headerRevisionField = "X-Last-Known-Revision"
        static let headerBearerTokenField = "Authorization"
        static let headerBearerTokenValue = "Bearer semihistoric"
        static let timeoutInterval: Double = 5
    }
}
