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
        BaaS.register(clientID: "196ba98487ebc358955d")
        let testBundle = Bundle(for: type(of: self))
        let fileUrl = testBundle.url(forResource: "testcase", withExtension: "plist")
        let data = NSDictionary(contentsOf: fileUrl!)
        Storage.shared.token = data?.getString("token")
        Storage.shared.expiresIn = data?.getDouble("expireIn")
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
}
