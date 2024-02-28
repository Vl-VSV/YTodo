//
//  TodoListView.swift
//  YTodoSwiftUI
//
//  Created by Vlad V on 16.07.2023.
//

import SwiftUI

struct TodoListView: View {
    //MARK: - Properties
    @State private var isPresentingTodoView: Bool = false
    @State private var hideCompletedItems: Bool = false
    @State private var selectedTodo: TodoItem?
    
    @State private var todoItems: [TodoItem] = [
        TodoItem(text: "Go to the cinema", priority: .normal, isCompleted: false, dateOfCreation: .now),
        TodoItem(text: "Complete the HW", priority: .high, isCompleted: true, dateOfCreation: .now),
        TodoItem(text: "Buy the car", priority: .normal, deadline: .now + 72000, isCompleted: false, dateOfCreation: .now),
        TodoItem(text: "Clean the room", priority: .low, isCompleted: false, dateOfCreation: .now),
        TodoItem(text: "Make a report", priority: .high, deadline: .now + 72000, isCompleted: true, dateOfCreation: .now),
        TodoItem(text: "Smth very long, long, long, long, long, long, long, long, long, long, long, long, long, long, long, long, long, long", priority: .high, deadline: .now + 72000, isCompleted: true, dateOfCreation: .now)
    ]
    
    // MARK: - Function
    func changeCompletion(_ item: TodoItem) {
        if let index = todoItems.firstIndex(where: {$0.id == item.id}) {
            changeCompletion(itemIndex: index)
        }
    }
    
    func changeCompletion(itemIndex: Int) {
        todoItems[itemIndex].isCompleted.toggle()
    }
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    Section(header: headerView) {
                        ForEach(hideCompletedItems ? todoItems.filter {!$0.isCompleted} : todoItems, id: \.id) { item in
                            VStack(spacing: 0) {
                                TodoItemCell(item: item, onChangeCopletion: changeCompletion)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTodo = item
                                        isPresentingTodoView.toggle()
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            changeCompletion(item)
                                        } label: {
                                            Image(systemName: "checkmark.circle")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                Divider()
                                    .padding(.leading, 38)
                                    .padding(.trailing, -100)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
                        }
                        Button("Новое") {
                            selectedTodo = nil
                            isPresentingTodoView.toggle()
                        }
                        .foregroundColor(ColorPalette.tertiary)
                        .padding(.vertical, 12)
                        .padding(.leading, 32)
                    }
                } //: LIST
                .scrollContentBackground(.hidden)
                .background(ColorPalette.backPrimary)
                .listStyle(.insetGrouped)
                
                
                Button {
                    selectedTodo = nil
                    isPresentingTodoView = true
                } label: {
                    Image(ImageAssets.newTodoButton)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .shadow(color:ColorPalette.newTodoButtonShadow, radius: 8, x: 0, y: 8)
                }
            } //: ZSTACK
            
            .sheet(isPresented: $isPresentingTodoView) {
                TodoView(item: $selectedTodo)
            }
            .navigationTitle("Мои дела")
            .navigationBarTitleDisplayMode(.large)
        } //: NAVSTACK
        .onAppear {
            UINavigationBar.appearance().layoutMargins.left = 32
        }
    }
    
    // MARK: - View Properties
    private var headerView: some View {
        HStack {
            Text("Выполнено - \(todoItems.filter { $0.isCompleted }.count)")
                .font(.callout)
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    hideCompletedItems.toggle()
                }
            } label: {
                Text(hideCompletedItems ? "Показать" : "Скрыть")
                    .font(.body)
                    .bold()
            }
        }
        .padding(.horizontal, -8)
        .textCase(.none)
    }
}

//MARK: - Preview
struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
