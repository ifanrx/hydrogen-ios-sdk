//
//  BaaSTestCase.swift
//  MinCloudTests
//
//  Created by pengquanhua on 2019/4/24.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class BaaSTestCase: XCTestCase {

    override func setUp() {
        BaaS.register(clientID: "fdc4feb5403a985fe681")
        let testBundle = Bundle(for: type(of: self))
        let fileUrl = testBundle.url(forResource: "testcase", withExtension: "plist")
        let data = NSDictionary(contentsOf: fileUrl!)
        Storage.shared.token = data?.getString("token")
        Storage.shared.expiresIn = data?.getDouble("expireIn")
        Storage.shared.userId = data?.getInt("userId")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // 云函数
    func testCloudFun() {
        let promise = expectation(description: "Status code: 201")

        BaaS.invoke(name: "helloWorld", data: ["name": "MinCloud"], sync: true) {result, error in
            XCTAssertNotNil(result, "记录为 nil")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    // 发送短信验证码
    func testSendCode() {
        let promise = expectation(description: "Status code: 201")

        BaaS.sendSmsCode(phone: "helloWorld") {result, error in
            XCTAssertTrue(result, "发送失败")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
