Pod::Spec.new do |s|
  s.name             = 'MinCloud'
  s.version          = '0.2.0-beta1'
  s.summary          = '知晓云 iOS SDK'
 
  s.description      = <<-DESC
知晓云是一个实时的后端云服务。使用它后，开发人员只需简单地在 App 中接入 SDK，而无需管理服务器或编写后端代码，即可轻松构建功能丰富的 App。
                       DESC
 
  s.swift_version    = '5.0'
  s.homepage         = 'https://cloud.minapp.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pengquanhua' => 'pengquanhua@ifanr.com' }
  s.source           = { :git => 'https://github.com/ifanrx/hydrogen-ios-sdk.git', :tag => s.version }
 
  s.ios.deployment_target = '9.0'
  s.source_files = 'MinCloud/*.{h,m,swift}'
  s.dependency 'Moya'

  s.vendored_libraries = 'MinCloud/*.a'
  s.frameworks = "SystemConfiguration", "Security", "CoreTelephony", "CFNetwork","CoreGraphics", "CoreTelephony", "QuartzCore", "CoreText", "CoreMotion", "UIKit", "Foundation"
  s.libraries = "z", "sqlite3.0", "c++"
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC -all_load' }
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/MinCloud' }

  s.ios.vendored_frameworks = 'MinCloud/*.framework'
  s.resource = 'MinCloud/PayLibrary/AliPay/AlipaySDK.bundle'

end
