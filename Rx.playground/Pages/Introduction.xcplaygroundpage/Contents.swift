/*:
 > # 重要提示：使用Rx.playground：
 1.  打开Rx.xcworkspace.
 1. 编译 RxSwift-macOS 项目 (Product → Build)
 1. 在项目导航栏你打开RX playground
 1. 打开调试窗口 (**View** → **Debug Area** → **Show Debug Area**).
 ----
 [上一页](@previous)
 */

import RxSwift

/*:
# 序章 介绍

## 为什么我们要使用RxSwift？

 
 我们写的绝大多数代码都包含了界面元素的事件响应。当用户操作控件时，我们需要写一个@IBAction的处理句柄去响应用户事件。我们需要订阅通知去观测何时键盘位置发生改变。当URL sessions返回一个数据时我们需要提供一个可执行的闭包。我们利用KVO去观测变量的变化。这些各种各样的机制促使我们的代码产生了不必要的复杂。有什么能比只使用一种机制去处理所有请求或响应更好的呢？Rx就是这样一种机制。
 
 RxSwift 是官方的[Reactive Extensions](http://reactivex.io) (也称作 Rx),  （一款同时支持[多种语言平台](http://reactivex.io/languages.html).）的实现
*/
/*:
 ## 概念
 
 **任何一个Observable的实例都是一个队列**
 
 一个Observable队列和Swift的SequenceType相比它的核心优势就在于它依然可以接收异步元素，这是RxSwift的核心所在。其他的所有都是建立在这基础之上的。
 * 一个Observable (`ObservableType`)等价于一个 `SequenceType`
 * `ObservableType.subscribe(_:)`方法等价于`SequenceType.generate()`
 * `ObservableType.subscribe(_:)`需要一个观察者(`ObserverType`)作为参数，他将自动订阅由Observable发出的事件队列，而不是手动的用`Next()`方法订阅回调。
 */
/*:
 如果 一个`Observable`发出一个`next`事件(`Event.next(Element)`),它人可以继续发出更多的事件。但是如果它发出了一个错误事件(`Event.error(ErrorType)`)或者一个完成事件(`Event.completed`)，他讲不再能够发送更多的事件给订阅者。
 
 这样介绍上面的概念更简洁:

 `next* (error | completed)?`

 用图表可以更形象的解释

 `--1--2--3--4--5--6--|----> // "|" = 正常停止`

 `--a--b--c--d--e--f--X----> // "X" = 错误时停止`

 `--tap--tap----------tap--> // "|" = 永远不停止，例如按钮的点击事件队列`

 > 这些图表称作大理石图. 你可以在[RxMarbles.com](http://rxmarbles.com).学到更多
*/
/*:
 ### Observables and observers (也称作 subscribers)
 
 可订阅对象(Observables)在有订阅者之前不会执行他们的订阅闭包。例如下面这个例子，他的闭包永远不会执行因为他没有一个订阅者
 */

example("Observable with no subscribers") {
    _ = Observable<String>.create { observerOfString -> Disposable in
        print("This will never be printed")
        observerOfString.on(.next("😬"))
        observerOfString.on(.completed)
        return Disposables.create()
    }
}
/*:
 ----
 在下面这个例子中，闭包会在被订阅(`subscribe(_:)`)时执行
 */
example("Observable with subscriber") {
  _ = Observable<String>.create { observerOfString in
            print("Observable created")
            observerOfString.on(.next("😉"))
            observerOfString.on(.completed)
            return Disposables.create()
        }
        .subscribe { event in
            print(event)
    }
}
/*:
 > 不要关心`Observables`是怎么创建的，我们将在[下一章](@next)介绍.
 #
 > `subscribe(_:)`返回一个`Disposable`实例代表一次性资源比如一个订阅。他在之前的简单例子中被忽略了，但是它常常正确的处理了。这意味着将它放入内容一个` DisposeBag`实例中。在此后的例子中我们将包含适当的处理，因为实践出真知！
 🙂. 你可以在这里获取更多[Disposing section](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#disposing) -  [入门指南](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md).
 */

//: [下一章](@next) - [返回目录](Table_of_Contents)
