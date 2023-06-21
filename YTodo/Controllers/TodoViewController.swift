//
//  TodoViewController.swift
//  YTodo
//
//  Created by Vlad V on 18.06.2023.
//

import UIKit

// MARK: - Color Palette
enum ColorPalette {
    static let backPrimary = UIColor(named: "BackPrimary")
    static let backSecondary = UIColor(named: "BackSecondary")
    static let separator = UIColor(named: "Separator")
    static let tertiary = UIColor(named: "Tertiary")
    static let labelPrimary = UIColor(named: "LabelPrimary")
    static let blue = UIColor(named: "Blue")
}

// MARK: - Image Assets
enum ImageAssets {
    static let priorityLow = UIImage(named: "PriorityLow")
    static let priorityHigh = UIImage(named: "PriorityHigh")
}

// MARK: - UIConstants
enum UIConstants {
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

// MARK: - Todo View Controller
class TodoViewController: UIViewController {
    
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
    }
    
    // MARK: - Views var
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = ColorPalette.backSecondary
        textView.layer.cornerRadius = UIConstants.cornerRadius
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = ColorPalette.tertiary
        textView.text = "Что надо сделать?"
        textView.textContainerInset = UIEdgeInsets(top: UIConstants.textViewContainerTopPadding,
                                                   left: UIConstants.textViewContainerLeftPadding,
                                                   bottom: UIConstants.textViewContainerBottomPadding,
                                                   right: UIConstants.textViewContainerRightPadding)
        textView.textAlignment = .left
        textView.keyboardDismissMode = .onDrag
        textView.isEditable = true
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var addNewTodoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIConstants.stackViewSpacing
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var importancePickerView: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["", "нет", ""])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.setImage(ImageAssets.priorityLow, forSegmentAt: 0)
        segmentedControl.setImage(ImageAssets.priorityHigh, forSegmentAt: 2)
        return segmentedControl
    }()
    
    private lazy var importanceStackView: UIStackView = {
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
    
    private lazy var deadlineLabel: UILabel = {
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
    
    private lazy var deadlineLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var deadlineSwitchView: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.addTarget(self, action: #selector(deadlineSwitchTapped), for: .valueChanged)
        deadlineSwitch.isEnabled = false
        return deadlineSwitch
    }()
    
    private lazy var deadlineStackView: UIStackView = {
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
    
    private lazy var settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.backgroundColor = ColorPalette.backSecondary
        stackView.layer.cornerRadius = UIConstants.cornerRadius
        return stackView
    }()
    
    private lazy var dividerView: UIView = {
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
        button.configuration = .plain()
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
        
        self.deadlineDateLabel.isHidden = true
        self.secondDividerView.isHidden = true
        self.datePicker.isHidden = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addNewTodoStackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        importanceStackView.translatesAutoresizingMaskIntoConstraints = false
        importancePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        ])
    }
    
    // MARK: - Handlers
    @objc private func textViewChanged() {
        textView.textColor = UIColor(named: "LabelPrimary")
        print("Delete Tapped")
    }
    
    @objc private func saveButtonTapped() {
        print("Save Tapped")
    }
    
    @objc private func cancelButtonTapped() {
        print("Cancel Tapped")
    }
    
    @objc private func deleteButtonTapped() {
        print("Delete Tapped")
    }
    
    @objc private func deadlineSwitchTapped() {
        print("Switch Tapped")
        
        UIView.transition(with: datePicker, duration: 1, options: [], animations: {
            self.datePicker.isHidden = !self.deadlineSwitchView.isOn
        })
        
        UIView.transition(with: secondDividerView, duration: 1, options: [], animations: {
            self.secondDividerView.isHidden = !self.deadlineSwitchView.isOn
        })
        
        UIView.transition(with: deadlineDateLabel, duration: 1, options: [], animations: {
            self.deadlineDateLabel.isHidden = !self.deadlineSwitchView.isOn
        })
    }
    
    @objc private func deadlineDateLabelTapped() {
        UIView.transition(with: datePicker, duration: 1) {
            self.datePicker.isHidden = false
        }
    }
    
    @objc func deadlineDateChanged(sender: UIDatePicker) {
        deadlineDateLabel.text = "\(sender.date.formatted(.dateTime.day().month().year()))"
        UIView.transition(with: datePicker, duration: 1) {
            self.datePicker.isHidden = true
        }
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
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
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = ColorPalette.tertiary
        }
    }
}
