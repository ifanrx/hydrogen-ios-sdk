//
//  ContentTestCase.swift
//  MinCloudTests
//
//  Created by pengquanhua on 2019/4/11.
//  Copyright © 2019 ifanr. All rights reserved.
//

import XCTest
@testable import MinCloud

class ContentTestCase: XCTestCase {

    var contentGroup: ContentGroup!
    var data: NSDictionary?
    override func setUp() {
        BaaS.register(clientID: "196ba98487ebc358955d")
        let testBundle = Bundle(for: type(of: self))
        let fileUrl = testBundle.url(forResource: "testcase", withExtension: "plist")
        data = NSDictionary(contentsOf: fileUrl!)
        Storage.shared.token = data?.getString("token")
        Storage.shared.expiresIn = data?.getDouble("expireIn")
        contentGroup = ContentGroup(Id: (data?.getInt64("contentGroupId"))!)
    }

    override func tearDown() {
        contentGroup = nil
    }

    func testGetContent() {
        let promise = expectation(description: "Status code: 201")

        let contentId = (data?.getInt64("contentId"))!
        contentGroup.get(contentId, select: ["title"]) { (content, error) in
            XCTAssertNotNil(content, "记录为 nil")
            XCTAssertNotNil(content!.Id, "记录 Id 无效")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testGetCategory() {
        let promise = expectation(description: "Status code: 201")

        let categoryId = (data?.getInt64("contentCategoryId"))!
        contentGroup.getCategory(categoryId) { (category, error) in
            XCTAssertNotNil(category, "记录为 nil")
            XCTAssertNotNil(category!.Id, "记录 Id 无效")
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testFindContentList() {
        let promise = expectation(description: "Status code: 201")

        contentGroup.find(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "内容列表为 nil")
            if listResult?.contents?.count ?? 0 > 0 {
                XCTAssertTrue(listResult?.contents?[0].Id != -1, "内容 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testFindCategoryList() {
        let promise = expectation(description: "Status code: 201")

        contentGroup.getCategoryList(completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "分类列表为 nil")
            if listResult?.contentCategorys?.count ?? 0 > 0 {
                XCTAssertTrue(listResult?.contentCategorys?[0].Id != -1, "分类 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testFindContentListInCategory() {
        let promise = expectation(description: "Status code: 201")

        let categoryId = (data?.getInt64("contentCategoryId"))!
        contentGroup.find(categoryId: categoryId, completion: { (listResult, error) in
            XCTAssertNotNil(listResult, "内容列表为 nil")
            if listResult?.contents?.count ?? 0 > 0 {
                XCTAssertTrue(listResult?.contents?[0].Id != -1, "内容 Id 无效")
            }
            XCTAssertNil(error, "发生错误: \(String(describing: error?.localizedDescription))")

            promise.fulfill()
        })

        waitForExpectations(timeout: timeout, handler: nil)
    }

}
