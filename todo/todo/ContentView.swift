//
//  ContentView.swift
//  todo
//
//  Created by Ksenia Zaharova on 17.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var newTaskDescription = ""
    @State private var showingEditSheet = false
    @State private var editingTask: TaskItem?
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        HStack {
                            Button(action: {
                                viewModel.toggleDone(for: task)
                            }) {
                                Image(systemName: task.isDone ? "checkmark.square" : "square")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(task.description)
                                .strikethrough(task.isDone)
                                .foregroundColor(task.isDone ? .gray : .primary)
                            
                            Spacer()
                            
                            Button(action: {
                                editingTask = task
                                showingEditSheet = true
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteTask(at: offsets)
                    }
                    .onMove { offsets, destination in
                        viewModel.moveTask(from: offsets, to: destination)
                    }
                }
                
                HStack {
                    TextField("Новое дело", text: $newTaskDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Добавить") {
                        viewModel.addTask(description: newTaskDescription)
                        newTaskDescription = ""
                    }
                }
                .padding()
            }
            .navigationTitle("TO-DOшечка")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Загрузить") {
                        viewModel.loadTasks()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.saveTasks()
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                if let task = editingTask {
                    EditTaskView(task: task, viewModel: viewModel)
                }
            }
        }
    }
}

struct EditTaskView: View {
    let task: TaskItem
    @ObservedObject var viewModel: TaskViewModel
    @State private var editedDescription: String
    @Environment(\.presentationMode) var presentationMode
    
    init(task: TaskItem, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        _editedDescription = State(initialValue: task.description)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Description", text: $editedDescription)
            }
            .navigationTitle("Изменить")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.updateDescription(for: task, newDescription: editedDescription)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
