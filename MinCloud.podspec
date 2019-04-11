Pod::Spec.new do |s|
  s.name             = 'MinCloud'
  s.version          = '0.0.6'
  s.summary          = '知晓云 iOS SDK'
 
  s.description      = <<-DESC
知晓云是一个实时的后端云服务。使用它后，开发人员只需简单地在 App 中接入 SDK，而无需管理服务器或编写后端代码，即可轻松构建功能丰富的 App。
                       DESC
 
  s.swift_version    = '4.2'
  s.homepage         = 'https://github.com/ifanrx/hydrogen-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pengquanhua' => 'pengquanhua@ifanr.com' }
  s.source           = { :git => 'https://github.com/ifanrx/hydrogen-ios-sdk.git', :commit => '623ac9433bbd1ecc605ba4adbff7cf61e965e42e' }
 
  s.ios.deployment_target = '9.0'
  s.source_files = 'MinCloud/*.swift'
  s.dependency "Moya"
 
end
