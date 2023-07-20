//
//  TodoListView.swift
//  YTodo
//
//  Created by Vlad V on 20.07.2023.
//

import SwiftUI

protocol TodoListSwiftUIProtocol {
    func clickOnCell(_ item: TodoItem, saveService: SaveService)
    func clickOnAddButton(saveService: SaveService)
}

struct TodoListView: View {
    // MARK: - Properties
    @StateObject private var saveService = SaveService()
    @State private var hideCompletedItems: Bool = true
    var delegate: TodoListSwiftUIProtocol?
    
    // MARK: - Function
    func changeCompletion(_ item: TodoItem) {
        var newItem = item
        newItem.isCompleted.toggle()
        saveService.update(newItem)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    Section(header: headerView) {
                        ForEach(hideCompletedItems ? saveService.todoItems.filter {!$0.isCompleted} : saveService.todoItems, id: \.id) { item in
                            VStack(spacing: 0) {
                                TodoItemCellView(item: item, onChangeCopletion: changeCompletion)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        delegate?.clickOnCell(item, saveService: saveService)
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
                                            saveService.delete(withId: item.id)
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
                        } //: FOREACH
                        Button("Новое") {
                            delegate?.clickOnAddButton(saveService: saveService)
                        }
                        .foregroundColor(ColorPaletteSwiftUI.tertiary)
                        .padding(.vertical, 12)
                        .padding(.leading, 32)
                    } //: SECTION
                } //: LIST
                
                Button {
                    delegate?.clickOnAddButton(saveService: saveService)
                } label: {
                    Image(ImageAssetsSwiftUI.newTodoButton)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .shadow(color:ColorPaletteSwiftUI.newTodoButtonShadow, radius: 8, x: 0, y: 8)
                }
            } //: ZSTACK
            .navigationTitle("Мои Дела")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProgressView()
                        .opacity(saveService.showActivityIndicator ? 1 : 0)
                }
            }
        } //: NAVSTACK
        .onAppear {
            saveService.loadData()
            UINavigationBar.appearance().layoutMargins.left = 32
        }
    }
    
    // MARK: - View Properties
    private var headerView: some View {
        HStack {
            Text("Выполнено - \(saveService.todoItems.filter { $0.isCompleted }.count)")
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

//MARK: - PREVIEW
struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
