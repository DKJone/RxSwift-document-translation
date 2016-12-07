# RxSwift-文档翻译
对RxSwift 官方playground的翻译，playGround基于2016年-12月-1日版本  
重要提示：使用Rx.playground
---
1. 打开Rx.xcworkspace.
2. 编译 RxSwift-macOS 项目 (Product → Build)
3. 在项目导航栏你打开RX playground
4. 打开调试窗口(View → Debug Area → Show Debug Area)

序章：介绍
---
为什么我们要使用RxSwift？
我们写的绝大多数代码都包含了界面元素的事件响应。当用户操作控件时，我们需要写一个@IBAction的处理句柄去响应用户事件。我们需要订阅通知去观测何时键盘位置发生改变。当URL sessions返回一个数据时我们需要提供一个可执行的闭包。我们利用KVO去观测变量的变化。这些各种各样的机制促使我们的代码产生了不必要的复杂。有什么能比只使用一种机制去处理所有请求或响应更好的呢？Rx就是这样一种机制。

RxSwift是官方的Reactiv Extension（一款同时支持多种语言平台）的实现。

第一章：概念
---
任何一个Observable的实例都是一个队列
一个Observable队列和Swift的SequenceType相比它的核心优势就在于它依然可以接收异步元素，这是RxSwift的核心所在。其他的所有都是建立在这基础之上的。
- 一个Observable (`ObservableType`)等价于一个 `SequenceType`
- `ObservableType.subscribe(_:)`方法等价于`SequenceType.generate()`
- `ObservableType.subscribe(_:)`需要一个观察者(`ObserverType`)作为参数，他将自动订阅由Observable发出的事件队列，而不是手动的用`Next()`方法订阅回调。

如果 一个`Observable`发出一个`next`事件(`Event.next(Element)`),它人可以继续发出更多的事件。但是如果它发出了一个错误事件(`Event.error(ErrorType)`)或者一个完成事件(`Event.completed`)，他讲不再能够发送更多的事件给订阅者。

这样介绍上面的概念更简洁
```
next* (error | completed)?
```
用图表可以更形象的解释
```
1-->1-->2-->3-->4-->5-->6-->|----> // "|" =正常停止
--a--b--c--d--e--f--X----> // "X" =错误时停止
--tap--tap----------tap--> // "|" =永远不停止，例如按钮的点击事件队列
```

#### Observables and observers (aka subscribers)
---
可订阅对象(Observables)在有订阅者之前不会执行他们的订阅闭包。例如下面这个例子，他的闭包永远不会执行因为他没有一个订阅者
```swift
example("Observable with no subscribers") {
_ = Observable<String>.create { observerOfString -> Disposable in
print("This will never be printed")
observerOfString.on(.next("😬"))
observerOfString.on(.completed)
return Disposables.create()
}
}
```
在下面这个例子中，闭包会在被订阅(`subscribe(_:)`)时执行
```swift
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
```
提示：不要关心`Observables`是怎么创建的，我们将在之后介绍
提示：`subscribe(_:)`返回一个`Disposable`实例代表一次性资源比如一个订阅。他在之前的简单例子中被忽略了，但是它常常正确的处理了。这意味着将它放入内容一个` DisposeBag`实例中。在此后的例子中我们将包含适当的处理，因为实践出真知！

你可以在这里获取更多
- [Disposing section](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#disposing)
- [Getting Started](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md)


第二章：创建和订阅可订阅者
---
有下面几种创建和订阅` Observable`队列的方式
#### 1. never:创建一个不会停止也不会发送任何元素的`Observable`队列

```swift
example("never") {
let disposeBag = DisposeBag()
let neverSequence = Observable<String>.never()

let neverSequenceSubscription = neverSequence
.subscribe { _ in
print("This will never be printed")
}

neverSequenceSubscription.addDisposableTo(disposeBag)
}
```
#### 2. empty:创建一个只会发送一个完成事件的`Observable`队列
```swift
example("empty") {
let disposeBag = DisposeBag()

Observable<Int>.empty()
.subscribe { event in
print(event)
}
.addDisposableTo(disposeBag)
}
```
提示：这个例子也包括创建和订阅一个`Observable`队列
#### 3. just:创建一个只有单一信号元素的`OBservable`队列
```swift
example("just") {
let disposeBag = DisposeBag()

Observable.just("🔴")
.subscribe { event in
print(event)
}
.addDisposableTo(disposeBag)
}
```
#### 4. of:创建一个带有固定元素个数的`Observable`队列
```swift
example("of") {
let disposeBag = DisposeBag()

Observable.of("🐶", "🐱", "🐭", "🐹")
.subscribe(onNext: { element in
print(element)
})
.addDisposableTo(disposeBag)
}
```
#### 提示：
这个例子也包括了使用`subscribe(onNext:)`简便方法，和`subscribe(_:)`订阅所有时间句柄不同(next,error,completeed),`subscribes(onNext:)`订阅一个元素的除了完成和错误(Error、Completed)的其他事件而且只产生下一个事件元素，当然还有`subscribe(onCompleted:)`和`subscribe(onError:) `只订阅而对应的事件.也有一个`subscribe(onNext:onError:onCompleted:onDisposed:)`方法，可以允许你响应一个或者多个类型的事件，包括由于某种原因使这个订阅终止和正常处理。
例如
```swift
someObservable.subscribe(
onNext: { print("Element:", $0) },
onError: { print("Error:", $0) },
onCompleted: { print("Completed") },
onDisposed: { print("Disposed") }
)
```
#### 5. from:由一个`SequenceType`创建一个`Observable`队列，例如`Array, Dictionary, Set`
```swift
example("from") {
let disposeBag = DisposeBag()

Observable.from(["🐶", "🐱", "🐭", "🐹"])
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
#### 提示：这个示例也示范了使用默认的声明`$0`去替代明确的声明

#### 6. create:创建一个自定义的`Observable`队列
```swift
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
```
#### 7. range：创建一段连续区间的整数的`Observable`队列
```swift
example("range") {
let disposeBag = DisposeBag()

Observable.range(start: 1, count: 10)
.subscribe { print($0) }
.addDisposableTo(disposeBag)
}
```
#### 8. `repeatElement`:创建一个无线发送元素的`Observable`队列
```swift
example("repeatElement") {
let disposeBag = DisposeBag()

Observable.repeatElement("🔴")
.take(3)
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
#### 提示：这个示例还展示了使用`take`操作符去返回一个指定数量元素的队列

#### 9.generate：创建一个只要提供的条件成立就持续生成值的队列
```swift
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
```
#### 10. deferred：为所有订阅者创建一个新的`Observable`队列
```swift
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
```
#### 11.error:创建一个不发送任何元素并且立即停止的错误`Observable`队列
```swift
example("error") {
let disposeBag = DisposeBag()

Observable<Int>.error(TestError.test)
.subscribe { print($0) }
.addDisposableTo(disposeBag)
}
```
#### 12. doOn:为所有发出和接受的事件添加一个附加的操作
```swift
example("doOn") {
let disposeBag = DisposeBag()

Observable.of("🍎", "🍐", "🍊", "🍋")
.do(onNext: { print("Intercepted:", $0) },
onError: { print("Intercepted error:", $0) }, 
onCompleted: { print("Completed") })
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
#### 提示：当然也会有`doOnNext(_:), doOnError(_:), doOnCompleted(_:)`这些方法去拦截特定的事件，`doOn(onNext:onError:onCompleted:)`拦截一个或多个的事件信号

第三章：利用分类工作(编码)
----
一个分类是获取Rx的观测者和可观察属性(`Observable`)的桥梁和代理。因为是观察者，所以它可以订阅一个或者多个可观察对象(`Observable`)。因为是可观察对象(`Observable`)，它可以通过元素观察和重发他们，也可以发送新的元素。
```swift
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
```
#### 1. PublishSubject:在订阅后向他的观察者广播事件
```swift
example("PublishSubject") {
let disposeBag = DisposeBag()
let subject = PublishSubject<String>()

subject.addObserver("1").addDisposableTo(disposeBag)
subject.onNext("🐶")
subject.onNext("🐱")

subject.addObserver("2").addDisposableTo(disposeBag)
subject.onNext("🅰️")
subject.onNext("🅱️")
```
#### 提示：这个示例还是用了`onNext(_:)`简便方法，等价于使用`on(.next(_:))`,让用户使用订阅元素的下一个事件。也有`onError(_:) 和onCompleted()`简便方法分别等价于`on(.error(_:)) 和   on(.completed)`
#### 2. ReplaySubject：广播新事件给所有订阅者，并指定新事件的之前的缓存大小。
```swift
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
```
#### 3. BehaviorSubject广播新的事件给订阅者，并发送最近的(或者初始值)给行的而订阅者
```swift
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
```
#### 提示：注意这些之前的例子中都遗漏了什么？完成事件！`PublishSubject, ReplaySubject,BehaviorSubject`当他们即将被处理时，不能自动发出完成事件。
#### 4.Variable覆盖`BehaviorSubject`所以它将发送最近(或初始)的值给新的订阅者，并维持最近值得状态。`Variable`将不会发送错误事件，然而他会在销毁前发送完成事件和结束
```swift
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
```
#### 提示：一个`Variable`实例使用`asObservable`方法，访问它的原始队列，`Variables`没有实现`on`操作符(如`onNext(_:)`),但是作为替代，提供了一个`value`属性可以用作获取最近的值，也可以设置一个新的值，设置新值也会添加这个值到原始的`BehaviorSubject`队列。

第四章 组合运算符
----
操作符可以绑定多个`Observable`为一个`Observable`信号

#### 1. StarWith发送指定元素的在队列发出之前(在队列最前方插入)
```swift
example("startWith") {
let disposeBag = DisposeBag()

Observable.of("🐶", "🐱", "🐭", "🐹")
.startWith("1️⃣")
.startWith("2️⃣")
.startWith("3️⃣", "🅰️", "🅱️")
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
提示：如例所示如，`startWidth`可以连接成一个后进先出队列，所有继承`StartWidth`的元素都被添加到之前`StartWidth`元素之前
#### 2. merge 从源头合并多个`Observable`元素为一个信号队列，并且发送原`Observable`队列的事件
```swift
example("merge") {
let disposeBag = DisposeBag()

let subject1 = PublishSubject<String>()
let subject2 = PublishSubject<String>()

Observable.of(subject1, subject2)
.merge()
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)

subject1.onNext("🅰️")

subject1.onNext("🅱️")

subject2.onNext("①")

subject2.onNext("②")

subject1.onNext("🆎")

subject2.onNext("③")
}
``` 
#### 3.zip
绑定最多达8个`Observable`队列源为一个信号源，并发送按原始队列对应序号绑定后的元素，直到每个原始队列在该序号上都有元素。

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/combinelatest.png)


graph LR
1-->2;2-->3;3-->4;4-->5;5-->....  
A-->B;B-->C;C-->D;D-->...
```
zip后

```
graph LR
1A-->2B;2B-->3C;3C-->4D;4D-->...
```
```swift
example("zip") {
let disposeBag = DisposeBag()

let stringSubject = PublishSubject<String>()
let intSubject = PublishSubject<Int>()

Observable.zip(stringSubject, intSubject) { stringElement, intElement in
"\(stringElement) \(intElement)"
}
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)

stringSubject.onNext("🅰️")
stringSubject.onNext("🅱️")

intSubject.onNext(1)

intSubject.onNext(2)

stringSubject.onNext("🆎")
intSubject.onNext(3)
}
```


#### 4. combineLatest
绑定最多达8个`Observable`队列为一个新的信号队列，并绑定每个原始队列的最新的一个元素在一起为一个信号，在每个原始队列添加元素师都会发送一个新的绑定元素。

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/combinelatest.png)
```swift
example("combineLatest") {
let disposeBag = DisposeBag()

let stringSubject = PublishSubject<String>()
let intSubject = PublishSubject<Int>()

Observable.combineLatest(stringSubject, intSubject) { stringElement, intElement in
"\(stringElement) \(intElement)"
}
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)

stringSubject.onNext("🅰️")

stringSubject.onNext("🅱️")
intSubject.onNext(1)

intSubject.onNext(2)

stringSubject.onNext("🆎")
}
```
#### 提示：`combinLatest`基于数组的扩展要求原队列元素类型相同。元素按原队列序号依次添加111222333....

#### 5. switchLatest 转换`Observable`队列发送的元素，并发送内部队列里最近的值
```swift
example("switchLatest") {
let disposeBag = DisposeBag()

let subject1 = BehaviorSubject(value: "⚽️")
let subject2 = BehaviorSubject(value: "🍎")

let variable = Variable(subject1)

variable.asObservable()
.switchLatest()
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)

subject1.onNext("🏈")
subject1.onNext("🏀")

variable.value = subject2

subject1.onNext("⚾️")

subject2.onNext("🍐")
}

```
#### 提示：在这个例子中，在设置`variable.value=subject2`后添加⚾️到`subject1`不会产生任何影响，因为只有最近的内部`Observable`队列`subject2`才会发送元素

第五章 Transforming Operators 转换操作符
---
转换由`observable`队列发出的下一个事件元素
#### 1. map 应用一个转换闭包发送`observable`队列，返回一个转换后的新队列
```swift
example("map") {
let disposeBag = DisposeBag()
Observable.of(1, 2, 3)
.map { $0 * $0 }
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
#### 2. flatMap and flatMapLatest   
转换由`Observable`队列发出的元素，并合并多个为一个信号队列。
在任何一个队列发出行的元素师这个转换依然有效。`flatMap`和`flatMapLatest`的区别就在于`flatMapLast`只从内部队列发送最近的元素。
```swift
example("flatMap and flatMapLatest") {
let disposeBag = DisposeBag()

struct Player {
var score: Variable<Int>
}

let 👦🏻 = Player(score: Variable(80))
let 👧🏼 = Player(score: Variable(90))

let player = Variable(👦🏻)

player.asObservable()
.flatMap { $0.score.asObservable() } //修改flatmap为flatmaplatest观察打印输出的变化
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)

👦🏻.score.value = 85

player.value = 👧🏼

👦🏻.score.value = 95 //用flatMap时输出用flatMapLatest时不输出

👧🏼.score.value = 100
}
```
#### 提示：在这个例子中使用`flatMap`可能会产生意想不到的结果。在给👧🏼赋`值player.value`后`👧🏼.score`将开始发送元素。但是之前的内部队列`👦🏻.score`仍将继续发送元素.把`flatMap`改为`flatMapLatest`后只有内部的`Observable`队列(`👧🏼.score`)最近的元素才会被发送,设置`👦🏻.score.value`将不会有结果

#### 提示:flatMapLatest其实是组合了 map 和switchLatest 操作符.

#### 3. scan 以一个初始值开始执行累加的闭包，并发送每次累加后的结果
```swift
example("scan") {
let disposeBag = DisposeBag()

Observable.of(10, 100, 1000)
.scan(1) { aggregateValue, newValue in
aggregateValue + newValue
}
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
第六章 Filtering and Conditional Operators 过滤操作
---
选择性的发送原`Observable`队列的元素
#### 1. filter
只发送原`Observable`队列中符合条件的元素
```swift
example("filter") {
let disposeBag = DisposeBag()

Observable.of(
"🐱", "🐰", "🐶",
"🐸", "🐱", "🐰",
"🐹", "🐸", "🐱")
.filter {
$0 == "🐱"
}
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}

```
#### 2. distinctUntilChanged 阻止同一`Observable`队列多次发送相同元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/distinct.png)
```
example("distinctUntilChanged") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐱")
.distinctUntilChanged()
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```

#### 3. elementAt
只发`Observable`队列送指定位置上的元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/elementat.png)

```
example("elementAt") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.elementAt(3)
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```

#### 4. single 发送`Observabel`队列中的第一个满足条件的元素，如果没满足条件的元素这会发送一个错误(`error`)
```swift 
example("single") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.single()
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}

example("single with conditions") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.single { $0 == "🐸" }
.subscribe { print($0) }
.addDisposableTo(disposeBag)

Observable.of("🐱", "🐰", "🐶", "🐱", "🐰", "🐶")
.single { $0 == "🐰" }
.subscribe { print($0) }
.addDisposableTo(disposeBag)

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.single { $0 == "🔵" }
.subscribe { print($0) }
.addDisposableTo(disposeBag)
}
```
#### 5. take发送`Observable`队列d的前n个元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/take.png)
```swift
example("take") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.take(3)
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
//"🐱", "🐰", "🐶",
```
#### 6. takeLast发送`Observable`队列d的最后n个元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takelast.png)

```swift
example("take") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.take(3)
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
//"🐸", "🐷","🐵"
```
#### 7. takeWhile 发送指定条件为真前所有的元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takewhile.png)
```swift
example("takeWhile") {
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4, 5, 6)
.takeWhile { $0 < 4 }
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
//1,2,3
```
#### 8. takeUntil选择一个参考队列在该队列发送元素前发送本队列的元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takeuntil.png)
```swift
example("takeUntil") {
let disposeBag = DisposeBag()

let sourceSequence = PublishSubject<String>()
let referenceSequence = PublishSubject<String>()

sourceSequence
.takeUntil(referenceSequence)
.subscribe { print($0) }
.addDisposableTo(disposeBag)

sourceSequence.onNext("🐱")
sourceSequence.onNext("🐰")
sourceSequence.onNext("🐶")

referenceSequence.onNext("🔴")

sourceSequence.onNext("🐸")
sourceSequence.onNext("🐷")
sourceSequence.onNext("🐵")
}
```
#### 9.skip 跳过前n个元素，发送之后的元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skip.png)
```swift
example("skipWhile") {
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4, 5, 6)
.skipWhile { $0 < 4 }
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
.addDisposableTo(disposeBag)
}
```
#### 10.skipWhileWithIndex跳过条件成立之前的元素，发送满足条件之后的元素，闭包发送每个元素的`index`
```swift
example("skipWhileWithIndex") {
let disposeBag = DisposeBag()

Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
.skipWhileWithIndex { element, index in
index < 3
}
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)
}
```
#### 11. skipUntil跳过参考队列发送元素前本队列发送的元素
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skipuntil.png)
```swift
example("skipUntil") {
let disposeBag = DisposeBag()

let sourceSequence = PublishSubject<String>()
let referenceSequence = PublishSubject<String>()

sourceSequence
.skipUntil(referenceSequence)
.subscribe(onNext: { print($0) })
.addDisposableTo(disposeBag)

sourceSequence.onNext("🐱")
sourceSequence.onNext("🐰")
sourceSequence.onNext("🐶")

referenceSequence.onNext("🔴")

sourceSequence.onNext("🐸")
sourceSequence.onNext("🐷")
sourceSequence.onNext("🐵")
}
```
第七章 Connectable Operators可连接的操作符
---
可连接`Observable`队列除了在被订阅时不发送元素之外都和普通的`Observable`队列类似，作为替代可连接的`Observable`队列只在他们的`connect()`方法执行后才会发送元素。所以你可以订阅所有你想订阅的连接型`OBservable`队列在他发送元素之前
####  提示这个页面里的suo'you'li'zhi所有例子都有注释掉的代码，试着去掉这些注释重新运行观察结果，然后再把注释添加回来  
在开始学习可连接队列前我们来回顾一下不可连接队列的操作
```swift
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
```
#### 提示：`interval`创建一个在每个周期(`Period`)后发送元素的`Observable`队列
![](http://reactivex.io/documentation/operators/images/interval.c.png)


#### 1. publish 把元`Observable`队列转换成可连接的`Observable`队列
![](http://reactivex.io/documentation/operators/images/publishConnect.c.png)
```swift
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

//sampleWithPublish() // ⚠️ Uncomment to run this example; comment to stop running
```
#### 提示：执行操作室调度这只是一个抽象出来的概念，比如在指定线程和`dispatch queues`
