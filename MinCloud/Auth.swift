//
//  Auth.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result
import AuthenticationServices

// 第三方授权类型
@objc(Provider)
public enum Provider: Int {
    case wechat
    case weibo
    case apple
}

@objc(SyncUserProfileType)
public enum SyncUserProfileType: Int {
    case overwrite
    case setnx
    case `false`
}

// 授权登录或授权绑定
private enum ThirdAuthType {
    case associate
    case authenticate
}

protocol WechatAuth {
    
}

@objc(BaaSAuth)
open class Auth: NSObject {
    
    static var AuthProvider = MoyaProvider<AuthAPI>(plugins: logPlugin)
    static fileprivate var completion: CurrentUserResultCompletion?
    static fileprivate var thirdAuthType: ThirdAuthType?
    static fileprivate var createUser: Bool?
    static fileprivate var syncUserProfile: SyncUserProfileType?

    /// 用户是否已经登录
    @objc public static var hadLogin: Bool {
        if Storage.shared.token != nil, let expiresIn = Storage.shared.expiresIn, expiresIn > Date().timeIntervalSince1970 {
            return true
        }
        return false
    }

    // MARK: - 注册

    /// 用户名注册
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - completion: 注册回调结果
    @discardableResult
    @objc public static func register(username: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.register(.username, ["username": username, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 邮箱注册
    ///
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - password: 密码
    ///   - completion: 注册回调结果
    @discardableResult
    @objc public static func register(email: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request =  AuthProvider.request(.register(.email, ["email": email, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // MARK: - 登录

    /// 用户名登录
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - completion: 登录回调结果
    @discardableResult
    @objc public static func login(username: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.username, ["username": username, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 邮箱登录
    ///
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - password: 密码
    ///   - completion: 登录结果回调
    @discardableResult
    @objc public static func login(email: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.email, ["email": email, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 匿名登录
    ///
    /// - Parameter completion: 登录结果回调
    @discardableResult
    @objc public static func anonymousLogin(_ completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.anonymous, [:])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
    
    /// 手机号 + 短信验证码登录
    ///
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证码
    ///   - createUser: 该参数决定了一个新用户第一次登录时的服务端处理行为。
    ///                 默认为 true，服务端会有该用户创建一个知晓云用户记录。
    ///                 当 createUser 为 false 时，服务端会终止登录过程，返回 404 错误码，开发者可根据该返回结果进行多平台账户绑定的处理。
    ///   - completion: 登录结果回调
    @discardableResult
    @objc public static func signInWithSMSVerificationCode(_ phone: String, code: String, createUser: Bool = true, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.sms(["phone": phone, "code": code, "create_user": createUser])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 用户登出
    ///
    /// - Parameter completion: 登出结果回调
    @discardableResult
    @objc public static func logout(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.logout) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    Storage.shared.reset()
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // 获取当前用户
    @discardableResult
    @objc public static func getCurrentUser(_ completion: @escaping CurrentUserResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin && Storage.shared.userId != nil else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(nil, error as NSError)
            return nil
        }

        let request = User.UserProvider.request(.getUserInfo(userId: Storage.shared.userId!, parameters: [:])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                user?.token = Storage.shared.token
                user?.expiresIn = Storage.shared.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
    
}

extension Auth {
    
    /// 授权第三方平台登录
    ///
    /// - Parameters:
    ///   - type: 平台类型: wechat-微信，weibo-微博，apple-苹果
    ///   - createUser: 是否创建用户。该参数决定了一个新的微信用户第一次登录时的服务端处理行为。
    ///                 默认为 true，服务端会有该用户创建一个知晓云用户记录。
    ///                 当 createUser 为 false 时，服务端会终止登录过程，返回 404 错误码，开发者可根据该返回结果进行多平台账户绑定的处理。
    ///   - syncUserProfile: 同步第三方平台用户信息方式：overwrite-强制更新，setnx-仅当字段从未被赋值时才更新，false-不更新
    ///   - completion: 登录结果回调
    @objc static public func signIn(with provider: Provider, createUser: Bool = true, syncUserProfile: SyncUserProfileType = .setnx, completion: @escaping CurrentUserResultCompletion) {
        
        switch provider {
        case .wechat:
            ThirdProxy.shared.sendWechatAuthRequset()
        case .apple:
            ThirdProxy.shared.sendAppleAuthRequest()
        case .weibo:
            ThirdProxy.shared.sendWeiboAuthRequset()
        }

        Auth.syncUserProfile = syncUserProfile
        Auth.createUser = createUser
        Auth.thirdAuthType = .authenticate
        Auth.completion = completion
        
    }
    
    /// 将当前登录账号关联到第三方平台
    ///
    /// - Parameters:
    ///   - type: 平台类型: wechat-微信，weibo-微博，apple-苹果
    ///   - syncUserProfile: 同步第三方平台用户信息方式：overwrite-强制更新，setnx-仅当字段从未被赋值时才更新，false-不更新
    ///   - completion: 登录结果回调
    @objc static public func associate(with provider: Provider, syncUserProfile: SyncUserProfileType = .setnx, completion: @escaping CurrentUserResultCompletion) {
        
        switch provider {
        case .wechat:
            ThirdProxy.shared.sendWechatAuthRequset()
        case .apple:
            ThirdProxy.shared.sendAppleAuthRequest()
        case .weibo:
            ThirdProxy.shared.sendWeiboAuthRequset()
        }

        Auth.syncUserProfile = syncUserProfile
        Auth.thirdAuthType = .associate
        Auth.completion = completion
    }
    
    fileprivate static func authWithWechat(code: String) {
        
        let apiType: AuthAPI
        switch Auth.thirdAuthType! {
        case .associate:
            apiType = .associationForWechat(["auth_token": code, "sync_user_profile": Auth.getSyncProfile(Auth.syncUserProfile)])
        case .authenticate:
            apiType = .wechat(["auth_token": code, "create_user": Auth.createUser ?? true, "sync_user_profile": Auth.getSyncProfile(Auth.syncUserProfile)])
        }
        
        Auth.AuthProvider.request(apiType) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                if case .authenticate = Auth.thirdAuthType {
                    Storage.shared.userId = user?.userId
                    Storage.shared.token = user?.token
                    Storage.shared.expiresIn = user?.expiresIn
                }
                
                Auth.completion?(user, error)
            })
        }
    }
    
    fileprivate static func authWithWeibo(code: String, uid: String) {
        let apiType: AuthAPI
        switch Auth.thirdAuthType! {
        case .associate:
            apiType = .associationForWeibo(["access_token": code, "uid": uid])
        case .authenticate:
            apiType = .weibo(["access_token": code, "uid": uid, "create_user": Auth.createUser ?? true])
        }
        
        Auth.AuthProvider.request(apiType) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                if case .authenticate = Auth.thirdAuthType {
                    Storage.shared.userId = user?.userId
                    Storage.shared.token = user?.token
                    Storage.shared.expiresIn = user?.expiresIn
                }
                
                Auth.completion?(user, error)
            })
        }
    }
    
    
    fileprivate static func authWithApple(authToken: String, nickname: String) {
        let apiType: AuthAPI
        switch Auth.thirdAuthType! {
        case .associate:
            apiType = .associationForApple(["auth_token": authToken, "nickname": nickname])
        case .authenticate:
            apiType = .apple(["auth_token": authToken, "nickname": nickname, "create_user": Auth.createUser ?? true])
        }
        
        Auth.AuthProvider.request(apiType) { (result) in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                if case .authenticate = Auth.thirdAuthType {
                    Storage.shared.userId = user?.userId
                    Storage.shared.token = user?.token
                    Storage.shared.expiresIn = user?.expiresIn
                }
                
                Auth.completion?(user, error)
            })
        }
    }
        
    private static func getSyncProfile(_ sync: SyncUserProfileType?) -> String {
        let type = sync ?? SyncUserProfileType.setnx
        switch type {
        case .overwrite:
            return "overwrite"
        case .setnx:
            return "setnx"
        case .false:
            return "false"
        }
    }
}


// 内部代理类，用于接收第三方平台的回调方法
class ThirdProxy: NSObject {
    static let shared = ThirdProxy()
}

extension ThirdProxy: WXApiDelegate {
    
    public func onResp(_ resp: BaseResp) {
        if let authResp =  resp as? SendAuthResp, let code = authResp.code {
            Auth.authWithWechat(code: code)
        } else {
            Auth.completion?(nil, HError(code: 500, description: Localisation.Wechat.authorizeFail) as NSError)
        }
    }
    
    func sendWechatAuthRequset() {
        assert(Config.wechatAppId != nil, Localisation.Wechat.registerAppId)
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        WXApi.send(req)
    }
}

extension ThirdProxy: WeiboSDKDelegate {
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        
        if let authResp = response as? WBAuthorizeResponse, let token = authResp.accessToken, let uid = authResp.userID {
            Auth.authWithWeibo(code: token, uid: uid)
        } else {
            Auth.completion?(nil, HError(code: 500, description: Localisation.Weibo.authorizeFail) as NSError)
        }
    }
    
    func sendWeiboAuthRequset() {
        assert(Config.weiboAppId != nil, Localisation.Weibo.registerAppId)
        
        let req = WBAuthorizeRequest()
        req.redirectURI = Config.redirectURI
        req.scope = "all"
        WeiboSDK.send(req)
    }
}

extension ThirdProxy: ASAuthorizationControllerDelegate {
    
    func sendAppleAuthRequest() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = ThirdProxy.shared
            authorizationController.presentationContextProvider = ThirdProxy.shared
            authorizationController.performRequests()
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let nickname = appleIDCredential.fullName?.nickname ?? ""
            
            if case appleIDCredential.realUserStatus = ASUserDetectionStatus.unsupported {
                
            }

            if let token = appleIDCredential.identityToken, let tokenStr = String(data: token, encoding: .utf8) {
                Auth.authWithApple(authToken: tokenStr, nickname: nickname)
            } else {
                Auth.completion?(nil, HError(code: 500, description: Localisation.Apple.authorizeFail) as NSError)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Auth.completion?(nil, error as NSError)
    }
}

extension ThirdProxy: ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}


