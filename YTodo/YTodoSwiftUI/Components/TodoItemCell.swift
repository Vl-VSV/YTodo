//
//  TodoItemCell.swift
//  YTodoSwiftUI
//
//  Created by Vlad V on 16.07.2023.
//

import SwiftUI

struct TodoItemCell: View {
    //MARK: - Properties
    var item: TodoItem
    let onChangeCopletion: (TodoItem) -> Void
    
    //MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            Image(item.isCompleted ? ImageAssets.complete : (item.priority == .high ? ImageAssets.incompleteRed : ImageAssets.incomplete))
                .foregroundColor(item.isCompleted ? ColorPalette.green : (item.priority == .high) ? ColorPalette.red : ColorPalette.tertiary)
                .onTapGesture {
                    onChangeCopletion(item)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    if item.priority == .low {
                        Image(ImageAssets.priorityLow)
                    } else if item.priority == .high {
                        Image(ImageAssets.priorityHigh)
                    }
                    
                    Text(item.text)
                        .lineLimit(3)
                        .strikethrough(item.isCompleted, color: ColorPalette.tertiary)
                        .foregroundColor(item.isCompleted ? ColorPalette.tertiary : Color.primary)
                }
                if let deadline = item.deadline {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(deadline.formatted(.dateTime.day().month())).strikethrough(item.isCompleted)
                    }
                    .foregroundColor(ColorPalette.tertiary)
                }
            }
            .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ColorPalette.gray)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Preview
struct TodoItemCell_Previews: PreviewProvider {
    static func test(_ item: TodoItem) {
        print("Test changing completion of: \(item)")
    }

    static var previews: some View {
        TodoItemCell(item: TodoItem(text: "Smth to do", priority: .high, isCompleted: false, dateOfCreation: .now), onChangeCopletion: test)
            .previewLayout(.sizeThatFits)
    }
}
