//
//  TodoViewController.swift
//  YTodo
//
//  Created by Vlad V on 18.06.2023.
//

import UIKit

// MARK: - Todo View Controller
class TodoViewController: UIViewController {
    
    private var scrollVeiwBottomConstraint: NSLayoutConstraint?
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        
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
        
        static let deleteButtonHeight: CGFloat = 56
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.backPrimary
        title = "Дело"
        
        textView.delegate = self
        
        setupNavigationBar()
        setupSubviews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties
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
    
    private let importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let importancePickerView: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["", "нет", ""])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.setImage(ImageAssets.priorityLow, forSegmentAt: 0)
        segmentedControl.setImage(ImageAssets.priorityHigh, forSegmentAt: 2)
        return segmentedControl
    }()
    
    private let importanceStackView: UIStackView = {
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
        label.text = "\(Date().formatted(.dateTime.day().month().year(.defaultDigits)))"
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
        deadlineSwitch.addTarget(self, action: #selector(UpdateDate), for: .valueChanged)
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
//        stackView.alignment = .center
        stackView.backgroundColor = ColorPalette.backSecondary
        stackView.layer.cornerRadius = UIConstants.cornerRadius
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.separator
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()
    
    private lazy var secondDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.separator
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
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
        
        importanceStackView.addArrangedSubview(importanceLabel)
        importanceStackView.addArrangedSubview(importancePickerView)
        
        deadlineLabelsStackView.addArrangedSubview(deadlineLabel)
        deadlineLabelsStackView.addArrangedSubview(deadlineDateLabel)
        
        deadlineStackView.addArrangedSubview(deadlineLabelsStackView)
        deadlineStackView.addArrangedSubview(deadlineSwitchView)
        
        settingsStackView.addArrangedSubview(importanceStackView)
        settingsStackView.addArrangedSubview(dividerView)
        settingsStackView.addArrangedSubview(deadlineStackView)
        settingsStackView.addArrangedSubview(secondDividerView)
        settingsStackView.addArrangedSubview(datePicker)
        
        secondDividerView.isHidden = true
        datePicker.isHidden = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addNewTodoStackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        importanceStackView.translatesAutoresizingMaskIntoConstraints = false
        importancePickerView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            bottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            addNewTodoStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: UIConstants.addNewTodoStackViewLeadingPadding),
            addNewTodoStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: UIConstants.addNewTodoStackViewTrailingPadding),
            addNewTodoStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: UIConstants.addNewTodoStackViewTopPadding),
            addNewTodoStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            addNewTodoStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.textViewHeight),
            
            settingsStackView.leadingAnchor.constraint(equalTo: addNewTodoStackView.leadingAnchor),
            settingsStackView.trailingAnchor.constraint(equalTo: addNewTodoStackView.trailingAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: UIConstants.deleteButtonHeight),
            
            importancePickerView.widthAnchor.constraint(equalToConstant: UIConstants.segmentedControlWidth),
            importancePickerView.heightAnchor.constraint(equalToConstant: UIConstants.segmentedControlHeight),
            
            datePicker.widthAnchor.constraint(equalTo: settingsStackView.widthAnchor)
        ])
        
        self.scrollVeiwBottomConstraint = bottomConstraint
        
        UpdateDate()
    }
    
    // MARK: - Handlers
    @objc private func saveButtonTapped() {
        print("Save Tapped")
    }
    
    @objc private func cancelButtonTapped() {
        print("Cancel Tapped")
    }
    
    @objc private func deleteButtonTapped() {
        print("Delete Tapped")
    }
    
    @objc private func UpdateDate() {
        print("Switch Tapped")
        
        if deadlineSwitchView.isOn == true {
            UIView.animate(withDuration: 1) {
                self.deadlineDateLabel.isHidden = !self.deadlineSwitchView.isOn
            }
        } else {
            UIView.animate(withDuration: 1) {
                self.deadlineDateLabel.isHidden = !self.deadlineSwitchView.isOn
                self.datePicker.isHidden = !self.deadlineSwitchView.isOn
                self.secondDividerView.isHidden = !self.deadlineSwitchView.isOn
            }
        }
        
    }
    
    @objc private func deadlineDateLabelTapped() {
        UIView.animate(withDuration: 1) {
            self.datePicker.isHidden = false
            self.secondDividerView.isHidden = false
        }
    }
    
    @objc private func deadlineDateChanged(sender: UIDatePicker) {
        deadlineDateLabel.text = "\(sender.date.formatted(.dateTime.day().month().year()))"
        UIView.animate(withDuration: 1) {
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
            keyboardConstant = height + 16
        } else {
            keyboardConstant = 16
        }
        scrollVeiwBottomConstraint?.constant = -keyboardConstant
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
        }
    }
    
}

// MARK: - UITextViewDelegate
extension TodoViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textView.textColor = ColorPalette.labelPrimary
        deleteButton.isEnabled = true
        deadlineSwitchView.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "Что надо сделать?"{
            textView.text = "Что надо сделать?"
            textView.textColor = ColorPalette.tertiary
            deadlineSwitchView.setOn(false, animated: true)
            UpdateDate()
        }
    }
}
