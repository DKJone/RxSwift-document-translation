
 [上一页](/Filtering_and_Conditional_Operators.md) - [返回目录](/README.md)

# 第六章 数学理论
 对整个`Observable`队列的所有元素进行操作。
## `toArray`
 把一个`Observable` 队列转换成一个`Array`,然后发送一个包含这个数组的单一元素队列（single-element `Observable` sequence），发送完成停止队列[更多信息](http://reactivex.io/documentation/operators/to.html)
 ![](http://reactivex.io/documentation/operators/images/to.c.png)
 ```swift
example("toArray") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .toArray()
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
}
```
 
 ----
 
## `reduce`
 以一个种子值作为开始执行累加闭包的内容，将操作完售楼元素得到的结果作为一个单一元素队列发送，复燃后停止队列。[更多信息](http://reactivex.io/documentation/operators/reduce.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/reduce.png)
 ```swift
example("reduce") {
    let disposeBag = DisposeBag()
    
    Observable.of(10, 100, 1000)
        .reduce(1, accumulator: +)
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
```
 
 ----
 
## `concat`
 将另一个`Observable`队列元素有序的加入内部`Observable`队列，直到一个队列`completed`事件发出后在开始加入下一个队列元素，`completed`事件发送之前的事件不会被发送新队列之前的元素 [更多信息](http://reactivex.io/documentation/operators/concat.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/concat.png)
 ```swift
example("concat") {
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "🍎")
    let subject2 = BehaviorSubject(value: "🐶")
    
    let variable = Variable(subject1)
    
    variable.asObservable()
        .concat()
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    subject1.onNext("🍐")
    subject1.onNext("🍊")
    
    variable.value = subject2
    
    subject2.onNext("I would be ignored")
    subject2.onNext("🐱")
    
    subject1.onCompleted()
    
    subject2.onNext("🐭")
}

//: [下一章](/Connectable_Operators.md) - [返回目录](/README.md)
