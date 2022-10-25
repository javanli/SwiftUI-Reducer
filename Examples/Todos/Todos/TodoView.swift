import Foundation
import SwiftUI

struct TodoView: View {
    var state : TodoState
    var body: some View {
        TodosStore.dispatchConsumer { dispatch in
            HStack {
                Button(action: { _ = dispatch(.checkBoxToggled(state.id)) }) {
                    Image(systemName: state.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)
                
                TextField(
                    "Untitled Todo",
                    text: Binding(get: {
                        state.description
                    }, set: { value in
                        _ = dispatch(.textFieldChanged(state.id, value))
                    })
                )
            }
            .foregroundColor(state.isComplete ? .gray : nil)
        }
    }
}
