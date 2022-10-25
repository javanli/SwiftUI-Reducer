# SwiftUIReducer

[![CI](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

为SwiftUI应用提供的一个轻量的状态管理方案。类似React的[useReducer](https://reactjs.org/docs/hooks-reference.html#usereducer)

## 特点

* 经典的State+Action+Reducer状态管理模型
* 多store
* 不可变数据
* 侵入性低

## 动机

SwiftUI 中提供了一些基础的状态管理关键字： @State、@ObservedObject 等，官方 SwiftUI 教程里对数据管理也有涉及：[数据传递](https://developer.apple.com/tutorials/app-dev-training/passing-data-with-bindings)和[状态管理](https://developer.apple.com/tutorials/app-dev-training/managing-state-and-life-cycle)。但光靠这些很难开发出稳定和可扩展的app。

社区中诞生了一些状态管理框架，其中最成功的是[TCA](https://github.com/pointfreeco/swift-composable-architecture)。TCA是个很好的框架，但也是一个侵入性和约束比较强的框架，不是适合所有应用，提供的是对整个应用的全局状态管理，也不适合在局部模块中引入。

SwiftUIReducer是个更轻量的解决方案，它仅在`@EnvironmentObject`基础上对State的读写做了一些约束，可以在任意的View层级引入。

## 例子

[这里](./Examples/)提供了一些例子来演示如何利用`SwiftUIReducer`进行状态管理。

## 使用

首先定义Action和State，

```swift
enum DemoAction {
    case add
}

struct DemoState: Equatable, Identifiable {
    var cnt = 0
}
```

然后定义Store，重写`reducer`和`asyncReducer`（按需）方法:

```swift
class DemoStore : Store<DemoState,DemoAction> {
    override class func reducer(state: DemoState, action: DemoAction) -> DemoState? {
        var newState = state
        switch action {
        case .add:
            newState.cnt += 1
        default:break;
        }
        return newState
    }
}
```

在目标View外层，通过`Store.provider`注入Store:

```swift
DemoStore(defaultValue: DemoState()).provider {
    AppView()
}
```

在目标View中，通过`Store.consumer`获取State和dispatch:

```swift
struct AppView: View {
    var body: some View {
        DemoStore.consumer { state, dispatch in
            Button("\(state.cnt)") {
                _ = dispatch(.add)
            }
        }
    }
}
```

更详细的使用方式请参考[例子](./Examples/)

## 依赖

* iOS 14.0+ / macOS 12.0+ / tvOS 14.0+ / watchOS 8.0+

## 安装

You can add SwiftUIReducer to an Xcode project by adding it as a package dependency.

> https://github.com/javanli/SwiftUI-Reducer

## 其他

欢迎提Issue和PR，也可以通过邮箱(javanli@qq.com)联系我。
