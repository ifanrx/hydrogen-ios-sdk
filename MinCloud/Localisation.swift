//
//  Localisation.swift
//  MinCloud
//
//  Created by quanhua on 2020/3/17.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

protocol StringLocalable {
    static func localized(_ key: String) -> String
}

extension StringLocalable {
    static func localized(_ key: String) -> String {
        let bundlePath = Bundle.main.path(forResource: "MinCloud", ofType: "bundle") ?? ""
        if let bundle = Bundle(path: bundlePath) {
           let result = NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
            return result != key ? result : ""
        }
        return ""
    }
}

extension String {
    
    func format(_ arguments: CVarArg...) -> String {
        return String(format: self, arguments: arguments)
    }
}

public struct Localisation {
    
    public struct Wechat: StringLocalable {
        public static let registerAppId = { localized("RegisterWechatAppId") }()
        public static let authorizeFail = { localized("AuthorizeWechatUserInfoFailed") }()
    }
    
    public struct Weibo: StringLocalable {
        public static let registerAppId = { localized("RegisterWeiboAppId") }()
        public static let authorizeFail = { localized("AuthorizeWeiboUserInfoFailed") }()
    }
    
    public struct Apple: StringLocalable {
        public static let authorizeFail = { localized("AuthorizeAppleUserInfoFailed") }()
    }
    
    public struct Common: StringLocalable {
        public static let registerClientId = { localized("RegisterMinCloudAppId") }()
    }
}
