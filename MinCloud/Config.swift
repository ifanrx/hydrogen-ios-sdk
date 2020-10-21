//
//  Config.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum NetworkEnvironment {
    case qa
    case production
}

enum AuthType: String {
    case username
    case email
    case anonymous
}

let logPlugin: [PluginType] = BaaS.isDebug ? [NetworkLoggerPlugin(verbose: true)] : []
let WXPay = "weixin_tenpay_app"
let AliPay = "alipay_app"

struct Config {
    static let environment: NetworkEnvironment = .production
    
    static var clientID: String!
    static var serverURLString: String?
    static var version = "1.2.1"    // MinCloud 当前版本号
    static var wechatAppId: String?
    static var weiboAppId: String?
    static var redirectURI: String?
    
    static var baseURL: String {
        if environment == .qa {
            return "https://viac2-p.eng-vm.can.corp.ifanr.com"
        }

        guard clientID != nil else {
            fatalError(Localisation.Common.registerClientId)
        }
        
        return serverURLString ?? "https://\(clientID!).myminapp.com"
    }

    static var HTTPHeaders: [String: String] {
        guard clientID != nil else { fatalError(Localisation.Common.registerClientId) }
        var headers: [String: String] = [:]
        headers["X-Hydrogen-Client-ID"] = clientID
        headers["Content-Type"] = "application/json"
        headers["X-Hydrogen-Client-Platform"] = "NATIVE_IOS"
        headers["X-Hydrogen-Client-Version"] = version
        if let token = Storage.shared.token {
            headers["Authorization"] = "Hydrogen-r1 \(token)"
        }
        return headers
    }

    struct Auth {
        static func register(authType: AuthType) -> String { return "/hserve/v2.0/register/\(authType.rawValue)/" }
        static func login(authType: AuthType) -> String { return "/hserve/v2.0/login/\(authType.rawValue)/" }
        static let logout = "/hserve/v2.0/session/destroy/"
        static let apple = "hserve/v2.3/idp/oauth/apple-native/authenticate/"
        static let wechat = "/hserve/v2.3/idp/oauth/wechat-native/authenticate/"
        static let weibo = "/hserve/v2.3/idp/oauth/weibo-native/authenticate/"
        static let weiboAssociation = "/hserve/v2.3/idp/oauth/weibo-native/user-association/"
        static let wechatAssociation = "/hserve/v2.3/idp/oauth/wechat-native/user-association/"
        static let appleAssociation = "/hserve/v2.3/idp/oauth/apple-native/user-association/"
        static let loginSms = "/hserve/v2.1/login/sms/"
    }

    struct User {
        static func getUserInfo(userId: String) -> String { return "/hserve/v2.1/user/info/\(userId)/" }
        static let updateAccount = "/hserve/v2.1/user/account/"
        static let resetPassword = "/hserve/v2.0/user/password/reset/"
        static let requestEmailVerify = "/hserve/v2.0/user/email-verify/"
        static let updateUserInfo = "/hserve/v2.1/user/info/"
        static let getUserList = "/hserve/v2.2/user/info/"
        static let verifyPhone = "/hserve/v2.1/sms-phone-verification/"
    }

    struct Table {
        static func recordDetail(tableId: String, recordId: String) -> String { return "/hserve/v2.1/table/\(tableId)/record/\(recordId)/" }
        static func recordList(tableId: String) -> String { return "/hserve/v2.2/table/\(tableId)/record/" }
        static func saveRecord(tableId: String) -> String { return "/hserve/v2.2/table/\(tableId)/record/" }
    }

    struct ContentGroup {
        static let contentList = "/hserve/v2.2/content/detail/"
        static let groupList = "/hserve/v2.2/content/group/"
        static func contentDetail(contentId: String) -> String { return "/hserve/v1.3/content/detail/\(contentId)/" }
        static let groupDetail = "/hserve/v1/content/category/"
        static let categoryList = "/hserve/v2.2/content/category/"
        static func categoryDetail(categoryId: String) -> String { return "/hserve/v1/content/category/\(categoryId)/" }
    }

    struct File {
        static let upload = "/hserve/v2.1/upload/"
        static func fileDetail(fileId: String) -> String { return "/hserve/v1.3/uploaded-file/\(fileId)/" }
        static let fileList = "/hserve/v2.2/uploaded-file/"
        static func deleteFile(fileId: String) -> String { return "/hserve/v1.3/uploaded-file/\(fileId)/" }
        static let deleteFiles = "/hserve/v1.3/uploaded-file/"
        static func categoryDetail(categoryId: String) -> String { return "/hserve/v1.3/file-category/\(categoryId)/" }
        static let fileCategoryList = "/hserve/v2.2/file-category/"
        static let gensorImage = "/hserve/v1.7/censor-image/"
        static let gensorMsg = "/hserve/v1.7/censor-msg/"
        static let sendSmsCode = "/hserve/v1.8/sms-verification-code/"
        static let verifySmsCode = "/hserve/v1.8/sms-verification-code/verify/"

        static let videoSnapshot = "/hserve/v1/media/video-snapshot/"
        static let m3u8Concat = "/hserve/v1/media/m3u8-concat/"
        static let m3u8Clip =  "/hserve/v1/media/m3u8-clip/"
        static let m3u8Meta = "/hserve/v1/media/m3u8-meta/"
        static let videoAudioMeta = "/hserve/v1/media/audio-video-meta/"
    }

    struct BaaS {
        static let cloudFunction = "/hserve/v1/cloud-function/job/"
        static let sendSmsCode = "/hserve/v2.1/sms-verification-code/"
        static let verifySmsCode = "/hserve/v1.8/sms-verification-code/verify/"
        static let serverTime = "/hserve/v2.2/server/time/"
    }

    struct Pay {
        static let pay = "/hserve/v2.0/idp/pay/order/"
        static func order(transactionID: String) -> String { return "/hserve/v2.0/idp/pay/order/\(transactionID)/" }
        static let orderList = "/hserve/v2.0/idp/pay/order/"
    }
}
