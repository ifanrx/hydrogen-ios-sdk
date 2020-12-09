//
//  UserCase.swift
//  MinCloudTests
//
//  Created by quanhua on 2019/9/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud
@testable import Moya

var get_user_info_option = false  // select/expand

class UserCase: MinCloudCase {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: 获取用户
    
    func test_get_userInfo_option() {
        let dict = SampleData.User.userInfo_option.toDictionary()!
        get_user_info_option = true
        User.get("92812581396859", select: ["nickname", "created_by"], expand: ["created_by"]) {user, error in
            ModelCase.userEqual(user: user!, dict: dict)
            get_user_info_option = false
        }
    }
    
    func test_get_userInfo_all() {
        let dict = SampleData.User.userInfo.toDictionary()!
        User.get("92812581396859") {user, error in
            ModelCase.userEqual(user: user!, dict: dict)
        }
    }
    
    func test_user_list_option() {
        let dict = SampleData.User.userList_option.toDictionary()
        
        let whereAgrs = Where.compare("age", operator: .equalTo, value: 23)
        let query = Query()
        query.where = whereAgrs
        query.limit = 10
        query.offset = 0
        query.orderBy = ["created_at"]
        query.expand = ["created_by"]
        query.select = ["_username", "created_by"]
        User.find(query: query) {userList, error in
            ModelCase.userListEqual(userList: userList!, dict: dict!)
        }
    }
    
    
    // MARK: 当前用户
    
    func test_current_user() {
        let dict = SampleData.User.userInfo.toDictionary()
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            XCTAssertNotNil(user, "获取当前用户失败")
            Auth.getCurrentUser { (user, error) in
                XCTAssertNotNil(user, "获取当前用户失败")
                XCTAssertEqual(Storage.shared.token, user?.token)
                XCTAssertEqual(Storage.shared.expiresIn, user?.expiresIn)
                ModelCase.userEqual(user: user!, dict: dict!)
            }
        }
    }
    
    func test_current_user_not_login() {
        Auth.logout() { (success, error) in
            Auth.getCurrentUser { (user, error) in
                XCTAssertNil(user, "user 为 nil")
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            }
        }
    }
    
    func test_update_username() {
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            Auth.getCurrentUser {user, _ in
                XCTAssertNotNil(user, "获取当前用户失败")
                user?.updateUsername("ifanr_new", completion: { (userDict, error) in
                    XCTAssertNotNil(userDict, "更新用户名失败")
                })
            }
        }
    }
    
    func test_update_username_not_login() {
        Auth.logout() { (success, error) in
            let curUser = CurrentUser(Id: "92812581396859")
            curUser.updateUsername("ifanr_new", completion: { (userDict, error) in
                XCTAssertNil(userDict, "user 为 nil")
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            })
        }
    }
    
    func test_update_email() {
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            Auth.getCurrentUser {user, _ in
                XCTAssertNotNil(user, "获取当前用户失败")
                user?.updateEmail("ifanr_new@ifanr.com", completion: { (userDict, error) in
                    XCTAssertNotNil(userDict, "更新邮箱失败")
                })
            }
        }
    }
    
    func test_update_email_not_login() {
        Auth.logout() { (success, error) in
            let curUser = CurrentUser(Id: "92812581396859")
            curUser.updateEmail("ifanr_new@ifanr.com", completion: { (userDict, error) in
                XCTAssertNil(userDict, "user 为 nil")
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            })
        }
    }
    
    func test_update_pwd() {
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            Auth.getCurrentUser {user, _ in
                XCTAssertNotNil(user, "获取当前用户失败")
                user?.updatePassword("12345", newPassword: "123456") { (userDict, error) in
                    XCTAssertNotNil(userDict, "更新密码失败")
                }

            }
        }
    }
    
    func test_update_pwd_not_login() {
        Auth.logout() { (success, error) in
            let curUser = CurrentUser(Id: "92812581396859")
            curUser.updatePassword("12345", newPassword: "123456") { (userDict, error) in
                XCTAssertNil(userDict, "user 为 nil")
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            }
        }
    }
    
    func test_update_userinfo() {
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            Auth.getCurrentUser {user, _ in
                XCTAssertNotNil(user, "获取当前用户失败")
                user?.updateUserInfo(["city": "guangzhou"], completion: { (userDict, error) in
                    XCTAssertNotNil(userDict, "更新用户信息失败")
                })
            }
        }
    }
    
    func test_update_userinfo_not_login() {
        Auth.logout() { (success, error) in
            let curUser = CurrentUser(Id: "92812581396859")
            curUser.updateUserInfo(["city": "guangzhou"], completion: { (userDict, error) in
                XCTAssertNil(userDict, "user 为 nil")
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            })
        }
    }
    
    func test_request_email_verification() {
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            Auth.getCurrentUser {user, _ in
                XCTAssertNotNil(user, "获取当前用户失败")
                user?.requestEmailVerification{ (success, error) in
                    XCTAssertTrue(success, "发送邮件失败")
                }
            }
        }
    }
    
    func test_request_email_verification_not_login() {
        Auth.logout() { (success, error) in
            let curUser = CurrentUser(Id: "92812581396859")
            curUser.requestEmailVerification{ (success, error) in
                XCTAssertFalse(success)
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            }
        }
    }
    
    func test_reset_pwd_with_email() {
        Auth.login(username: "ifanr", password: "12345") { (user, error) in
            Auth.getCurrentUser {user, _ in
                XCTAssertNotNil(user, "获取当前用户失败")
                user?.resetPassword(email: "ifanr@ifanr.com", completion: { (success, error) in
                    XCTAssertTrue(success, "发送邮件失败")
                })
            }
        }
    }
    
    func test_reset_pwd_with_email_not_login() {
        Auth.logout() { (success, error) in
            let curUser = CurrentUser(Id: "92812581396859")
            curUser.resetPassword(email: "ifanr@ifanr.com", completion: { (success, error) in
                XCTAssertFalse(success)
                XCTAssertNotNil(error, "发生错误")
                XCTAssertEqual(error?.code, 604)
            })
        }
    }
}

extension UserAPI {
    var testSampleData: Data {
        switch self {
        case .getUserInfo:
            if get_user_info_option {
                return SampleData.User.userInfo_option
            }
            return SampleData.User.userInfo
        case .getUserList:
            return SampleData.User.userList_option
        case .updateAccount(let parameters):
            if let key = parameters.first?.key {
                if key == "username"{
                    return SampleData.User.updateUserName
                } else if key == "email" {
                    return SampleData.User.updateEmail
                } else {
                    return SampleData.User.updatePwd
                }
            }
            return Data()
        case .requestEmailVerify:
            return "{\"status\" : \"ok\"}".data(using: String.Encoding.utf8)!
        case .resetPassword:
            return "{\"status\" : \"ok\"}".data(using: String.Encoding.utf8)!
        default:
            return SampleData.User.userInfo
        }
    }
}


class UserPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        guard let api = target as? UserAPI else {
            XCTFail("发送 AuthAPI 错误")
            return request
        }
        
        // 测试 path
        test_path(target: api)
        
        // 测试 method
        test_method(target: api)
        
        // 测试参数
        test_params(target: api)
        
        
        return request
    }
    
    private func test_path(target: UserAPI) {
        let path = target.path
        switch target {
        case .getUserInfo:
            XCTAssertEqual(path, Path.User.getUserInfo(userId: "92812581396859"))
        case .updateAccount:
            XCTAssertEqual(path, Path.User.updateAccount)
        case .updateUserInfo:
            XCTAssertEqual(path, Path.User.updateUserInfo)
        case .resetPassword:
            XCTAssertEqual(path, Path.User.resetPassword)
        case .requestEmailVerify:
            XCTAssertEqual(path, Path.User.requestEmailVerify)
        case .getUserList:
            XCTAssertEqual(path, Path.User.getUserList)
            
        case .verifyPhone(parameters: let parameters):
            break
        }
    }
    
    private func test_method(target: UserAPI) {
        let method = target.method
        switch target {
        case .getUserInfo, .getUserList:
            XCTAssertEqual(method, Moya.Method.get)
        case .resetPassword, .requestEmailVerify:
            XCTAssertEqual(method, Moya.Method.post)
        case .updateAccount, .updateUserInfo:
            XCTAssertEqual(method, Moya.Method.put)
        case .verifyPhone(parameters: let parameters):
            break
        }
    }
    
    private func test_params(target: UserAPI) {
        switch target {
        case .getUserInfo(let userId, let parameters):
            if get_user_info_option == true {
                XCTAssertTrue(parameters.keys.contains("keys"))
                XCTAssertTrue(parameters.keys.contains("expand"))
            }
            XCTAssertEqual("92812581396859", userId)
        case .getUserList(let parameters):
            XCTAssertTrue(parameters.keys.contains("where"))
            XCTAssertTrue(parameters.keys.contains("keys"))
            XCTAssertTrue(parameters.keys.contains("expand"))
            XCTAssertTrue(parameters.keys.contains("limit"))
            XCTAssertTrue(parameters.keys.contains("offset"))
            XCTAssertTrue(parameters.keys.contains("order_by"))
        case .updateAccount(let parameters):
            let username = parameters.keys.contains("username")
            let email = parameters.keys.contains("email")
            let pwd = parameters.keys.contains("password") && parameters.keys.contains("new_password")
            XCTAssertTrue(username || email || pwd)
        case .updateUserInfo(let parameters):
            XCTAssertTrue(parameters.keys.contains("city"))
            XCTAssertEqual(parameters.getString("city"), "guangzhou")
        case .resetPassword(let parameters):
            XCTAssertTrue(parameters.keys.contains("email"))
            XCTAssertEqual("ifanr@ifanr.com", parameters.getString("email"))
        case .requestEmailVerify:
            break
        case .verifyPhone(parameters: let parameters):
            break
        }
    }
}
