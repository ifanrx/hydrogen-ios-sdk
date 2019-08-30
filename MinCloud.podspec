Pod::Spec.new do |s|
  s.name             = 'MinCloud'
  s.version          = '0.2.0'
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
  s.subspec 'Core' do |core|
    core.source_files = 'MinCloud/*.{swift}'
    core.dependency 'Moya'
  end

  s.subspec 'Alipay' do |ali|
    ali.resource = 'MinCloud/AlipaySDK.bundle'
    ali.ios.vendored_frameworks = 'MinCloud/AlipaySDK.framework'
    ali.frameworks = "SystemConfiguration", "CoreTelephony", "CFNetwork", "CoreGraphics", "QuartzCore", "CoreText", "CoreMotion", "UIKit", "Foundation"
    ali.libraries = "z", "c++"
    ali.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/MinCloud' }
    ali.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/MinCloud' }
  end

  s.subspec 'WeChat' do |wx|
    wx.source_files = 'MinCloud/*.{h}'
    wx.vendored_libraries = 'MinCloud/libWeChatSDK.a'
    wx.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-Objc -all_load' }
    wx.frameworks = "SystemConfiguration", "CoreTelephony", "Security", "CoreGraphics", "CFNetwork"
    wx.libraries = "z", "c++", "sqlite3.0"
    wx.xcconfig = { "HEADER_SEARCH_PATHS" => "$(PODS_ROOT)/MinCloud" }
  end

  s.module_map = 'MinCloud/module.modulemap'
  s.static_framework = true
end
