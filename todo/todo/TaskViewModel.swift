//
//  TaskViewModel.swift
//  todo
//
//  Created by Ksenia Zaharova on 15.09.2025.
//

import SwiftUI
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var filter: TaskFilter = .all
    
    private let fileName = "tasks.json"
    
    init() {
    }
    
    func addTask(description: String) {
        if !description.isEmpty {
            tasks.append(TaskItem(description: description))
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func toggleDone(for task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
        }
    }
    
    func updateDescription(for task: TaskItem, newDescription: String) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].description = newDescription
        }
    }
    
    func moveTask(from offsets: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: offsets, toOffset: destination)
    }
    
    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            let desktopURL = URL(fileURLWithPath: "/Users/kseniazaharova/Desktop/\(fileName)")
            try data.write(to: desktopURL, options: .atomic)
            print("Сохранено \(desktopURL.path)")
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }
    
    func loadTasks() {
        do {
            let desktopURL = URL(fileURLWithPath: "/Users/kseniazaharova/Desktop/\(fileName)")
            let data = try Data(contentsOf: desktopURL)
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
            print("Загружено \(desktopURL.path)")
        } catch {
            print("Ошибка загрузки: \(error)")
            tasks = []
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var filteredTasks: [TaskItem] {
        switch filter {
        case .all:
            return tasks
        case .done:
            return tasks.filter { $0.isDone }
        case .undone:
            return tasks.filter { !$0.isDone }
        }
    }
}

enum TaskFilter: String, CaseIterable {
    case all = "Все"
    case done = "Выполненные"
    case undone = "Невыполненные"
}
