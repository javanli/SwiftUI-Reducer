//
//  ReducerCore.swift
//  SwiftUI-Reducer
//
//  Created by lijunfan on 2022/9/15.
//

import Foundation
import SwiftUI

public class StateWrapper<ValueType> : ObservableObject {
    @Published public var value : ValueType
    public init(value: ValueType) {
        self.value = value
    }
}

public class Dispatcher<ActionType> : ObservableObject {
    public var _dispatch : (ActionType) -> Task<Void, Never>
    public init<StateType>(state: StateWrapper<StateType>,
                           reducer : @escaping (StateType, ActionType) -> StateType?,
                           asyncReducer : (@escaping (ActionType, @escaping (ActionType) -> Task<Void, Never>) async -> Void) = {_,_ in }) {
        let oriDispatch = { (action:ActionType) in
            return Task { @MainActor in
                let oldValue = state.value
                let newValue = reducer(oldValue, action)
                if newValue != nil {
                    state.value = newValue!
                }
            }
        }
        _dispatch = { (action:ActionType) in
            return Task {
                await asyncReducer(action, oriDispatch)
                await oriDispatch(action).value
            }
        }
    }
    @discardableResult
    func dispatch(_ action : ActionType) -> Task<Void, Never> {
        return _dispatch(action)
    }
}
