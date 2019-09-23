//
//  Contants.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
@testable import MinCloud

struct Path {
    static let environment: NetworkEnvironment = .production
    static var clientID: String!
    static var version: String {
        if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String {
            return version
        }
        return "0.2.0"
    }
    static var baseURL: String {
        if environment == .qa {
            return "https://viac2-p.eng-vm.can.corp.ifanr.com"
        }

        guard clientID != nil else {
            fatalError("请注册 clientID")
        }
        return "https://\(clientID!).myminapp.com"
    }

    static var HTTPHeaders: [String: String] {
        guard clientID != nil else { fatalError("请注册 clientID") }
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
    }

    struct User {
        static func getUserInfo(userId: String) -> String { return "/hserve/v2.1/user/info/\(userId)/" }
        static let updateAccount = "/hserve/v2.0/user/account/"
        static let resetPassword = "/hserve/v2.0/user/password/reset/"
        static let requestEmailVerify = "/hserve/v2.0/user/email-verify/"
        static let updateUserInfo = "/hserve/v2.1/user/info/"
        static let getUserList = "/hserve/v2.1/user/info/"
    }

    struct Table {
        static func recordDetail(tableId: String, recordId: String) -> String { return "/hserve/v2.1/table/\(tableId)/record/\(recordId)/" }
        static func recordList(tableId: String) -> String { return "/hserve/v2.1/table/\(tableId)/record/" }
        static func saveRecord(tableId: String) -> String { return "/hserve/v2.1/table/\(tableId)/record/" }
    }

    struct ContentGroup {
        static let contentList = "/hserve/v1.3/content/detail/"
        static let groupList = "/hserve/v1/content/group/"
        static func contentDetail(contentId: String) -> String { return "/hserve/v1.3/content/detail/\(contentId)/" }
        static let groupDetail = "/hserve/v1/content/category/"
        static let categoryList = "/hserve/v1/content/category/"
        static func categoryDetail(categoryId: String) -> String { return "/hserve/v1/content/category/\(categoryId)/" }
    }

    struct File {
        static let upload = "/hserve/v1/upload/"
        static func fileDetail(fileId: String) -> String { return "/hserve/v1.3/uploaded-file/\(fileId)/" }
        static let fileList = "/hserve/v1.3/uploaded-file/"
        static func deleteFile(fileId: String) -> String { return "/hserve/v1.3/uploaded-file/\(fileId)/" }
        static let deleteFiles = "/hserve/v1.3/uploaded-file/"
        static func categoryDetail(categoryId: String) -> String { return "/hserve/v1.3/file-category/\(categoryId)/" }
        static let fileCategoryList = "/hserve/v1.3/file-category/"
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
        static let sendSmsCode = "/hserve/v1.8/sms-verification-code/"
        static let verifySmsCode = "/hserve/v1.8/sms-verification-code/verify/"
    }

    struct Pay {
        static let pay = "/hserve/v2.0/idp/pay/order/"
        static func order(transactionID: String) -> String { return "/hserve/v2.0/idp/pay/order/\(transactionID)/" }
        static let orderList = "/hserve/v2.0/idp/pay/order/"
    }
}
