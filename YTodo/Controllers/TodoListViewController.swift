//
//  TodoListViewController.swift
//  YTodo
//
//  Created by Vlad V on 26.06.2023.
//

import UIKit

class TodoListViewController: UIViewController {
    
    private var hideCompletedItems = false
    
    // MARK: - Data
    private var todoItems: [TodoItem] = [
        TodoItem(text: "Wash the car", priority: .normal, isCompleted: true, dateOfCreation: .now),
        TodoItem(text: "Clean the room", priority: .high, deadline: Date(timeIntervalSinceNow: 72000), isCompleted: false, dateOfCreation: .now),
        TodoItem(text: "Например, сейчас одна акция «Лукойла» стоит около 5700 рублей. Фьючерс на акции «Лукойла» — это, например, договор между покупателем и продавцом о том, что покупатель купит акции «Лукойла» у продавца по цене 5700 рублей через 3 месяца. При этом не важно, какая цена будет у акций через 3 месяца: цена сделки между покупателем и продавцом все равно останется 5700 рублей. Если реальная цена акции через три месяца не останется прежней, одна из сторон в любом случае понесет убытки.", priority: .normal, isCompleted: false, dateOfCreation: .now),
        TodoItem(text: "Buy the floor", priority: .normal, deadline: Date(timeIntervalSince1970: 72000), isCompleted: false, dateOfCreation: .now),
        TodoItem(text: "Finish homework", priority: .normal, isCompleted: false, dateOfCreation: Date()),
        TodoItem(text: "Go for a run", priority: .low, isCompleted: true, dateOfCreation: Date()),
        TodoItem(text: "Go to the cinema", priority: .low, deadline: .now, isCompleted: true, dateOfCreation: Date()),
        TodoItem(text: "Например, сейчас одна акция «Лукойла» стоит около 5700 рублей. Фьючерс на акции «Лукойла» — это, например, договор между покупателем и продавцом о том, что покупатель купит акции «Лукойла» у продавца по цене 5700 рублей через 3 месяца. При этом не важно, какая цена будет у акций через 3 месяца: цена сделки между покупателем и продавцом все равно останется 5700 рублей. Если реальная цена акции через три месяца не останется прежней, одна из сторон в любом случае понесет убытки.", priority: .high, deadline: .now, isCompleted: true, dateOfCreation: .now),
    ]
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        let viewb = UIView()
        viewb.backgroundColor = ColorPalette.backPrimary
        table.backgroundView = viewb
        return table
    }()
    
    private lazy var addTodoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(ImageAssets.newTodoButton, for: .normal)
        
        button.layer.shadowColor = ColorPalette.newTodoButtonShadow?.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 8
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        return button
    }()

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Мои Дела"
        setupNavigationBar()
        setupSubviews()
        
        view.backgroundColor = ColorPalette.backPrimary
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Setup Functions
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = ColorPalette.backSecondary
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(addTodoButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addTodoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            addTodoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTodoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54),
            addTodoButton.widthAnchor.constraint(equalToConstant: 44),
            addTodoButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    // MARK: - Handlers
    @objc private func addButtonTapped() {
        
    }
    
    @objc private func filterButtonTapped() {
        hideCompletedItems.toggle()
        tableView.reloadData()
    }
    
    @objc private func changeCompletion(at indexPath: IndexPath) {
        let selectedTodo = hideCompletedItems ? todoItems.filter { !$0.isCompleted }[indexPath.row] : todoItems[indexPath.row]
        let index = todoItems.firstIndex(where: {$0.id == selectedTodo.id})
        if let index = index {
            todoItems[index].isCompleted.toggle()
        }
        tableView.reloadData()
    }
    
    @objc private func goToDetailView(at indexPath: IndexPath) {

    }
    
    @objc private func deleteItem(at indexPath: IndexPath) {
        let selectedTodo = hideCompletedItems ? todoItems.filter { !$0.isCompleted }[indexPath.row] : todoItems[indexPath.row]
        let index = todoItems.firstIndex(where: {$0.id == selectedTodo.id})
        if let index = index {
            todoItems.remove(at: index)
        }
        tableView.reloadData()
    }
}

// MARK: - Extension for Table
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideCompletedItems {
            return todoItems.filter { !$0.isCompleted }.count
        } else {
            return todoItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TodoItemCell()
        
        if hideCompletedItems {
            let uncompletedItems = todoItems.filter { !$0.isCompleted }
            cell.configure(with: uncompletedItems[indexPath.row])
        } else {
            cell.configure(with: todoItems[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        changeCompletion(at: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let stack = UIStackView()
        let label = UILabel()
        let button = UIButton()
        
        stack.axis = .horizontal
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true
        
        label.text = "Выполнено - \(todoItems.filter{$0.isCompleted == true}.count)"
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = ColorPalette.tertiary
        
        button.setTitle(hideCompletedItems ? "Показать" : "Скрыть", for: .normal)
        button.setTitleColor(ColorPalette.blue, for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(button)
        
        return stack
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.changeCompletion(at: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = ColorPalette.green
        action.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let info = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.goToDetailView(at: indexPath)
            completionHandler(true)
        }
        info.backgroundColor = ColorPalette.lightGray
        info.image = UIImage(systemName: "info.circle.fill")
        
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.deleteItem(at: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = ColorPalette.red
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete, info])
    }
}

