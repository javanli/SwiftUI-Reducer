//
//  Store.swift
//  Todos
//
//  Created by lijunfan on 2022/10/13.
//

import Foundation
import SwiftUIReducer
import SwiftUI

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
}

enum TodosAction {
    case addTodoButtonTapped
    case clearCompletedButtonTapped
    case delete(IndexSet)
    case editModeChanged(EditMode)
    case filterPicked(Filter)
    case moveAsync(IndexSet, Int)
    case move(IndexSet, Int)
    case sortCompletedTodos
    case checkBoxToggled(UUID)
    case textFieldChanged(UUID,String)
}

struct TodoState: Equatable, Identifiable {
    var description = ""
    let id: UUID
    var isComplete = false
}
struct TodosState {
    var editMode: EditMode = .inactive
    var filter: Filter = .all
    let isClearCompletedButtonDisabled: Bool = false
    var todos: [TodoState] = []

    var filteredTodos: [TodoState] {
      switch filter {
      case .active: return self.todos.filter { !$0.isComplete }
      case .all: return self.todos
      case .completed: return self.todos.filter(\.isComplete)
      }
    }
}
class TodosStore : Store<TodosState,TodosAction> {
    override class func reducer(state: TodosState, action: TodosAction) -> TodosState? {
        var newState = state
        switch action {
        case .addTodoButtonTapped:
            newState.todos.insert(TodoState(id: UUID()), at: 0)
            
        case .clearCompletedButtonTapped:
            newState.todos.removeAll(where: \.isComplete)
            
        case let .delete(indexSet):
            newState.todos.remove(atOffsets: indexSet)
            
        case let .editModeChanged(editMode):
            newState.editMode = editMode
            
        case let .filterPicked(filter):
            newState.filter = filter
            
        case var .move(source, destination):
            if newState.filter == .completed {
                source = IndexSet(
                    source
                        .map { newState.filteredTodos[$0] }
                        .compactMap({ oldState in
                            newState.todos.firstIndex { state in
                                return state.id == oldState.id
                            }
                        })
                )
                destination =
                (destination < newState.filteredTodos.endIndex
                 ? newState.todos.firstIndex(where: { state in
                    return state.id == newState.filteredTodos[destination].id
                })
                 : newState.todos.endIndex)
                ?? destination
            }
            
            newState.todos.move(fromOffsets: source, toOffset: destination)
            
        case .sortCompletedTodos:
            newState.todos.sort { $1.isComplete && !$0.isComplete }
        case let .checkBoxToggled(id):
            for index in 0..<newState.todos.count {
                if newState.todos[index].id == id {
                    newState.todos[index].isComplete.toggle()
                }
            }
        case let .textFieldChanged(id, description):
            for index in 0..<newState.todos.count {
                if newState.todos[index].id == id {
                    newState.todos[index].description = description
                }
            }
        default:break;
        }
        return newState
    }
        
    override class func asyncReducer(action: TodosAction, dispatch: @escaping (TodosAction) -> Task<Void, Never>) async {
        switch action {
        case let .moveAsync(source, destination):
            do {
                await dispatch(.move(source, destination)).value
                try await Task.sleep(nanoseconds: 100 * 1_000_000)
                await dispatch(.sortCompletedTodos).value
            } catch {
            }
        default:break;
        }
    }
}
