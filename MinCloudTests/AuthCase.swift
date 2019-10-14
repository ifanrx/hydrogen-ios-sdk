//
//  AuthCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/16.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

class AuthCase: MinCloudCase {

    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_register_username() {
        let userDict = SampleData.Auth.registerUsername.toDictionary()
        Auth.register(username: "ifanr", password: "12345") { (user, error) in
            XCTAssertNotNil(user, "用户名注册失败")
            XCTAssertEqual(user?.Id, userDict?.getString("id"), "用户 id 不相等")
            XCTAssertEqual(user?.token, userDict?.getString("token"), "用户 token 不相等")
            XCTAssertEqual(user?.username, userDict?.getString("_username"), "用户 username 不相等")
            ModelCase.userEqual(user: user!, dict: userDict!)
            XCTAssertEqual(Auth.hadLogin, true, "用户登录失败")
        }
    }
    
    func test_register_email() {
        let userDict = SampleData.Auth.registerEmail.toDictionary()
        Auth.register(email: "ifanr@ifanr.com", password: "12345") { (user, error) in
            XCTAssertNotNil(user, "邮箱注册失败")
            XCTAssertEqual(user?.Id, userDict?.getString("id"), "用户 id 不相等")
            XCTAssertEqual(user?.token, userDict?.getString("token"), "用户 token 不相等")
            XCTAssertEqual(user?.email, userDict?.getString("_email"), "用户 email 不相等")
            ModelCase.userEqual(user: user!, dict: userDict!)
            XCTAssertEqual(Auth.hadLogin, true, "用户登录失败")
        }
    }
    
    func test_login_username() {
        let userDict = SampleData.Auth.loginUsername.toDictionary()
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            XCTAssertNotNil(user, "用户名登录失败")
            XCTAssertEqual(user?.Id, userDict?.getString("id"), "用户 id 不相等")
            XCTAssertEqual(user?.token, userDict?.getString("token"), "用户 token 不相等")
            XCTAssertEqual(user?.username, userDict?.getString("_username"), "用户 username 不相等")
            XCTAssertEqual(Auth.hadLogin, true, "用户登录失败")
        }
    }
    
    
    func test_login_email() {
        let userDict = SampleData.Auth.loginEmail.toDictionary()
        Auth.login(email: "ifanr@ifanr.com", password: "12345") { (user, error) in
            XCTAssertNotNil(user, "邮箱登录失败")
            XCTAssertEqual(user?.Id, userDict?.getString("id"), "用户 id 不相等")
            XCTAssertEqual(user?.token, userDict?.getString("token"), "用户 token 不相等")
            XCTAssertEqual(user?.email, userDict?.getString("_email"), "用户 email 不相等")
            XCTAssertEqual(Auth.hadLogin, true, "用户登录失败")
        }
    }
    
    func test_login_anonymous() {
        let userDict = SampleData.Auth.anonymous.toDictionary()
        Auth.anonymousLogin { (user, error) in
            XCTAssertNotNil(user, "匿名登录失败")
            XCTAssertEqual(user?.Id, userDict?.getString("id"), "用户 id 不相等")
            XCTAssertEqual(user?.token, userDict?.getString("token"), "用户 token 不相等")
            XCTAssertEqual(Auth.hadLogin, true, "用户登录失败")
        }
    }
    
    func test_logout() {
        Auth.logout { (success, error) in
            XCTAssertEqual(success, true, "用户登出失败")
            XCTAssertEqual(Auth.hadLogin, false, "用户登出失败")
        }
    }

}

extension AuthAPI {
    var testSampleData: Data {
        switch self {
        case .login(let loginType, _):
            switch loginType {
            case .username:
                return SampleData.Auth.loginUsername
            case .email:
                return SampleData.Auth.loginEmail
            case .anonymous:
                return SampleData.Auth.anonymous
            }
        case .register(let authType, _):
            switch authType {
            case .email:
                return SampleData.Auth.registerEmail
            case .username:
                return SampleData.Auth.registerUsername
            default:
                return Data()
            }
        case .logout:
            return "{}".data(using: String.Encoding.utf8)!
        }
    }
}

class AuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        guard let authAPI = target as? AuthAPI else {
            XCTFail("发送 AuthAPI 错误")
            return request
        }
        
        // 测试 path
        test_path(target: authAPI)
        
        // 测试 method
        test_method(target: authAPI)
        
        
        return request
    }
    
    private func test_path(target: AuthAPI) {
        let path = target.path
        switch target {
        case .login(let authType, _):
            XCTAssertEqual(path, Path.Auth.login(authType: authType))
        case .register(let authType, _):
            XCTAssertEqual(path, Path.Auth.register(authType: authType))
        case .logout:
            XCTAssertEqual(path, Path.Auth.logout)
        }
    }
    
    private func test_method(target: AuthAPI) {
        let method = target.method
        XCTAssertEqual(method, Moya.Method.post)
    }
    
    private func test_params(target: AuthAPI) {
        switch target {
        case .login(let authType, let params):
            if authType.rawValue == "username" {
                XCTAssertTrue(params.keys.contains("username"))
                XCTAssertTrue(params.keys.contains("password"))
            } else if authType.rawValue == "email" {
                XCTAssertTrue(params.keys.contains("email"))
                XCTAssertTrue(params.keys.contains("password"))
            }
        case .register(let authType, let params):
            if authType.rawValue == "username" {
                XCTAssertTrue(params.keys.contains("username"))
                XCTAssertTrue(params.keys.contains("password"))
            } else if authType.rawValue == "email" {
                XCTAssertTrue(params.keys.contains("email"))
                XCTAssertTrue(params.keys.contains("password"))
            }
        default: break
        }
    }
}




