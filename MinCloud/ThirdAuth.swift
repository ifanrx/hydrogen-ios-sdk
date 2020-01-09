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

    private var completion: CurrentUserResultCompletion?
    
    private var type: Type?
    
    static var AuthProvider = MoyaProvider<AuthAPI>(plugins: logPlugin)
    
    @objc public func signInWeibo(_ completion: @escaping CurrentUserResultCompletion) {
        self.type = .authenticate
        self.completion = completion
        sendAuthWithWeibo()
    }
    
    // 微信登录
    @objc public func signInWechat(_ completion: @escaping CurrentUserResultCompletion) {

        self.type = .authenticate
        self.completion = completion
        sendAuthRequest()
    }
    
    // 苹果登录
    @objc public func signInApple(_ completion: @escaping CurrentUserResultCompletion) {

        self.type = .authenticate
        self.completion = completion
    }
    
    @objc public func associateWeibo(_ completion: @escaping CurrentUserResultCompletion) {
        self.type = .association
        sendAuthWithWeibo()
    }
    
    @objc public func associateWechat(_ completion: @escaping CurrentUserResultCompletion) {
        self.type = .association
        self.completion = completion
        sendAuthRequest()
    }
    
    @objc public func associateApple(authToken: String, nickname: String, completion: @escaping CurrentUserResultCompletion) {

    }
    
    private func sendAuthWithWeibo() {
        WeiboSDK.enableDebugMode(true)
        guard let appId = Config.weiboAppid else {
            fatalError("请绑定微博 appKey")
        }
        WeiboSDK.registerApp(appId)
        let req = WBAuthorizeRequest()
        req.scope = "all"
        WeiboSDK.send(req)
    }
    
    private func sendAuthRequest() {
        guard let appId = Config.wechatAppid else {
            fatalError("请绑定微信 appKey!")
        }
        WXApi.registerApp(appId)
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
                
                self.completion?(user, error)
            })
        }
    }
    
    private func signInWeibo(code: String) {
        ThirdAuth.AuthProvider.request(.weibo(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                self.completion?(user, error)
            })
        }
    }
    
    private func associateWeibo(code: String) {
        ThirdAuth.AuthProvider.request(.wbassociation(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
//                user?.token = Storage.shared.token
//                user?.expiresIn = Storage.shared.expiresIn
                self.completion?(user, error)
            })
        }
    }
    
    private func associateWechat(code: String) {
        ThirdAuth.AuthProvider.request(.wxassociation(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
//                user?.token = Storage.shared.token
//                user?.expiresIn = Storage.shared.expiresIn
                self.completion?(user, error)
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
