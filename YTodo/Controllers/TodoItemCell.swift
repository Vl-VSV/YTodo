//
//  TodoItemCell.swift
//  YTodo
//
//  Created by Vlad V on 26.06.2023.
//

import UIKit

class TodoItemCell: UITableViewCell {
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let deadlineIcon: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 14))))
        image.tintColor = ColorPalette.tertiary
        return image
    }()
    
    private let arrowIcon: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14, weight: .heavy))))
        image.tintColor = ColorPalette.gray
        return image
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "14 july"
        label.font = .systemFont(ofSize: 15)
        label.textColor = ColorPalette.tertiary
        return label
    }()
    
    private let priorityIcon: UIImageView = {
        let image = UIImageView(image: ImageAssets.priorityHigh)
        image.sizeToFit()
        return image
    }()
    
    private let priorityStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()
    
    private let deadlineStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        return stack
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private let statusImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "circle"))
        image.tintColor = ColorPalette.separator
        return image
    }()
    
    // MARK: - Setup
    private func setupViews() {
        separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        
        deadlineStack.addArrangedSubview(deadlineIcon)
        deadlineStack.addArrangedSubview(deadlineLabel)
        
        priorityStack.addArrangedSubview(priorityIcon)
        priorityStack.addArrangedSubview(titleLabel)
        
        labelsStack.addArrangedSubview(priorityStack)
        labelsStack.addArrangedSubview(deadlineStack)
        
        addSubview(statusImage)
        addSubview(labelsStack)
        addSubview(arrowIcon)
        
        statusImage.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false
        priorityIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            statusImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusImage.widthAnchor.constraint(equalToConstant: 24),
            statusImage.heightAnchor.constraint(equalToConstant: 24),
            statusImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            labelsStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            labelsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            labelsStack.leadingAnchor.constraint(equalTo: statusImage.trailingAnchor, constant: 12),
            labelsStack.trailingAnchor.constraint(equalTo: arrowIcon.leadingAnchor, constant: -16),
            
            arrowIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            arrowIcon.widthAnchor.constraint(equalToConstant: 7),
            arrowIcon.heightAnchor.constraint(equalToConstant: 12),
            
            priorityIcon.widthAnchor.constraint(equalToConstant: 12),
            priorityIcon.heightAnchor.constraint(equalToConstant: 16),
            
        ])
    }
    
    // MARK: - Configuration
    func configure(with item: TodoItem) {
        titleLabel.text = item.text
        
        if item.isCompleted {
            statusImage.image = UIImage(systemName: "checkmark.circle.fill")
            statusImage.tintColor = ColorPalette.green
            
            let str = NSMutableAttributedString(string: item.text)
            str.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: str.length))
            titleLabel.attributedText = str
            titleLabel.textColor = ColorPalette.tertiary
        } else if item.priority == .high {
            statusImage.tintColor = ColorPalette.red
        }
        
        if let deadline = item.deadline {
            deadlineLabel.text = "\(deadline.formatted(.dateTime.day().month(.wide)))"
        } else {
            deadlineStack.isHidden = true
        }
        
        switch item.priority {
        case .high:
            priorityIcon.image = ImageAssets.priorityHigh
        case .normal:
            priorityIcon.isHidden = true
        case .low:
            priorityIcon.image = ImageAssets.priorityLow
        }
        
    }
    
}
