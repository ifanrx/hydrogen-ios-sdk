//
//  BaaS.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc public class BaaS: NSObject {
    @objc public static func register(clientID: String) {
        Config.clientID = clientID
    }

    @objc public static var isDebug: Bool = false

    @discardableResult
    @objc public static func invoke(name: String, data: Any, sync: Bool, completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.invokeFunction(parameters: ["function_name": name, "data": data, "sync": sync])) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc public static func sendSmsCode(phone: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.sendSmsCode(parameters: ["phone": phone])) { result in
            let (_, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc public static func verifySmsCode(phone: String, code: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.verifySmsCode(parameters: ["phone": phone, "code": code])) { result in
            let (_, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}

// 微信支付
extension BaaS {
    /*! @brief 检查微信是否已被用户安装
     *
     * @return 微信已安装返回YES，未安装返回NO。
     */
    @objc public static func isWXAppInstalled() -> Bool {
        return WXApi.isWXAppInstalled()
    }

    /*! @brief 处理微信通过URL启动App时传递的数据
     *
     * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
     * @param url 微信启动第三方应用时传递过来的URL
     * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
     * @return 成功返回YES，失败返回NO。
     */
    @objc public static func handleOpenURL(url: URL) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: nil)
            return true
        } else if url.host == "pay" {
            return WXApi.handleOpen(url, delegate: Pay.shared)
        }
        return true
    }
}
