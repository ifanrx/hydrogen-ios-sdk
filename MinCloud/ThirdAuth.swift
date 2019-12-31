//
//  ThirdAuth.swift
//  MinCloud
//
//  Created by quanhua on 2019/12/13.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

private enum Type {
    case association
    case authenticate
}

@objc(BaaSThirdAuth)
open class ThirdAuth: NSObject {
    
    static public let shared = ThirdAuth()
    
    private var wechatAppKey: String?
    private var weiboAppKey: String?
    
    private var type: Type?
    
    static var AuthProvider = MoyaProvider<AuthAPI>(plugins: logPlugin)
    
    @objc public func setWeChat(with appKey: String) {
        wechatAppKey = appKey
    }
    
    @objc public func setWeiBo(with appKey: String) {
        weiboAppKey = appKey
    }
    
    @objc public func signInWeibo(_ completion: @escaping OBJECTResultCompletion) {
        self.type = .authenticate
        sendAuthWithWeibo()
    }
    
    // 微信登录
    @objc public func signIn(_ completion: @escaping OBJECTResultCompletion) {
        self.type = .authenticate
        sendAuthRequest()
    }
    
    @objc public func associateWeibo(_ completion: @escaping OBJECTResultCompletion) {
        self.type = .association
        sendAuthWithWeibo()
    }
    
    @objc public func associateWexin(_ completion: @escaping OBJECTResultCompletion) {
        self.type = .association
        sendAuthRequest()
    }
    
    private func sendAuthWithWeibo() {
        WeiboSDK.enableDebugMode(true)
        guard let appKey = weiboAppKey else {
            fatalError("请绑定微博 appKey")
        }
        WeiboSDK.registerApp(appKey)
        let req = WBAuthorizeRequest()
        req.scope = "all"
        WeiboSDK.send(req)
    }
    
    private func sendAuthRequest() {
        guard let wechatAppKey = wechatAppKey else {
            fatalError("请绑定微信 appKey!")
        }
        WXApi.startLog(by: .normal) { (log) in
            print("log: \(log)")
        }
        WXApi.registerApp(wechatAppKey)
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        WXApi.send(req)
    }
    
    private func signInWechat(code: String) {
        ThirdAuth.AuthProvider.request(.wechat(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
            })
        }
    }
    
    private func signInWeibo(code: String) {
        ThirdAuth.AuthProvider.request(.weibo(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
            })
        }
    }
    
    private func associateWeibo(code: String) {
        ThirdAuth.AuthProvider.request(.wbassociation(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
//                user?.token = Storage.shared.token
//                user?.expiresIn = Storage.shared.expiresIn
            })
        }
    }
    
    private func associateWechat(code: String) {
        ThirdAuth.AuthProvider.request(.wxassociation(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
//                user?.token = Storage.shared.token
//                user?.expiresIn = Storage.shared.expiresIn
            })
        }
    }
    
}

extension ThirdAuth: WXApiDelegate {
    
    public func onResp(_ resp: BaseResp) {
        if let authResp =  resp as? SendAuthResp, let code = authResp.code {
            switch type! {
            case .association:
                associateWechat(code: code)
            case .authenticate:
                signInWechat(code: code)
            }
        }
    }
}

extension ThirdAuth: WeiboSDKDelegate {
    public func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        
        if let authResp = response as? WBAuthorizeResponse, let token = authResp.accessToken {
            switch type! {
            case .association:
                associateWeibo(code: token)
            case .authenticate:
                signInWeibo(code: token)
            }
        }
    }
}
