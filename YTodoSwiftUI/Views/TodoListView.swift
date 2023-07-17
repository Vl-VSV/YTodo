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
    private var selectedTodo: TodoItem?

    //MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    Section(header: headerView) {
                        ForEach(hideCompletedItems ? todoItems.filter {!$0.isCompleted} : todoItems, id: \.id) { item in
                            NavigationLink(destination: TodoView(item: item)) {
                                TodoItemCell(item: item)
                            }
                        }
                        Button("Новое") {
                            
                        }
                        .foregroundColor(ColorPalette.tertiary)
                        .padding(.vertical, 12)
                        .padding(.leading, 36)
                    }
                } //: LIST
                .listStyle(.insetGrouped)
                
                Button {
                    isPresentingTodoView = true
                } label: {
                    Image(ImageAssets.newTodoButton)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .shadow(color:ColorPalette.newTodoButtonShadow, radius: 8, x: 0, y: 8)
                }
            } //: ZSTACK
            .sheet(isPresented: $isPresentingTodoView) {
                TodoView(item: selectedTodo)
            }
            .navigationTitle("Мои дела")
            .navigationBarTitleDisplayMode(.large)
        } //: NAVSTACK
        .onAppear {
            UINavigationBar.appearance().layoutMargins.left = 32
        }
        .background(ColorPalette.backPrimary)
        
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
