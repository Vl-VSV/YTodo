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
    
    //MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            
            Button {
                
            } label: {
                if (item.isCompleted) {
                    Image(ImageAssets.complete)
                        .foregroundColor(ColorPalette.green)
                } else if (item.priority == .high) {
                    Image(ImageAssets.incompleteRed)
                        .foregroundColor(ColorPalette.red)
                } else {
                    Image(ImageAssets.incomplete)
                        .foregroundColor(ColorPalette.tertiary)
                }
            }
           
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    if item.priority == .low {
                        Image(ImageAssets.priorityLow)
                    } else if item.priority == .high {
                        Image(ImageAssets.priorityHigh)
                    }

                    Text(item.text).strikethrough(item.isCompleted, color: ColorPalette.tertiary)
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
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
struct TodoItemCell_Previews: PreviewProvider {
    func test(item: TodoItem) {}
    
    static var previews: some View {
        TodoItemCell(item: todoItems[1])
            .previewLayout(.sizeThatFits)
    }
}
