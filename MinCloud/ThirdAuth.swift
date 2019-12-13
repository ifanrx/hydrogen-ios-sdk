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

@objc(BaaSThirdAuth)
open class ThirdAuth: NSObject {
    
    static public let shared = ThirdAuth()
    
    static var AuthProvider = MoyaProvider<AuthAPI>(plugins: logPlugin)
    
    @objc public func signInWeibo(_ completion: @escaping OBJECTResultCompletion) {
        sendAuthWithWeibo()
    }
    
    // 微信登录
    @objc public func signIn(_ completion: @escaping OBJECTResultCompletion) {
        sendAuthRequest()
    }
    
    private func sendAuthWithWeibo() {
        WeiboSDK.registerApp("542432732")
        let req = WBAuthorizeRequest()
        req.scope = "all"
        WeiboSDK.send(req)
    }
    
    private func sendAuthRequest() {
        WXApi.registerApp("wx4b3c1aff4c5389f5")
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        WXApi.send(req)
//        if WXApi.isWXAppInstalled() {
//
//        } else {
//            fatalError()
//        }
    }
    
    private func singInWechat(code: String) {
        ThirdAuth.AuthProvider.request(.wechat(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                user?.token = Storage.shared.token
                user?.expiresIn = Storage.shared.expiresIn
            })
        }
    }
    
    private func singInWeibo(code: String) {
        ThirdAuth.AuthProvider.request(.weibo(["auth_token": code])) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                user?.token = Storage.shared.token
                user?.expiresIn = Storage.shared.expiresIn
            })
        }
    }
    
}

extension ThirdAuth: WXApiDelegate {
    
    public func onResp(_ resp: BaseResp) {
        if let authResp =  resp as? SendAuthResp, let code = authResp.code {
            singInWechat(code: code)
        }
    }
}

extension ThirdAuth: WeiboSDKDelegate {
    public func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        
        if let authResp = response as? WBAuthorizeResponse, let token = authResp.accessToken {
            singInWechat(code: token)
        }
    }
}
