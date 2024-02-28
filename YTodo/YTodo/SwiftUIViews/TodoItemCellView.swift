//
//  TodoItemCellView.swift
//  YTodo
//
//  Created by Vlad V on 20.07.2023.
//

import SwiftUI

struct TodoItemCellView: View {
    //MARK: - Properties
    var item: TodoItem
    let onChangeCopletion: (TodoItem) -> Void
    
    //MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            Image(item.isCompleted ? ImageAssetsSwiftUI.complete : (item.priority == .high ? ImageAssetsSwiftUI.incompleteRed : ImageAssetsSwiftUI.incomplete))
                .foregroundColor(item.isCompleted ? ColorPaletteSwiftUI.green : (item.priority == .high) ? ColorPaletteSwiftUI.red : ColorPaletteSwiftUI.tertiary)
                .onTapGesture {
                    onChangeCopletion(item)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    if item.priority == .low {
                        Image(ImageAssetsSwiftUI.priorityLow)
                    } else if item.priority == .high {
                        Image(ImageAssetsSwiftUI.priorityHigh)
                    }
                    
                    Text(item.text)
                        .lineLimit(3)
                        .strikethrough(item.isCompleted, color: ColorPaletteSwiftUI.tertiary)
                        .foregroundColor(item.isCompleted ? ColorPaletteSwiftUI.tertiary : Color.primary)
                }
                if let deadline = item.deadline {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(deadline.formatted(.dateTime.day().month())).strikethrough(item.isCompleted)
                    }
                    .foregroundColor(ColorPaletteSwiftUI.tertiary)
                }
            }
            .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ColorPaletteSwiftUI.gray)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 20)
    }
}

struct TodoItemCellView_Previews: PreviewProvider {
    static func test(_ item: TodoItem) {}
    
    static var previews: some View {
        TodoItemCellView(item: TodoItem(text: "Test text", priority: .high, isCompleted: false, dateOfCreation: .now), onChangeCopletion: test)
    }
}
