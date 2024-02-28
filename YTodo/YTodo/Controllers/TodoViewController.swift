//
//  TodoViewController.swift
//  YTodo
//
//  Created by Vlad V on 18.06.2023.
//

import UIKit

// MARK: - Todo View Controller
class TodoViewController: UIViewController {
    
    // MARK: - Properties
    private var scrollVeiwBottomConstraint: NSLayoutConstraint?
    var saveService: SaveService
    var todo: TodoItem
    weak var delegate: UpdateTable?
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        
        static let scrollViewBottomPadding: CGFloat = 16
        
        static let stackViewSpacing: CGFloat = 16
        
        static let addNewTodoStackViewTopPadding: CGFloat = 16
        static let addNewTodoStackViewLeadingPadding: CGFloat = 16
        static let addNewTodoStackViewTrailingPadding: CGFloat = -16
        
        static let textViewHeight: CGFloat = 120
        static let textViewContainerTopPadding: CGFloat = 17
        static let textViewContainerLeftPadding: CGFloat = 16
        static let textViewContainerBottomPadding: CGFloat = 17
        static let textViewContainerRightPadding: CGFloat = 16
        
        static let importanceStackViewContainerTopPaddding: CGFloat = 10
        static let importanceStackViewContainerLeftPaddding: CGFloat = 16
        static let importanceStackViewContainerBottomPaddding: CGFloat = 16
        static let importanceStackViewContainerRightPaddding: CGFloat = 12
        
        static let deadlineStackViewContainerTopPaddding: CGFloat = 16
        static let deadlineStackViewContainerLeftPaddding: CGFloat = 16
        static let deadlineStackViewContainerBottomPaddding: CGFloat = 16
        static let deadlineStackViewContainerRightPaddding: CGFloat = 12
        
        static let datePickerContainerTopPaddding: CGFloat = 16
        static let datePickerContainerLeftPaddding: CGFloat = 16
        static let datePickerContainerBottomPaddding: CGFloat = 0
        static let datePickerContainerRightPaddding: CGFloat = 16
        
        static let segmentedControlWidth: CGFloat = 150
        static let segmentedControlHeight: CGFloat = 36
        
        static let dividerHeight: CGFloat = 1
        
        static let deleteButtonHeight: CGFloat = 56
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.backPrimary
        title = "Дело"
        
        textView.delegate = self
        
        setupNavigationBar()
        setupTodoInfo()
        setupSubviews()
        subscribeToKeyboard()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Init
    init(saveService: SaveService, todo: TodoItem = TodoItem(text: "", priority: .normal, isCompleted: false, dateOfCreation: .now)) {
        self.saveService = saveService
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = UIConstants.cornerRadius
        textView.backgroundColor = ColorPalette.backSecondary
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = ColorPalette.tertiary
        textView.text = "Что надо сделать?"
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: UIConstants.textViewContainerTopPadding,
                                                   left: UIConstants.textViewContainerLeftPadding,
                                                   bottom: UIConstants.textViewContainerBottomPadding,
                                                   right: UIConstants.textViewContainerRightPadding)
        return textView
    }()
    
    private let addNewTodoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIConstants.stackViewSpacing
        stackView.distribution = .fill
        return stackView
    }()
    
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var priorityPickerView: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["", "нет", ""])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.setImage(ImageAssets.priorityLow, forSegmentAt: 0)
        segmentedControl.setImage(ImageAssets.priorityHigh, forSegmentAt: 2)
        segmentedControl.addTarget(self, action: #selector(priorityValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private let priorityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: UIConstants.importanceStackViewContainerTopPaddding,
                                               left: UIConstants.importanceStackViewContainerLeftPaddding,
                                               bottom: UIConstants.importanceStackViewContainerBottomPaddding,
                                               right: UIConstants.importanceStackViewContainerRightPaddding)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Cделать до"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.text = "\(Date(timeIntervalSinceNow: 60*60*24).formatted(.dateTime.day().month().year(.defaultDigits)))"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = ColorPalette.blue
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deadlineDateLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private let deadlineLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var deadlineSwitchView: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        deadlineSwitch.isEnabled = false
        return deadlineSwitch
    }()
    
    private let deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: UIConstants.deadlineStackViewContainerTopPaddding,
                                               left: UIConstants.deadlineStackViewContainerLeftPaddding,
                                               bottom: UIConstants.deadlineStackViewContainerBottomPaddding,
                                               right: UIConstants.deadlineStackViewContainerRightPaddding)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.backgroundColor = ColorPalette.backSecondary
        stackView.layer.cornerRadius = UIConstants.cornerRadius
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.separator
        view.heightAnchor.constraint(equalToConstant: UIConstants.dividerHeight).isActive = true
        view.layer.cornerRadius = UIConstants.cornerRadius
        return view
    }()
    
    private lazy var secondDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.separator
        view.heightAnchor.constraint(equalToConstant: UIConstants.dividerHeight).isActive = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = .now + 60*60*24
        datePicker.minimumDate = .now
        datePicker.preferredDatePickerStyle = .inline
        datePicker.layoutMargins = UIEdgeInsets(top: UIConstants.datePickerContainerTopPaddding,
                                                left: UIConstants.datePickerContainerLeftPaddding,
                                                bottom: UIConstants.datePickerContainerBottomPaddding,
                                                right: UIConstants.datePickerContainerRightPaddding)
        datePicker.addTarget(self, action: #selector(deadlineDateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ColorPalette.backSecondary
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = UIConstants.cornerRadius
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup Functions
    private func setupNavigationBar() {
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveButtonTapped))
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(addNewTodoStackView)
        
        addNewTodoStackView.addArrangedSubview(textView)
        addNewTodoStackView.addArrangedSubview(settingsStackView)
        addNewTodoStackView.addArrangedSubview(deleteButton)
        
        priorityStackView.addArrangedSubview(priorityLabel)
        priorityStackView.addArrangedSubview(priorityPickerView)
        
        deadlineLabelsStackView.addArrangedSubview(deadlineLabel)
        deadlineLabelsStackView.addArrangedSubview(deadlineDateLabel)
        
        deadlineStackView.addArrangedSubview(deadlineLabelsStackView)
        deadlineStackView.addArrangedSubview(deadlineSwitchView)
        
        settingsStackView.addArrangedSubview(priorityStackView)
        settingsStackView.addArrangedSubview(dividerView)
        settingsStackView.addArrangedSubview(deadlineStackView)
        settingsStackView.addArrangedSubview(secondDividerView)
        settingsStackView.addArrangedSubview(datePicker)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addNewTodoStackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        priorityStackView.translatesAutoresizingMaskIntoConstraints = false
        priorityPickerView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = scrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -UIConstants.scrollViewBottomPadding
        )
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bottomConstraint,

            addNewTodoStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: UIConstants.addNewTodoStackViewLeadingPadding),
            addNewTodoStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: UIConstants.addNewTodoStackViewTrailingPadding),
            addNewTodoStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: UIConstants.addNewTodoStackViewTopPadding),
            addNewTodoStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            addNewTodoStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.textViewHeight),
            
            settingsStackView.leadingAnchor.constraint(equalTo: addNewTodoStackView.leadingAnchor),
            settingsStackView.trailingAnchor.constraint(equalTo: addNewTodoStackView.trailingAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: UIConstants.deleteButtonHeight),
            
            priorityPickerView.widthAnchor.constraint(equalToConstant: UIConstants.segmentedControlWidth),
            priorityPickerView.heightAnchor.constraint(equalToConstant: UIConstants.segmentedControlHeight),
            
            datePicker.widthAnchor.constraint(equalTo: settingsStackView.widthAnchor)
        ])
        
        self.scrollVeiwBottomConstraint = bottomConstraint
        updateDate()
    }
    
    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupTodoInfo() {
        if todo.text != "" {
            textView.text = todo.text
            textView.textColor = ColorPalette.labelPrimary
            
            switch todo.priority {
            case .low:
                priorityPickerView.selectedSegmentIndex = 0
            case .normal:
                priorityPickerView.selectedSegmentIndex = 1
            case .high:
                priorityPickerView.selectedSegmentIndex = 2
            }
            if let deadline = todo.deadline {
                deadlineSwitchView.setOn(true, animated: true)
                secondDividerView.isHidden = true
                datePicker.isHidden = true
                deadlineDateLabel.isHidden = false
                deadlineDateLabel.text = "\(deadline.formatted(.dateTime.day().month().year()))"
            }
            deadlineSwitchView.isEnabled = true
            deleteButton.isEnabled = true
        }
    }
    
    // MARK: - Handlers
    @objc private func saveButtonTapped() {
        
        let alert = UIAlertController(title: "Ошибка", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(action)

        todo.text = textView.text
        guard todo.text != "" && todo.text != "Что надо сделать?" else {
            alert.message = "Некоректное описание задачи"
            present(alert, animated: true, completion: nil)
            return
        }
        
        saveService.add(todo)
        
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        saveService.delete(withId: todo.id)
        dismiss(animated: true)
    }
    
    @objc private func updateDate() {
        
        if deadlineSwitchView.isOn == true {
            UIView.animate(withDuration: 0.5) {
                self.deadlineDateLabel.isHidden = false
                self.todo.deadline = Date(timeIntervalSinceNow: 60*60*24)
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.deadlineDateLabel.isHidden = true
                self.datePicker.isHidden = true
                self.secondDividerView.isHidden = true
                self.todo.deadline = nil
            }
        }
    }
    
    @objc private func deadlineDateLabelTapped() {
        UIView.animate(withDuration: 0.5) {
            self.datePicker.isHidden = false
            self.secondDividerView.isHidden = false
        }
    }
    
    @objc private func deadlineDateChanged(sender: UIDatePicker) {
        deadlineDateLabel.text = "\(sender.date.formatted(.dateTime.day().month().year()))"
        todo.deadline = sender.date
        UIView.animate(withDuration: 0.5) {
            self.datePicker.isHidden = true
            self.secondDividerView.isHidden = true
        }
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    @objc private func handleKeyboard(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let height = view.convert(keyboardValue.cgRectValue, to: view.window).height
        let keyboardConstant: CGFloat
        if notification.name == UIResponder.keyboardWillShowNotification {
            keyboardConstant = height + UIConstants.scrollViewBottomPadding
        } else {
            keyboardConstant = UIConstants.scrollViewBottomPadding
        }
        scrollVeiwBottomConstraint?.constant = -keyboardConstant
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
        }
    }
    
    @objc private func priorityValueChanged() {
        switch priorityPickerView.selectedSegmentIndex {
        case 0:
            todo.priority = .low
        case 1:
            todo.priority = .normal
        case 2:
            todo.priority = .high
        default:
            todo.priority = .normal
        }
    }
}

// MARK: - UITextViewDelegate
extension TodoViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Что надо сделать?" {
            textView.text = nil
        }
        textView.textColor = ColorPalette.labelPrimary
        deleteButton.isEnabled = true
        deadlineSwitchView.isEnabled = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = ColorPalette.tertiary
            deadlineSwitchView.setOn(false, animated: true)
            updateDate()
        }
        todo.text = textView.text
    }
}
