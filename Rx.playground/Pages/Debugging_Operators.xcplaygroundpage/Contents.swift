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
 # 附录(一) 调试
为了方便调试Rx代码的操作符。
 ## `debug`
 打印多有的`subscriptions, events, disposals`
 */
example("debug") {
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
        .debug()
        .subscribe(onNext: { print($0) })
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `RxSwift.Resources.total`
 RxSwift.Resources.total 提供一个对所有`allocation`的计数，来观察是否有内存泄漏。
 */
#if NOT_IN_PLAYGROUND
#else
example("RxSwift.Resources.total") {
    print(RxSwift.Resources.total)
    
    let disposeBag = DisposeBag()
    
    print(RxSwift.Resources.total)
    
    let variable = Variable("🍎")
    
    let subscription1 = variable.asObservable().subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    let subscription2 = variable.asObservable().subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    subscription1.dispose()
    
    print(RxSwift.Resources.total)
    
    subscription2.dispose()
    
    print(RxSwift.Resources.total)
}
    
print(RxSwift.Resources.total)
#endif
//: > `RxSwift.Resources.total` 默认是不可用的, 一般不在发布版本中启用. [点此](Enable_RxSwift.Resources.total) 了解怎样使其可用.

//: [下一章](@next) - [返回目录](Table_of_Contents)
