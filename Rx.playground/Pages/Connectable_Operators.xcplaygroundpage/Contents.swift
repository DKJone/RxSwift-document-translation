/*:
 > # 重要提示：使用Rx.playground：
 1.  打开Rx.xcworkspace.
 1. 编译 RxSwift-macOS 项目 (Product → Build)
 1. 在项目导航栏你打开RX playground
 1. 打开调试窗口 (**View** → **Debug Area** → **Show Debug Area**).
 ----
 [上一页](@previous) - [返回目录](Table_of_Contents)
 */
import RxSwift

playgroundShouldContinueIndefinitely()
/*:
# 第七章 Connectable
 可连接`Observable`队列除了在被订阅时不发送元素之外都和普通的`Observable`队列类似，作为替代可连接的`Observable`队列只在他们的`connect()`方法执行后才会发送元素。所以你可以订阅所有你想订阅的连接型`OBservable`队列在他发送元素之前。
 > 这个页面里的所有例子都有注释掉的代码，试着去掉这些注释重新运行观察结果，然后再把注释添加回来 。
 # 
 在开始学习可连接队列前我们来回顾一下不可连接队列的操作:
*/
func sampleWithoutConnectableOperators() {
    printExampleHeader(#function)
    
    let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    
    _ = interval
        .subscribe(onNext: { print("Subscription: 1, Event: \($0)") })
    
    delay(5) {
        _ = interval
            .subscribe(onNext: { print("Subscription: 2, Event: \($0)") })
    }
}

//sampleWithoutConnectableOperators() // ⚠️ 去掉这些注释重新运行观察结果，然后再把注释添加回来.
/*:
 > `interval`创建一个在每个周期(`Period`)后发送元素的`Observable`队列. [更多信息](http://reactivex.io/documentation/operators/interval.html)
 ![](http://reactivex.io/documentation/operators/images/interval.c.png)
 ----
 ## `publish`
 把元`Observable`队列转换成可连接的`Observable`队列。 [更多信息](http://reactivex.io/documentation/operators/publish.html)
 ![](http://reactivex.io/documentation/operators/images/publishConnect.c.png)
 */
func sampleWithPublish() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .publish()
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}

//sampleWithPublish() // ⚠️ 去掉这些注释重新运行观察结果，然后再把注释添加回来.

//: > 执行操作的调度者只是一个抽象出来的概念，比如在指定线程和`dispatch queues`。 [更多信息](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md)

/*:
 ----
 ## `replay`
把原`Observable`队列转换为可连接队列。并把`bufferSize`大小的之前元素推送给新的订阅者。 [更多信息](http://reactivex.io/documentation/operators/replay.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replay.png)
 */
func sampleWithReplayBuffer() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .replay(5)
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(8) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}

// sampleWithReplayBuffer() // ⚠️ 去掉这些注释重新运行观察结果，然后再把注释添加回来.

/*:
 ----
 ## `multicast`
 转化原`Observable`队列为可连接队列，并发送指定的`Subject`。
 */
func sampleWithMulticast() {
    printExampleHeader(#function)
    
    let subject = PublishSubject<Int>()
    
    _ = subject
        .subscribe(onNext: { print("Subject: \($0)") })
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .multicast(subject)
    
    _ = intSequence
        .subscribe(onNext: { print("\tSubscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 3:, Event: \($0)") })
    }
}

//sampleWithMulticast() // ⚠️ 去掉这些注释重新运行观察结果，然后再把注释添加回来.

//: [下一章](@next) - [返回目录](Table_of_Contents)
