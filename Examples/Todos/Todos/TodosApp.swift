//
//  TodosApp.swift
//  Todos
//
//  Created by lijunfan on 2022/10/12.
//

import SwiftUI

@main
struct TodosApp: App {
    var body: some Scene {
        WindowGroup {
            TodosStore(defaultValue: TodosState()).provider {
                AppView()
            }
        }
    }
}
