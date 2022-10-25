import SwiftUI
import SwiftUIReducer

struct AppView: View {
    var body: some View {
        TodosStore.consumer { state, dispatch in
            NavigationView {
                VStack(alignment: .leading) {
                    Picker(
                        "Filter",
                        selection: Binding(get: {
                            state.filter
                        }, set: { value, trans in
                            _ = dispatch(.filterPicked(value))
                        })
                        .animation()
                    ) {
                        ForEach(Filter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    List {
                        ForEach(state.filteredTodos) { todo in
                            TodoView(state: todo)
                        }
                        .onDelete { _ = dispatch(.delete($0)) }
                        .onMove { _ = dispatch(.move($0, $1)) }
                    }
                }
                .navigationTitle("Todos")
                .navigationBarItems(
                    trailing: HStack(spacing: 20) {
                        EditButton()
                        Button("Clear Completed") {
                            _ = dispatch(.clearCompletedButtonTapped)
                        }
                        .disabled(state.isClearCompletedButtonDisabled)
                        Button("Add Todo") { _ = dispatch(.addTodoButtonTapped) }
                    }
                )
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        var state =  TodosState()
        state.todos = [
            TodoState(
                description: "Check Mail",
                id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEDDEADBEEF")!,
                isComplete: false
            ),
            TodoState(
                description: "Buy Milk",
                id: UUID(uuidString: "CAFEBEEF-CAFE-BEEF-CAFE-BEEFCAFEBEEF")!,
                isComplete: false
            ),
            TodoState(
                description: "Call Mom",
                id: UUID(uuidString: "D00DCAFE-D00D-CAFE-D00D-CAFED00DCAFE")!,
                isComplete: true
            ),
        ]
        var store = TodosStore(defaultValue: state)
        return store.provider {
            AppView()
        }
    }
}
