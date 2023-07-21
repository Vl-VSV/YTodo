//
//  TodoListSwiftUIViewController.swift
//  YTodo
//
//  Created by Vlad V on 20.07.2023.
//

import UIKit
import SwiftUI

class TodoListSwiftUIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addSwiftUIView()
        title = "Test Title"
    }
    
    func addSwiftUIView() {
        var swiftUIView = TodoListView()
        swiftUIView.delegate = self
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)

        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        hostingController.didMove(toParent: self)
    }
}

extension TodoListSwiftUIViewController: TodoListSwiftUIProtocol {
    func clickOnCell(_ item: TodoItem, saveService: SaveService) {
        let todoVC = TodoViewController(saveService: saveService, todo: item)
        let navigationController = UINavigationController(rootViewController: todoVC)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)
    }
    
    func clickOnAddButton(saveService: SaveService) {
        let todoVC = TodoViewController(saveService: saveService)
        let navigationController = UINavigationController(rootViewController: todoVC)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)
    }
}
