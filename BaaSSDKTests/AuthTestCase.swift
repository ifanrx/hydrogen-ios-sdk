//
//  AuthTestCase.swift
//  BaaSSDKTests
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import BaaSSDK

let timeout: TimeInterval = 30

class AuthTestCase: XCTestCase {

    var auth: Auth!
    override func setUp() {
        BaaS.register(clientID: "f86c122f10f45d1152a1")
    }

    override func tearDown() {
        auth = nil
    }

    // 用户名注册
    func testUsernameRegister() {

        let promise = expectation(description: "Status code: 201")
        Auth.register(username: "test29", password: "1111") { (user, error) in
            XCTAssertNotNil(user, "数据为空")
            XCTAssertFalse(user!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 注册
    func testEmailRegister() {

        let promise = expectation(description: "Status code: 201")
        Auth.register(email: "test12345@ifanr.com", password: "1111") { (user, error) in
            XCTAssertNotNil(user, "数据为空")
            XCTAssertFalse(user!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 用户名登录
    func testUsernameLogin() {
        let promise = expectation(description: "Status code: 201")
        Auth.login(username: "test29", password: "1111") { (user, error) in
            XCTAssertNotNil(user, "数据为空")
            XCTAssertFalse(user!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 用户名登录（未注册）
    func testUsernameLoginInNotRegister() {
        let promise = expectation(description: "Status code: 201")
        Auth.login(username: "test291", password: "1111") { (user, error) in
            XCTAssertNil(user, "未注册时应该返回空user")
            XCTAssertNotNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 邮件登录
    func testEmailLogin() {
        let promise = expectation(description: "Status code: 201")
        Auth.login(email: "test12345@ifanr.com", password: "1111") { (user, error) in
            XCTAssertNotNil(user, "数据为空")
            XCTAssertFalse(user!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 邮件登录（未注册）
    func testEmailLoginInNotRegister() {
        let promise = expectation(description: "Status code: 201")
        Auth.login(email: "test123456@ifanr.com", password: "1111") { (user, error) in
            XCTAssertNil(user, "未注册时应该返回空user")
            XCTAssertNotNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 匿名登录
    func testAnonymousLogin() {
        let promise = expectation(description: "Status code: 201")
        Auth.anonymousLogin({ (user, error) in
            XCTAssertNotNil(user, "数据为空")
            XCTAssertFalse(user!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
