//
//  CurrentUserTestCase.swift
//  MinCloudTests
//
//  Created by pengquanhua on 2019/4/11.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class CurrentUserTestCase: XCTestCase {

    var currentUser: CurrentUser!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        BaaS.register(clientID: "fdc4feb5403a985fe681")
        let testBundle = Bundle(for: type(of: self))
        let fileUrl = testBundle.url(forResource: "testcase", withExtension: "plist")
        let data = NSDictionary(contentsOf: fileUrl!)
        Storage.shared.token = data?.getString("token")
        Storage.shared.expiresIn = data?.getDouble("expireIn")
        Storage.shared.userId = data?.getInt64("userId")
    }

    override func tearDown() {
        self.currentUser = nil
    }

    // 获取当前用户
    func testGetCurrentUser() {

        let promise = expectation(description: "Status code: 201")
        Auth.getCurrentUser { (currentUser, error) in
            XCTAssertNotNil(currentUser, "当前用户为空")
            XCTAssertFalse(currentUser!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 更新用户名
    func testUpdateUserName() {
        let promise = expectation(description: "Status code: 201")
        Auth.getCurrentUser { (currentUser, error) in
            XCTAssertNotNil(currentUser, "当前用户为空")
            XCTAssertFalse(currentUser!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            currentUser?.updateUsername("0807_new", completion: { (result, error) in
                XCTAssertNotNil(result, "更新信息为空")
                XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

                promise.fulfill()
            })
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 更新邮箱地址
    func testUpdateEmail() {
        let promise = expectation(description: "Status code: 201")
        Auth.getCurrentUser { (currentUser, error) in
            XCTAssertNotNil(currentUser, "当前用户为空")
            XCTAssertFalse(currentUser!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            currentUser?.updateEmail("080701@ifanr.com", sendVerification: true, completion: { (result, error) in
                XCTAssertNotNil(result, "更新信息为空")
                XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

                promise.fulfill()
            })
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 更新密码
    func testUpdatePassword() {
        let promise = expectation(description: "Status code: 201")
        Auth.getCurrentUser { (currentUser, error) in
            XCTAssertNotNil(currentUser, "当前用户为空")
            XCTAssertFalse(currentUser!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            currentUser?.resetPassword(email: "080701@ifanr.com", completion: { (_, error) in
                XCTAssertTrue(error?.localizedDescription == "Can not reset password with unverified email.")

                promise.fulfill()
            })
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 更新用户信息(自定义字段)
    func testUpdateUserInfo() {
        let promise = expectation(description: "Status code: 201")
        Auth.getCurrentUser { (currentUser, error) in
            XCTAssertNotNil(currentUser, "当前用户为空")
            XCTAssertFalse(currentUser!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            currentUser?.updateUserInfo(["age": 19], completion: { (result, error) in
                XCTAssertNotNil(result, "更新信息为空")
                XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

                promise.fulfill()
            })
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 获取指定用户
    func testGetUser() {
        let promise = expectation(description: "Status code: 201")
        User.get(37308161491447) { (user, error) in
            XCTAssertNotNil(user, "用户为空")
            XCTAssertFalse(user!.userId == -1)
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 查询用户
    func testFindUsers() {
        let promise = expectation(description: "Status code: 201")

        User.find(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "数据列表为 nil")
            if listResult?.users?.count ?? 0 > 0 {
                XCTAssertNotNil(listResult?.users, "数据项 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
