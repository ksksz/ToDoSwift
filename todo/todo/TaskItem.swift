//
//  TaskItem.swift
//  todo
//
//  Created by Ksenia Zaharova on 15.09.2025.
//

import Foundation

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var description: String
    var isDone: Bool
    
    init(description: String, isDone: Bool = false) {
        self.id = UUID()
        self.description = description
        self.isDone = isDone
    }
}
