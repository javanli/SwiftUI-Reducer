//
//  ReducerHelper.swift
//  SwiftUI-Reducer
//
//  Created by lijunfan on 2022/9/15.
//

import Foundation
import SwiftUI

open class Store<StateType, ActionType> : ObservableObject {
    public var state: StateWrapper<StateType>
    public var dispatcher: Dispatcher<ActionType>
    public required init(defaultValue: StateType) {
        state = StateWrapper(value: defaultValue)
        dispatcher = Dispatcher(state: state, reducer: type(of: self).reducer, asyncReducer: type(of: self).asyncReducer)
    }
    public init(defaultValue: StateType,
                    reducer : @escaping (StateType, ActionType) -> StateType?,
                asyncReducer : @escaping (ActionType, @escaping (ActionType) -> Task<Void, Never>) async -> Void = {_,_ in }) {
        state = StateWrapper(value: defaultValue)
        dispatcher = Dispatcher(state: state, reducer: reducer, asyncReducer: asyncReducer)
    }
    public func dispatch(action:ActionType) -> Task<Void, Never> {
        return dispatcher.dispatch(action)
    }
    public func stateValue() -> StateType {
        return state.value
    }
    public static func provider<Content : View>(defaultValue: StateType, @ViewBuilder contents:@escaping ()->Content) -> ReducerProvider<StateType,ActionType,Content> {
        let store = self.init(defaultValue: defaultValue)
        return ReducerProvider(store: store, contents: contents)
    }
    public func provider<Content : View>(@ViewBuilder contents:@escaping ()->Content) -> some View {
        return ReducerProvider(store: self, contents: contents)
    }
    public static func dispatchConsumer<Content:View>(@ViewBuilder contents: @escaping (@escaping (ActionType) -> Task<Void, Never>) -> Content) -> some View {
        return DispatchConsumer(contents: contents)
    }
    public static func stateConsumer<Content:View>(@ViewBuilder contents: @escaping (StateType) -> Content) -> some View {
        return StateConsumer(contents: contents)
    }
    public static func consumer<Content:View>(@ViewBuilder contents: @escaping (StateType,@escaping (ActionType) -> Task<Void, Never>) -> Content) -> some View {
        return StateConsumer { (state : StateType) in
            DispatchConsumer<ActionType,Content> { dispatch in
                contents(state,dispatch)
            }
        }
    }
    // rewrite
    open class func reducer(state : StateType, action : ActionType) -> StateType? {
        return nil
    }
    open class func asyncReducer(action : ActionType, dispatch : @escaping (ActionType) -> Task<Void, Never>) async -> Void {
    }
}

public struct StateConsumer<StateType, Content : View> : View {
    @EnvironmentObject public var state : StateWrapper<StateType>
    private let contents: (StateType) -> Content

    public init(@ViewBuilder contents: @escaping (StateType) -> Content) {
        self.contents = contents
    }
    public var body: some View {
        contents(state.value)
    }
}

public struct DispatchConsumer<ActionType, Content : View> : View {
    @EnvironmentObject public var dispatcher : Dispatcher<ActionType>
    private let contents: (@escaping(ActionType) -> Task<Void, Never>) -> Content

    public init(@ViewBuilder contents: @escaping (@escaping (ActionType) -> Task<Void, Never>) -> Content) {
        self.contents = contents
    }
    public var body: some View {
        contents(dispatcher.dispatch)
    }
}

public struct ReducerProvider<StateType, ActionType, Content : View> : View {
    private let store : Store<StateType, ActionType>
    private let contents: () -> Content

    public init(store : Store<StateType, ActionType>, @ViewBuilder contents: @escaping () -> Content) {
        self.store = store
        self.contents = contents
    }
    
    public var body: some View {
        contents()
            .environmentObject(store.state)
            .environmentObject(store.dispatcher)
            .environmentObject(store)
    }
}
