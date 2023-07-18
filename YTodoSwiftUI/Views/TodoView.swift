//
//  TodoView.swift
//  YTodoSwiftUI
//
//  Created by Vlad V on 16.07.2023.
//

import SwiftUI

struct TodoView: View {
    //MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    let item: TodoItem?
    
    @State private var todoText: String = "Что надо сделать?"
    @State private var priorityIndex: Int = 1
    @State private var isDeadlineEnabled: Bool = false
    @State private var isShowDatePicker: Bool = false
    @State private var selectedDate: Date = .now + 72000
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextEditor(text: $todoText)
                    .frame(height: 98)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(ColorPalette.backSecondary))
                    .padding(.top)
                    .foregroundColor(todoText == "Что надо сделать?" ? ColorPalette.tertiary : .primary)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Важность")
                        
                        Spacer()
                        
                        Picker("", selection: $priorityIndex) {
                            Image(uiImage: UIImage(named: "PriorityLow")!)
                                .tag(0)
                            Text("нет").bold()
                                .tag(1)
                            Image(uiImage: UIImage(named: "PriorityHigh")!)
                                .tag(2)
                        }
                        .frame(width: 150, height: 36)
                        .pickerStyle(.segmented)
                    } //: HSTACK
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Сделать до")
                            if isDeadlineEnabled {
                                Text(selectedDate.formatted(.dateTime.day().month().year()))
                                    .font(.footnote).bold()
                                    .foregroundColor(ColorPalette.blue)
                                    .onTapGesture {
                                        isShowDatePicker.toggle()
                                    }
                            }
                        }
                        Spacer()
                        Toggle("", isOn: $isDeadlineEnabled)
                            .onChange(of: isDeadlineEnabled) { newValue in
                                if newValue == false {
                                    isShowDatePicker = false
                                }
                            }
                    }//: HSTACK
                    
                    if isShowDatePicker {
                        Divider()
                        DatePicker("Picker", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding(.top, -8)
                            .onChange(of: selectedDate) { newValue in
                                isShowDatePicker = false
                            }
                    }
                } //: VSTACK
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(ColorPalette.backSecondary))
                
                Button {
                    
                } label: {
                    Text("Удалить")
                        .foregroundColor(ColorPalette.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorPalette.backSecondary)
                        )
                }
                
                Spacer()
                
            } //: VSTACK
            .padding(.horizontal)
            .background(ColorPalette.backPrimary)
            
            .navigationTitle("Дело")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("Сохранить")
                            .bold()
                    }
                }
            } //: TOOLBAR
        } //: NAVSTACK
        .onAppear {
            if let item {
                todoText = item.text
                priorityIndex = item.priority == .high ? 2 : (item.priority == .low ? 0 : 1)
                isDeadlineEnabled = item.deadline != nil ? true : false
                selectedDate = item.deadline ?? .now + 72000
            }
            
        }
    }
}

// MARK: - Preview
struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(item: nil)
    }
}
