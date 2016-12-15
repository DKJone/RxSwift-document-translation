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
/*:
 # 第二章 使用Subjects
 一个Subject是获取Rx的观测者和可观察属性(`Observable`)的桥梁和代理。因为是观察者，所以它可以订阅一个或者多个可观察对象(`Observable`)。因为是可观察对象(`Observable`)，它可以通过元素观察和重发他们，也可以发送新的元素。[更多信息](http://reactivex.io/documentation/subject.html)
*/
extension ObservableType {
    
    /**
     为id添加观察者，并打印所有发出的事件
     - parameter id: 订阅者的id.
     */
    func addObserver(_ id: String) -> Disposable {
        return subscribe { print("Subscription:", id, "Event:", $0) }
    }
    
}

func writeSequenceToConsole<O: ObservableType>(name: String, sequence: O) -> Disposable {
    return sequence.subscribe { event in
        print("Subscription: \(name), event: \(event)")
    }
}
/*:
 ## PublishSubject
 在订阅后向他的观察者广播事件。
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject.png "PublishSubject")
 */
example("PublishSubject") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.addObserver("1").addDisposableTo(disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").addDisposableTo(disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
/*:
 > 提示：这个示例还是用了`onNext(_:)`简便方法，等价于使用`on(.next(_:))`,让用户使用订阅元素的下一个事件。也有`onError(_:) 和onCompleted()`简便方法分别等价于`on(.error(_:)) 和   on(.completed)`。
 ----
 ## ReplaySubject
 广播新事件给所有订阅者，并指定新事件的之前的缓存大小。
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png)
*/
example("ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.create(bufferSize: 1)
    
    subject.addObserver("1").addDisposableTo(disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").addDisposableTo(disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
/*:
 ----
## BehaviorSubject
广播新的事件给订阅者，并发送最近的(或者初始值)给行的而订阅者
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)
*/
example("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subject = BehaviorSubject(value: "🔴")
    
    subject.addObserver("1").addDisposableTo(disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").addDisposableTo(disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
    
    subject.addObserver("3").addDisposableTo(disposeBag)
    subject.onNext("🍐")
    subject.onNext("🍊")
}
/*:
 > 注意这些之前的例子中都遗漏了什么？完成事件！`PublishSubject, ReplaySubject,BehaviorSubject`当他们即将被处理时，不能自动发出完成事件。
 ----
 ## Variable
 覆盖`BehaviorSubject`所以它将发送最近(或初始)的值给新的订阅者，并维持最近值得状态。`Variable`将不会发送错误事件，然而他会在销毁前发送完成事件和结束。
*/
example("Variable") {
    let disposeBag = DisposeBag()
    let variable = Variable("🔴")
    
    variable.asObservable().addObserver("1").addDisposableTo(disposeBag)
    variable.value = "🐶"
    variable.value = "🐱"
    
    variable.asObservable().addObserver("2").addDisposableTo(disposeBag)
    variable.value = "🅰️"
    variable.value = "🅱️"
}
//:  > 一个`Variable`实例使用`asObservable`方法，访问它的原始队列，`Variables`没有实现`on`操作符(如`onNext(_:)`),但是作为替代，提供了一个`value`属性可以用作获取最近的值，也可以设置一个新的值，设置新值也会添加这个值到原始的`BehaviorSubject`队列。

//: [下一章](@next) - [返回目录](Table_of_Contents)
