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
 # 第一章 创建并使用Observables
 有下面几种创建和订阅` Observable`队列的方式
 ## never
 创建一个不会停止也不会发送任何元素的`Observable`队列. [更多信息](http://reactivex.io/documentation/operators/empty-never-throw.html)
 */
example("never") {
    let disposeBag = DisposeBag()
    let neverSequence = Observable<String>.never()
    
    let neverSequenceSubscription = neverSequence
        .subscribe { _ in
            print("This will never be printed")
    }
    
    neverSequenceSubscription.addDisposableTo(disposeBag)
}
/*:
 ----
 ## empty
 创建一个只会发送一个完成事件的`Observable`队列.。[更多信息](http://reactivex.io/documentation/operators/empty-never-throw.html)
 */
example("empty") {
    let disposeBag = DisposeBag()
    
    Observable<Int>.empty()
        .subscribe { event in
            print(event)
        }
        .addDisposableTo(disposeBag)
}
/*:
 > 这个例子也包括创建和订阅一个`Observable`队列.
 ----
 ## just
 创建一个只有单一信号元素的`OBservable`队列。[更多信息](http://reactivex.io/documentation/operators/just.html)
 */
example("just") {
    let disposeBag = DisposeBag()
    
    Observable.just("🔴")
        .subscribe { event in
            print(event)
        }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## of
 创建一个带有固定元素个数的`Observable`队列
 */
example("of") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .subscribe(onNext: { element in
            print(element)
        })
        .addDisposableTo(disposeBag)
}
/*:
 > 这个例子也包括了使用`subscribe(onNext:)`简便方法，和`subscribe(_:)`订阅所有时间句柄不同(next,error,completeed),`subscribes(onNext:)`订阅一个元素的除了完成和错误(Error、Completed)的其他事件而且只产生下一个事件元素，当然还有  `subscribe(onCompleted:)` 和 subscribe(onError:)`  只订阅而对应的事件.也有一个`subscribe(onNext:onError:onCompleted:onDisposed:)`方法，可以允许你响应一个或者多个类型的事件，包括由于某种原因使这个订阅终止和正常处理。
 例如:
 ```
 someObservable.subscribe(
     onNext: { print("Element:", $0) },
     onError: { print("Error:", $0) },
     onCompleted: { print("Completed") },
     onDisposed: { print("Disposed") }
 )
```
 ----
 ## from
 由一个`SequenceType`创建一个`Observable`队列，例如`Array, Dictionary, Set`
 */
example("from") {
    let disposeBag = DisposeBag()
    
    Observable.from(["🐶", "🐱", "🐭", "🐹"])
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
/*:
 > 这个示例也示范了使用默认的声明`$0`去替代明确的声明。
----
 ## create
 创建一个自定义的`Observable`队列. [更多信息](http://reactivex.io/documentation/operators/create.html)
*/
example("create") {
    let disposeBag = DisposeBag()
    
    let myJust = { (element: String) -> Observable<String> in
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
            return Disposables.create()
        }
    }
        
    myJust("🔴")
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## range
  创建一段连续区间的整数的`Observable`队列，发送完成后终止队列. [更多信息](http://reactivex.io/documentation/operators/range.html)
 */
example("range") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## repeatElement
 创建一个无线发送元素的`Observable`队列。 [获取更多](http://reactivex.io/documentation/operators/repeat.html)
 */
example("repeatElement") {
    let disposeBag = DisposeBag()
    
    Observable.repeatElement("🔴")
        .take(3)
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
/*:
 > 这个示例还展示了使用`take`操作符去返回一个指定数量元素的队列。
 ----
 ## generate
 创建一个只要提供的条件成立就持续生成值的队列
 */
example("generate") {
    let disposeBag = DisposeBag()
    
    Observable.generate(
            initialState: 0,
            condition: { $0 < 3 },
            iterate: { $0 + 1 }
        )
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## deferred
 为所有订阅者创建一个新的`Observable`队列. [更多信息](http://reactivex.io/documentation/operators/defer.html)
 */
example("deferred") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let deferredSequence = Observable<String>.deferred {
        print("Creating \(count)")
        count += 1
        
        return Observable.create { observer in
            print("Emitting...")
            observer.onNext("🐶")
            observer.onNext("🐱")
            observer.onNext("🐵")
            return Disposables.create()
        }
    }
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## error
 创建一个不发送任何元素并且立即停止的错误`Observable`队列
 */
example("error") {
    let disposeBag = DisposeBag()
        
    Observable<Int>.error(TestError.test)
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## doOn
为所有发出和接受的事件添加一个附加的操作 [更多信息](http://reactivex.io/documentation/operators/do.html)
 */
example("doOn") {
    let disposeBag = DisposeBag()
    
    Observable.of("🍎", "🍐", "🍊", "🍋")
        .do(onNext: { print("Intercepted:", $0) }, onError: { print("Intercepted error:", $0) }, onCompleted: { print("Completed")  })
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
//: > 当然也会有`doOnNext(_:), doOnError(_:), doOnCompleted(_:)`这些方法去拦截特定的事件，`doOn(onNext:onError:onCompleted:)`拦截一个或多个的事件信号。

//: [下一章](@next) - [返回目录](Table_of_Contents)
