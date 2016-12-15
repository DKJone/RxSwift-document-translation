
 [上一页](/Combining_Operators.md) - [返回目录](/README.md)

# 第四章 转换
转换由`observable`队列发出的下一个事件元素。
## `map`
 应用一个转换闭包发送`observable`队列，返回一个转换后的新队列。 [更多信息](http://reactivex.io/documentation/operators/map.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/map.png)
```swift
example("map") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2, 3)
        .map { $0 * $0 }
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
```

----
 
## `flatMap` 和 `flatMapLatest`
 转换由`Observable`队列发出的元素，并合并多个为一个信号队列。 [更多信息](http://reactivex.io/documentation/operators/flatmap.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/flatmap.png)
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
    
    👦🏻.score.value = 95 // 用flatMap时输出用flatMapLatest时不输出
    👧🏼.score.value = 100
}
```
> 在这个例子中使用`flatMap`可能会产生意想不到的结果。在给👧🏼赋`值player.value`后`👧🏼.score`将开始发送元素。但是之前的内部队列`👦🏻.score`仍将继续发送元素.把`flatMap`改为`flatMapLatest`后只有内部的`Observable`队列(`👧🏼.score`)最近的元素才会被发送,设置`👦🏻.score.value`将不会有结果。
#
> flatMapLatest其实是组合了 map 和switchLatest 操作符。


----
 
## `scan`
 以一个初始值开始执行累加的闭包，并发送每次累加后的结果。 [更多信息](http://reactivex.io/documentation/operators/scan.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/scan.png)
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
[下一章](/Filtering_and_Conditional_Operators.md) - [返回目录](/README.md)
