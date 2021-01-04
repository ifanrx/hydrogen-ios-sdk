//
//  BaaS.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

/// MinCloud 全局类，主要实现通用功能。
@objc public class BaaS: NSObject {
    @objc public static func register(clientID: String, serverURLString: String? = nil) {
        Config.clientID = clientID
        Config.serverURLString = serverURLString
    }
    
    
    
    /// 注册微信 appId
    /// - Parameters:
    ///   - appId: 在微信开放平台注册获取的 appId
    ///   - universalLink: 在微信开放平台注册获取的 universalLink
    @objc public static func registerWechat(_ appId: String, universalLink: String) {
        Config.wechatAppId = appId
        WXApi.registerApp(appId, universalLink: universalLink)
    }
    
    /// 注册微博 appId
    /// - Parameters:
    ///   - appId: 在微博开放平台注册获取的 appId
    ///   - redirectURI: 在微博开放平台注册获取的 appId
    @objc public static func registerWeibo(_ appId: String, redirectURI: String) {
        Config.weiboAppId = appId
        Config.redirectURI = redirectURI
        WeiboSDK.registerApp(appId)
    }

    /// 是否开启调试模式，默认不开启。开启后将打印调试日志。
    @objc public static var isDebug: Bool = false
    
    static var BaasProvider = MoyaProvider<BaaSAPI>(plugins: logPlugin)
    
    /// 获取 MinCloud 当前版本
    /// - Returns: 当前版本
    @objc public static func getVersion() -> String {
        return Config.version
    }

    /// 触发云函数
    ///
    /// - Parameters:
    ///   - name: 云函数名称
    ///   - data: 云函数参数，具体使用请参照文档：https://doc.minapp.com/ios-sdk/invoke-function.html
    ///   - sync: 是否等待执行结果
    ///   - callBackQueue: 回调函数执行队列
    ///   - completion: 执行结果
    /// - Returns:
    @discardableResult
    @objc public static func invoke(name: String, data: Any, sync: Bool, callBackQueue: DispatchQueue = .main, completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.invokeFunction(parameters: ["function_name": name, "data": data, "sync": sync]), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (invokeResult: MappableDictionary?, error: NSError?) in
                completion(invokeResult?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 发送短信验证码
    ///
    /// - Parameters:
    ///   - phone: 手机号
    ///   - callBackQueue: 回调函数执行队列
    ///   - completion: 发送结果
    /// - Returns:
    @discardableResult
    @objc public static func sendSmsCode(phone: String, callBackQueue: DispatchQueue = .main, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.sendSmsCode(parameters: ["phone": phone]), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 验证手机已接收的验证码
    ///
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证
    ///   - callBackQueue: 回调函数执行队列
    ///   - completion: 验证结果
    /// - Returns:
    @discardableResult
    @objc public static func verifySmsCode(phone: String, code: String, callBackQueue: DispatchQueue = .main, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.verifySmsCode(parameters: ["phone": phone, "code": code]), callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }
    
    /// 获取服务器时间
    ///
    /// - Parameters:
    ///   - callBackQueue: 回调函数执行队列
    ///   - completion: 获取服务器时间结果
    /// - Returns:
    @discardableResult
    @objc public static func getServerTime(callBackQueue: DispatchQueue = .main, completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.getServerTime, callbackQueue: callBackQueue) { result in
            ResultHandler.parse(result, handler: { (invokeResult: MappableDictionary?, error: NSError?) in
                completion(invokeResult?.value, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}

// 微信支付
extension BaaS {

    /// 检查微信是否已被用户安装
    ///
    /// - Returns: 微信已安装返回YES，未安装返回NO。
    @objc public static func isWXAppInstalled() -> Bool {
        return WXApi.isWXAppInstalled()
    }

    /// 处理微信或支付宝通过URL启动App时传递的数据
    /// 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
    ///
    /// - Parameter url: 微信或支付宝启动第三方应用时传递过来的URL
    /// - Returns: 成功返回YES，失败返回NO。
    @objc public static func handleOpenURL(url: URL) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: nil)
            return true
        } else if url.host == "pay" {
            return WXApi.handleOpen(url, delegate: nil)
        } else if url.host == "oauth" {
            return WXApi.handleOpen(url, delegate: ThirdProxy.shared)
        } else if url.host == "response" {
            return WeiboSDK.handleOpen(url, delegate: ThirdProxy.shared)
        }
        return true
    }
    
    /// 适配了 SceneDelegate 的 App，
    /// 系统将会回调 SceneDelegate 的 continueUserActivity 方法，
    /// 所以需要重写 SceneDelegate 的该方法，并在 continueUserActivity 内调用 handleOpenUniversalLink 方法。
    @objc public static func handleOpenUniversalLink(userActivity: NSUserActivity) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: ThirdProxy.shared)
    }
}
