
[上一页](/Connectable_Operators.md) - [返回目录](/README.md)

# 第八章 错误处理
处理一个`Observable`发出的错误通知的操作符。
## `catchErrorJustReturn`
 让队列从错误事件中恢复，并发送一个单一元素的队列，然后停止原队列。 [更多信息](http://reactivex.io/documentation/operators/catch.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)
```swift
example("catchErrorJustReturn") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    
    sequenceThatFails
        .catchErrorJustReturn("😊")
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onNext("😡")
    sequenceThatFails.onNext("🔴")
    sequenceThatFails.onError(TestError.test)
}
```

----
 
## `catchError`
 catchError从错误事件中恢复并切换到提供的恢复队列。 [更多信息](http://reactivex.io/documentation/operators/catch.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)
 ```swift
example("catchError") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    let recoverySequence = PublishSubject<String>()
    
    sequenceThatFails
        .catchError {
            print("Error:", $0)
            return recoverySequence
        }
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onNext("😡")
    sequenceThatFails.onNext("🔴")
    sequenceThatFails.onError(TestError.test)
    
    recoverySequence.onNext("😊")
}
```

----
 
## `retry`
 从错误中恢复并尝试重新订阅产生错误的队列。 [更多信息](http://reactivex.io/documentation/operators/retry.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)
 ```swift
example("retry") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count == 1 {
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry()
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
```

----
 
## `retry(_:)`
从错误中恢复并尝试重新订阅产生错误的队列, 在达到`maxAttemptCount`次数之前尝试. [更多信息](http://reactivex.io/documentation/operators/retry.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)
```swift
example("retry maxAttemptCount") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count < 5 {
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry(3)
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
```
[下一章](/Debugging_Operators.md) - [返回目录](/README.md)
