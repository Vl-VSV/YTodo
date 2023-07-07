//
//  TodoListViewController.swift
//  YTodo
//
//  Created by Vlad V on 26.06.2023.
//

import UIKit

protocol UpdateTable: AnyObject {
    func updateData()
    func startLoading()
    func completeLoading()
}

protocol CellTapped: AnyObject {
    func changeCompletion(_ taskCell: TodoItemCell)
}

class TodoListViewController: UIViewController {
    
    private var hideCompletedItems = true
    private var saveService: SaveService = SaveService()
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        let viewb = UIView()
        viewb.backgroundColor = ColorPalette.backPrimary
        table.backgroundView = viewb
        table.showsVerticalScrollIndicator = false
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
        
        saveService.delegate = self
        saveService.loadData()
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            addTodoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTodoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54),
            addTodoButton.widthAnchor.constraint(equalToConstant: 44),
            addTodoButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    // MARK: - Functions
    
    private func showLoadingView() {
        DispatchQueue.main.async {
            let nactivityIndicator = UIActivityIndicatorView(style: .medium)
            let barButton = UIBarButtonItem(customView: nactivityIndicator)
            self.navigationItem.setRightBarButton(barButton, animated: true)
            nactivityIndicator.startAnimating()
        }
        
    }

    private func hideLoadingView() {
        DispatchQueue.main.async {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    // MARK: - Handlers
    @objc private func addButtonTapped() {
        let todoVC = TodoViewController(saveService: saveService)
        todoVC.delegate = self
        let navigationController = UINavigationController(rootViewController: todoVC)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)

    }
    
    @objc private func filterButtonTapped() {
        hideCompletedItems.toggle()
        UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)

    }
    
    @objc private func changeCompletion(at indexPath: IndexPath) {
        var selectedTodo = hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }[indexPath.row] : saveService.todoItems[indexPath.row]
        selectedTodo.isCompleted.toggle()
        saveService.update(selectedTodo)
    }
    
    @objc private func goToDetailView(at indexPath: IndexPath) {
        let selectedTodo = hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }[indexPath.row] : saveService.todoItems[indexPath.row]
        let todoVC = TodoViewController(saveService: saveService, todo: selectedTodo)
        todoVC.delegate = self
        let navigationController = UINavigationController(rootViewController: todoVC)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)
    }
    
    @objc private func deleteItem(at indexPath: IndexPath) {
        let selectedTodo = hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }[indexPath.row] : saveService.todoItems[indexPath.row]
        saveService.delete(withId: selectedTodo.id)
    }
}

// MARK: - Extension for Table
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideCompletedItems {
            return saveService.todoItems.filter { !$0.isCompleted }.count + 1
        } else {
            return saveService.todoItems.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == (hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }.count : saveService.todoItems.count)) {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            var contentConfig = cell.defaultContentConfiguration()
            contentConfig.text = "Новое"
            contentConfig.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 54, bottom: 16, trailing: 0)
            contentConfig.textProperties.color = ColorPalette.tertiary ?? .green
            cell.contentConfiguration = contentConfig
            return cell
        }
        
        let cell = TodoItemCell()
        
        if hideCompletedItems {
            let uncompletedItems = saveService.todoItems.filter { !$0.isCompleted }
            cell.configure(with: uncompletedItems[indexPath.row])
        } else {
            cell.configure(with: saveService.todoItems[indexPath.row])
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == (hideCompletedItems ? saveService.todoItems.filter {!$0.isCompleted}.count : saveService.todoItems.count)) {
            addButtonTapped()
        } else {
            let selectedTodo = hideCompletedItems ? saveService.todoItems.filter {!$0.isCompleted}[indexPath.row] : saveService.todoItems[indexPath.row]
            let todoVC = TodoViewController(saveService: saveService, todo: selectedTodo)
            todoVC.delegate = self
            let navigationController = UINavigationController(rootViewController: todoVC)
            navigationController.modalPresentationStyle = .popover
            self.present(navigationController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let stack = UIStackView()
        let label = UILabel()
        let button = UIButton()
        
        stack.axis = .horizontal
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true
        
        label.text = "Выполнено - \(saveService.todoItems.filter {$0.isCompleted == true}.count)"
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
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.changeCompletion(at: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = ColorPalette.green
        action.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let info = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.goToDetailView(at: indexPath)
            completionHandler(true)
        }
        info.backgroundColor = ColorPalette.lightGray
        info.image = UIImage(systemName: "info.circle.fill")
        
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            self?.deleteItem(at: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = ColorPalette.red
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete, info])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == (hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }.count : saveService.todoItems.count ) {
            return nil
        }
        let selectedTodo = hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }[indexPath.row] : saveService.todoItems[indexPath.row]
        
        let previewProvider: () -> UIViewController? = { [weak self] in
            guard let self = self else { return nil }
            let todoVC = TodoViewController(saveService: self.saveService, todo: selectedTodo)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == (hideCompletedItems ? saveService.todoItems.filter { !$0.isCompleted }.count : saveService.todoItems.count)) {
            return false
        }
        return true
    }
}

extension TodoListViewController: UpdateTable {
    func updateData() {
        UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    func startLoading() {
        self.showLoadingView()
    }
    
    func completeLoading() {
        self.hideLoadingView()
    }
}

extension TodoListViewController: CellTapped {
    func changeCompletion(_ taskCell: TodoItemCell) {
        guard let indexPath = tableView.indexPath(for: taskCell) else { return }
        changeCompletion(at: indexPath)
    }
}
