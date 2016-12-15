//: [返回前一页](@previous)
/*:
 # 附录二 cocoapods
 通过以下指令把 `RxSwift.Resources.total` 加入你的项目:
 **CocoaPods**
 1. 添加一个 `post_install` 在你的 Podfile中, 例如:
 ```
 target 'AppTarget' do
 pod 'RxSwift'
 end
 
 post_install do |installer|
     installer.pods_project.targets.each do |target|
         if target.name == 'RxSwift'
             target.build_configurations.each do |config|
                 if config.name == 'Debug'
                     config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                 end
             end
         end
     end
 end
 ```
 2. 执行 `pod update`.
 3. 编译项目 (**Product** → **Build**).
 #
 **Carthage**
 1. 执行 `carthage build --configuration Debug`.
 2. 编译项目 (**Product** → **Build**).
 */
