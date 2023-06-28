//
//  TodoListViewController.swift
//  YTodo
//
//  Created by Vlad V on 26.06.2023.
//

import UIKit

protocol updateTable {
    func updateData()
}


class TodoListViewController: UIViewController {
    
    private var hideCompletedItems = false
    private var fileCache: FileCache = FileCache()
    
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
        loadDate()
        
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
    
    // MARK: - Functions
    private func loadDate() {
        DispatchQueue.main.async {
            do{
                try self.fileCache.loadCSV(from: "SavedItems.csv")
            } catch {
                print(error)
            }
            self.tableView.reloadData()
        }
    }
    
    private func saveData() {
        DispatchQueue.main.async {
            do{
                try self.fileCache.saveCSV(to: "SavedItems.csv")
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Handlers
    @objc private func addButtonTapped() {
        let todoVC = TodoViewController(fileCache: fileCache)
        todoVC.delegate = self
        let navigationController = UINavigationController(rootViewController: todoVC)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        hideCompletedItems.toggle()
        tableView.reloadData()
    }
    
    @objc private func changeCompletion(at indexPath: IndexPath) {
        var selectedTodo = hideCompletedItems ? fileCache.todoItems.filter { !$0.isCompleted }[indexPath.row] : fileCache.todoItems[indexPath.row]
        selectedTodo.isCompleted.toggle()
        fileCache.update(at: selectedTodo.id, to: selectedTodo)
        tableView.reloadData()
        do {
            try fileCache.saveCSV(to: "SavedItems.csv")
        } catch {
            print(error)
        }
    }
    
    @objc private func goToDetailView(at indexPath: IndexPath) {
        let selectedTodo = hideCompletedItems ? fileCache.todoItems.filter { !$0.isCompleted }[indexPath.row] : fileCache.todoItems[indexPath.row]
        print(selectedTodo)
        let todoVC = TodoViewController(fileCache: fileCache, todo: selectedTodo)
        todoVC.delegate = self
        let navigationController = UINavigationController(rootViewController: todoVC)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)
    }
    
    @objc private func deleteItem(at indexPath: IndexPath) {
        let selectedTodo = hideCompletedItems ? fileCache.todoItems.filter { !$0.isCompleted }[indexPath.row] : fileCache.todoItems[indexPath.row]
        fileCache.delete(withId: selectedTodo.id)
        saveData()
        tableView.reloadData()
    }
}

// MARK: - Extension for Table
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideCompletedItems {
            return fileCache.todoItems.filter { !$0.isCompleted }.count
        } else {
            return fileCache.todoItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TodoItemCell()
        
        if hideCompletedItems {
            let uncompletedItems = fileCache.todoItems.filter { !$0.isCompleted }
            cell.configure(with: uncompletedItems[indexPath.row])
        } else {
            cell.configure(with: fileCache.todoItems[indexPath.row])
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
        
        label.text = "Выполнено - \(fileCache.todoItems.filter{$0.isCompleted == true}.count)"
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedTodo = hideCompletedItems ? fileCache.todoItems.filter { !$0.isCompleted }[indexPath.row] : fileCache.todoItems[indexPath.row]
        
        
        let previewProvider: () -> UIViewController? = { [weak self] in
            let todoVC = TodoViewController(fileCache: self!.fileCache, todo: selectedTodo)
            let navigationController = UINavigationController(rootViewController: todoVC)
            navigationController.modalPresentationStyle = .popover
            return navigationController
        }

        let actionsProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { [weak self] _ in
                self?.deleteItem(at: indexPath)
            }

            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.goToDetailView(at: indexPath)
            }

            return UIMenu(title: "", children: [deleteAction, editAction])
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider, actionProvider: actionsProvider)
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
    }
}

extension TodoListViewController: updateTable {
    func updateData() {
        tableView.reloadData()
    }
}
